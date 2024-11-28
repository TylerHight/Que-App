// lib/features/device_settings/services/settings_service.dart

import 'package:que_app/core/models/device/index.dart';
import 'package:que_app/core/services/ble/ble_service.dart';
import 'package:que_app/features/device_settings/models/settings_config.dart';
import 'package:que_app/features/device_settings/repositories/device_settings_repository.dart';
import 'package:que_app/features/device_settings/utils/settings_helpers.dart';

class SettingsService {
  final BleService _bleService;
  final DeviceSettingsRepository _repository;

  const SettingsService({
    required BleService bleService,
    required DeviceSettingsRepository repository,
  }) : _bleService = bleService,
        _repository = repository;

  BleService get bleService => _bleService;

  Future<bool> _isDeviceConnected() async {
    return await _bleService.connectionStatusStream.first;
  }

  /// Update emission duration for scent one
  Future<void> updateEmission1Duration(
      Device device,
      Duration duration,
      ) async {
    try {
      SettingsHelpers.validateDuration(duration);

      final config = await _repository.getDeviceSettings(device.id);
      final newScentConfig = ScentConfig(
        emissionDuration: duration,
        releaseInterval: config.scentOne.releaseInterval,
        isPeriodicEnabled: config.scentOne.isPeriodicEnabled,
      );

      // Update repository first
      await _repository.updateScentOneConfig(device.id, newScentConfig);

      // Only update device if connected
      if (await _isDeviceConnected()) {
        try {
          await _bleService.updateEmission1Duration(device.id, duration);
          await _removeFromPendingChanges(device.id, 'emission1Duration');
        } catch (e) {
          await _addToPendingChanges(device.id, 'emission1Duration', duration);
          rethrow;
        }
      } else {
        await _addToPendingChanges(device.id, 'emission1Duration', duration);
      }
    } catch (e) {
      throw SettingsServiceException('Failed to update emission 1 duration: $e');
    }
  }

  /// Update emission duration for scent two
  Future<void> updateEmission2Duration(
      Device device,
      Duration duration,
      ) async {
    try {
      SettingsHelpers.validateDuration(duration);

      final config = await _repository.getDeviceSettings(device.id);
      final newScentConfig = ScentConfig(
        emissionDuration: duration,
        releaseInterval: config.scentTwo.releaseInterval,
        isPeriodicEnabled: config.scentTwo.isPeriodicEnabled,
      );

      await _repository.updateScentTwoConfig(device.id, newScentConfig);

      if (await _isDeviceConnected()) {
        try {
          await _bleService.updateEmission2Duration(device.id, duration);
          await _removeFromPendingChanges(device.id, 'emission2Duration');
        } catch (e) {
          await _addToPendingChanges(device.id, 'emission2Duration', duration);
          rethrow;
        }
      } else {
        await _addToPendingChanges(device.id, 'emission2Duration', duration);
      }
    } catch (e) {
      throw SettingsServiceException('Failed to update emission 2 duration: $e');
    }
  }

  /// Update release interval for scent one
  Future<void> updateReleaseInterval1(
      Device device,
      Duration interval,
      ) async {
    try {
      SettingsHelpers.validateInterval(interval);

      final config = await _repository.getDeviceSettings(device.id);
      final newScentConfig = ScentConfig(
        emissionDuration: config.scentOne.emissionDuration,
        releaseInterval: interval,
        isPeriodicEnabled: config.scentOne.isPeriodicEnabled,
      );

      await _repository.updateScentOneConfig(device.id, newScentConfig);

      if (await _isDeviceConnected()) {
        try {
          await _bleService.updateInterval1(device.id, interval);
          await _removeFromPendingChanges(device.id, 'releaseInterval1');
        } catch (e) {
          await _addToPendingChanges(device.id, 'releaseInterval1', interval);
          rethrow;
        }
      } else {
        await _addToPendingChanges(device.id, 'releaseInterval1', interval);
      }
    } catch (e) {
      throw SettingsServiceException('Failed to update release interval 1: $e');
    }
  }

