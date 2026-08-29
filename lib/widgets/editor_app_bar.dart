import 'package:flutter/material.dart';

/// Shared AppBar for create/edit screens: an optional tag picker action,
/// a save checkmark, and (when editing) a styled overflow menu holding
/// Delete.
class EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EditorAppBar({
    super.key,
    required this.title,
    required this.onSave,
    this.tagAction,
    this.onDelete,
  });

  final String title;
  final VoidCallback onSave;

  /// Typically a [TagAction]; omitted on screens with nothing to tag
  /// (e.g. editing a Tag itself).
  final Widget? tagAction;

  /// Null on create screens, where there is nothing yet to delete.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      title: Text(title),
      actions: [
        ?tagAction,
        IconButton(
          icon: const Icon(Icons.check),
          tooltip: 'Save',
          onPressed: onSave,
        ),
        if (onDelete != null)
          PopupMenuButton<void>(
            tooltip: 'More',
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: onDelete,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline, color: cs.error),
                  title: Text('Delete', style: TextStyle(color: cs.error)),
                ),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
