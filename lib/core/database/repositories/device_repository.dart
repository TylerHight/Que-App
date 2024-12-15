// lib/core/repositories/device_repository.dart

import 'package:que_app/core/models/device/device.dart';
import 'package:que_app/core/services/database_service.dart';

class DeviceRepository {
  final DatabaseService _databaseService = DatabaseService.instance;
  final Set<Device> _devices = {};

  List<Device> get devices => _devices.toList();

  bool hasDevice(String id) {
    return _devices.any((device) => device.id == id);
  }

  Future<void> addDevice(Device device) async {
    print('DeviceRepository: Adding device ${device.deviceName}');
    try {
      // Remove existing device with same ID if it exists
      _devices.removeWhere((d) => d.id == device.id);
      _devices.add(device);

      // Save to database
      await _databaseService.createDevice(device);

      print('DeviceRepository: Device list now contains ${_devices.length} devices');
    } catch (e) {
      print('DeviceRepository: Error adding device: $e');
      rethrow;
    }
  }

  Future<void> removeDevice(Device device) async {
    try {
      print('DeviceRepository: Starting device removal for ${device.deviceName}');
      print('DeviceRepository: Current device count: ${_devices.length}');

      // Remove from database
      print('DeviceRepository: Deleting from database');
      final success = await _databaseService.deleteDevice(device.id);
      print('DeviceRepository: Database deletion success: $success');

      if (!success) {
        throw Exception('Failed to delete device from database');
      }

      // Remove from memory
      print('DeviceRepository: Removing device from memory');
      final removed = _devices.remove(device);
      print('DeviceRepository: Device removed from memory: $removed');
      print('DeviceRepository: Remaining devices: ${_devices.length}');
      print('DeviceRepository: Device removal complete');

    } catch (e) {
      print('DeviceRepository: Error removing device: $e');
      print('DeviceRepository: Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<Device>> loadDevices() async {
    try {
      final devices = await _databaseService.getAllDevices();
      _devices.clear();
      _devices.addAll(devices);
      return devices;
    } catch (e) {
      print('DeviceRepository: Error loading devices: $e');
      rethrow;
    }
  }

  Future<Device?> findDeviceById(String id) async {
    try {
      return await _databaseService.getDevice(id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateDevice(Device device) async {
    try {
      await _databaseService.updateDevice(device);

      // Update in memory
      _devices.removeWhere((d) => d.id == device.id);
      _devices.add(device);
    } catch (e) {
      print('DeviceRepository: Error updating device: $e');
      rethrow;
    }
  }

  Future<void> clear() async {
    print('DeviceRepository: Clearing all devices');
    try {
      // Clear from database
      for (final device in _devices) {
        await _databaseService.deleteDevice(device.id);
      }

      // Clear from memory
      _devices.clear();
      print('DeviceRepository: All devices cleared');
    } catch (e) {
      print('DeviceRepository: Error clearing devices: $e');
      rethrow;
    }
  }
}