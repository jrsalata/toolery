import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/task/view.dart';
import 'package:toolery/models/task.dart';
import 'package:toolery/notifiers/task.dart';

// dedicated Widget to list all of the tasks
class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Consumer<TaskNotifier>(
        builder: (context, tasks, child) {
          return tasks.tasks.isNotEmpty
              ? ListView(
                  children: [
                    for (Task task in tasks.tasks)
                      ListTile(
                        title: Text(task.name),
                        subtitle: Text(task.description),
                        onTap: () async {
                          await Navigator.push<bool>(
                            context,
                            MaterialPageRoute<bool>(
                              builder: (context) => TaskInfo(taskID: task.id),
                            ),
                          );
                        },
                      ),
                  ],
                )
              : Text("No tasks yet :(");
        },
      ),
    );
  }
}
