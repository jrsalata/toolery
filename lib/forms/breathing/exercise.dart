import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolery/models/breathing.dart';
import 'package:toolery/notifiers/breathing.dart';

class ExerciseView extends StatefulWidget {
  final int breathingID;

  const ExerciseView({super.key, required this.breathingID});

  @override
  State<ExerciseView> createState() => _ExerciseViewState();
}

class _ExerciseViewState extends State<ExerciseView> {
  late int breathingID;

  @override
  void initState() {
    super.initState();
    breathingID = widget.breathingID;
  }

  @override
  Widget build(BuildContext context) {
    final breathingNotifier = context.watch<BreathingNotifier>();
    return FutureBuilder<Breathing>(
      future: breathingNotifier.getById(breathingID),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final Breathing? breathing = snapshot.data;
        if (breathing == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Breathing')),
            body: const Center(child: Text('Breathing Exercise not found')),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text("Breathing Exercise Test")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [CircleAvatar(radius: 100)]),
          ),
        );
      },
    );
  }
}
