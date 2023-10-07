import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'generated_hr_data.dart';

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  Map<DateTime, double> heartRateData = generateHeartRateData(
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 0, 0),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 30, 0),
    Duration(hours: 1),
  );

  DateTime selectedStartDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 0, 0);
  DateTime selectedEndDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 30, 0);

  // Store the original x-axis values for resetting
  DateTime originalStartDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 0, 0);
  DateTime originalEndDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 30, 0);

  @override
  Widget build(BuildContext context) {
    double minY = heartRateData.values.reduce((min, val) => val < min ? val : min).toDouble();
    double maxY = heartRateData.values.reduce((max, val) => val > max ? val : max).toDouble();

    minY = (minY / 5).floor() * 5;
    maxY = ((maxY + 4) / 5).ceil() * 5;

    void resetXAxis() {
      setState(() {
        selectedStartDate = originalStartDate;
        selectedEndDate = originalEndDate;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate and Device Data'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 0),
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: Text(
                        'Heart Rate (BPM)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 0, right: 20, top: 20, bottom: 20),
                      child: SfCartesianChart(
                        primaryXAxis: DateTimeAxis(
                          minimum: selectedStartDate,
                          maximum: selectedEndDate,
                        ),
                        primaryYAxis: NumericAxis(
                          minimum: minY,
                          maximum: maxY,
                          interval: 5,
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Start Date: '),
                TextButton(
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: selectedStartDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    ).then((date) {
                      if (date != null) {
                        setState(() {
                          selectedStartDate = date;
                        });
                      }
                    });
                  },
                  child: Text(
                    "${selectedStartDate.toLocal()}".split(' ')[0],
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(width: 10),
                Text('End Date: '),
                TextButton(
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: selectedEndDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    ).then((date) {
                      if (date != null) {
                        setState(() {
                          selectedEndDate = date;
                        });
                      }
                    });
                  },
                  child: Text(
                    "${selectedEndDate.toLocal()}".split(' ')[0],
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          // Add a Reset button
          ElevatedButton(
            onPressed: resetXAxis,
            child: Text('Reset X-Axis'),
          ),
        ],
      ),
    );
  }
}
