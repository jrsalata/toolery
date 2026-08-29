import 'package:flutter/material.dart';
import 'package:toolery/forms/task/create.dart';
import 'package:toolery/forms/task/list.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: const TaskList(),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Create task',
        onPressed: () async {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute<bool>(builder: (context) => const CreateTask()),
          );
        },
        label: const Text('Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
