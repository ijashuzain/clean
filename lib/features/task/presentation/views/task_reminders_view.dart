import 'package:logit/features/task/domain/entities/task/task.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TaskRemindersArgs {
  final String taskTitle;
  final List<TaskReminder> reminders;
  final DateTime startDate;
  final DateTime? endDate;
  final bool readOnly;
  final int? maxReminderCount;
  final bool allowRepeatingReminders;

  const TaskRemindersArgs({
    required this.taskTitle,
    required this.reminders,
    required this.startDate,
    required this.endDate,
    required this.readOnly,
    int? maxReminderCount,
    this.allowRepeatingReminders = true,
  }) : maxReminderCount = maxReminderCount == null
           ? null
           : (maxReminderCount < 0 ? 0 : maxReminderCount);
}

class TaskRemindersView extends StatefulWidget {
  final TaskRemindersArgs args;

  const TaskRemindersView({super.key, required this.args});

  @override
  State<TaskRemindersView> createState() => _TaskRemindersViewState();
}

class _TaskRemindersViewState extends State<TaskRemindersView> {
  late List<TaskReminder> _reminders;

  @override
  void initState() {
    super.initState();
    _reminders = widget.args.reminders.toList(growable: true);
    _cleanupPastReminders();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _closeWithResult();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _closeWithResult,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('Reminders'),
          actions: [
            if (!widget.args.readOnly)
              IconButton(
                tooltip: 'Add reminder',
                onPressed: _addReminder,
                icon: const Icon(Icons.add_alarm_rounded),
              ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.args.taskTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage local reminder notifications for this task.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _reminders.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.notifications_off_outlined),
                              const SizedBox(height: 8),
                              Text(
                                'No upcoming reminders',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              if (!widget.args.readOnly) ...[
                                const SizedBox(height: 6),
                                Text(
                                  _emptyStateHintText(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _reminders.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final reminder = _reminders[index];
                            final dayLabel = DateFormat(
                              'EEE, d MMM yyyy',
                            ).format(_toDateOnly(reminder.date));
                            return Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF2F333D)
                                      : const Color(0xFFE3E0D5),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                leading: const Icon(Icons.alarm_rounded),
                                title: Text(
                                  _formatMinute(reminder.minuteOfDay),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  reminder.repeatsDaily
                                      ? '$dayLabel • repeats daily'
                                      : dayLabel,
                                ),
                                trailing: widget.args.readOnly
                                    ? null
                                    : PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _editReminder(reminder);
                                            return;
                                          }
                                          _deleteReminder(reminder.id);
                                        },
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Text('Edit'),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      ),
                                onTap: widget.args.readOnly
                                    ? null
                                    : () => _editReminder(reminder),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addReminder() async {
    final maxReminderCount = widget.args.maxReminderCount;
    if (maxReminderCount != null && _reminders.length >= maxReminderCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only add up to $maxReminderCount reminder(s)'),
        ),
      );
      return;
    }
    final reminder = await _openEditor();
    if (reminder == null) {
      return;
    }
    setState(() {
      _reminders.add(reminder);
      _reminders = _sorted(_reminders);
    });
  }

  Future<void> _editReminder(TaskReminder current) async {
    final reminder = await _openEditor(initial: current);
    if (reminder == null) {
      return;
    }
    setState(() {
      final index = _reminders.indexWhere((item) => item.id == current.id);
      if (index == -1) {
        _reminders.add(reminder);
      } else {
        _reminders[index] = reminder;
      }
      _reminders = _sorted(_reminders);
    });
  }

  void _deleteReminder(String reminderId) {
    setState(() {
      _reminders.removeWhere((item) => item.id == reminderId);
    });
  }

