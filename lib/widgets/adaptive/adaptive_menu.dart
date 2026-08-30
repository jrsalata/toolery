import 'package:flutter/cupertino.dart'
    show
        CupertinoActionSheet,
        CupertinoActionSheetAction,
        showCupertinoModalPopup;
import 'package:flutter/material.dart';
import 'package:toolery/widgets/adaptive/platform.dart';

/// One entry in an [AdaptiveOverflowMenu].
class AdaptiveMenuItem {
  const AdaptiveMenuItem({
    required this.label,
    required this.icon,
    required this.onSelected,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onSelected;

  /// Tints the entry with the error colour on Android and marks it
  /// destructive (red) in the iOS action sheet.
  final bool isDestructive;
}

/// An app-bar overflow menu: a Material popup menu on Android, a Cupertino
/// action sheet on iOS.
class AdaptiveOverflowMenu extends StatelessWidget {
  const AdaptiveOverflowMenu({
    super.key,
    required this.items,
    this.tooltip = 'More',
  });

  final List<AdaptiveMenuItem> items;
  final String tooltip;

  Future<void> _showActionSheet(BuildContext context) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        actions: [
          for (final item in items)
            CupertinoActionSheetAction(
              isDestructiveAction: item.isDestructive,
              // Dismiss first: the callers open dialogs of their own, and the
              // sheet does not self-dismiss the way a PopupMenuItem does.
              onPressed: () {
                Navigator.pop(sheetContext);
                item.onSelected();
              },
              child: Text(item.label),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isCupertino(context)) {
      return IconButton(
        icon: Icon(Icons.adaptive.more),
        tooltip: tooltip,
        onPressed: () => _showActionSheet(context),
      );
    }

    final errorColor = Theme.of(context).colorScheme.error;
    return PopupMenuButton<void>(
      tooltip: tooltip,
      itemBuilder: (context) => [
        for (final item in items)
          PopupMenuItem<void>(
            onTap: item.onSelected,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                item.icon,
                color: item.isDestructive ? errorColor : null,
              ),
              title: Text(
                item.label,
                style: item.isDestructive ? TextStyle(color: errorColor) : null,
              ),
            ),
          ),
      ],
    );
  }
}
