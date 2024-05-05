import 'package:flutter/material.dart';
import 'dart:math'; // Import dart:math for generating random icons
import 'timed_binary_button.dart'; // Import the TimedBinaryButton widget

class DeviceRemote extends StatelessWidget {
  final String deviceName;
  final String connectedQueName;
  final Duration emission1Duration;
  final Duration emission2Duration;

  final VoidCallback? onSettingsButtonPressed;
  final VoidCallback? onNoteButtonPressed;
  final VoidCallback? onEmission1PressedOn;
  final VoidCallback? onEmission1PressedOff;
  final VoidCallback? onEmission2PressedOn;
  final VoidCallback? onEmission2PressedOff;

  const DeviceRemote({
    Key? key,
    required this.deviceName,
    required this.connectedQueName,
    required this.emission1Duration,
    required this.emission2Duration,

    this.onSettingsButtonPressed,
    this.onNoteButtonPressed,
    this.onEmission1PressedOn,
    this.onEmission1PressedOff,
    this.onEmission2PressedOn,
    this.onEmission2PressedOff,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0), // Add padding at the top of the card
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
                        onPressed: onSettingsButtonPressed,
                        icon: Icon(
                            Icons.settings,
                            size: 28,
                            color: Colors.grey.shade400
                        ),
                      ),
                      IconButton(
                        onPressed: onNoteButtonPressed,
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
                    periodicEmissionTimerDuration: Duration(seconds: 3),
                    activeColor: Colors.lightBlue.shade400,
                    inactiveColor: Colors.grey.shade300,
                    iconData: Icons.air,
                    buttonSize: 55.0,
                    iconSize: 40.0,
                    autoTurnOffDuration: emission1Duration,
                    autoTurnOffEnabled: true,
                  ),
                  const SizedBox(width: 8),
                  TimedBinaryButton(
                    periodicEmissionEnabled: false,
                    periodicEmissionTimerDuration: Duration(seconds: 3),
                    activeColor: Colors.green.shade500,
                    inactiveColor: Colors.grey.shade300,
                    iconData: Icons.air,
                    buttonSize: 55.0,
                    iconSize: 40.0,
                    autoTurnOffDuration: emission1Duration,
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
