import 'package:flutter/material.dart';

class DeviceSettingsScreen extends StatefulWidget {
  final VoidCallback onDelete;

  const DeviceSettingsScreen({Key? key, required this.onDelete}) : super(key: key);

  @override
  _DeviceSettingsScreenState createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  Duration? _selectedPositiveEmissionDuration;
  Duration? _selectedNegativeEmissionDuration;
  Duration? _selectedDuration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildSettingCard(
            title: 'Positive scent duration',
            value: _selectedPositiveEmissionDuration != null
                ? _formatDuration(_selectedPositiveEmissionDuration!)
                : 'Select Duration',
            onTap: () {
              _selectDuration(context, 'Positive scent duration');
            },
          ),
          _buildSettingCard(
            title: 'Negative scent duration',
            value: _selectedNegativeEmissionDuration != null
                ? _formatDuration(_selectedNegativeEmissionDuration!)
                : 'Select Duration',
            onTap: () {
              _selectDuration(context, 'Negative scent duration');
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
            backgroundColor: Colors.red,
            minimumSize: const Size(50, 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 4,
          ),
          child: const Text(
            'Delete Device',
            style: TextStyle(fontSize: 16.0),
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
      margin: EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value),
        onTap: onTap,
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    return '${duration.inHours} hours ${duration.inMinutes % 60} minutes ${duration.inSeconds % 60} seconds';
  }

  Future<void> _selectDuration(BuildContext context, String title) async {
    final Duration? selectedDuration = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DurationPickerDialog(); // Custom duration picker dialog
      },
    );

    if (selectedDuration != null) {
      setState(() {
        if (title == 'Time between periodic emissions') {
          _selectedDuration = selectedDuration;
        } else if (title == 'Positive scent duration') {
          _selectedPositiveEmissionDuration = selectedDuration;
        } else if (title == 'Negative scent duration') {
          _selectedNegativeEmissionDuration = selectedDuration;
        }
      });
    }
  }
}

class DurationPickerDialog extends StatefulWidget {
  @override
  _DurationPickerDialogState createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {
  int _selectedHours = 0;
  int _selectedMinutes = 0;
  int _selectedSeconds = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Duration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
