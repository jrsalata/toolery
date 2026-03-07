import 'package:test/test.dart';
import 'package:toolery/models/breathing.dart';

void main() {
  group('Breathing model', () {
    final breathing = Breathing(
      id: 1,
      name: 'Box Breathing',
      countIn: 4,
      holdIn: 4,
      countOut: 4,
      holdOut: 4,
      reps: 3,
    );

    test('toString returns expected format', () {
      expect(breathing.toString(), contains('Breathing(id: 1'));
      expect(breathing.toString(), contains('name: Box Breathing'));
      expect(breathing.toString(), contains('countIn: 4'));
      expect(breathing.toString(), contains('reps: 3'));
    });

    test('toMap returns correct map', () {
      expect(breathing.toMap(), {
        'id': 1,
        'name': 'Box Breathing',
        'countIn': 4,
        'holdIn': 4,
        'countOut': 4,
        'holdOut': 4,
        'reps': 3,
      });
    });

    test('fromMap reconstructs a Breathing', () {
      final map = {
        'id': 2,
        'name': '4-7-8',
        'countIn': 4,
        'holdIn': 7,
        'countOut': 8,
        'holdOut': 0,
        'reps': 4,
      };
      final b = Breathing.fromMap(map);
      expect(b.id, 2);
      expect(b.name, '4-7-8');
      expect(b.countIn, 4);
      expect(b.holdIn, 7);
      expect(b.countOut, 8);
      expect(b.holdOut, 0);
      expect(b.reps, 4);
    });

    test('toJson/fromJson round-trip', () {
      final json = breathing.toJson();
      final restored = Breathing.fromJson(json);
      expect(restored, breathing);
    });

    test('copyWith changes only specified fields', () {
      final copy = breathing.copyWith(name: 'Updated', reps: 5);
      expect(copy.id, breathing.id);
      expect(copy.name, 'Updated');
      expect(copy.reps, 5);
      expect(copy.countIn, breathing.countIn);
    });

    test('copyWith with no arguments returns equivalent breathing', () {
      expect(breathing.copyWith(), breathing);
    });

    test('equality holds for identical data', () {
      final other = Breathing(
        id: 1,
        name: 'Box Breathing',
        countIn: 4,
        holdIn: 4,
        countOut: 4,
        holdOut: 4,
        reps: 3,
      );
      expect(breathing, other);
    });

    test('inequality when fields differ', () {
      expect(breathing == breathing.copyWith(id: 99), isFalse);
      expect(breathing == breathing.copyWith(countIn: 5), isFalse);
    });

    test('hashCode is consistent with equality', () {
      final other = Breathing(
        id: 1,
        name: 'Box Breathing',
        countIn: 4,
        holdIn: 4,
        countOut: 4,
        holdOut: 4,
        reps: 3,
      );
      expect(breathing.hashCode, other.hashCode);
    });

    group('humanReadable getter', () {
      test('includes holdIn when holdIn > 0', () {
        expect(breathing.humanReadable, contains('Hold 4'));
      });

      test('omits holdIn section when holdIn is 0', () {
        final b = breathing.copyWith(holdIn: 0);
        expect(b.humanReadable, isNot(contains('Hold')));
      });

      test('includes holdOut when holdOut > 0', () {
        expect(breathing.humanReadable, contains('Hold 4'));
      });

      test('omits holdOut section when holdOut is 0', () {
        final b = breathing.copyWith(holdOut: 0);
        // holdIn is still 4, so "Hold 4" still appears once but not twice
        expect(b.humanReadable.split('Hold').length - 1, 1);
      });

      test('format is In X - Out Y for no holds', () {
        final b = Breathing(
          id: 1,
          name: 'Simple',
          countIn: 4,
          holdIn: 0,
          countOut: 4,
          holdOut: 0,
          reps: 1,
        );
        expect(b.humanReadable, 'In 4 - Out 4');
      });

      test('format is In X - Hold Y - Out Z for holdIn only', () {
        final b = Breathing(
          id: 1,
          name: 'Hold In',
          countIn: 4,
          holdIn: 2,
          countOut: 4,
          holdOut: 0,
          reps: 1,
        );
        expect(b.humanReadable, 'In 4 - Hold 2 - Out 4');
      });
    });
  });
}
