# Accessibility Review and Best Practices

This review covers the main Toolery UI sections: Welcome, Tasks, Breathing Exercises, Affirmations, and Settings.

## Summary of observed risks

1. **Screen reader naming risk for icon-only controls**
   - `lib/forms/breathing/main.dart` had an icon-only settings button with no explicit tooltip.
2. **Inconsistent text contrast for custom tag colors**
   - `lib/forms/task/list.dart` and `lib/forms/breathing/list.dart` used a luminance cutoff that can pick lower-contrast text on mid-tone colors.
3. **Settings toggle discoverability for assistive technology**
   - `lib/settings.dart` switch controls did not expose explicit semantic labels tied to the user-facing setting names.

## Changes implemented in this issue

### 1) Explicit labels for primary actions

- Added tooltips for key actions:
  - `TaskPage` FAB: **Create task**
  - `BreathingPage` settings icon: **Breathing settings**
  - `BreathingPage` FAB: **Create breathing exercise**
  - `AffirmationPage` FAB: **Create affirmation list**

These labels improve discoverability for screen readers and long-press hints for touch users.

### 2) WCAG-aligned color contrast selection for tag chips

- Added `lib/accessibility/contrast.dart` with a reusable contrast-ratio helper.
- Updated task/breathing tag chips to pick either black or white text/checkmark based on the **higher contrast ratio** against the chip background.

This is stronger than a fixed luminance threshold and better aligns with WCAG contrast intent for dynamic colors.

### 3) Semantic labels for settings toggles

- Added semantic labels on settings switches:
  - **Enable dark mode**
  - **Use system theme color**

This improves switch context when navigating by screen reader controls.

## Accessibility testing strategy added

New non-functional tests were added in `test/accessibility_test.dart`:

- Verifies presence of tooltip labels for main action controls in:
  - Tasks
  - Breathing
  - Affirmations
- Verifies semantic labels exist for Settings switches.
- Verifies contrast helper behavior for representative background colors.

## Best practices for this project going forward

1. **Always label icon-only actions**
   - Add `tooltip` and/or semantic labels to `IconButton`, FABs, and custom gesture targets.
2. **Use contrast-ratio-based foreground selection for user-defined colors**
   - Reuse `highContrastTextColor` when rendering text/icons over configurable colors.
3. **Prefer semantic context for toggles and filters**
   - For switches/chips/sliders, ensure assistive technologies can announce purpose + state.
4. **Keep non-functional accessibility tests close to feature pages**
   - Continue adding page-set tests under `test/` whenever new controls are introduced.
5. **Preserve readable copy and tap targets**
   - Keep action labels descriptive and avoid relying only on icon shape/color.
