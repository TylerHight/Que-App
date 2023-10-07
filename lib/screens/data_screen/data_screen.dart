import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'data/generated_hr_data.dart';

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

  DateTime originalStartDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 0, 0);
  DateTime originalEndDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 30, 0);

  final TextStyle textStyle = TextStyle(fontSize: 15);

  void resetXAxis() {
    setState(() {
      selectedStartDate = originalStartDate;
      selectedEndDate = originalEndDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    double minY = heartRateData.values.reduce((min, val) => val < min ? val : min).toDouble();
    double maxY = heartRateData.values.reduce((max, val) => val > max ? val : max).toDouble();

    minY = (minY / 5).floor() * 5;
    maxY = ((maxY + 4) / 5).ceil() * 5;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate and Device Data'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  minimum: selectedStartDate,
                  maximum: selectedEndDate,
                  isVisible: true, // Enable x-axis visibility
                  zoomFactor: 1.0, // Set zoom factor
                  zoomPosition: 1.0, // Set zoom position
                  enableAutoIntervalOnZooming: true, // Auto-calculate interval on zooming
                  intervalType: DateTimeIntervalType.hours, // Set interval type
                ),
                primaryYAxis: NumericAxis(
                  minimum: minY,
                  maximum: maxY,
                  isVisible: true, // Enable y-axis visibility
                  interval: 5,
                ),
                series: <ChartSeries>[
                  LineSeries<MapEntry<DateTime, double>, DateTime>(
                    dataSource: heartRateData.entries.toList(),
                    xValueMapper: (MapEntry<DateTime, double> entry, _) => entry.key,
                    yValueMapper: (MapEntry<DateTime, double> entry, _) => entry.value,
                  ),
                ],
                // Enable zooming and panning
                zoomPanBehavior: ZoomPanBehavior(
                  enablePanning: true, // Enable panning
                  enablePinching: true, // Enable pinching to zoom
                  enableMouseWheelZooming: true,
                  zoomMode: ZoomMode.x, // Zoom only in the x-axis direction
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Start: ', style: textStyle),
                ElevatedButton(
                  onPressed: () async {
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
                  },
                  child: Text(
                    "${selectedStartDate.toLocal()}".split(' ')[0] +
                        " ${TimeOfDay.fromDateTime(selectedStartDate).format(context)}",
                    style: textStyle,
                  ),
                ),
                SizedBox(width: 10),
                Text('End: ', style: textStyle),
                ElevatedButton(
                  onPressed: () async {
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
                  },
                  child: Text(
                    "${selectedEndDate.toLocal()}".split(' ')[0] +
                        " ${TimeOfDay.fromDateTime(selectedEndDate).format(context)}",
                    style: textStyle,
                  ),
                ),
              ],
            ),
          ),
          // Add padding below the Reset button
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: resetXAxis,
              child: Text('Reset', style: textStyle),
            ),
          ),
        ],
      ),
    );
  }
}
