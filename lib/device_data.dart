// device_data.dart
import 'package:flutter/foundation.dart';

class DeviceTimeSeriesData {
  final DateTime timestamp;
  // stores heart rate values
  final int heartRate;
  // tracks when the device was on or off
  final bool deviceOn;
  // tracks when emissions are being released
  final bool positiveEmission;
  final bool negativeEmission;
  // stores the user setting for how long an emission lasts without being cancelled
  final int positiveEmissionTime;
  final int negativeEmissionTime;
  // stores the user setting for the amount of time between periodic emissions
  final int periodicEmissionTimerLength;
  // stores the datetimes when a periodic emission was triggered
  final List<DateTime> periodicEmissionTriggers;

  DeviceTimeSeriesData({
    required this.timestamp,
    required this.heartRate,
    required this.deviceOn,
    required this.positiveEmission,
    required this.negativeEmission,
    required this.positiveEmissionTime,
    required this.negativeEmissionTime,
    required this.periodicEmissionTimerLength,
    required this.periodicEmissionTriggers,
  });
}

class DeviceData extends ChangeNotifier {
  final List<String> _deviceTitles = List.generate(2, (index) => 'Device $index');
  final Map<String, List<DeviceTimeSeriesData>> _deviceDataMap = {};

  List<String> get deviceTitles => _deviceTitles;

  List<DeviceTimeSeriesData> getDeviceData(String deviceTitle) {
    return _deviceDataMap[deviceTitle] ?? [];
  }

  void addDeviceTitle(String title) {
    _deviceTitles.add(title);
    _deviceDataMap[title] = []; // Initialize data for the new device
    notifyListeners();
  }

  void deleteDeviceTitle(int index) {
    final title = _deviceTitles[index];
    _deviceTitles.removeAt(index);
    _deviceDataMap.remove(title);
    notifyListeners();
  }
}
