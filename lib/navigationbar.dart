import 'package:flutter/material.dart';

class TooleryNavigationBar extends StatefulWidget {
  const TooleryNavigationBar({super.key});

  @override
  State<TooleryNavigationBar> createState() => _TooleryNavigationBarState();
}

class _TooleryNavigationBarState extends State<TooleryNavigationBar> {
  int currentDestination = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: [
        NavigationDestination(icon: Icon(Icons.home), label: "Menu 1"),
        NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
      ],
      onDestinationSelected: (int index) {
        setState(() {
          currentDestination = index;
        });
      },
      selectedIndex: currentDestination,
    );
  }
}
