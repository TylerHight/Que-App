// lib/core/database/migrations/v1_initial_schema.dart

import 'migration.dart';

class V1InitialSchema extends Migration {
  const V1InitialSchema() : super(1);

  @override
  Future<void> up(dynamic db) async {
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

    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        creationDate TEXT NOT NULL,
        deviceId TEXT,
        FOREIGN KEY (deviceId) REFERENCES devices (id)
      )
    ''');

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

  @override
  Future<void> down(dynamic db) async {
    await db.execute('DROP TABLE IF EXISTS deviceSettings');
    await db.execute('DROP TABLE IF EXISTS notes');
    await db.execute('DROP TABLE IF EXISTS devices');
  }
}