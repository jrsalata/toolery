import 'package:flutter/cupertino.dart' show CupertinoTabBar;
import 'package:flutter/material.dart';
import 'package:toolery/widgets/adaptive/platform.dart';

/// The screen's "create a new thing" action.
///
/// [tooltip] is required, not optional: it is the one label that survives the
/// platform swap, so `find.byTooltip(...)` keeps working whether the action
/// renders as a floating action button or a nav-bar icon.
class AdaptivePrimaryAction {
  const AdaptivePrimaryAction({
    required this.label,
    required this.tooltip,
    required this.onPressed,
    this.icon = Icons.add,
  });

  /// Shown beside the icon on Android's extended FAB. iOS shows icon only.
  final String label;
  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;
}

/// A list screen with an app bar and an optional primary action.
///
/// Android renders the primary action as an extended [FloatingActionButton];
/// iOS, which has no FAB idiom, renders it as a trailing app-bar button — the
/// native equivalent of "new item".
class AdaptivePage extends StatelessWidget {
  const AdaptivePage({
    super.key,
    required this.title,
    required this.body,
    this.actions = const <Widget>[],
    this.actionsPadding,
    this.primaryAction,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final EdgeInsetsGeometry? actionsPadding;
  final AdaptivePrimaryAction? primaryAction;

  @override
  Widget build(BuildContext context) {
    final cupertino = isCupertino(context);
    final action = primaryAction;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actionsPadding: actionsPadding,
        actions: [
          ...actions,
          if (cupertino && action != null)
            IconButton(
              icon: Icon(action.icon),
              tooltip: action.tooltip,
              onPressed: action.onPressed,
            ),
        ],
      ),
      body: body,
      floatingActionButton: (!cupertino && action != null)
          ? FloatingActionButton.extended(
              tooltip: action.tooltip,
              onPressed: action.onPressed,
              icon: Icon(action.icon),
              label: Text(action.label),
            )
          : null,
    );
  }
}

/// One tab in [AdaptiveTabShell].
class AdaptiveTabDestination {
  const AdaptiveTabDestination({
    required this.label,
    required this.icon,
    required this.cupertinoIcon,
  });

  final String label;
  final IconData icon;
  final IconData cupertinoIcon;
}

/// The app's bottom tab bar.
///
/// The Material 3 [NavigationBar]'s selection pill is the loudest remaining
/// Android tell and has no `.adaptive` constructor, so iOS gets a
/// [CupertinoTabBar] instead. The bare tab bar works fine inside a plain
/// [Scaffold]; `CupertinoTabScaffold` is deliberately not used, which is what
/// keeps this to one Scaffold and leaves the nested-navigator question open.
class AdaptiveTabShell extends StatelessWidget {
  const AdaptiveTabShell({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
  });

  final List<AdaptiveTabDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: isCupertino(context)
          ? CupertinoTabBar(
              currentIndex: selectedIndex,
              onTap: onDestinationSelected,
              activeColor: Theme.of(context).colorScheme.primary,
              items: [
                for (final destination in destinations)
                  BottomNavigationBarItem(
                    icon: Icon(destination.cupertinoIcon),
                    label: destination.label,
                  ),
              ],
            )
          : NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: [
                for (final destination in destinations)
                  NavigationDestination(
                    icon: Icon(destination.icon),
                    label: destination.label,
                  ),
              ],
            ),
    );
  }
}
