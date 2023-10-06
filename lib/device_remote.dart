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
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.grey[300],
              ),
              onPressed: onTap,
            ),
            SizedBox(width: 8),
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
            SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
