import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/breathing/view.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/notifiers/breathing.dart';

// dedicated Widget to list all of the breathings
class BreathingList extends StatefulWidget {
  const BreathingList({super.key});

  @override
  State<BreathingList> createState() => _BreathingListState();
}

class _BreathingListState extends State<BreathingList> {
  List<int> filterTags = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<TagNotifier>(
      builder: (context, tags, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tags.tags.isNotEmpty) Divider(),
            Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                const SizedBox(width: 6, height: 6),
                for (Tag tag in tags.tags)
                  FilterChip(
                    selected: filterTags.contains(tag.id),
                    backgroundColor: tag.color,
                    selectedColor: tag.color,
                    label: Text(tag.name),
                    labelStyle: TextStyle(
                      color: tag.color.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    ),
                    showCheckmark: true,
                    checkmarkColor: tag.color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          if (!filterTags.contains(tag.id)) {
                            filterTags.add(tag.id);
                          }
                        } else {
                          filterTags.remove(tag.id);
                        }
                      });
                    },
                  ),
              ],
            ),
            if (tags.tags.isNotEmpty) Divider(),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        );
      },
      child: Consumer<BreathingNotifier>(
        builder: (context, breathings, child) {
          if (breathings.breathings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.air,
                    size: 72,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No breathing exercises yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first exercise',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          final List<Breathing> filteredBreathings = breathings.breathings
              .where((breathing) {
                return filterTags.isEmpty ||
                    filterTags.any(
                      (tagID) => breathings.getTags(breathing).contains(tagID),
                    );
              })
              .toList();

          if (filteredBreathings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list_off,
                    size: 72,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No exercises match the selected filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: filteredBreathings.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final breathing = filteredBreathings[index];
              return ListTile(
                title: Text(breathing.name),
                subtitle: Text(breathing.humanReadable),
                onTap: () async {
                  await Navigator.push<bool>(
                    context,
                    MaterialPageRoute<bool>(
                      builder: (context) =>
                          BreathingInfo(breathingID: breathing.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