  /// Update release interval for scent two
  Future<void> updateReleaseInterval2(
      Device device,
      Duration interval,
      ) async {
    try {
      SettingsHelpers.validateInterval(interval);

      final config = await _repository.getDeviceSettings(device.id);
      final newScentConfig = ScentConfig(
        emissionDuration: config.scentTwo.emissionDuration,
        releaseInterval: interval,
        isPeriodicEnabled: config.scentTwo.isPeriodicEnabled,
      );

      await _repository.updateScentTwoConfig(device.id, newScentConfig);

      if (await _isDeviceConnected()) {
        try {
          await _bleService.updateInterval2(device.id, interval);
          await _removeFromPendingChanges(device.id, 'releaseInterval2');
        } catch (e) {
          await _addToPendingChanges(device.id, 'releaseInterval2', interval);
          rethrow;
        }
      } else {
        await _addToPendingChanges(device.id, 'releaseInterval2', interval);
      }
    } catch (e) {
      throw SettingsServiceException('Failed to update release interval 2: $e');
    }
  }

  /// Update periodic emission setting for scent one
  Future<void> updatePeriodicEmission1(
      Device device,
      bool enabled,
      ) async {
    try {
      final config = await _repository.getDeviceSettings(device.id);
      final newScentConfig = ScentConfig(
        emissionDuration: config.scentOne.emissionDuration,
        releaseInterval: config.scentOne.releaseInterval,
        isPeriodicEnabled: enabled,
      );

      await _repository.updateScentOneConfig(device.id, newScentConfig);

      if (await _isDeviceConnected()) {
        try {
          await _bleService.updatePeriodicEmission1(device.id, enabled);
          await _removeFromPendingChanges(device.id, 'isPeriodicEmission1');
        } catch (e) {
          await _addToPendingChanges(device.id, 'isPeriodicEmission1', enabled);
          rethrow;
        }
      } else {
        await _addToPendingChanges(device.id, 'isPeriodicEmission1', enabled);
      }
    } catch (e) {
      throw SettingsServiceException('Failed to update periodic emission 1: $e');
    }
  }

  /// Update periodic emission setting for scent two
  Future<void> updatePeriodicEmission2(
      Device device,
      bool enabled,
      ) async {
    try {
      final config = await _repository.getDeviceSettings(device.id);
      final newScentConfig = ScentConfig(
        emissionDuration: config.scentTwo.emissionDuration,
        releaseInterval: config.scentTwo.releaseInterval,
        isPeriodicEnabled: enabled,
      );

      await _repository.updateScentTwoConfig(device.id, newScentConfig);

      if (await _isDeviceConnected()) {
        try {
          await _bleService.updatePeriodicEmission2(device.id, enabled);
          await _removeFromPendingChanges(device.id, 'isPeriodicEmission2');
        } catch (e) {
          await _addToPendingChanges(device.id, 'isPeriodicEmission2', enabled);
          rethrow;
        }
      } else {
        await _addToPendingChanges(device.id, 'isPeriodicEmission2', enabled);
      }
    } catch (e) {
      throw SettingsServiceException('Failed to update periodic emission 2: $e');
    }
  }

  /// Update heart rate threshold
  Future<void> updateHeartRateThreshold(
      Device device,
      int threshold,
      ) async {
    try {
      SettingsHelpers.validateHeartRateThreshold(threshold);

      final newHeartRateConfig = HeartRateConfig(
        threshold: threshold,
      );

      await _repository.updateHeartRateConfig(device.id, newHeartRateConfig);

      if (await _isDeviceConnected()) {
        try {
          await _bleService.updateHeartRateThreshold(device.id, threshold);
          await _removeFromPendingChanges(device.id, 'heartRateThreshold');
        } catch (e) {
          await _addToPendingChanges(device.id, 'heartRateThreshold', threshold);
          rethrow;
        }
      } else {
        await _addToPendingChanges(device.id, 'heartRateThreshold', threshold);
      }
    } catch (e) {
      throw SettingsServiceException('Failed to update heart rate threshold: $e');
    }
  }

