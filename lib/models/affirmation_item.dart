// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

/// A single positive affirmation belonging to an [AffirmationList].
///
/// Each [AffirmationItem] stores one piece of text (e.g. "I am capable and
/// strong") and is linked to its parent list via [listId]. Items are managed
/// via [AffirmationNotifier] and persisted through [SqliteAffirmationRepository].
///
/// Example:
/// ```dart
/// const item = AffirmationItem(
///   id: 1,
///   listId: 2,
///   item: 'I am worthy of good things.',
/// );
/// ```
class AffirmationItem {
  /// Unique identifier (assigned by the database on insert).
  final int id;

  /// Foreign key referencing the parent [AffirmationList.id].
  final int listId;

  /// The affirmation text displayed to the user.
  final String item;

  const AffirmationItem({
    required this.id,
    required this.listId,
    required this.item,
  });

  /// Serialises this item to a [Map] suitable for SQLite insertion.
  ///
  /// The parent list reference is stored under the key `list_id` to match
  /// the database schema.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'list_id': listId, 'item': item};
  }

  @override
  String toString() => 'AffirmationItem(id: $id, listId: $listId, item: $item)';

  /// Returns a copy of this item with the given fields replaced.
  AffirmationItem copyWith({int? id, int? listId, String? item}) {
    return AffirmationItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      item: item ?? this.item,
    );
  }

  /// Deserialises an [AffirmationItem] from a SQLite row [Map].
  ///
  /// Expects the parent list reference under the key `list_id`.
  factory AffirmationItem.fromMap(Map<String, dynamic> map) {
    return AffirmationItem(
      id: map['id'] as int,
      listId: map['list_id'] as int,
      item: map['item'] as String,
    );
  }

  /// Serialises this item to a JSON string.
  String toJson() => json.encode(toMap());

  /// Deserialises an [AffirmationItem] from a JSON string produced by [toJson].
  factory AffirmationItem.fromJson(String source) =>
      AffirmationItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant AffirmationItem other) {
    if (identical(this, other)) return true;
    return other.id == id && other.listId == listId && other.item == item;
  }

  @override
  int get hashCode => id.hashCode ^ listId.hashCode ^ item.hashCode;
}
