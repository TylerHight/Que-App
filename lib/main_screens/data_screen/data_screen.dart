import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'generated_hr_data.dart';

class DataScreen extends StatelessWidget {
  Map<DateTime, double> heartRateData = generateHeartRateData(
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 0, 0), // Start at 8:00 AM
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 30, 0), // End at 5:00 PM
    Duration(seconds: 30), // 30-second intervals
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Heartrate and Device Data'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
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
                  rotateAngle: 45, // Rotate labels for better readability
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
              minX: heartRateData.keys.first.millisecondsSinceEpoch.toDouble(),
              maxX: heartRateData.keys.last.millisecondsSinceEpoch.toDouble(),
              minY: heartRateData.values.reduce((min, val) => val < min ? val : min).toDouble(),
              maxY: heartRateData.values.reduce((max, val) => val > max ? val : max).toDouble(),
              lineBarsData: [
                LineChartBarData(
                  spots: heartRateData.entries
                      .map((entry) => FlSpot(
                      entry.key.millisecondsSinceEpoch.toDouble(),
                      entry.value))
                      .toList(),
                  isCurved: true,
                  colors: [Colors.red],
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
