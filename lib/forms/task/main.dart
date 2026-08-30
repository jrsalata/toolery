import 'package:flutter/material.dart';
import 'package:toolery/forms/task/create.dart';
import 'package:toolery/forms/task/list.dart';
import 'package:toolery/widgets/adaptive/adaptive_scaffold.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});
  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      title: 'Tasks',
      body: const TaskList(),
      primaryAction: AdaptivePrimaryAction(
        label: 'Task',
        tooltip: 'Create task',
        onPressed: () async {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute<bool>(builder: (context) => const CreateTask()),
          );
        },
      ),
    );
  }
}
