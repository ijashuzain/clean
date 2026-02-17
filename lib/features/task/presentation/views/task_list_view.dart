import 'package:logit/core/router/route_paths.dart';
import 'package:logit/core/theme/app_colors.dart';
import 'package:logit/core/widgets/brand_logo.dart';
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

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: GestureDetector(
        onTap: () => context.push(RoutePaths.taskManage),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x16000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: const [
              Icon(
                Icons.sentiment_satisfied_alt_rounded,
                size: 24,
                color: AppColors.accentGold,
              ),
              Positioned(
                right: 12,
                bottom: 13,
                child: Icon(Icons.add, size: 13, color: AppColors.accentGold),
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
              const SizedBox(height: 2),
              const Center(child: BrandLogo(fontSize: 22)),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  monthText,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
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
                    return RefreshIndicator(
                      onRefresh: () => ref
                          .read(taskTimelineProviderProvider.notifier)
                          .loadTasks(),
                      child: Stack(
                        children: [
                          if (state.tasks.isNotEmpty)
                            Positioned(
                              left: 63,
                              top: 8,
                              bottom: 28,
                              child: Container(
                                width: 1.5,
                                color: AppColors.accentGold,
                              ),
                            ),
                          if (state.tasks.isNotEmpty)
                            const Positioned(
                              left: 58,
                              top: 0,
                              child: _TimelineDot(),
                            ),
                          if (state.tasks.isNotEmpty)
                            const Positioned(
                              left: 58,
                              bottom: 20,
                              child: _TimelineDot(),
                            ),
                          SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 12,
                                right: 2,
                                bottom: 20,
                              ),
                              child: state.tasks.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            const Icon(
                                              Icons
                                                  .assignment_turned_in_outlined,
                                              size: 28,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'No tasks for this date',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Use + to add activity with notes and subtasks.',
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.color
                                                        ?.withValues(
                                                          alpha: 0.72,
                                                        ),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        for (
                                          var i = 0;
                                          i < state.tasks.length;
                                          i++
                                        )
                                          Dismissible(
                                            key: ValueKey(state.tasks[i].id),
                                            direction:
                                                DismissDirection.endToStart,
                                            background: Container(
                                              alignment: Alignment.centerRight,
                                              padding: const EdgeInsets.only(
                                                right: 14,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDC4E4E),
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                                        title: const Text(
                                                          'Delete task?',
                                                        ),
                                                        content: const Text(
                                                          'This task will be removed permanently.',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  dialogContext,
                                                                ).pop(false),
                                                            child: const Text(
                                                              'Cancel',
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  dialogContext,
                                                                ).pop(true),
                                                            child: const Text(
                                                              'Delete',
                                                            ),
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
                                                    taskTimelineProviderProvider
                                                        .notifier,
                                                  )
                                                  .deleteTask(
                                                    state.tasks[i].id,
                                                  );
                                            },
                                            child: TaskItemWidget(
                                              task: state.tasks[i],
                                              subtasksExpanded: _expandedTaskIds
                                                  .contains(state.tasks[i].id),
                                              onToggleSubtasks: () {
                                                setState(() {
                                                  if (!_expandedTaskIds.add(
                                                    state.tasks[i].id,
                                                  )) {
                                                    _expandedTaskIds.remove(
                                                      state.tasks[i].id,
                                                    );
                                                  }
                                                });
                                              },
                                              onTaskToggle: () => ref
                                                  .read(
                                                    taskTimelineProviderProvider
                                                        .notifier,
                                                  )
                                                  .toggleTask(
                                                    taskId: state.tasks[i].id,
                                                  ),
                                              onSubTaskChanged: (subtask) => ref
                                                  .read(
                                                    taskTimelineProviderProvider
                                                        .notifier,
                                                  )
                                                  .toggleTask(
                                                    taskId: state.tasks[i].id,
                                                    subTaskId: subtask.id,
                                                  ),
                                              onTap: () => context.push(
                                                '${RoutePaths.taskManage}?id=${state.tasks[i].id}',
                                              ),
                                              onDelete: () => ref
                                                  .read(
                                                    taskTimelineProviderProvider
                                                        .notifier,
                                                  )
                                                  .deleteTask(
                                                    state.tasks[i].id,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
