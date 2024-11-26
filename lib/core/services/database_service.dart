/// database_service.dart
/// Handles database operations

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:que_app/core/models/device/index.dart';
import 'package:que_app/core/models/note.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('devices_notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE devices ( 
  id $idType, 
  deviceName $textType,
  connectedQueueName $textType
  )
''');

    await db.execute('''
CREATE TABLE notes (
  id $idType,
  content $textType,
  creationDate TEXT,
  deviceId INTEGER,
  FOREIGN KEY (deviceId) REFERENCES devices (id)
  )
''');

    await db.execute('''
CREATE TABLE deviceSettings (
  id $idType,
  deviceId INTEGER,
  settingName $textType,
  settingValue TEXT,
  FOREIGN KEY (deviceId) REFERENCES devices (id)
  )
''');
  }

  Future<Device> createDevice(Device device) async {
    final db = await instance.database;

    final id = await db.insert('devices', device.toJson());
    return device.copyWith(id: id.toString());  // Changed from copy to copyWith
  }

  Future<Note> createNote(Note note) async {
    final db = await instance.database;

    final id = await db.insert('notes', note.toJson());
    return note.copy(id: id.toString());
  }

// Add methods for read, update, and delete operations...
}