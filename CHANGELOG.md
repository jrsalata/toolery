# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Entries are managed with [cider](https://pub.dev/packages/cider) — see
[CONTRIBUTING.md](CONTRIBUTING.md) for the release process.

## Unreleased

## [0.2.0] - 2026-08-30

### Added

- iOS adaptive widget layer with per-platform theming and `ThemeMode.system`.
- Podfile and raised iOS deployment target.
- Integration test suite covering tasks, breathing, journal, and affirmations.
- CI: format/analyze/test gate, android-emulator and macOS build jobs, and
  this release workflow.
- Data import/export from the settings page.
- Journal feature with rich text editing (flutter_quill).

### Changed

- Extracted tags into a reusable `TagAction`/`TagFilterChips` component,
  shared by task, breathing, and journal forms.
- Swapped FABs for nav-bar actions on iOS/macOS.
- Collapsed the async-page loading ladder; tuned haptics; fixed text-scale
  overflow.

### Fixed

- Journal tag colors now render correctly.
- Back-swipe restored on clean editors; journal navigation guarded.
- iPad share-sheet crash.
- Debug/release build naming.
