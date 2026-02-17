import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/notifiers/breathing.dart';
import 'package:toolery/breathingExercises/controller.dart';
import 'package:toolery/breathingExercises/visualizer.dart';
import 'package:toolery/breathingExercises/phase_info.dart';
import 'package:toolery/breathingExercises/controls.dart';
import 'package:toolery/settings.dart';

class ExerciseView extends StatelessWidget {
  final int breathingID;

  const ExerciseView({super.key, required this.breathingID});

  @override
  Widget build(BuildContext context) {
    final breathingNotifier = context.watch<BreathingNotifier>();
    return FutureBuilder<Breathing>(
      future: breathingNotifier.getById(breathingID),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final Breathing? breathing = snapshot.data;
        if (breathing == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Breathing')),
            body: const Center(child: Text('Breathing Exercise not found')),
          );
        }
        return ChangeNotifierProvider<ExerciseController>(
          create: (_) => ExerciseController(breathing),
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
                        onStartStop: () => ctrl.toggle(
                          context.read<SettingsNotifier>().countUp,
                        ),
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
