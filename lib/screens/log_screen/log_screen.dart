/// log_screen.dart
///
///
/// By: Tyler Hight

import 'package:flutter/material.dart';

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dummy data, replace with your actual data
    List<EventModel> events = [
      EventModel(title: 'Setting Change', description: 'Setting 1 changed to Value 1'),
      EventModel(title: 'Note Entered', description: 'User entered a note'),
      // Add more events as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Log'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(0.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          EventModel event = events[index];
          return _buildEventTile(
            title: event.title,
            description: event.description,
            onTap: () {
              // Handle onTap for each event if needed
            },
          );
        },
      ),
    );
  }

  Widget _buildEventTile({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.only(bottom: 5.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        onTap: onTap,
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}

class EventModel {
  final String title;
  final String description;
  final DateTime timestamp;

  EventModel({
    required this.title,
    required this.description,
    // Add more properties as needed
  }) : timestamp = DateTime.now();
}
