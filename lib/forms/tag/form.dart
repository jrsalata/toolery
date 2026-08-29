import 'package:flutter/material.dart';
import 'package:toolery/accessibility/color_picker_dialog.dart';
import 'package:toolery/models/tag.dart';

// reusable form to edit the tag
class TagForm extends StatefulWidget {
  const TagForm({
    super.key,
    required this.formButton,
    required this.nameController,
    required this.colorController,
    this.tag,
  });

  final ButtonStyleButton formButton;
  final TextEditingController nameController;
  final ValueNotifier<Color> colorController;
  final Tag? tag;

  @override
  State<TagForm> createState() => _TagFormState();
}

class _TagFormState extends State<TagForm> {
  late ButtonStyleButton _formButton;
  Tag? tag;
  late TextEditingController nameController;
  late ValueNotifier<Color> colorController;

  @override
  void initState() {
    super.initState();
    tag = widget.tag;
    nameController = widget.nameController;
    colorController = widget.colorController;
    _formButton = widget.formButton;
    if (tag != null) {
      nameController.text = tag!.name;
      colorController.value = tag!.color;
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
            decoration: InputDecoration(
              labelText: "Tag Name",
              hintText: "Give your tag a name",
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please give a name';
              }
              return null;
            },
          ),
          ListTile(
            title: Text("Set Tag Color"),
            leading: ValueListenableBuilder<Color>(
              valueListenable: colorController,
              builder: (context, value, _) => SizedBox(
                width: 24,
                height: double.infinity,
                child: DecoratedBox(decoration: BoxDecoration(color: value)),
              ),
            ),
            onTap: () async => showAccessibleColorPickerDialog(
              context: context,
              pickerColor: colorController.value,
              onColorChanged: (changeColor) =>
                  colorController.value = changeColor,
            ),
          ),
          _formButton,
        ],
      ),
    );
  }
}
