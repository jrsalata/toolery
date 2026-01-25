import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/models/task.dart';
import 'package:toolery/notifiers/tag.dart';

class TaskForm extends StatefulWidget {
  const TaskForm({
    super.key,
    required this.formButton,
    required this.nameController,
    required this.descriptionController,
    required this.activityController,
    this.task,
    this.initialTagIDs,
    this.onTagIDsChanged,
  });

  final ButtonStyleButton formButton;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController activityController;
  final Task? task;
  final List<int>? initialTagIDs;
  final ValueChanged<List<int>>? onTagIDsChanged;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  Task? task;
  List<int> tagIDs = [];
  late ButtonStyleButton _formButton;
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
    _formButton = widget.formButton;
    // initialize selected tag IDs from provided initialTagIDs
    if (widget.initialTagIDs != null) {
      tagIDs = List<int>.from(widget.initialTagIDs!);
    }

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
          decoration: InputDecoration(
            labelText: "Task Name",
            hintText: "Enter the name of a task",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please give a name';
            }
            return null;
          },
        ),
        TextFormField(
          autofocus: false,
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: "Description",
            hintText: "Provide a brief description of the task",
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
        TextFormField(
          autofocus: false,
          controller: activityController,
          decoration: InputDecoration(
            labelText: "Activity",
            hintText: "Provide step-by-step instructions",
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
        Wrap(
          children: [
            for (Tag tag in context.read<TagNotifier>().tags)
              FilterChip(
                selected: tagIDs.contains(tag.id),
                backgroundColor: tag.color,
                selectedColor: tag.color,
                label: Text(tag.name),
                labelStyle: TextStyle(
                  color: tag.color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                ),
                showCheckmark: true,
                checkmarkColor: tag.color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      if (!tagIDs.contains(tag.id)) tagIDs.add(tag.id);
                    } else {
                      tagIDs.remove(tag.id);
                    }
                  });
                  widget.onTagIDsChanged?.call(List<int>.from(tagIDs));
                },
              ),
          ],
        ),
        _formButton,
      ],
    );
  }
}
