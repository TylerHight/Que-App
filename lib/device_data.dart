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
  final bool periodicEmissionOn; // if enabled or disabled
  int heartRateEmissionDuration;
  int heartRateThreshold;
  bool heartRateEmissionsOn; // if enabled or disabled

  DeviceTimeSeriesData({
    required this.timestamp,
    this.heartRate = 0,
    this.deviceOn = false,
    this.positiveEmission = false,
    this.negativeEmission = false,
    this.positiveEmissionDuration = 10,
    this.negativeEmissionDuration = 10,
    this.periodicEmissionTimerLength = 2,
    this.periodicEmissionOn = false,
    this.heartRateEmissionDuration = 10,
    this.heartRateThreshold = 80,
    this.heartRateEmissionsOn = false, // Initialize the new field
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
    int? heartRateEmissionDuration,
    int? heartRateThreshold,
    bool? heartRateEmissions,
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
      heartRateEmissionDuration: heartRateEmissionDuration ?? previous.heartRateEmissionDuration,
      heartRateThreshold: heartRateThreshold ?? previous.heartRateThreshold,
      heartRateEmissionsOn: heartRateEmissions ?? previous.heartRateEmissionsOn, // Set the new field
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

  void addDataPoint(String deviceTitle, DeviceTimeSeriesData dataPoint) {
    if (_deviceDataMap.containsKey(deviceTitle)) {
      _deviceDataMap[deviceTitle]?.add(dataPoint);
      notifyListeners();
    }

    print("addDataPoint called for device: $deviceTitle");
    print("New Data Point: $dataPoint");
  }

  DeviceTimeSeriesData getDeviceSettings(String deviceTitle) {
    final List<DeviceTimeSeriesData>? deviceData = _deviceDataMap[deviceTitle];
    if (deviceData != null && deviceData.isNotEmpty) {
      return deviceData.first;
    } else {
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
        print('Periodic Emission: ${dataPoint.periodicEmissionOn}');
        print('\n');
      });
    });
  }
}
