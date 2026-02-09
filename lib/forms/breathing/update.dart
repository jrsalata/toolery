import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/breathing/form.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/notifiers/breathing.dart';

// page to update the breathing
class UpdateBreathing extends StatefulWidget {
  const UpdateBreathing({super.key, required this.breathing});

  final Breathing breathing;

  @override
  State<UpdateBreathing> createState() => _UpdateBreathingState();
}

class _UpdateBreathingState extends State<UpdateBreathing> {
  List<int> tagIDs = [];
  late Breathing _breathing;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final countInController = TextEditingController();
  final holdInController = TextEditingController();
  final countOutController = TextEditingController();
  final holdOutController = TextEditingController();
  final repsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _breathing = widget.breathing;
    nameController.text = _breathing.name;
    countInController.text = _breathing.countIn.toString();
    holdInController.text = _breathing.holdIn.toString();
    countOutController.text = _breathing.countOut.toString();
    holdOutController.text = _breathing.holdOut.toString();
    repsController.text = _breathing.reps.toString();
  }

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
    tagIDs = breathingNotifier.getTags(_breathing);
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${_breathing.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: BreathingForm(
                nameController: nameController,
                countInController: countInController,
                holdInController: holdInController,
                countOutController: countOutController,
                holdOutController: holdOutController,
                repsController: repsController,
                breathing: _breathing,
                initialTagIDs: tagIDs,
                onTagIDsChanged: ((List<int> tagIDList) => tagIDs = tagIDList),
                formButton: FilledButton(
                  onPressed: (() async {
                    if (_formKey.currentState!.validate()) {
                      final Breathing updatedBreathing = Breathing(
                        id: _breathing.id,
                        name: nameController.text,
                        countIn: _parseOrZero(countInController),
                        holdIn: _parseOrZero(holdInController),
                        countOut: _parseOrZero(countOutController),
                        holdOut: _parseOrZero(holdOutController),
                        reps: _parseOrZero(repsController),
                      );
                      await breathingNotifier.update(updatedBreathing);
                      await breathingNotifier.setTags(_breathing, tagIDs);
                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to validate!')),
                      );
                    }
                  }),
                  child: const Text('Save Changes'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  Theme.of(context).colorScheme.errorContainer,
                ),
                foregroundColor: MaterialStatePropertyAll(
                  Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              onPressed: () async {
                final bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete breathing?'),
                    content: const Text(
                      'This action cannot be undone. Are you sure you want to delete this breathing?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ButtonStyle(
                          foregroundColor: MaterialStatePropertyAll(
                            Theme.of(context).colorScheme.error,
                          ),
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await breathingNotifier.delete(_breathing.id);
                  if (context.mounted) {
                    // we need to pop out of the edit page
                    // and the breathing info page
                    Navigator.pop(context, true);
                    Navigator.pop(context, true);
                  }
                }
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
