import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/core/providers/task_provider.dart';

import '../models/task_model.dart';


class AddEditTaskScreen extends ConsumerStatefulWidget {
  final TaskModel? task;

  const AddEditTaskScreen({
    super.key,
    this.task,
  });

  @override
  ConsumerState<AddEditTaskScreen> createState() =>
      _AddEditTaskScreenState();
}

class _AddEditTaskScreenState
    extends ConsumerState<AddEditTaskScreen> {
  final formKey =
      GlobalKey<FormState>();

  final titleController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  String priority = 'Medium';

  DateTime? dueDate;

  bool get isEdit =>
      widget.task != null;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      titleController.text =
          widget.task!.title;

      descriptionController.text =
          widget.task!.description;

      priority =
          widget.task!.priority;

      dueDate =
          widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? 'Edit Task'
              : 'Add Task',
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: titleController,
              decoration:
                  const InputDecoration(
                labelText: 'Title',
                hintText:
                    'Enter task title',
                prefixIcon:
                    Icon(Icons.title),
                border:
                    OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Title is required';
                }

                if (value.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller:
                  descriptionController,
              maxLines: 4,
              decoration:
                  const InputDecoration(
                labelText: 'Description',
                hintText:
                    'Enter description',
                prefixIcon:
                    Icon(Icons.description),
                border:
                    OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: priority,
              decoration:
                  const InputDecoration(
                labelText: 'Priority',
                prefixIcon:
                    Icon(Icons.flag),
                border:
                    OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'High',
                  child: Text('High'),
                ),
                DropdownMenuItem(
                  value: 'Medium',
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: 'Low',
                  child: Text('Low'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    priority = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            InkWell(
              onTap: selectDate,
              child: InputDecorator(
                decoration:
                    const InputDecoration(
                  labelText: 'Due Date',
                  prefixIcon: Icon(
                    Icons.calendar_month,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
                child: Text(
                  dueDate == null
                      ? 'Select due date'
                      : DateFormat(
                          'dd MMM yyyy',
                        ).format(dueDate!),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: saveTask,
                child: Text(
                  isEdit
                      ? 'Update Task'
                      : 'Create Task',
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> selectDate() async {
    final selected =
        await showDatePicker(
      context: context,
      initialDate:
          dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        dueDate = selected;
      });
    }
  }

  Future<void> saveTask() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (dueDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a due date',
          ),
        ),
      );

      return;
    }

    final notifier =
        ref.read(taskProvider.notifier);

    if (isEdit) {
      await notifier.updateTask(
        task: widget.task!,
        title:
            titleController.text.trim(),
        description:
            descriptionController.text.trim(),
        priority: priority,
        dueDate: dueDate!,
      );
    } else {
      await notifier.createTask(
        title:
            titleController.text.trim(),
        description:
            descriptionController.text.trim(),
        priority: priority,
        dueDate: dueDate!,
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}