# iOS-adaptive UI for Toolery

> **Session handoff.** This plan was researched on the Linux machine; implementation moves to the Mac so the simulator is available throughout. Nothing has been implemented yet — the working tree is clean apart from two pre-existing Android edits (`android/app/build.gradle.kts`, `android/app/src/debug/AndroidManifest.xml`) on branch `39-devops-refinement` at `8473dfc`.
>
> First steps on the Mac: `flutter pub get`, then `flutter build ios --no-codesign` once to generate `ios/Podfile` (Phase 0), then work the phases in order. Gate each phase with `flutter analyze && dart format --set-exit-if-changed . && flutter test`.
>
> All findings below were verified against Flutter 3.47.2 / Dart 3.13.2 and the actual source — including that `.adaptive` constructors and `showAdaptiveDialog` exist, that iOS page transitions and back-swipe are already the default, and that `PopScope(canPop: false)` suppresses the swipe gesture entirely.

## Context

Toolery is a 61-file, ~7,000-line Flutter app that today is 100% Material with **zero platform branching** — no `Platform.isIOS`, no `defaultTargetPlatform`, no `cupertino.dart` import anywhere in `lib/`. The `ios/` folder exists and the app builds, but every screen renders Android chrome on an iPhone: M3 `NavigationBar` pills, floating action buttons, Material dialogs and switches, and a settings screen whose "Use System Theme Color?" toggle silently does nothing because `dynamic_color` is Android-only.

The goal is an app that feels native on iOS **without forking the UI**. We keep one Material widget tree and branch only at a handful of chokepoints, using Flutter's `.adaptive` constructors plus a small set of hand-written wrappers for the gaps where no `.adaptive` exists.

Three findings from exploration reshape the work:

1. **iOS page transitions and back-swipe already work.** `page_transitions_theme.dart:767` maps `TargetPlatform.iOS` to `CupertinoPageTransitionsBuilder` by default, and the interactive pop gesture lives inside it. All 15 `MaterialPageRoute` sites already get the iOS slide and swipe — no routing changes needed.
2. **Except on six screens, where we break it.** `UnsavedChangesGuard` uses `PopScope(canPop: false)` unconditionally, and `pop_scope.dart:50` documents that this means "no gesture will be detected at all." A dead edge-swipe reads as a frozen app. This is the single highest-value fix in the effort.
3. **A real iPad crash is hiding here.** `settings.dart:118` calls `SharePlus.share` with no `sharePositionOrigin`; on iPad the share sheet is a popover that requires a source rect. Data export is simply broken on iPad.

Scope decisions already made: adaptive-Material (not a CupertinoApp fork); SnackBars stay Material on both platforms; a Mac + simulator is available for verification.

---

## Priority stack

| # | Item | Cost | Why |
|---|---|---|---|
| 1 | Back-swipe fix | ~1h | The one thing that feels *broken*, not just Android |
| 2 | Remove stray `SafeArea` | 15m | Visibly wrong chrome on a notched device |
| 3 | iPad share crash, Podfile, deployment target | 1h | "Does it run" beats "does it look right" |
| 4 | `ThemeMode.system` | 1h | iOS users expect it |
| 5 | Free `.adaptive` swaps | 2h | Best look-per-line ratio in the codebase |
| 6 | Theme shaping | 3h | Fixes ~75 `Theme.of` sites without editing one |
| 7 | FAB → nav-bar action | 3h | Most obvious remaining Android tell |
| 8 | Overflow menu → action sheet | 2h | Polish |
| 9 | `AsyncPage` ladder collapse | 2h | Refactor that pays for itself |
| — | Nested per-tab navigators | 1–2d | **Defer** — see Phase 5 |
| — | flutter_quill Cupertino-ification | ∞ | **Don't** — see Phase 6 |

---

## Phase 0 — It runs and it doesn't crash

Files: `ios/Podfile` (new), `ios/Runner.xcodeproj/project.pbxproj`, `lib/settings.dart`, `pubspec.yaml`

