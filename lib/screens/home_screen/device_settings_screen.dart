// device_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:que_app/device_data.dart';
import 'package:provider/provider.dart';
import 'utils/duration_picker_dialog.dart';

class DeviceSettingsScreen extends StatefulWidget {
  final VoidCallback onDelete;
  final String deviceTitle;

  const DeviceSettingsScreen({Key? key, required this.onDelete, required this.deviceTitle}) : super(key: key);

  @override
  _DeviceSettingsScreenState createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  Map<String, Duration?> _selectedDurations = {
    'positive scent duration': null,
    'negative scent duration': null,
    'time between periodic emissions': null,
    'heart rate emission duration': null,
  };

  int _heartRateThreshold = 0;

  bool isPeriodicEmissionEnabled = false;
  bool isHeartRateEmissionEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final deviceData = Provider.of<DeviceData>(context, listen: false);
    final deviceSettings = deviceData.getDeviceSettings(widget.deviceTitle);

    setState(() {
      _selectedDurations['positive scent duration'] =
          Duration(seconds: deviceSettings.positiveEmissionDuration);
      _selectedDurations['negative scent duration'] =
          Duration(seconds: deviceSettings.negativeEmissionDuration);
      _selectedDurations['time between periodic emissions'] =
          Duration(seconds: deviceSettings.periodicEmissionTimerLength);
      _selectedDurations['heart rate emission duration'] =
          Duration(seconds: deviceSettings.heartRateEmissionDuration);
      _heartRateThreshold = deviceSettings.heartRateThreshold;
      isPeriodicEmissionEnabled = deviceSettings.periodicEmissionOn;
      isHeartRateEmissionEnabled = deviceSettings.heartRateEmissionsOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.deviceTitle} Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildSettingCard(
            title: 'Positive scent duration',
            value: _selectedDurations['positive scent duration'] != null
                ? _formatDuration(_selectedDurations['positive scent duration']!)
                : 'Select duration',
            onTap: () {
              _selectDuration(context, 'positive scent duration');
            },
          ),
          _buildSettingCard(
            title: 'Negative scent duration',
            value: _selectedDurations['negative scent duration'] != null
                ? _formatDuration(_selectedDurations['negative scent duration']!)
                : 'Select duration',
            onTap: () {
              _selectDuration(context, 'negative scent duration');
            },
          ),
          _buildSettingCard(
            title: 'Periodic emission timer',
            value: isPeriodicEmissionEnabled
                ? _formatDuration(_selectedDurations['time between periodic emissions']!)
                : 'Off',
            onTap: () {
              _selectDuration(context, 'time between periodic emissions');
            },
            isSwitch: true,
            switchValue: isPeriodicEmissionEnabled,
            onSwitchChanged: (newValue) {
              setState(() {
                isPeriodicEmissionEnabled = newValue;
                _updateTimeSeriesData('periodic emission toggle', Duration.zero, null, isPeriodicEmissionEnabled, isHeartRateEmissionEnabled);
              });
            },
          ),
          _buildSettingCard(
            title: 'Heart rate emission duration',
            value: isHeartRateEmissionEnabled
                ? _formatDuration(_selectedDurations['heart rate emission duration']!)
                : 'Off',
            onTap: () {
              _selectDuration(context, 'heart rate emission duration');
            },
            isSwitch: true,
            switchValue: isHeartRateEmissionEnabled,
            onSwitchChanged: (newValue) {
              setState(() {
                isHeartRateEmissionEnabled = newValue;
              });
              _updateTimeSeriesData('heart rate emission toggle', Duration.zero, null, isPeriodicEmissionEnabled, isHeartRateEmissionEnabled);
            },
          ),
          _buildSettingCard(
            title: 'Heart rate threshold',
            value: _heartRateThreshold.toString(),
            onTap: () {
              _selectHeartRateThreshold(context);
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: widget.onDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size(50, 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 4,
          ),
          child: const Text(
            'Delete Device',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String value,
    required VoidCallback onTap,
    bool isSwitch = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        title: Text(title),
        subtitle: isSwitch
            ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Switch(
              value: switchValue,
              onChanged: onSwitchChanged,
            ),
            Text(value),
          ],
        )
            : Text(value),
        onTap: onTap,
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    return '${duration.inHours} hours ${duration.inMinutes % 60} minutes ${duration.inSeconds % 60} seconds';
  }

  Future<void> _selectDuration(BuildContext context, String title) async {
    final Duration? selectedDuration = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DurationPickerDialog(
          title: title,
          initialDuration: _selectedDurations[title],
          isPeriodicEmissionEnabled: isPeriodicEmissionEnabled,
        );
      },
    );

    if (selectedDuration != null) {
      print("Selected duration: $selectedDuration");
      setState(() {
        _selectedDurations[title] = selectedDuration;
      });
      _updateTimeSeriesData(title, selectedDuration, null, isPeriodicEmissionEnabled, isHeartRateEmissionEnabled);
    }
  }

  Future<void> _selectHeartRateThreshold(BuildContext context) async {
    int? selectedHeartRateThreshold = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int? enteredHeartRateThreshold;
        return AlertDialog(
          title: Text('Select Heart Rate Threshold'),
          content: Container(
            width: double.minPositive,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Choose a heart rate threshold:'),
                DropdownButton<int>(
                  value: _heartRateThreshold,
                  items: List.generate(200, (index) => index + 1)
                      .map((value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      enteredHeartRateThreshold = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(enteredHeartRateThreshold);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    if (selectedHeartRateThreshold != null) {
      setState(() {
        _heartRateThreshold = selectedHeartRateThreshold;
      });

      _updateTimeSeriesData('heart rate threshold', Duration.zero, selectedHeartRateThreshold, isPeriodicEmissionEnabled, isHeartRateEmissionEnabled);
    }
  }



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
}
