import 'package:flutter/foundation.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/models/task.dart';
import 'package:toolery/repositories/task.dart';

class TaskNotifier extends ChangeNotifier {
  final TaskRepository repository;
  List<Task> tasks = [];
  final Map<int, List<Tag>> _tagCache = {};

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

  Future<void> create(Task t) async {
    await repository.insertTask(t);
    await loadAll();
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

  Future<Task> getById(int id) async => repository.getTask(id);
}
