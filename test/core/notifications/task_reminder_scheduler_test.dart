import 'dart:io';

import 'package:logit/core/constants/hive_keys.dart';
import 'package:logit/core/notifications/task_reminder_scheduler.dart';
import 'package:logit/features/task/domain/entities/task/task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory hiveTempDir;
  late Box<dynamic> settingsBox;
  late TaskReminderScheduler scheduler;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    hiveTempDir = await Directory.systemTemp.createTemp(
      'logit_reminder_scheduler_test_',
    );
    Hive.init(hiveTempDir.path);
    settingsBox = await Hive.openBox<dynamic>(HiveBoxNames.settings);
    scheduler = TaskReminderScheduler();
  });

  tearDownAll(() async {
    await settingsBox.close();
    await Hive.close();
    if (await hiveTempDir.exists()) {
      await hiveTempDir.delete(recursive: true);
    }
  });

  test('one-time reminder is upcoming only before reminder minute', () {
    final now = DateTime(2026, 2, 24, 10, 0);
    final task = _task(
      scheduledAt: DateTime(2026, 2, 24),
      reminders: [
        _reminder(date: DateTime(2026, 2, 24), minuteOfDay: 10 * 60 + 30),
      ],
    );

    expect(
      scheduler.hasUpcomingOccurrence(task, task.reminders.first, now: now),
      isTrue,
    );
    expect(
      scheduler.hasUpcomingOccurrence(
        task,
        task.reminders.first,
        now: DateTime(2026, 2, 24, 10, 30),
      ),
      isFalse,
    );
    expect(
      scheduler.hasUpcomingOccurrence(
        task,
        task.reminders.first,
        now: DateTime(2026, 2, 24, 10, 31),
      ),
      isFalse,
    );
  });

  test('daily reminder has upcoming occurrence for every minute of day', () {
    final task = _task(
      scheduledAt: DateTime(2026, 2, 24),
      endDate: null,
      reminders: [
        _reminder(
          date: DateTime(2026, 2, 24),
          minuteOfDay: 0,
          repeatsDaily: true,
        ),
      ],
    );

    for (var minute = 0; minute < 24 * 60; minute++) {
      final now = DateTime(2026, 2, 24, minute ~/ 60, minute % 60);
      final reminder = task.reminders.first.copyWith(minuteOfDay: minute);

      expect(
        scheduler.hasUpcomingOccurrence(task, reminder, now: now),
        isTrue,
        reason: 'Expected upcoming occurrence for minute $minute',
      );
    }
  });

  test('daily reminder does not continue beyond task end date', () {
    final reminder = _reminder(
      date: DateTime(2026, 2, 24),
      minuteOfDay: 8 * 60,
      repeatsDaily: true,
    );
    final task = _task(
      scheduledAt: DateTime(2026, 2, 24),
      endDate: DateTime(2026, 2, 24),
      reminders: [reminder],
    );

    expect(
      scheduler.hasUpcomingOccurrence(
        task,
        reminder,
        now: DateTime(2026, 2, 24, 8, 1),
      ),
      isFalse,
    );
  });

  test(
    'daily reminder is not upcoming at exact reminder minute on end date',
    () {
      final reminder = _reminder(
        date: DateTime(2026, 2, 24),
        minuteOfDay: 8 * 60,
        repeatsDaily: true,
      );
      final task = _task(
        scheduledAt: DateTime(2026, 2, 24),
        endDate: DateTime(2026, 2, 24),
        reminders: [reminder],
      );

      expect(
        scheduler.hasUpcomingOccurrence(
          task,
          reminder,
          now: DateTime(2026, 2, 24, 8, 0),
        ),
        isFalse,
      );
    },
  );

  test('one-time reminder minute sweep validates boundary at midnight', () {
    final task = _task(
      scheduledAt: DateTime(2026, 2, 24),
      reminders: [_reminder(date: DateTime(2026, 2, 24), minuteOfDay: 0)],
    );
    final now = DateTime(2026, 2, 24, 0, 0);

    for (var minute = 0; minute < 24 * 60; minute++) {
      final reminder = task.reminders.first.copyWith(minuteOfDay: minute);
      final hasUpcoming = scheduler.hasUpcomingOccurrence(
        task,
        reminder,
        now: now,
      );
      expect(
        hasUpcoming,
        minute > 0,
        reason:
            'Minute $minute should be ${minute > 0 ? 'upcoming' : 'not upcoming'}',
      );
    }
  });
}

Task _task({
  required DateTime scheduledAt,
  DateTime? endDate,
  required List<TaskReminder> reminders,
}) {
  final createdAt = DateTime(2026, 2, 24, 9, 0);
  return Task(
    id: 'task-1',
    title: 'Task',
    scheduledAt: scheduledAt,
    endDate: endDate,
    reminders: reminders,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

TaskReminder _reminder({
  required DateTime date,
  required int minuteOfDay,
  bool repeatsDaily = false,
}) {
  return TaskReminder(
    id: 'rem-1',
    date: date,
    minuteOfDay: minuteOfDay,
    repeatsDaily: repeatsDaily,
  );
}
