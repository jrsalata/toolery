import 'package:flutter/material.dart';

/// Start/Stop and Close buttons for the breathing exercise screen.
///
/// Displays two [FilledButton]s side by side:
/// - **Start / Stop** – toggles the exercise via [onStartStop]. The label
///   switches between "Start" (when [running] is `false`) and "Stop" (when
///   [running] is `true`).
/// - **Close** – calls [onClose], which should stop the exercise and pop the
///   current route.
///
/// Parameters:
/// - [running]: Whether the exercise is currently in progress.
/// - [onStartStop]: Callback invoked when the user taps the Start/Stop button.
/// - [onClose]: Callback invoked when the user taps the Close button.
class ExerciseControls extends StatelessWidget {
  /// Whether the exercise is currently running.
  final bool running;

  /// Called when the user taps the Start/Stop button.
  final VoidCallback onStartStop;

  /// Called when the user taps the Close button.
  final VoidCallback onClose;

  const ExerciseControls({
    super.key,
    required this.running,
    required this.onStartStop,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: onStartStop,
              child: Text(running ? 'Stop' : 'Start'),
            ),
            const SizedBox(width: 12),
            FilledButton(onPressed: onClose, child: const Text('Close')),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
