// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AffirmationItem {
  final int id;
  final int listId;
  final String item;

  const AffirmationItem({
    required this.id,
    required this.listId,
    required this.item,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'list_id': listId, 'item': item};
  }

  @override
  String toString() => 'AffirmationItem(id: $id, listId: $listId, item: $item)';

  AffirmationItem copyWith({int? id, int? listId, String? item}) {
    return AffirmationItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      item: item ?? this.item,
    );
  }

  factory AffirmationItem.fromMap(Map<String, dynamic> map) {
    return AffirmationItem(
      id: map['id'] as int,
      listId: map['list_id'] as int,
      item: map['item'] as String,
    );
  }

  String toJson() => json.encode(toMap());

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
