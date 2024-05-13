import 'package:flutter/material.dart';
import 'package:que_app/models/device.dart';
import 'duration_selection_dialog.dart';

class SettingsScreen extends StatefulWidget {
  final Device device;

  const SettingsScreen({Key? key, required this.device}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
            trailing: Icon(Icons.air), // Changed to timer icon
            onTap: () {
              _showDurationPickerDialog(context, 'scent one', (device, duration) {
                device.emission1Duration = duration;
                print('Updated emission1Duration: ${device.emission1Duration}');
              });
            },
          ),
          Divider(),
          ListTile(
            title: Text('Scent two duration'),
            trailing: Icon(Icons.air), // Changed to timer icon
            onTap: () {
              _showDurationPickerDialog(context, 'scent two', (device, duration) {
                device.emission2Duration = duration;
                print('Updated emission2Duration: ${device.emission2Duration}');
              });
            },
          ),
          Divider(),
          ListTile(
            title: Text('Account'),
            trailing: Icon(Icons.account_circle),
            onTap: () {
              // Handle account settings
            },
          ),
          Divider(),
          ListTile(
            title: Text('About'),
            trailing: Icon(Icons.info_outline), // Changed to info_outline icon
            onTap: () {
              // Handle about settings
            },
          ),
          Divider(),
          // Add more settings here...
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
      // Update the device with the selected duration
      propertyToUpdate(widget.device, selectedDuration);

      // Print the updated duration along with the setting name
      print('Updated $title duration: $selectedDuration');
    }
  }
}
