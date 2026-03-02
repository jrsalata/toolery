import 'package:flutter/material.dart';
import 'package:toolery/forms/affirmation/create.dart';
import 'package:toolery/forms/affirmation/list.dart';

class AffirmationPage extends StatelessWidget {
  const AffirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Affirmations')),
      body: const AffirmationListView(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateAffirmationList()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New List'),
      ),
    );
  }
}
