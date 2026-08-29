import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/breathing/form.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/notifiers/breathing.dart';
import 'package:toolery/widgets/confirm_dialog.dart';
import 'package:toolery/widgets/editor_app_bar.dart';
import 'package:toolery/widgets/tag_action.dart';
import 'package:toolery/widgets/unsaved_changes.dart';

// page to update the breathing
class UpdateBreathing extends StatefulWidget {
  const UpdateBreathing({super.key, required this.breathing});

  final Breathing breathing;

  @override
  State<UpdateBreathing> createState() => _UpdateBreathingState();
}

class _UpdateBreathingState extends State<UpdateBreathing> {
  late Breathing _breathing;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final countInController = TextEditingController();
  final holdInController = TextEditingController();
  final countOutController = TextEditingController();
  final holdOutController = TextEditingController();
  final repsController = TextEditingController();
  late List<int> _tagIDs;
  late List<int> _initialTagIDs;

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
    _initialTagIDs = context.read<BreathingNotifier>().getTags(_breathing);
    _tagIDs = List<int>.from(_initialTagIDs);
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

  bool _isDirty() {
    return nameController.text != _breathing.name ||
        countInController.text != _breathing.countIn.toString() ||
        holdInController.text != _breathing.holdIn.toString() ||
        countOutController.text != _breathing.countOut.toString() ||
        holdOutController.text != _breathing.holdOut.toString() ||
        repsController.text != _breathing.reps.toString() ||
        !listEquals(_tagIDs, _initialTagIDs);
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final breathingNotifier = context.read<BreathingNotifier>();
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
      await breathingNotifier.setTags(_breathing, _tagIDs);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to validate!')));
    }
  }

  Future<void> _delete() async {
    final breathingNotifier = context.read<BreathingNotifier>();
    final confirmed = await confirmDestructive(
      context,
      title: 'Delete breathing?',
      message:
          'This action cannot be undone. Are you sure you want to delete '
          'this breathing?',
    );
    if (confirmed) {
      await breathingNotifier.delete(_breathing.id);
      if (mounted) {
        // we need to pop out of the edit page
        // and the breathing info page
        Navigator.pop(context, true);
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesGuard(
      isDirty: _isDirty,
      child: Scaffold(
        appBar: EditorAppBar(
          title: 'Edit ${_breathing.name}',
          tagAction: TagAction(
            tagIDs: _tagIDs,
            onChanged: (v) => setState(() => _tagIDs = v),
          ),
          onSave: _save,
          onDelete: _delete,
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
              breathing: _breathing,
            ),
          ),
        ),
      ),
    );
  }
}
