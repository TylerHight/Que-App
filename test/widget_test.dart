// widget_test.dart

// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:que_app/device_data.dart';
import 'package:que_app/screens/device_control/device_settings_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Open device settings and set Positive scent duration', (WidgetTester tester) async {
    // Create a DeviceData instance with some initial data
    final deviceData = DeviceData();
    deviceData.addDeviceTitle('Test Device');

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => deviceData),
          ],
          child: DeviceSettingsScreen(
            onDelete: () {},
            deviceTitle: 'Test Device',
          ),
        ),
      ),
    );

    // Wait for widgets to load
    await tester.pumpAndSettle();

    // Tap on "Positive scent duration"
    await tester.tap(find.text('Positive scent duration'));
    await tester.pumpAndSettle();

    // Set the duration to 7 minutes
    await tester.tap(find.byType(DropdownButton<int>).at(1));
    await tester.pumpAndSettle();
    // After opening the dropdown, you can tap on the "7" option
    await tester.tap(find.text('7'));
    await tester.pumpAndSettle();

    // Tap "OK" to confirm the duration
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Check if a new time series data point was created
    expect(deviceData.getDeviceData('Test Device').length, 2);

    // Get the created time series data point
    final newDataPoint = deviceData.getDeviceData('Test Device').first;

    // Check if the positive scent duration was set to 7 minutes (420 seconds)
    expect(newDataPoint.positiveEmissionDuration, 7*60);

    // You can add more assertions as needed for other settings
  });

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
      expect(defaultDataPoint.periodicEmissionEnabled, false);
    });

    test('Creating a new data point from previous data', () {
      final previousDataPoint = DeviceTimeSeriesData(
        timestamp: DateTime(2023, 10, 15),
        heartRate: 70,
        deviceOn: true,
        positiveEmission: true,
        positiveEmissionDuration: 15,
        periodicEmissionTimerLength: 900, // 15 minutes
      );

      final newDataPoint = DeviceTimeSeriesData.fromPrevious(previousDataPoint,
        heartRate: 80, // Overwrite heartRate
        positiveEmission: false, // Overwrite positiveEmission
      );

      expect(newDataPoint.timestamp, previousDataPoint.timestamp);
      expect(newDataPoint.heartRate, 80); // Verify the updated heartRate
      expect(newDataPoint.deviceOn, previousDataPoint.deviceOn);
      expect(newDataPoint.positiveEmission, false); // Verify the updated positiveEmission
      expect(newDataPoint.negativeEmission, previousDataPoint.negativeEmission);
      expect(newDataPoint.positiveEmissionDuration, previousDataPoint.positiveEmissionDuration);
      expect(newDataPoint.negativeEmissionDuration, previousDataPoint.negativeEmissionDuration);
      expect(newDataPoint.periodicEmissionTimerLength, previousDataPoint.periodicEmissionTimerLength);
      expect(newDataPoint.periodicEmissionEnabled, previousDataPoint.periodicEmissionEnabled);
    });


  });
}