- **Commit a Podfile.** None exists. `ios/.gitignore` ignores `Pods/` but not `Podfile`, so today the first person to build leaves a machine-specific artifact untracked-but-not-ignored. Generate once via `flutter build ios --no-codesign`, then commit.
- **Bump deployment target 13.0 → 15.0** — three sites in `project.pbxproj` (lines 349, 475, 526), `platform :ios, '15.0'` in the Podfile, and `MinimumOSVersion` in `ios/Flutter/AppFrameworkInfo.plist`. iOS 15 is where `UISheetPresentationController` detents and modern nav-bar scroll-edge appearance become reliable. Fall back to 14.0 only if a pod objects.
- **Info.plist: add nothing.** Audited — `file_picker` uses `UIDocumentPickerViewController` (no usage description), `share_plus` and `sound_effect` need no keys, `url_launcher` only opens `https`. An unused purpose string is an App Review liability; resist adding them speculatively.
- **Fix the iPad share crash** in `settings.dart:_exportData`:
  ```dart
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(ShareParams(
    files: [XFile(filePath)],
    subject: 'Toolery Data Export',
    sharePositionOrigin: box != null
        ? box.localToGlobal(Offset.zero) & box.size : null,
  ));
  ```
  Extracting the export `ListTile` into its own widget gives a better-anchored popover.
- **pubspec:** drop `flutter_colorpicker` (dead since `accessibility/color_picker_dialog.dart` replaced it). **Keep** `cupertino_icons` — Phase 4 needs it.

---

## Phase 1 — The back-swipe (highest value)

Files: `lib/widgets/unsaved_changes.dart`, its 6 call sites, plus `lib/forms/journal/{create,update}.dart`

Make `canPop` reactive so a **clean** editor keeps the iOS swipe and only a **dirty** one blocks it. `UnsavedChangesGuard` becomes stateful and takes a `watch` list of `Listenable`s:

```dart
const UnsavedChangesGuard({
  required this.isDirty,   // bool Function() — unchanged
  required this.watch,     // List<Listenable> — new
  required this.child,
});
```

State holds `late bool _dirty = widget.isDirty()`, subscribes via `Listenable.merge(widget.watch)`, re-evaluates on notify **and** in `didUpdateWidget`, and renders `PopScope(canPop: !_dirty, ...)`.

Two consequences worth noting:
- The `if (!isDirty()) Navigator.pop(...)` branch **disappears**. Clean screens pop natively — no manual re-pop, no `context.mounted` dance, and the return value flows normally instead of being re-synthesized.
- `watch` only ever needs the `TextEditingController`s. Tag and colour changes already trigger `setState` in all six call sites (e.g. `task/create.dart:80`), so `didUpdateWidget` picks them up for free.

Call sites each gain one argument — e.g. `task/create.dart:70` → `watch: [nameController, descriptionController, activityController]`.

**Then close a pre-existing gap:** `journal/create.dart` and `update.dart` have **no guard at all** — the app's richest editor silently discards work on back. Wrap them; dirtiness is `!listEquals(_quillController.document.toDelta().toJson(), _initialDelta)`, and `QuillController` is a `ChangeNotifier` so it drops straight into `watch:`.

**Accepted limitation** (document in the dartdoc): when dirty, `canPop: false` still kills the swipe rather than letting you swipe-then-confirm. Flutter 3.47 offers no way to intercept a completed Cupertino back gesture. Native iOS apps also disable interactive dismissal for dirty sheets, so this is the right trade — but it argues for being conservative about calling things dirty.

---

## Phase 2 — Insets

File: `lib/main.dart`

**Delete the `SafeArea` at `main.dart:148`.** Wrapping *outside* `Scaffold` means the Scaffold never sees the real view padding: the page's `AppBar` is pushed below the status bar instead of extending under it (leaving a bare strip across the notch), and `NavigationBar` gets double-padded above the home indicator. `Scaffold`, `AppBar`, and `NavigationBar` each consume `MediaQuery.viewPadding` correctly on their own. Remove it and add nothing.

The other two `SafeArea`s are correct and stay: `journal/form.dart:101` (`top: false`, docked toolbar) and `tag_action.dart:45` (inside the bottom sheet).

---

## Phase 3 — Theme: change ~75 call sites by editing none

Files: `lib/theme/app_theme.dart` (new), `lib/main.dart`, `lib/settings.dart`

