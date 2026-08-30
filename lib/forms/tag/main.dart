import 'package:flutter/material.dart';
import 'package:toolery/forms/tag/create.dart';
import 'package:toolery/forms/tag/list.dart';
import 'package:toolery/widgets/adaptive/adaptive_scaffold.dart';

class TagPage extends StatelessWidget {
  const TagPage({super.key});
  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      title: 'Configure Tags',
      body: const TagList(),
      primaryAction: AdaptivePrimaryAction(
        label: 'Tags',
        tooltip: 'Create tag',
        onPressed: () async {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute<bool>(builder: (context) => const CreateTag()),
          );
        },
      ),
    );
  }
}
