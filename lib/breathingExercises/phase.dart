enum PhaseType { inhale, hold, exhale }

class Phase {
  final PhaseType type;
  final int seconds;
  final double initialScale;
  final double targetScale;

  Phase({
    required this.type,
    required this.seconds,
    required this.initialScale,
    required this.targetScale,
  });

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
