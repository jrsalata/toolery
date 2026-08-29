import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/task/form.dart';
import 'package:toolery/models/task.dart';
import 'package:toolery/notifiers/task.dart';
import 'package:toolery/widgets/confirm_dialog.dart';
import 'package:toolery/widgets/editor_app_bar.dart';
import 'package:toolery/widgets/tag_action.dart';
import 'package:toolery/widgets/unsaved_changes.dart';

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
  late List<int> _tagIDs;
  late List<int> _initialTagIDs;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    nameController.text = _task.name;
    descriptionController.text = _task.description;
    activityController.text = _task.task;
    _initialTagIDs = context.read<TaskNotifier>().getTags(_task);
    _tagIDs = List<int>.from(_initialTagIDs);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    descriptionController.dispose();
    activityController.dispose();
    super.dispose();
  }

  bool _isDirty() {
    return nameController.text != _task.name ||
        descriptionController.text != _task.description ||
        activityController.text != _task.task ||
        !listEquals(_tagIDs, _initialTagIDs);
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final taskNotifier = context.read<TaskNotifier>();
      final Task updatedTask = Task(
        id: _task.id,
        name: nameController.text,
        description: descriptionController.text,
        task: activityController.text,
      );
      await taskNotifier.update(updatedTask);
      await taskNotifier.setTags(_task, _tagIDs);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to validate!')));
    }
  }

  Future<void> _delete() async {
    final taskNotifier = context.read<TaskNotifier>();
    final confirmed = await confirmDestructive(
      context,
      title: 'Delete task?',
      message:
          'This action cannot be undone. Are you sure you want to delete '
          'this task?',
    );
    if (confirmed) {
      await taskNotifier.delete(_task.id);
      if (mounted) {
        // we need to pop out of the edit page
        // and the task info page
        Navigator.pop(context, true);
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesGuard(
      isDirty: _isDirty,
      child: Scaffold(
        appBar: EditorAppBar(
          title: 'Edit ${_task.name}',
          tagAction: TagAction(
            tagIDs: _tagIDs,
            onChanged: (v) => setState(() => _tagIDs = v),
          ),
          onSave: _save,
          onDelete: _delete,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: TaskForm(
              nameController: nameController,
              descriptionController: descriptionController,
              activityController: activityController,
              task: _task,
            ),
          ),
        ),
      ),
    );
  }
}
