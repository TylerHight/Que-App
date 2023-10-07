// generated_hr_data.dart

import 'dart:math';

Map<DateTime, double> generateHeartRateData(
    DateTime startTime,
    DateTime endTime,
    Duration interval,
    ) {
  final heartRateData = <DateTime, double>{};
  final random = Random();

  DateTime currentTime = startTime;

  while (currentTime.isBefore(endTime)) {
    final heartRate = 60 + random.nextDouble() * 40; // Random heart rate between 60 and 100 BPM
    heartRateData[currentTime] = heartRate;
    currentTime = currentTime.add(interval);
  }

  return heartRateData;
}
