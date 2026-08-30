import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/accessibility/contrast.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/widgets/tag_filter_chips.dart';

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
/// The parent owns [tagIDs]; this widget mirrors it into local state so the
/// open sheet keeps working off a live value even while the parent rebuilds
/// around it, and re-mirrors via [didUpdateWidget] if the parent changes
/// [tagIDs] out from under it.
class TagAction extends StatefulWidget {
  const TagAction({super.key, required this.tagIDs, required this.onChanged});

  final List<int> tagIDs;
  final ValueChanged<List<int>> onChanged;

  @override
  State<TagAction> createState() => _TagActionState();
}

class _TagActionState extends State<TagAction> {
  late List<int> _tagIDs = List.of(widget.tagIDs);

  @override
  void didUpdateWidget(TagAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tagIDs != oldWidget.tagIDs) {
      _tagIDs = List.of(widget.tagIDs);
    }
  }

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
                        return TagFilterChips(
                          tags: tagNotifier.tags,
                          selectedTagIds: _tagIDs,
                          onChanged: (updated) {
                            setSheetState(() => _tagIDs = updated);
                            widget.onChanged(updated);
                          },
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
        isLabelVisible: _tagIDs.isNotEmpty,
        label: Text('${_tagIDs.length}'),
        child: const Icon(Icons.label_outline),
      ),
      tooltip: 'Tags',
      onPressed: () => _showTagSheet(context),
    );
  }
}
