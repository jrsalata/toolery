import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/models/task.dart';

// main task page that calls task list
class TaskPage extends StatelessWidget {
  const TaskPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: TaskList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push<bool>(
            context,
            MaterialPageRoute<bool>(builder: (context) => const CreateTask()),
          );
        },
        label: const Text("Task"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

// reusable form to edit the task
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
            labelText: "Task Name",
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
            labelText: "Description",
            hintText: "Provide a brief description of the task",
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          minLines: 1,
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
            labelText: "Activity",
            hintText: "Provide step-by-step instructions",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.multiline,
          maxLines: null,
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

// page to create the task
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
    final taskNotifier = context.watch<TaskChangeNotifier>();
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
                await taskNotifier.insertTask(newTask);
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

// page to update the task
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
    final taskNotifier = context.watch<TaskChangeNotifier>();
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${_task.name}')),
      body: Column(
        children: [
          Form(
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
                    await taskNotifier.updateTask(updatedTask);
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
          FilledButton.tonal(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.errorContainer,
              ),
              foregroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            onPressed: () async {
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete task?'),
                  content: const Text(
                    'This action cannot be undone. Are you sure you want to delete this task?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.error,
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await taskNotifier.deleteTask(_task.id);
                if (context.mounted) {

                  // we need to pop out of the edit page
                  // and the task info page
                  Navigator.pop(context, true);
                  Navigator.pop(context, true);
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// single-page to show all of the info on one task
class TaskInfo extends StatelessWidget {
  const TaskInfo({super.key, required this.taskID});

  // single task to view
  final int taskID;

  @override
  Widget build(BuildContext context) {
    final taskNotifier = context.watch<TaskChangeNotifier>();
    return FutureBuilder<Task>(
      future: taskNotifier.getTask(taskID),
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

// dedicated Widget to list all of the tasks
class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Consumer<TaskChangeNotifier>(
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
