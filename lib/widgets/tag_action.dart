import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/accessibility/contrast.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/notifiers/tag.dart';

/// A read-only chip for displaying a tag, used on detail/view screens.
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(tag.name),
      labelStyle: TextStyle(color: highContrastTextColor(tag.color)),
      backgroundColor: tag.color,
    );
  }
}

/// AppBar action for picking tags: a badge icon showing the current
/// selection count that opens a modal bottom sheet of [FilterChip]s.
///
/// The parent owns [tagIDs]; this widget is stateless and always reflects
/// the parent's state, so the badge and the sheet can't drift out of sync.
class TagAction extends StatelessWidget {
  const TagAction({super.key, required this.tagIDs, required this.onChanged});

  final List<int> tagIDs;
  final ValueChanged<List<int>> onChanged;

  Future<void> _showTagSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Consumer<TagNotifier>(
                      builder: (context, tagNotifier, _) {
                        return Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (Tag tag in tagNotifier.tags)
                              FilterChip(
                                selected: tagIDs.contains(tag.id),
                                backgroundColor: tag.color,
                                selectedColor: tag.color,
                                label: Text(tag.name),
                                labelStyle: TextStyle(
                                  color: highContrastTextColor(tag.color),
                                ),
                                showCheckmark: true,
                                checkmarkColor: highContrastTextColor(
                                  tag.color,
                                ),
                                onSelected: (bool selected) {
                                  final updated = List<int>.from(tagIDs);
                                  if (selected) {
                                    if (!updated.contains(tag.id)) {
                                      updated.add(tag.id);
                                    }
                                  } else {
                                    updated.remove(tag.id);
                                  }
                                  setSheetState(() {});
                                  onChanged(updated);
                                },
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Badge(
        isLabelVisible: tagIDs.isNotEmpty,
        label: Text('${tagIDs.length}'),
        child: const Icon(Icons.label_outline),
      ),
      tooltip: 'Tags',
      onPressed: () => _showTagSheet(context),
    );
  }
}
