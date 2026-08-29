import 'package:flutter/material.dart';
import 'package:toolery/models/task.dart';

class TaskForm extends StatefulWidget {
  const TaskForm({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.activityController,
    this.task,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController activityController;
  final Task? task;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  Task? task;
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController activityController;

  @override
  void initState() {
    super.initState();
    task = widget.task;
    nameController = widget.nameController;
    descriptionController = widget.descriptionController;
    activityController = widget.activityController;

    if (task != null) {
      nameController.text = task!.name;
      descriptionController.text = task!.description;
      activityController.text = task!.task;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          autofocus: true,
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Task Name',
            hintText: 'Enter the name of a task',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please give a name';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          autofocus: false,
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Provide a brief description of the task',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          minLines: 1,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please put a description';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          autofocus: false,
          controller: activityController,
          decoration: const InputDecoration(
            labelText: 'Activity',
            hintText: 'Provide step-by-step instructions',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.multiline,
          maxLines: null,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some instructions';
            }
            return null;
          },
        ),
      ],
    );
  }
}
