// lib/features/device_settings/dialogs/heart_rate_threshold_dialog.dart
import 'package:flutter/material.dart';

class HeartRateThresholdDialog extends StatefulWidget {
  final String title;
  final int currentThreshold;
  final int minThreshold;  // Add this
  final int maxThreshold;  // Add this

  const HeartRateThresholdDialog({
    Key? key,
    required this.title,
    required this.currentThreshold,
    required this.minThreshold,   // Add this
    required this.maxThreshold,   // Add this
  }) : super(key: key);

  @override
  _HeartRateThresholdDialogState createState() => _HeartRateThresholdDialogState();
}

class _HeartRateThresholdDialogState extends State<HeartRateThresholdDialog> {
  late int _selectedThreshold;

  @override
  void initState() {
    super.initState();
    _selectedThreshold = widget.currentThreshold;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,  // Use the title from props
        style: const TextStyle(color: Colors.black),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8.0),
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red),
              Expanded(
                child: Slider(
                  value: _selectedThreshold.toDouble(),
                  min: widget.minThreshold.toDouble(),  // Use minThreshold
                  max: widget.maxThreshold.toDouble(),  // Use maxThreshold
                  divisions: widget.maxThreshold - widget.minThreshold,  // Dynamic divisions
                  label: _selectedThreshold.toString(),
                  onChanged: (value) {
                    setState(() {
                      _selectedThreshold = value.round();
                    });
                  },
                ),
              ),
            ],
          ),
          Text('Threshold: $_selectedThreshold BPM'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedThreshold),
          child: const Text('Set'),
        ),
      ],
    );
  }
}