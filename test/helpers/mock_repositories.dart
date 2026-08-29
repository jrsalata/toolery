import 'dart:async';
import 'package:flutter/material.dart';
import 'package:toolery/models/affirmation_item.dart';
import 'package:toolery/models/affirmation_list.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/models/journal.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/models/task.dart';
import 'package:toolery/repositories/affirmation.dart';
import 'package:toolery/repositories/breathing.dart';
import 'package:toolery/repositories/journal.dart';
import 'package:toolery/repositories/tag.dart';
import 'package:toolery/repositories/task.dart';

// ---------------------------------------------------------------------------
// In-memory TaskRepository
// ---------------------------------------------------------------------------

/// An in-memory [TaskRepository] used for unit tests.
class FakeTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];
  final Map<int, Set<int>> _taskTags = {};
  int _nextId = 1;

  @override
  Future<void> get ready => Future.value();

  @override
  Future<List<Task>> allTasks() async => List.unmodifiable(_tasks);

  @override
  Future<Task> insertTask(Task task) async {
    final newTask = task.copyWith(id: _nextId++);
    _tasks.add(newTask);
    _taskTags[newTask.id] = {};
    return newTask;
  }

  @override
  Future<Task> getTask(int id) async {
    return _tasks.firstWhere(
      (t) => t.id == id,
      orElse: () => Task(
        id: -1,
        name: 'Null',
        description: 'Not found',
        task: 'Not found',
      ),
    );
  }

  @override
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _tasks[index] = task;
  }

  @override
  Future<void> deleteTask(int id) async {
    _tasks.removeWhere((t) => t.id == id);
    _taskTags.remove(id);
  }

  @override
  Future<List<int>> tagsForTask(int taskID) async {
    return (_taskTags[taskID] ?? {}).toList();
  }

  @override
  Future<void> addTag(int taskID, int tagID) async {
    _taskTags.putIfAbsent(taskID, () => {}).add(tagID);
  }

  @override
  Future<void> removeTag(int taskID, int tagID) async {
    _taskTags[taskID]?.remove(tagID);
  }
}

// ---------------------------------------------------------------------------
// In-memory TagRepository
// ---------------------------------------------------------------------------

/// An in-memory [TagRepository] used for unit tests.
class FakeTagRepository implements TagRepository {
  final List<Tag> _tags = [];
  int _nextId = 1;

  @override
  Future<void> get ready => Future.value();

  @override
  Future<List<Tag>> allTags() async => List.unmodifiable(_tags);

  @override
  Future<void> insertTag(Tag tag) async {
    _tags.add(tag.copyWith(id: _nextId++));
  }

  @override
  Future<Tag> getTag(int id) async {
    return _tags.firstWhere(
      (t) => t.id == id,
      orElse: () => Tag(id: -1, name: 'Null', color: Colors.red),
    );
  }

  @override
  Future<void> updateTag(Tag tag) async {
    final index = _tags.indexWhere((t) => t.id == tag.id);
    if (index != -1) _tags[index] = tag;
  }

  @override
  Future<void> deleteTag(int id) async {
    _tags.removeWhere((t) => t.id == id);
  }
}

// ---------------------------------------------------------------------------
// In-memory BreathingRepository
// ---------------------------------------------------------------------------

/// An in-memory [BreathingRepository] used for unit tests.
class FakeBreathingRepository implements BreathingRepository {
  final List<Breathing> _breathings = [];
  final Map<int, Set<int>> _breathingTags = {};
  int _nextId = 1;

  @override
  Future<void> get ready => Future.value();

  @override
  Future<List<Breathing>> allBreathing() async =>
      List.unmodifiable(_breathings);

  @override
  Future<Breathing> insertBreathing(Breathing breathing) async {
    final newBreathing = breathing.copyWith(id: _nextId++);
    _breathings.add(newBreathing);
    _breathingTags[newBreathing.id] = {};
    return newBreathing;
  }

  @override
  Future<Breathing> getBreathing(int id) async {
    return _breathings.firstWhere(
      (b) => b.id == id,
      orElse: () => Breathing(
        id: -1,
        name: 'Empty',
        countIn: 0,
        holdIn: 0,
        countOut: 0,
        holdOut: 0,
        reps: 0,
      ),
    );
  }

  @override
  Future<void> updateBreathing(Breathing breathing) async {
    final index = _breathings.indexWhere((b) => b.id == breathing.id);
    if (index != -1) _breathings[index] = breathing;
  }

