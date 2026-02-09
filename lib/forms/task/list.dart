import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
              children: [
                Padding(padding: EdgeInsets.all(6)),
                for (Tag tag in tags.tags)
                  FilterChip(
                    selected: filterTags.contains(tag.id),
                    backgroundColor: tag.color,
                    selectedColor: tag.color,
                    label: Text(tag.name),
                    labelStyle: TextStyle(
                      color: tag.color.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    ),
                    showCheckmark: true,
                    checkmarkColor: tag.color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
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
            return Text("No tasks yet :(");
          }

          final List<Task> filteredTasks = tasks.tasks.where((task) {
            return filterTags.isEmpty ||
                filterTags.every(
                  (tagID) => tasks.getTags(task).contains(tagID),
                );
          }).toList();

          if (filteredTasks.isEmpty) {
            return Text("No tasks match the selected filters");
          }

          return ListView(
            children: [
              for (Task task in filteredTasks)
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
          );
        },
      ),
    );
  }
}
