import 'affirmation_test.dart' show affirmationTests;
import 'breathing_test.dart' show breathingTests;
import 'ios_specific_test.dart' show iosSpecificTests;
import 'journal_test.dart' show journalTests;
import 'navigation_test.dart' show navigationTests;
import 'settings_test.dart' show settingsTests;
import 'tag_test.dart' show tagTests;
import 'task_test.dart' show taskTests;
import 'welcome_test.dart' show welcomeTests;

/// Runs every integration test group in a single app process, so the suite
/// pays for one app launch instead of one per file. Each file above is also
/// independently runnable (`flutter test integration_test/<file> -d <id>`)
/// for fast iteration during development -- see README.md.
void main() {
  welcomeTests();
  navigationTests();
  taskTests();
  journalTests();
  breathingTests();
  affirmationTests();
  tagTests();
  settingsTests();
  iosSpecificTests();
}
