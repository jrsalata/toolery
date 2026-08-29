import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/affirmation/detail.dart';
import 'package:toolery/models/affirmation_list.dart';
import 'package:toolery/notifiers/affirmation.dart';

class AffirmationListView extends StatelessWidget {
  const AffirmationListView({super.key});

  Future<void> _confirmDeleteList(
    BuildContext context,
    AffirmationNotifier notifier,
    AffirmationList list,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete list?'),
        content: Text(
          'Delete "${list.name}" and all its affirmations? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await notifier.deleteList(list.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AffirmationNotifier>(
      builder: (context, notifier, child) {
        if (notifier.lists.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.self_improvement,
                  size: 72,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No affirmation lists yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + New List to create one',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          itemCount: notifier.lists.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final list = notifier.lists[index];
            return ListTile(
              title: Text(list.name),
              subtitle: Text(
                '${(notifier.items[list.id] ?? []).length} affirmations',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shuffle),
                    tooltip: 'Random affirmation',
                    onPressed: () async {
                      await notifier.loadItemsForList(list.id);
                      final text = await notifier.randomAffirmation(list.id);
                      if (text.isNotEmpty && context.mounted) {
                        await showDialog<void>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(list.name),
                            content: Text(
                              text,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No affirmations in this list yet.'),
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete list',
                    onPressed: () =>
                        _confirmDeleteList(context, notifier, list),
                  ),
                ],
              ),
              onTap: () async {
                await notifier.loadItemsForList(list.id);
                if (context.mounted) {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AffirmationDetailPage(list: list),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
