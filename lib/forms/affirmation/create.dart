import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/affirmation/form.dart';
import 'package:toolery/models/affirmation_list.dart';
import 'package:toolery/notifiers/affirmation.dart';

class CreateAffirmationList extends StatefulWidget {
  const CreateAffirmationList({super.key});

  @override
  State<CreateAffirmationList> createState() => _CreateAffirmationListState();
}

class _CreateAffirmationListState extends State<CreateAffirmationList> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AffirmationNotifier>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create Affirmation List')),
      body: Form(
        key: _formKey,
        child: AffirmationListForm(
          nameController: nameController,
          formButton: FilledButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final list = AffirmationList(id: -1, name: nameController.text);
                await notifier.createList(list);
                if (context.mounted) Navigator.pop(context, true);
              }
            },
            child: const Text('Add List'),
          ),
        ),
      ),
    );
  }
}
