import 'package:toolery/models/journal.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toolery/database/startdb.dart';
import 'dart:async';

/// Defines the data-access contract for [Journal] persistence.
///
/// Concrete implementations (e.g. [SqliteJournalRepository]) are injected into
/// [JournalNotifier] so that the notifier remains database-agnostic and is easy
/// to test with a fake in-memory implementation.
abstract class JournalRepository {
  /// Returns all journal entries ordered by date written (newest first).
  Future<List<Journal>> allEntries();

  /// Persists [entry] and returns the saved copy with its database-assigned id.
  Future<Journal> insertEntry(Journal entry);

  /// Returns the entry with the given [id], or a sentinel entry if none exists.
  Future<Journal> getEntry(int id);

  /// Overwrites the stored record that matches [entry.id] with new field values.
  Future<void> updateEntry(Journal entry);

  /// Permanently removes the entry with [id] and its associated tag links.
  Future<void> deleteEntry(int id);

  /// Returns the list of tag IDs currently attached to the entry with [entryID].
  Future<List<int>> tagsForEntry(int entryID);

  /// Links the tag [tagID] to the entry [entryID].
  Future<void> addTag(int entryID, int tagID);

  /// Removes the link between tag [tagID] and entry [entryID].
  Future<void> removeTag(int entryID, int tagID);

  /// Completes when the repository has finished initialising and is ready to use.
  Future<void> get ready;
}

class SqliteJournalRepository implements JournalRepository {
  late Database db;
  final String table = 'journal';
  final String joinTable = 'journaltag';
  final Completer<void> _ready = Completer<void>();

  SqliteJournalRepository() {
    _initDB();
  }

  Future<void> _initDB() async {
    db = await getDatabase();
    if (!_ready.isCompleted) _ready.complete();
  }

  @override
  Future<void> get ready => _ready.future;

  Journal _fromMap(Map<String, Object?> m) => Journal.fromMap(m);

  Map<String, Object?> _toMap(Journal e) => e.toMap();

  @override
  Future<void> deleteEntry(int id) async {
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
    await db.delete(joinTable, where: 'entryID = ?', whereArgs: [id]);
  }

  @override
  Future<Journal> insertEntry(Journal entry) async {
    Map<String, Object?> map = _toMap(entry);
    map.remove('id');
    final id = await db.insert(
      table,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return getEntry(id);
  }

  @override
  Future<List<Journal>> allEntries() async {
    final rows = await db.query(table, orderBy: 'dateWritten DESC');
    return rows.map((r) => _fromMap(r)).toList();
  }

  @override
  Future<Journal> getEntry(int id) async {
    final rows = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return Journal(
        id: -1,
        title: 'Null',
        dateWritten: '',
        content: '[{"insert":"\\n"}]',
      );
    }
    return _fromMap(rows.first);
  }

  @override
  Future<void> updateEntry(Journal entry) async {
    final map = _toMap(entry);
    final id = map['id'];
    if (id == null) return;
    await db.update(table, map, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<int>> tagsForEntry(int entryID) async {
    final rows = await db.rawQuery(
      'SELECT id FROM tag JOIN journaltag ON tag.id = journaltag.tagID WHERE journaltag.entryID = ?',
      [entryID],
    );
    return rows.map((row) => row['id'] as int).toList();
  }

  @override
  Future<void> addTag(int entryID, int tagID) async {
    await db.insert(joinTable, {
      'entryID': entryID,
      'tagID': tagID,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> removeTag(int entryID, int tagID) async {
    await db.delete(
      joinTable,
      where: 'entryID = ? AND tagID = ?',
      whereArgs: [entryID, tagID],
    );
  }
}
