// device_remote.dart

import 'package:flutter/material.dart';
import 'timed_binary_button.dart';
import 'binary_button.dart';
import 'package:que_app/device_data.dart';
import 'package:provider/provider.dart';

class DeviceRemote extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  DeviceRemote({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final deviceData = Provider.of<DeviceData>(context);
    final deviceSettings = deviceData.getDeviceSettings(title);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    BinaryButton( // power button
                        activeColor: Colors.green.shade400,
                        inactiveColor: Colors.grey.shade300,
                        iconData: Icons.power_settings_new,
                        buttonSize: 26.0,
                        iconSize: 18.0,
                        onPressedGreyToColor: () {
                          //onTap();
                        },
                        onPressedColorToGrey: () {
                          //onTap();
                        },
                    ),
                    SizedBox(width: 8),
                    TimedBinaryButton( // settings button
                      activeColor: Colors.white,
                      inactiveColor: Colors.white,
                      iconData: Icons.settings,
                      iconColor: Colors.grey.shade300,
                      buttonSize: 30.0,
                      iconSize: 30.0,
                      autoTurnOffDuration: Duration(seconds: 3),
                      autoTurnOffEnabled: false,
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
                TimedBinaryButton( // negative emission
                  activeColor: Colors.red.shade400,
                  inactiveColor: Colors.grey.shade300,
                  iconData: Icons.sentiment_very_dissatisfied,
                  buttonSize: 50.0,
                  iconSize: 38.0,
                  autoTurnOffDuration: Duration(seconds: deviceSettings.negativeEmissionDuration),
                  autoTurnOffEnabled: true,
                ),
                SizedBox(width: 8),
                TimedBinaryButton( // positive emission
                  activeColor: Colors.green.shade500,
                  inactiveColor: Colors.grey.shade300,
                  iconData: Icons.mood,
                  buttonSize: 50.0,
                  iconSize: 38.0,
                  autoTurnOffDuration: Duration(seconds: deviceSettings.positiveEmissionDuration),
                  autoTurnOffEnabled: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
