import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:toolery/models/journal.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/notifiers/journal.dart';
import 'package:toolery/notifiers/tag.dart';

class CreateJournal extends StatefulWidget {
  const CreateJournal({super.key});

  @override
  State<CreateJournal> createState() => _CreateJournalState();
}

class _CreateJournalState extends State<CreateJournal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _quillController = QuillController.basic();
  List<int> _tagIDs = [];

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Journal Entry')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextFormField(
                autofocus: true,
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Give this entry a title',
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
                  config: const QuillEditorConfig(
                    placeholder: 'Write your journal entry here...',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final content = jsonEncode(
                      _quillController.document.toDelta().toJson(),
                    );
                    final entry = Journal(
                      id: -1,
                      title: _titleController.text,
                      dateWritten: DateTime.now().toIso8601String(),
                      content: content,
                    );
                    final journalNotifier = context.read<JournalNotifier>();
                    final created = await journalNotifier.create(entry);
                    if (_tagIDs.isNotEmpty) {
                      await journalNotifier.setTags(created, _tagIDs);
                    }
                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a title')),
                    );
                  }
                },
                child: const Text('Save Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
