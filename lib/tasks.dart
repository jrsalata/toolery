import 'dart:async';

import 'package:flutter/material.dart';
import 'package:toolery/models/task.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Tasks')),
        body: TaskList(),
        floatingActionButton: FloatingActionButton.extended(onPressed: ((){}), label: Text("Task"), icon: Icon(Icons.add)),
    );
  }
}

class CreateTask extends StatelessWidget {
  const CreateTask({super.key});

  @override
  Widget build(BuildContext context){
    return Text("HERE");
  }
}

// dedicated Widget to list all of the tasks
class TaskList extends StatelessWidget {
  TaskList({super.key});
  final Future<List<Task>> tasks = allTasks();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Task>>(
        future: tasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          final tasks = snapshot.data ?? [];
          return tasks.isNotEmpty
              ? ListView(
                  children: [
                    for (Task task in tasks)
                      ListTile(
                        title: Text(task.name),
                        subtitle: Text(task.description),
                      ),
                  ],
                )
              : Text("No tasks yet :(");
        },
      ),
    );
  }
}
