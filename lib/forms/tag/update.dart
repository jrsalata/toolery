import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/tag/form.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/widgets/confirm_dialog.dart';
import 'package:toolery/widgets/editor_app_bar.dart';
import 'package:toolery/widgets/unsaved_changes.dart';

// page to update the tag
class UpdateTag extends StatefulWidget {
  const UpdateTag({super.key, required this.tag});

  final Tag tag;

  @override
  State<UpdateTag> createState() => _UpdateTagState();
}

class _UpdateTagState extends State<UpdateTag> {
  late Tag _tag;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  late ValueNotifier<Color> colorController;

  @override
  void initState() {
    super.initState();
    _tag = widget.tag;
    nameController.text = _tag.name;
    colorController = ValueNotifier(_tag.color);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    colorController.dispose();
    super.dispose();
  }

  bool _isDirty() {
    return nameController.text != _tag.name ||
        colorController.value != _tag.color;
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final tagNotifier = context.read<TagNotifier>();
      final Tag updatedTag = Tag(
        id: _tag.id,
        name: nameController.text,
        color: colorController.value,
      );
      await tagNotifier.update(updatedTag);
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
    final tagNotifier = context.read<TagNotifier>();
    final confirmed = await confirmDestructive(
      context,
      title: 'Delete tag?',
      message:
          'This action cannot be undone. Are you sure you want to delete '
          'this tag?',
    );
    if (confirmed) {
      await tagNotifier.delete(_tag.id);
      if (mounted) {
        // we need to pop out of the edit page
        // and the tag info page
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesGuard(
      isDirty: _isDirty,
      watch: [nameController, colorController],
      child: Scaffold(
        appBar: EditorAppBar(
          title: 'Edit ${_tag.name}',
          onSave: _save,
          onDelete: _delete,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: TagForm(
              nameController: nameController,
              colorController: colorController,
              tag: _tag,
            ),
          ),
        ),
      ),
    );
  }
}
