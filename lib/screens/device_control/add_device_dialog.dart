import 'package:flutter/material.dart';

class AddDeviceDialog extends StatefulWidget {
  @override
  _AddDeviceDialogState createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Device'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            // Add your form fields or any content here
            // For example:
            TextFormField(
              decoration: InputDecoration(labelText: 'Device Name'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Device Type'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Add'),
          onPressed: () {
            // Implement logic to add the device here
            // You can access form values using form fields controllers or state
            // Once done, you can close the dialog
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