The ~75 `Theme.of(context)` sites read `colorScheme` and `textTheme`. Reshape those per-platform and every site follows. Extract the inline block at `main.dart:70–93` into `buildAppTheme({required ColorScheme colorScheme, required TargetPlatform platform})`, returning the plain theme on Android and, on iOS, a `copyWith`:

- **`platform:` is the load-bearing line.** Setting `ThemeData.platform` drives typography selection, scrollbars, `Icons.adaptive`, and every `.adaptive` constructor. **Do not hand-roll an SF Pro `TextTheme`** — iOS system fonts can't be bundled, and Flutter already resolves them via the `CupertinoSystemText` aliases.
- **`appBarTheme`**: `centerTitle: true`, `elevation: 0`, `scrolledUnderElevation: 0`, transparent surface tint, and `shape: Border(bottom: BorderSide(color: outlineVariant, width: 0.5))` — the iOS hairline instead of M3's tonal scroll-under, which is a strong Android tell.
- **`cardTheme`**: elevation 0, `surfaceContainerLow`, 10pt radius. Combined with the existing `Card`+`ListTile` pattern in `settings.dart`, `breathing/settings.dart`, and `welcome_page.dart`, this is ~90% of `CupertinoListSection.insetGrouped` for zero structural change. **Don't migrate to `CupertinoListSection`** — it forks three files and breaks `find.widgetWithText(SwitchListTile, ...)`.
- **`inputDecorationTheme`**: `filled: true`, 10pt radius, `BorderSide.none`. **This replaces any `AdaptiveTextField`.** Prerequisite: delete the inline `border: OutlineInputBorder()` from all 13 `TextFormField`s (e.g. `task/form.dart:50`) — inline decoration overrides the theme. `CupertinoTextFormFieldRow` would cost the floating label, the validator wiring, and error styling for a marginal gain.
- **`dividerTheme`**: `space: 0.5, thickness: 0.5`.

**No `pageTransitionsTheme` needed** — the iOS default is already correct.

**`ThemeMode.system`.** `main.dart:94` never uses it. Migrate `SettingsNotifier` to a `ThemeMode themeMode` field with a one-time migration from the legacy `enableDarkMode` bool, keeping `bool get darkMode => themeMode == ThemeMode.dark` so nothing else breaks. The settings UI becomes three-way: `SegmentedButton` on Android, `CupertinoSlidingSegmentedControl` on iOS — one of the few places a genuine branch earns its keep.

**Fix the no-op iOS setting.** "Use System Theme Color?" (`settings.dart:194`) does nothing on iOS, since `lightDynamic`/`darkDynamic` are always null there. A no-op switch is worse than no switch. On iOS, relabel it "Use iOS accent colour" and back it with `CupertinoColors.systemBlue` as the seed — the pref stays live, the `if (!settings.materialTheme)` custom-colour tile still works, and `_buildSettingsApp(materialTheme:)` in `accessibility_test.dart:44` keeps testing a real branch.

**Also fold in:** delete `tag_action.dart:9`'s `tagLabelColor` and import `highContrastTextColor` from `accessibility/contrast.dart`. The two implementations genuinely disagree for mid-tones (naive luminance vs. WCAG ratio), so today the tag sheet and the filter row pick different text colours for the same colour on the same screen.

---

## Phase 4 — The adaptive widget layer

Four files, deliberately small:

```
lib/widgets/adaptive/
  platform.dart          # isCupertino(BuildContext)
  adaptive_scaffold.dart # AdaptivePage, AdaptiveTabShell
  adaptive_menu.dart     # AdaptiveOverflowMenu
  adaptive_controls.dart # AdaptiveSegmentedControl
```

**`isCupertino`** reads `Theme.of(context).platform` — never `Platform.isIOS` or `defaultTargetPlatform`. Only this form respects `ThemeData(platform:)`, which is how Phase 7 writes iOS tests without a leaking global override.

