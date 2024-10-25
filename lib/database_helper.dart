import 'dart:developer';

import 'package:oxdo_sqflite/person/person.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) _database;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), "my_database.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS person(
            id INTEGER  PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            age INTEGER
          )
      ''');
      },
    );
  }

  Future<int> insertPerson(Person person) async {
    try {
      final db = await database;

      return db.insert(
        "person",
        person.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception("Person insert exception:$e");
    }
  }

  Future<List<Person>> getAllPersons() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> list = await db.query("person");
      return list.map((element) => Person.fromJson(element)).toList();
    } catch (e) {
      throw Exception("Get all exception:$e");
    }
  }

  Future updatePerson(Person person) async {
    try {
      final personJson = person.toJson();
      log(personJson.toString());
      final db = await database;
      await db.update("person", (person.toJson()),
          where: "id=?", whereArgs: [person.id]);
    } catch (e) {
      log("update error=> $e");
      throw Exception("Person update exception:$e");
    }
  }

  Future deletePerson(int id) async {
    try {
      final db = await database;
      await db.delete("person", where: "id=?", whereArgs: [id]);
    } catch (e) {
      throw Exception("Person update exception:$e");
    }
  }
}
