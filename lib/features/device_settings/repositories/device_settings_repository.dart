// lib/features/device_settings/repositories/device_settings_repository.dart

import 'package:que_app/core/services/database_service.dart';
import 'package:que_app/core/services/ble/ble_service.dart';
import 'package:que_app/features/device_settings/models/settings_config.dart';

class DeviceSettingsRepository {
  final DatabaseService _databaseService;
  final BleService _bleService;

  const DeviceSettingsRepository({
    required DatabaseService databaseService,
    required BleService bleService,
  }) : _databaseService = databaseService,
        _bleService = bleService;

  /// Generate a unique key for device settings
  String _getDeviceSettingsKey(String deviceId) => 'device_settings_$deviceId';

  /// Fetch settings for a specific device
  Future<SettingsConfig> getDeviceSettings(String deviceId) async {
    try {
      final key = _getDeviceSettingsKey(deviceId);
      final data = await _databaseService.get<Map<String, dynamic>>(key);

      if (data == null) {
        // Return default settings if none exist
        return SettingsConfig.defaults(deviceId: deviceId);
      }

      return SettingsConfig.fromJson(data);
    } catch (e) {
      throw SettingsRepositoryException(
        'Failed to fetch device settings: $e',
      );
    }
  }

  /// Save settings for a device
  Future<void> saveDeviceSettings(SettingsConfig config) async {
    try {
      final key = _getDeviceSettingsKey(config.deviceId);
      // Save to local storage
      await _databaseService.set(key, config.toJson());

      // Update device via BLE
      await _updateDeviceViaBle(config);
    } catch (e) {
      throw SettingsRepositoryException(
        'Failed to save device settings: $e',
      );
    }
  }

  /// Update scent one configuration
  Future<void> updateScentOneConfig(
      String deviceId,
      ScentConfig config,
      ) async {
    try {
      final settings = await getDeviceSettings(deviceId);
      final updatedSettings = settings.copyWith(
        scentOne: config,
        lastUpdated: DateTime.now(),
      );
      await saveDeviceSettings(updatedSettings);
    } catch (e) {
      throw SettingsRepositoryException(
        'Failed to update scent one config: $e',
      );
    }
  }

  /// Update scent two configuration
  Future<void> updateScentTwoConfig(
      String deviceId,
      ScentConfig config,
      ) async {
    try {
      final settings = await getDeviceSettings(deviceId);
      final updatedSettings = settings.copyWith(
        scentTwo: config,
        lastUpdated: DateTime.now(),
      );
      await saveDeviceSettings(updatedSettings);
    } catch (e) {
      throw SettingsRepositoryException(
        'Failed to update scent two config: $e',
      );
    }
  }

  /// Update heart rate configuration
  Future<void> updateHeartRateConfig(
      String deviceId,
      HeartRateConfig config,
      ) async {
    try {
      final settings = await getDeviceSettings(deviceId);
      final updatedSettings = settings.copyWith(
        heartRate: config,
        lastUpdated: DateTime.now(),
      );
      await saveDeviceSettings(updatedSettings);
    } catch (e) {
      throw SettingsRepositoryException(
        'Failed to update heart rate config: $e',
      );
    }
  }

  /// Delete device settings
  Future<void> deleteDeviceSettings(String deviceId) async {
    try {
      final key = _getDeviceSettingsKey(deviceId);
      await _databaseService.delete(key);
    } catch (e) {
      throw SettingsRepositoryException(
        'Failed to delete device settings: $e',
      );
    }
  }

  /// Update device settings via BLE
  Future<void> _updateDeviceViaBle(SettingsConfig config) async {
    try {
      await _bleService.updateDeviceSettings(
        config.deviceId,
        {
          'emission1': config.scentOne.emissionDuration.inSeconds,
          'emission2': config.scentTwo.emissionDuration.inSeconds,
          'interval1': config.scentOne.releaseInterval.inSeconds,
          'interval2': config.scentTwo.releaseInterval.inSeconds,
          'periodic1': config.scentOne.isPeriodicEnabled ? 1 : 0,
          'periodic2': config.scentTwo.isPeriodicEnabled ? 1 : 0,
          'heartrate': config.heartRate.threshold,
        },
      );
    } catch (e) {
      throw SettingsRepositoryException(
        'Failed to update device via BLE: $e',
      );
    }
  }
}

class SettingsRepositoryException implements Exception {
  final String message;

  SettingsRepositoryException(this.message);

  @override
  String toString() => 'SettingsRepositoryException: $message';
}