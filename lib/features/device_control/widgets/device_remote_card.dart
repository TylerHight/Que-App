import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que_app/features/device_settings/views/settings_screen.dart';
import 'timed_binary_button.dart';
import 'package:que_app/core/models/device/index.dart';
import 'package:que_app/core/services/ble_service.dart';
import '../../notes/dialogs/add_note_dialog.dart';
import 'package:que_app/core/models/note.dart';

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
  late StreamSubscription<String>? _deviceStateSubscription;
  bool isConnected = false;
  String _lastError = '';

  @override
  void initState() {
    super.initState();
    _setupSubscriptions();
  }

  void _setupSubscriptions() {
    // Listen to connection status changes
    _connectionSubscription = widget.bleService.connectionStatusStream.listen(
          (status) {
        setState(() {
          isConnected = status;
          widget.device.isBleConnected = status;
        });
      },
      onError: (error) {
        setState(() {
          _lastError = 'Connection error: $error';
          isConnected = false;
          widget.device.isBleConnected = false;
        });
      },
    );

    // Listen to device state updates
    _deviceStateSubscription = widget.bleService.deviceStateStream.listen(
          (state) {
        if (mounted && state.contains('error')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state)),
          );
        }
      },
    );
  }

  Future<void> _sendCommand(int command) async {
    try {
      await widget.bleService.setLedColor(command);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send command: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    _deviceStateSubscription?.cancel();
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
                  // Bluetooth status indicator
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          device.isBleConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                          color: device.isBleConnected ? Colors.blue : Colors.grey.shade400,
                        ),
                        if (_lastError.isNotEmpty)
                          const Positioned(
                            right: 0,
                            bottom: 0,
                            child: Icon(Icons.error_outline,
                              size: 12,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Device info and controls
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 11.0),
                          child: Text(
                            device.deviceName,
                            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 19.0),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SettingsScreen(device: device, bleService: widget.bleService)),
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
                                    return AddNoteDialog(
                                      onNoteAdded: (Note newNote) {
                                        // Callback logic here
                                      },
                                      device: device,
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
                  ),
                  // Emission controls
                  TimedBinaryButton(
                    key: UniqueKey(),
                    periodicEmissionEnabled: device.isPeriodicEmissionEnabled,
                    periodicEmissionTimerDuration: device.releaseInterval1,
                    activeColor: Colors.lightBlue.shade400,
                    inactiveColor: Colors.lightBlue.shade100,
                    iconData: Icons.air,
                    buttonSize: 55.0,
                    iconSize: 40.0,
                    autoTurnOffDuration: device.emission1Duration,
                    autoTurnOffEnabled: true,
                    onPressedTurnOn: () => _sendCommand(BleService.LED_RED),
                    onPressedTurnOff: () => _sendCommand(BleService.LED_OFF),
                    isConnected: device.isBleConnected,
                  ),
                  const SizedBox(width: 8),
                  TimedBinaryButton(
                    key: UniqueKey(),
                    periodicEmissionEnabled: device.isPeriodicEmissionEnabled2,
                    periodicEmissionTimerDuration: device.releaseInterval2,
                    activeColor: Colors.green.shade500,
                    inactiveColor: Colors.green.shade100,
                    iconData: Icons.air,
                    buttonSize: 55.0,
                    iconSize: 40.0,
                    autoTurnOffDuration: device.emission2Duration,
                    autoTurnOffEnabled: true,
                    onPressedTurnOn: () => _sendCommand(BleService.LED_GREEN),
                    onPressedTurnOff: () => _sendCommand(BleService.LED_OFF),
                    isConnected: device.isBleConnected,
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