import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/breathing/form.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/notifiers/breathing.dart';

// page to create the breathing
class CreateBreathing extends StatefulWidget {
  const CreateBreathing({super.key, this.breathing});

  final Breathing? breathing;

  @override
  State<CreateBreathing> createState() => _CreateBreathingState();
}

class _CreateBreathingState extends State<CreateBreathing> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final countInController = TextEditingController();
  final holdInController = TextEditingController();
  final countOutController = TextEditingController();
  final holdOutController = TextEditingController();
  final repsController = TextEditingController();
  List<int> tagIDs = [];

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    countInController.dispose();
    holdInController.dispose();
    countOutController.dispose();
    holdOutController.dispose();
    repsController.dispose();
    super.dispose();
  }

  int _parseOrZero(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final breathingNotifier = context.watch<BreathingNotifier>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Breathing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: BreathingForm(
            nameController: nameController,
            countInController: countInController,
            holdInController: holdInController,
            countOutController: countOutController,
            holdOutController: holdOutController,
            repsController: repsController,
            initialTagIDs: const [],
            onTagIDsChanged: (List<int> ids) => tagIDs = ids,
            formButton: FilledButton(
              onPressed: (() async {
                if (_formKey.currentState!.validate()) {
                  final Breathing newBreathing = Breathing(
                    id: -1,
                    name: nameController.text,
                    countIn: _parseOrZero(countInController),
                    holdIn: _parseOrZero(holdInController),
                    countOut: _parseOrZero(countOutController),
                    holdOut: _parseOrZero(holdOutController),
                    reps: _parseOrZero(repsController),
                  );
                  final created = await breathingNotifier.create(newBreathing);
                  if (tagIDs.isNotEmpty) {
                    await breathingNotifier.setTags(created, tagIDs);
                  }
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to validate!')),
                  );
                }
              }),
              child: const Text('Add Breathing'),
            ),
          ),
        ),
      ),
    );
  }
}
