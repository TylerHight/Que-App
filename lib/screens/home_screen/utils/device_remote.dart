import 'package:flutter/material.dart';
import 'timed_binary_button.dart';
import 'binary_button.dart';
import 'package:que_app/device_data.dart';
import 'package:provider/provider.dart';
import 'dart:async';

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

    // Function to turn on the positive emission after the timer duration.
    void turnOnPositiveEmission() {
      // Implement the logic to turn on the positive emission here.
      // You can use setState or other state management techniques to update the UI.
      // Replace this comment with your actual logic for turning on positive emission.
    }

    // Check if the periodic emission is enabled and the timer is not running.
    if (deviceSettings.periodicEmission) {
      Timer.periodic(
        Duration(seconds: deviceSettings.periodicEmissionTimerLength),
            (timer) {
          // After the timer duration, call the function to turn on positive emission.
          turnOnPositiveEmission();
          timer.cancel(); // Cancel the timer after one execution.
        },
      );
    }

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
                      periodicEmissionTimerDuration: Duration(seconds: 0),
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
                  periodicEmissionTimerDuration: Duration(seconds: 0),
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
                  periodicEmissionEnabled: true,
                  periodicEmissionTimerDuration: Duration(seconds: deviceSettings.periodicEmissionTimerLength),
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
