// lib/features/device_settings/services/settings_service.dart

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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

  // Add getter for BleService to support connection handling
  BleService get bleService => _bleService;

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

      await _repository.updateScentOneConfig(device.id, newScentConfig);
      if (device.isConnected) {
        await _bleService.updateEmission1Duration(device.id, duration);
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
      if (device.isConnected) {
        await _bleService.updateEmission2Duration(device.id, duration);
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
      if (device.isConnected) {
        await _bleService.updateInterval1(device.id, interval);
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
      if (device.isConnected) {
        await _bleService.updateInterval2(device.id, interval);
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
      if (device.isConnected) {
        await _bleService.updatePeriodicEmission1(device.id, enabled);
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
      if (device.isConnected) {
        await _bleService.updatePeriodicEmission2(device.id, enabled);
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

      final config = await _repository.getDeviceSettings(device.id);
      final newHeartRateConfig = HeartRateConfig(
        threshold: threshold,
      );

      await _repository.updateHeartRateConfig(device.id, newHeartRateConfig);
      if (device.isConnected) {
        await _bleService.updateHeartRateThreshold(device.id, threshold);
      }
    } catch (e) {
      throw SettingsServiceException('Failed to update heart rate threshold: $e');
    }
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
      if (device.isConnected) {
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
      if (device.isConnected) {
        // Sync all settings with device
        await _bleService.updateEmission1Duration(device.id, config.scentOne.emissionDuration);
        await _bleService.updateEmission2Duration(device.id, config.scentTwo.emissionDuration);
        await _bleService.updateInterval1(device.id, config.scentOne.releaseInterval);
        await _bleService.updateInterval2(device.id, config.scentTwo.releaseInterval);
        await _bleService.updatePeriodicEmission1(device.id, config.scentOne.isPeriodicEnabled);
        await _bleService.updatePeriodicEmission2(device.id, config.scentTwo.isPeriodicEnabled);
        await _bleService.updateHeartRateThreshold(device.id, config.heartRate.threshold);
      }
    } catch (e) {
      throw SettingsServiceException('Failed to sync pending changes: $e');
    }
  }
}

class SettingsServiceException implements Exception {
  final String message;

  SettingsServiceException(this.message);

  @override
  String toString() => 'SettingsServiceException: $message';
}