  /// Helper method to add a pending change
  Future<void> _addToPendingChanges(String deviceId, String key, dynamic value) async {
    final config = await _repository.getDeviceSettings(deviceId);
    final newPendingChanges = Map<String, dynamic>.from(config.pendingChanges);
    newPendingChanges[key] = value;
    await _repository.updatePendingChanges(deviceId, newPendingChanges);
  }

  /// Helper method to remove a pending change
  Future<void> _removeFromPendingChanges(String deviceId, String key) async {
    final config = await _repository.getDeviceSettings(deviceId);
    final newPendingChanges = Map<String, dynamic>.from(config.pendingChanges);
    newPendingChanges.remove(key);
    await _repository.updatePendingChanges(deviceId, newPendingChanges);
  }

  /// Connect to heart rate monitor
  Future<void> connectToHeartRateMonitor(Device device) async {
    try {
      final scanResults = await _bleService.scanForHeartRateMonitors();
      if (scanResults.isEmpty) {
        throw SettingsServiceException('No heart rate monitors found');
      }

      final monitor = scanResults.first;
      await _bleService.connectToHeartRateMonitor(device.id, monitor);
    } catch (e) {
      throw SettingsServiceException('Failed to connect to heart rate monitor: $e');
    }
  }

  /// Delete device settings
  Future<void> deleteDevice(Device device) async {
    try {
      await _repository.deleteDeviceSettings(device.id);
      if (await _isDeviceConnected()) {
        await _bleService.forgetDevice(device.id);
      }
    } catch (e) {
      throw SettingsServiceException('Failed to delete device: $e');
    }
  }

  /// Save all settings
  Future<void> saveSettings(Device device) async {
    try {
      final config = SettingsConfig.fromDevice(device);
      await _repository.saveDeviceSettings(config);
    } catch (e) {
      throw SettingsServiceException('Failed to save settings: $e');
    }
  }

  /// Sync pending changes
  Future<void> syncPendingChanges(Device device) async {
    try {
      final config = await _repository.getDeviceSettings(device.id);
      if (await _isDeviceConnected() && config.pendingChanges.isNotEmpty) {
        for (final entry in config.pendingChanges.entries) {
          switch (entry.key) {
            case 'emission1Duration':
              await _bleService.updateEmission1Duration(device.id, entry.value as Duration);
              break;
            case 'emission2Duration':
              await _bleService.updateEmission2Duration(device.id, entry.value as Duration);
              break;
            case 'releaseInterval1':
              await _bleService.updateInterval1(device.id, entry.value as Duration);
              break;
            case 'releaseInterval2':
              await _bleService.updateInterval2(device.id, entry.value as Duration);
              break;
            case 'isPeriodicEmission1':
              await _bleService.updatePeriodicEmission1(device.id, entry.value as bool);
              break;
            case 'isPeriodicEmission2':
              await _bleService.updatePeriodicEmission2(device.id, entry.value as bool);
              break;
            case 'heartRateThreshold':
              await _bleService.updateHeartRateThreshold(device.id, entry.value as int);
              break;
          }
        }
        await clearPendingChanges(device);
      }
    } catch (e) {
      throw SettingsServiceException('Failed to sync pending changes: $e');
    }
  }

  /// Save pending changes
  Future<void> savePendingChanges(
      Device device,
      Map<String, dynamic> pendingChanges,
      ) async {
    try {
      await _repository.updatePendingChanges(device.id, pendingChanges);
    } catch (e) {
      throw SettingsServiceException('Failed to save pending changes: $e');
    }
  }

  /// Clear pending changes after sync
  Future<void> clearPendingChanges(Device device) async {
    try {
      await _repository.clearPendingChanges(device.id);
    } catch (e) {
      throw SettingsServiceException('Failed to clear pending changes: $e');
    }
  }

  /// Load pending changes
  Future<Map<String, dynamic>> loadPendingChanges(String deviceId) async {
    try {
      final config = await _repository.getDeviceSettings(deviceId);
      return config.pendingChanges;
    } catch (e) {
      throw SettingsServiceException('Failed to load pending changes: $e');
    }
  }
}

class SettingsServiceException implements Exception {
  final String message;

  SettingsServiceException(this.message);

  @override
  String toString() => 'SettingsServiceException: $message';
}