import 'package:flutter/material.dart';
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

  Future<void> _showIntroDialogs(SettingsNotifier settings) async {
    if (!mounted) return;

    // Show Welcome
    if (!mounted) return;
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Welcome"),
          content: Text(
            "Welcome to toolery! This is your personal toolkit made by you, for you! Everything is stored locally on your device so it is as private as your phone is. There is no subscription, cost, ads, or collected user data for this app. I'm going to briefly explain everything so you can make the most of your toolbox!",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Tasks"),
          content: Text(
            "Tasks are meant to be things you can do when you need help. They can be a reminder, a journaling activity, a mindset. Whatever you think will help you in the moment!",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Neat!"),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Breathing Exercises"),
          content: Text(
            "Breathing exercises are exactly what they sound like! Guided breathing can be a great way to ground yourself. Make whatever helps you best!",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cool!"),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Tags"),
          content: Text(
            "Tags can be configured in the settings page. They are a way to label your tasks and breathing exercises so you can quickly find what you need! Like everything else, it is completely customizable",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Shiny!"),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("One Last Reminder"),
          content: Text(
            "While your toolbox is a great place to go to in moments of crisis, if you feel like you want to hurt yourself or someone else, please reach out to a local hotline or your nearest hospital. Some resources will be listed in the settings tab.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                settings.changeReturningUser(true);
              },
              child: Text("Understood"),
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
            if (!settings.returningUser && !_dialogsShown) {
              _dialogsShown = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showIntroDialogs(settings);
              });
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
              ],
            );
          },
        ),
      ),
    );
  }
}