  @override
  Future<void> deleteBreathing(int id) async {
    _breathings.removeWhere((b) => b.id == id);
    _breathingTags.remove(id);
  }

  @override
  Future<List<int>> tagsForBreathing(int breathingID) async {
    return (_breathingTags[breathingID] ?? {}).toList();
  }

  @override
  Future<void> addTag(int breathingId, int tagID) async {
    _breathingTags.putIfAbsent(breathingId, () => {}).add(tagID);
  }

  @override
  Future<void> removeTag(int breathingID, int tagID) async {
    _breathingTags[breathingID]?.remove(tagID);
  }
}

// ---------------------------------------------------------------------------
// In-memory AffirmationRepository
// ---------------------------------------------------------------------------

/// An in-memory [AffirmationRepository] used for unit tests.
class FakeAffirmationRepository implements AffirmationRepository {
  final List<AffirmationList> _lists = [];
  final Map<int, List<AffirmationItem>> _items = {};
  int _nextListId = 1;
  int _nextItemId = 1;

  @override
  Future<void> get ready => Future.value();

  @override
  Future<List<AffirmationList>> allLists() async =>
      List.unmodifiable(_lists);

  @override
  Future<void> insertList(AffirmationList list) async {
    _lists.add(list.copyWith(id: _nextListId++));
  }

  @override
  Future<AffirmationList> getList(int id) async {
    return _lists.firstWhere(
      (l) => l.id == id,
      orElse: () => AffirmationList(id: -1, name: 'Null'),
    );
  }

  @override
  Future<void> updateList(AffirmationList list) async {
    final index = _lists.indexWhere((l) => l.id == list.id);
    if (index != -1) _lists[index] = list;
  }

  @override
  Future<void> deleteList(int id) async {
    _lists.removeWhere((l) => l.id == id);
    _items.remove(id);
  }

  @override
  Future<List<AffirmationItem>> itemsForList(int listId) async {
    return List.unmodifiable(_items[listId] ?? []);
  }

  @override
  Future<void> insertItem(AffirmationItem item) async {
    final newItem = item.copyWith(id: _nextItemId++);
    _items.putIfAbsent(item.listId, () => []).add(newItem);
  }

  @override
  Future<AffirmationItem> getItem(int id) async {
    for (final list in _items.values) {
      for (final item in list) {
        if (item.id == id) return item;
      }
    }
    return AffirmationItem(id: -1, listId: -1, item: '');
  }

  @override
  Future<void> updateItem(AffirmationItem item) async {
    final list = _items[item.listId];
    if (list == null) return;
    final index = list.indexWhere((i) => i.id == item.id);
    if (index != -1) list[index] = item;
  }

  @override
  Future<void> deleteItem(int id) async {
    for (final list in _items.values) {
      list.removeWhere((i) => i.id == id);
    }
  }
}

// ---------------------------------------------------------------------------
// In-memory JournalRepository
// ---------------------------------------------------------------------------

/// An in-memory [JournalRepository] used for unit tests.
class FakeJournalRepository implements JournalRepository {
  final List<Journal> _entries = [];
  final Map<int, Set<int>> _entryTags = {};
  int _nextId = 1;

  @override
  Future<void> get ready => Future.value();

  @override
  Future<List<Journal>> allEntries() async => List.unmodifiable(_entries);

  @override
  Future<Journal> insertEntry(Journal entry) async {
    final newEntry = entry.copyWith(id: _nextId++);
    _entries.add(newEntry);
    _entryTags[newEntry.id] = {};
    return newEntry;
  }

  @override
  Future<Journal> getEntry(int id) async {
    return _entries.firstWhere(
      (e) => e.id == id,
      orElse: () => Journal(
        id: -1,
        title: 'Null',
        dateWritten: '',
        content: '[{"insert":"\\n"}]',
      ),
    );
  }

  @override
  Future<void> updateEntry(Journal entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) _entries[index] = entry;
  }

  @override
  Future<void> deleteEntry(int id) async {
    _entries.removeWhere((e) => e.id == id);
    _entryTags.remove(id);
  }

  @override
  Future<List<int>> tagsForEntry(int entryID) async {
    return (_entryTags[entryID] ?? {}).toList();
  }

  @override
  Future<void> addTag(int entryID, int tagID) async {
    _entryTags.putIfAbsent(entryID, () => {}).add(tagID);
  }

  @override
  Future<void> removeTag(int entryID, int tagID) async {
    _entryTags[entryID]?.remove(tagID);
  }
}
