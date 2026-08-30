import 'package:flutter/material.dart';
import 'package:toolery/forms/journal/create.dart';
import 'package:toolery/forms/journal/list.dart';
import 'package:toolery/widgets/adaptive/adaptive_scaffold.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      title: 'Journal',
      body: const JournalList(),
      primaryAction: AdaptivePrimaryAction(
        label: 'Entry',
        tooltip: 'Create journal entry',
        onPressed: () async {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute<bool>(
              builder: (context) => const CreateJournal(),
            ),
          );
        },
      ),
    );
  }
}
