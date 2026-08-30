import 'package:flutter/material.dart';

/// Whether this subtree should render iOS-style chrome.
///
/// Reads `Theme.of(context).platform` rather than `Platform.isIOS` or
/// [defaultTargetPlatform], because only this form respects
/// `ThemeData(platform:)` — which is how tests select a platform without a
/// leaking global override.
bool isCupertino(BuildContext context) =>
    Theme.of(context).platform == TargetPlatform.iOS;
