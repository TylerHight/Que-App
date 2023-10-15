// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:que_app/device_data.dart';
import 'package:que_app/main.dart';

void main() {
  // Add your custom tests here
  group('DeviceData', () {
    test('Adding a device title', () {
      final deviceData = DeviceData();
      deviceData.addDeviceTitle('New Device');
      expect(deviceData.deviceTitles, contains('New Device'));
    });

    test('Adding a data point', () {
      final deviceData = DeviceData();
      final dataPoint = DeviceTimeSeriesData(timestamp: DateTime.now());
      deviceData.addDeviceTitle('Device A');
      deviceData.addDataPoint('Device A', dataPoint);
      final deviceDataList = deviceData.getDeviceData('Device A');
      expect(deviceDataList, contains(dataPoint));
    });

    test('Check default values for DeviceTimeSeriesData', () {
      final defaultDataPoint = DeviceTimeSeriesData(timestamp: DateTime.now());

      // Check the default values of the data point
      expect(defaultDataPoint.heartRate, 0);
      expect(defaultDataPoint.deviceOn, false);
      expect(defaultDataPoint.positiveEmission, false);
      expect(defaultDataPoint.negativeEmission, false);
      expect(defaultDataPoint.positiveEmissionDuration, 10);
      expect(defaultDataPoint.negativeEmissionDuration, 10);
      expect(defaultDataPoint.periodicEmissionTimerLength, 30 * 60);
      expect(defaultDataPoint.periodicEmission, false);
    });

  });
}
