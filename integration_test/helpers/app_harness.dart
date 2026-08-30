import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toolery/database/startdb.dart';
import 'package:toolery/main.dart';
import 'package:toolery/notifiers/affirmation.dart';
import 'package:toolery/notifiers/breathing.dart';
import 'package:toolery/notifiers/journal.dart';
import 'package:toolery/notifiers/tag.dart';
import 'package:toolery/notifiers/task.dart';

import 'seed.dart';

/// Boots the real app (the same [buildToolery] tree `main()` runs) against a
/// throwaway database seeded to [seed].
///
/// Order matters: the SQLite repositories capture the database handle in
/// their constructors, so the reset and the seed must both land *before*
/// [buildToolery] is pumped, or a live repository ends up holding a closed
/// connection.
///
/// [returningUser] defaults to `true` so most tests skip the five-dialog
/// welcome gauntlet; pass `false` to exercise it directly.
Future<void> launchApp(
  WidgetTester tester, {
  bool returningUser = true,
  Map<String, Object> prefs = const <String, Object>{},
  Seed seed = const Seed.demo(),
}) async {
  // Every integration_test entrypoint needs this binding initialized
  // exactly once; the call is idempotent, so it's safe to make on every
  // launchApp invocation.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  SharedPreferences.setMockInitialValues(<String, Object>{
    'returningUser': returningUser,
    // Emulators have no audio and no haptics; the futures cost time and can
    // throw on a bare AVD. Tests that assert on these settings override them.
    'breathingSounds': false,
    'breathingVibrate': false,
    ...prefs,
  });

  await resetDatabaseForTesting(name: 'toolery_it.db');
  await deleteDatabaseFileForTesting();
  final Database db = await getDatabase(); // runs onCreate + its demo seed
  await applySeed(db, seed);

  await tester.pumpWidget(buildToolery());
  await tester.pumpAndSettle();
  await _awaitFirstLoad(tester);
  await tester.pumpAndSettle();
}

/// Blocks until every notifier's first database load has landed.
///
/// Without this the harness hands back an app whose lists are still empty:
/// `pumpAndSettle` above only waits for scheduled *frames*, and a SQLite
/// query in flight schedules none, so it returns while the notifiers are
/// still loading. The tests that follow then tap or assert on seeded rows
/// that have not been rendered yet — and the load lands later, sometimes
/// after `tearDown` has closed the database, surfacing as a
/// `database_closed` error attributed to whatever test was running by then.
///
/// The timing is invisible on a developer machine and reliably lost on a CI
/// emulator, which is why this only ever failed in CI.
Future<void> _awaitFirstLoad(WidgetTester tester) async {
  final BuildContext context = tester.element(find.byType(Main));
  await Future.wait(<Future<void>>[
    Provider.of<TaskNotifier>(context, listen: false).loaded,
    Provider.of<TagNotifier>(context, listen: false).loaded,
    Provider.of<BreathingNotifier>(context, listen: false).loaded,
    Provider.of<AffirmationNotifier>(context, listen: false).loaded,
    Provider.of<JournalNotifier>(context, listen: false).loaded,
  ]).timeout(
    const Duration(seconds: 30),
    onTimeout: () => fail('Timed out waiting for the initial database load'),
  );
}

/// Registers the teardown every integration test file needs: closing and
/// forgetting the throwaway database so a leaked handle from one test can
/// never cascade into the next.
void registerAppHarnessTearDown() {
  tearDown(() async {
    await resetDatabaseForTesting();
  });
}
