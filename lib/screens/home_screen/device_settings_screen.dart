import 'package:flutter/material.dart';

class DeviceSettingsScreen extends StatefulWidget {
  final VoidCallback onDelete;

  const DeviceSettingsScreen({super.key, required this.onDelete});

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
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Hours:'),
                    DropdownButton<int>(
                      value: title == 'Time between periodic emissions'
                          ? _selectedHours
                          : title == 'Positive Emission Duration'
                          ? _selectedPositiveHours
                          : title == 'Negative Emission Duration'
                          ? _selectedNegativeHours
                          : 0,
                      onChanged: (value) {
                        setState(() {
                          if (title == 'Time between periodic emissions') {
                            _selectedHours = value!;
                          } else if (title == 'Positive Emission Duration') {
                            _selectedPositiveHours = value!;
                          } else if (title == 'Negative Emission Duration') {
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Minutes:'),
                    DropdownButton<int>(
                      value: title == 'Time between periodic emissions'
                          ? _selectedMinutes
                          : title == 'Positive Emission Duration'
                          ? _selectedPositiveMinutes
                          : title == 'Negative Emission Duration'
                          ? _selectedNegativeMinutes
                          : 0,
                      onChanged: (value) {
                        setState(() {
                          if (title == 'Time between periodic emissions') {
                            _selectedMinutes = value!;
                          } else if (title == 'Positive Emission Duration') {
                            _selectedPositiveMinutes = value!;
                          } else if (title == 'Negative Emission Duration') {
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Seconds:'),
                    DropdownButton<int>(
                      value: title == 'Time between periodic emissions'
                          ? _selectedSeconds
                          : title == 'Positive Emission Duration'
                          ? _selectedPositiveSeconds
                          : title == 'Negative Emission Duration'
                          ? _selectedNegativeSeconds
                          : 0,
                      onChanged: (value) {
                        setState(() {
                          if (title == 'Time between periodic emissions') {
                            _selectedSeconds = value!;
                          } else if (title == 'Positive Emission Duration') {
                            _selectedPositiveSeconds = value!;
                          } else if (title == 'Negative Emission Duration') {
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
                  } else if (title == 'Positive Emission Duration') {
                    _selectedPositiveEmissionDuration = Duration(
                      hours: _selectedPositiveHours,
                      minutes: _selectedPositiveMinutes,
                      seconds: _selectedPositiveSeconds,
                    );
                  } else if (title == 'Negative Emission Duration') {
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Positive Emission Duration input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Text('Positive Emission Duration:'),
                  ElevatedButton(
                    onPressed: () {
                      _selectDuration(context, 'Positive Emission Duration');
                    },
                    child: Text(
                      _selectedPositiveEmissionDuration != null
                          ? '${_selectedPositiveEmissionDuration!.inHours} hours ${(_selectedPositiveEmissionDuration!.inMinutes % 60)} minutes ${(_selectedPositiveEmissionDuration!.inSeconds % 60)} seconds'
                          : 'Select Duration',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20), // Add spacing between the input fields

            // Negative Emission Duration input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Text('Negative Emission Duration:'),
                  ElevatedButton(
                    onPressed: () {
                      _selectDuration(context, 'Negative Emission Duration');
                    },
                    child: Text(
                      _selectedNegativeEmissionDuration != null
                          ? '${_selectedNegativeEmissionDuration!.inHours} hours ${(_selectedNegativeEmissionDuration!.inMinutes % 60)} minutes ${(_selectedNegativeEmissionDuration!.inSeconds % 60)} seconds'
                          : 'Select Duration',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20), // Add spacing between the input fields

            // Time between periodic emissions input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Text('Time between periodic emissions:'),
                  ElevatedButton(
                    onPressed: () {
                      _selectDuration(context, 'Time between periodic emissions');
                    },
                    child: Text(
                      _selectedDuration != null
                          ? '${_selectedDuration!.inHours} hours ${(_selectedDuration!.inMinutes % 60)} minutes ${(_selectedDuration!.inSeconds % 60)} seconds'
                          : 'Select Duration',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20), // Add spacing between the input fields

            ElevatedButton(
              onPressed: widget.onDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Set the button's background color to red
              ),
              child: const Text('Delete Device'),
            ),
          ],
        ),
      ),
    );
  }
}
