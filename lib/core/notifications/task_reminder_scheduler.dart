import 'dart:async';

import 'package:crypto/crypto.dart';
import 'package:logit/core/constants/hive_keys.dart';
import 'package:logit/features/task/domain/entities/task/task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

part 'task_reminder_scheduler.g.dart';

@Riverpod(keepAlive: true)
TaskReminderScheduler taskReminderScheduler(TaskReminderSchedulerRef ref) {
  return TaskReminderScheduler();
}

class TaskReminderScheduler {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final Box<dynamic> _settingsBox = Hive.box<dynamic>(HiveBoxNames.settings);
  final Set<String> _foregroundDeliveredSlots = <String>{};
  Timer? _foregroundTicker;
  bool _foregroundTickInProgress = false;
  bool _initialized = false;
  bool _permissionsRequested = false;

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }

    tz_data.initializeTimeZones();
    final timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
      defaultPresentBanner: true,
      defaultPresentList: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.createNotificationChannel(
      const AndroidNotificationChannel(
        'task_reminders',
        'Task reminders',
        description: 'Task due and reminder notifications',
        importance: Importance.max,
      ),
    );
    await _requestPermissions();
    _initialized = true;
  }

  void startForegroundReminderLoop({
    required Future<List<Task>> Function() loadTasks,
  }) {
    _foregroundTicker?.cancel();
    _foregroundTicker = Timer.periodic(const Duration(seconds: 20), (_) {
      unawaited(_deliverDueForegroundReminders(loadTasks));
    });
    unawaited(_deliverDueForegroundReminders(loadTasks));
  }

  void dispose() {
    _foregroundTicker?.cancel();
  }

  Future<void> syncForTasks(List<Task> tasks) async {
    await ensureInitialized();

    final trackedMap = _trackedNotificationMap();
    final taskIds = tasks.map((task) => task.id).toSet();

    for (final entry in trackedMap.entries) {
      if (taskIds.contains(entry.key)) {
        continue;
      }
      for (final notificationId in entry.value) {
        await _notifications.cancel(notificationId);
      }
      await _persistTrackedIds(entry.key, const <int>[]);
    }

    for (final task in tasks) {
      await syncForTask(task);
    }
  }

  Future<void> syncForTask(Task task) async {
    await ensureInitialized();
    final trackedIds = _trackedNotificationIds(task.id);
    for (final id in trackedIds) {
      await _notifications.cancel(id);
    }
    await _notifications.cancel(_legacyNotificationId(task.id));

    if (_isFinished(task)) {
      await _persistTrackedIds(task.id, const <int>[]);
      return;
    }

    final reminders = _effectiveReminders(task);
    if (reminders.isEmpty) {
      await _persistTrackedIds(task.id, const <int>[]);
      return;
    }

    await _requestPermissions();
    final now = DateTime.now();
    final scheduledIds = <int>[];

    for (final reminder in reminders) {
      final nextReminder = _resolveNextReminderDateTime(task, reminder, now);
      if (nextReminder == null) {
        continue;
      }

      final notificationId = _notificationId(task.id, reminder.id);
      final zonedDateTime = tz.TZDateTime.from(nextReminder, tz.local);
      final details = _notificationDetails();

      try {
        await _notifications.zonedSchedule(
          notificationId,
          _titleFor(task),
          task.title,
          zonedDateTime,
          details,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: '${task.id}:${reminder.id}',
        );
      } catch (_) {
        await _notifications.zonedSchedule(
          notificationId,
          _titleFor(task),
          task.title,
          zonedDateTime,
          details,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: '${task.id}:${reminder.id}',
        );
      }
      scheduledIds.add(notificationId);
    }

    await _persistTrackedIds(task.id, scheduledIds);
  }

  Future<void> cancelForTaskId(String taskId) async {
    await ensureInitialized();
    final trackedIds = _trackedNotificationIds(taskId);
    for (final id in trackedIds) {
      await _notifications.cancel(id);
    }
    await _notifications.cancel(_legacyNotificationId(taskId));
    await _persistTrackedIds(taskId, const <int>[]);
  }

  bool hasUpcomingOccurrence(
    Task task,
    TaskReminder reminder, {
    DateTime? now,
  }) {
    return _resolveNextReminderDateTime(
          task,
          reminder,
          now ?? DateTime.now(),
        ) !=
        null;
  }

  DateTime? _resolveNextReminderDateTime(
    Task task,
    TaskReminder reminder,
    DateTime now,
  ) {
    final reminderStart = _toDateOnly(reminder.date);
    final taskStart = _toDateOnly(task.scheduledAt);
    final start = reminderStart.isAfter(taskStart) ? reminderStart : taskStart;
    final end = task.endDate == null ? null : _toDateOnly(task.endDate!);
    final reminderMinute = reminder.minuteOfDay;

    if (!reminder.repeatsDaily) {
      if (end != null && start.isAfter(end)) {
        return null;
      }
      final candidate = _combine(start, reminderMinute);
      return candidate.isAfter(now) ? candidate : null;
    }

    var day = _toDateOnly(now);

    if (day.isBefore(start)) {
      day = start;
    }

    while (end == null || !day.isAfter(end)) {
      final next = _combine(day, reminderMinute);
      if (next.isAfter(now)) {
        return next;
      }
      day = day.add(const Duration(days: 1));
    }

    return null;
  }

  String _titleFor(Task task) {
    final emoji = task.iconKey.trim();
    if (_isEmoji(emoji)) {
      return '$emoji Complete the task';
    }
    return 'Complete the task';
  }

  bool _isEmoji(String value) {
    if (value.isEmpty) {
      return false;
    }
    return value.runes.any((rune) => rune > 127);
  }

  bool _isFinished(Task task) {
    if (task.isCompleted) {
      return true;
    }
    return task.subtasks.isNotEmpty &&
        task.subtasks.every((subtask) => subtask.isCompleted);
  }

  int _notificationId(String taskId, String reminderId) {
    final bytes = sha1.convert('$taskId:$reminderId'.codeUnits).bytes;
    final firstFour = bytes.take(4).toList(growable: false);
    var value = 0;
    for (final byte in firstFour) {
      value = (value << 8) | byte;
    }
    return value & 0x7fffffff;
  }

  int _legacyNotificationId(String taskId) {
    final bytes = sha1.convert(taskId.codeUnits).bytes;
    final firstFour = bytes.take(4).toList(growable: false);
    var value = 0;
    for (final byte in firstFour) {
      value = (value << 8) | byte;
    }
    return value & 0x7fffffff;
  }

  DateTime _toDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _combine(DateTime day, int minuteOfDay) {
    final hour = minuteOfDay ~/ 60;
    final minute = minuteOfDay % 60;
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'task_reminders',
        'Task reminders',
        channelDescription: 'Task due and reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
        interruptionLevel: InterruptionLevel.active,
      ),
    );
  }

  Future<void> _deliverDueForegroundReminders(
    Future<List<Task>> Function() loadTasks,
  ) async {
    if (_foregroundTickInProgress) {
      return;
    }
    if (!_isAppInForeground()) {
      return;
    }

    _foregroundTickInProgress = true;
    try {
      await ensureInitialized();
      final tasks = await loadTasks();
      final now = DateTime.now();
      final nowDay = _toDateOnly(now);
      final nowMinuteOfDay = now.hour * 60 + now.minute;

      _purgeOldDeliveredSlots(nowDay);

      for (final task in tasks) {
        if (_isFinished(task)) {
          continue;
        }

        for (final reminder in _effectiveReminders(task)) {
          if (!_isDueNow(task, reminder, nowDay, nowMinuteOfDay)) {
            continue;
          }
          final slotKey = _deliverySlotKey(task.id, reminder.id, nowDay);
          if (!_foregroundDeliveredSlots.add(slotKey)) {
            continue;
          }

          final notificationId = _notificationId(task.id, reminder.id);
          await _notifications.cancel(notificationId);
          await _notifications.show(
            notificationId,
            _titleFor(task),
            task.title,
            _notificationDetails(),
            payload: '${task.id}:${reminder.id}',
          );
          await syncForTask(task);
        }
      }
    } finally {
      _foregroundTickInProgress = false;
    }
  }

  bool _isAppInForeground() {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle == null) {
      return true;
    }
    return lifecycle == AppLifecycleState.resumed ||
        lifecycle == AppLifecycleState.inactive;
  }

  bool _isDueNow(
    Task task,
    TaskReminder reminder,
    DateTime currentDay,
    int currentMinuteOfDay,
  ) {
    if (reminder.minuteOfDay != currentMinuteOfDay) {
      return false;
    }

    final taskStart = _toDateOnly(task.scheduledAt);
    final reminderStart = _toDateOnly(reminder.date);
    final start = reminderStart.isAfter(taskStart) ? reminderStart : taskStart;
    final end = task.endDate == null ? null : _toDateOnly(task.endDate!);

    if (currentDay.isBefore(start)) {
      return false;
    }
    if (end != null && currentDay.isAfter(end)) {
      return false;
    }

    if (!reminder.repeatsDaily) {
      return _isSameDate(currentDay, start);
    }
    return true;
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _deliverySlotKey(String taskId, String reminderId, DateTime day) {
    return '$taskId:$reminderId:${day.year}-${day.month}-${day.day}';
  }

  void _purgeOldDeliveredSlots(DateTime currentDay) {
    _foregroundDeliveredSlots.removeWhere((entry) {
      final parts = entry.split(':');
      if (parts.length < 5) {
        return true;
      }
      final year = int.tryParse(parts[2]);
      final month = int.tryParse(parts[3]);
      final day = int.tryParse(parts[4]);
      if (year == null || month == null || day == null) {
        return true;
      }
      final slotDay = DateTime(year, month, day);
      return slotDay.isBefore(currentDay);
    });
  }

  Future<void> _requestPermissions() async {
    if (_permissionsRequested) {
      return;
    }
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.requestNotificationsPermission();

    final iosImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    _permissionsRequested = true;
  }

  List<TaskReminder> _effectiveReminders(Task task) {
    if (task.reminders.isNotEmpty) {
      return task.reminders;
    }
    if (task.reminderDate != null && task.reminderMinuteOfDay != null) {
      return <TaskReminder>[
        TaskReminder(
          id: 'legacy_${task.id}',
          date: task.reminderDate!,
          minuteOfDay: task.reminderMinuteOfDay!,
          repeatsDaily: false,
        ),
      ];
    }
    return const <TaskReminder>[];
  }

  List<int> _trackedNotificationIds(String taskId) {
    return _trackedNotificationMap()[taskId] ?? const <int>[];
  }

  Map<String, List<int>> _trackedNotificationMap() {
    final raw = _settingsBox.get(
      HiveSettingsKeys.scheduledReminderNotificationIds,
      defaultValue: <String, dynamic>{},
    );
    if (raw is! Map) {
      return <String, List<int>>{};
    }

    final result = <String, List<int>>{};
    for (final entry in raw.entries) {
      final taskId = entry.key.toString();
      final value = entry.value;
      if (value is! List) {
        continue;
      }
      final ids = value
          .map((id) => id is num ? id.toInt() : null)
          .whereType<int>()
          .toSet()
          .toList(growable: false);
      if (ids.isNotEmpty) {
        result[taskId] = ids;
      }
    }
    return result;
  }

  Future<void> _persistTrackedIds(String taskId, List<int> ids) async {
    final map = _trackedNotificationMap();
    if (ids.isEmpty) {
      map.remove(taskId);
    } else {
      map[taskId] = ids.toSet().toList(growable: false);
    }
    await _settingsBox.put(
      HiveSettingsKeys.scheduledReminderNotificationIds,
      map,
    );
  }
}
