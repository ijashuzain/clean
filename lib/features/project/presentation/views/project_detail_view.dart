import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logit/core/router/route_paths.dart';
import 'package:logit/core/theme/app_colors.dart';
import 'package:logit/features/project/presentation/providers/project_provider.dart';
import 'package:logit/features/task/domain/entities/task/task.dart';
import 'package:logit/features/task/domain/usecases/get_tasks_by_date_usecase/get_tasks_by_date_usecase.dart';
import 'package:logit/features/task/presentation/providers/task_timeline_provider/task_timeline_provider.dart';
import 'package:logit/features/task/presentation/widgets/date_selector_strip.dart';
import 'package:logit/features/task/presentation/widgets/task_item_widget.dart';

class ProjectDetailView extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailView({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends ConsumerState<ProjectDetailView> {
  static const double _timelineTopInset = 8;
  static const double _tasksTopInset = 12;

  final Set<String> _expandedTaskIds = <String>{};
  Map<String, List<String>> _projectWeekEmojiMap =
      const <String, List<String>>{};
  ProviderSubscription<TaskTimelineState>? _timelineSubscription;
  ProviderSubscription<ProjectState>? _projectSubscription;
  String _lastWeekSignature = '';
  int _emojiRequestToken = 0;

  @override
  void initState() {
    super.initState();
    _timelineSubscription = ref.listenManual(taskTimelineProviderProvider, (
      previous,
      next,
    ) {
      final previousDate = previous?.selectedDate;
      final selectedDateChanged =
          previousDate == null || !_sameDate(previousDate, next.selectedDate);
      final previousTaskSignature = previous == null
          ? ''
          : _taskSignatureForProject(
              tasks: previous.tasks,
              selectedDate: previous.selectedDate,
            );
      final nextTaskSignature = _taskSignatureForProject(
        tasks: next.tasks,
        selectedDate: next.selectedDate,
      );
      if (selectedDateChanged || previousTaskSignature != nextTaskSignature) {
        _loadProjectWeekEmojiMap(forDate: next.selectedDate);
      }
    });
    _projectSubscription = ref.listenManual(projectNotifierProvider, (
      previous,
      next,
    ) {
      final previousSignature = previous == null
          ? ''
          : _projectMappingSignature(previous.taskProjectMap);
      final nextSignature = _projectMappingSignature(next.taskProjectMap);
      if (previousSignature != nextSignature) {
        _loadProjectWeekEmojiMap();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProjectWeekEmojiMap();
    });
  }

  @override
  void dispose() {
    _timelineSubscription?.close();
    _projectSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(projectNotifierProvider);
    final taskState = ref.watch(taskTimelineProviderProvider);
    final project = ref
        .read(projectNotifierProvider.notifier)
        .projectById(widget.projectId);

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Project')),
        body: const Center(child: Text('Project not found')),
      );
    }

    final visibleTasks = taskState.tasks
        .where((task) {
          final taskProjectId = ref
              .read(projectNotifierProvider.notifier)
              .projectIdForTaskId(task.id);
          return taskProjectId == project.id;
        })
        .toList(growable: false);
    final selectedDate = taskState.selectedDate;
    final monthText = DateFormat('MMMM').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          project.name,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () => context.push(
          '${RoutePaths.taskManage}?projectId=${project.id}&lockProject=true',
        ),
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
                child: Icon(Icons.add, size: 12, color: AppColors.accentGold),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      monthText,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Text(
                      '${visibleTasks.length} task${visibleTasks.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DateSelectorStrip(
                selectedDate: selectedDate,
                dayEmojiMap: _projectWeekEmojiMap,
                onDateSelected: (date) => ref
                    .read(taskTimelineProviderProvider.notifier)
                    .loadTasks(date),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildTimelineSection(context, visibleTasks)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context, List<Task> tasks) {
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
          const Positioned(
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
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (tasks.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20 + _tasksTopInset),
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
                            'No tasks in this project for selected date',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(
                    top: _tasksTopInset,
                    right: 2,
                    bottom: 120,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final task = tasks[index];
                      return TaskItemWidget(
                        task: task,
                        interactionLocked: _isPreviousDayCompletedTask(task),
                        subtasksExpanded: _expandedTaskIds.contains(task.id),
                        onToggleSubtasks: () {
                          setState(() {
                            if (!_expandedTaskIds.add(task.id)) {
                              _expandedTaskIds.remove(task.id);
                            }
                          });
                        },
                        onTaskToggle: () => ref
                            .read(taskTimelineProviderProvider.notifier)
                            .toggleTask(taskId: task.id),
                        onSubTaskChanged: (subtask) => ref
                            .read(taskTimelineProviderProvider.notifier)
                            .toggleTask(taskId: task.id, subTaskId: subtask.id),
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
                      );
                    }, childCount: tasks.length),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
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

  Future<void> _loadProjectWeekEmojiMap({DateTime? forDate}) async {
    final selectedDate = _toDateOnly(
      forDate ?? ref.read(taskTimelineProviderProvider).selectedDate,
    );
    final weekStart = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    final projectState = ref.read(projectNotifierProvider);
    final taskState = ref.read(taskTimelineProviderProvider);
    final taskSignature = _taskSignatureForProject(
      tasks: taskState.tasks,
      selectedDate: selectedDate,
    );
    final weekSignature =
        '${_dateKey(weekStart)}::${_projectMappingSignature(projectState.taskProjectMap)}::$taskSignature';
    if (_lastWeekSignature == weekSignature) {
      return;
    }

    final requestToken = ++_emojiRequestToken;
    final output = <String, List<String>>{};
    final getTasksByDateUseCase = ref.read(getTasksByDateUseCaseProvider);
    final projectNotifier = ref.read(projectNotifierProvider.notifier);

    for (var index = 0; index < 7; index++) {
      final day = weekStart.add(Duration(days: index));
      final result = await getTasksByDateUseCase.call(day);
      await result.when(
        success: (tasks) async {
          final emojis = <String>[];
          for (final task in tasks) {
            final projectId = projectNotifier.projectIdForTaskId(task.id);
            if (projectId != widget.projectId) {
              continue;
            }
            final icon = task.iconKey.trim();
            if (!_isEmoji(icon)) {
              continue;
            }
            emojis.add(icon);
            if (emojis.length >= 4) {
              break;
            }
          }
          if (emojis.isNotEmpty) {
            output[_dateKey(day)] = emojis;
          }
        },
        failure: (_) async {},
      );
    }

    if (!mounted || requestToken != _emojiRequestToken) {
      return;
    }
    setState(() {
      _lastWeekSignature = weekSignature;
      _projectWeekEmojiMap = output;
    });
  }

  String _projectMappingSignature(Map<String, String> taskProjectMap) {
    final taskIds =
        taskProjectMap.entries
            .where((entry) => entry.value == widget.projectId)
            .map((entry) => entry.key)
            .toList(growable: true)
          ..sort();
    return taskIds.join('|');
  }

  String _taskSignatureForProject({
    required List<Task> tasks,
    required DateTime selectedDate,
  }) {
    final selectedDateOnly = _toDateOnly(selectedDate);
    final weekStart = selectedDateOnly.subtract(
      Duration(days: selectedDateOnly.weekday - 1),
    );
    final weekEnd = weekStart.add(const Duration(days: 6));
    final projectNotifier = ref.read(projectNotifierProvider.notifier);
    final entries = <String>[];

    for (final task in tasks) {
      final taskDate = _toDateOnly(task.scheduledAt);
      if (taskDate.isBefore(weekStart) || taskDate.isAfter(weekEnd)) {
        continue;
      }
      final projectId = projectNotifier.projectIdForTaskId(task.id);
      if (projectId != widget.projectId) {
        continue;
      }
      entries.add(
        '${task.id}|${_dateKey(taskDate)}|${task.iconKey.trim()}|${task.updatedAt.toIso8601String()}',
      );
    }
    entries.sort();
    return entries.join('::');
  }

  bool _isEmoji(String value) {
    return value.trim().isNotEmpty && value.runes.any((rune) => rune > 127);
  }

  DateTime _toDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _dateKey(DateTime date) {
    final yyyy = date.year.toString().padLeft(4, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  bool _sameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
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
