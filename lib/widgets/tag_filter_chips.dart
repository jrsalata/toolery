import 'package:flutter/material.dart';
import 'package:toolery/accessibility/contrast.dart';
import 'package:toolery/models/tag.dart';

/// A [Wrap] of [FilterChip]s for toggling tag selection, shared by the
/// task/journal/breathing list filters and the [TagAction] bottom sheet.
class TagFilterChips extends StatelessWidget {
  const TagFilterChips({
    super.key,
    required this.tags,
    required this.selectedTagIds,
    required this.onChanged,
  });

  final List<Tag> tags;
  final List<int> selectedTagIds;
  final ValueChanged<List<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        const SizedBox(width: 6, height: 6),
        for (final tag in tags)
          FilterChip(
            selected: selectedTagIds.contains(tag.id),
            backgroundColor: tag.color,
            selectedColor: tag.color,
            label: Text(tag.name),
            labelStyle: TextStyle(color: highContrastTextColor(tag.color)),
            showCheckmark: true,
            checkmarkColor: highContrastTextColor(tag.color),
            onSelected: (bool selected) {
              final updated = List<int>.from(selectedTagIds);
              if (selected) {
                if (!updated.contains(tag.id)) {
                  updated.add(tag.id);
                }
              } else {
                updated.remove(tag.id);
              }
              onChanged(updated);
            },
          ),
      ],
    );
  }
}
