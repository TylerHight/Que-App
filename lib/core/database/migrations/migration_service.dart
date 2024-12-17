// lib/core/database/migrations/migration_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MigrationService {
  static const int currentVersion = 2;
  static const String databaseName = 'que_app.db';

  static Future<Database> initializeDatabase() async {
    final String path = join(await getDatabasesPath(), databaseName);

    // Force delete the existing database to handle schema changes
    await deleteDatabase(path);

    return await openDatabase(
      path,
      version: currentVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  static Future<void> _createTables(dynamic db) async {
    await db.execute('''
      CREATE TABLE devices ( 
        id TEXT PRIMARY KEY,
        deviceName TEXT NOT NULL,
        connectedQueName TEXT NOT NULL DEFAULT '',
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

    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        creationDate TEXT NOT NULL,
        deviceId TEXT,
        FOREIGN KEY (deviceId) REFERENCES devices (id)
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // For now, we'll recreate the database when schema changes
    await _recreateDatabase(db);
  }

  static Future<void> _recreateDatabase(Database db) async {
    await db.transaction((txn) async {
      // Drop existing tables
      await txn.execute('DROP TABLE IF EXISTS notes');
      await txn.execute('DROP TABLE IF EXISTS devices');

      // Recreate with current schema
      await _createTables(txn);
    });
  }

  static Future<void> resetDatabase() async {
    final String path = join(await getDatabasesPath(), databaseName);
    await deleteDatabase(path);
  }
}