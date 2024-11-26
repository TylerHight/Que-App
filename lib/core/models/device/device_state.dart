// lib/core/models/device/device_state.dart
import 'package:equatable/equatable.dart';

class DeviceState with EquatableMixin {
  Duration _emission1Duration;
  Duration _emission2Duration;
  Duration _releaseInterval1;
  Duration _releaseInterval2;
  bool _isPeriodicEmissionEnabled;
  bool _isPeriodicEmissionEnabled2;
  bool _isBleConnected;
  int _heartrateThreshold;

  Duration get emission1Duration => _emission1Duration;
  Duration get emission2Duration => _emission2Duration;
  Duration get releaseInterval1 => _releaseInterval1;
  Duration get releaseInterval2 => _releaseInterval2;
  bool get isPeriodicEmissionEnabled => _isPeriodicEmissionEnabled;
  bool get isPeriodicEmissionEnabled2 => _isPeriodicEmissionEnabled2;
  bool get isBleConnected => _isBleConnected;
  int get heartrateThreshold => _heartrateThreshold;

  DeviceState({
    required Duration emission1Duration,
    required Duration emission2Duration,
    required Duration releaseInterval1,
    required Duration releaseInterval2,
    required bool isPeriodicEmissionEnabled,
    required bool isPeriodicEmissionEnabled2,
    required bool isBleConnected,
    required int heartrateThreshold,
  })  : _emission1Duration = emission1Duration,
        _emission2Duration = emission2Duration,
        _releaseInterval1 = releaseInterval1,
        _releaseInterval2 = releaseInterval2,
        _isPeriodicEmissionEnabled = isPeriodicEmissionEnabled,
        _isPeriodicEmissionEnabled2 = isPeriodicEmissionEnabled2,
        _isBleConnected = isBleConnected,
        _heartrateThreshold = heartrateThreshold;

  void updateEmission1Duration(Duration duration) {
    _emission1Duration = duration;
  }

  void updateEmission2Duration(Duration duration) {
    _emission2Duration = duration;
  }

  void updateReleaseInterval1(Duration interval) {
    _releaseInterval1 = interval;
  }

  void updateReleaseInterval2(Duration interval) {
    _releaseInterval2 = interval;
  }

  void updatePeriodicEmission1(bool enabled) {
    _isPeriodicEmissionEnabled = enabled;
  }

  void updatePeriodicEmission2(bool enabled) {
    _isPeriodicEmissionEnabled2 = enabled;
  }

  void updateHeartRateThreshold(int threshold) {
    _heartrateThreshold = threshold;
  }

  set isBleConnected(bool value) {
    _isBleConnected = value;
  }

  @override
  List<Object?> get props => [
    _emission1Duration,
    _emission2Duration,
    _releaseInterval1,
    _releaseInterval2,
    _isPeriodicEmissionEnabled,
    _isPeriodicEmissionEnabled2,
    _isBleConnected,
    _heartrateThreshold,
  ];
}