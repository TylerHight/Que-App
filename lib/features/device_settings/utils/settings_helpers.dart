// lib/features/device_settings/utils/settings_helpers.dart

import 'package:flutter/material.dart';

class SettingsHelpers {
  /// Validation constants
  static const Duration minEmissionDuration = Duration(milliseconds: 100);
  static const Duration maxEmissionDuration = Duration(seconds: 10);
  static const Duration minInterval = Duration(seconds: 30);
  static const Duration maxInterval = Duration(hours: 24);
  static const int minHeartRate = 40;
  static const int maxHeartRate = 220;

  /// Validate emission duration
  static void validateDuration(Duration duration) {
    if (duration < minEmissionDuration || duration > maxEmissionDuration) {
      throw ValidationException(
        'Duration must be between ${minEmissionDuration.inMilliseconds}ms and ${maxEmissionDuration.inSeconds}s',
      );
    }
  }

  /// Validate release interval
  static void validateInterval(Duration interval) {
    if (interval < minInterval || interval > maxInterval) {
      throw ValidationException(
        'Interval must be between ${minInterval.inSeconds}s and ${maxInterval.inHours}h',
      );
    }
  }

  /// Validate heart rate threshold
  static void validateHeartRateThreshold(int threshold) {
    if (threshold < minHeartRate || threshold > maxHeartRate) {
      throw ValidationException(
        'Heart rate threshold must be between $minHeartRate and $maxHeartRate',
      );
    }
  }

  /// Format duration for display
  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else if (duration.inSeconds > 0) {
      return '${duration.inSeconds}s';
    } else {
      return '${duration.inMilliseconds}ms';
    }
  }

  /// Get color based on heart rate threshold
  static Color getHeartRateColor(int heartRate, int threshold) {
    final percentage = heartRate / threshold;
    if (percentage >= 1.0) {
      return Colors.red;
    } else if (percentage >= 0.8) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  /// Create settings backup string
  static String createBackupString(Map<String, dynamic> settings) {
    return Uri(queryParameters: settings.map(
          (key, value) => MapEntry(key, value.toString()),
    )).query;
  }

  /// Parse settings from backup string
  static Map<String, dynamic> parseBackupString(String backup) {
    try {
      final uri = Uri(query: backup);
      return uri.queryParameters;
    } catch (e) {
      throw ValidationException('Invalid backup string format');
    }
  }

  /// Check if settings need update based on version
  static bool needsUpdate(String currentVersion, String minimumVersion) {
    final current = Version.parse(currentVersion);
    final minimum = Version.parse(minimumVersion);
    return current < minimum;
  }
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class Version implements Comparable<Version> {
  final int major;
  final int minor;
  final int patch;

  const Version(this.major, this.minor, this.patch);

  factory Version.parse(String version) {
    final parts = version.split('.');
    if (parts.length != 3) {
      throw ValidationException('Invalid version format');
    }
    return Version(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  @override
  int compareTo(Version other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  bool operator <(Version other) => compareTo(other) < 0;
  bool operator >(Version other) => compareTo(other) > 0;
  bool operator <=(Version other) => compareTo(other) <= 0;
  bool operator >=(Version other) => compareTo(other) >= 0;

  @override
  String toString() => '$major.$minor.$patch';
}