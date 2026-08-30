import 'package:flutter/material.dart';

/// Gives Material-library content a [Material] ancestor inside an adaptive
/// dialog.
///
/// On iOS `AlertDialog.adaptive` builds a `CupertinoAlertDialog`, which is not
/// a [Material]. Anything from the Material library that paints ink -- an
/// [InkWell], a [TextField] -- asserts "No Material widget found" in that
/// tree, so a dialog that works on Android crashes on iOS.
///
/// Wrapping the content in a transparent [Material] fixes iOS and is a no-op
/// on Android, where the enclosing [AlertDialog] already provides one.
class AdaptiveDialogContent extends StatelessWidget {
  const AdaptiveDialogContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(type: MaterialType.transparency, child: child);
  }
}
