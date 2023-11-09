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
  };

  bool isPeriodicEmissionEnabled = false; // Initially, it's disabled

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Load the settings when the screen is first created
  }

  /// Load device settings from the data provider
  void _loadSettings() {
    final deviceData = Provider.of<DeviceData>(context, listen: false);
    final deviceSettings = deviceData.getDeviceSettings(widget.deviceTitle);

    setState(() {
      // Update the _selectedDurations map with the current values from deviceSettings
      _selectedDurations['positive scent duration'] =
          Duration(seconds: deviceSettings.positiveEmissionDuration);
      _selectedDurations['negative scent duration'] =
          Duration(seconds: deviceSettings.negativeEmissionDuration);
      _selectedDurations['time between periodic emissions'] =
          Duration(seconds: deviceSettings.periodicEmissionTimerLength);
      isPeriodicEmissionEnabled = deviceSettings.periodicEmission;
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
            title: 'Time between periodic emissions',
            value: isPeriodicEmissionEnabled
                ? _formatDuration(_selectedDurations['time between periodic emissions']!)
                : 'Off',
            onTap: () {
              _selectDuration(context, 'time between periodic emissions');
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
  }) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        title: Text(title),
        subtitle: title == 'Time between periodic emissions'
            ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Switch(
              value: isPeriodicEmissionEnabled,
              onChanged: (newValue) {
                setState(() {
                  isPeriodicEmissionEnabled = newValue;
                });
              },
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

      _updateTimeSeriesData(title, selectedDuration);
    }
  }

  void _updateTimeSeriesData(String title, Duration selectedDuration) {
    final totalSeconds = selectedDuration.inSeconds;
    final deviceData = Provider.of<DeviceData>(context, listen: false);

    DeviceTimeSeriesData newDataPoint = deviceData.getDeviceSettings(widget.deviceTitle);

    if (title == "positive scent duration") {
      newDataPoint.positiveEmissionDuration = totalSeconds;
    } else if (title == "negative scent duration") {
      newDataPoint.negativeEmissionDuration = totalSeconds;
    } else if (title == "time between periodic emissions") {
      newDataPoint.periodicEmissionTimerLength = totalSeconds;
    }

    deviceData.addDataPoint(widget.deviceTitle, newDataPoint);
  }
}