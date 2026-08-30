import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/breathingExercises/exercise.dart';
import 'package:toolery/forms/breathing/update.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/notifiers/breathing.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/widgets/adaptive/adaptive_menu.dart';
import 'package:toolery/widgets/confirm_dialog.dart';
import 'package:toolery/widgets/tag_action.dart';

// single-page to show all of the info on one breathing
class BreathingInfo extends StatelessWidget {
  const BreathingInfo({super.key, required this.breathingID});

  // single breathing to view
  final int breathingID;

  Future<void> _delete(BuildContext context, Breathing breathing) async {
    final breathingNotifier = context.read<BreathingNotifier>();
    final confirmed = await confirmDestructive(
      context,
      title: 'Delete breathing?',
      message:
          'This action cannot be undone. Are you sure you want to delete '
          'this breathing?',
    );
    if (confirmed) {
      await breathingNotifier.delete(breathing.id);
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final breathingNotifier = context.watch<BreathingNotifier>();
    return FutureBuilder<Breathing>(
      future: breathingNotifier.getById(breathingID),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
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
          appBar: AppBar(
            title: Text(breathing.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                onPressed: () async {
                  await Navigator.push<bool>(
                    context,
                    MaterialPageRoute<bool>(
                      builder: (context) =>
                          UpdateBreathing(breathing: breathing),
                    ),
                  );
                },
              ),
              AdaptiveOverflowMenu(
                items: [
                  AdaptiveMenuItem(
                    label: 'Delete',
                    icon: Icons.delete_outline,
                    isDestructive: true,
                    onSelected: () => _delete(context, breathing),
                  ),
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  breathing.humanReadable,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text('Tags', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (Tag tag in tags) TagChip(tag: tag),
                    if (tags.isEmpty)
                      Text(
                        'No tags',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
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
        );
      },
    );
  }
}
