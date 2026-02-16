import 'package:flutter/material.dart';

class ExerciseControls extends StatelessWidget {
  final bool running;
  final VoidCallback onStartStop;
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
