import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/notifiers/tag.dart';

class BreathingForm extends StatefulWidget {
  const BreathingForm({
    super.key,
    required this.formButton,
    required this.nameController,
    required this.countInController,
    required this.holdInController,
    required this.countOutController,
    required this.holdOutController,
    required this.repsController,
    this.breathing,
    this.initialTagIDs,
    this.onTagIDsChanged,
  });

  final ButtonStyleButton formButton;
  final TextEditingController nameController;
  final TextEditingController countInController;
  final TextEditingController holdInController;
  final TextEditingController countOutController;
  final TextEditingController holdOutController;
  final TextEditingController repsController;
  final Breathing? breathing;
  final List<int>? initialTagIDs;
  final ValueChanged<List<int>>? onTagIDsChanged;

  @override
  State<BreathingForm> createState() => _BreathingFormState();
}

class _BreathingFormState extends State<BreathingForm> {
  Breathing? breathing;
  List<int> tagIDs = [];
  late ButtonStyleButton _formButton;
  late TextEditingController nameController;
  late TextEditingController countInController;
  late TextEditingController holdInController;
  late TextEditingController countOutController;
  late TextEditingController holdOutController;
  late TextEditingController repsController;

  @override
  void initState() {
    super.initState();
    breathing = widget.breathing;
    nameController = widget.nameController;
    countInController = widget.countInController;
    holdInController = widget.holdInController;
    countOutController = widget.countOutController;
    holdOutController = widget.holdOutController;
    repsController = widget.repsController;
    _formButton = widget.formButton;
    // initialize selected tag IDs from provided initialTagIDs
    if (widget.initialTagIDs != null) {
      tagIDs = List<int>.from(widget.initialTagIDs!);
    }

    if (breathing != null) {
      nameController.text = breathing!.name;
      countInController.text = breathing!.countIn.toString();
      holdInController.text = breathing!.holdIn.toString();
      countOutController.text = breathing!.countOut.toString();
      holdOutController.text = breathing!.holdOut.toString();
      repsController.text = breathing!.reps.toString();
    }
  }

  String? _validateInt(String? value, String fieldName) {
    if (value == null || value.isEmpty) return 'Please enter $fieldName';
    if (int.tryParse(value) == null) return '$fieldName must be an integer';
    if (int.tryParse(value)! < 0) return '$fieldName must be non-negative';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          autofocus: true,
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Breathing Exercise Name',
            hintText: 'Enter the name of your exercise',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please give a name';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: countInController,
          decoration: const InputDecoration(
            labelText: 'Count In',
            hintText: 'Seconds for inhale',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (v) => _validateInt(v, 'Count In'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: holdInController,
          decoration: const InputDecoration(
            labelText: 'Hold In',
            hintText: 'Seconds to hold after an inhale',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (v) => _validateInt(v, 'Hold In'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: countOutController,
          decoration: const InputDecoration(
            labelText: 'Count Out',
            hintText: 'Seconds for exhale',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (v) => _validateInt(v, 'Count Out'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: holdOutController,
          decoration: const InputDecoration(
            labelText: 'Hold Out',
            hintText: 'Seconds to hold after an exhale',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (v) => _validateInt(v, 'Hold Out'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: repsController,
          decoration: const InputDecoration(
            labelText: 'Repetitions',
            hintText: 'Number of reps',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (v) => _validateInt(v, 'Repetitions'),
        ),
        const SizedBox(height: 8),
        Wrap(
          children: [
            for (Tag tag in context.watch<TagNotifier>().tags)
              FilterChip(
                selected: tagIDs.contains(tag.id),
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
                      if (!tagIDs.contains(tag.id)) tagIDs.add(tag.id);
                    } else {
                      tagIDs.remove(tag.id);
                    }
                  });
                  widget.onTagIDsChanged?.call(List<int>.from(tagIDs));
                },
              ),
          ],
        ),
        _formButton,
      ],
    );
  }
}
