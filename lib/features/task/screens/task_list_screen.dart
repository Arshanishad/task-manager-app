import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/core/providers/task_provider.dart';
import 'package:task_manager/features/task/screens/task_details_screen.dart';

import '../models/task_model.dart';
import 'add_edit_task_screen.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          _SyncIndicator(state: state),
        ],
      ),
      body: Column(
        children: [
          const _SearchBox(),
          const _FilterSortRow(),
          Expanded(
            child: _TaskBody(state: state),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditTaskScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}


class _SyncIndicator extends StatelessWidget {
  final TaskState state;

  const _SyncIndicator({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isSyncing) {
      return const Padding(
        padding: EdgeInsets.only(right: 16),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 6),
            Text('Syncing'),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Icon(
            state.isOnline
                ? Icons.cloud_done
                : Icons.cloud_off,
            size: 20,
            color: state.isOnline
                ? Colors.green
                : Colors.red,
          ),
          const SizedBox(width: 5),
          Text(
            state.isOnline
                ? 'Online'
                : 'Offline',
          ),
        ],
      ),
    );
  }
}


class _SearchBox extends ConsumerWidget {
  const _SearchBox();

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        8,
      ),
      child: TextField(
        onChanged: (value) {
          ref
              .read(taskProvider.notifier)
              .search(value);
        },
        decoration: InputDecoration(
          hintText: 'Search task title...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}


class _FilterSortRow extends ConsumerWidget {
  const _FilterSortRow();

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(taskProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: state.filter,
              decoration: InputDecoration(
                labelText: 'Filter',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'All',
                  child: Text('All'),
                ),
                DropdownMenuItem(
                  value: 'Completed',
                  child: Text('Completed'),
                ),
                DropdownMenuItem(
                  value: 'Pending',
                  child: Text('Pending'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(taskProvider.notifier)
                      .setFilter(value);
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: state.sort,
              decoration: InputDecoration(
                labelText: 'Sort',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Due Date',
                  child: Text('Due Date'),
                ),
                DropdownMenuItem(
                  value: 'Priority',
                  child: Text('Priority'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(taskProvider.notifier)
                      .setSort(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}


class _TaskBody extends ConsumerWidget {
  final TaskState state;

  const _TaskBody({
    required this.state,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    if (state.isLoading && state.tasks.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null &&
        state.tasks.isEmpty) {
      return _ErrorView(
        message: state.errorMessage!,
      );
    }

    final tasks = state.filteredTasks;

    if (tasks.isEmpty) {
      return const _EmptyView();
    }

    return RefreshIndicator(
      onRefresh: () {
        return ref
            .read(taskProvider.notifier)
            .syncTasks();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return _TaskCard(
            task: tasks[index],
          );
        },
      ),
    );
  }
}


class _TaskCard extends ConsumerWidget {
  final TaskModel task;

  const _TaskCard({
    required this.task,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final priorityColor = _getPriorityColor(
      task.priority,
    );

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskDetailScreen(
                task: task,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (_) async {
                  await ref
                      .read(taskProvider.notifier)
                      .toggleCompleted(task);
                },
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      task.description.isEmpty
                          ? 'No description'
                          : task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor
                                .withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.priority,
                            style: TextStyle(
                              color: priorityColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.calendar_today,
                          size: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMM yyyy')
                              .format(task.dueDate),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditTaskScreen(
                          task: task,
                        ),
                      ),
                    );
                  }

                  if (value == 'delete') {
                    _deleteTask(
                      context,
                      ref,
                    );
                  }
                },
                itemBuilder: (_) => const [
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
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
      default:
        return Colors.green;
    }
  }

  void _deleteTask(
    BuildContext context,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text(
            'Are you sure you want to delete this task?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await ref
                    .read(taskProvider.notifier)
                    .deleteTask(task);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 70,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Create your first task',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}



class _ErrorView extends ConsumerWidget {
  final String message;

  const _ErrorView({
    required this.message,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 10),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(message),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(taskProvider.notifier)
                  .loadTasks();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}