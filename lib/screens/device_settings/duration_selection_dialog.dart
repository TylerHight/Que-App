import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class DurationSelectionDialog extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Duration durationSeconds;

  const DurationSelectionDialog({
    Key? key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.durationSeconds,
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
    // Initialize pickers based on durationSeconds
    _hours = widget.durationSeconds.inHours;
    _minutes = (widget.durationSeconds.inMinutes % 60).toInt();
    _seconds = (widget.durationSeconds.inSeconds % 60).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(widget.icon, color: widget.iconColor), // Icon with color
          SizedBox(width: 8.0), // Space between icon and text
          Text(
            'Set ${widget.title}',
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: _buildNumberPicker('Hr', _hours, (value) => setState(() => _hours = value), 0, 23)),
          Expanded(child: _buildNumberPicker('Min', _minutes, (value) => setState(() => _minutes = value), 0, 59)),
          Expanded(child: _buildNumberPicker('Sec', _seconds, (value) => setState(() => _seconds = value), 0, 59)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(Duration(hours: _hours, minutes: _minutes, seconds: _seconds));
          },
          child: Text('OK'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildNumberPicker(String label, int currentValue, ValueChanged<int> onChanged, int minValue, int maxValue) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
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
