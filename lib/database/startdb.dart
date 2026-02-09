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
    onUpgrade: (db, prevVersion, curVersion) {
      // migrate older versions to use a composite primary key on tasktag
      if (prevVersion < 2) {
        db.execute(
          'CREATE TABLE tag (id INTEGER PRIMARY KEY, name TEXT, color INTEGER)',
        );
        db.execute(
          'CREATE TABLE tasktag (taskID INTEGER PRIMARY KEY, tagID INTEGER, FOREIGN KEY(tagID) REFERENCES tag(id), FOREIGN KEY(taskID) REFERENCES task(id))',
        );
      }
      if (prevVersion < 3) {
        // ensure new table exists
        db.execute(
          'CREATE TABLE IF NOT EXISTS tasktag_new (taskID INTEGER NOT NULL, tagID INTEGER NOT NULL, PRIMARY KEY (taskID, tagID), FOREIGN KEY(tagID) REFERENCES tag(id), FOREIGN KEY(taskID) REFERENCES task(id))',
        );
        // copy existing relations into the new table (ignore duplicates)
        db.execute(
          'INSERT OR IGNORE INTO tasktag_new (taskID, tagID) SELECT taskID, tagID FROM tasktag',
        );
        // replace old table
        db.execute('DROP TABLE IF EXISTS tasktag');
        db.execute('ALTER TABLE tasktag_new RENAME TO tasktag');
      }
      if (prevVersion < 4) {
        db.execute(
          'CREATE TABLE breathing (id INTEGER PRIMARY KEY, name TEXT, countIn INTEGER, holdIn INTEGER, countOut INTEGER, holdOut INTEGER, reps INTEGER)',
        );
        db.execute(
          'CREATE TABLE breathingtag (breathingID INTEGER NOT NULL, tagID INTEGER NOT NULL, PRIMARY KEY (breathingID, tagID), FOREIGN KEY(tagID) REFERENCES tag(id), FOREIGN KEY(breathingID) REFERENCES breathing(id))',
        );
      }
    },
    version: 3,
  );
}
