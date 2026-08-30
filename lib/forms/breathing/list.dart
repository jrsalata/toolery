import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/breathing/view.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/notifiers/breathing.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/widgets/tag_filter_chips.dart';

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
            if (tags.tags.isNotEmpty) const Divider(),
            TagFilterChips(
              tags: tags.tags,
              selectedTagIds: filterTags,
              onChanged: (updated) => setState(() => filterTags = updated),
            ),
            if (tags.tags.isNotEmpty) const Divider(),
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
