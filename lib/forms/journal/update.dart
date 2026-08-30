import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/journal/form.dart';
import 'package:toolery/models/journal.dart';
import 'package:toolery/notifiers/journal.dart';
import 'package:toolery/widgets/confirm_dialog.dart';
import 'package:toolery/widgets/unsaved_changes.dart';

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
  late final String _initialContent;
  late final List<int> _initialTagIDs;
  late List<int> _tagIDs;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _initialTagIDs = List<int>.from(
      context.read<JournalNotifier>().getTags(widget.entry),
    );
    _tagIDs = List<int>.from(_initialTagIDs);
    try {
      final delta = jsonDecode(widget.entry.content) as List<dynamic>;
      _quillController = QuillController(
        document: Document.fromJson(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (_) {
      _quillController = QuillController.basic();
    }
    _initialContent = _encodedContent();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  /// Encoded so it compares by value — the raw delta is a list of maps, which
  /// Dart compares by identity, making every fresh `toJson()` look different.
  String _encodedContent() =>
      jsonEncode(_quillController.document.toDelta().toJson());

  bool _isDirty() {
    return _titleController.text != widget.entry.title ||
        _encodedContent() != _initialContent ||
        !listEquals(_tagIDs, _initialTagIDs);
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final content = _encodedContent();
      final updated = widget.entry.copyWith(
        title: _titleController.text,
        content: content,
      );
      final journalNotifier = context.read<JournalNotifier>();
      await journalNotifier.update(updated, tagIDs: _tagIDs);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
    }
  }

  Future<void> _delete() async {
    final journalNotifier = context.read<JournalNotifier>();
    final confirm = await confirmDestructive(
      context,
      title: 'Delete entry?',
      message:
          'This action cannot be undone. Are you sure you want to delete '
          'this journal entry?',
    );
    if (confirm) {
      await journalNotifier.delete(widget.entry.id);
      if (mounted) {
        Navigator.pop(context, true);
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesGuard(
      isDirty: _isDirty,
      watch: [_titleController, _quillController],
      child: JournalForm(
        formKey: _formKey,
        appBarTitle: 'Edit ${widget.entry.title}',
        titleController: _titleController,
        titleAutofocus: false,
        quillController: _quillController,
        initialTagIDs: _tagIDs,
        onTagIDsChanged: (tagIDs) => setState(() => _tagIDs = tagIDs),
        onSave: _save,
        onDelete: _delete,
      ),
    );
  }
}
