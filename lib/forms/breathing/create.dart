import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/breathing/form.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/notifiers/breathing.dart';
import 'package:toolery/widgets/editor_app_bar.dart';
import 'package:toolery/widgets/tag_action.dart';
import 'package:toolery/widgets/unsaved_changes.dart';

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
  List<int> _tagIDs = [];

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

  bool _isDirty() {
    return nameController.text.isNotEmpty ||
        countInController.text.isNotEmpty ||
        holdInController.text.isNotEmpty ||
        countOutController.text.isNotEmpty ||
        holdOutController.text.isNotEmpty ||
        repsController.text.isNotEmpty ||
        _tagIDs.isNotEmpty;
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final breathingNotifier = context.read<BreathingNotifier>();
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
      if (_tagIDs.isNotEmpty) {
        await breathingNotifier.setTags(created, _tagIDs);
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to validate!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesGuard(
      isDirty: _isDirty,
      child: Scaffold(
        appBar: EditorAppBar(
          title: 'Create New Breathing Exercise',
          tagAction: TagAction(
            tagIDs: _tagIDs,
            onChanged: (v) => setState(() => _tagIDs = v),
          ),
          onSave: _save,
        ),
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
            ),
          ),
        ),
      ),
    );
  }
}
