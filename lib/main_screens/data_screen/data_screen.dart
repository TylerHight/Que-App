import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'generated_hr_data.dart';

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  Map<DateTime, double> heartRateData = generateHeartRateData(
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 0, 0), // Start at 8:00 AM
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 30, 0), // End at 5:00 PM
    Duration(hours: 1), // 1-hour intervals
  );

  int recentHoursToShow = 8; // Default value

  @override
  Widget build(BuildContext context) {
    double minY = heartRateData.values.reduce((min, val) => val < min ? val : min).toDouble();
    double maxY = heartRateData.values.reduce((max, val) => val > max ? val : max).toDouble();

    // Calculate minY and maxY rounding to the nearest multiple of 5
    minY = (minY / 5).floor() * 5;
    maxY = ((maxY + 4) / 5).ceil() * 5;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heartrate and Device Data'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Row(
                children: [
                  // Y-axis title
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 0),
                    child: RotatedBox(
                      quarterTurns: -1, // Rotate counterclockwise
                      child: Text(
                        'Heart Rate (BPM)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Chart
                  Expanded(
                    child: SfCartesianChart(
                      primaryXAxis: DateTimeAxis(),
                      primaryYAxis: NumericAxis(
                        minimum: minY, // Set the minimum value of the y-axis
                        maximum: maxY, // Set the maximum value of the y-axis
                        interval: 5, // Set the interval to 5 to show labels in multiples of 5
                      ),
                      series: <ChartSeries>[
                        LineSeries<MapEntry<DateTime, double>, DateTime>(
                          dataSource: heartRateData.entries.toList(),
                          xValueMapper: (MapEntry<DateTime, double> entry, _) => entry.key,
                          yValueMapper: (MapEntry<DateTime, double> entry, _) => entry.value,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align to the right
              children: [
                const Text('hours: '),
                SizedBox(
                  width: 60,
                  height: 50,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        recentHoursToShow = int.tryParse(value) ?? 8;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
