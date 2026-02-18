import 'package:crypto/crypto.dart';
import 'package:logit/features/task/domain/entities/task/task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
    _initialized = true;
  }

  Future<void> syncForTasks(List<Task> tasks) async {
    if (tasks.every(
      (task) => task.reminderDate == null || task.reminderMinuteOfDay == null,
    )) {
      return;
    }
    await ensureInitialized();
    for (final task in tasks) {
      await syncForTask(task);
    }
  }

  Future<void> syncForTask(Task task) async {
    await ensureInitialized();
    final id = _notificationId(task.id);
    await _notifications.cancel(id);

    if (_isFinished(task)) {
      return;
    }

    final nextReminder = _resolveNextReminderDateTime(task, DateTime.now());
    if (nextReminder == null) {
      return;
    }
    await _requestPermissions();

    final zonedDateTime = tz.TZDateTime.from(nextReminder, tz.local);
    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        'task_reminders',
        'Task reminders',
        channelDescription: 'Task due and reminder notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
        interruptionLevel: InterruptionLevel.active,
      ),
    );

    try {
      await _notifications.zonedSchedule(
        id,
        _titleFor(task),
        task.title,
        zonedDateTime,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: task.id,
      );
    } catch (_) {
      await _notifications.zonedSchedule(
        id,
        _titleFor(task),
        task.title,
        zonedDateTime,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: task.id,
      );
    }
  }

  Future<void> cancelForTaskId(String taskId) async {
    await ensureInitialized();
    await _notifications.cancel(_notificationId(taskId));
  }

  DateTime? _resolveNextReminderDateTime(Task task, DateTime now) {
    final reminderDate = task.reminderDate;
    final reminderMinute = task.reminderMinuteOfDay;
    if (reminderDate == null || reminderMinute == null) {
      return null;
    }

    var day = _toDateOnly(reminderDate);
    final candidate = _combine(day, reminderMinute);
    if (candidate.isAfter(now)) {
      return candidate;
    }

    final hasDateRange = task.endDate != null;
    if (!task.repeatsDaily && !hasDateRange) {
      return null;
    }

    final start = _toDateOnly(task.scheduledAt);
    final end = task.endDate == null ? null : _toDateOnly(task.endDate!);
    day = _toDateOnly(now);

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

  int _notificationId(String taskId) {
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
}
