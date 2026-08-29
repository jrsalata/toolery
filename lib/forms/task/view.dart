import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/task/update.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/models/task.dart';
import 'package:toolery/notifiers/tag.dart';
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task')),
            body: Center(child: Text('Error loading task: ${snapshot.error}')),
          );
        }
        final Task? task = snapshot.data;
        final tagNotifier = context.watch<TagNotifier>();
        if (task == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task')),
            body: const Center(child: Text('Task not found')),
          );
        }

        final List<int> tagIds = taskNotifier.getTags(task);
        final tags = tagNotifier.tags
            .where((t) => tagIds.contains(t.id))
            .toList();

        return Scaffold(
          appBar: AppBar(title: Text(task.name)),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text('Activity', style: Theme.of(context).textTheme.bodyLarge),
                Text(task.task, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                Text('Tags', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (Tag tag in tags)
                      Chip(
                        label: Text(tag.name),
                        labelStyle: TextStyle(
                          color: tag.color.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                        ),
                        backgroundColor: tag.color,
                      ),
                    if (tags.isEmpty)
                      Text(
                        'No tags',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
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
