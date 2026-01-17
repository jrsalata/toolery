import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> getDatabase() async {
  WidgetsFlutterBinding.ensureInitialized();

  return openDatabase(
    join(await getDatabasesPath(), 'toolery.db'),
    onCreate: (db, version) {
      db.execute(
        'CREATE TABLE task (id INTEGER PRIMARY KEY, name TEXT, description TEXT, task TEXT )',
      );
      db.execute('CREATE TABLE tag (id INTEGER PRIMARY KEY, name TEXT, color INTEGER)',);
      db.execute('CREATE TABLE tasktag (taskID INTEGER PRIMARY KEY, tagID INTEGER, FOREIGN KEY(tagID) REFERENCES tag(id), FOREIGN KEY(taskID) REFERENCES task(id))');
    },
    onUpgrade: (db, prevVersion, curVersion){
      if(prevVersion == 1){
        db.execute('CREATE TABLE tag (id INTEGER PRIMARY KEY, name TEXT, color TEXT)',);
        db.execute('CREATE TABLE tasktag (taskID INTEGER PRIMARY KEY, tagID INTEGER, FOREIGN KEY(tagID) REFERENCES tag(id), FOREIGN KEY(taskID) REFERENCES task(id))');
      }
    },
    version: 2,
  );
}
