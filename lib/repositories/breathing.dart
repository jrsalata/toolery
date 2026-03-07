import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:toolery/database/startdb.dart';
import 'package:toolery/models/breathing.dart';

/// Defines the data-access contract for [Breathing] exercise persistence.
///
/// Concrete implementations (e.g. [SqliteBreathingRepository]) are injected
/// into [BreathingNotifier] so the notifier stays database-agnostic and
/// testable.
abstract class BreathingRepository {
  /// Returns all breathing exercises in insertion order.
  Future<List<Breathing>> allBreathing();

  /// Persists [breathing] and returns the saved copy with its database-assigned id.
  Future<Breathing> insertBreathing(Breathing breathing);

  /// Returns the breathing exercise with [id], or a sentinel empty record if none exists.
  Future<Breathing> getBreathing(int id);

  /// Overwrites the stored record that matches [breathing.id] with new field values.
  Future<void> updateBreathing(Breathing breathing);

  /// Permanently removes the breathing exercise with [id] and its tag links.
  Future<void> deleteBreathing(int id);

  /// Completes when the repository has finished initialising and is ready to use.
  Future<void> get ready;

  /// Returns the list of tag IDs currently attached to the breathing exercise [breathingID].
  Future<List<int>> tagsForBreathing(int breathingID);

  /// Links the tag [tagID] to the breathing exercise [breathingId].
  Future<void> addTag(int breathingId, int tagID);

  /// Removes the link between tag [tagID] and breathing exercise [breathingID].
  Future<void> removeTag(int breathingID, int tagID);
}

class SqliteBreathingRepository implements BreathingRepository {
  late Database db;
  final String table = 'breathing';
  final String joinTable = 'breathingtag';
  final Completer<void> _ready = Completer<void>();

  SqliteBreathingRepository() {
    _initDB();
  }

  Future<void> _initDB() async {
    db = await getDatabase();
    // mark repository as ready
    if (!_ready.isCompleted) _ready.complete();
  }

  @override
  Future<void> get ready => _ready.future;

  Breathing _fromMap(Map<String, Object?> m) => Breathing.fromMap(m);

  Map<String, Object?> _toMap(Breathing t) => t.toMap();

  @override
  Future<void> deleteBreathing(int id) async {
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
    await db.delete(joinTable, where: 'breathingID = ?', whereArgs: [id]);
  }

  @override
  Future<Breathing> insertBreathing(Breathing breathing) async {
    Map<String, Object?> map = _toMap(breathing);
    map.remove('id');
    final id = await db.insert(
      table,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return getBreathing(id);
  }

  @override
  Future<List<Breathing>> allBreathing() async {
    final rows = await db.query(table);
    return rows.map((r) => _fromMap(r)).toList();
  }

  @override
  Future<Breathing> getBreathing(int id) async {
    final rows = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return Breathing(
        id: -1,
        name: "Empty",
        countIn: 0,
        holdIn: 0,
        countOut: 0,
        holdOut: 0,
        reps: 0,
      );
    }
    return _fromMap(rows.first);
  }

  @override
  Future<void> updateBreathing(Breathing breathing) async {
    final map = _toMap(breathing);
    final id = map['id'];
    if (id == null) return;
    await db.update(table, map, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<int>> tagsForBreathing(int breathingID) async {
    final rows = await db.rawQuery(
      'SELECT id, name, color FROM tag JOIN breathingtag on tag.id = breathingtag.tagID WHERE breathingtag.breathingID = ?',
      [breathingID],
    );
    return rows.map((row) => row['id'] as int).toList();
  }

  @override
  Future<void> addTag(int breathingId, int tagID) async {
    await db.insert(joinTable, {
      'breathingID': breathingId,
      'tagID': tagID,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> removeTag(int breathingID, int tagID) async {
    await db.delete(
      joinTable,
      where: "breathingID = ? AND tagID = ?",
      whereArgs: [breathingID, tagID],
    );
  }
}
