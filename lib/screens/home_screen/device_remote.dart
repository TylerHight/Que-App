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
                SizedBox(height: 8),
                Row(
                  children: [
                    BinaryButton(
                      buttonColor: Colors.green,
                      iconData: Icons.power_settings_new,
                    ),
                    SizedBox(width: 8),
                    BinaryButton(
                      buttonColor: Colors.red,
                      iconData: Icons.air,
                    ),
                    SizedBox(width: 8),
                    BinaryButton(
                      buttonColor: Colors.cyan,
                      iconData: Icons.air,
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              label: Text(
                'Settings',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Custom button color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
