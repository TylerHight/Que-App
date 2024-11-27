// lib/features/device_settings/dialogs/duration_selection_dialog.dart
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class DurationSelectionDialog extends StatefulWidget {
  final String title;
  final Duration initialDuration;  // Changed from durationSeconds
  final Duration? minDuration;     // Added
  final Duration? maxDuration;     // Added
  final IconData icon;
  final Color iconColor;

  const DurationSelectionDialog({
    Key? key,
    required this.title,
    required this.initialDuration,
    this.minDuration,
    this.maxDuration,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  _DurationSelectionDialogState createState() => _DurationSelectionDialogState();
}

class _DurationSelectionDialogState extends State<DurationSelectionDialog> {
  late int _hours;
  late int _minutes;
  late int _seconds;

  @override
  void initState() {
    super.initState();
    // Initialize pickers based on initialDuration
    _hours = widget.initialDuration.inHours;
    _minutes = (widget.initialDuration.inMinutes % 60).toInt();
    _seconds = (widget.initialDuration.inSeconds % 60).toInt();
  }

  bool _isValidDuration(Duration duration) {
    if (widget.minDuration != null && duration < widget.minDuration!) {
      return false;
    }
    if (widget.maxDuration != null && duration > widget.maxDuration!) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(widget.icon, color: widget.iconColor),
          const SizedBox(width: 8.0),
          Text(widget.title),
        ],
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: _buildNumberPicker('Hr', _hours, (value) => setState(() => _hours = value), 0, 23)),
          Expanded(child: _buildNumberPicker('Min', _minutes, (value) => setState(() => _minutes = value), 0, 59)),
          Expanded(child: _buildNumberPicker('Sec', _seconds, (value) => setState(() => _seconds = value), 0, 59)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final duration = Duration(
              hours: _hours,
              minutes: _minutes,
              seconds: _seconds,
            );

            if (_isValidDuration(duration)) {
              Navigator.of(context).pop(duration);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Duration out of allowed range'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildNumberPicker(String label, int currentValue, ValueChanged<int> onChanged, int minValue, int maxValue) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        NumberPicker(
          value: currentValue,
          minValue: minValue,
          maxValue: maxValue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}