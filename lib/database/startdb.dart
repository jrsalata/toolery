import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database? _database;
Future<Database>? _databaseFuture;

Future<Database> getDatabase() async {
  // Return cached database if already initialized
  if (_database != null) {
    return _database!;
  }

  // If initialization is in progress, wait for it to complete
  if (_databaseFuture != null) {
    return _databaseFuture!;
  }

  // Start initialization and cache the future
  _databaseFuture = _initDatabase();
  _database = await _databaseFuture!;
  return _database!;
}

Future<Database> _initDatabase() async {
  WidgetsFlutterBinding.ensureInitialized();

  return openDatabase(
    join(await getDatabasesPath(), 'toolery.db'),
    onCreate: (db, version) async {
      await db.execute(
        'CREATE TABLE task (id INTEGER PRIMARY KEY, name TEXT, description TEXT, task TEXT )',
      );
      await db.execute(
        'CREATE TABLE tag (id INTEGER PRIMARY KEY, name TEXT, color INTEGER)',
      );
      await db.execute(
        'CREATE TABLE breathing (id INTEGER PRIMARY KEY, name TEXT, countIn INTEGER, holdIn INTEGER, countOut INTEGER, holdOut INTEGER, reps INTEGER)',
      );
      await db.execute(
        'CREATE TABLE affirmation_list (id INTEGER PRIMARY KEY, name TEXT)',
      );
      await db.execute(
        'CREATE TABLE affirmation_items (id INTEGER PRIMARY KEY, list_id INTEGER NOT NULL, item TEXT, FOREIGN KEY(list_id) REFERENCES affirmation_list(id))',
      );
      await db.execute(
        'CREATE TABLE tasktag (taskID INTEGER NOT NULL, tagID INTEGER NOT NULL, PRIMARY KEY (taskID, tagID), FOREIGN KEY(tagID) REFERENCES tag(id), FOREIGN KEY(taskID) REFERENCES task(id))',
      );
      await db.execute(
        'CREATE TABLE breathingtag (breathingID INTEGER NOT NULL, tagID INTEGER NOT NULL, PRIMARY KEY (breathingID, tagID), FOREIGN KEY(tagID) REFERENCES tag(id), FOREIGN KEY(breathingID) REFERENCES breathing(id))',
      );
      await db.execute(
        'CREATE TABLE journal (id INTEGER PRIMARY KEY, title TEXT, dateWritten TEXT, content TEXT)',
      );
      await db.execute(
        'CREATE TABLE journaltag (entryID INTEGER NOT NULL, tagID INTEGER NOT NULL, PRIMARY KEY (entryID, tagID), FOREIGN KEY(tagID) REFERENCES tag(id), FOREIGN KEY(entryID) REFERENCES journal(id))',
      );

      // tag examples
      await db.execute(
        "INSERT INTO tag (id, name, color) VALUES (1, 'mindfulness', 4283215696)",
      );
      await db.execute(
        "INSERT INTO tag (id, name, color) VALUES (2, 'breathing', 4278221563)",
      );
      await db.execute(
        "INSERT INTO tag (id, name, color) VALUES (3, 'stress', 4294901760)",
      );
      await db.execute(
        "INSERT INTO tag (id, name, color) VALUES (4, 'anxiety', 4294967040)",
      );
      await db.execute(
        "INSERT INTO tag (id, name, color) VALUES (5, 'self-care', 4289429645)",
      );

      // task examples
      await db.execute(
        "INSERT INTO task (id, name, description, task) VALUES (1, 'Journal', 'Write a short journal entry', 'Spend 5-10 minutes writing about your day or feelings.')",
      );
      await db.execute(
        "INSERT INTO task (id, name, description, task) VALUES (2, 'Say something kind', 'Say something kind to yourself out loud', 'Say: \"I am doing my best\" or another kind phrase.')",
      );
      await db.execute(
        "INSERT INTO task (id, name, description, task) VALUES (3, 'Take a walk', 'Step outside for a short walk', 'Walk for 5-15 minutes in a safe and calming environment.')",
      );
      await db.execute(
        "INSERT INTO task (id, name, description, task) VALUES (4, 'Drink water', 'Hydrate', 'Slowly drink a glass of water to fuel your body.')",
      );

      // breathing exercise examples
      await db.execute(
        "INSERT INTO breathing (id, name, countIn, holdIn, countOut, holdOut, reps) VALUES (1, 'Square breathing', 4, 4, 4, 4, 6)",
      );
      await db.execute(
        "INSERT INTO breathing (id, name, countIn, holdIn, countOut, holdOut, reps) VALUES (2, 'Triangle breathing', 4, 4, 4, 0, 6)",
      );
      await db.execute(
        "INSERT INTO breathing (id, name, countIn, holdIn, countOut, holdOut, reps) VALUES (3, '4-7-8', 4, 7, 8, 0, 4)",
      );

      // adding tags to tasks
      await db.execute("INSERT INTO tasktag (taskID, tagID) VALUES (1, 1)");
      await db.execute("INSERT INTO tasktag (taskID, tagID) VALUES (1, 5)");
      await db.execute("INSERT INTO tasktag (taskID, tagID) VALUES (2, 5)");
      await db.execute("INSERT INTO tasktag (taskID, tagID) VALUES (3, 1)");
      await db.execute("INSERT INTO tasktag (taskID, tagID) VALUES (3, 3)");
      await db.execute("INSERT INTO tasktag (taskID, tagID) VALUES (4, 5)");

      // adding tags to breathing tasks
      await db.execute(
        "INSERT INTO breathingtag (breathingID, tagID) VALUES (1, 2)",
      );
      await db.execute(
        "INSERT INTO breathingtag (breathingID, tagID) VALUES (1, 1)",
      );
      await db.execute(
        "INSERT INTO breathingtag (breathingID, tagID) VALUES (2, 2)",
      );

      // affirmation list examples
      await db.execute(
        "INSERT INTO affirmation_list (id, name) VALUES (1, 'Morning Affirmations')",
      );
      await db.execute(
        "INSERT INTO affirmation_list (id, name) VALUES (2, 'Peace Reminders')",
      );

      // affirmation items
      await db.execute(
        "INSERT INTO affirmation_items (list_id, item) VALUES (1, 'I am enough exactly as I am')",
      );
      await db.execute(
        "INSERT INTO affirmation_items (list_id, item) VALUES (1, 'I am worthy of love and kindness')",
      );
      await db.execute(
        "INSERT INTO affirmation_items (list_id, item) VALUES (1, 'I am grateful for this moment')",
      );
      await db.execute(
        "INSERT INTO affirmation_items (list_id, item) VALUES (2, 'May I experience peace and health today')",
      );
      await db.execute(
        "INSERT INTO affirmation_items (list_id, item) VALUES (2, 'May I be resilient and capable')",
      );
      await db.execute(
        "INSERT INTO affirmation_items (list_id, item) VALUES (2, 'I can do hard things')",
      );
      await db.execute(
        "INSERT INTO affirmation_items (list_id, item) VALUES (2, 'My feelings are valid')",
      );
    },
    onUpgrade: (db, prevVersion, curVersion) async {
      if (prevVersion < 2) {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS affirmation_list (id INTEGER PRIMARY KEY, name TEXT)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS affirmation_items (id INTEGER PRIMARY KEY, list_id INTEGER NOT NULL, item TEXT, FOREIGN KEY(list_id) REFERENCES affirmation_list(id))',
        );
      }
      if (prevVersion < 3) {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS journal (id INTEGER PRIMARY KEY, title TEXT, dateWritten TEXT, content TEXT)',
        );
        await db.execute(
          'CREATE TABLE IF NOT EXISTS journaltag (entryID INTEGER NOT NULL, tagID INTEGER NOT NULL, PRIMARY KEY (entryID, tagID), FOREIGN KEY(tagID) REFERENCES tag(id), FOREIGN KEY(entryID) REFERENCES journal(id))',
        );
      }
    },
    version: 3,
  );
}
