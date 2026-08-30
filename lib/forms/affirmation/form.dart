import 'package:flutter/material.dart';
import 'package:toolery/models/affirmation_list.dart';

class AffirmationListForm extends StatefulWidget {
  const AffirmationListForm({
    super.key,
    required this.formButton,
    required this.nameController,
    this.list,
  });

  final ButtonStyleButton formButton;
  final TextEditingController nameController;
  final AffirmationList? list;

  @override
  State<AffirmationListForm> createState() => _AffirmationListFormState();
}

class _AffirmationListFormState extends State<AffirmationListForm> {
  AffirmationList? list;
  late TextEditingController nameController;
  late ButtonStyleButton formButton;

  @override
  void initState() {
    super.initState();
    list = widget.list;
    nameController = widget.nameController;
    formButton = widget.formButton;
    if (list != null) {
      nameController.text = list!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextFormField(
            autofocus: true,
            controller: nameController,
            decoration: const InputDecoration(labelText: 'List Name'),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please give a name';
              return null;
            },
          ),
          formButton,
        ],
      ),
    );
  }
}
