import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:toolery/forms/affirmation/main.dart';
import 'package:toolery/forms/breathing/main.dart';
import 'package:toolery/forms/journal/main.dart';
import 'package:toolery/forms/task/main.dart';
import 'package:toolery/settings.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _dialogsShown = false;
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> _showIntroDialogs(SettingsNotifier settings) async {
    // Show Welcome
    if (!mounted) return;
    await showAdaptiveDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: const Text('Welcome'),
          content: const Text(
            "Welcome to toolery! This is your personal toolkit made by you, for you! Everything is stored locally on your device so it is as private as your phone is. There is no subscription, cost, ads, or collected user data for this app. I'm going to briefly explain everything so you can make the most of your toolbox!",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    await showAdaptiveDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: const Text('Tasks'),
          content: const Text(
            'Tasks are meant to be things you can do when you need help. They can be a reminder, a journaling activity, a mindset. Whatever you think will help you in the moment!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Neat!'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    await showAdaptiveDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: const Text('Breathing Exercises'),
          content: const Text(
            'Breathing exercises are exactly what they sound like! Guided breathing can be a great way to ground yourself. Make whatever helps you best!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cool!'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    await showAdaptiveDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: const Text('Tags'),
          content: const Text(
            'Tags can be configured in the settings page. They are a way to label your tasks and breathing exercises so you can quickly find what you need! Like everything else, it is completely customizable',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Shiny!'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    await showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: const Text('One Last Reminder'),
          content: const Text(
            'While your toolbox is a great place to go to in moments of crisis, if you feel like you want to hurt yourself or someone else, please reach out to a local hotline or your nearest hospital. Some resources will be listed in the settings tab.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                settings.changeReturningUser(true);
              },
              child: const Text('Understood'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUpdateDialog(
    SettingsNotifier settings,
    String version,
  ) async {
    if (!mounted) return;
    await showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: Text('New v$version update!'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "It's been a while since I've worked on this project, but I'm excited to release a major update! New features include:",
              ),
              SizedBox(height: 12),
              Text('• Journaling! Create your own journal entries.'),
              Text('• UI improvements. Overall cleaner and more intuitive.'),
              Text(
                '• Import/Export data. Useful to own your data or make custom sheets',
              ),
              Text('• Lots of behind-the-scenes changes.'),
              SizedBox(height: 12),
              Text(
                'As always, please let me know what you think at toolery@salata.software!\nStay curious :)',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                settings.changeLastSeenChangelogVersion(version);
              },
              child: const Text('Great!'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Toolery!')),
      body: Center(
        child: Consumer<SettingsNotifier>(
          builder: (context, settings, child) {
            final version = _packageInfo?.version;
            if (version != null && !settings.returningUser && !_dialogsShown) {
              _dialogsShown = true;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await _showIntroDialogs(settings);
                await _showUpdateDialog(settings, version);
              });
            } else if (version != null &&
                settings.lastSeenChangelogVersion != version &&
                !_dialogsShown) {
              _dialogsShown = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showUpdateDialog(settings, version);
              });
            }
            // A ListView, not a Column: at large system text sizes the four
            // cards are taller than the screen, and a Column would overflow
            // rather than scroll.
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.menu_book, size: 32),
                      title: const Text('Journal'),
                      subtitle: const Text(
                        'Write and reflect on your thoughts and feelings',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const JournalPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.task_alt, size: 32),
                      title: const Text('Tasks'),
                      subtitle: const Text(
                        'Activities and prompts that help you the most',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute(builder: (_) => const TaskPage()),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.air, size: 32),
                      title: const Text('Breathing Exercises'),
                      subtitle: const Text(
                        'Guided breathing exercises to help calm and ground yourself',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BreathingPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.self_improvement, size: 32),
                      title: const Text('Affirmations'),
                      subtitle: const Text('Important reminders in the moment'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AffirmationPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
