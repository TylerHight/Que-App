import 'package:flutter/material.dart';
import 'timed_binary_button.dart'; // Import the TimedBinaryButton widget
import 'package:que_app/models/device.dart'; // Import the Device class from your package
import 'package:que_app/services/ble_service.dart'; // Import the BleService class

class DeviceRemote extends StatelessWidget {
  final Device device;
  final BleService bleService; // Add a BleService instance

  const DeviceRemote({
    Key? key,
    required this.device,
    required this.bleService,
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
                      device.deviceName,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
                    ),
                  ),
                  const SizedBox(height: 0),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Add your onPressed logic here
                        },
                        icon: Icon(
                            Icons.settings,
                            size: 28,
                            color: Colors.grey.shade400
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Add your onPressed logic here
                        },
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
                    autoTurnOffDuration: device.emission1Duration,
                    autoTurnOffEnabled: true,
                    onPressedTurnOn: () {
                      bleService.sendCommand(device.controlCharacteristic, 1);
                    },
                    onPressedTurnOff: () {
                      bleService.sendCommand(device.controlCharacteristic, 2);
                    },
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
                    autoTurnOffDuration: device.emission2Duration,
                    autoTurnOffEnabled: true,
                    onPressedTurnOn: () {
                      bleService.sendCommand(device.controlCharacteristic, 3);
                    },
                    onPressedTurnOff: () {
                      bleService.sendCommand(device.controlCharacteristic, 4);
                    },
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
