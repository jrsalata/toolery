import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/breathingExercises/phase.dart';

class ExerciseController extends ChangeNotifier {
  final Breathing breathing;

  List<Phase> phases = [];
  int phaseIndex = 0;
  int elapsed = 0;
  bool running = false;

  // initial starting value
  // will change with time
  double displayScale = 0.0;

  // max and mins
  final double minScale = 0.0;
  final double maxScale = 1.0;

  Timer? _tickTimer;

  ExerciseController(this.breathing) {
    _buildPhases();
  }

  Phase? get currentPhase {
    if (phaseIndex >= 0 && phaseIndex < phases.length) {
      return phases[phaseIndex];
    }
    return null;
  }

  void _buildPhases() {
    final List<Phase> p = [];
    for (int r = 0; r < breathing.reps; r++) {
      if (breathing.countIn > 0) {
        p.add(
          Phase(
            type: PhaseType.inhale,
            seconds: breathing.countIn,
            initialScale: minScale,
            targetScale: maxScale,
          ),
        );
      }
      if (breathing.holdIn > 0) {
        p.add(
          Phase(
            type: PhaseType.hold,
            seconds: breathing.holdIn,
            initialScale: maxScale,
            targetScale: maxScale,
          ),
        );
      }
      if (breathing.countOut > 0) {
        p.add(
          Phase(
            type: PhaseType.exhale,
            seconds: breathing.countOut,
            initialScale: maxScale,
            targetScale: minScale,
          ),
        );
      }
      if (breathing.holdOut > 0) {
        p.add(
          Phase(
            type: PhaseType.hold,
            seconds: breathing.holdOut,
            initialScale: minScale,
            targetScale: minScale,
          ),
        );
      }
    }
    phases = p;
  }

  void start(bool countUp, bool breathingVibrate) {
    if (phases.isEmpty) return;
    running = true;
    phaseIndex = 0;
    notifyListeners();
    _startPhase(phaseIndex, countUp, breathingVibrate);
  }

  void stop() {
    _tickTimer?.cancel();
    running = false;
    phaseIndex = 0;
    elapsed = 0;
    displayScale = minScale;
    notifyListeners();
  }

  void toggle(bool countUp, bool breathingVibrate) {
    if (running) {
      stop();
    } else {
      start(countUp, breathingVibrate);
    }
  }

  void _startPhase(int index, bool countUp, bool breathingVibrate) {
    if (index < 0 || index >= phases.length) {
      _completeExercise(breathingVibrate);
      return;
    }
    final Phase phase = phases[index];
    phaseIndex = index;
    elapsed = countUp ? 1 : phase.seconds;
    displayScale = phase.initialScale;
    notifyListeners();

    Future.microtask(() {
      displayScale = phase.targetScale;
      notifyListeners();
    });

    if (breathingVibrate) HapticFeedback.vibrate();

    _tickTimer?.cancel();
    if (phase.seconds <= 0) {
      Future.microtask(() => _advancePhase(countUp, breathingVibrate));
      return;
    }

    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!running) {
        timer.cancel();
        return;
      }
      elapsed += countUp ? 1 : -1;
      notifyListeners();
      if (countUp && elapsed > phase.seconds) {
        timer.cancel();
        _advancePhase(countUp, breathingVibrate);
      } else if (!countUp && elapsed <= 0) {
        timer.cancel();
        _advancePhase(countUp, breathingVibrate);
      }
    });
  }

  void _advancePhase(bool countUp, bool breathingVibrate) {
    final next = phaseIndex + 1;
    if (next >= phases.length) {
      _completeExercise(breathingVibrate);
    } else {
      _startPhase(next, countUp, breathingVibrate);
    }
  }

  void _completeExercise(bool breathingVibrate) {
    _tickTimer?.cancel();
    running = false;
    elapsed = 0;
    phaseIndex = 0;
    displayScale = minScale;
    notifyListeners();
    if (breathingVibrate) HapticFeedback.vibrate();
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }
}
