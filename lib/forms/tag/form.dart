import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
    return Column(
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
          trailing: ValueListenableBuilder<Color>(
            valueListenable: colorController,
            builder: (context, value, _) =>
                CircleAvatar(backgroundColor: value),
          ),
          onTap: () async => showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext builder) => AlertDialog(
              title: const Text("Select Color"),
              content: BlockPicker(
                pickerColor: colorController.value,
                onColorChanged: (changeColor) =>
                    colorController.value = changeColor,
              ),
              actions: [
                TextButton(
                  child: const Text("Done!"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
        _formButton,
      ],
    );
  }
}
