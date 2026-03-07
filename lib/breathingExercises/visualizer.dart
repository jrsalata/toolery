import 'package:flutter/material.dart';
import 'package:toolery/breathingExercises/phase.dart';

/// Animated circle that expands and contracts to guide the user's breathing.
///
/// The outer circle is fixed in size and provides a reference boundary. The
/// inner circle animates between a fraction of that size (representing empty
/// lungs) and the full outer diameter (representing full lungs).
///
/// The animation duration matches the current phase's duration so that the
/// circle reaches its target size exactly when the phase ends. During a hold
/// phase [Duration.zero] is used so the circle snaps to its target immediately
/// and stays there for the hold period.
///
/// Parameters:
/// - [currentPhase]: The active [Phase], or `null` when the exercise is idle.
/// - [displayScale]: The target scale for the inner circle, in the range
///   `[0.0, 1.0]` where `1.0` fills the outer circle completely.
/// - [minScale]: The minimum inner-circle scale (default `0.10`). Override
///   for testing or visual customisation.
/// - [baseSize]: Optional fixed size for the outer circle. Defaults to 75% of
///   the device's shortest side, clamped to `[120, 420]` logical pixels.
class BreathingVisualizer extends StatelessWidget {
  /// The phase currently being executed, used to determine animation duration.
  final Phase? currentPhase;

  /// Target scale of the inner circle in `[0.0, 1.0]`.
  final double displayScale;

  /// Minimum inner-circle scale (the "empty lungs" position).
  final double minScale;

  /// Optional fixed outer-circle diameter in logical pixels.
  final double? baseSize;

  const BreathingVisualizer({
    super.key,
    required this.currentPhase,
    required this.displayScale,
    this.minScale = 0.10,
    this.baseSize,
  });

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.of(context).size.shortestSide;
    final double resolvedBase = (baseSize ?? (shortest * 0.75))
        .clamp(120.0, 420.0)
        .toDouble();

    final isHold = currentPhase?.type == PhaseType.hold;
    final duration = isHold
        ? Duration.zero
        : Duration(seconds: (currentPhase?.seconds ?? 1).clamp(1, 120));
    final desiredScale = displayScale;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: resolvedBase,
          height: resolvedBase,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        AnimatedContainer(
          curve: Curves.easeInOutQuad,
          duration: duration,
          width: resolvedBase * desiredScale,
          height: resolvedBase * desiredScale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}
