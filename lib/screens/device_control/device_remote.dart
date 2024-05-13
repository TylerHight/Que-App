import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que_app/screens/device_settings/device_settings.dart';
import 'package:que_app/models/device.dart';
import 'package:que_app/services/ble_service.dart';
import 'package:que_app/models/note.dart';
import 'package:que_app/screens/device_control/add_note_dialog.dart';
import 'package:que_app/models/notes_list.dart';

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
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  device.isBleConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: device.isBleConnected ? Colors.blue : Colors.grey,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 11.0),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SettingsScreen(device: device)),
                          );
                        },
                        icon: Icon(
                            Icons.settings,
                            size: 28,
                            color: Colors.grey.shade400
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
              Spacer(),
              // Emission buttons
            ],
          ),
        ),
      ),
    );
  }
}
