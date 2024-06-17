import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que_app/screens/device_settings/device_settings.dart'; // Import the SettingsScreen widget
import 'timed_binary_button.dart'; // Import the TimedBinaryButton widget
import 'package:que_app/models/device.dart'; // Import the Device class from your package
import 'package:que_app/services/ble_service.dart'; // Import the BleService class
import 'add_note_dialog.dart';
import 'package:que_app/models/note.dart';

class DeviceRemote extends StatelessWidget {
  final Device device;
  final BleService bleService;

  const DeviceRemote({
    Key? key,
    required this.device,
    required this.bleService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            children: [
              // Bluetooth Icon indicating connection status
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  device.isBleConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: device.isBleConnected ? Colors.blue : Colors.grey.shade400,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 11.0),
                    child: Text(
                      device.deviceName,
                      style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 19.0),
                    ),
                  ),
                  const SizedBox(height: 0),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Open settings screen when settings icon button is tapped
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SettingsScreen(device: device)),
                          );
                        },
                        icon: Icon(
                          Icons.settings,
                          size: 28,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Builder(
                                builder: (context) {
                                  return AddNoteDialog(
                                    onNoteAdded: (Note newNote) {
                                      // Callback logic here
                                    },
                                    device: device, // Pass the device object
                                  );
                                },
                              );
                            },
                          );
                        },
                        icon: Icon(
                          Icons.description,
                          size: 28,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(), // Add spacer to push emission buttons to the right
              Consumer<Device>(
                builder: (context, device, _) {
                  return TimedBinaryButton(
                    key: UniqueKey(), // Add a unique key to force rebuild
                    periodicEmissionEnabled: device.isPeriodicEmissionEnabled,
                    periodicEmissionTimerDuration: Duration(seconds: 3),
                    activeColor: Colors.lightBlue.shade400,
                    inactiveColor: Colors.lightBlue.shade100,
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
                  );
                },
              ),
              SizedBox(width: 8), // Add spacing between emission buttons
              Consumer<Device>(
                builder: (context, device, _) {
                  return TimedBinaryButton(
                    key: UniqueKey(), // Add a unique key to force rebuild
                    periodicEmissionEnabled: device.isPeriodicEmissionEnabled2,
                    periodicEmissionTimerDuration: Duration(seconds: 3),
                    activeColor: Colors.green.shade500,
                    inactiveColor: Colors.green.shade100,
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
