import 'package:flutter/cupertino.dart' show CupertinoDialogAction;
import 'package:flutter/material.dart';
import 'package:toolery/widgets/adaptive/platform.dart';

/// Shows a destructive-action confirmation dialog and returns whether the
/// user confirmed. Never returns `null` — dismissing the dialog (e.g. by
/// tapping outside it) is treated the same as tapping Cancel.
///
/// The actions are branched by hand rather than left to `AlertDialog.adaptive`
/// because the "destructive" emphasis has no shared spelling: Material wants a
/// button styled with the error colour, Cupertino wants
/// [CupertinoDialogAction.isDestructiveAction].
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
}) async {
  final bool? confirmed = await showAdaptiveDialog<bool>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text(title),
      content: Text(message),
      actions: isCupertino(context)
          ? [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmLabel),
              ),
            ]
          : [
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
                child: Text(confirmLabel),
              ),
            ],
    ),
  );
  return confirmed ?? false;
}
