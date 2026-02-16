import 'dart:async';

import 'package:flutter/material.dart';
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
    onCreate: (db, version) {
      db.execute(
        'CREATE TABLE task (id INTEGER PRIMARY KEY, name TEXT, description TEXT, task TEXT )',
      );
      db.execute(
        'CREATE TABLE tag (id INTEGER PRIMARY KEY, name TEXT, color INTEGER)',
      );
      db.execute(
        'CREATE TABLE breathing (id INTEGER PRIMARY KEY, name TEXT, countIn INTEGER, holdIn INTEGER, countOut INTEGER, holdOut INTEGER, reps INTEGER)',
      );
      db.execute(
        'CREATE TABLE tasktag (taskID INTEGER NOT NULL, tagID INTEGER NOT NULL, PRIMARY KEY (taskID, tagID), FOREIGN KEY(tagID) REFERENCES tag(id), FOREIGN KEY(taskID) REFERENCES task(id))',
      );
      db.execute(
        'CREATE TABLE breathingtag (breathingID INTEGER NOT NULL, tagID INTEGER NOT NULL, PRIMARY KEY (breathingID, tagID), FOREIGN KEY(tagID) REFERENCES tag(id), FOREIGN KEY(breathingID) REFERENCES breathing(id))',
      );
    },
    onUpgrade: (db, prevVersion, curVersion) {},
    version: 1,
  );
}
