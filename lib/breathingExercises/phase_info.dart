import 'package:flutter/material.dart';
import 'package:toolery/breathingExercises/phase.dart';

/// Displays the current breathing phase label and elapsed/countdown timer.
///
/// When the exercise is running, [PhaseInfo] shows the [Phase.label] of the
/// active phase (e.g. "Inhale", "Hold", "Exhale") and the [elapsed] counter.
/// When the exercise is idle it shows "Ready to begin?" and the [fallbackText]
/// (typically [Breathing.humanReadable]) to give the user a preview of the
/// pattern.
///
/// Parameters:
/// - [currentPhase]: The active [Phase], or `null` when idle.
/// - [running]: Whether the exercise is currently in progress.
/// - [elapsed]: The current elapsed (or remaining, if counting down) seconds.
/// - [fallbackText]: Text shown instead of the counter when [running] is
///   `false`. Defaults to an empty string.
class PhaseInfo extends StatelessWidget {
  /// The phase currently being executed.
  final Phase? currentPhase;

  /// Whether the exercise is currently running.
  final bool running;

  /// The elapsed (or remaining) seconds for the current phase.
  final int elapsed;

  /// Text shown when the exercise is not running (e.g. the pattern summary).
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
