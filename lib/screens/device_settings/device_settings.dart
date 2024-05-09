import 'package:que_app/models/device.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final String deviceName;

  const SettingsScreen({Key? key, required this.deviceName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$deviceName Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Theme'),
            trailing: Icon(Icons.color_lens),
            onTap: () {
              // Navigate to theme settings screen
            },
          ),
          Divider(),
          ListTile(
            title: Text('Notifications'),
            trailing: Icon(Icons.notifications),
            onTap: () {
              // Navigate to notifications settings screen
            },
          ),
          Divider(),
          ListTile(
            title: Text('Account'),
            trailing: Icon(Icons.account_circle),
            onTap: () {
              // Navigate to account settings screen
            },
          ),
          Divider(),
          ListTile(
            title: Text('About'),
            trailing: Icon(Icons.info),
            onTap: () {
              // Navigate to about screen
            },
          ),
          Divider(),
          // Add more settings here...
        ],
      ),
    );
  }
}

