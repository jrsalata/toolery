import 'package:flutter/material.dart';
import 'package:toolery/forms/breathing/create.dart';
import 'package:toolery/forms/breathing/list.dart';

class BreathingPage extends StatelessWidget {
  const BreathingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breathing Exercises')),
      body: const BreathingList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute<bool>(
              builder: (context) => const CreateBreathing(),
            ),
          );
        },
        label: const Text("Breathing Exercise"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
