import 'package:flutter/foundation.dart';
import 'package:toolery/models/task.dart';
import 'package:toolery/repositories/task.dart';

/// State management for the user's [Task] collection.
///
/// [TaskNotifier] extends [ChangeNotifier] and is exposed to the widget tree
/// via `provider`. Widgets consume [tasks] to render lists and subscribe to
/// updates via [addListener] / `context.watch`.
///
/// All mutating methods persist the change through the injected
/// [TaskRepository] and then call [loadAll] to refresh [tasks] and notify
/// listeners.
///
/// Tag associations are lazily cached in [_tagCache] to avoid redundant
/// database round-trips on every rebuild.
class TaskNotifier extends ChangeNotifier {
  /// The repository used for all task persistence operations.
  final TaskRepository repository;

  /// The current list of tasks, refreshed after every mutation.
  List<Task> tasks = [];

  // Internal cache mapping task id → list of associated tag ids.
  final Map<int, List<int>> _tagCache = {};

  /// Creates a [TaskNotifier] and immediately begins loading data from
  /// [repository] once it signals readiness.
  TaskNotifier({required this.repository}) {
    _init();
  }

  Future<void> _init() async {
    await repository.ready;
    await loadAll();
  }

  /// Fetches all tasks from the repository and refreshes [tasks].
  ///
  /// Also repopulates the internal tag cache. Listeners are notified once
  /// loading completes.
  Future<void> loadAll() async {
    tasks = await repository.allTasks();
    for (Task task in tasks) {
      _tagCache[task.id] = await repository.tagsForTask(task.id);
    }
    notifyListeners();
  }

  /// Persists [t] and returns the saved copy (with its database-assigned id).
  ///
  /// [tasks] is refreshed and listeners are notified after insertion.
  Future<Task> create(Task t) async {
    final Task created = await repository.insertTask(t);
    await loadAll();
    return created;
  }

  /// Permanently removes the task with [id] and refreshes [tasks].
  Future<void> delete(int id) async {
    await repository.deleteTask(id);
    await loadAll();
  }

  /// Overwrites the stored task that matches [t.id] with updated field values,
  /// then refreshes [tasks].
  Future<void> update(Task t) async {
    await repository.updateTask(t);
    await loadAll();
  }

  /// Links the tag [tagID] to [taskID] and refreshes [tasks].
  Future<void> addTag(int taskID, int tagID) async {
    await repository.addTag(taskID, tagID);
    await loadAll();
  }

  /// Removes the link between [tagID] and [taskID], then refreshes [tasks].
  Future<void> removeTag(int taskID, int tagID) async {
    await repository.removeTag(taskID, tagID);
    await loadAll();
  }

  /// Returns the cached list of tag IDs associated with [task].
  ///
  /// Returns an empty list if no tags have been loaded for this task.
  List<int> getTags(Task task) {
    return _tagCache[task.id] ?? [];
  }

  /// Replaces all tags on [task] with [tagIDs].
  ///
  /// Only the diff is applied (adds missing tags, removes stale ones) to
  /// minimise database writes. [tasks] is refreshed once after all changes.
  Future<void> setTags(Task task, List<int> tagIDs) async {
    List<int> currentTags = getTags(task);
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

  /// Returns the task with the given [id] directly from the repository.
  Future<Task> getById(int id) async => repository.getTask(id);
}
