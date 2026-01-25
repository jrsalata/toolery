import 'package:flutter/foundation.dart';
import 'package:toolery/models/task.dart';
import 'package:toolery/repositories/task.dart';

class TaskNotifier extends ChangeNotifier {
  final TaskRepository repository;
  List<Task> tasks = [];
  final Map<int, List<int>> _tagCache = {};

  TaskNotifier({required this.repository}) {
    _init();
  }

  Future<void> _init() async {
    await repository.ready;
    await loadAll();
  }

  Future<void> loadAll() async {
    tasks = await repository.allTasks();
    for (Task task in tasks) {
      _tagCache[task.id] = await repository.tagsForTask(task.id);
    }
    notifyListeners();
  }

  Future<Task> create(Task t) async {
    final Task created = await repository.insertTask(t);
    await loadAll();
    return created;
  }

  Future<void> delete(int id) async {
    await repository.deleteTask(id);
    await loadAll();
  }

  Future<void> update(Task t) async {
    await repository.updateTask(t);
    await loadAll();
  }

  Future<void> addTag(int taskID, int tagID) async {
    await repository.addTag(taskID, tagID);
    await loadAll();
  }

  Future<void> removeTag(int taskID, int tagID) async {
    await repository.removeTag(taskID, tagID);
    await loadAll();
  }

  List<int> getTags(Task task) {
    return _tagCache[task.id] ?? [];
  }

  Future<void> setTags(Task task, List<int> tagIDs) async {
    List<int> currentTags = await getTags(task);
    final Set<int> currentTagSet = currentTags.toSet();
    final Set<int> tagIdSet = tagIDs.toSet();

    // note we are calling the repository version
    // so we avoid constantly calling loadAll()
    for (int tagID in currentTags) {
      if (!tagIdSet.contains(tagID)) {
        await repository.removeTag(task.id, tagID);
      }
    }
    for (int tagID in tagIDs) {
      if (!currentTagSet.contains(tagID)) {
        await repository.addTag(task.id, tagID);
      }
    }
    await loadAll();
  }

  Future<Task> getById(int id) async => repository.getTask(id);
}
