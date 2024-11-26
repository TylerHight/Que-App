// lib/features/device_settings/models/settings_config.dart

import 'package:equatable/equatable.dart';

import '../../../core/models/device/index.dart';

/// Configuration model for device settings
class SettingsConfig extends Equatable {
  final String deviceId;
  final ScentConfig scentOne;
  final ScentConfig scentTwo;
  final HeartRateConfig heartRate;
  final DateTime lastUpdated;

  const SettingsConfig({
    required this.deviceId,
    required this.scentOne,
    required this.scentTwo,
    required this.heartRate,
    required this.lastUpdated,
  });

  factory SettingsConfig.fromDevice(Device device) {
    return SettingsConfig(
      deviceId: device.id,
      scentOne: ScentConfig(
        emissionDuration: device.emission1Duration,
        releaseInterval: device.releaseInterval1,
        isPeriodicEnabled: device.isPeriodicEmissionEnabled,
      ),
      scentTwo: ScentConfig(
        emissionDuration: device.emission2Duration,
        releaseInterval: device.releaseInterval2,
        isPeriodicEnabled: device.isPeriodicEmissionEnabled2,
      ),
      heartRate: HeartRateConfig(
        threshold: device.heartrateThreshold,
      ),
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'scentOne': scentOne.toJson(),
    'scentTwo': scentTwo.toJson(),
    'heartRate': heartRate.toJson(),
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory SettingsConfig.fromJson(Map<String, dynamic> json) => SettingsConfig(
    deviceId: json['deviceId'] as String,
    scentOne: ScentConfig.fromJson(json['scentOne'] as Map<String, dynamic>),
    scentTwo: ScentConfig.fromJson(json['scentTwo'] as Map<String, dynamic>),
    heartRate: HeartRateConfig.fromJson(json['heartRate'] as Map<String, dynamic>),
    lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  );

  SettingsConfig copyWith({
    String? deviceId,
    ScentConfig? scentOne,
    ScentConfig? scentTwo,
    HeartRateConfig? heartRate,
    DateTime? lastUpdated,
  }) {
    return SettingsConfig(
      deviceId: deviceId ?? this.deviceId,
      scentOne: scentOne ?? this.scentOne,
      scentTwo: scentTwo ?? this.scentTwo,
      heartRate: heartRate ?? this.heartRate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object> get props => [deviceId, scentOne, scentTwo, heartRate, lastUpdated];
}

class ScentConfig extends Equatable {
  final Duration emissionDuration;
  final Duration releaseInterval;
  final bool isPeriodicEnabled;

  const ScentConfig({
    required this.emissionDuration,
    required this.releaseInterval,
    required this.isPeriodicEnabled,
  });

  Map<String, dynamic> toJson() => {
    'emissionDuration': emissionDuration.inSeconds,
    'releaseInterval': releaseInterval.inSeconds,
    'isPeriodicEnabled': isPeriodicEnabled,
  };

  factory ScentConfig.fromJson(Map<String, dynamic> json) => ScentConfig(
    emissionDuration: Duration(seconds: json['emissionDuration'] as int),
    releaseInterval: Duration(seconds: json['releaseInterval'] as int),
    isPeriodicEnabled: json['isPeriodicEnabled'] as bool,
  );

  @override
  List<Object> get props => [emissionDuration, releaseInterval, isPeriodicEnabled];
}

class HeartRateConfig extends Equatable {
  final int threshold;

  const HeartRateConfig({
    required this.threshold,
  });

  Map<String, dynamic> toJson() => {
    'threshold': threshold,
  };

  factory HeartRateConfig.fromJson(Map<String, dynamic> json) => HeartRateConfig(
    threshold: json['threshold'] as int,
  );

  @override
  List<Object> get props => [threshold];
}