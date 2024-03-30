// File: device_data.dart
// Description: Contains classes for managing and storing device data and settings 

import 'package:flutter/foundation.dart';

// Stores time series data for the device
class DeviceTimeSeriesData {
  final DateTime timestamp; // timestamp for the data
  final int heartRate; // heart rate that is being collected from the connected HR device
  final bool deviceOn; // whether the necklace is on or off
  final bool positiveEmission; // whether a positive emission is being released or not
  final bool negativeEmission; // whether a negative emission is being released or not
  int positiveEmissionDuration; // duration of positive scent emission
  int negativeEmissionDuration; // duration of negative scent emission
  int periodicEmissionTimerLength; // length of time between periodically-triggered emissions
  bool periodicEmissionEnabled; // whether periodic emissions are enabled or disabled
  int heartRateEmissionDuration; // duration of heart-rate triggered scent emission
  int heartRateThreshold; // heart rate threshold for triggering scent emission
  bool heartRateEmissionsEnabled; // if heartrate-triggered emissions are enabled or disabled
  String connectedHRDeviceName = ""; // name of connected heart rate monitoring device
  bool positiveEmissionsEnabled; // if enabled or disabled
  bool negativeEmissionsEnabled; // if enabled or disabled
  String note; // Add this field for storing the note

  DeviceTimeSeriesData({
    required this.timestamp,
    this.heartRate = 0,
    this.deviceOn = false,
    this.positiveEmission = false,
    this.negativeEmission = false,
    this.positiveEmissionDuration = 10,
    this.negativeEmissionDuration = 10,
    this.periodicEmissionTimerLength = 2,
    this.periodicEmissionEnabled = false,
    this.heartRateEmissionDuration = 10,
    this.heartRateThreshold = 80,
    this.heartRateEmissionsEnabled = false,
    this.positiveEmissionsEnabled = false,
    this.negativeEmissionsEnabled = false,
    this.note = "", // Initialize the note field
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
    bool? positiveEmissionsEnabled,
    bool? negativeEmissionsEnabled,
    String? note, // Add the note field to the factory constructor
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
      heartRateEmissionsEnabled: heartRateEmissions ?? previous.heartRateEmissionsEnabled,
      positiveEmissionsEnabled: positiveEmissionsEnabled ?? previous.positiveEmissionsEnabled,
      negativeEmissionsEnabled: negativeEmissionsEnabled ?? previous.negativeEmissionsEnabled,
      note: note ?? previous.note, // Set the note field in the factory constructor
    );
  }
}

class DeviceData extends ChangeNotifier {
  final List<String> _deviceTitles = [];
  final Map<String, List<DeviceTimeSeriesData>> _deviceDataMap = {};
  final Map<String, DateTime> _logItems = {};

  List<String> get deviceTitles => _deviceTitles;

  List<DeviceTimeSeriesData> getDeviceData(String deviceTitle) {
    return _deviceDataMap[deviceTitle] ?? [];
  }

  void addDeviceTitle(String title) {
    _deviceTitles.insert(0, title); // Insert at the beginning of _deviceTitles
    _deviceDataMap[title] = [
      DeviceTimeSeriesData(timestamp: DateTime.now())
    ];

    // Add the "Device added: " prefix to the device name
    String logItemTitle = "Device added: $title";

    // Create a new map with the new device added to the front
    Map<String, DateTime> newLogItem = {logItemTitle: DateTime.now()};
    newLogItem.addAll(_logItems);

    // Update the newLogItem variable
    _logItems.clear();
    _logItems.addAll(newLogItem);

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

      for (var dataPoint in dataPoints) {
        print('Timestamp: ${dataPoint.timestamp}');
        print('Heart Rate: ${dataPoint.heartRate}');
        print('Device On: ${dataPoint.deviceOn}');
        print('Positive Emission: ${dataPoint.positiveEmission}');
        print('Negative Emission: ${dataPoint.negativeEmission}');
        print('Positive Emission Duration: ${dataPoint.positiveEmissionDuration}');
        print('Negative Emission Duration: ${dataPoint.negativeEmissionDuration}');
        print('Periodic Emission Timer Length: ${dataPoint.periodicEmissionTimerLength}');
        print('Periodic Emission: ${dataPoint.periodicEmissionEnabled}');
        print('Connected Heart Rate Device Name: ${dataPoint.connectedHRDeviceName}');
        print('\n');
      }
    });
  }

  void setConnectedHRDeviceName(String deviceName) {
    // Set the connected HR device name for each device title
    for (var title in _deviceDataMap.keys) {
      if (_deviceDataMap[title]!.isNotEmpty) {
        _deviceDataMap[title]!.first.connectedHRDeviceName = deviceName;
      }
    }

    notifyListeners();
  }

  void setNoteForDevice(String deviceTitle, String note) {
    final List<DeviceTimeSeriesData>? deviceData = _deviceDataMap[deviceTitle];
    if (deviceData != null && deviceData.isNotEmpty) {
      // Add the "Note: " prefix to the note
      deviceData.first.note = "Note: $note";

      // Create a new map with the new note and timestamp added to the front
      Map<String, DateTime> newLogItems = {"Note for $deviceTitle: $note": DateTime.now()};
      newLogItems.addAll(_logItems);

      // Update the _logItems variable
      _logItems.clear();
      _logItems.addAll(newLogItems);

      notifyListeners();
    }
  }

  Map<String, DateTime> get logItems => _logItems;
}
