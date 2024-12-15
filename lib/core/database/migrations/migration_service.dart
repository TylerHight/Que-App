// lib/core/database/migrations/migration_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MigrationService {
  static const int currentVersion = 2;
  static const String databaseName = 'que_app.db';

  static Future<Database> initializeDatabase() async {
    final String path = join(await getDatabasesPath(), databaseName);

    return await openDatabase(
      path,
      version: currentVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await _createInitialTables(db);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Run migrations sequentially
    for (var i = oldVersion + 1; i <= newVersion; i++) {
      await _runMigration(db, i);
    }
  }

  static Future<void> _createInitialTables(Database db) async {
    // Create devices table
    await db.execute('''
      CREATE TABLE devices ( 
        id TEXT PRIMARY KEY,
        deviceName TEXT NOT NULL,
        connectedQueName TEXT NOT NULL,
        emission1Duration INTEGER NOT NULL,
        emission2Duration INTEGER NOT NULL,
        releaseInterval1 INTEGER NOT NULL,
        releaseInterval2 INTEGER NOT NULL,
        isBleConnected INTEGER NOT NULL,
        isPeriodicEmissionEnabled INTEGER NOT NULL,
        isPeriodicEmissionEnabled2 INTEGER NOT NULL,
        heartrateThreshold INTEGER NOT NULL,
        bluetoothServiceCharacteristics TEXT
      )
    ''');

    // Create notes table
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        creationDate TEXT NOT NULL,
        deviceId TEXT,
        FOREIGN KEY (deviceId) REFERENCES devices (id)
      )
    ''');

    // Create device settings table
    await db.execute('''
      CREATE TABLE deviceSettings (
        deviceId TEXT NOT NULL,
        settingName TEXT NOT NULL,
        settingValue TEXT NOT NULL,
        PRIMARY KEY (deviceId, settingName),
        FOREIGN KEY (deviceId) REFERENCES devices (id)
      )
    ''');
  }

  static Future<void> _runMigration(Database db, int version) async {
    switch (version) {
      case 2:
        await _migrationV2(db);
        break;
    // Add future migrations here
    }
  }

  static Future<void> _migrationV2(Database db) async {
    // Migration to add connectedQueName column if it doesn't exist
    try {
      await db.execute('''
        ALTER TABLE devices 
        ADD COLUMN connectedQueName TEXT NOT NULL DEFAULT ''
      ''');
    } catch (e) {
      print('Migration V2 error (can be ignored if column exists): $e');
    }
  }

  static Future<void> resetDatabase() async {
    final String path = join(await getDatabasesPath(), databaseName);
    final db = await openDatabase(path);

    // Drop all tables
    await db.transaction((txn) async {
      await txn.execute('DROP TABLE IF EXISTS deviceSettings');
      await txn.execute('DROP TABLE IF EXISTS notes');
      await txn.execute('DROP TABLE IF EXISTS devices');
    });

    await db.close();

    // Delete the database file
    await deleteDatabase(path);
  }
}