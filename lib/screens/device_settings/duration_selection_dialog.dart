import 'package:flutter/material.dart';

class DurationSelectionDialog extends StatefulWidget {
  final String title;

  const DurationSelectionDialog({Key? key, required this.title}) : super(key: key);

  @override
  _DurationSelectionDialogState createState() => _DurationSelectionDialogState();
}

class _DurationSelectionDialogState extends State<DurationSelectionDialog> {
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Set ${widget.title} duration',
          style: TextStyle(color: Colors.black),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDurationField('Hours', _hours, (value) => _hours = value),
          _buildDurationField('Minutes', _minutes, (value) => _minutes = value),
          _buildDurationField('Seconds', _seconds, (value) => _seconds = value),
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


  Widget _buildDurationField(String label, int value, void Function(int) onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label),
        ),
        Expanded(
          child: Slider(
            min: 0,
            max: label == 'Hours' ? 24 : 59,
            value: value.toDouble(),
            onChanged: (newValue) {
              setState(() {
                value = newValue.toInt();
                onChanged(value);
              });
            },
          ),
        ),
        Text('$value'),
      ],
    );
  }
}
