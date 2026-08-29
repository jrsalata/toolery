# Contributing

## Building and running

Requires the Flutter SDK (stable channel, `>=3.44.0`; developed against 3.47.2) with Dart
`>=3.12.0`.

```sh
flutter pub get      # install dependencies
flutter run           # run the app on a connected device/emulator
```

Before opening a PR, run the same checks CI runs:

```sh
dart format lib test                # auto-format
flutter analyze --fatal-infos       # static analysis
flutter test                        # unit/widget tests
```

A release build (signed, for Play upload) additionally requires an Android keystore:

1. Create `android/key.properties` (gitignored) pointing at your `.jks` keystore file.
2. Run `scripts/build_release.sh`, which fails fast if the keystore is missing rather than
   silently producing a debug-signed bundle, and stamps the build with a monotonic build number.

## Pull requests

Every PR runs the [CI workflow](.github/workflows/ci.yml): formatting, `flutter analyze`, and the
test suite. All three must pass before merging.

[Conventional Commits](https://www.conventionalcommits.org/) prefixes (`feat:`, `fix:`, `chore:`,
`docs:`, `refactor:`, `test:`, `ci:`, `style:`) are encouraged for commit messages/PR titles so the
history stays scannable, but — unlike some setups — nothing here parses them automatically.
Versioning is a separate, manual step described below.

## Releasing

Versioning is handled with [cider](https://pub.dev/packages/cider), which manages the `version:`
field in `pubspec.yaml` and the `CHANGELOG.md` together. Install it once:

```sh
dart pub global activate cider
```

**While working**, optionally log notable changes as you make them (this keeps the changelog
accurate without having to reconstruct it later):

```sh
cider log added "Support for custom breathing patterns"
cider log fixed "Crash when importing an empty export"
```

This appends to the `## Unreleased` section of `CHANGELOG.md`.

**To cut a release**, decide the bump per [semver](https://semver.org/): `patch` for fixes,
`minor` for backward-compatible features, `major` for breaking changes. Then:

```sh
cider bump minor      # or patch / major — updates pubspec.yaml
cider release         # moves "Unreleased" entries under a new dated version heading
```

Commit both files and open a PR as normal:

```sh
git add pubspec.yaml CHANGELOG.md
git commit -m "chore(release): $(cider version)"
```

Once merged to `main`, the [release workflow](.github/workflows/release.yml) notices the version
in `pubspec.yaml` changed, tags the commit `vX.Y.Z`, and publishes a GitHub Release using the
matching `CHANGELOG.md` section as its notes. It does not build or upload anything to Google
Play — that remains a manual step using `scripts/build_release.sh`.

**Toolery is currently pre-1.0 (`0.1.0`)** with no prior tags. The next release is intended to be
the first `cider bump major` up to `1.0.0`, marking the app's first tagged release; after that,
normal semver bumps apply.
