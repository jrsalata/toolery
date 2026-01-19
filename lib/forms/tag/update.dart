import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/tag/form.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/notifiers/tag.dart';

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

  @override
  Widget build(BuildContext context) {
    final tagNotifier = context.watch<TagNotifier>();
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${_tag.name}')),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: TagForm(
              nameController: nameController,
              colorController: colorController,
              tag: _tag,
              formButton: FilledButton(
                onPressed: (() async {
                  if (_formKey.currentState!.validate()) {
                    final Tag updatedTag = Tag(
                      id: _tag.id,
                      name: nameController.text,
                      color: colorController.value,
                    );
                    await tagNotifier.update(updatedTag);
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
                  title: const Text('Delete tag?'),
                  content: const Text(
                    'This action cannot be undone. Are you sure you want to delete this tag?',
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
                await tagNotifier.delete(_tag.id);
                if (context.mounted) {
                  // we need to pop out of the edit page
                  // and the tag info page
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
