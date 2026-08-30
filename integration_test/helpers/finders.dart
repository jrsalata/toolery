import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Finds a switch whichever platform rendered it.
///
/// Copied from `test/helpers/finders.dart` — see its comment for why both
/// widget types are matched.
Finder findAdaptiveSwitch() =>
    find.byWidgetPredicate((w) => w is Switch || w is CupertinoSwitch);

/// Finds a tab by [label], scoped to the app's bottom tab bar.
///
/// `Tasks`, `Journal`, and `Breathing` each appear both as a tab label and as
/// page chrome (an AppBar title, a `WelcomePage` card) elsewhere on screen,
/// so a bare `find.text(label)` is ambiguous. Scoping to the [NavigationBar]
/// (Android) or [CupertinoTabBar] (iOS) disambiguates without needing a key
/// in `lib/`.
Finder findTab(String label) => find.descendant(
  of: find.byWidgetPredicate((w) => w is NavigationBar || w is CupertinoTabBar),
  matching: find.text(label),
);

/// The journal editor's title field: the first `EditableText` on the page.
///
/// See [quillBody] for why this pairing is the addressing convention.
Finder quillTitle() => find.byType(EditableText).first;

/// The journal editor's rich-text body: the last `EditableText` on the page.
///
/// Convention carried over from `test/unsaved_changes_test.dart`: "The Quill
/// body is the last EditableText on the page; the title field is the first."
Finder quillBody() => find.byType(EditableText).last;

/// Pumps real frames until [condition] holds, failing after [timeout].
///
/// Two situations make `pumpAndSettle` the wrong tool, and both need this:
///
/// 1. Screens that never settle. The breathing exercise screen keeps frames
///    scheduled for the exercise's whole duration (a 1-second
///    `Timer.periodic` in `ExerciseController._startPhase` plus an
///    `AnimatedContainer`), so `pumpAndSettle` either times out or blocks for
///    however long the exercise runs.
///
/// 2. Screens waiting on data. `pumpAndSettle` waits for scheduled *frames*,
///    but the notifiers do their SQLite work off-frame — a query in flight
///    schedules nothing. So `pumpAndSettle` happily reports "settled" on a
///    list that is still empty because its load has not come back yet. That
///    gap is invisible on a fast device and wide open on a CI emulator.
///
/// Pumping small fixed frames and re-checking after each one covers both: it
/// waits exactly as long as the device needs, and no longer.
Future<void> pumpUntilCondition(
  WidgetTester tester,
  bool Function() condition,
  String description, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final DateTime deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (condition()) return;
  }
  fail('Timed out waiting for: $description');
}

/// Pumps real frames until [finder] matches at least one widget.
///
/// Use instead of `pumpAndSettle` before asserting on (or tapping) anything
/// that arrives from the database. See [pumpUntilCondition].
Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) => pumpUntilCondition(
  tester,
  () => finder.evaluate().isNotEmpty,
  '$finder',
  timeout: timeout,
);

/// Waits for a save to land by watching the editor close, then settles.
///
/// The editor pops only after `_save()` has finished both its write and the
/// reload behind it, so the save affordance disappearing is the signal that
/// the database work is done.
///
/// Do NOT wait on the saved text instead: that text is already on screen in
/// the field it was just typed into, so the finder matches immediately and
/// waits for nothing — which is worse than `pumpAndSettle`, not better.
///
/// [editor] overrides what is watched for dialogs, which have no `Save`
/// tooltip — pass the field the dialog owns.
Future<void> pumpUntilSaved(
  WidgetTester tester, {
  Finder? editor,
  Duration timeout = const Duration(seconds: 20),
}) async {
  await pumpUntilGone(
    tester,
    editor ?? find.byTooltip('Save'),
    timeout: timeout,
  );
  await tester.pumpAndSettle();
}

/// Pumps real frames until [finder] matches nothing.
///
/// The disappearance counterpart to [pumpUntil], for asserting that a delete
/// actually landed rather than that its reload had not finished yet.
Future<void> pumpUntilGone(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) => pumpUntilCondition(
  tester,
  () => finder.evaluate().isEmpty,
  '$finder to disappear',
  timeout: timeout,
);
