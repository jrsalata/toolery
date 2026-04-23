import 'package:flutter/material.dart';
import 'package:toolery/accessibility/contrast.dart';

const List<Color> accessibleColorPalette = <Color>[
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.grey,
];

String colorHexLabel(Color color) {
  final rgb = color.toARGB32() & 0x00FFFFFF; // Strip alpha; keep RGB only.
  return '#${rgb.toRadixString(16).toUpperCase().padLeft(6, '0')}';
}

Future<void> showAccessibleColorPickerDialog({
  required BuildContext context,
  required Color pickerColor,
  required ValueChanged<Color> onColorChanged,
  String title = 'Select Color',
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final color in accessibleColorPalette)
              _ColorSwatchButton(
                color: color,
                selected: color.toARGB32() == pickerColor.toARGB32(),
                onTap: () => onColorChanged(color),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Done'),
          onPressed: () => Navigator.of(dialogContext).pop(),
        ),
      ],
    ),
  );
}

class _ColorSwatchButton extends StatelessWidget {
  const _ColorSwatchButton({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = 'Select color ${colorHexLabel(color)}';
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: selected
                ? Icon(Icons.check, color: highContrastTextColor(color))
                : null,
          ),
        ),
      ),
    );
  }
}
