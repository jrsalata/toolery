import 'package:flutter/material.dart';

/// Calculates the WCAG contrast ratio between two colors.
double _contrastRatio(Color a, Color b) {
  final luminanceA = a.computeLuminance();
  final luminanceB = b.computeLuminance();
  final lighter = luminanceA > luminanceB ? luminanceA : luminanceB;
  final darker = luminanceA > luminanceB ? luminanceB : luminanceA;
  return (lighter + 0.05) / (darker + 0.05);
}

/// Returns either black or white text, whichever has the higher contrast ratio
/// against the provided [background] color.
Color highContrastTextColor(Color background) {
  final blackContrast = _contrastRatio(background, Colors.black);
  final whiteContrast = _contrastRatio(background, Colors.white);
  return blackContrast >= whiteContrast ? Colors.black : Colors.white;
}
