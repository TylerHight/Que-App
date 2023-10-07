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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heartrate and Device Data'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text('Show most recent '),
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
                const Text(' hrs'),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(),
                primaryYAxis: NumericAxis(
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
          ),
        ],
      ),
    );
  }
}
