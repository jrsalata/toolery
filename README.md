# toolery
Toolery is an Android app created using Flutter that I created to act as a sort of toolbox for mental health. Its a place to write down various techniques, thought patterns, and reminders that help you when you need it most. It is a fairly simple app, but one that I created out of necessity for myself.

The overall design philosophy is to have most, if not all, of the content be user-customizable and local. This means that there are no accounts, no advertisements, and complete control over your toolbox. Users know what they need best and they should have full control over their tools.

If I can afford the Apple development program, it will also be on iOS as Flutter is a multi-platform tool.

Some features include:

- Custom guided breathing exercises
- Affirmations lists for reminders to yourself
- Detailed tasks to help you out
- Tags to organize tasks
- No data collection
- No account
- No ads

It is currently in a closed testing period. If you are interested, please email toolery@salata.software with the email address associated with your Google Play Account!

## Contributions

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for the build/run guide,
coding checks, and how releases are versioned.

### Testing

**Unit and Widget Tests**: Run the test suite with:

```bash
flutter test
```

**Integration Tests**: Full end-to-end tests drive the real app on a device or emulator. These test SQLite persistence, shared_preferences, tab navigation, and platform-specific UI (FABs vs. nav-bar actions on iOS).

**Android (emulator)**:

```bash
flutter devices  # find your emulator device ID
flutter test integration_test -d <device-id>
```

**iOS (simulator)**:

```bash
open -a Simulator
flutter devices  # find your simulator UDID
flutter test integration_test -d <UDID>
```

To run a specific test file:

```bash
flutter test integration_test/welcome_test.dart -d <device-id>
```

To wipe app state between runs:

```bash
# Android
adb shell pm clear software.salata.toolery.debug

# iOS
xcrun simctl uninstall booted software.salata.toolery
```

Integration tests live in `integration_test/` and cover ~48 scenarios: welcome dialogs, CRUD for all features (tasks, journal, breathing, affirmations, tags), settings, filtering, and iOS-specific chrome (Cupertino controls, back-swipe). The `ios_specific_test.dart` file is skipped on Android.

## License

Toolery's code is licensed under the [MIT License](LICENSE). The app icon and sound effects are
third-party work with their own terms — see the Credit section below.

## Accessibility

See the project accessibility review and recommendations in
[`docs/accessibility_review.md`](docs/accessibility_review.md).

## Credit

### App Icon

My good friend Morgan Roberts created the app icon. Highly recommend you check out their work at [imaginativeillustrator.com](https://www.imaginativeillustrator.com/)

### Sound Effects

All sound effects were from [Pixabay](https://pixabay.com/). Specifically

- [Block 1 by asmarttv2022](https://pixabay.com/sound-effects/musical-block-1-328874/)
- [Block 2 by asmarttv2022](https://pixabay.com/sound-effects/musical-block-2-328875/)
- [Drumstick by freesound_community](https://pixabay.com/sound-effects/film-special-effects-drumsticks-pro-mark-la-special-2bn-hickory-no4-103712/)
