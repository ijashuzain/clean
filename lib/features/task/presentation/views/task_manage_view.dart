import 'package:logit/core/widgets/custom_text_field.dart';
import 'package:logit/core/widgets/primary_button.dart';
import 'package:logit/features/task/domain/entities/task/task.dart';
import 'package:logit/features/task/presentation/providers/task_timeline_provider/task_timeline_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TaskManageView extends ConsumerStatefulWidget {
  final String? taskId;

  const TaskManageView({super.key, this.taskId});

  @override
  ConsumerState<TaskManageView> createState() => _TaskManageViewState();
}

class _TaskManageViewState extends ConsumerState<TaskManageView> {
  final _titleController = TextEditingController();
  final _topicController = TextEditingController();
  final _emojiController = TextEditingController();
  final _noteController = TextEditingController();
  final List<_SubTaskDraft> _subTaskDrafts = [];
  final _emojiFormatter = _EmojiOnlyFormatter();

  DateTime? _scheduledDate;
  DateTime? _endDate;
  int? _startMinuteOfDay;
  int? _endMinuteOfDay;
  DateTime? _reminderDate;
  int? _reminderMinuteOfDay;
  bool _reminderEnabled = false;
  bool _repeatsDaily = false;
  bool _loadingTask = false;
  bool _isReadOnlyCompletedPastTask = false;

