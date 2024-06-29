import 'package:flutter/material.dart';

class HeartRateThresholdDialog extends StatefulWidget {
  final String title;

  const HeartRateThresholdDialog({Key? key, required this.title}) : super(key: key);

  @override
  _HeartRateThresholdDialogState createState() => _HeartRateThresholdDialogState();
}

class _HeartRateThresholdDialogState extends State<HeartRateThresholdDialog> {
  late int _selectedThreshold;

  @override
  void initState() {
    super.initState();
    _selectedThreshold = 0; // Set an initial value for the heart rate threshold
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Set the heart rate threshold:'),
          SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Threshold',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedThreshold = int.tryParse(value) ?? 0;
                    });
                  },
                ),
              ),
            ],
          ),
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
