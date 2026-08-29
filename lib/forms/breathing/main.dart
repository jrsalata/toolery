import 'package:flutter/material.dart';
import 'package:toolery/forms/breathing/create.dart';
import 'package:toolery/forms/breathing/list.dart';
import 'package:toolery/forms/breathing/settings.dart';

class BreathingPage extends StatelessWidget {
  const BreathingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathing Exercises'),
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
        actionsPadding: const EdgeInsets.only(right: 16.0),
      ),
      body: const BreathingList(),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Create breathing exercise',
        onPressed: () async {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute<bool>(
              builder: (context) => const CreateBreathing(),
            ),
          );
        },
        label: const Text('Breathing Exercise'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
