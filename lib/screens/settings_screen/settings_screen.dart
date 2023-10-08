import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings Screen'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildSettingCard(
            title: 'Setting 1',
            value: 'Value 1',
            onTap: () {
              // Add your functionality here
            },
          ),
          _buildSettingCard(
            title: 'Setting 2',
            value: 'Value 2',
            onTap: () {
              // Add your functionality here
            },
          ),
          Card(
            elevation: 4.0,
            margin: EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              title: Text('Info'),
              onTap: (){},
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ),
        ],
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
}
