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
        title: Text(
          '${widget.device.deviceName} Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ), // Set title text color to black
        ),
        backgroundColor: Colors.white, // Set the AppBar background color
        elevation: 0, // Remove elevation to match ListView items
        iconTheme: IconThemeData(color: Colors.black), // Set the color of icons in AppBar
        centerTitle: true, // Center align the title
      ),
      body: Container(
        color: Colors.white, // Set the background color of the body (ListView items)
        child: ListView(
          padding: const EdgeInsets.all(16.0), // Add padding to the entire ListView
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
                    _showDurationPickerDialog(context, 'duration for scent one', (device, duration) {
                      device.emission1Duration = duration;
                      print('Updated emission1Duration: ${device.emission1Duration}');
                    });
                  },
                ),
                Divider(),
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
                Divider(),
                _buildListTile(
                  context,
                  title: 'Set Release Interval',
                  icon: Icons.timer,
                  iconColor: _isPeriodicEmissionEnabled ? Colors.blue : Colors.grey,
                  onTap: () {
                    _showDurationPickerDialog(context, 'release interval for scent one', (device, duration) {
                      device.releaseInterval1 = duration;
                      print('Updated releaseInterval1: ${device.releaseInterval1}');
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 8.0), // Reduce the space between cards
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
                    _showDurationPickerDialog(context, 'duration for scent two', (device, duration) {
                      device.emission2Duration = duration;
                      print('Updated emission2Duration: ${device.emission2Duration}');
                    });
                  },
                ),
                Divider(),
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
                Divider(),
                _buildListTile(
                  context,
                  title: 'Set Release Interval',
                  icon: Icons.timer,
                  iconColor: _isPeriodicEmissionEnabled2 ? Colors.green.shade500 : Colors.grey,
                  onTap: () {
                    _showDurationPickerDialog(context, 'release interval for scent two', (device, duration) {
                      device.releaseInterval2 = duration;
                      print('Updated releaseInterval2: ${device.releaseInterval2}');
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 8.0), // Reduce the space between cards
            _buildSettingsGroup(
              context,
              '',
              [
                _buildListTile(
                  context,
                  title: 'Connect to Que',
                  icon: Icons.bluetooth,
                  iconColor: Colors.blue,
                  onTap: () {
                    // Handle connection to Que
                  },
                ),
                Divider(),
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
      margin: EdgeInsets.symmetric(vertical: 4.0), // Reduce vertical margin between cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Curved corners
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
                  fontSize: 18, // Increased font size
                  color: Colors.grey.shade500, // Grey color for titles
                ),
              ),
            if (title.isNotEmpty) SizedBox(height: 8.0),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required void Function() onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.only(right: 8.0), // Adjust this value as needed
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15, // Increased font size
          color: textColor ?? Colors.black,
          fontWeight: FontWeight.w400, // Slightly less than bold
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchListTile(BuildContext context, {
    required String title,
    required bool value,
    required Color iconColor,
    required void Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.only(right: 8.0), // Adjust this value as needed
        child: Icon(
          Icons.timer,
          color: iconColor,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15, // Increased font size
          fontWeight: FontWeight.w400, // Slightly less than bold
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: iconColor, // Set activeColor to match iconColor
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
