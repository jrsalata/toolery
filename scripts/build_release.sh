#!/usr/bin/env bash
# Builds a signed release Android App Bundle with an explicit, monotonic
# build number.
#
# Why this exists: pubspec.yaml's `version:` intentionally carries no `+N`
# build-number suffix (see CONTRIBUTING.md) -- without one, Gradle falls
# back to versionCode 1 for every build, and Google Play rejects the second
# upload as a duplicate. This script supplies the build number at build
# time instead.
#
# Build number source: $GITHUB_RUN_NUMBER if set (for a future CI build
# job), otherwise the total commit count on HEAD. These two are NOT
# interchangeable -- the commit count is already well past 1, so if a CI
# build job is added later using GITHUB_RUN_NUMBER starting from a low
# number, versionCode would regress and Play would reject the upload.
# Either seed the run number past the current commit count, or standardize
# on one source in both places.
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f "android/key.properties" ]; then
  echo "error: android/key.properties not found." >&2
  echo "Without it, Gradle silently falls back to debug signing for a" >&2
  echo "'release' build -- refusing to produce an unsigned bundle by accident." >&2
  echo "See CONTRIBUTING.md for keystore setup." >&2
  exit 1
fi

BUILD_NUMBER="${GITHUB_RUN_NUMBER:-$(git rev-list --count HEAD)}"

echo "Building release AAB with build number $BUILD_NUMBER..."
flutter build appbundle --release --build-number="$BUILD_NUMBER"
