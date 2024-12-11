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
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const boolType = 'INTEGER NOT NULL';  // SQLite doesn't have boolean, uses INTEGER

    await db.execute('''
CREATE TABLE devices ( 
  id $idType,
  deviceName $textType,
  connectedQueName $textType,
  emission1Duration $intType,
  emission2Duration $intType,
  releaseInterval1 $intType,
  releaseInterval2 $intType,
  isBleConnected $boolType,
  isPeriodicEmissionEnabled $boolType,
  isPeriodicEmissionEnabled2 $boolType,
  heartrateThreshold $intType,
  bluetoothServiceCharacteristics TEXT
)
''');

    await db.execute('''
CREATE TABLE notes (
  id $idType,
  content $textType,
  creationDate TEXT NOT NULL,
  deviceId TEXT,
  FOREIGN KEY (deviceId) REFERENCES devices (id)
  )
''');
  }

  // Create operations
  Future<Device> createDevice(Device device) async {
    final db = await instance.database;
    final id = await db.insert('devices', device.toJson());
    return device.copyWith(id: id.toString());
  }

  Future<Note> createNote(Note note) async {
    final db = await instance.database;
    final id = await db.insert('notes', note.toJson());
    return note.copy(id: id.toString());
  }

  Future<void> createDeviceSetting(String deviceId, String name, String value) async {
    final db = await instance.database;
    await db.insert('deviceSettings', {
      'deviceId': deviceId,
      'settingName': name,
      'settingValue': value,
    });
  }

  // Read operations
  Future<Device?> getDevice(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'devices',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DevicePersistence.fromJson(maps.first);
    }
    return null;
  }

  Future<List<Device>> getAllDevices() async {
    final db = await instance.database;
    final result = await db.query('devices');
    return result.map((json) => DevicePersistence.fromJson(json)).toList();
  }

  Future<List<Note>> getDeviceNotes(String deviceId) async {
    final db = await instance.database;
    final device = await getDevice(deviceId);
    final result = await db.query(
      'notes',
      where: 'deviceId = ?',
      whereArgs: [deviceId],
    );
    return result.map((json) {
      final note = Note.fromJson(json);
      note.device = device;
      return note;
    }).toList();
  }

  Future<Map<String, String>> getDeviceSettings(String deviceId) async {
    final db = await instance.database;
    final result = await db.query(
      'deviceSettings',
      where: 'deviceId = ?',
      whereArgs: [deviceId],
    );

    return Map.fromEntries(
        result.map((row) => MapEntry(row['settingName'] as String, row['settingValue'] as String))
    );
  }

  // Update operations
  Future<bool> updateDevice(Device device) async {
    final db = await instance.database;
    final result = await db.update(
      'devices',
      device.toJson(),
      where: 'id = ?',
      whereArgs: [device.id],
    );
    return result > 0;
  }

  Future<bool> updateNote(Note note) async {
    final db = await instance.database;
    final result = await db.update(
      'notes',
      note.toJson(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
    return result > 0;
  }

  Future<bool> updateDeviceSetting(String deviceId, String name, String value) async {
    final db = await instance.database;
    final result = await db.update(
      'deviceSettings',
      {'settingValue': value},
      where: 'deviceId = ? AND settingName = ?',
      whereArgs: [deviceId, name],
    );
    return result > 0;
  }

  // Delete operations
  Future<bool> deleteDevice(String id) async {
    final db = await instance.database;

    // Start a transaction to ensure all related records are deleted
    return await db.transaction((txn) async {
      // Delete related settings
      await txn.delete(
        'deviceSettings',
        where: 'deviceId = ?',
        whereArgs: [id],
      );

      // Delete related notes
      await txn.delete(
        'notes',
        where: 'deviceId = ?',
        whereArgs: [id],
      );

      // Delete the device
      final result = await txn.delete(
        'devices',
        where: 'id = ?',
        whereArgs: [id],
      );

      return result > 0;
    });
  }

  Future<bool> deleteNote(String id) async {
    final db = await instance.database;
    final result = await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }

  Future<bool> deleteDeviceSetting(String deviceId, String name) async {
    final db = await instance.database;
    final result = await db.delete(
      'deviceSettings',
      where: 'deviceId = ? AND settingName = ?',
      whereArgs: [deviceId, name],
    );
    return result > 0;
  }

  // Utility methods
  Future<bool> deviceExists(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'devices',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }

  Future<T?> get<T>(String key) async {
    final db = await instance.database;
    final result = await db.query(
      'deviceSettings',
      where: 'settingName = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final value = result.first['settingValue'] as String;
    return _convertValue<T>(value);
  }

  Future<bool> set<T>(String key, T value) async {
    final db = await instance.database;

    try {
      await db.insert(
        'deviceSettings',
        {
          'settingName': key,
          'settingValue': value.toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print('Error setting value: $e');
      return false;
    }
  }

  Future<bool> delete(String key) async {
    final db = await instance.database;
    final result = await db.delete(
      'deviceSettings',
      where: 'settingName = ?',
      whereArgs: [key],
    );
    return result > 0;
  }

  // Helper method to convert string values to the correct type
  T? _convertValue<T>(String value) {
    if (T == String) {
      return value as T;
    } else if (T == int) {
      return int.tryParse(value) as T?;
    } else if (T == double) {
      return double.tryParse(value) as T?;
    } else if (T == bool) {
      return (value.toLowerCase() == 'true') as T;
    } else if (T == DateTime) {
      return DateTime.tryParse(value) as T?;
    }
    return null;
  }

  // handles database upgrades if needed
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Drop existing tables
    await db.execute('DROP TABLE IF EXISTS devices');
    await db.execute('DROP TABLE IF EXISTS notes');

    // Recreate tables
    await _createDB(db, newVersion);
  }
}