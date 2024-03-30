// duration_picker_dialog.dart

import 'package:flutter/material.dart';

class DurationPickerDialog extends StatefulWidget {
  final String title;
  final Duration? initialDuration;
  bool isPeriodicEmissionEnabled;

  DurationPickerDialog({super.key, 
    required this.title,
    this.initialDuration,
    required this.isPeriodicEmissionEnabled,
  });

  @override
  _DurationPickerDialogState createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {
  int _selectedHours = 0;
  int _selectedMinutes = 0;
  int _selectedSeconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialDuration != null) {
      _selectedHours = widget.initialDuration!.inHours;
      _selectedMinutes = (widget.initialDuration!.inMinutes % 60);
      _selectedSeconds = (widget.initialDuration!.inSeconds % 60);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select ${widget.title}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.title == 'Time between periodic emissions')
            Switch(
              value: widget.isPeriodicEmissionEnabled,
              onChanged: (newValue) {
                setState(() {
                  widget.isPeriodicEmissionEnabled = newValue;
                });
              },
            ),
          _buildDurationDropdown(
            title: 'Hours:',
            value: _selectedHours,
            onChanged: (value) {
              setState(() {
                _selectedHours = value!;
              });
            },
            itemCount: 24,
          ),
          _buildDurationDropdown(
            title: 'Minutes:',
            value: _selectedMinutes,
            onChanged: (value) {
              setState(() {
                _selectedMinutes = value!;
              });
            },
            itemCount: 60,
          ),
          _buildDurationDropdown(
            title: 'Seconds:',
            value: _selectedSeconds,
            onChanged: (value) {
              setState(() {
                _selectedSeconds = value!;
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
            final selectedDuration = Duration(
              hours: _selectedHours,
              minutes: _selectedMinutes,
              seconds: _selectedSeconds,
            );

            Navigator.of(context).pop(selectedDuration);
          },
          child: const Text('OK'),
        ),
      ],
    );
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