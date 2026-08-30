import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/models/affirmation_item.dart';
import 'package:toolery/models/affirmation_list.dart';
import 'package:toolery/notifiers/affirmation.dart';
import 'package:toolery/widgets/adaptive/adaptive_scaffold.dart';
import 'package:toolery/widgets/confirm_dialog.dart';

/// Full-page view of all items in one affirmation list.
/// Inline dialogs handle add and edit; delete is in-place.
class AffirmationDetailPage extends StatefulWidget {
  const AffirmationDetailPage({super.key, required this.list});

  final AffirmationList list;

  @override
  State<AffirmationDetailPage> createState() => _AffirmationDetailPageState();
}

class _AffirmationDetailPageState extends State<AffirmationDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load items when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AffirmationNotifier>().loadItemsForList(widget.list.id);
    });
  }

  Future<void> _showItemDialog({AffirmationItem? existing}) async {
    final notifier = context.read<AffirmationNotifier>();

    await showAdaptiveDialog<void>(
      context: context,
      builder: (context) => _AffirmationItemDialog(
        existing: existing,
        notifier: notifier,
        listId: widget.list.id,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AffirmationItem item,
  ) async {
    final notifier = context.read<AffirmationNotifier>();
    final confirmed = await confirmDestructive(
      context,
      title: 'Delete affirmation?',
      message: '"${item.item}"',
    );
    if (confirmed) {
      await notifier.deleteItem(item.id, listId: widget.list.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      title: widget.list.name,
      primaryAction: AdaptivePrimaryAction(
        label: 'Add',
        tooltip: 'Add affirmation',
        onPressed: () => _showItemDialog(),
      ),
      body: Consumer<AffirmationNotifier>(
        builder: (context, notifier, _) {
          final listItems = notifier.items[widget.list.id] ?? [];
          if (listItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.format_quote,
                    size: 72,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No affirmations yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first affirmation',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: listItems.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = listItems[index];
              return ListTile(
                title: Text(item.item),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit',
                      onPressed: () => _showItemDialog(existing: item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete',
                      onPressed: () => _confirmDelete(context, item),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AffirmationItemDialog extends StatefulWidget {
  const _AffirmationItemDialog({
    this.existing,
    required this.notifier,
    required this.listId,
  });

  final AffirmationItem? existing;
  final AffirmationNotifier notifier;
  final int listId;

  @override
  State<_AffirmationItemDialog> createState() => _AffirmationItemDialogState();
}

class _AffirmationItemDialogState extends State<_AffirmationItemDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existing?.item ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.existing == null) {
      await widget.notifier.addItem(
        AffirmationItem(
          id: -1,
          listId: widget.listId,
          item: _controller.text.trim(),
        ),
      );
    } else {
      await widget.notifier.updateItem(
        widget.existing!.copyWith(item: _controller.text.trim()),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text(
        widget.existing == null ? 'Add Affirmation' : 'Edit Affirmation',
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Affirmation',
            hintText: 'ex) I am not a burden',
          ),
          minLines: 1,
          maxLines: 4,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please enter text' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _onSave,
          child: Text(widget.existing == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
