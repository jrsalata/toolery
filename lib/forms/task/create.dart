import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/task/form.dart';
import 'package:toolery/models/task.dart';
import 'package:toolery/notifiers/task.dart';
import 'package:toolery/widgets/editor_app_bar.dart';
import 'package:toolery/widgets/tag_action.dart';
import 'package:toolery/widgets/unsaved_changes.dart';

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
  List<int> _tagIDs = [];

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    descriptionController.dispose();
    activityController.dispose();
    super.dispose();
  }

  bool _isDirty() {
    return nameController.text.isNotEmpty ||
        descriptionController.text.isNotEmpty ||
        activityController.text.isNotEmpty ||
        _tagIDs.isNotEmpty;
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final taskNotifier = context.read<TaskNotifier>();
      final Task newTask = Task(
        id: -1,
        name: nameController.text,
        description: descriptionController.text,
        task: activityController.text,
      );
      await taskNotifier.create(newTask, tagIDs: _tagIDs);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to validate!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesGuard(
      isDirty: _isDirty,
      watch: [nameController, descriptionController, activityController],
      child: Scaffold(
        appBar: EditorAppBar(
          title: 'Create New Task',
          tagAction: TagAction(
            tagIDs: _tagIDs,
            onChanged: (v) => setState(() => _tagIDs = v),
          ),
          onSave: _save,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: TaskForm(
              nameController: nameController,
              descriptionController: descriptionController,
              activityController: activityController,
            ),
          ),
        ),
      ),
    );
  }
}
