import 'package:flutter/material.dart';
import 'package:toolery/widgets/confirm_dialog.dart';

/// Prompts before letting the user navigate away from unsaved changes.
///
/// [isDirty] is checked at pop time; when it returns true a confirm dialog
/// asks whether to discard the changes before the pop is allowed to proceed.
class UnsavedChangesGuard extends StatelessWidget {
  const UnsavedChangesGuard({
    super.key,
    required this.isDirty,
    required this.child,
  });

  final bool Function() isDirty;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!isDirty()) {
          if (context.mounted) Navigator.pop(context, result);
          return;
        }
        final discard = await confirmDestructive(
          context,
          title: 'Discard changes?',
          message:
              'You have unsaved changes. Are you sure you want to '
              'discard them?',
          confirmLabel: 'Discard',
        );
        if (discard && context.mounted) {
          Navigator.pop(context, result);
        }
      },
      child: child,
    );
  }
}
