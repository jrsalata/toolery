import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/task/update.dart';
import 'package:toolery/models/task.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/notifiers/task.dart';
import 'package:toolery/notifiers/tag.dart';

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
        final tagNotifier = context.watch<TagNotifier>();
        return FutureBuilder<List<int>>(
          future: taskNotifier.getTags(task!),
          builder: (context, tagSnap) {
            if (tagSnap.connectionState != ConnectionState.done) {
              return Scaffold(
                appBar: AppBar(title: Text(task.name)),
                body: const Center(child: CircularProgressIndicator()),
              );
            }
            if (tagSnap.hasError) {
              return Scaffold(
                appBar: AppBar(title: Text(task.name)),
                body: Text('Error loading tags: ${tagSnap.error}'),
              );
            }

            final List<int> tagIds = tagSnap.data ?? <int>[];
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
                      "Description",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Activity",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      task.task,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text("Tags", style: Theme.of(context).textTheme.bodyLarge),
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
                        if (tags.isEmpty) const Text('No tags'),
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
      },
    );
  }
}
