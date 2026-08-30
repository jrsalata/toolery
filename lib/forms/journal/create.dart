import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/journal/form.dart';
import 'package:toolery/models/journal.dart';
import 'package:toolery/notifiers/journal.dart';
import 'package:toolery/widgets/unsaved_changes.dart';

class CreateJournal extends StatefulWidget {
  const CreateJournal({super.key});

  @override
  State<CreateJournal> createState() => _CreateJournalState();
}

class _CreateJournalState extends State<CreateJournal> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: DateFormat('EEEE, MMM d').format(DateTime.now()),
  );
  final _quillController = QuillController.basic();
  late final String _initialTitle;
  late final String _initialContent;
  List<int> _tagIDs = [];

  @override
  void initState() {
    super.initState();
    _initialTitle = _titleController.text;
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
    return _titleController.text != _initialTitle ||
        _encodedContent() != _initialContent ||
        _tagIDs.isNotEmpty;
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final content = _encodedContent();
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
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesGuard(
      isDirty: _isDirty,
      watch: [_titleController, _quillController],
      child: JournalForm(
        formKey: _formKey,
        appBarTitle: 'New Journal Entry',
        titleController: _titleController,
        titleAutofocus: false,
        quillController: _quillController,
        initialTagIDs: _tagIDs,
        onTagIDsChanged: (tagIDs) => setState(() => _tagIDs = tagIDs),
        onSave: _save,
      ),
    );
  }
}
