// lib/core/database/repositories/device_repository.dart

import 'dart:convert';
import 'package:que_app/core/models/device/device.dart';
import '../database/abstracts/crud_repository.dart';
import '../database/providers/sqlite_provider.dart';

class DeviceRepository implements CrudRepository<Device> {
  final SQLiteProvider _provider;
  static const String _tableName = 'devices';

  DeviceRepository({required SQLiteProvider provider}) : _provider = provider;

  @override
  Future<Device> create(Device device) async {
    try {
      final id = await _provider.insert(_tableName, _toMap(device));
      return device.copyWith(id: id.toString());
    } catch (e) {
      throw DatabaseException('Failed to create device: $e');
    }
  }

  @override
  Future<Device?> read(String id) async {
    try {
      final maps = await _provider.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return _fromMap(maps.first);
    } catch (e) {
      throw DatabaseException('Failed to read device: $e');
    }
  }

  @override
  Future<bool> update(Device device) async {
    try {
      final count = await _provider.update(
        _tableName,
        _toMap(device),
        where: 'id = ?',
        whereArgs: [device.id],
      );
      return count > 0;
    } catch (e) {
      throw DatabaseException('Failed to update device: $e');
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      return await _provider.transaction((txn) async {
        // Delete related settings
        await txn.delete(
          'deviceSettings',
          where: 'deviceId = ?',
          whereArgs: [id],
        );

        // Delete the device
        final count = await txn.delete(
          _tableName,
          where: 'id = ?',
          whereArgs: [id],
        );

        return count > 0;
      });
    } catch (e) {
      throw DatabaseException('Failed to delete device: $e');
    }
  }

  @override
  Future<List<Device>> getAll() async {
    try {
      final maps = await _provider.query(_tableName);
      return maps.map(_fromMap).toList();
    } catch (e) {
      throw DatabaseException('Failed to get all devices: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final count = await _provider.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      return count.isNotEmpty;
    } catch (e) {
      throw DatabaseException('Failed to check device existence: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final result = await _provider.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
      return result.first['count'] as int;
    } catch (e) {
      throw DatabaseException('Failed to count devices: $e');
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _provider.delete(_tableName);
    } catch (e) {
      throw DatabaseException('Failed to delete all devices: $e');
    }
  }

  Map<String, dynamic> _toMap(Device device) {
    return {
      'id': device.id,
      'deviceName': device.deviceName,
      'connectedQueName': device.connectedQueName,
      'emission1Duration': device.emission1Duration.inSeconds,
      'emission2Duration': device.emission2Duration.inSeconds,
      'releaseInterval1': device.releaseInterval1.inSeconds,
      'releaseInterval2': device.releaseInterval2.inSeconds,
      'isBleConnected': device.isBleConnected ? 1 : 0,
      'isPeriodicEmissionEnabled': device.isPeriodicEmissionEnabled ? 1 : 0,
      'isPeriodicEmissionEnabled2': device.isPeriodicEmissionEnabled2 ? 1 : 0,
      'heartrateThreshold': device.heartrateThreshold,
      'bluetoothServiceCharacteristics': jsonEncode(device.bluetoothDevice?.toString() ?? ''),
    };
  }

  Device _fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] as String,
      deviceName: map['deviceName'] as String,
      connectedQueName: map['connectedQueName'] as String,
      emission1Duration: Duration(seconds: map['emission1Duration'] as int),
      emission2Duration: Duration(seconds: map['emission2Duration'] as int),
      releaseInterval1: Duration(seconds: map['releaseInterval1'] as int),
      releaseInterval2: Duration(seconds: map['releaseInterval2'] as int),
      isBleConnected: map['isBleConnected'] == 1,
      isPeriodicEmissionEnabled: map['isPeriodicEmissionEnabled'] == 1,
      isPeriodicEmissionEnabled2: map['isPeriodicEmissionEnabled2'] == 1,
      heartrateThreshold: map['heartrateThreshold'] as int,
    );
  }
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}