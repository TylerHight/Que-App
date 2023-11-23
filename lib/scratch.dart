void _updateTimeSeriesData(String title, Duration selectedDuration, int? heartRateThreshold, bool isPeriodicEmissionEnabled, bool isHeartRateEmissionEnabled) {
  final totalSeconds = selectedDuration.inSeconds;
  final deviceData = Provider.of<DeviceData>(context, listen: false);

  DeviceTimeSeriesData newDataPoint = deviceData.getDeviceSettings(widget.deviceTitle);

  if (title == "positive scent duration") {
    newDataPoint.positiveEmissionDuration = totalSeconds;
  } else if (title == "negative scent duration") {
    newDataPoint.negativeEmissionDuration = totalSeconds;
  } else if (title == "time between periodic emissions") {
    newDataPoint.periodicEmissionTimerLength = totalSeconds;
  } else if (title == "heart rate emission duration") {
    newDataPoint.heartRateEmissionDuration = totalSeconds;
  } else if (title == "heart rate threshold") {
    newDataPoint.heartRateThreshold = heartRateThreshold ?? 0;
  } else if (title == "periodic emission toggle") {
    newDataPoint.periodicEmissionOn = isPeriodicEmissionEnabled;
  } else if (title == "heart rate emission toggle") {
    newDataPoint.heartRateEmissionsOn = isHeartRateEmissionEnabled;
  }

  deviceData.addDataPoint(widget.deviceTitle, newDataPoint);
}