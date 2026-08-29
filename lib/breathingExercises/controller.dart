import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sound_effect/sound_effect.dart';
import 'package:toolery/breathingExercises/phase.dart';
import 'package:toolery/models/breathing.dart';

/// Controls the state and timing for a single guided breathing exercise.
///
/// [ExerciseController] extends [ChangeNotifier] and is provided to the
/// widget tree by [ExerciseView] via a [ChangeNotifierProvider]. It converts
/// a [Breathing] definition into a flat list of [Phase]s, then advances
/// through them using a periodic [Timer].
///
/// **Key state**
/// - [phases] – the full sequence of phases built from the [Breathing].
/// - [phaseIndex] – index of the currently active phase.
/// - [elapsed] – seconds since the current phase started (counting up) or
///   remaining seconds (counting down), controlled by [countUp].
/// - [running] – whether the exercise is in progress.
/// - [displayScale] – inner-circle scale in `[0.0, 1.0]`, consumed by
///   [BreathingVisualizer].
///
/// Parameters:
/// - [breathing]: The exercise definition.
/// - [countUp]: When `true` the counter increases from 1; when `false` it
///   counts down from the phase duration.
/// - [breathingVibrate]: Trigger a haptic vibration at the start of each phase.
/// - [breathingSounds]: Play an audio cue at the start of each phase.
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

  /// The flat list of [Phase]s for this exercise.
  List<Phase> phases = [];

  /// Index of the currently active phase within [phases].
  int phaseIndex = 0;

  /// The elapsed or remaining seconds for the current phase.
  int elapsed = 0;

  /// Whether the exercise is currently running.
  bool running = false;

  /// Current scale of the inner circle in the [BreathingVisualizer] (`0.0`–`1.0`).
  double displayScale = 0.0;

  // max and mins
  /// Minimum displayScale value (inner circle at its smallest).
  final double minScale = 0.0;

  /// Maximum displayScale value (inner circle fills the outer circle).
  final double maxScale = 1.0;

  Timer? _tickTimer;

  /// Creates an [ExerciseController] for the given [breathing] definition.
  ///
  /// Phases are built immediately. If [breathingSounds] is `true` the audio
  /// assets are loaded asynchronously; if loading fails, sounds are silently
  /// disabled.
  ExerciseController(
    this.breathing,
    this.countUp,
    this.breathingVibrate,
    this.breathingSounds,
  ) {
    _buildPhases();
    if (breathingSounds) {
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
  }

  /// The currently active [Phase], or `null` if the exercise has not started
  /// or has completed.
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

  /// Starts the exercise from the first phase.
  ///
  /// Does nothing if [phases] is empty.
  void start() {
    if (phases.isEmpty) return;
    running = true;
    phaseIndex = 0;
    notifyListeners();
    _startPhase(phaseIndex);
  }

  /// Stops the exercise and resets all state to initial values.
  void stop() {
    _tickTimer?.cancel();
    running = false;
    phaseIndex = 0;
    elapsed = 0;
    displayScale = minScale;
    notifyListeners();
  }

  /// Toggles between running and stopped states.
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
