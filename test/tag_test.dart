import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolery/models/tag.dart';

void main() {
  group('Tag model', () {
    final tag = Tag(id: 1, name: 'Work', color: Colors.blue);

    test('toString returns expected format', () {
      expect(tag.toString(), contains('Tag(id: 1'));
      expect(tag.toString(), contains('name: Work'));
    });

    test('toMap includes id, name, and color as int', () {
      final map = tag.toMap();
      expect(map['id'], 1);
      expect(map['name'], 'Work');
      expect(map['color'], isA<int>());
    });

    test('copyWith changes only specified fields', () {
      final copy = tag.copyWith(name: 'Personal');
      expect(copy.id, tag.id);
      expect(copy.name, 'Personal');
      expect(copy.color, tag.color);
    });

    test('copyWith with no arguments returns equivalent tag', () {
      final copy = tag.copyWith();
      expect(copy, tag);
    });

    test('equality holds for identical data', () {
      final other = Tag(id: 1, name: 'Work', color: Colors.blue);
      expect(tag, other);
    });

    test('inequality when fields differ', () {
      expect(tag == tag.copyWith(id: 2), isFalse);
      expect(tag == tag.copyWith(name: 'Other'), isFalse);
      expect(tag == tag.copyWith(color: Colors.red), isFalse);
    });

    test('hashCode is consistent with equality', () {
      final other = Tag(id: 1, name: 'Work', color: Colors.blue);
      expect(tag.hashCode, other.hashCode);
    });
  });
}