  Future<TaskReminder?> _openEditor({TaskReminder? initial}) async {
    final now = DateTime.now();
    var selectedDate = _toDateOnly(initial?.date ?? widget.args.startDate);
    var selectedMinute = initial?.minuteOfDay;
    var repeatsDaily = initial?.repeatsDaily ?? false;
    if (initial == null && !widget.args.allowRepeatingReminders) {
      repeatsDaily = false;
    }

    return showModalBottomSheet<TaskReminder>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: _toDateOnly(widget.args.startDate),
                lastDate: _toDateOnly(
                  widget.args.endDate ?? DateTime(now.year + 6),
                ),
              );
              if (picked == null) {
                return;
              }
              setModalState(() {
                selectedDate = _toDateOnly(picked);
              });
            }

            Future<void> pickTime() async {
              final initialTime = selectedMinute == null
                  ? TimeOfDay.now()
                  : TimeOfDay(
                      hour: selectedMinute! ~/ 60,
                      minute: selectedMinute! % 60,
                    );
              final picked = await showTimePicker(
                context: context,
                initialTime: initialTime,
              );
              if (picked == null) {
                return;
              }
              setModalState(() {
                selectedMinute = picked.hour * 60 + picked.minute;
              });
            }

            final dateLabel = DateFormat(
              'EEE, d MMM yyyy',
            ).format(selectedDate);
            final timeLabel = selectedMinute == null
                ? 'Pick time'
                : _formatMinute(selectedMinute!);

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    initial == null ? 'Add reminder' : 'Edit reminder',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: pickDate,
                          icon: const Icon(
                            Icons.calendar_month_rounded,
                            size: 18,
                          ),
                          label: Text(dateLabel),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: pickTime,
                          icon: const Icon(Icons.alarm_rounded, size: 18),
                          label: Text(timeLabel),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (widget.args.allowRepeatingReminders)
                    SwitchListTile.adaptive(
                      value: repeatsDaily,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Repeat daily'),
                      subtitle: const Text('Repeat this reminder every day'),
                      onChanged: (value) {
                        setModalState(() => repeatsDaily = value);
                      },
                    ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedMinute == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reminder time is required'),
                            ),
                          );
                          return;
                        }
                        final endDate = widget.args.endDate == null
                            ? null
                            : _toDateOnly(widget.args.endDate!);
                        if (selectedDate.isBefore(
                          _toDateOnly(widget.args.startDate),
                        )) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Reminder date cannot be before task start date',
                              ),
                            ),
                          );
                          return;
                        }
                        if (endDate != null && selectedDate.isAfter(endDate)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Reminder date must be within task date range',
                              ),
                            ),
                          );
                          return;
                        }

                        final when = _combine(selectedDate, selectedMinute!);
                        if (!repeatsDaily && !when.isAfter(DateTime.now())) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'One-time reminder must be in the future',
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.of(context).pop(
                          TaskReminder(
                            id:
                                initial?.id ??
                                DateTime.now().microsecondsSinceEpoch
                                    .toString(),
                            date: selectedDate,
                            minuteOfDay: selectedMinute!,
                            repeatsDaily: repeatsDaily,
                          ),
                        );
                      },
                      child: Text(
                        initial == null ? 'Add reminder' : 'Save reminder',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _cleanupPastReminders() {
    final now = DateTime.now();
    _reminders = _reminders
        .where((reminder) => _hasUpcomingOccurrence(reminder, now))
        .toList(growable: true);
    _reminders = _sorted(_reminders);
  }

  bool _hasUpcomingOccurrence(TaskReminder reminder, DateTime now) {
    final day = _toDateOnly(reminder.date);
    final end = widget.args.endDate == null
        ? null
        : _toDateOnly(widget.args.endDate!);
    if (!reminder.repeatsDaily) {
      final when = _combine(day, reminder.minuteOfDay);
      return when.isAfter(now);
    }

    var cursor = _toDateOnly(now);
    if (cursor.isBefore(day)) {
      cursor = day;
    }

    while (end == null || !cursor.isAfter(end)) {
      final when = _combine(cursor, reminder.minuteOfDay);
      if (when.isAfter(now)) {
        return true;
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    return false;
  }

  List<TaskReminder> _sorted(List<TaskReminder> reminders) {
    reminders.sort((a, b) {
      final dateCompare = _toDateOnly(a.date).compareTo(_toDateOnly(b.date));
      if (dateCompare != 0) {
        return dateCompare;
      }
      return a.minuteOfDay.compareTo(b.minuteOfDay);
    });
    return reminders;
  }

  void _closeWithResult() {
    context.pop(_reminders.toList(growable: false));
  }

  DateTime _toDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _combine(DateTime date, int minute) {
    return DateTime(date.year, date.month, date.day, minute ~/ 60, minute % 60);
  }

  String _formatMinute(int minuteOfDay) {
    final time = TimeOfDay(hour: minuteOfDay ~/ 60, minute: minuteOfDay % 60);
    return time.format(context);
  }

  String _emptyStateHintText() {
    if (widget.args.allowRepeatingReminders) {
      return 'Add one or more reminders with optional daily repeat.';
    }
    final maxReminderCount = widget.args.maxReminderCount;
    if (maxReminderCount == null || maxReminderCount > 1) {
      return 'Add one or more reminders without daily repeat.';
    }
    return 'Add one reminder without daily repeat.';
  }
}
