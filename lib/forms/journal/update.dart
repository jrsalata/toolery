import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/journal/form.dart';
import 'package:toolery/models/journal.dart';
import 'package:toolery/notifiers/journal.dart';

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

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final content = jsonEncode(_quillController.document.toDelta().toJson());
      final updated = widget.entry.copyWith(
        title: _titleController.text,
        content: content,
      );
      final journalNotifier = context.read<JournalNotifier>();
      await journalNotifier.update(updated);
      await journalNotifier.setTags(updated, _tagIDs);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
    }
  }

  Future<void> _delete() async {
    final journalNotifier = context.read<JournalNotifier>();
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
      if (mounted) {
        Navigator.pop(context, true);
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return JournalForm(
      formKey: _formKey,
      appBarTitle: 'Edit ${widget.entry.title}',
      titleController: _titleController,
      titleAutofocus: false,
      quillController: _quillController,
      initialTagIDs: _tagIDs,
      onTagIDsChanged: (tagIDs) => _tagIDs = tagIDs,
      onSave: _save,
      onDelete: _delete,
    );
  }
}
