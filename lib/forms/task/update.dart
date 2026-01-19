import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/task/form.dart';
import 'package:toolery/models/task.dart';
import 'package:toolery/notifiers/task.dart';

// page to update the task
class UpdateTask extends StatefulWidget {
  const UpdateTask({super.key, required this.task});

  final Task task;

  @override
  State<UpdateTask> createState() => _UpdateTaskState();
}

class _UpdateTaskState extends State<UpdateTask> {
  late Task _task;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final activityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    nameController.text = _task.name;
    descriptionController.text = _task.description;
    activityController.text = _task.task;
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    descriptionController.dispose();
    activityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskNotifier = context.watch<TaskNotifier>();
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${_task.name}')),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: TaskForm(
              nameController: nameController,
              descriptionController: descriptionController,
              activityController: activityController,
              task: _task,
              formButton: FilledButton(
                onPressed: (() async {
                  if (_formKey.currentState!.validate()) {
                    final Task updatedTask = Task(
                      id: _task.id,
                      name: nameController.text,
                      description: descriptionController.text,
                      task: activityController.text,
                    );
                    await taskNotifier.update(updatedTask);
                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to validate!')),
                    );
                  }
                }),
                child: const Text('Save Changes'),
              ),
            ),
          ),
          FilledButton.tonal(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.errorContainer,
              ),
              foregroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            onPressed: () async {
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete task?'),
                  content: const Text(
                    'This action cannot be undone. Are you sure you want to delete this task?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.error,
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await taskNotifier.delete(_task.id);
                if (context.mounted) {
                  // we need to pop out of the edit page
                  // and the task info page
                  Navigator.pop(context, true);
                  Navigator.pop(context, true);
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