**`AdaptivePage`** — the FAB answer and the app-bar answer in one widget. iOS has no FAB idiom; the native equivalent of "create a new thing" is a `+` in the nav bar's trailing slot. All six FABs are `FloatingActionButton.extended` with `Icons.add` + a label, so they map cleanly. It takes `title`, `body`, `actions`, and an `AdaptivePrimaryAction? primaryAction` (`label`, `tooltip`, `icon`, `onPressed`), rendering the FAB on Android and a trailing `IconButton` on iOS.

Make `tooltip` **required** — it forces `affirmation/detail.dart:120` to gain the tooltip it's currently missing, and it means `find.byTooltip('Create task')` keeps passing on *both* platforms because the tooltip travels with the action regardless of which widget renders it. That is what keeps Phase 7 cheap.

**Which of the 24 Scaffolds actually change:**
- **6 structurally** → `AdaptivePage`: the six with FABs — `task/main.dart`, `tag/main.dart`, `breathing/main.dart` (also passes its settings `IconButton` through `actions:`), `journal/main.dart`, `affirmation/main.dart`, `affirmation/detail.dart`.
- **1** → `main.dart`'s tab shell.
- **16** → via the `AsyncPage` refactor in Phase 5 (not iOS-specific).
- **7 editor screens: no change.** They route through `EditorAppBar`; edit that one file and all seven follow.
- **`settings.dart`, `breathing/settings.dart`, `welcome_page.dart`: no change.** Plain `Scaffold` + `AppBar` under the Phase-3 theme already looks right.

**`AdaptiveTabShell`** — the M3 `NavigationBar` selection pill is the loudest remaining Android tell, and there is no `NavigationBar.adaptive`. Swap in `CupertinoTabBar` as the `bottomNavigationBar` on iOS. It works fine inside a plain `Scaffold`; **`CupertinoTabScaffold` is not needed**, and using the bare tab bar is exactly what lets us keep one Scaffold and defer the nested-navigator question. Pass `activeColor` from `colorScheme.primary`. Map the five icons: `home`/`menu_book`/`task_alt_rounded`/`air`/`settings` → `CupertinoIcons.house`/`book`/`checkmark_circle`/`wind`/`settings`. These five are the only icons worth mapping out of ~35.

**`AdaptiveOverflowMenu`** — the four `PopupMenuButton`s (`editor_app_bar.dart` + three `view.dart`) each hold exactly one Delete item. On iOS render an `ellipsis` `IconButton` opening a `CupertinoActionSheet` with `isDestructiveAction: true` and a cancel button. **Dismiss before acting** (`Navigator.pop(ctx)` then `onPressed()`) — the current `PopupMenuItem(onTap:)` relies on the menu self-dismissing, and `task/view.dart:_delete` then shows a dialog.

### Phase 4b — the free `.adaptive` swaps (one mechanical pass)

- `showDialog` → `showAdaptiveDialog` (8 sites); `AlertDialog` → `AlertDialog.adaptive` (9 sites). Covers `confirm_dialog.dart`, the 5 intro dialogs in `welcome_page.dart`, `color_picker_dialog.dart`, and `_AffirmationItemDialog`. `AlertDialog.adaptive` maps its `actions` to `CupertinoDialogAction`s automatically.
  - **One gotcha:** `confirm_dialog.dart` styles its confirm button via `ButtonStyle(foregroundColor: ...error)`, which Cupertino ignores. This one dialog needs a hand-written branch to `CupertinoDialogAction(isDestructiveAction: true)`. The other eight take `.adaptive` as-is.
- `showAboutDialog` (`settings.dart:267`) → `showAdaptiveAboutDialog`.
- `SwitchListTile` → `.adaptive` (`settings.dart:185,194`); the 3 bare `Switch` in `breathing/settings.dart:22,33,44` → `Switch.adaptive`.
- `CircularProgressIndicator` → `.adaptive` (4 sites). Disproportionately noticeable — the Material spinner on every `FutureBuilder` load is a constant Android signal.
- `Icons.more_vert` (`settings.dart:213`) → `Icons.adaptive.more`.

### Explicitly **not** building

