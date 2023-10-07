import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

  double leftPadding = 8.0;
  double rightPadding = 16;
  double topPadding = 8.0;
  double bottomPadding = 32;

  // Custom function to format time
  String formatTime(int hour, int minute) {
    String period = 'AM';
    if (hour >= 12) {
      period = 'PM';
      if (hour > 12) {
        hour -= 12;
      }
    }
    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }

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
              child: Padding(
                padding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
                child: Row(
                  children: [
                    // Y-axis title
                    RotatedBox(
                      quarterTurns: -1, // Rotate counterclockwise
                      child: Text(
                        'Heart Rate (BPM)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 20), // Adjust the spacing between title and chart
                    Expanded( // Ensure the chart takes up available space
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawHorizontalLine: true,
                            drawVerticalLine: true,
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              margin: 10,
                            ),
                            bottomTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              margin: 10,
                              rotateAngle: 90, // Rotate labels to be vertical
                              getTitles: (value) {
                                final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                                final int hour = dateTime.hour;
                                final int minute = dateTime.minute;

                                // Check if it's outside the desired range (8 AM - 5 PM)
                                if (hour < 8 || (hour == 17 && minute > 0) || hour > 17) {
                                  return '';
                                }

                                return formatTime(hour, minute);
                              },
                            ),
                            topTitles: SideTitles(
                              showTitles: false,
                            ),
                            rightTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: const Color(0xff37434d), width: 1),
                          ),
                          minX: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 0, 0).millisecondsSinceEpoch.toDouble(),
                          maxX: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 30, 0).millisecondsSinceEpoch.toDouble(),
                          minY: heartRateData.values.reduce((min, val) => val < min ? val : min).toDouble(),
                          maxY: heartRateData.values.reduce((max, val) => val > max ? val : max).toDouble(),
                          lineBarsData: [
                            LineChartBarData(
                              spots: heartRateData.entries
                                  .map((entry) => FlSpot(
                                entry.key.millisecondsSinceEpoch.toDouble(),
                                entry.value,
                              ))
                                  .toList(),
                              isCurved: false,
                              colors: [Colors.blue],
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
