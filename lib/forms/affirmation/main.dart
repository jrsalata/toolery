import 'package:flutter/material.dart';
import 'package:toolery/forms/affirmation/create.dart';
import 'package:toolery/forms/affirmation/list.dart';
import 'package:toolery/widgets/adaptive/adaptive_scaffold.dart';

class AffirmationPage extends StatelessWidget {
  const AffirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      title: 'Affirmations',
      body: const AffirmationListView(),
      primaryAction: AdaptivePrimaryAction(
        label: 'New List',
        tooltip: 'Create affirmation list',
        onPressed: () async {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateAffirmationList()),
          );
        },
      ),
    );
  }
}
