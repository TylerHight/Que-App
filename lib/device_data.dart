// device_data.dart

import 'package:flutter/foundation.dart';

class DeviceTimeSeriesData {
  final DateTime timestamp;
  final int heartRate;
  final bool deviceOn;
  final bool positiveEmission;
  final bool negativeEmission;
  int positiveEmissionDuration;
  int negativeEmissionDuration;
  int periodicEmissionTimerLength;
  final bool periodicEmission;

  DeviceTimeSeriesData({
    required this.timestamp,
    this.heartRate = 0,
    this.deviceOn = false,
    this.positiveEmission = false,
    this.negativeEmission = false,
    this.positiveEmissionDuration = 10,
    this.negativeEmissionDuration = 10,
    this.periodicEmissionTimerLength = 2,
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
  final List<String> _deviceTitles = [];
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

    // Print a message to confirm that the method is called
    print("addDataPoint called for device: $deviceTitle");
    print("New Data Point: $dataPoint");
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

  void printDeviceData() {
    print('');
    print('Printing device data: ');
    print('\n');
    _deviceDataMap.forEach((deviceTitle, dataPoints) {
      print('Device Title: $deviceTitle');
      print('Number of Data Points: ${dataPoints.length}');
      print('\n');

      dataPoints.forEach((dataPoint) {
        print('Timestamp: ${dataPoint.timestamp}');
        print('Heart Rate: ${dataPoint.heartRate}');
        print('Device On: ${dataPoint.deviceOn}');
        print('Positive Emission: ${dataPoint.positiveEmission}');
        print('Negative Emission: ${dataPoint.negativeEmission}');
        print('Positive Emission Duration: ${dataPoint.positiveEmissionDuration}');
        print('Negative Emission Duration: ${dataPoint.negativeEmissionDuration}');
        print('Periodic Emission Timer Length: ${dataPoint.periodicEmissionTimerLength}');
        print('Periodic Emission: ${dataPoint.periodicEmission}');
        print('\n');
      });
    });
  }
}
