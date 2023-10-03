import 'package:flutter/material.dart';
import 'device_remote.dart'; // Import the DeviceRemote class

class HomeScreen extends StatelessWidget {
  final int numberOfItems = 10; // Change this to the number of desired items

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: numberOfItems,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(2.0), // Add spacing between cards
            child: DeviceRemote( // Create an instance of the DeviceRemote
              title: 'Item $index', // Customize the title
            ),
          );
        },
      ),
    );
  }
}
