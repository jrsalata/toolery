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

/// Polls for [finder] with real frames, for screens that never settle.
///
/// `pumpAndSettle` is unusable on the breathing exercise screen: a 1-second
/// `Timer.periodic` (see `ExerciseController._startPhase`) plus an
/// `AnimatedContainer` keep frames scheduled for the exercise's whole
/// duration, so it either times out or blocks for however long the exercise
/// runs. This pumps small, fixed frames instead and checks after each one.
Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final DateTime deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for: $finder');
}
