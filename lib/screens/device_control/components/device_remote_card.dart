import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que_app/screens/device_settings/device_settings_screen.dart'; // Import the SettingsScreen widget
import 'timed_binary_button.dart'; // Import the TimedBinaryButton widget
import 'package:que_app/models/device.dart'; // Import the Device class from your package
import 'package:que_app/services/ble_service.dart'; // Import the BleService class
import '../dialogs/add_note_dialog.dart';
import 'package:que_app/models/note.dart';

class DeviceRemote extends StatefulWidget {
  final Device device;
  final BleService bleService;

  const DeviceRemote({
    Key? key,
    required this.device,
    required this.bleService,
  }) : super(key: key);

  @override
  _DeviceRemoteState createState() => _DeviceRemoteState();
}

class _DeviceRemoteState extends State<DeviceRemote> {
  late StreamSubscription<bool> _connectionSubscription;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectionSubscription = widget.bleService.connectionStatusStream.listen((status) {
      setState(() {
        isConnected = status;
        widget.device.isBleConnected = status; // Update isBleConnected in the Device model
      });
    });
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Device>(
      builder: (context, device, _) {
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
                              Icons.note_add,
                              size: 28,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Spacer(), // Add spacer to push emission buttons to the right
                  TimedBinaryButton(
                    key: UniqueKey(), // Add a unique key to force rebuild
                    periodicEmissionEnabled: device.isPeriodicEmissionEnabled,
                    periodicEmissionTimerDuration: device.releaseInterval1,
                    activeColor: Colors.lightBlue.shade400,
                    inactiveColor: Colors.lightBlue.shade100,
                    iconData: Icons.air,
                    buttonSize: 55.0,
                    iconSize: 40.0,
                    autoTurnOffDuration: device.emission1Duration,
                    autoTurnOffEnabled: true,
                    onPressedTurnOn: () {
                      widget.bleService.sendCommand(widget.bleService.controlCharacteristic, 1);
                    },
                    onPressedTurnOff: () {
                      widget.bleService.sendCommand(widget.bleService.controlCharacteristic, 2);
                    },
                    isConnected: device.isBleConnected, // Pass the isConnected parameter
                  ),
                  SizedBox(width: 8), // Add spacing between emission buttons
                  TimedBinaryButton(
                    key: UniqueKey(), // Add a unique key to force rebuild
                    periodicEmissionEnabled: device.isPeriodicEmissionEnabled2,
                    periodicEmissionTimerDuration: device.releaseInterval2,
                    activeColor: Colors.green.shade500,
                    inactiveColor: Colors.green.shade100,
                    iconData: Icons.air,
                    buttonSize: 55.0,
                    iconSize: 40.0,
                    autoTurnOffDuration: device.emission2Duration,
                    autoTurnOffEnabled: true,
                    onPressedTurnOn: () {
                      widget.bleService.sendCommand(widget.bleService.controlCharacteristic, 3);
                    },
                    onPressedTurnOff: () {
                      widget.bleService.sendCommand(widget.bleService.controlCharacteristic, 4);
                    },
                    isConnected: device.isBleConnected, // Pass the isConnected parameter
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
