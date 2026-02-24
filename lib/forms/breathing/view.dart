import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/breathingExercises/exercise.dart';
import 'package:toolery/forms/breathing/update.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/notifiers/breathing.dart';
import 'package:toolery/notifiers/tag.dart';

// single-page to show all of the info on one breathing
class BreathingInfo extends StatelessWidget {
  const BreathingInfo({super.key, required this.breathingID});

  // single breathing to view
  final int breathingID;

  @override
  Widget build(BuildContext context) {
    final breathingNotifier = context.watch<BreathingNotifier>();
    return FutureBuilder<Breathing>(
      future: breathingNotifier.getById(breathingID),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final Breathing breathing = snapshot.data!;
        final tagNotifier = context.watch<TagNotifier>();
        if (breathing.id == -1) {
          return Scaffold(
            appBar: AppBar(title: const Text('Breathing')),
            body: const Center(child: Text('Breathing Exercise not found')),
          );
        }

        final List<int> tagIds = breathingNotifier.getTags(breathing);
        final tags = tagNotifier.tags
            .where((t) => tagIds.contains(t.id))
            .toList();

        return Scaffold(
          appBar: AppBar(title: Text(breathing.name)),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Description",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  breathing.humanReadable,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text("Tags", style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (Tag tag in tags)
                      Chip(
                        label: Text(tag.name),
                        labelStyle: TextStyle(
                          color: tag.color.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                        ),
                        backgroundColor: tag.color,
                      ),
                    if (tags.isEmpty) const Text('No tags'),
                  ],
                ),
                FilledButton(
                  child: const Text('Start Exercise'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ExerciseView(breathingID: breathingID),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push<bool>(
                context,
                MaterialPageRoute<bool>(
                  builder: (context) => UpdateBreathing(breathing: breathing),
                ),
              );
            },
            child: const Icon(Icons.edit),
          ),
        );
      },
    );
  }
}
