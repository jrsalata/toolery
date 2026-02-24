import 'package:flutter/material.dart';
import 'package:toolery/breathingExercises/phase.dart';

class PhaseInfo extends StatelessWidget {
  final Phase? currentPhase;
  final bool running;
  final int elapsed;
  final String fallbackText;

  const PhaseInfo({
    super.key,
    required this.currentPhase,
    required this.running,
    required this.elapsed,
    this.fallbackText = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Text(
          running ? currentPhase?.label ?? 'Ready' : 'Ready to begin?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          running ? '$elapsed' : fallbackText,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
