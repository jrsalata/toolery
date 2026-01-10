import 'dart:async';

import 'package:flutter/material.dart';
import 'package:toolery/models/task.dart';

class TaskPage extends StatelessWidget {
  TaskPage({super.key});
  
  final Future<List<Task>> tasks = allTasks();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Tasks')),
        body: Center(
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
              return tasks.length > 0 ? ListView(
                children: [
                  for (Task task in tasks)
                    ListTile(
                      title: Text(task.name),
                      subtitle: Text(task.description),
                    )
                ],
              ) : Text("No tasks yet :(");
            },
          ),
        ),
      ),
    );
  }
}
