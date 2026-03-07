import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/breathingExercises/phase.dart';
import 'package:sound_effect/sound_effect.dart';

class ExerciseController extends ChangeNotifier {
  // breathing exercise that we are controlling
  final Breathing breathing;

  // flags and settings
  final bool countUp;
  final bool breathingVibrate;
  final bool breathingSounds;

  // sound effect management
  final SoundEffect _soundEffect = SoundEffect();
  bool _soundsLoaded = false;

  // state management
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

  ExerciseController(
    this.breathing,
    this.countUp,
    this.breathingVibrate,
    this.breathingSounds,
  ) {
    _buildPhases();
    Future.microtask(() async {
      try {
        await _soundEffect.initialize();
        await _soundEffect.load('inhale', 'assets/audio/block1.mp3');
        await _soundEffect.load('hold', 'assets/audio/stick1.mp3');
        await _soundEffect.load('exhale', 'assets/audio/block2.mp3');
        _soundsLoaded = true;
      } catch (_) {
        _soundsLoaded = false;
      }
    });
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

  void start() {
    if (phases.isEmpty) return;
    running = true;
    phaseIndex = 0;
    notifyListeners();
    _startPhase(phaseIndex);
  }

  void stop() {
    _tickTimer?.cancel();
    running = false;
    phaseIndex = 0;
    elapsed = 0;
    displayScale = minScale;
    notifyListeners();
  }

  void toggle() {
    if (running) {
      stop();
    } else {
      start();
    }
  }

  void _playForPhase(Phase phase) {
    if (!_soundsLoaded) return;
    switch (phase.type) {
      case PhaseType.inhale:
        _soundEffect.play('inhale');
        break;
      case PhaseType.hold:
        _soundEffect.play('hold');
        break;
      case PhaseType.exhale:
        _soundEffect.play('exhale');
        break;
    }
  }

  void _startPhase(int index) {
    if (index < 0 || index >= phases.length) {
      _completeExercise();
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

    if (breathingSounds) _playForPhase(phase);

    _tickTimer?.cancel();
    if (phase.seconds <= 0) {
      Future.microtask(() => _advancePhase());
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
        _advancePhase();
      } else if (!countUp && elapsed <= 0) {
        timer.cancel();
        _advancePhase();
      }
    });
  }

  void _advancePhase() {
    final next = phaseIndex + 1;
    if (next >= phases.length) {
      _completeExercise();
    } else {
      _startPhase(next);
    }
  }

  void _completeExercise() {
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
    _soundEffect.release();
    super.dispose();
  }
}
