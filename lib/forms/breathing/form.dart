import 'package:flutter/material.dart';
import 'package:toolery/models/breathing.dart';

class BreathingForm extends StatefulWidget {
  const BreathingForm({
    super.key,
    required this.nameController,
    required this.countInController,
    required this.holdInController,
    required this.countOutController,
    required this.holdOutController,
    required this.repsController,
    this.breathing,
  });

  final TextEditingController nameController;
  final TextEditingController countInController;
  final TextEditingController holdInController;
  final TextEditingController countOutController;
  final TextEditingController holdOutController;
  final TextEditingController repsController;
  final Breathing? breathing;

  @override
  State<BreathingForm> createState() => _BreathingFormState();
}

class _BreathingFormState extends State<BreathingForm> {
  Breathing? breathing;
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
          ),
          keyboardType: TextInputType.number,
          validator: (v) => _validateInt(v, 'Repetitions'),
        ),
      ],
    );
  }
}
