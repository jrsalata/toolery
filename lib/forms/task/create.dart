import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/task/form.dart';
import 'package:toolery/models/task.dart';

// page to create the task
class CreateTask extends StatefulWidget {
  const CreateTask({super.key, this.task});

  final Task? task;

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final activityController = TextEditingController();

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
    final taskNotifier = context.watch<TaskChangeNotifier>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Task')),
      body: Form(
        key: _formKey,
        child: TaskForm(
          nameController: nameController,
          descriptionController: descriptionController,
          activityController: activityController,
          formButton: FilledButton(
            onPressed: (() async {
              if (_formKey.currentState!.validate()) {
                final Task newTask = Task(
                  id: -1,
                  name: nameController.text,
                  description: descriptionController.text,
                  task: activityController.text,
                );
                await taskNotifier.insertTask(newTask);
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to validate!')),
                );
              }
            }),
            child: const Text('Add Task'),
          ),
        ),
      ),
    );
  }
}
