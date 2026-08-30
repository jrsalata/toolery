# Integration Testing Guide

This project uses Flutter integration tests that run against a real app on an emulator, not just widget tests. This brings real-world fidelity but also timing challenges specific to emulators. This guide explains the patterns and pitfalls.

## The Core Problem: CI Emulator Timing

The CI emulator is **much slower** than a developer machine. Two issues arise:

### 1. Screens That Never Settle

Some screens schedule frames continuously and never reach a quiescent state. Example: the breathing exercise screen keeps a `Timer.periodic` running for the exercise's duration.

**Wrong:** `await tester.pumpAndSettle()` will either timeout or block until the exercise finishes.

**Right:** Use `pumpUntilCondition()` with a specific condition (e.g., "exercise is complete"), then settle.

### 2. Screens Waiting on Database Queries

The notifiers load data from SQLite off the main frame. `pumpAndSettle` only waits for **scheduled frames**, not for database queries in flight.

**Wrong:**
```dart
await tester.tap(find.byTooltip('Create'));
await tester.pumpAndSettle();
expect(find.text('New item appears here'), findsOneWidget); // ❌ List still empty on CI
```

The query may still be loading. On a fast dev machine, it lands before the next test step; on CI, it doesn't.

**Right:**
```dart
await tester.tap(find.byTooltip('Create'));
await pumpUntil(tester, find.text('New item appears here')); // ✅ Waits for actual data
```

## Pump Helpers

All helpers are in [integration_test/helpers/finders.dart](integration_test/helpers/finders.dart).

### `pumpAndSettle()` (Flutter built-in)

Pumps frames until none are scheduled. Good for synchronous UI updates.

**Use when:** Tapping a button that shows a dialog, changing a tab, dismissing a snackbar.

**Avoid when:** Waiting on database queries, or the screen has ongoing animations.

### `pumpUntilCondition(tester, condition, description, timeout)`

Pumps small fixed frames and re-checks a condition after each one. Waits exactly as long as needed—no more, no less.

**Use when:** You need to wait for something specific, whether it's data loading or a visual condition.

```dart
await pumpUntilCondition(
  tester,
  () => find.text('Loaded data').evaluate().isNotEmpty,
  'data to load',
  timeout: const Duration(seconds: 30),
);
```

### `pumpUntil(tester, finder, timeout)`

Shorthand: pumps until `finder` matches at least one widget. Common case of `pumpUntilCondition`.

```dart
await pumpUntil(tester, find.text('Task saved'));
```

### `pumpUntilSaved(tester, editor, timeout)`

Pumps until the `Save` button (or custom `editor` widget) disappears, then settles.

The editor only closes after the database write completes and the reload finishes, so this is the signal that save is done. Do **not** wait on the saved text instead — the text is already on screen in the field, so the finder matches immediately and waits for nothing.

```dart
await tester.tap(find.byTooltip('Create'));
await tester.pumpAndSettle();
await tester.tap(quillTitle());
await tester.enterText(quillTitle(), 'New entry');
await tester.tap(find.byTooltip('Save'));
await pumpUntilSaved(tester); // ✅ Waits for the write and reload
```

### `pumpUntilGone(tester, finder, timeout)`

Pumps until `finder` matches nothing. Counterpart to `pumpUntil`, for asserting deletes landed.

```dart
await tester.tap(find.byTooltip('Delete'));
await tester.tap(find.text('Confirm delete'));
await pumpUntilGone(tester, find.text('Item to delete'));
```

### `pumpUntilQuillBodyContains(tester, text, timeout)`

Pumps until the Quill body's `EditableText` controller actually contains `text`.

**Why it exists:** `tester.enterText()` on the Quill body goes through the real text input pipeline, not a plain controller assignment. On a slow CI emulator, the edit can be in flight when the next step fires. Waiting for the text to actually arrive prevents the next step from running before the guard has seen the change.

