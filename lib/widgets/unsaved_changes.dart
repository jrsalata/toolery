import 'package:flutter/material.dart';
import 'package:toolery/widgets/confirm_dialog.dart';

/// Prompts before letting the user navigate away from unsaved changes.
///
/// [isDirty] is re-checked whenever any [Listenable] in [watch] notifies, or
/// the widget rebuilds. A clean screen pops immediately, including via the
/// iOS edge-swipe gesture; a dirty screen blocks the pop and asks whether to
/// discard.
///
/// Accepted limitation: once dirty, this disables the iOS back-swipe
/// entirely rather than letting it complete and then confirming — Flutter
/// offers no way to intercept a completed Cupertino back gesture, and native
/// iOS apps make the same trade for dirty sheets.
class UnsavedChangesGuard extends StatefulWidget {
  const UnsavedChangesGuard({
    super.key,
    required this.isDirty,
    required this.watch,
    required this.child,
  });

  final bool Function() isDirty;
  final List<Listenable> watch;
  final Widget child;

  @override
  State<UnsavedChangesGuard> createState() => _UnsavedChangesGuardState();
}

class _UnsavedChangesGuardState extends State<UnsavedChangesGuard> {
  late bool _dirty = widget.isDirty();
  late final Listenable _listenable = Listenable.merge(widget.watch);

  @override
  void initState() {
    super.initState();
    _listenable.addListener(_recompute);
  }

  @override
  void didUpdateWidget(UnsavedChangesGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _recompute();
  }

  @override
  void dispose() {
    _listenable.removeListener(_recompute);
    super.dispose();
  }

  void _recompute() {
    final dirty = widget.isDirty();
    if (dirty != _dirty) {
      setState(() => _dirty = dirty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
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
      child: widget.child,
    );
  }
}
