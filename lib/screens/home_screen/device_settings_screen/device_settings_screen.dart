// device_settings_screen.dart

import 'package:flutter/material.dart';

class DeviceSettingsScreen extends StatefulWidget {
  final VoidCallback onDelete;

  const DeviceSettingsScreen({Key? key, required this.onDelete}) : super(key: key);

  @override
  _DeviceSettingsScreenState createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  int _selectedPositiveHours = 0;
  int _selectedPositiveMinutes = 0;
  int _selectedPositiveSeconds = 0;

  int _selectedNegativeHours = 0;
  int _selectedNegativeMinutes = 0;
  int _selectedNegativeSeconds = 0;

  int _selectedHours = 0;
  int _selectedMinutes = 0;
  int _selectedSeconds = 0;

  void _selectDuration(BuildContext context, String title) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select $title Duration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDurationDropdown(
                title: 'Hours:',
                value: title == 'Time between periodic emissions'
                    ? _selectedHours
                    : title == 'Positive emission duration'
                    ? _selectedPositiveHours
                    : title == 'Negative emission duration'
                    ? _selectedNegativeHours
                    : 0,
                onChanged: (value) {
                  setState(() {
                    if (title == 'Time between periodic emissions') {
                      _selectedHours = value!;
                    } else if (title == 'Positive emission duration') {
                      _selectedPositiveHours = value!;
                    } else if (title == 'Negative emission duration') {
                      _selectedNegativeHours = value!;
                    }
                  });
                },
                itemCount: 24,
              ),
              _buildDurationDropdown(
                title: 'Minutes:',
                value: title == 'Time between periodic emissions'
                    ? _selectedMinutes
                    : title == 'Positive emission duration'
                    ? _selectedPositiveMinutes
                    : title == 'Negative emission duration'
                    ? _selectedNegativeMinutes
                    : 0,
                onChanged: (value) {
                  setState(() {
                    if (title == 'Time between periodic emissions') {
                      _selectedMinutes = value!;
                    } else if (title == 'Positive emission duration') {
                      _selectedPositiveMinutes = value!;
                    } else if (title == 'Negative emission duration') {
                      _selectedNegativeMinutes = value!;
                    }
                  });
                },
                itemCount: 60,
              ),
              _buildDurationDropdown(
                title: 'Seconds:',
                value: title == 'Time between periodic emissions'
                    ? _selectedSeconds
                    : title == 'Positive emission duration'
                    ? _selectedPositiveSeconds
                    : title == 'Negative emission duration'
                    ? _selectedNegativeSeconds
                    : 0,
                onChanged: (value) {
                  setState(() {
                    if (title == 'Time between periodic emissions') {
                      _selectedSeconds = value!;
                    } else if (title == 'Positive emission duration') {
                      _selectedPositiveSeconds = value!;
                    } else if (title == 'Negative emission duration') {
                      _selectedNegativeSeconds = value!;
                    }
                  });
                },
                itemCount: 60,
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (title == 'Time between periodic emissions') {
                    _selectedDuration = Duration(
                      hours: _selectedHours,
                      minutes: _selectedMinutes,
                      seconds: _selectedSeconds,
                    );
                  } else if (title == 'Positive emission duration') {
                    _selectedPositiveEmissionDuration = Duration(
                      hours: _selectedPositiveHours,
                      minutes: _selectedPositiveMinutes,
                      seconds: _selectedPositiveSeconds,
                    );
                  } else if (title == 'Negative emission duration') {
                    _selectedNegativeEmissionDuration = Duration(
                      hours: _selectedNegativeHours,
                      minutes: _selectedNegativeMinutes,
                      seconds: _selectedNegativeSeconds,
                    );
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Duration? _selectedDuration;
  Duration? _selectedPositiveEmissionDuration;
  Duration? _selectedNegativeEmissionDuration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0), // Increased padding for better spacing
        children: [
          _buildSettingCard(
            title: 'Positive emission duration',
            value: _selectedPositiveEmissionDuration != null
                ? _formatDuration(_selectedPositiveEmissionDuration!)
                : 'Select Duration',
            onTap: () {
              _selectDuration(context, 'Positive emission duration');
            },
          ),
          _buildSettingCard(
            title: 'Negative emission duration',
            value: _selectedNegativeEmissionDuration != null
                ? _formatDuration(_selectedNegativeEmissionDuration!)
                : 'Select Duration',
            onTap: () {
              _selectDuration(context, 'Negative emission duration');
            },
          ),
          _buildSettingCard(
            title: 'Time between periodic emissions',
            value: _selectedDuration != null
                ? _formatDuration(_selectedDuration!)
                : 'Select Duration',
            onTap: () {
              _selectDuration(context, 'Time between periodic emissions');
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: widget.onDelete,
          style: ElevatedButton.styleFrom(
            primary: Colors.red, // Set button color to red
            minimumSize: Size.fromHeight(48), // Increased button height
          ),
          child: const Text(
            'Delete Device',
            style: TextStyle(fontSize: 16.0), // Adjusted font size
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
      margin: EdgeInsets.only(bottom: 16.0), // Increased margin for better separation
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
        onTap: onTap,
        trailing: Icon(Icons.arrow_forward_ios), // Added the arrow icon
      ),
    );
  }

  String _formatDuration(Duration duration) {
    return '${duration.inHours} hours ${duration.inMinutes % 60} minutes ${duration.inSeconds % 60} seconds';
  }

  Widget _buildDurationDropdown({
    required String title,
    required int value,
    required ValueChanged<int?> onChanged,
    required int itemCount,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        DropdownButton<int>(
          value: value,
          onChanged: onChanged,
          items: List.generate(itemCount, (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Text('$index'),
            );
          }),
        ),
      ],
    );
  }
}
