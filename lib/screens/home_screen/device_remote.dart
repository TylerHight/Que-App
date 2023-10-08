// device_remote.dart

import 'package:flutter/material.dart';
import 'binary_button.dart';

class DeviceRemote extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  DeviceRemote({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: EdgeInsets.all(12.0), // Improved spacing
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Center-align elements
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0, // Adjusted font size
                    fontWeight: FontWeight.bold, // Added bold style
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    BinaryButton(
                      activeColor: Colors.green,
                      inactiveColor: Colors.grey.shade300,
                      iconData: Icons.power_settings_new,
                      buttonSize: 30.0,
                      iconSize: 20.0
                    ),
                    SizedBox(width: 8),
                    BinaryButton( // settings button
                        activeColor: Colors.white,
                        inactiveColor: Colors.white,
                        iconData: Icons.settings,
                        iconColor: Colors.grey.shade300,
                        buttonSize: 30.0,
                        iconSize: 30.0,
                        onPressedGreyToColor: () {
                          onTap();
                        },
                        onPressedColorToGrey: () {
                          onTap();
                        },
                    ),
                  ],
                ),

              ],
            ),
            Row(
              children: [
                SizedBox(width: 8),
                BinaryButton( // negative emission
                  activeColor: Colors.red,
                  inactiveColor: Colors.grey.shade300,
                  iconData: Icons.sentiment_very_dissatisfied,
                  buttonSize: 50.0,
                  iconSize: 38.0
                ),
                SizedBox(width: 8),
                BinaryButton( // positive emission
                  activeColor: Colors.cyan,
                  inactiveColor: Colors.grey.shade300,
                  iconData: Icons.mood,
                    buttonSize: 50.0,
                    iconSize: 38.0
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
