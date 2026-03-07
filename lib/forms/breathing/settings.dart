import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/settings.dart';

class BreathingSettingsPage extends StatelessWidget {
  const BreathingSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breathing Settings')),
      body: Center(
        child: Consumer<SettingsNotifier>(
          builder: (context, settings, child) => ListView(
            children: [
              Card(
                child: ListTile(
                  title: const Text("Count up for breathing exercises?"),
                  subtitle: settings.countUp
                      ? const Text("Currently: 1, 2, 3, 4")
                      : const Text("Currently: 4, 3, 2, 1"),
                  trailing: Switch(
                    value: settings.countUp,
                    onChanged: ((bool value) {
                      settings.changeCountUp(value);
                    }),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Enable sounds?"),
                  trailing: Switch(
                    value: settings.breathingSounds,
                    onChanged: ((bool value) {
                      settings.changeBreathingSounds(value);
                    }),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Turn on vibrations?"),
                  trailing: Switch(
                    value: settings.breathingVibrate,
                    onChanged: ((bool value) {
                      settings.changeBreathingVibrate(value);
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
