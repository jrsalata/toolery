import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:toolery/models/journal.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/notifiers/journal.dart';
import 'package:toolery/notifiers/tag.dart';

class UpdateJournal extends StatefulWidget {
  const UpdateJournal({super.key, required this.entry});

  final Journal entry;

  @override
  State<UpdateJournal> createState() => _UpdateJournalState();
}

class _UpdateJournalState extends State<UpdateJournal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final QuillController _quillController;
  late List<int> _tagIDs;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _tagIDs = List<int>.from(context.read<JournalNotifier>().getTags(widget.entry));
    try {
      final delta = jsonDecode(widget.entry.content) as List<dynamic>;
      _quillController = QuillController(
        document: Document.fromJson(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (_) {
      _quillController = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journalNotifier = context.watch<JournalNotifier>();

    return Scaffold(
      appBar: AppBar(title: Text('Edit ${widget.entry.title}')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Consumer<TagNotifier>(
                builder: (context, tagNotifier, _) {
                  return Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (Tag tag in tagNotifier.tags)
                        FilterChip(
                          selected: _tagIDs.contains(tag.id),
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
                                if (!_tagIDs.contains(tag.id)) {
                                  _tagIDs.add(tag.id);
                                }
                              } else {
                                _tagIDs.remove(tag.id);
                              }
                            });
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
            const Divider(),
            QuillSimpleToolbar(
              controller: _quillController,
              config: const QuillSimpleToolbarConfig(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: QuillEditor.basic(
                  controller: _quillController,
                  config: const QuillEditorConfig(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FilledButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final content = jsonEncode(
                      _quillController.document.toDelta().toJson(),
                    );
                    final updated = widget.entry.copyWith(
                      title: _titleController.text,
                      content: content,
                    );
                    await journalNotifier.update(updated);
                    await journalNotifier.setTags(updated, _tagIDs);
                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a title')),
                    );
                  }
                },
                child: const Text('Save Changes'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FilledButton.tonal(
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
                      title: const Text('Delete entry?'),
                      content: const Text(
                        'This action cannot be undone. Are you sure you want to delete this journal entry?',
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
                    await journalNotifier.delete(widget.entry.id);
                    if (context.mounted) {
                      Navigator.pop(context, true);
                      Navigator.pop(context, true);
                    }
                  }
                },
                child: const Text('Delete'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
