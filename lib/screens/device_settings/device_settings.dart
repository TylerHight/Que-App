import 'package:flutter/material.dart';
import 'package:que_app/models/device.dart';
import 'duration_selection_dialog.dart';
import 'delete_device_dialog.dart'; // Import the DeleteDeviceDialog
import 'package:provider/provider.dart';
import 'package:que_app/models/device_list.dart';

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
        title: Text('${widget.device.deviceName} Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Scent one duration'),
            trailing: Icon(
              Icons.air,
              color: Colors.lightBlue.shade400,
            ),
            onTap: () {
              _showDurationPickerDialog(context, 'scent one', (device, duration) {
                device.emission1Duration = duration;
                print('Updated emission1Duration: ${device.emission1Duration}');
              });
            },
          ),
          Divider(),
          ListTile(
            title: Text('Periodic emissions for scent one'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: _isPeriodicEmissionEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isPeriodicEmissionEnabled = value;
                    });
                    widget.device.isPeriodicEmissionEnabled = value;
                  },
                ),
                Icon(
                  Icons.timer,
                  color: _isPeriodicEmissionEnabled ? Colors.blue : Colors.grey,
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('Periodic emission interval for scent one'),
            trailing: Icon(
              Icons.timer,
              color: Colors.grey,
            ),
            onTap: () {
              _showDurationPickerDialog(context, 'periodic emission interval for scent two', (device, duration) {
                device.emission1Duration = duration;
                print('Updated emission1Duration: ${device.emission1Duration}');
              });
            },
          ),
          Divider(),
          ListTile(
            title: Text('Scent two duration'),
            trailing: Icon(
              Icons.air,
              color: Colors.green.shade500,
            ),
            onTap: () {
              _showDurationPickerDialog(context, 'scent two', (device, duration) {
                device.emission2Duration = duration;
                print('Updated emission2Duration: ${device.emission2Duration}');
              });
            },
          ),
          Divider(),
          ListTile(
            title: Text('Periodic emissions for scent two'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: _isPeriodicEmissionEnabled2,
                  onChanged: (value) {
                    setState(() {
                      _isPeriodicEmissionEnabled2 = value;
                    });
                    widget.device.isPeriodicEmissionEnabled = value;
                  },
                ),
                Icon(
                  Icons.timer,
                  color: _isPeriodicEmissionEnabled2 ? Colors.blue : Colors.grey,
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Periodic emission interval for scent two'),
            trailing: Icon(
              Icons.timer,
              color: Colors.grey,
            ),
            onTap: () {
              _showDurationPickerDialog(context, 'periodic emission interval for scent two', (device, duration) {
                device.emission1Duration = duration;
                print('Updated emission1Duration: ${device.emission1Duration}');
              });
            },
          ),
          Divider(),
          ListTile(
            title: Text('Connect to Que'),
            trailing: Icon(
              Icons.bluetooth,
              color: Colors.blue,
            ),
            onTap: () {
              // Handle connection to Que
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
            trailing: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onTap: _showDeleteDeviceDialog,
          ),
          Divider(),
        ],
      ),
    );
  }

  void _showDurationPickerDialog(BuildContext context, String title, void Function(Device, Duration) propertyToUpdate) async {
    final selectedDuration = await showDialog<Duration>(
      context: context,
      builder: (BuildContext context) {
        return DurationSelectionDialog(title: title);
      },
    );
    if (selectedDuration != null) {
      propertyToUpdate(widget.device, selectedDuration);
      print('Updated $title duration: $selectedDuration');
    }
  }

  void _showDeleteDeviceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteDeviceDialog(
          deviceName: widget.device.deviceName,
          onDelete: () {
            Provider.of<DeviceList>(context, listen: false).remove(widget.device);
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

