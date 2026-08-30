import 'package:flutter/material.dart';
import 'package:toolery/widgets/adaptive/adaptive_menu.dart';

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
    return AppBar(
      title: Text(title),
      actions: [
        ?tagAction,
        IconButton(
          icon: const Icon(Icons.check),
          tooltip: 'Save',
          onPressed: onSave,
        ),
        if (onDelete case final onDelete?)
          AdaptiveOverflowMenu(
            items: [
              AdaptiveMenuItem(
                label: 'Delete',
                icon: Icons.delete_outline,
                isDestructive: true,
                onSelected: onDelete,
              ),
            ],
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
