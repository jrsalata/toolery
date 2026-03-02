import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/tag/update.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/notifiers/tag.dart';

// dedicated Widget to list all of the tags
class TagList extends StatelessWidget {
  const TagList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TagNotifier>(
      builder: (context, tags, child) {
        if (tags.tags.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.label_off_outlined,
                  size: 72,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No tags yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to create your first tag',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }
        return Align(
          alignment: Alignment.topLeft,
          child: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1.0, // square tiles
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            padding: const EdgeInsets.all(8),
            shrinkWrap: true,
            children: [
              for (Tag tag in tags.tags)
                Material(
                  borderRadius: BorderRadius.circular(12),
                  color: tag.color,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push<bool>(
                        context,
                        MaterialPageRoute<bool>(
                          builder: (context) => UpdateTag(tag: tag),
                        ),
                      );
                    },
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tag.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
