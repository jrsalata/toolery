import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/journal/update.dart';
import 'package:toolery/models/journal.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/notifiers/journal.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/widgets/adaptive/adaptive_menu.dart';
import 'package:toolery/widgets/confirm_dialog.dart';
import 'package:toolery/widgets/tag_action.dart';

class JournalView extends StatefulWidget {
  const JournalView({super.key, required this.entryID});

  final int entryID;

  @override
  State<JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends State<JournalView> {
  QuillController? _quillController;
  Journal? _entry;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  @override
  void dispose() {
    _quillController?.dispose();
    super.dispose();
  }

  Future<void> _loadEntry() async {
    try {
      final entry = await context.read<JournalNotifier>().getById(
        widget.entryID,
      );
      QuillController controller;
      try {
        final delta = jsonDecode(entry.content) as List<dynamic>;
        controller = QuillController(
          document: Document.fromJson(delta),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      } catch (_) {
        controller = QuillController.basic();
      }
      if (mounted) {
        setState(() {
          _entry = entry;
          _quillController?.dispose();
          _quillController = controller;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _delete(Journal entry) async {
    final journalNotifier = context.read<JournalNotifier>();
    final confirmed = await confirmDestructive(
      context,
      title: 'Delete entry?',
      message:
          'This action cannot be undone. Are you sure you want to delete '
          'this journal entry?',
    );
    if (confirmed) {
      await journalNotifier.delete(entry.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Journal')),
        body: Center(child: Text('Error loading entry: $_error')),
      );
    }

    final entry = _entry;
    if (entry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Journal')),
        body: const Center(child: Text('Entry not found')),
      );
    }

    final journalNotifier = context.watch<JournalNotifier>();
    final tagNotifier = context.watch<TagNotifier>();
    final List<int> tagIds = journalNotifier.getTags(entry);
    final tags = tagNotifier.tags.where((t) => tagIds.contains(t.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () async {
              await Navigator.push<bool>(
                context,
                MaterialPageRoute<bool>(
                  builder: (context) => UpdateJournal(entry: entry),
                ),
              );
              // Reload entry data after returning from update
              await _loadEntry();
            },
          ),
          AdaptiveOverflowMenu(
            items: [
              AdaptiveMenuItem(
                label: 'Delete',
                icon: Icons.delete_outline,
                isDestructive: true,
                onSelected: () => _delete(entry),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(entry.dateWritten),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (Tag tag in tags) TagChip(tag: tag)],
            ),
            if (tags.isNotEmpty) const SizedBox(height: 8),
            const Divider(),
            Expanded(
              child: QuillEditor.basic(
                controller: _quillController!,
                config: const QuillEditorConfig(showCursor: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
