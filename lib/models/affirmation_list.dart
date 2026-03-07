// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

/// A named collection of [AffirmationItem]s.
///
/// An [AffirmationList] acts as a folder that groups related positive
/// affirmations together. Users can create multiple lists (e.g. "Morning
/// Mantras", "Work Mindset") and have the app surface a random [AffirmationItem]
/// from a chosen list at any time.
///
/// Lists are managed via [AffirmationNotifier] and persisted through
/// [SqliteAffirmationRepository].
///
/// Example:
/// ```dart
/// const list = AffirmationList(id: 1, name: 'Morning Mantras');
/// ```
class AffirmationList {
  /// Unique identifier (assigned by the database on insert).
  final int id;

  /// Display name for this collection of affirmations.
  final String name;

  const AffirmationList({required this.id, required this.name});

  /// Serialises this list to a [Map] suitable for SQLite insertion.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name};
  }

  @override
  String toString() => 'AffirmationList(id: $id, name: $name)';

  /// Returns a copy of this list with the given fields replaced.
  AffirmationList copyWith({int? id, String? name}) {
    return AffirmationList(id: id ?? this.id, name: name ?? this.name);
  }

  /// Deserialises an [AffirmationList] from a SQLite row [Map].
  factory AffirmationList.fromMap(Map<String, dynamic> map) {
    return AffirmationList(id: map['id'] as int, name: map['name'] as String);
  }

  /// Serialises this list to a JSON string.
  String toJson() => json.encode(toMap());

  /// Deserialises an [AffirmationList] from a JSON string produced by [toJson].
  factory AffirmationList.fromJson(String source) =>
      AffirmationList.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant AffirmationList other) {
    if (identical(this, other)) return true;
    return other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