- **`AdaptiveButton`** — most of the 9 `TextButton`s are dialog actions that `AlertDialog.adaptive` already converts. The rest look fine as `FilledButton` under the Phase-3 theme.
- **`showAdaptiveSheet`** — one call site (`tag_action.dart:35`). Since iOS 15, `showModalBottomSheet(showDragHandle: true, useSafeArea: true)` *is* visually the native sheet. Add two arguments and move on.
- **`AdaptiveTextField`** — covered by `inputDecorationTheme`.
- **`AdaptiveAppBar`** — `AppBar` + `appBarTheme` + `centerTitle` gets there; Flutter already substitutes the Cupertino back chevron when `platform` is iOS.

---

## Phase 5 — Structure and polish

**Collapse the 4-Scaffold ladder.** `task/view.dart`, `journal/view.dart`, `breathing/view.dart`, and `breathingExercises/exercise.dart` each repeat loading/error/not-found/loaded. Extract `AsyncPage<T>` taking `future`, `fallbackTitle`, `builder`, and an `isMissing` hook (`exercise.dart` signals not-found via `id == -1`; `task/view.dart` via `data == null`). Not iOS work, but it's the difference between changing chrome in 1 place vs. 16. It also fixes real jank: the loading state currently renders a Scaffold with **no AppBar** (`task/view.dart:44`), so iOS shows a title-less screen that then pops a nav bar into existence. `AsyncPage` should show the app bar in every state.

**Haptics.** `controller.dart:214,257` uses `HapticFeedback.vibrate()`, which on iOS is a coarse, deprecated-feeling buzz. Use `.lightImpact()` for inhale/exhale and `.mediumImpact()` for hold boundaries on iOS. Branch on `defaultTargetPlatform` inside the controller (it has no `BuildContext`) — this is genuinely platform-specific *behaviour*, not styling. A breathing app is exactly where haptic quality is felt.

**Dynamic Type.** iOS users change system text size far more than Android users, and it's the fastest way to break a layout. Don't clamp globally — that's an accessibility regression. Instead test at 200% text scale in the simulator and fix the overflows: the likely casualties are `breathing/settings.dart`'s `ListTile(trailing: Switch)` rows and the `Card`+`ListTile` stacks in `welcome_page.dart`. Hardcoded sizes to watch: `welcome_page.dart` (`Icon(size: 32)` ×4), `task/list.dart` (`size: 72` empty states), `visualizer.dart:46`. For icons that shouldn't scale, `MediaQuery.withNoTextScaling` on the icon subtree is the surgical tool.

**Nested per-tab navigators — defer, probably permanently.** iOS HIG says pushed content stays within its tab. But: `welcome_page.dart` pushes `TaskPage`, `BreathingPage`, `AffirmationPage`, and `JournalPage` as *routes* — the same widgets that are also tab bodies. Nested navigators would push one tab's page inside another tab's navigator, forcing those four cards to become tab-switch calls and changing the app's information architecture. Add the 15 `Navigator.push<bool>` return values, a new Android back layer, and tap-tab-to-pop-to-root, and it's 1–2 days plus a full re-test to fix something most users won't consciously notice. **Ship Phases 0–4 to the simulator and decide by feel.** If you do it later, the entry point is replacing `AdaptiveTabShell`'s body with an `IndexedStack` of five `Navigator`s — that seam is the real reason to build the shell abstraction now.

---

## Phase 6 — flutter_quill: what to accept

`flutter_quill 11.5.1` is hard-Material (`QuillSimpleToolbar` builds `IconButton`s and `DropdownButton`s) with no Cupertino counterpart. Achievable, in value order:

1. **`AdaptiveTextSelectionToolbar`** — the highest-value fix and the smallest. Selection handles and the copy/paste toolbar are the most-touched, most-obviously-wrong part of a text editor. `QuillEditorConfig` exposes `contextMenuBuilder` (verified at `editor_config.dart:436`); point it at `AdaptiveTextSelectionToolbar.editableText` and Flutter renders the iOS bubble and handles.
2. Theme the docked toolbar via `IconButtonThemeData`. `_toolbarConfig` (`journal/form.dart:45`) already trims to ~10 buttons, which helps.
3. **Verify keyboard handling** — the docked toolbar at `journal/form.dart:101` must sit above the iOS keyboard including the accessory bar. This is where it will actually be broken; test it.

Accept that toolbar buttons look Material-ish. It's one screen.

