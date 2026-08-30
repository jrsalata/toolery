import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:toolery/database/startdb.dart';
import 'package:toolery/main.dart';

import 'seed.dart';

// Every integration_test entrypoint needs this binding initialized exactly
// once; importing this helper file is enough to trigger it.
// ignore: unused_element
final IntegrationTestWidgetsFlutterBinding _binding =
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
}

/// Registers the teardown every integration test file needs: closing and
/// forgetting the throwaway database so a leaked handle from one test can
/// never cascade into the next.
void registerAppHarnessTearDown() {
  tearDown(() async {
    await resetDatabaseForTesting();
  });
}
