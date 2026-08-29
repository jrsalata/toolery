import 'package:flutter/material.dart';
import 'package:toolery/forms/tag/create.dart';
import 'package:toolery/forms/tag/list.dart';

class TagPage extends StatelessWidget {
  const TagPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configure Tags')),
      body: const TagList(),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Create tag',
        onPressed: () async {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute<bool>(builder: (context) => const CreateTag()),
          );
        },
        label: const Text('Tags'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