---

## Phase 7 — Tests and CI

**Nothing in the current suite breaks.** Widget tests default to `TargetPlatform.android`, so `find.byType(Switch)` at `accessibility_test.dart:150` still passes under `SwitchListTile.adaptive`. The work is *adding* iOS coverage, not repairing.

- Parameterize the three harnesses — `widget_test.dart:38`, `accessibility_test.dart:41` and `:66` — with `{TargetPlatform platform = TargetPlatform.android}`, passing it into `buildAppTheme`. Default keeps every existing assertion byte-identical. **Prefer this over `debugDefaultTargetPlatformOverride`**: no `addTearDown` reset, no leaking between tests.
- Add `test/helpers/finders.dart` with `findAdaptiveSwitch()` — `find.byWidgetPredicate((w) => w is Switch || w is CupertinoSwitch)` — for the new iOS group.
- The tooltip assertions (`accessibility_test.dart:111,119–120,128,136`) are the safety net for the FAB→nav-bar swap. Add iOS variants.

**New tests worth writing:**
1. `unsaved_changes_test.dart` — clean guard reports `canPop == true`; typing into a watched controller flips it to `false` without a parent rebuild; back tap shows the discard dialog. Platform-independent; guards Phase 1.
2. iOS smoke: pump the 6 `AdaptivePage` screens at `TargetPlatform.iOS`, assert `findsNothing` for `FloatingActionButton` and `findsOneWidget` for each tooltip.
3. `themeMode` migration: legacy `enableDarkMode: true` → `ThemeMode.dark`; absent → `ThemeMode.system`.

**Goldens: no.** Two platforms × light/dark × a seeded dynamic scheme is a maintenance tax paid on every padding nudge, and a simulator does the job goldens approximate.

**CI** — add a macOS *build* job to `.github/workflows/ci.yml` (keep `flutter test` on ubuntu):
```yaml
ios-build:
  runs-on: macos-latest
  steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
      with: { channel: stable, flutter-version: 3.47.2, cache: true }
    - run: flutter pub get
    - run: flutter build ios --no-codesign --simulator
```
`--no-codesign` avoids certs. Catches what ubuntu can't: a pod that won't resolve at the deployment target, a plist key that breaks the build, a plugin that lost iOS support. macOS runners bill at 10×, so gate to `pull_request` or to changes touching `ios/**` and `pubspec.yaml`.

---

## Verification

Run `flutter analyze && dart format --set-exit-if-changed . && flutter test` after every phase — `analysis_options.yaml` enforces `prefer_const_constructors`, `require_trailing_commas`, `unawaited_futures`, and `directives_ordering`, and CI gates on all three.

On the simulator (`flutter run -d <iphone>`), phase by phase:

1. **Phase 0** — app launches; export on an **iPad** simulator opens the share popover without crashing; import round-trips a ZIP.
2. **Phase 1** — in each of task/tag/breathing create+update and both journal editors: edge-swipe on a clean form pops; type one character, then swipe is inert and the back chevron shows the discard sheet; Discard leaves, Cancel stays.
3. **Phase 2** — status bar and home indicator: app bar extends under the notch, tab bar sits flush above the indicator, no bare strips.
4. **Phase 3** — toggle Light/Dark/System in settings and flip the simulator's appearance (⌘⇧A); the app follows in System mode. Confirm text fields are filled and hairless, cards are flat and grouped, app bar has a hairline and centred title.
5. **Phase 4** — the 6 list screens show a `+` in the nav bar and **no FAB**; delete via the overflow opens a Cupertino action sheet with a red Delete; every dialog renders Cupertino-style; switches and spinners are iOS.
6. **Phase 5** — Settings → Accessibility → Larger Text at max; walk every screen looking for overflow. Run a breathing exercise and confirm phase haptics feel like taps, not buzzes.
7. **Phase 6** — long-press in the journal editor: iOS selection handles and bubble toolbar; the docked toolbar clears the keyboard accessory bar.

Then run the same pass on an Android emulator to confirm nothing regressed — every phase must leave Android byte-identical except the intentional `ThemeMode` three-way and the shared `highContrastTextColor`.
