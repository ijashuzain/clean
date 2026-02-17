import 'package:logit/core/theme/app_colors.dart';
import 'package:logit/features/task/domain/entities/task/task.dart';
import 'package:flutter/material.dart';

class TaskItemWidget extends StatelessWidget {
  final Task task;
  final bool subtasksExpanded;
  final VoidCallback onToggleSubtasks;
  final VoidCallback onTaskToggle;
  final ValueChanged<SubTask> onSubTaskChanged;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskItemWidget({
    super.key,
    required this.task,
    required this.subtasksExpanded,
    required this.onToggleSubtasks,
    required this.onTaskToggle,
    required this.onSubTaskChanged,
    required this.onTap,
    required this.onDelete,
  });

  bool _isEmoji(String value) {
    return value.trim().isNotEmpty && value.runes.any((rune) => rune > 127);
  }

  @override
  Widget build(BuildContext context) {
    final done = task.subtasks.where((item) => item.isCompleted).length;
    final total = task.subtasks.length;
    final hasTime =
        task.startMinuteOfDay != null || task.endMinuteOfDay != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: onTap,
        onLongPress: onDelete,
        borderRadius: BorderRadius.circular(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 44,
              child: hasTime
                  ? Padding(
                      padding: const EdgeInsets.only(top: 9),
                      child: Text(
                        _formatMinute(
                          task.startMinuteOfDay ?? task.endMinuteOfDay!,
                          context,
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkMutedText
                              : const Color(0xFFACAFB4),
                          fontSize: 9,
                        ),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: _isEmoji(task.iconKey)
                  ? Text(task.iconKey, style: const TextStyle(fontSize: 20))
                  : Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.accentGold,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasTime || task.repeatsDaily || task.endDate != null)
                    Row(
                      children: [
                        if (hasTime)
                          Text(
                            _timeRangeLabel(context),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.darkMutedText
                                      : const Color(0xFFACAFB4),
                                ),
                          ),
                        if (task.repeatsDaily || task.endDate != null) ...[
                          if (hasTime) const SizedBox(width: 6),
                          const Icon(
                            Icons.repeat_rounded,
                            size: 14,
                            color: Color(0xFF6D6F75),
                          ),
                        ],
                      ],
                    ),
                  if (task.topic.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        task.topic.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.8,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkMutedText
                              : const Color(0xFFAEB0B5),
                        ),
                      ),
                    ),
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.note.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        task.note,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (task.subtasks.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A7F49),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$done/$total',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: onToggleSubtasks,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 2,
                            ),
                            child: Icon(
                              subtasksExpanded
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: const Color(0xFF3A7F49),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (subtasksExpanded) ...[
                      const SizedBox(height: 6),
                      ...task.subtasks.map(
                        (subtask) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: InkWell(
                            onTap: () => onSubTaskChanged(subtask),
                            child: Row(
                              children: [
                                Icon(
                                  subtask.isCompleted
                                      ? Icons.check_box_outlined
                                      : Icons.check_box_outline_blank,
                                  color: const Color(0xFF3A7F49),
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    subtask.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 12,
                                          decoration: subtask.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onTaskToggle,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3E8550),
                    width: 1.5,
                  ),
                  color: task.isCompleted
                      ? const Color(0xFF3E8550)
                      : Colors.transparent,
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeRangeLabel(BuildContext context) {
    final start = task.startMinuteOfDay;
    final end = task.endMinuteOfDay;
    if (start != null && end != null) {
      return '${_formatMinute(start, context)} - ${_formatMinute(end, context)}';
    }
    if (start != null) {
      return _formatMinute(start, context);
    }
    if (end != null) {
      return _formatMinute(end, context);
    }
    return '';
  }

  String _formatMinute(int minuteOfDay, BuildContext context) {
    final time = TimeOfDay(hour: minuteOfDay ~/ 60, minute: minuteOfDay % 60);
    return time.format(context);
  }
}
