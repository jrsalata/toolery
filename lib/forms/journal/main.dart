import 'package:flutter/material.dart';
import 'package:toolery/forms/journal/create.dart';
import 'package:toolery/forms/journal/list.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: const JournalList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute<bool>(
              builder: (context) => const CreateJournal(),
            ),
          );
        },
        label: const Text('Entry'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
