/// database_service.dart
/// Handles database operations

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:que_app/models/device.dart';
import 'package:que_app/models/note.dart';
import 'package:que_app/models/setting.dart';

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
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';

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
    return device.copy(id: id.toString()); // Adjusted to match the change in the Device class
  }

  Future<Note> createNote(Note note) async {
    final db = await instance.database;

    final id = await db.insert('notes', note.toJson());
    return note.copy(id: id);
  }

  Future<DeviceSettings> createDeviceSetting(DeviceSettings setting) async {
    final db = await instance.database;

    final id = await db.insert('deviceSettings', setting.toJson());
    return setting.copy(id: id);
  }

// Add methods for read, update, and delete operations...
}
