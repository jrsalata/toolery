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

class TaskForm extends StatefulWidget {
  const TaskForm({
    super.key,
    required this.formButton,
    required this.nameController,
    required this.descriptionController,
    required this.activityController,
    this.task,
  });

  final ButtonStyleButton formButton;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController activityController;
  final Task? task;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late ButtonStyleButton _formButton;
  Task? task;
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController activityController;

  @override
  void initState() {
    super.initState();
    task = widget.task;
    nameController = widget.nameController;
    descriptionController = widget.descriptionController;
    activityController = widget.activityController;
    _formButton = widget.formButton;
    if (task != null) {
      nameController.text = task!.name;
      descriptionController.text = task!.description;
      activityController.text = task!.task;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          autofocus: false,
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
          autofocus: false,
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
        _formButton,
      ],
    );
  }
}

class CreateTask extends StatefulWidget {
  const CreateTask({super.key, this.task});

  final Task? task;

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
        child: TaskForm(
          nameController: nameController,
          descriptionController: descriptionController,
          activityController: activityController,
          formButton: FilledButton(
            onPressed: (() async {
              if (_formKey.currentState!.validate()) {
                final Task newTask = Task(
                  id: -1,
                  name: nameController.text,
                  description: descriptionController.text,
                  task: activityController.text,
                );
                await insertTask(newTask);
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to validate!')),
                );
              }
            }),
            child: const Text('Add Task'),
          ),
        ),
      ),
    );
  }
}

class UpdateTask extends StatefulWidget {
  const UpdateTask({super.key, required this.task});

  final Task task;

  @override
  State<UpdateTask> createState() => _UpdateTaskState();
}

class _UpdateTaskState extends State<UpdateTask> {
  late Task _task;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final activityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    nameController.text = _task.name;
    descriptionController.text = _task.description;
    activityController.text = _task.task;
  }

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
      appBar: AppBar(title: Text('Edit ${_task.name}')),
      body: Form(
        key: _formKey,
        child: TaskForm(
          nameController: nameController,
          descriptionController: descriptionController,
          activityController: activityController,
          task: _task,
          formButton: FilledButton(
            onPressed: (() async {
              if (_formKey.currentState!.validate()) {
                final Task updatedTask = Task(
                  id: _task.id,
                  name: nameController.text,
                  description: descriptionController.text,
                  task: activityController.text,
                );
                await updateTask(updatedTask);
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to validate!')),
                );
              }
            }),
            child: const Text('Save Changes'),
          ),
        ),
      ),
    );
  }
}

class TaskInfo extends StatelessWidget {
  const TaskInfo({super.key, required this.task});

  // single task to view
  final Task task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(task.name)),
      body: Column(
        children: [
          Text("Description", style: Theme.of(context).textTheme.bodyLarge),
          Text(task.description, style: Theme.of(context).textTheme.bodyMedium),
          Text("Activity", style: Theme.of(context).textTheme.bodyLarge),
          Text(task.task, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UpdateTask(task: task)),
          );
        }),
        child: Icon(Icons.edit),
      ),
    );
  }
}

// dedicated Widget to list all of the tasks
class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Task>>(
        future: allTasks(),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskInfo(task: task),
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
