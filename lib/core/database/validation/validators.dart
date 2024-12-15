// lib/core/database/validation/validators.dart

import 'package:que_app/core/models/device/device.dart';
import 'package:que_app/core/models/note.dart';

class DatabaseValidators {
  static void validateDevice(Device device) {
    if (device.id.isEmpty) {
      throw ValidationException('Device ID cannot be empty');
    }

    if (device.deviceName.isEmpty) {
      throw ValidationException('Device name cannot be empty');
    }

    if (device.emission1Duration.inSeconds <= 0 ||
        device.emission2Duration.inSeconds <= 0) {
      throw ValidationException('Emission duration must be positive');
    }

    if (device.releaseInterval1.inSeconds <= 0 ||
        device.releaseInterval2.inSeconds <= 0) {
      throw ValidationException('Release interval must be positive');
    }

    if (device.heartrateThreshold <= 0) {
      throw ValidationException('Heart rate threshold must be positive');
    }
  }

  static void validateNote(Note note) {
    if (note.id.isEmpty) {
      throw ValidationException('Note ID cannot be empty');
    }

    if (note.content.isEmpty) {
      throw ValidationException('Note content cannot be empty');
    }

    if (note.creationDate.isAfter(DateTime.now())) {
      throw ValidationException('Creation date cannot be in the future');
    }
  }

  static void validateDeviceSetting(String deviceId, String key, String value) {
    if (deviceId.isEmpty) {
      throw ValidationException('Device ID cannot be empty');
    }

    if (key.isEmpty) {
      throw ValidationException('Setting key cannot be empty');
    }

    if (value.isEmpty) {
      throw ValidationException('Setting value cannot be empty');
    }

    // Validate specific settings based on key
    switch (key) {
      case 'emission1Duration':
      case 'emission2Duration':
        final duration = int.tryParse(value);
        if (duration == null || duration <= 0) {
          throw ValidationException('Invalid emission duration value');
        }
        break;

      case 'releaseInterval1':
      case 'releaseInterval2':
        final interval = int.tryParse(value);
        if (interval == null || interval <= 0) {
          throw ValidationException('Invalid release interval value');
        }
        break;

      case 'heartrateThreshold':
        final threshold = int.tryParse(value);
        if (threshold == null || threshold <= 0) {
          throw ValidationException('Invalid heart rate threshold value');
        }
        break;
    }
  }
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}