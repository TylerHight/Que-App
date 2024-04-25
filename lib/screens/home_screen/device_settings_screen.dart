/// device_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:que_app/device_data.dart';
import 'package:provider/provider.dart';
import 'utils/duration_picker_dialog.dart';
import 'utils/heart_rate_monitor_connection.dart';
import 'package:que_app/ble_control.dart';

class DeviceSettingsScreen extends StatefulWidget {
  final VoidCallback onDelete;
  final String deviceTitle;

  const DeviceSettingsScreen({Key? key, required this.onDelete, required this.deviceTitle}) : super(key: key);

  @override
  _DeviceSettingsScreenState createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  late final BleControl _bleController = BleControl();

  final Map<String, Duration?> _selectedDurations = {
    'positive scent duration': null,
    'negative scent duration': null,
    'time between periodic emissions': null,
    'heart rate emission duration': null,
  };

  int _heartRateThreshold = 0;

  bool isPeriodicEmissionEnabled = false;
  bool isHeartRateEmissionEnabled = false;
  bool isPositiveEmissionEnabled = false;
  bool isNegativeEmissionEnabled = false;

  late DeviceData deviceData; // Declare a variable to hold DeviceData instance

  @override
  void initState() {
    super.initState();
    // Retrieve DeviceData instance in initState
    deviceData = Provider.of<DeviceData>(context, listen: false);
    // Load settings when the screen initializes
    _loadSettings();
  }

  void _loadSettings() {
    // Access device settings using deviceData
    final deviceSettings = deviceData.getDeviceSettings(widget.deviceTitle);
    // Update the state with the loaded settings
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
      isPeriodicEmissionEnabled = deviceSettings.periodicEmissionEnabled;
      isHeartRateEmissionEnabled = deviceSettings.heartRateEmissionsEnabled;
      isPositiveEmissionEnabled = deviceSettings.positiveEmissionsEnabled;
      isNegativeEmissionEnabled = deviceSettings.negativeEmissionsEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.deviceTitle} Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Other settings widgets...
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
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
    if (title.toLowerCase() == 'connect to heart rate monitor') {
      return _buildBluetoothConnectionSetting();
    }

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.only(bottom: 16.0),
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
            Text(switchValue ? value : 'Off'), // Show 'Off' when the switch is off
          ],
        )
            : Text(value),
        onTap: onTap,
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Widget _buildBluetoothDeviceIDSetting(String deviceTitle) {
    final deviceData = Provider.of<DeviceData>(context);
    final deviceSettings = deviceData.getDeviceSettings(deviceTitle);
    String bluetoothDeviceID = deviceSettings.bluetoothDeviceID ?? ''; // Get the Bluetooth device ID

    // Retrieve the connected Bluetooth device name using the BLEController
    String bluetoothDeviceName = _bleController.connectedDevice?.name ?? 'Not connected';

    return _buildSettingCard(
      title: 'Bluetooth Device',
      value: bluetoothDeviceName.isNotEmpty ? bluetoothDeviceName : 'Not connected',
      onTap: () {}, // You can define an action here if needed
    );
  }



  Widget _buildBluetoothConnectionSetting() {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        title: const Text('Connect to heart rate monitor'),
        subtitle: _buildConnectedDeviceSubtitle(false),
        onTap: () {
          //_selectBluetoothDevice(context);
        },
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Widget _buildConnectedDeviceSubtitle(bool isConnected) {
    String dummyDeviceName = 'Simulated Heart Rate Device';

    if (isConnected) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Connected to:'),
          Text(
            dummyDeviceName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      return const Text('Not connected');
    }
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
      _updateTimeSeriesData(title, selectedDuration, null, isPeriodicEmissionEnabled, isHeartRateEmissionEnabled, isPositiveEmissionEnabled, isNegativeEmissionEnabled);
    }
  }

  Future<void> _selectHeartRateThreshold(BuildContext context) async {
    int? selectedHeartRateThreshold = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        int? enteredHeartRateThreshold;
        return AlertDialog(
          title: const Text('Select Heart Rate Threshold'),
          content: SizedBox(
            width: double.minPositive,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose a heart rate threshold:'),
                SizedBox(
                  width: 80,
                  child: DropdownButtonFormField<int>(
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
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(enteredHeartRateThreshold);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (selectedHeartRateThreshold != null) {
      setState(() {
        _heartRateThreshold = selectedHeartRateThreshold;
      });

      _updateTimeSeriesData('heart rate threshold', Duration.zero, selectedHeartRateThreshold, isPeriodicEmissionEnabled, isHeartRateEmissionEnabled, isPositiveEmissionEnabled, isNegativeEmissionEnabled);
    }
  }

  void _updateTimeSeriesData(String title, Duration selectedDuration, int? heartRateThreshold, bool isPeriodicEmissionEnabled, bool isHeartRateEmissionEnabled, bool isPositiveEmissionsEnabled, bool isNegativeEmissionsEnabled) {
    final totalSeconds = selectedDuration.inSeconds;
    final deviceData = Provider.of<DeviceData>(context, listen: false);

    DeviceTimeSeriesData newDataPoint = deviceData.getDeviceSettings(widget.deviceTitle);

    if (title == "positive scent duration") {
      newDataPoint.positiveEmissionDuration = isPositiveEmissionsEnabled ? totalSeconds : 0;
    } else if (title == "negative scent duration") {
      newDataPoint.negativeEmissionDuration = isNegativeEmissionsEnabled ? totalSeconds : 0;
    } else if (title == "time between periodic emissions") {
      newDataPoint.periodicEmissionTimerLength = isPeriodicEmissionEnabled ? totalSeconds : 0;
    } else if (title == "heart rate emission duration") {
      newDataPoint.heartRateEmissionDuration = isHeartRateEmissionEnabled ? totalSeconds : 0;
    } else if (title == "heart rate threshold") {
      newDataPoint.heartRateThreshold = heartRateThreshold ?? 0;
    } else if (title == "periodic emission toggle") {
      newDataPoint.periodicEmissionEnabled = isPeriodicEmissionEnabled;
    } else if (title == "heart rate emission toggle") {
      newDataPoint.heartRateEmissionsEnabled = isHeartRateEmissionEnabled;
    } else if (title == "positive emission toggle") {
      newDataPoint.positiveEmissionsEnabled = isPositiveEmissionsEnabled;
      if (!isPositiveEmissionsEnabled) {
        newDataPoint.positiveEmissionDuration = 0;
      }
    } else if (title == "negative emission toggle") {
      newDataPoint.negativeEmissionsEnabled = isNegativeEmissionsEnabled;
      if (!isNegativeEmissionsEnabled) {
        newDataPoint.negativeEmissionDuration = 0;
      }
    }

    deviceData.addDataPoint(widget.deviceTitle, newDataPoint);
  }

}
