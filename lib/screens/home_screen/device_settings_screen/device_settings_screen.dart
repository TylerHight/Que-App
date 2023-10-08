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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Hours:'),
                  DropdownButton<int>(
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
                    items: List.generate(24, (index) {
                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text('$index'),
                      );
                    }),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Minutes:'),
                  DropdownButton<int>(
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
                    items: List.generate(60, (index) {
                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text('$index'),
                      );
                    }),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Seconds:'),
                  DropdownButton<int>(
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
                    items: List.generate(60, (index) {
                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text('$index'),
                      );
                    }),
                  ),
                ],
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
        padding: EdgeInsets.all(4.0),
        children: [
          _buildSettingCard(
            title: 'Positive emission duration',
            value: _selectedPositiveEmissionDuration != null
                ? '${_selectedPositiveEmissionDuration!.inHours} hours ${(_selectedPositiveEmissionDuration!.inMinutes % 60)} minutes ${(_selectedPositiveEmissionDuration!.inSeconds % 60)} seconds'
                : 'Select Duration',
            onTap: () {
              _selectDuration(context, 'Positive emission duration');
            },
          ),
          _buildSettingCard(
            title: 'Negative emission duration',
            value: _selectedNegativeEmissionDuration != null
                ? '${_selectedNegativeEmissionDuration!.inHours} hours ${(_selectedNegativeEmissionDuration!.inMinutes % 60)} minutes ${(_selectedNegativeEmissionDuration!.inSeconds % 60)} seconds'
                : 'Select Duration',
            onTap: () {
              _selectDuration(context, 'Negative emission duration');
            },
          ),
          _buildSettingCard(
            title: 'Time between periodic emissions',
            value: _selectedDuration != null
                ? '${_selectedDuration!.inHours} hours ${(_selectedDuration!.inMinutes % 60)} minutes ${(_selectedDuration!.inSeconds % 60)} seconds'
                : 'Select Duration',
            onTap: () {
              _selectDuration(context, 'Time between periodic emissions');
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: widget.onDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: Size.fromHeight(40),
          ),
          child: const Text('Delete Device'),
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
      margin: EdgeInsets.only(bottom: 4.0),
      child: ListTile(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: Text(title),
              ),
              //Icon(Icons.arrow_forward_ios), // Add the arrow icon here
            ],
          ),
        ),
        subtitle: Text(value),
        onTap: onTap,
      ),
    );
  }
}