See [Quill Editor Specifics](#quill-editor-specifics) below.

```dart
await tester.tap(quillBody());
await tester.enterText(quillBody(), 'Draft text');
await pumpUntilQuillBodyContains(tester, 'Draft text');
await tester.pageBack();
await tester.pumpAndSettle();
expect(find.text('Discard changes?'), findsOneWidget); // ✅ Guard saw the change
```

## Quill Editor Specifics

The Quill rich-text editor has some quirks in tests.

### Text Input Pipeline

`tester.enterText()` on a Quill editor goes through Flutter's real text input system, not a direct controller assignment. This means:

- The change is **asynchronous** — it lands in the next frame or later.
- On a fast dev machine, it lands before the next `await`, so tests pass.
- On CI, it's still in flight, so the next step can run before the editor sees it.

**Pattern:**

```dart
await tester.enterText(quillBody(), 'unsaved change');
// ❌ DON'T do this:
await tester.pumpAndSettle(); // May return before text arrives

// ✅ DO this:
await pumpUntilQuillBodyContains(tester, 'unsaved change');
```

### Addressing Quill Fields

Quill editors render as `EditableText` widgets. The convention in this project:

- **Title field:** `find.byType(EditableText).first`
- **Body field:** `find.byType(EditableText).last`

Helpers `quillTitle()` and `quillBody()` encapsulate this.

```dart
await tester.enterText(quillTitle(), 'Entry title');
await tester.enterText(quillBody(), 'Entry body');
```

This works because the form layout is consistent: title field first, body field last. If the layout changes (more EditableText fields added), update the helpers, not every test.

### Dirty State Detection

The `UnsavedChangesGuard` in [lib/widgets/unsaved_changes.dart](lib/widgets/unsaved_changes.dart) watches the Quill controller to detect changes. It calls `isDirty()` whenever the controller notifies.

On CI, if `pageBack()` fires before the controller notification lands, the guard sees a clean state and pops silently instead of prompting.

**Pattern:**

```dart
await tester.tap(quillBody());
await tester.enterText(quillBody(), 'unsaved change');
await pumpUntilQuillBodyContains(tester, 'unsaved change'); // Ensures guard sees it
await tester.pageBack();
await tester.pumpAndSettle();
expect(find.text('Discard changes?'), findsOneWidget);
```

## Common Pitfalls

### Pitfall 1: `pumpAndSettle` After Database Writes

```dart
await tester.tap(find.byTooltip('Save'));
await tester.pumpAndSettle(); // ❌ Returns too early on CI
expect(find.text('New item'), findsOneWidget); // May fail
```

**Fix:** Wait for the save to complete:

```dart
await tester.tap(find.byTooltip('Save'));
await pumpUntilSaved(tester); // ✅ Waits for write and reload
expect(find.text('New item'), findsOneWidget);
```

### Pitfall 2: Asserting on Text Before It Loads

```dart
await launchApp(tester);
await tester.pumpAndSettle();
expect(find.text('Seeded task'), findsOneWidget); // ❌ May fail on CI
```

The seeded data loads asynchronously. `pumpAndSettle` returns before the load completes.

**Fix:** Use `pumpUntil`:

```dart
await launchApp(tester);
await pumpUntil(tester, find.text('Seeded task')); // ✅ Waits for load
expect(find.text('Seeded task'), findsOneWidget);
```

Note: `launchApp` already calls `_awaitFirstLoad` internally, but it's still good practice to wait before asserting on seeded data.

### Pitfall 3: Not Waiting for Quill Text Entry

```dart
await tester.enterText(quillBody(), 'unsaved');
await tester.pumpAndSettle();
await tester.pageBack(); // ❌ May pop before entry sees the change
```

**Fix:** Wait for the text to actually arrive:

```dart
await tester.enterText(quillBody(), 'unsaved');
await pumpUntilQuillBodyContains(tester, 'unsaved'); // ✅
await tester.pageBack();
```

### Pitfall 4: Waiting on Text That's Already on Screen

```dart
await tester.tap(find.byTooltip('Create'));
await tester.enterText(find.byType(TextField), 'New item');
// ❌ Don't do this:
await pumpUntil(tester, find.text('New item')); // Returns immediately
// The text is already on screen in the field!
```

This is a no-op. Only use `pumpUntil` for text that appears **after** a database operation (seeded data loading, a save completing) or a navigation (a new page opening).

For fields you just typed into, use `pumpAndSettle`.

### Pitfall 5: Awaiting Fields with Dialog Confirmation

```dart
await tester.tap(find.byTooltip('Delete'));
// ❌ Don't do this:
await pumpUntilGone(tester, find.text('Item')); // May return after dialog, before delete
```

The delete dialog is modal and appears before the actual delete. Waiting for the item to disappear waits for the entire flow.

**Better:** Wait for a specific step:

```dart
await tester.tap(find.byTooltip('Delete'));
await tester.pumpAndSettle(); // Dialog appears
await tester.tap(find.text('Confirm'));
await pumpUntilGone(tester, find.text('Item')); // ✅ Specific stage
```

## Test Organization

- **[integration_test/all_test.dart](integration_test/all_test.dart):** Main entry point, imports and runs all test groups.
- **[integration_test/*_test.dart](integration_test/):** Individual test suites (journal, tasks, tags, etc.).
- **[integration_test/helpers/](integration_test/helpers/):** Shared utilities:
  - `app_harness.dart`: App bootstrapping and database setup.
  - `finders.dart`: Pump helpers and custom finders.
  - `seed.dart`: Test data definitions.

## Running Tests Locally

Run all integration tests on a connected emulator or device:

```bash
flutter test integration_test/all_test.dart -d <device-id>
```

Run a single test file during development:

```bash
flutter test integration_test/journal_test.dart -d <device-id>
```

The emulator will be slower than your dev machine, but the timing should be closer to CI than running widget tests with `flutter test test/`.

## Adding a New Test

1. Create a new file `integration_test/foo_test.dart` (or add to an existing one).
2. Import [finders.dart](integration_test/helpers/finders.dart) for pump helpers.
3. Call `registerAppHarnessTearDown()` in your `group()` to clean up the database between tests.
4. Use `pumpUntil*` instead of `pumpAndSettle` after database operations or navigations.
5. For Quill editors, use `pumpUntilQuillBodyContains` after `enterText`.
6. Add your test group to [all_test.dart](integration_test/all_test.dart).

```dart
import 'helpers/app_harness.dart';
import 'helpers/finders.dart';

void fooTests() {
  registerAppHarnessTearDown();

  group('Foo CRUD', () {
    testWidgets('creates a foo', (tester) async {
      await launchApp(tester);
      await tester.tap(find.byTooltip('Create foo'));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), 'My foo');
      await tester.tap(find.byTooltip('Save'));
      await pumpUntilSaved(tester); // ✅ Wait for save
      
      await pumpUntil(tester, find.text('My foo')); // ✅ Wait for reload
      expect(find.text('My foo'), findsOneWidget);
    });
  });
}
```

## Further Reading

- [Flutter integration testing docs](https://docs.flutter.dev/testing/integration-tests)
- [WidgetTester API](https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html)
- Local references:
  - [app_harness.dart](integration_test/helpers/app_harness.dart) — Why timing matters
  - [finders.dart](integration_test/helpers/finders.dart) — Pump helper details
  - [unsaved_changes.dart](lib/widgets/unsaved_changes.dart) — How dirty state works