  @override
  void initState() {
    super.initState();
    final selectedDate = _toDateOnly(
      ref.read(taskTimelineProviderProvider).selectedDate,
    );
    final today = _toDateOnly(DateTime.now());
    _scheduledDate = widget.taskId == null && selectedDate.isBefore(today)
        ? today
        : selectedDate;
    _addSubTaskField();
    if (widget.taskId != null) {
      _prefillTask(widget.taskId!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    _emojiController.dispose();
    _noteController.dispose();
    for (final draft in _subTaskDrafts) {
      draft.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _prefillTask(String taskId) async {
    setState(() => _loadingTask = true);
    final task = await ref
        .read(taskTimelineProviderProvider.notifier)
        .getTaskById(taskId);
    if (!mounted) {
      return;
    }

    if (task != null) {
      _titleController.text = task.title;
      _topicController.text = task.topic;
      _emojiController.text = _containsEmojiRune(task.iconKey)
          ? task.iconKey
          : '';
      _noteController.text = task.note;
      _scheduledDate = task.scheduledAt;
      _endDate = task.endDate;
      _startMinuteOfDay = task.startMinuteOfDay;
      _endMinuteOfDay = task.endMinuteOfDay;
      _reminderDate = task.reminderDate;
      _reminderMinuteOfDay = task.reminderMinuteOfDay;
      _reminderEnabled =
          task.reminderDate != null || task.reminderMinuteOfDay != null;
      _repeatsDaily = task.repeatsDaily;
      _isReadOnlyCompletedPastTask = _isPreviousDayCompletedTask(task);

      for (final draft in _subTaskDrafts) {
        draft.controller.dispose();
      }
      _subTaskDrafts
        ..clear()
        ..addAll(
          task.subtasks.map(
            (subtask) => _SubTaskDraft(
              id: subtask.id,
              controller: TextEditingController(text: subtask.title),
              completed: subtask.isCompleted,
            ),
          ),
        );
      if (_subTaskDrafts.isEmpty) {
        _addSubTaskField();
      }
    }

    setState(() => _loadingTask = false);
  }

  void _addSubTaskField() {
    setState(
      () => _subTaskDrafts.add(
        _SubTaskDraft(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          controller: TextEditingController(),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = _toDateOnly(now);
    final isCreating = widget.taskId == null;
    final initialDateCandidate = _scheduledDate ?? today;
    final initialDate = isCreating && initialDateCandidate.isBefore(today)
        ? today
        : initialDateCandidate;
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isCreating ? today : DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (selected != null) {
      setState(() {
        _scheduledDate = DateTime(selected.year, selected.month, selected.day);
        if (_endDate != null && _endDate!.isBefore(_scheduledDate!)) {
          _endDate = null;
        }
        if (_reminderDate != null &&
            _toDateOnly(
              _reminderDate!,
            ).isBefore(_toDateOnly(_scheduledDate!))) {
          _reminderDate = null;
          _reminderMinuteOfDay = null;
        }
        _coerceReminderDateForScope();
      });
    }
  }

  Future<void> _pickEndDate() async {
    final start = _scheduledDate ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _endDate ?? start,
      firstDate: DateTime(start.year, start.month, start.day),
      lastDate: DateTime(start.year + 6),
    );

    if (selected != null) {
      setState(() {
        _endDate = DateTime(selected.year, selected.month, selected.day);
        if (_reminderDate != null &&
            _toDateOnly(_reminderDate!).isAfter(_toDateOnly(_endDate!))) {
          _reminderDate = null;
          _reminderMinuteOfDay = null;
        }
        _coerceReminderDateForScope();
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final minute = isStart ? _startMinuteOfDay : _endMinuteOfDay;
    final initial = minute == null
        ? TimeOfDay.now()
        : TimeOfDay(hour: minute ~/ 60, minute: minute % 60);

    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (selected == null) {
      return;
    }

    final selectedMinute = selected.hour * 60 + selected.minute;

    setState(() {
      if (isStart) {
        _startMinuteOfDay = selectedMinute;
        if (_endMinuteOfDay != null && _endMinuteOfDay! <= _startMinuteOfDay!) {
          _endMinuteOfDay = null;
        }
      } else {
        _endMinuteOfDay = selectedMinute;
      }
    });

    if (!isStart &&
        _startMinuteOfDay != null &&
        _endMinuteOfDay != null &&
        _endMinuteOfDay! <= _startMinuteOfDay!) {
      setState(() => _endMinuteOfDay = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
      }
    }
  }

  Future<void> _pickReminderDate() async {
    final now = DateTime.now();
    final start = _toDateOnly(_scheduledDate ?? now);
    final selected = await showDatePicker(
      context: context,
      initialDate: _toDateOnly(_reminderDate ?? start),
      firstDate: start,
      lastDate: _toDateOnly(_endDate ?? DateTime(now.year + 6)),
    );

    if (selected != null) {
      setState(() {
        _reminderDate = _toDateOnly(selected);
      });
    }
  }

  Future<void> _pickReminderTime() async {
    final initial = _reminderMinuteOfDay == null
        ? TimeOfDay.now()
        : TimeOfDay(
            hour: _reminderMinuteOfDay! ~/ 60,
            minute: _reminderMinuteOfDay! % 60,
          );
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (selected == null) {
      return;
    }

    setState(() {
      _reminderMinuteOfDay = selected.hour * 60 + selected.minute;
      _coerceReminderDateForScope();
    });
  }

  Future<void> _save() async {
    if (_isReadOnlyCompletedPastTask) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completed tasks from previous days are read-only'),
        ),
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }

    if (_startMinuteOfDay != null &&
        _endMinuteOfDay != null &&
        _endMinuteOfDay! <= _startMinuteOfDay!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }
    if (_endDate != null &&
        _scheduledDate != null &&
        _endDate!.isBefore(_scheduledDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date must be on or after start date'),
        ),
      );
      return;
    }
    final baseDate = _scheduledDate ?? DateTime.now();
    final normalizedDate = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
    );
    final normalizedReminderDate = !_reminderEnabled
        ? null
        : (_usesReminderDatePicker
              ? (_reminderDate == null ? null : _toDateOnly(_reminderDate!))
              : normalizedDate);
    final normalizedReminderMinute = _reminderEnabled
        ? _reminderMinuteOfDay
        : null;
    final hasPartialReminder =
        (normalizedReminderDate == null) != (normalizedReminderMinute == null);
    if (hasPartialReminder) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder date and time are both required'),
        ),
      );
      return;
    }
    final today = _toDateOnly(DateTime.now());
    if (widget.taskId == null && normalizedDate.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only create tasks for today or future dates'),
        ),
      );
      return;
    }
    if (normalizedReminderDate != null && normalizedReminderMinute != null) {
      final reminderDate = normalizedReminderDate;
      if (reminderDate.isBefore(normalizedDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder date cannot be before the task start date'),
          ),
        );
        return;
      }
      if (_endDate != null && reminderDate.isAfter(_toDateOnly(_endDate!))) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder date must be within task date range'),
          ),
        );
        return;
      }
      final reminderAt = _combineDateAndMinute(
        reminderDate,
        normalizedReminderMinute,
      );
      final canRemindAgain =
          _repeatsDaily ||
          (_endDate != null && !reminderDate.isAfter(_toDateOnly(_endDate!)));
      if (reminderAt.isBefore(DateTime.now()) && !canRemindAgain) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder must be in the future for one-day tasks'),
          ),
        );
        return;
      }
    }
    final now = DateTime.now();

    final subtasks = _subTaskDrafts
        .where((draft) => draft.controller.text.trim().isNotEmpty)
        .map(
          (draft) => SubTask(
            id: draft.id,
            title: draft.controller.text.trim(),
            isCompleted: draft.completed,
          ),
        )
        .toList(growable: false);

    final existingTask = widget.taskId == null
        ? null
        : await ref
              .read(taskTimelineProviderProvider.notifier)
              .getTaskById(widget.taskId!);

    final task = Task(
      id: existingTask?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      topic: _topicController.text.trim(),
      note: _noteController.text.trim(),
      iconKey: _emojiController.text.trim(),
      scheduledAt: normalizedDate,
      endDate: _endDate,
      startMinuteOfDay: _startMinuteOfDay,
      endMinuteOfDay: _endMinuteOfDay,
      reminderDate: normalizedReminderDate,
      reminderMinuteOfDay: normalizedReminderMinute,
      repeatsDaily: _repeatsDaily || _endDate != null,
      isCompleted: existingTask?.isCompleted ?? false,
      subtasks: subtasks,
      createdAt: existingTask?.createdAt ?? now,
      updatedAt: now,
    );

    await ref.read(taskTimelineProviderProvider.notifier).saveTask(task);
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final startDateLabel = DateFormat(
      'EEE, d MMM yyyy',
    ).format(_scheduledDate ?? DateTime.now());
    final endDateLabel = _endDate == null
        ? 'No end date'
        : DateFormat('EEE, d MMM yyyy').format(_endDate!);
    final reminderDateLabel = _reminderDate == null
        ? 'Reminder date'
        : DateFormat('EEE, d MMM yyyy').format(_reminderDate!);
    final reminderTimeLabel = _formatMinuteLabel(
      _reminderMinuteOfDay,
      fallback: 'Reminder time',
    );
    final showReminderSection = _reminderEnabled;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 52,
        leading: IconButton(
          onPressed: context.pop,
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          widget.taskId == null ? 'Log your activity' : 'Edit activity',
        ),
        actions: [
          if (widget.taskId != null)
            IconButton(
              tooltip: 'Delete task',
              onPressed: () async {
                final shouldDelete =
                    await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Delete task?'),
                        content: const Text(
                          'This task will be removed permanently.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ) ??
                    false;
                if (!shouldDelete || !context.mounted) {
                  return;
                }
                await ref
                    .read(taskTimelineProviderProvider.notifier)
                    .deleteTask(widget.taskId!);
                if (!context.mounted) {
                  return;
                }
                context.pop();
              },
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          IconButton(
            onPressed: _isReadOnlyCompletedPastTask ? null : _save,
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
      body: _loadingTask
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isReadOnlyCompletedPastTask) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF2F333D)
                              : const Color(0xFFE3E0D5),
                        ),
                      ),
                      child: Text(
                        'This completed task is from a previous day. You can delete it, but editing is locked.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 11.8),
                      ),
                    ),
                  ],
                  _sectionTitle('Emoji (optional)'),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _emojiPickerField(),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    compact: true,
                    label: 'Task',
                    hint: 'Enter your task',
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    readOnly: _isReadOnlyCompletedPastTask,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    compact: true,
                    label: 'Topic (optional)',
                    hint: 'Work, Health, Personal...',
                    controller: _topicController,
                    textInputAction: TextInputAction.next,
                    readOnly: _isReadOnlyCompletedPastTask,
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle('Start & End Date'),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _compactPickerButton(
                          onPressed: _isReadOnlyCompletedPastTask
                              ? null
                              : _pickDate,
                          icon: Icons.calendar_month_rounded,
                          label: startDateLabel,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: _compactPickerButton(
                          onPressed: _isReadOnlyCompletedPastTask
                              ? null
                              : _pickEndDate,
                          icon: Icons.event_repeat_rounded,
                          label: endDateLabel,
                        ),
                      ),
                    ],
                  ),
                  if (!_isReadOnlyCompletedPastTask && _endDate != null)
                    _buildInlineResetAction(
                      label: 'Clear end date',
                      onPressed: () => setState(() {
                        _endDate = null;
                        _coerceReminderDateForScope();
                      }),
                    ),
                  const SizedBox(height: 14),
                  _sectionTitle('Start & End Time (optional)'),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _compactPickerButton(
                          onPressed: _isReadOnlyCompletedPastTask
                              ? null
                              : () => _pickTime(isStart: true),
                          icon: Icons.play_circle_outline_rounded,
                          label: _formatMinuteLabel(
                            _startMinuteOfDay,
                            fallback: 'Start',
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: _compactPickerButton(
                          onPressed: _isReadOnlyCompletedPastTask
                              ? null
                              : () => _pickTime(isStart: false),
                          icon: Icons.stop_circle_outlined,
                          label: _formatMinuteLabel(
                            _endMinuteOfDay,
                            fallback: 'End',
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!_isReadOnlyCompletedPastTask &&
                      (_startMinuteOfDay != null || _endMinuteOfDay != null))
                    _buildInlineResetAction(
                      label: 'Clear time',
                      onPressed: () => setState(() {
                        _startMinuteOfDay = null;
                        _endMinuteOfDay = null;
                      }),
                    ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2F333D)
                            : const Color(0xFFE3E0D5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_active_outlined,
                          size: 21,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reminder',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                'Notify to complete this task',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(fontSize: 11.8),
                              ),
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 0.88,
                          child: Switch.adaptive(
                            value: _reminderEnabled,
                            onChanged: _isReadOnlyCompletedPastTask
                                ? null
                                : (value) {
                                    setState(() {
                                      _reminderEnabled = value;
                                      if (!_reminderEnabled) {
                                        _reminderDate = null;
                                        _reminderMinuteOfDay = null;
                                      } else {
                                        _coerceReminderDateForScope();
                                      }
                                    });
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showReminderSection) ...[
                    const SizedBox(height: 10),
                    if (_usesReminderDatePicker)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _compactPickerButton(
                              onPressed: _isReadOnlyCompletedPastTask
                                  ? null
                                  : _pickReminderDate,
                              icon: Icons.event_note_rounded,
                              label: reminderDateLabel,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: _compactPickerButton(
                              onPressed: _isReadOnlyCompletedPastTask
                                  ? null
                                  : _pickReminderTime,
                              icon: Icons.alarm_rounded,
                              label: reminderTimeLabel,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _compactPickerButton(
                              onPressed: null,
                              icon: Icons.calendar_month_rounded,
                              label: DateFormat(
                                'EEE, d MMM yyyy',
                              ).format(_scheduledDate ?? DateTime.now()),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: _compactPickerButton(
                              onPressed: _isReadOnlyCompletedPastTask
                                  ? null
                                  : _pickReminderTime,
                              icon: Icons.alarm_rounded,
                              label: reminderTimeLabel,
                            ),
                          ),
                        ],
                      ),
                    if (!_isReadOnlyCompletedPastTask &&
                        (_reminderDate != null || _reminderMinuteOfDay != null))
                      _buildInlineResetAction(
                        label: 'Clear reminder',
                        onPressed: () => setState(() {
                          _reminderDate = null;
                          _reminderMinuteOfDay = null;
                        }),
                      ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2F333D)
                            : const Color(0xFFE3E0D5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.repeat_rounded, size: 21),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Repeat daily',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                _endDate == null
                                    ? 'Show this task every day until deleted'
                                    : 'Show this task daily until end date',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(fontSize: 11.8),
                              ),
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 0.88,
                          child: Switch.adaptive(
                            value: _repeatsDaily || _endDate != null,
                            onChanged: _isReadOnlyCompletedPastTask
                                ? null
                                : (value) => setState(() {
                                    _repeatsDaily = value;
                                    _coerceReminderDateForScope();
                                  }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    compact: true,
                    label: 'Activity note',
                    hint: 'Add useful context',
                    maxLines: 5,
                    controller: _noteController,
                    textInputAction: TextInputAction.newline,
                    readOnly: _isReadOnlyCompletedPastTask,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _sectionTitle('Subtasks'),
                      const Spacer(),
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: _isReadOnlyCompletedPastTask
                            ? null
                            : _addSubTaskField,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, size: 19),
                              const SizedBox(width: 4),
                              Text(
                                'Add subtask',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._subTaskDrafts.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: entry.value.controller,
                              readOnly: _isReadOnlyCompletedPastTask,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 11,
                                ),
                                hintText: 'Subtask ${entry.key + 1}',
                                prefixIcon: const Icon(
                                  Icons.subdirectory_arrow_right_rounded,
                                  size: 21,
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            height: 44,
                            child: Center(
                              child: IconButton(
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints.tightFor(
                                  width: 24,
                                  height: 24,
                                ),
                                onPressed: () {
                                  if (_isReadOnlyCompletedPastTask) {
                                    return;
                                  }
                                  if (_subTaskDrafts.length == 1) {
                                    _subTaskDrafts.first.controller.clear();
                                    setState(() {});
                                    return;
                                  }
                                  final draft = _subTaskDrafts.removeAt(
                                    entry.key,
                                  );
                                  draft.controller.dispose();
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_isReadOnlyCompletedPastTask)
                    PrimaryButton(
                      height: 52,
                      text: widget.taskId == null
                          ? 'Create Task'
                          : 'Save Changes',
                      onPressed: _save,
                    ),
                ],
              ),
            ),
    );
  }

  String _formatMinuteLabel(int? minuteOfDay, {required String fallback}) {
    if (minuteOfDay == null) {
      return fallback;
    }
    final time = TimeOfDay(hour: minuteOfDay ~/ 60, minute: minuteOfDay % 60);
    return time.format(context);
  }

  Widget _compactPickerButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 11.6,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineResetAction({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          minimumSize: const Size(0, 28),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: const Icon(Icons.close_rounded, size: 16),
        label: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _emojiPickerField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2F333D) : const Color(0xFFE3E0D5),
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 34,
          child: TextField(
            controller: _emojiController,
            readOnly: _isReadOnlyCompletedPastTask,
            textInputAction: TextInputAction.next,
            inputFormatters: [_emojiFormatter],
            maxLines: 1,
            minLines: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, height: 1.0),
            decoration: InputDecoration(
              hintText: '😀',
              hintStyle: TextStyle(
                fontSize: 21,
                color: Theme.of(context).hintColor.withValues(alpha: 0.45),
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  bool get _usesReminderDatePicker => _endDate != null || _repeatsDaily;

  void _coerceReminderDateForScope() {
    if (!_reminderEnabled) {
      return;
    }
    if (_usesReminderDatePicker) {
      _reminderDate ??= _toDateOnly(_scheduledDate ?? DateTime.now());
      return;
    }
    _reminderDate = _toDateOnly(_scheduledDate ?? DateTime.now());
  }

  bool _isPreviousDayCompletedTask(Task task) {
    if (!task.isCompleted) {
      return false;
    }
    final today = _toDateOnly(DateTime.now());
    return _toDateOnly(task.scheduledAt).isBefore(today);
  }

  DateTime _toDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _combineDateAndMinute(DateTime date, int minuteOfDay) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      minuteOfDay ~/ 60,
      minuteOfDay % 60,
    );
  }
}

class _SubTaskDraft {
  final String id;
  final TextEditingController controller;
  final bool completed;

  _SubTaskDraft({
    required this.id,
    required this.controller,
    this.completed = false,
  });
}

class _EmojiOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.trim();
    if (text.isEmpty) {
      return const TextEditingValue(text: '');
    }

    String emoji = '';
    for (final grapheme in text.characters) {
      if (_containsEmojiRune(grapheme)) {
        emoji = grapheme;
        break;
      }
    }

    return TextEditingValue(
      text: emoji,
      selection: TextSelection.collapsed(offset: emoji.length),
    );
  }
}

bool _containsEmojiRune(String value) {
  for (final rune in value.runes) {
    final isEmojiBlock =
        (rune >= 0x1F300 && rune <= 0x1FAFF) ||
        (rune >= 0x1F1E6 && rune <= 0x1F1FF) ||
        (rune >= 0x2600 && rune <= 0x27BF);
    if (isEmojiBlock) {
      return true;
    }
  }
  return false;
}
