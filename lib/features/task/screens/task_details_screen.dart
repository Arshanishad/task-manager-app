import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/core/providers/task_provider.dart';
import '../models/task_model.dart';
import 'add_edit_task_screen.dart';

class TaskDetailScreen extends ConsumerWidget {
  final TaskModel task;

  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditTaskScreen(
                    task: task,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    task.isCompleted
                        ? 'Completed'
                        : 'Pending',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _InfoCard(
            icon: Icons.description,
            title: 'Description',
            value: task.description.isEmpty
                ? 'No description'
                : task.description,
          ),
          _InfoCard(
            icon: Icons.flag,
            title: 'Priority',
            value: task.priority,
          ),
          _InfoCard(
            icon: Icons.calendar_today,
            title: 'Due Date',
            value: DateFormat(
              'dd MMM yyyy',
            ).format(task.dueDate),
          ),

          // CREATED DATE
          _InfoCard(
            icon: Icons.access_time,
            title: 'Created Date',
            value: DateFormat(
              'dd MMM yyyy, hh:mm a',
            ).format(task.createdDate),
          ),

          // TASK ID
          _InfoCard(
            icon: Icons.fingerprint,
            title: 'Task ID',
            value: task.id,
          ),

          const SizedBox(height: 20),

          // COMPLETE / PENDING
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ref
                    .read(taskProvider.notifier)
                    .toggleCompleted(task);

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              icon: Icon(
                task.isCompleted
                    ? Icons.undo
                    : Icons.check,
              ),
              label: Text(
                task.isCompleted
                    ? 'Mark as Pending'
                    : 'Mark as Completed',
              ),
            ),
          ),

          const SizedBox(height: 10),

          // DELETE
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                showDeleteDialog(
                  context,
                  ref,
                );
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              label: const Text(
                'Delete Task',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showDeleteDialog(
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

                if (context.mounted) {
                  Navigator.pop(context);
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        leading: const Icon(
          Icons.info,
          color: Colors.indigo,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 4,
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}