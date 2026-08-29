// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

/// Represents a single journal entry written by the user.
///
/// A [Journal] stores a [title], the [dateWritten] (ISO 8601 string),
/// and the rich-text [content] serialised as a flutter_quill Delta JSON string.
/// Entries are persisted to SQLite via [SqliteJournalRepository].
///
/// Example:
/// ```dart
/// final entry = Journal(
///   id: 1,
///   title: 'Morning Reflection',
///   dateWritten: '2024-01-15T08:30:00.000',
///   content: '[{"insert":"Today I feel grateful.\\n"}]',
/// );
/// ```
class Journal {
  /// Unique identifier assigned by the database on insert.
  final int id;

  /// Short title shown in the list view.
  final String title;

  /// ISO 8601 date-time string recording when the entry was created.
  final String dateWritten;

  /// flutter_quill Delta JSON string containing the rich-text body.
  final String content;

  const Journal({
    required this.id,
    required this.title,
    required this.dateWritten,
    required this.content,
  });

  /// Serialises this entry to a [Map] suitable for SQLite insertion.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'dateWritten': dateWritten,
      'content': content,
    };
  }

  @override
  String toString() {
    return 'Journal(id: $id, title: $title, dateWritten: $dateWritten)';
  }

  /// Returns a copy of this entry with the given fields replaced.
  Journal copyWith({
    int? id,
    String? title,
    String? dateWritten,
    String? content,
  }) {
    return Journal(
      id: id ?? this.id,
      title: title ?? this.title,
      dateWritten: dateWritten ?? this.dateWritten,
      content: content ?? this.content,
    );
  }

  /// Serialises this entry to a JSON string.
  String toJson() => json.encode(toMap());

  @override
  bool operator ==(covariant Journal other) {
    if (identical(this, other)) return true;
    return other.id == id &&
        other.title == title &&
        other.dateWritten == dateWritten &&
        other.content == content;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        dateWritten.hashCode ^
        content.hashCode;
  }

  /// Deserialises a [Journal] from a SQLite row [Map].
  factory Journal.fromMap(Map<String, dynamic> map) {
    return Journal(
      id: map['id'] as int,
      title: map['title'] as String,
      dateWritten: map['dateWritten'] as String,
      content: map['content'] as String,
    );
  }

  /// Deserialises a [Journal] from a JSON string produced by [toJson].
  factory Journal.fromJson(String source) =>
      Journal.fromMap(json.decode(source) as Map<String, dynamic>);
}
