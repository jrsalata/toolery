import 'package:flutter/material.dart';
import 'package:toolery/breathingExercises/phase.dart';

class BreathingVisualizer extends StatelessWidget {
  final Phase? currentPhase;
  final double displayScale;
  final double minScale;
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
