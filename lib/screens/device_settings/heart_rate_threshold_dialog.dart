import 'package:flutter/material.dart';

class HeartRateThresholdDialog extends StatefulWidget {
  final String title;
  final int currentThreshold; // Add this instance variable

  const HeartRateThresholdDialog({
    Key? key,
    required this.title,
    required this.currentThreshold, // Add this parameter to the constructor
  }) : super(key: key);

  @override
  _HeartRateThresholdDialogState createState() => _HeartRateThresholdDialogState();
}

class _HeartRateThresholdDialogState extends State<HeartRateThresholdDialog> {
  late int _selectedThreshold; // Declare as late

  @override
  void initState() {
    super.initState();
    _selectedThreshold = widget.currentThreshold; // Initialize with currentThreshold
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Set heart rate threshold",
        style: TextStyle(color: Colors.black),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8.0),
          Slider(
            value: _selectedThreshold.toDouble(), // Convert to double for slider
            min: 30.0,
            max: 200.0,
            divisions: 170,
            label: _selectedThreshold.round().toString(),
            onChanged: (value) {
              setState(() {
                _selectedThreshold = value.round(); // Round to integer
              });
            },
          ),
          Text('Threshold: ${_selectedThreshold.round()} BPM'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedThreshold),
          child: Text('Set'),
        ),
      ],
    );
  }
}
