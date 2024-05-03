import 'package:flutter/material.dart';
import 'dart:math'; // Import dart:math for generating random icons
import 'timed_binary_button.dart'; // Import the TimedBinaryButton widget

class DeviceRemote extends StatelessWidget {
  final String deviceName;
  final String connectedQueName;

  final VoidCallback? onButton1Pressed;
  final VoidCallback? onButton2Pressed;
  final VoidCallback? onButton3Pressed;
  final VoidCallback? onButton4Pressed;
  final VoidCallback? onMainButton1Pressed;
  final VoidCallback? onMainButton2Pressed;

  const DeviceRemote({
    Key? key,
    required this.deviceName,
    required this.connectedQueName,

    this.onButton1Pressed,
    this.onButton2Pressed,
    this.onButton3Pressed,
    this.onButton4Pressed,
    this.onMainButton1Pressed,
    this.onMainButton2Pressed,
  }) : super(key: key);

  // Generate a random icon
  Icon _generateRandomIcon() {
    List<IconData> icons = [
      Icons.lightbulb,
      Icons.power,
      Icons.play_arrow,
      Icons.pause,
      Icons.volume_up,
      Icons.volume_down,
    ];
    final random = Random();
    return Icon(icons[random.nextInt(icons.length)]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey), // Add visible borders
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
      ),
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0), // Increase text size
                ),
                SizedBox(height: 0.0),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: onButton2Pressed,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(Icons.settings),
                    ),
                    SizedBox(width: 5), // Adjust the spacing as needed
                    ElevatedButton(
                      onPressed: onButton3Pressed,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(Icons.description),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 10.0), // Add spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Align to the end (right)
            children: [
              TimedBinaryButton(
                iconData: Icons.add,
                onPressedTurnOn: onMainButton1Pressed,
                onPressedTurnOff: () {}, // Set to empty function as it's not used
                autoTurnOffDuration: Duration(seconds: 3), // Set auto turn-off duration
                autoTurnOffEnabled: false, // Disable auto turn-off
                periodicEmissionTimerDuration: Duration(seconds: 1), // Set periodic emission duration
                periodicEmissionEnabled: false, // Disable periodic emission
              ),
              SizedBox(width: 10.0), // Add spacing between buttons
              TimedBinaryButton(
                iconData: Icons.remove,
                onPressedTurnOn: onMainButton2Pressed,
                onPressedTurnOff: () {}, // Set to empty function as it's not used
                autoTurnOffDuration: Duration(seconds: 3), // Set auto turn-off duration
                autoTurnOffEnabled: false, // Disable auto turn-off
                periodicEmissionTimerDuration: Duration(seconds: 1), // Set periodic emission duration
                periodicEmissionEnabled: false, // Disable periodic emission
              ),
            ],
          ),
        ],
      ),
    );
  }
}
