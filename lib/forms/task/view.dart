import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/task/update.dart';
import 'package:toolery/models/task.dart';
import 'package:toolery/notifiers/task.dart';

// single-page to show all of the info on one task
class TaskInfo extends StatelessWidget {
  const TaskInfo({super.key, required this.taskID});

  // single task to view
  final int taskID;

  @override
  Widget build(BuildContext context) {
    final taskNotifier = context.watch<TaskNotifier>();
    return FutureBuilder<Task>(
      future: taskNotifier.getById(taskID),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final Task? task = snapshot.data;
        return Scaffold(
          appBar: AppBar(title: Text(task!.name)),
          body: Column(
            children: [
              Text("Description", style: Theme.of(context).textTheme.bodyLarge),
              Text(
                task.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text("Activity", style: Theme.of(context).textTheme.bodyLarge),
              Text(task.task, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push<bool>(
                context,
                MaterialPageRoute<bool>(
                  builder: (context) => UpdateTask(task: task),
                ),
              );
            },
            child: const Icon(Icons.edit),
          ),
        );
      },
    );
  }
}
