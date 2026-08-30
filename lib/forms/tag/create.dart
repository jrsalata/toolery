import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/tag/form.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/widgets/editor_app_bar.dart';
import 'package:toolery/widgets/unsaved_changes.dart';

// page to create a tag
class CreateTag extends StatefulWidget {
  const CreateTag({super.key, this.tag});

  final Tag? tag;

  @override
  State<CreateTag> createState() => _CreateTagState();
}

class _CreateTagState extends State<CreateTag> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ValueNotifier<Color> colorController = ValueNotifier<Color>(
    Colors.blue,
  );

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    colorController.dispose();
    super.dispose();
  }

  bool _isDirty() {
    return nameController.text.isNotEmpty ||
        colorController.value != Colors.blue;
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final tagNotifier = context.read<TagNotifier>();
      final Tag newTag = Tag(
        id: -1,
        name: nameController.text,
        color: colorController.value,
      );
      await tagNotifier.create(newTag);
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
      watch: [nameController, colorController],
      child: Scaffold(
        appBar: EditorAppBar(title: 'Create New Tag', onSave: _save),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: TagForm(
              nameController: nameController,
              colorController: colorController,
            ),
          ),
        ),
      ),
    );
  }
}
