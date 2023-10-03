import 'package:flutter/material.dart';
import 'binary_button.dart';

class DeviceRemote extends StatelessWidget {
  final String title;

  DeviceRemote({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
      ),
      elevation: 4.0, // Add elevation for a shadow effect
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding
        child: Row( // Use a Row to arrange items horizontally
          children: [
            SizedBox(width: 16), // Add spacing from the left
            Text(
              title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
              ), // Set text color to black
            ), // Display the title
            Spacer(), // Add space between title and buttons
            BinaryButton( // Power Button
              buttonColor: Colors.green,
              iconData: Icons.power_settings_new,
            ),
            SizedBox(width: 8), // Add spacing between buttons
            BinaryButton( // Negative emission
              buttonColor: Colors.red,
              iconData: Icons.air,
            ),
            SizedBox(width: 8), // Add spacing between buttons
            BinaryButton( // Positive emission
              buttonColor: Colors.cyan,
              iconData: Icons.air,
            ),
            SizedBox(width: 16), // Add spacing from the right
          ],
        ),
      ),
    );
  }
}
