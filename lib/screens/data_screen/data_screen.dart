// data_screen.dart

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'data/generated_hr_data.dart';
import '../../device_data.dart'; // Import your DeviceData class
import 'package:provider/provider.dart'; // Import the provider package

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  String selectedDevice = 'Device 0'; // Initialize with the first device title

  // Your existing code for chart and data
  Map<DateTime, double> heartRateData = generateHeartRateData(
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 0, 0),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 30, 0),
    const Duration(hours: 1),
  );

  DateTime selectedStartDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 0, 0);
  DateTime selectedEndDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 30, 0);

  DateTime originalStartDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 0, 0);
  DateTime originalEndDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 30, 0);

  final TextStyle textStyle = const TextStyle(fontSize: 15);

  Future<void> _selectStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: selectedStartDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedStartDate),
      );
      if (selectedTime != null) {
        setState(() {
          selectedStartDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _selectEndDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: selectedEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedEndDate),
      );
      if (selectedTime != null) {
        setState(() {
          selectedEndDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  Widget _buildChart() {
    // Check if there are devices
    if (Provider.of<DeviceData>(context).deviceTitles.isEmpty) {
      return const Center(
        child: Text(
          'No devices available.\nAdd devices to view data.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center, // Align the text in the center
        ),
      );
    }

    // Continue building the chart as before
    double minY = heartRateData.values.reduce((min, val) => val < min ? val : min).toDouble();
    double maxY = heartRateData.values.reduce((max, val) => val > max ? val : max).toDouble();

    minY = (minY / 5).floor() * 5;
    maxY = ((maxY + 4) / 5).ceil() * 5;

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        minimum: selectedStartDate,
        maximum: selectedEndDate,
        isVisible: true,
        intervalType: DateTimeIntervalType.hours,
        visibleMinimum: selectedStartDate,
        visibleMaximum: selectedEndDate,
      ),
      primaryYAxis: NumericAxis(
        minimum: minY,
        maximum: maxY,
        isVisible: true,
        interval: 5,
      ),
      series: <ChartSeries>[
        LineSeries<MapEntry<DateTime, double>, DateTime>(
          dataSource: heartRateData.entries.toList(),
          xValueMapper: (MapEntry<DateTime, double> entry, _) => entry.key,
          yValueMapper: (MapEntry<DateTime, double> entry, _) => entry.value,
        ),
      ],
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
        enablePinching: true,
        enableMouseWheelZooming: true,
        zoomMode: ZoomMode.x,
      ),
    );
  }

  // Function to reset the date range
  void resetXAxis() {
    setState(() {
      selectedStartDate = originalStartDate;
      selectedEndDate = originalEndDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Heart Rate and Device Data',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12), // Add spacing
          DropdownButton<String>(
            value: Provider.of<DeviceData>(context).deviceTitles.contains(selectedDevice) ? selectedDevice : Provider.of<DeviceData>(context).deviceTitles.isEmpty ? '' : Provider.of<DeviceData>(context).deviceTitles.first,
            items: Provider.of<DeviceData>(context).deviceTitles.map((String title) {
              return DropdownMenuItem<String>(
                value: title,
                child: Text(title),
              );
            }).toList(),
            onChanged: Provider.of<DeviceData>(context).deviceTitles.isEmpty
                ? null
                : (String? newValue) {
              setState(() {
                selectedDevice = newValue!;
              });
            },
          ),
          const SizedBox(height: 12), // Add spacing
          Expanded(
            child: Center(
              child: _buildChart(),
            ),
          ),
          const SizedBox(height: 10), // Add spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.date_range), // Date Range icon
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _selectStartDate,
                child: const Text(
                  'Select Start Date/Time',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Add spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.date_range), // Date Range icon
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _selectEndDate,
                child: const Text(
                  'Select End Date/Time',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Add spacing
          ElevatedButton(
            onPressed: resetXAxis,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh), // Reset icon
                SizedBox(width: 8),
                Text(
                  'Reset',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
