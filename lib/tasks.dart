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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (() {
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (context) => const CreateTask()),
          );
        }),
        label: Text("Task"),
        icon: Icon(Icons.add),
      ),
    );
  }
}

class CreateTask extends StatefulWidget {
  const CreateTask({super.key});

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final activityController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    descriptionController.dispose();
    activityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Task')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              autofocus: true,
              controller: nameController,
              decoration: InputDecoration(
                label: Text("Task Name"),
                hintText: "Enter the name of a task",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please give a name';
                }
                return null;
              },
            ),
            TextFormField(
              autofocus: true,
              controller: descriptionController,
              decoration: InputDecoration(
                label: Text("Description"),
                hintText: "Provide a brief description of the task",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please put a description';
                }
                return null;
              },
            ),
            TextFormField(
              autofocus: true,
              controller: activityController,
              decoration: InputDecoration(
                label: Text("Activity"),
                hintText: "Provide step-by-step instructions",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some instructions';
                }
                return null;
              },
            ),
            FilledButton(
              onPressed: (() {
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  Task newTask = Task(
                    id: -1,
                    name: nameController.text,
                    description: descriptionController.text,
                    task: activityController.text,
                  );
                  insertTask(newTask);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to validate!')),
                  );
                }
              }),
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
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
