import 'package:sqflite/sqflite.dart';

/// Describes the database state an integration test should start from.
///
/// [applySeed] applies this on top of whatever `onCreate` already put in the
/// database (the ~30-row demo fixture from `lib/database/startdb.dart`).
/// Setting [keepDemoData] to `false` wipes that fixture first, which is
/// useful for tests that assert on an exact list ("no tasks yet").
class Seed {
  const Seed({
    this.keepDemoData = true,
    this.tags = const <(String name, int color)>[],
    this.breathings = const <BreathingSeed>[],
  });

  /// Keeps the demo fixture `onCreate` inserts (5 tags, 4 tasks, 3 breathing
  /// exercises, 2 affirmation lists with 7 items). This is the default: most
  /// tests want realistic starting data rather than an empty app.
  const Seed.demo() : this();

  /// Wipes the demo fixture, leaving every table empty before any extra rows
  /// below are inserted.
  const Seed.empty() : this(keepDemoData: false);

  /// A single breathing exercise short enough to run to completion on a
  /// wall clock: two one-second phases (~2s) instead of Square breathing's
  /// 4/4/4/4 x6 (~96s). See `_buildPhases` in
  /// `lib/breathingExercises/controller.dart` — a phase is only emitted for
  /// a non-zero count, so `holdIn`/`holdOut` at 0 are skipped entirely.
  static const Seed quickBreath = Seed(
    breathings: <BreathingSeed>[
      BreathingSeed(
        name: 'IT quick breath',
        countIn: 1,
        holdIn: 0,
        countOut: 1,
        holdOut: 0,
        reps: 1,
      ),
    ],
  );

  final bool keepDemoData;
  final List<(String name, int color)> tags;
  final List<BreathingSeed> breathings;
}

/// A breathing exercise row to insert as part of a [Seed].
class BreathingSeed {
  const BreathingSeed({
    required this.name,
    required this.countIn,
    required this.holdIn,
    required this.countOut,
    required this.holdOut,
    required this.reps,
  });

  final String name;
  final int countIn;
  final int holdIn;
  final int countOut;
  final int holdOut;
  final int reps;
}

/// Deletes the demo fixture (if `!seed.keepDemoData`) then inserts the extra
/// rows [seed] describes, directly against [db].
///
/// Runs before the widget tree is built, so nothing here goes through the
/// notifiers/repositories — it talks to the same tables `startdb.dart`
/// created, in the same order `DataService.tableNames` uses (children before
/// parents on delete, so foreign keys never dangle).
Future<void> applySeed(Database db, Seed seed) async {
  if (!seed.keepDemoData) {
    for (final String table in <String>[
      'journaltag',
      'tasktag',
      'breathingtag',
      'affirmation_items',
      'affirmation_list',
      'journal',
      'task',
      'breathing',
      'tag',
    ]) {
      await db.delete(table);
    }
  }

  for (final (String name, int color) in seed.tags) {
    await db.insert('tag', <String, Object?>{'name': name, 'color': color});
  }

  for (final BreathingSeed b in seed.breathings) {
    await db.insert('breathing', <String, Object?>{
      'name': b.name,
      'countIn': b.countIn,
      'holdIn': b.holdIn,
      'countOut': b.countOut,
      'holdOut': b.holdOut,
      'reps': b.reps,
    });
  }
}
