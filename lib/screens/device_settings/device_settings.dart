import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import 'package:que_app/models/device.dart';
import 'package:que_app/models/device_list.dart';
import 'package:que_app/screens/device_control/add_device_dialog.dart';
import 'package:que_app/screens/device_settings/delete_device_dialog.dart';
import 'duration_selection_dialog.dart';
import 'heart_rate_threshold_dialog.dart';

class SettingsScreen extends StatefulWidget {
  final Device device;

  const SettingsScreen({Key? key, required this.device}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isPeriodicEmissionEnabled;
  late bool _isPeriodicEmissionEnabled2;

  @override
  void initState() {
    super.initState();
    _isPeriodicEmissionEnabled = widget.device.isPeriodicEmissionEnabled;
    _isPeriodicEmissionEnabled2 = widget.device.isPeriodicEmissionEnabled2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.device.deviceName} Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            _buildSettingsGroup(
              context,
              'Scent One Settings',
              [
                _buildListTile(
                  context,
                  title: 'Set Release Duration',
                  icon: Icons.air,
                  iconColor: Colors.lightBlue.shade400,
                  onTap: () {
                    _showDurationPickerDialog(
                      context,
                      'scent one duration',
                      widget.device.emission1Duration,
                          (device, duration) {
                        device.emission1Duration = duration;
                        print('Updated emission1Duration: ${device.emission1Duration}');
                      },
                    );
                  },
                ),
                _buildSwitchListTile(
                  context,
                  title: 'Periodic Emissions',
                  value: _isPeriodicEmissionEnabled,
                  iconColor: _isPeriodicEmissionEnabled ? Colors.blue : Colors.grey,
                  onChanged: (value) {
                    setState(() {
                      _isPeriodicEmissionEnabled = value;
                    });
                    widget.device.isPeriodicEmissionEnabled = value;
                  },
                ),
                _buildListTile(
                  context,
                  title: 'Set Release Interval',
                  icon: Icons.timer,
                  iconColor: _isPeriodicEmissionEnabled ? Colors.blue : Colors.grey,
                  onTap: () {
                    _showDurationPickerDialog(
                      context,
                      'scent one interval',
                      widget.device.releaseInterval1,
                          (device, duration) {
                        device.releaseInterval1 = duration;
                        print('Updated releaseInterval1: ${device.releaseInterval1}');
                      },
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 8.0),
            _buildSettingsGroup(
              context,
              'Scent Two Settings',
              [
                _buildListTile(
                  context,
                  title: 'Set Release Duration',
                  icon: Icons.air,
                  iconColor: Colors.green.shade500,
                  onTap: () {
                    _showDurationPickerDialog(
                      context,
                      'scent two duration',
                      widget.device.emission2Duration,
                          (device, duration) {
                        device.emission2Duration = duration;
                        print('Updated emission2Duration: ${device.emission2Duration}');
                      },
                    );
                  },
                ),
                _buildSwitchListTile(
                  context,
                  title: 'Periodic Emissions',
                  value: _isPeriodicEmissionEnabled2,
                  iconColor: _isPeriodicEmissionEnabled2 ? Colors.green.shade500 : Colors.grey,
                  onChanged: (value) {
                    setState(() {
                      _isPeriodicEmissionEnabled2 = value;
                    });
                    widget.device.isPeriodicEmissionEnabled2 = value;
                  },
                ),
                _buildListTile(
                  context,
                  title: 'Set Release Interval',
                  icon: Icons.timer,
                  iconColor: _isPeriodicEmissionEnabled2 ? Colors.green.shade500 : Colors.grey,
                  onTap: () {
                    _showDurationPickerDialog(
                      context,
                      'scent two interval',
                      widget.device.releaseInterval2,
                          (device, duration) {
                        device.releaseInterval2 = duration;
                        print('Updated releaseInterval2: ${device.releaseInterval2}');
                      },
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 8.0),
            _buildSettingsGroup(
              context,
              'Heart Rate Settings',
              [
                _buildListTile(
                  context,
                  title: 'Connect to heart rate monitor',
                  icon: Icons.bluetooth,
                  iconColor: Colors.blue,
                  onTap: () {
                    // Handle connection to heart rate monitor
                  },
                ),
                _buildListTile(
                  context,
                  title: 'Set heart rate threshold',
                  icon: Icons.favorite,
                  iconColor: Colors.red,
                  onTap: () {
                    _showHeartRateThresholdDialog(
                      context,
                      'Set heart rate threshold',
                      widget.device.heartrateThreshold,
                          (device, threshold) {
                        device.heartrateThreshold = threshold;
                        print('Updated heartrateThreshold: ${device.heartrateThreshold}');
                      },
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 8.0),
            _buildSettingsGroup(
              context,
              'Device',
              [
                _buildListTile(
                  context,
                  title: 'Connect to Que',
                  icon: Icons.bluetooth,
                  iconColor: Colors.blue,
                  onTap: () {
                    _showBluetoothDeviceListDialog(context);
                  },
                ),
                _buildListTile(
                  context,
                  title: 'Delete Device',
                  icon: Icons.delete,
                  iconColor: Colors.red,
                  onTap: _showDeleteDeviceDialog,
                  textColor: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade500,
                ),
              ),
            if (title.isNotEmpty) SizedBox(height: 8.0),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required String title,
        required IconData icon,
        required Color iconColor,
        required void Function() onTap,
        Color? textColor}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.only(right: 8.0),
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: textColor ?? Colors.black,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchListTile(BuildContext context,
      {required String title,
        required bool value,
        required Color iconColor,
        required void Function(bool) onChanged}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.only(right: 8.0),
        child: Icon(
          Icons.timer,
          color: iconColor,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: iconColor,
      ),
    );
  }

  void _showDurationPickerDialog(BuildContext context, String title,
      Duration currentDuration, void Function(Device, Duration) propertyToUpdate) async {
    final selectedDuration = await showDialog<Duration>(
      context: context,
      builder: (BuildContext context) {
        return DurationSelectionDialog(
          title: title,
          icon: Icons.timer,
          iconColor: Colors.blue,
          durationSeconds: currentDuration,
        );
      },
    );
    if (selectedDuration != null) {
      propertyToUpdate(widget.device, selectedDuration);
      print('Updated $title duration: $selectedDuration');
    }
  }

  void _showHeartRateThresholdDialog(BuildContext context, String title,
      int currentThreshold, void Function(Device, int) propertyToUpdate) async {
    final selectedThreshold = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return HeartRateThresholdDialog(
          title: title,
          currentThreshold: currentThreshold,
        );
      },
    );
    if (selectedThreshold != null) {
      propertyToUpdate(widget.device, selectedThreshold);
      print('Updated $title threshold: $selectedThreshold');
    }
  }

  void _showBluetoothDeviceListDialog(BuildContext context) async {
    // Simulate selecting a Bluetooth device (replace with your actual logic)
    // For demonstration purposes, assume the first device in a list
    List<BluetoothDevice> devices = []; // Replace with your list of Bluetooth devices
    BluetoothDevice? selectedDevice = devices.isNotEmpty ? devices.first : null;

    // If a device is selected, connect to it and show the AddDeviceDialog
    if (selectedDevice != null) {
      _connectToDevice(selectedDevice);

      // Show AddDeviceDialog immediately after selecting a device
      final result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddDeviceDialog(
            onDeviceAdded: (Device newDevice) {
              Provider.of<DeviceList>(context, listen: false).add(newDevice);
            },
          );
        },
      );

      // Handle the result if needed
      if (result != null) {
        print('AddDeviceDialog result: $result');
      }
    } else {
      // If no devices are available, you can handle this case (optional)
      print('No devices available');
    }
  }

  void _connectToDevice(device) {
    // Implement your logic to connect to the Bluetooth device here
    print('Connecting to device: ${device.deviceName}');
    // Example: BleService.connectToDevice(device);
  }

  void _showDeleteDeviceDialog() {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return DeleteDeviceDialog(
          device: widget.device,
        );
      },
    ).then((result) {
      if (result == true) {
        // Perform additional actions after deletion if necessary
        print('Device deletion confirmed');
        Provider.of<DeviceList>(context, listen: false).remove(widget.device);
        Navigator.of(context).pop(); // Close the settings screen
      } else {
        print('Device deletion canceled');
      }
    });
  }


}
