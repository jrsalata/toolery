import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/tag/form.dart';
import 'package:toolery/models/tag.dart';

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

  @override
  Widget build(BuildContext context) {
    final tagNotifier = context.watch<TagChangeNotifier>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Tag')),
      body: Form(
        key: _formKey,
        child: TagForm(
          nameController: nameController,
          colorController: colorController,
          formButton: FilledButton(
            onPressed: (() async {
              if (_formKey.currentState!.validate()) {
                final Tag newTag = Tag(
                  id: -1,
                  name: nameController.text,
                  color: colorController.value,
                );
                await tagNotifier.insertTag(newTag);
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to validate!')),
                );
              }
            }),
            child: const Text('Add Tag'),
          ),
        ),
      ),
    );
  }
}
