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
  bool _repeatsDaily = false;
  bool _loadingTask = false;

  @override
  void initState() {
    super.initState();
    _scheduledDate = ref.read(taskTimelineProviderProvider).selectedDate;
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
      _repeatsDaily = task.repeatsDaily;

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
    final selected = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (selected != null) {
      setState(() {
        _scheduledDate = DateTime(selected.year, selected.month, selected.day);
        if (_endDate != null && _endDate!.isBefore(_scheduledDate!)) {
          _endDate = null;
        }
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
      setState(
        () => _endDate = DateTime(selected.year, selected.month, selected.day),
      );
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

  Future<void> _save() async {
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

    return Scaffold(
      appBar: AppBar(
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
          IconButton(onPressed: _save, icon: const Icon(Icons.check_rounded)),
        ],
      ),
      body: _loadingTask
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Task',
                      hint: 'Enter your task',
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Topic (optional)',
                      hint: 'Work, Health, Personal...',
                      controller: _topicController,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      label: 'Emoji (optional)',
                      hint: 'Type from emoji keyboard',
                      controller: _emojiController,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [_emojiFormatter],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Start & End Date',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_month_rounded),
                            label: Text(startDateLabel),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickEndDate,
                            icon: const Icon(Icons.event_repeat_rounded),
                            label: Text(endDateLabel),
                          ),
                        ),
                        if (_endDate != null)
                          IconButton(
                            tooltip: 'Clear end date',
                            onPressed: () => setState(() => _endDate = null),
                            icon: const Icon(Icons.close_rounded),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Start & End Time (optional)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickTime(isStart: true),
                            icon: const Icon(Icons.play_circle_outline_rounded),
                            label: Text(
                              _formatMinuteLabel(
                                _startMinuteOfDay,
                                fallback: 'Start',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickTime(isStart: false),
                            icon: const Icon(Icons.stop_circle_outlined),
                            label: Text(
                              _formatMinuteLabel(
                                _endMinuteOfDay,
                                fallback: 'End',
                              ),
                            ),
                          ),
                        ),
                        if (_startMinuteOfDay != null ||
                            _endMinuteOfDay != null)
                          IconButton(
                            onPressed: () => setState(() {
                              _startMinuteOfDay = null;
                              _endMinuteOfDay = null;
                            }),
                            icon: const Icon(Icons.close_rounded),
                            tooltip: 'Clear time',
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile.adaptive(
                      value: _repeatsDaily || _endDate != null,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Repeat daily'),
                      subtitle: Text(
                        _endDate == null
                            ? 'Show this task every day until deleted'
                            : 'Show this task daily until end date',
                      ),
                      secondary: const Icon(Icons.repeat_rounded),
                      onChanged: (value) =>
                          setState(() => _repeatsDaily = value),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      label: 'Activity note',
                      hint: 'Add useful context',
                      maxLines: 4,
                      controller: _noteController,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtasks',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        TextButton.icon(
                          onPressed: _addSubTaskField,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add subtask'),
                        ),
                      ],
                    ),
                    ..._subTaskDrafts.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: entry.value.controller,
                                decoration: InputDecoration(
                                  hintText: 'Subtask ${entry.key + 1}',
                                  prefixIcon: const Icon(
                                    Icons.subdirectory_arrow_right_rounded,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
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
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      text: widget.taskId == null
                          ? 'Create Task'
                          : 'Save Changes',
                      onPressed: _save,
                    ),
                  ],
                ),
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
