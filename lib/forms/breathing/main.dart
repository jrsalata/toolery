import 'package:flutter/material.dart';
import 'package:toolery/forms/breathing/create.dart';
import 'package:toolery/forms/breathing/list.dart';
import 'package:toolery/forms/breathing/settings.dart';
import 'package:toolery/widgets/adaptive/adaptive_scaffold.dart';

class BreathingPage extends StatelessWidget {
  const BreathingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      title: 'Breathing Exercises',
      body: const BreathingList(),
      actionsPadding: const EdgeInsets.only(right: 16.0),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Breathing settings',
          onPressed: () async {
            await Navigator.push<bool>(
              context,
              MaterialPageRoute<bool>(
                builder: (context) => const BreathingSettingsPage(),
              ),
            );
          },
        ),
      ],
      primaryAction: AdaptivePrimaryAction(
        label: 'Breathing Exercise',
        tooltip: 'Create breathing exercise',
        onPressed: () async {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute<bool>(
              builder: (context) => const CreateBreathing(),
            ),
          );
        },
      ),
    );
  }
}
