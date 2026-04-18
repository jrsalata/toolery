import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/accessibility/contrast.dart';
import 'package:toolery/forms/task/view.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/models/task.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/notifiers/task.dart';

// dedicated Widget to list all of the tasks
class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<int> filterTags = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<TagNotifier>(
      builder: (context, tags, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tags.tags.isNotEmpty) Divider(),
            Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                const SizedBox(width: 6, height: 6),
                for (Tag tag in tags.tags)
                  FilterChip(
                    selected: filterTags.contains(tag.id),
                    backgroundColor: tag.color,
                    selectedColor: tag.color,
                    label: Text(tag.name),
                    labelStyle: TextStyle(
                      color: highContrastTextColor(tag.color),
                    ),
                    showCheckmark: true,
                    checkmarkColor: highContrastTextColor(tag.color),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          if (!filterTags.contains(tag.id)) {
                            filterTags.add(tag.id);
                          }
                        } else {
                          filterTags.remove(tag.id);
                        }
                      });
                    },
                  ),
              ],
            ),
            if (tags.tags.isNotEmpty) Divider(),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        );
      },
      child: Consumer<TaskNotifier>(
        builder: (context, tasks, child) {
          if (tasks.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 72,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first task',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          final List<Task> filteredTasks = tasks.tasks.where((task) {
            return filterTags.isEmpty ||
                filterTags.any((tagID) => tasks.getTags(task).contains(tagID));
          }).toList();

          if (filteredTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list_off,
                    size: 72,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks match the selected filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: filteredTasks.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return ListTile(
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
              );
            },
          );
        },
      ),
    );
  }
}
