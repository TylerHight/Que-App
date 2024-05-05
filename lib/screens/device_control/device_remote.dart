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
    return Padding(
      padding: const EdgeInsets.only(top: 20.0), // Add padding at the top of the card
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 11.0), // Add padding to the left of the title
                    child: Text(
                      deviceName,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
                    ),
                  ),
                  const SizedBox(height: 0),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onButton2Pressed,
                        icon: Icon(
                            Icons.settings,
                            size: 28,
                            color: Colors.grey.shade400
                        ),
                      ),
                      IconButton(
                        onPressed: onButton3Pressed,
                        icon: Icon(
                            Icons.description,
                            size: 28,
                            color: Colors.grey.shade400
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 8),
                  TimedBinaryButton(
                    periodicEmissionTimerDuration: const Duration(seconds: 0),
                    activeColor: Colors.lightBlue.shade400,
                    inactiveColor: Colors.grey.shade300,
                    iconData: Icons.air,
                    buttonSize: 55.0,
                    iconSize: 40.0,
                    autoTurnOffDuration: Duration(seconds: 3),
                    autoTurnOffEnabled: true,
                  ),
                  const SizedBox(width: 8),
                  TimedBinaryButton(
                    periodicEmissionEnabled: false,
                    periodicEmissionTimerDuration: Duration(seconds: 1),
                    activeColor: Colors.green.shade500,
                    inactiveColor: Colors.grey.shade300,
                    iconData: Icons.air,
                    buttonSize: 55.0,
                    iconSize: 40.0,
                    autoTurnOffDuration: Duration(seconds: 3),
                    autoTurnOffEnabled: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
