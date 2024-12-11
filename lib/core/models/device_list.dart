// lib/core/models/device_list.dart

import 'package:flutter/foundation.dart';
import 'package:que_app/core/services/database_service.dart';
import 'device/index.dart';

class DeviceList extends ChangeNotifier {
  final Set<Device> _devices = {};
  final DatabaseService _databaseService = DatabaseService.instance;

  List<Device> get devices => _devices.toList();

  bool hasDevice(String id) {
    return _devices.any((device) => device.id == id);
  }

  void add(Device device) {
    print('DeviceList: Adding device ${device.deviceName}');
    // Remove existing device with same ID if it exists
    _devices.removeWhere((d) => d.id == device.id);
    _devices.add(device);
    print('DeviceList: Device list now contains ${_devices.length} devices');
    notifyListeners();
  }

  Future<void> removeDevice(Device device) async {
    try {
      print('DeviceList: Starting device removal for ${device.deviceName}');
      print('DeviceList: Current device count: ${_devices.length}');

      // First try to disconnect and cleanup the device
      print('DeviceList: Calling device.delete()');
      await device.delete();

      // Then remove from database
      print('DeviceList: Deleting from database');
      final success = await _databaseService.deleteDevice(device.id);
      print('DeviceList: Database deletion success: $success');

      if (!success) {
        throw Exception('Failed to delete device from database');
      }

      // Finally remove from memory
      print('DeviceList: Removing device from memory');
      final removed = _devices.remove(device);
      print('DeviceList: Device removed from memory: $removed');
      print('DeviceList: Remaining devices: ${_devices.length}');

      // Notify listeners AFTER all operations are complete
      print('DeviceList: Notifying listeners');
      notifyListeners();
      print('DeviceList: Device removal complete');

    } catch (e) {
      print('DeviceList: Error removing device: $e');
      print('DeviceList: Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Device? findDeviceById(String id) {
    try {
      return _devices.firstWhere((device) => device.id == id);
    } catch (_) {
      return null;
    }
  }

  void clear() {
    print('DeviceList: Clearing all devices');
    _devices.clear();
    notifyListeners();
    print('DeviceList: All devices cleared');
  }
}