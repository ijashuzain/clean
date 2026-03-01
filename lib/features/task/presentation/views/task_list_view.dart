import 'package:logit/core/router/route_paths.dart';
import 'package:logit/core/theme/app_colors.dart';
import 'package:logit/core/widgets/brand_logo.dart';
import 'package:logit/features/project/presentation/providers/project_provider.dart';
import 'package:logit/features/task/data/repositories/task_repository_impl/task_repository_impl.dart';
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
  static const double _timelineTopInset = 8;
  static const double _tasksTopInset = 12;

  final Set<String> _expandedTaskIds = <String>{};
  final ScrollController _taskScrollController = ScrollController();
  bool _hideFinishedTasks = false;
  double _extraScrollSpace = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _taskScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskTimelineProviderProvider);
    final isSyncing = ref.watch(taskSyncStatusProvider).valueOrNull ?? false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _recalculateExtraScrollSpace(hasTasks: visibleTasks.isNotEmpty);
    });

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 52,
            height: 154,
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
                  tooltip: 'Projects',
                  onPressed: () => context.push(RoutePaths.projects),
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.folder_open_rounded, size: 20),
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  const SizedBox(height: 2),
                  const Center(child: BrandLogo(fontSize: 22)),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                final pickedDate = await context.push<DateTime>(
                                  RoutePaths.taskCalendar,
                                );
                                if (!mounted || pickedDate == null) {
                                  return;
                                }
                                await ref
                                    .read(taskTimelineProviderProvider.notifier)
                                    .loadTasks(pickedDate);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 2,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      monthText,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 18,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: isTodaySelected
                                ? null
                                : () => ref
                                      .read(
                                        taskTimelineProviderProvider.notifier,
                                      )
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
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
                    ],
                  ),
                  Expanded(
                    child: _buildTimelineSection(
                      context,
                      visibleTasks,
                      emptyTitle: emptyTitle,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 6,
              right: 10,
              child: IgnorePointer(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: isSyncing
                      ? const _SyncPulseDot(key: ValueKey('syncing-dot'))
                      : const SizedBox.shrink(key: ValueKey('no-sync-dot')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection(
    BuildContext context,
    List<Task> tasks, {
    required String emptyTitle,
  }) {
    return Stack(
      children: [
        if (tasks.isNotEmpty)
          Positioned(
            left: 63,
            top: _timelineTopInset,
            bottom: 0,
            child: Container(width: 1.5, color: AppColors.accentGold),
          ),
        if (tasks.isNotEmpty)
          Positioned(
            left: 58,
            top: _timelineTopInset - 8,
            child: _TimelineDot(),
          ),
        if (tasks.isNotEmpty)
          const Positioned(left: 58, bottom: 0, child: _TimelineDot()),
        RefreshIndicator(
          edgeOffset: 0,
          displacement: 28,
          onRefresh: () =>
              ref.read(taskTimelineProviderProvider.notifier).loadTasks(),
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: (_) {
              _recalculateExtraScrollSpace(hasTasks: tasks.isNotEmpty);
              return false;
            },
            child: CustomScrollView(
              controller: _taskScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (tasks.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.only(top: 22 + _tasksTopInset),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.only(
                      top: _tasksTopInset,
                      right: 2,
                      bottom: 120 + _extraScrollSpace,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final task = tasks[index];
                        final interactionLocked = _isPreviousDayCompletedTask(
                          task,
                        );
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
                            final shouldDelete =
                                await showDialog<bool>(
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
                            if (shouldDelete) {
                              await ref
                                  .read(taskTimelineProviderProvider.notifier)
                                  .deleteTask(task.id);
                              await ref
                                  .read(projectNotifierProvider.notifier)
                                  .assignTaskToProject(
                                    taskId: task.id,
                                    projectId: null,
                                  );
                            }
                            // Keep Dismissible in tree until provider state refreshes.
                            return false;
                          },
                          child: TaskItemWidget(
                            task: task,
                            topicLabel: _topicLabelForTask(task),
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
                              _recalculateExtraScrollSpace(
                                hasTasks: tasks.isNotEmpty,
                              );
                            },
                            onTaskToggle: () => ref
                                .read(taskTimelineProviderProvider.notifier)
                                .toggleTask(taskId: task.id),
                            onSubTaskChanged: (subtask) => ref
                                .read(taskTimelineProviderProvider.notifier)
                                .toggleTask(
                                  taskId: task.id,
                                  subTaskId: subtask.id,
                                ),
                            onTap: () => context.push(
                              '${RoutePaths.taskManage}?id=${task.id}',
                            ),
                            onDelete: () async {
                              await ref
                                  .read(taskTimelineProviderProvider.notifier)
                                  .deleteTask(task.id);
                              await ref
                                  .read(projectNotifierProvider.notifier)
                                  .assignTaskToProject(
                                    taskId: task.id,
                                    projectId: null,
                                  );
                            },
                          ),
                        );
                      }, childCount: tasks.length),
                    ),
                  ),
              ],
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
    if (!_isTaskFinished(task)) {
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduled = DateTime(
      task.scheduledAt.year,
      task.scheduledAt.month,
      task.scheduledAt.day,
    );
    final end = task.endDate == null
        ? scheduled
        : DateTime(task.endDate!.year, task.endDate!.month, task.endDate!.day);
    return end.isBefore(today);
  }

  void _toggleTaskFilter() {
    setState(() => _hideFinishedTasks = !_hideFinishedTasks);
    _recalculateExtraScrollSpace(hasTasks: true);
  }

  void _recalculateExtraScrollSpace({required bool hasTasks}) {
    if (!mounted) {
      return;
    }

    if (!_taskScrollController.hasClients || !hasTasks) {
      if (_extraScrollSpace != 0) {
        setState(() => _extraScrollSpace = 0);
      }
      return;
    }

    final maxScroll = _taskScrollController.position.maxScrollExtent;
    final baseScroll = (maxScroll - _extraScrollSpace).clamp(
      0.0,
      double.infinity,
    );
    const targetMinScrollableExtent = 140.0;

    double target = 0;
    if (baseScroll > 0 && baseScroll < targetMinScrollableExtent) {
      target = targetMinScrollableExtent - baseScroll;
    }
    target = target.clamp(0.0, targetMinScrollableExtent);

    if ((target - _extraScrollSpace).abs() > 1) {
      setState(() => _extraScrollSpace = target);
    }
  }

  String _topicLabelForTask(Task task) {
    final projectId = ref
        .read(projectNotifierProvider.notifier)
        .projectIdForTaskId(task.id);
    final topic = task.topic.trim();
    if (projectId == null || projectId.isEmpty) {
      return topic;
    }
    final project = ref
        .read(projectNotifierProvider.notifier)
        .projectById(projectId);
    if (project == null) {
      return topic;
    }
    if (topic.isEmpty) {
      return project.name;
    }
    return '${project.name} - $topic';
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

class _SyncPulseDot extends StatefulWidget {
  const _SyncPulseDot({super.key});

  @override
  State<_SyncPulseDot> createState() => _SyncPulseDotState();
}

class _SyncPulseDotState extends State<_SyncPulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    )..repeat();

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1,
          end: 1.26,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 14,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.26,
          end: 0.96,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.96,
          end: 1.18,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 14,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.18,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 62,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.12,
          end: 0.35,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 14,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.35,
          end: 0.16,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.16,
          end: 0.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 14,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.3,
          end: 0.12,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 62,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(opacity: _opacityAnimation.value, child: child),
        );
      },
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppColors.accentGreen,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
