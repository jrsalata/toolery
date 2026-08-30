import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/journal/view.dart';
import 'package:toolery/models/journal.dart';
import 'package:toolery/notifiers/journal.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/widgets/tag_filter_chips.dart';

class JournalList extends StatefulWidget {
  const JournalList({super.key});

  @override
  State<JournalList> createState() => _JournalListState();
}

class _JournalListState extends State<JournalList> {
  List<int> filterTags = [];

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

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
      child: Consumer<JournalNotifier>(
        builder: (context, journal, child) {
          if (journal.entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 72,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No journal entries yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to write your first entry',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          final List<Journal> filteredEntries = journal.entries.where((entry) {
            return filterTags.isEmpty ||
                filterTags.any(
                  (tagID) => journal.getTags(entry).contains(tagID),
                );
          }).toList();

          if (filteredEntries.isEmpty) {
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
                    'No entries match the selected filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: filteredEntries.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = filteredEntries[index];
              return ListTile(
                title: Text(entry.title),
                subtitle: Text(_formatDate(entry.dateWritten)),
                onTap: () async {
                  await Navigator.push<bool>(
                    context,
                    MaterialPageRoute<bool>(
                      builder: (context) => JournalView(entryID: entry.id),
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
