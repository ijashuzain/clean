import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logit/core/router/route_paths.dart';
import 'package:logit/core/theme/app_colors.dart';
import 'package:logit/features/project/presentation/providers/project_provider.dart';

class ProjectsView extends ConsumerWidget {
  const ProjectsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Projects',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _showProjectEditor(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(projectNotifierProvider.notifier).syncFromRemote(),
          child: state.projects.isEmpty
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.folder_open_rounded, size: 30),
                          const SizedBox(height: 10),
                          Text(
                            'No projects yet',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Create a project to group related tasks.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withValues(alpha: 0.74),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
                  itemCount: state.projects.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final project = state.projects[index];
                    final assignedCount = state.taskProjectMap.values
                        .where((id) => id == project.id)
                        .length;
                    return Material(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => context.push(
                          '${RoutePaths.projectDetail}?id=${project.id}',
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surface.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.folder_open_rounded),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      project.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    if (project.description.trim().isNotEmpty)
                                      Text(
                                        project.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color
                                                  ?.withValues(alpha: 0.74),
                                            ),
                                      )
                                    else
                                      Text(
                                        '$assignedCount task${assignedCount == 1 ? '' : 's'} linked',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color
                                                  ?.withValues(alpha: 0.74),
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (action) async {
                                  if (action == 'edit') {
                                    await _showProjectEditor(
                                      context,
                                      ref,
                                      projectId: project.id,
                                      initialName: project.name,
                                      initialDescription: project.description,
                                    );
                                    return;
                                  }
                                  if (action == 'delete') {
                                    await _confirmDelete(
                                      context,
                                      ref,
                                      project.id,
                                    );
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String projectId,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete project?'),
            content: const Text(
              'Tasks remain available. The project association will be removed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
    if (!shouldDelete) {
      return;
    }
    await ref.read(projectNotifierProvider.notifier).deleteProject(projectId);
  }

  Future<void> _showProjectEditor(
    BuildContext context,
    WidgetRef ref, {
    String? projectId,
    String initialName = '',
    String initialDescription = '',
  }) async {
    final isEditing = projectId != null;
    final formKey = GlobalKey<FormState>();
    var editedName = initialName;
    var editedDescription = initialDescription;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit project' : 'Create project',
                    style: Theme.of(sheetContext).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: initialName,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Project name',
                      hintText: 'Eg: Work, Personal',
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Project name is required';
                      }
                      return null;
                    },
                    onChanged: (value) => editedName = value,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: initialDescription,
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                    onChanged: (value) => editedDescription = value,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        final notifier = ref.read(
                          projectNotifierProvider.notifier,
                        );
                        if (projectId == null) {
                          await notifier.createProject(
                            name: editedName,
                            description: editedDescription,
                          );
                        } else {
                          await notifier.updateProject(
                            projectId: projectId,
                            name: editedName,
                            description: editedDescription,
                          );
                        }
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                      child: Text(
                        isEditing ? 'Save changes' : 'Create project',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
