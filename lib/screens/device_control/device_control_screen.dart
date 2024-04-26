import 'package:flutter/material.dart';

class DeviceControlScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Control'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Handle your logic here
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Device Control Screen',
        ),
      ),
    );
  }
}
