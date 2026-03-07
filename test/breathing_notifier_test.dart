import 'package:flutter_test/flutter_test.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/notifiers/breathing.dart';

import 'helpers/mock_repositories.dart';

Breathing _makeBreathing({int id = 0, String name = 'Box Breathing'}) =>
    Breathing(
      id: id,
      name: name,
      countIn: 4,
      holdIn: 4,
      countOut: 4,
      holdOut: 4,
      reps: 3,
    );

void main() {
  late FakeBreathingRepository repo;
  late BreathingNotifier notifier;

  setUp(() {
    repo = FakeBreathingRepository();
    notifier = BreathingNotifier(repository: repo);
  });

  tearDown(() => notifier.dispose());

  group('BreathingNotifier', () {
    test('starts with an empty breathing list', () async {
      await Future.microtask(() {});
      expect(notifier.breathings, isEmpty);
    });

    test('create adds a breathing exercise and updates the list', () async {
      await notifier.create(_makeBreathing(name: '4-7-8'));
      expect(notifier.breathings.length, 1);
      expect(notifier.breathings.first.name, '4-7-8');
    });

    test('create returns the inserted breathing with a generated id', () async {
      final created = await notifier.create(_makeBreathing());
      expect(created.id, isPositive);
    });

    test('delete removes the breathing exercise', () async {
      final created = await notifier.create(_makeBreathing());
      await notifier.delete(created.id);
      expect(notifier.breathings, isEmpty);
    });

    test('update changes breathing fields', () async {
      final created = await notifier.create(_makeBreathing(name: 'Original'));
      final updated = created.copyWith(name: 'Updated');
      await notifier.update(updated);
      expect(notifier.breathings.first.name, 'Updated');
    });

    test('addTag associates a tag with a breathing exercise', () async {
      final created = await notifier.create(_makeBreathing());
      await notifier.addTag(created.id, 10);
      expect(notifier.getTags(created), contains(10));
    });

    test('removeTag dissociates a tag', () async {
      final created = await notifier.create(_makeBreathing());
      await notifier.addTag(created.id, 10);
      await notifier.removeTag(created.id, 10);
      expect(notifier.getTags(created), isNot(contains(10)));
    });

    test('getTags returns empty list for exercise with no tags', () async {
      final created = await notifier.create(_makeBreathing());
      expect(notifier.getTags(created), isEmpty);
    });

    test('setTags replaces all tags', () async {
      final created = await notifier.create(_makeBreathing());
      await notifier.addTag(created.id, 1);
      await notifier.addTag(created.id, 2);
      await notifier.setTags(created, [5, 6]);
      final tags = notifier.getTags(created);
      expect(tags, containsAll([5, 6]));
      expect(tags, isNot(contains(1)));
      expect(tags, isNot(contains(2)));
    });

    test('setTags with empty list removes all tags', () async {
      final created = await notifier.create(_makeBreathing());
      await notifier.addTag(created.id, 1);
      await notifier.setTags(created, []);
      expect(notifier.getTags(created), isEmpty);
    });

    test('getById returns the correct breathing exercise', () async {
      final created = await notifier.create(_makeBreathing(name: 'Find Me'));
      final found = await notifier.getById(created.id);
      expect(found.name, 'Find Me');
    });

    test('loadAll notifies listeners', () async {
      bool notified = false;
      notifier.addListener(() => notified = true);
      await notifier.loadAll();
      expect(notified, isTrue);
    });
  });
}
