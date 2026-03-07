/// The category of a single breathing phase.
enum PhaseType {
  /// The user should breathe in.
  inhale,

  /// The user should hold their breath.
  hold,

  /// The user should breathe out.
  exhale,
}

/// Represents a single timed step within a breathing exercise sequence.
///
/// A [Phase] describes what the user should do ([type]), for how long
/// ([seconds]), and provides animation parameters ([initialScale],
/// [targetScale]) used by [BreathingVisualizer] to animate the circle.
///
/// Phases are constructed by [ExerciseController._buildPhases] from a
/// [Breathing] definition.
class Phase {
  /// Whether this phase is an inhale, hold, or exhale.
  final PhaseType type;

  /// Duration of this phase in seconds.
  final int seconds;

  /// The inner-circle scale at the start of this phase (`0.0` = empty lungs,
  /// `1.0` = full lungs).
  final double initialScale;

  /// The inner-circle scale the animation should reach by the end of this
  /// phase.
  final double targetScale;

  Phase({
    required this.type,
    required this.seconds,
    required this.initialScale,
    required this.targetScale,
  });

  /// Human-readable label for this phase (e.g. `"Inhale"`, `"Hold"`, `"Exhale"`).
  String get label {
    switch (type) {
      case PhaseType.inhale:
        return 'Inhale';
      case PhaseType.hold:
        return 'Hold';
      case PhaseType.exhale:
        return 'Exhale';
    }
  }
}
