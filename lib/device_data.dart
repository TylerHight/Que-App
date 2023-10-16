// device_data.dart

import 'package:flutter/foundation.dart';

class DeviceTimeSeriesData {
  final DateTime timestamp;
  final int heartRate;
  final bool deviceOn; // if device is on or off
  final bool positiveEmission;  // if being released
  final bool negativeEmission;  // if being released
  final int positiveEmissionDuration;  // release duration setting
  final int negativeEmissionDuration; // release duration settings
  final int periodicEmissionTimerLength; // time between periodic emissions setting
  final bool periodicEmission; // if being released

  DeviceTimeSeriesData({
    required this.timestamp,
    this.heartRate = 0,
    this.deviceOn = false,
    this.positiveEmission = false,
    this.negativeEmission = false,
    this.positiveEmissionDuration = 10,
    this.negativeEmissionDuration = 10,
    this.periodicEmissionTimerLength = 30 * 60, // 30 minutes * (60 seconds/min)
    this.periodicEmission = false,
  });

  factory DeviceTimeSeriesData.fromPrevious(DeviceTimeSeriesData previous, {
    DateTime? timestamp,
    int? heartRate,
    bool? deviceOn,
    bool? positiveEmission,
    bool? negativeEmission,
    int? positiveEmissionTime,
    int? negativeEmissionTime,
    int? periodicEmissionTimerLength,
    bool? periodicEmissionTriggers,
  }) {
    return DeviceTimeSeriesData(
      timestamp: timestamp ?? previous.timestamp,
      heartRate: heartRate ?? previous.heartRate,
      deviceOn: deviceOn ?? previous.deviceOn,
      positiveEmission: positiveEmission ?? previous.positiveEmission,
      negativeEmission: negativeEmission ?? previous.negativeEmission,
      positiveEmissionDuration: positiveEmissionTime ?? previous.positiveEmissionDuration,
      negativeEmissionDuration: negativeEmissionTime ?? previous.negativeEmissionDuration,
      periodicEmissionTimerLength: periodicEmissionTimerLength ?? previous.periodicEmissionTimerLength,
      periodicEmission: periodicEmissionTriggers ?? previous.periodicEmission,
    );
  }
}

class DeviceData extends ChangeNotifier {
  final List<String> _deviceTitles = List.generate(
      2, (index) => 'Device $index'); // auto generate two devices on startup
  final Map<String, List<DeviceTimeSeriesData>> _deviceDataMap = {};

  List<String> get deviceTitles => _deviceTitles;

  List<DeviceTimeSeriesData> getDeviceData(String deviceTitle) {
    return _deviceDataMap[deviceTitle] ?? [];
  }

  void addDeviceTitle(String title) {
    _deviceTitles.add(title);
    _deviceDataMap[title] = [
      // Create a default time series data point for the new title
      DeviceTimeSeriesData(timestamp: DateTime.now())
    ];
    notifyListeners();
  }

  void deleteDeviceTitle(int index) {
    final title = _deviceTitles[index];
    _deviceTitles.removeAt(index);
    _deviceDataMap.remove(title);
    notifyListeners();
  }

  // Add a data point to a specific device
  void addDataPoint(String deviceTitle, DeviceTimeSeriesData dataPoint) {
    if (_deviceDataMap.containsKey(deviceTitle)) {
      _deviceDataMap[deviceTitle]?.add(dataPoint);
      notifyListeners(); // Notify the UI of the data change
    }
  }

  DeviceTimeSeriesData getDeviceSettings(String deviceTitle) {
    final List<DeviceTimeSeriesData>? deviceData = _deviceDataMap[deviceTitle];
    if (deviceData != null && deviceData.isNotEmpty) {
      return deviceData.first; // Return the settings from the first data point
    } else {
      // Return default settings with the current timestamp
      return DeviceTimeSeriesData(timestamp: DateTime.now());
    }
  }
}
