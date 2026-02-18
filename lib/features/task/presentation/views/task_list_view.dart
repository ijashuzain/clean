import 'package:logit/core/router/route_paths.dart';
import 'package:logit/core/theme/app_colors.dart';
import 'package:logit/core/widgets/brand_logo.dart';
import 'package:logit/features/task/domain/entities/task/task.dart';
import 'package:logit/features/task/presentation/providers/task_timeline_provider/task_timeline_provider.dart';
import 'package:logit/features/task/presentation/widgets/date_selector_strip.dart';
import 'package:logit/features/task/presentation/widgets/task_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TaskListView extends ConsumerStatefulWidget {
  const TaskListView({super.key});

  @override
  ConsumerState<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends ConsumerState<TaskListView> {
  final Set<String> _expandedTaskIds = <String>{};
  bool _hideFinishedTasks = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskTimelineProviderProvider);

    ref.listen(taskTimelineProviderProvider, (previous, next) {
      next.taskStatus.maybeWhen(
        failure: (message) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message))),
        orElse: () {},
      );
    });

    final monthText = DateFormat('MMMM').format(state.selectedDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isTodaySelected =
        state.selectedDate.year == today.year &&
        state.selectedDate.month == today.month &&
        state.selectedDate.day == today.day;
    final visibleTasks = _filterTasks(state.tasks);
    final emptyTitle = _hideFinishedTasks
        ? 'No unfinished tasks for this date'
        : 'No tasks for this date';

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 52,
            height: 106,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Hide finished',
                  onPressed: _toggleTaskFilter,
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    _hideFinishedTasks
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 20,
                    color: _hideFinishedTasks
                        ? AppColors.accentGreen
                        : AppColors.brandText,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 18,
                  height: 1,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                ),
                const SizedBox(height: 2),
                IconButton(
                  tooltip: 'Settings',
                  onPressed: () => context.push(RoutePaths.settings),
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.settings_outlined, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push(RoutePaths.taskManage),
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: const [
                  Icon(
                    Icons.sentiment_satisfied_alt_rounded,
                    size: 22,
                    color: AppColors.accentGold,
                  ),
                  Positioned(
                    right: 11,
                    bottom: 11,
                    child: Icon(
                      Icons.add,
                      size: 12,
                      color: AppColors.accentGold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          edgeOffset: 0,
          displacement: 28,
          onRefresh: () =>
              ref.read(taskTimelineProviderProvider.notifier).loadTasks(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                const SizedBox(height: 2),
                const Center(child: BrandLogo(fontSize: 22)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        monthText,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: isTodaySelected
                          ? null
                          : () => ref
                                .read(taskTimelineProviderProvider.notifier)
                                .loadTasks(today),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isTodaySelected
                              ? AppColors.accentGreenMuted
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isTodaySelected
                                ? AppColors.accentGreen
                                : Theme.of(context).brightness ==
                                      Brightness.dark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.today_rounded,
                              size: 13,
                              color: isTodaySelected
                                  ? AppColors.accentGreen
                                  : null,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Today',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isTodaySelected
                                        ? AppColors.accentGreen
                                        : null,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DateSelectorStrip(
                  selectedDate: state.selectedDate,
                  dayEmojiMap: state.weekEmojiMap,
                  onDateSelected: (date) => ref
                      .read(taskTimelineProviderProvider.notifier)
                      .loadTasks(date),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return _buildTimelineSection(
                        context,
                        visibleTasks,
                        minHeight: constraints.maxHeight,
                        emptyTitle: emptyTitle,
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

  Widget _buildTimelineSection(
    BuildContext context,
    List<Task> tasks, {
    required double minHeight,
    required String emptyTitle,
  }) {
    return Stack(
      children: [
        if (tasks.isNotEmpty)
          Positioned(
            left: 63,
            top: 8,
            bottom: 28,
            child: Container(width: 1.5, color: AppColors.accentGold),
          ),
        if (tasks.isNotEmpty)
          const Positioned(left: 58, top: 0, child: _TimelineDot()),
        if (tasks.isNotEmpty)
          const Positioned(left: 58, bottom: 20, child: _TimelineDot()),
        SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: tasks.isEmpty ? 0 : minHeight,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: 12,
                right: 2,
                bottom: tasks.isEmpty ? 20 : 88,
              ),
              child: tasks.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.assignment_turned_in_outlined,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              emptyTitle,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Use + to add activity with notes and subtasks.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withValues(alpha: 0.72),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < tasks.length; i++)
                          Builder(
                            builder: (context) {
                              final task = tasks[i];
                              final interactionLocked =
                                  _isPreviousDayCompletedTask(task);
                              return Dismissible(
                                key: ValueKey(task.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC4E4E),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (_) async {
                                  return await showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) {
                                          return AlertDialog(
                                            title: const Text('Delete task?'),
                                            content: const Text(
                                              'This task will be removed permanently.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(
                                                  dialogContext,
                                                ).pop(false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.of(
                                                  dialogContext,
                                                ).pop(true),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          );
                                        },
                                      ) ??
                                      false;
                                },
                                onDismissed: (_) {
                                  ref
                                      .read(
                                        taskTimelineProviderProvider.notifier,
                                      )
                                      .deleteTask(task.id);
                                },
                                child: TaskItemWidget(
                                  task: task,
                                  interactionLocked: interactionLocked,
                                  subtasksExpanded: _expandedTaskIds.contains(
                                    task.id,
                                  ),
                                  onToggleSubtasks: () {
                                    setState(() {
                                      if (!_expandedTaskIds.add(task.id)) {
                                        _expandedTaskIds.remove(task.id);
                                      }
                                    });
                                  },
                                  onTaskToggle: () => ref
                                      .read(
                                        taskTimelineProviderProvider.notifier,
                                      )
                                      .toggleTask(taskId: task.id),
                                  onSubTaskChanged: (subtask) => ref
                                      .read(
                                        taskTimelineProviderProvider.notifier,
                                      )
                                      .toggleTask(
                                        taskId: task.id,
                                        subTaskId: subtask.id,
                                      ),
                                  onTap: () => context.push(
                                    '${RoutePaths.taskManage}?id=${task.id}',
                                  ),
                                  onDelete: () => ref
                                      .read(
                                        taskTimelineProviderProvider.notifier,
                                      )
                                      .deleteTask(task.id),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  List<Task> _filterTasks(List<Task> tasks) {
    if (!_hideFinishedTasks) {
      return tasks;
    }
    return tasks
        .where((task) => !_isTaskFinished(task))
        .toList(growable: false);
  }

  bool _isTaskFinished(Task task) {
    if (task.isCompleted) {
      return true;
    }
    return task.subtasks.isNotEmpty &&
        task.subtasks.every((subtask) => subtask.isCompleted);
  }

  bool _isPreviousDayCompletedTask(Task task) {
    if (!task.isCompleted) {
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduled = DateTime(
      task.scheduledAt.year,
      task.scheduledAt.month,
      task.scheduledAt.day,
    );
    return scheduled.isBefore(today);
  }

  void _toggleTaskFilter() {
    setState(() => _hideFinishedTasks = !_hideFinishedTasks);
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: AppColors.accentGold,
        shape: BoxShape.circle,
      ),
    );
  }
}
