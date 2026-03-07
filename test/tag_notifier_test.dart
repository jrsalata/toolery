import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolery/models/tag.dart';
import 'package:toolery/notifiers/tag.dart';

import 'helpers/mock_repositories.dart';

Tag _makeTag({int id = 0, String name = 'Work', Color? color}) =>
    Tag(id: id, name: name, color: color ?? Colors.blue);

void main() {
  late FakeTagRepository repo;
  late TagNotifier notifier;

  setUp(() {
    repo = FakeTagRepository();
    notifier = TagNotifier(repository: repo);
  });

  tearDown(() => notifier.dispose());

  group('TagNotifier', () {
    test('starts with an empty tag list', () async {
      await Future.microtask(() {});
      expect(notifier.tags, isEmpty);
    });

    test('create adds a tag to the list', () async {
      await notifier.create(_makeTag(name: 'Health'));
      expect(notifier.tags.length, 1);
      expect(notifier.tags.first.name, 'Health');
    });

    test('create assigns a generated id', () async {
      await notifier.create(_makeTag());
      expect(notifier.tags.first.id, isPositive);
    });

    test('delete removes the tag', () async {
      await notifier.create(_makeTag());
      final id = notifier.tags.first.id;
      await notifier.delete(id);
      expect(notifier.tags, isEmpty);
    });

    test('update changes tag fields', () async {
      await notifier.create(_makeTag(name: 'Original'));
      final tag = notifier.tags.first;
      await notifier.update(tag.copyWith(name: 'Updated'));
      expect(notifier.tags.first.name, 'Updated');
    });

    test('getById returns the correct tag', () async {
      await notifier.create(_makeTag(name: 'Unique'));
      final id = notifier.tags.first.id;
      final found = await notifier.getById(id);
      expect(found.name, 'Unique');
    });

    test('loadAll notifies listeners', () async {
      bool notified = false;
      notifier.addListener(() => notified = true);
      await notifier.loadAll();
      expect(notified, isTrue);
    });
  });
}
