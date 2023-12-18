/// log_screen.dart
///
///
/// By: Tyler Hight

import 'package:flutter/material.dart';
import '../../device_data.dart';
import 'package:provider/provider.dart';

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: LogListWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

class LogListWidget extends StatefulWidget {
  @override
  _LogListWidgetState createState() => _LogListWidgetState();
}

class _LogListWidgetState extends State<LogListWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceData>(
      builder: (context, deviceData, child) {
        return ListView.builder(
          itemCount: deviceData.deviceAddedHistory.length,
          itemBuilder: (context, index) {
            String deviceTitle = deviceData.deviceAddedHistory.keys.elementAt(index);
            DateTime addedTimestamp = deviceData.deviceAddedHistory[deviceTitle] ?? DateTime.now();
            List<DeviceTimeSeriesData> deviceDataPoints = deviceData.getDeviceData(deviceTitle);

            // Retrieve the latest data point for the log entry
            DeviceTimeSeriesData latestDataPoint = deviceDataPoints.isNotEmpty
                ? deviceDataPoints.last
                : DeviceTimeSeriesData(timestamp: DateTime.now());

            return LogEntryWidget(
              deviceTitle: deviceTitle,
              addedTimestamp: addedTimestamp,
              latestDataPoint: latestDataPoint,
            );
          },
        );
      },
    );
  }
}

class LogEntryWidget extends StatelessWidget {
  final String deviceTitle;
  final DateTime addedTimestamp;
  final DeviceTimeSeriesData latestDataPoint;

  LogEntryWidget({
    required this.deviceTitle,
    required this.addedTimestamp,
    required this.latestDataPoint,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          deviceTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Added Timestamp: $addedTimestamp'),
              Text('Timestamp: ${latestDataPoint.timestamp}'),
              Text('Heart Rate: ${latestDataPoint.heartRate}'),
              // Add other relevant data points as needed
            ],
          ),
        ),
        onTap: () {
          // Handle onTap for each log entry if needed
        },
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
