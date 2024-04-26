import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:que_app/models/device.dart';
import 'package:que_app/models/note.dart';

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
CREATE TABLE $tableDevices ( 
  ${DeviceFields.id} $idType, 
  ${DeviceFields.name} $textType,
  ${DeviceFields.type} $textType,
  ${DeviceFields.isConnected} BOOLEAN
  )
''');

    await db.execute('''
CREATE TABLE $tableNotes (
  ${NoteFields.id} $idType,
  ${NoteFields.content} $textType,
  ${NoteFields.creationDate} TEXT,
  ${NoteFields.deviceId} INTEGER,
  FOREIGN KEY (${NoteFields.deviceId}) REFERENCES $tableDevices (${DeviceFields.id})
  )
''');
  }

// Add methods for insert, update, delete, and retrieve operations...
}
