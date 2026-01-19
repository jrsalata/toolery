import 'package:flutter/foundation.dart';
import 'package:toolery/models/task.dart';
import 'package:toolery/repositories/task.dart';

class TaskNotifier extends ChangeNotifier {
  final TaskRepository repository;
  List<Task> tasks = [];

  TaskNotifier({required this.repository});

  Future<void> loadAll() async {
    tasks = await repository.allTasks();
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

  Future<Task> getById(int id) async => repository.getTask(id);
}
