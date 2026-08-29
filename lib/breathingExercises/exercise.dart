import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/breathingExercises/controller.dart';
import 'package:toolery/breathingExercises/controls.dart';
import 'package:toolery/breathingExercises/phase_info.dart';
import 'package:toolery/breathingExercises/visualizer.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/notifiers/breathing.dart';
import 'package:toolery/settings.dart';

/// Full-screen view for running a single guided breathing exercise.
///
/// Given a [breathingID], [ExerciseView] fetches the corresponding [Breathing]
/// record from [BreathingNotifier] and creates an [ExerciseController] scoped
/// to this route. While loading, a progress indicator is shown. If the record
/// cannot be found or an error occurs the user is presented with a descriptive
/// message.
///
/// The view is composed of three child widgets:
/// - [PhaseInfo] – shows the current phase label and elapsed/countdown timer.
/// - [BreathingVisualizer] – animated circle that expands and contracts with
///   the breathing rhythm.
/// - [ExerciseControls] – Start/Stop and Close buttons.
///
/// Parameters:
/// - [breathingID]: The database id of the [Breathing] exercise to run.
class ExerciseView extends StatelessWidget {
  /// The database id of the [Breathing] exercise to run.
  final int breathingID;

  const ExerciseView({super.key, required this.breathingID});

  @override
  Widget build(BuildContext context) {
    final breathingNotifier = context.watch<BreathingNotifier>();
    return FutureBuilder<Breathing>(
      future: breathingNotifier.getById(breathingID),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Breathing')),
            body: Center(
              child: Text('Error loading exercise: ${snapshot.error}'),
            ),
          );
        }
        final Breathing breathing = snapshot.data!;
        if (breathing.id == -1) {
          return Scaffold(
            appBar: AppBar(title: const Text('Breathing')),
            body: const Center(child: Text('Breathing Exercise not found')),
          );
        }

        final settings = context.read<SettingsNotifier>();

        return ChangeNotifierProvider<ExerciseController>(
          create: (_) => ExerciseController(
            breathing,
            settings.countUp,
            settings.breathingVibrate,
            settings.breathingSounds,
          ),
          child: Consumer<ExerciseController>(
            builder: (context, ctrl, _) {
              return Scaffold(
                appBar: AppBar(title: Text(breathing.name)),
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      PhaseInfo(
                        currentPhase: ctrl.currentPhase,
                        running: ctrl.running,
                        elapsed: ctrl.elapsed,
                        fallbackText: breathing.humanReadable,
                      ),
                      Expanded(
                        child: Center(
                          child: BreathingVisualizer(
                            currentPhase: ctrl.currentPhase,
                            displayScale: ctrl.displayScale,
                            minScale: ctrl.minScale,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ExerciseControls(
                        running: ctrl.running,
                        onStartStop: () => ctrl.toggle(),
                        onClose: () {
                          ctrl.stop();
                          Navigator.maybePop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
