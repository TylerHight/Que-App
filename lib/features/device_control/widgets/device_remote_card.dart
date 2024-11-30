// lib/features/device_control/widgets/device_remote_card.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que_app/features/device_settings/views/settings_screen.dart';
import 'timed_binary_button.dart';
import 'package:que_app/core/models/device/index.dart';
import 'package:que_app/core/services/ble/ble_service.dart';
import '../../notes/dialogs/add_note_dialog.dart';
import 'package:que_app/core/models/note.dart';
import 'package:que_app/core/constants/ble_constants.dart';
// TODO: Make settings and notes buttons bigger and easier to tap
// TODO: Add a way to change the device name
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
          SnackBar(
            content: Text('Failed to send command: $e'),
            behavior: SnackBarBehavior.floating,
          ),
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
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Device Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Connection Status
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: device.isBleConnected ? Colors.blue[50] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        device.isBleConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                        color: device.isBleConnected ? Colors.blue[600] : Colors.grey[400],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Device Name and Error
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.deviceName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_lastError.isNotEmpty)
                            Text(
                              _lastError,
                              style: TextStyle(
                                color: Colors.red[400],
                                fontSize: 12.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Controls
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16.0),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Action Buttons
                        Expanded(
                          child: Row(
                            children: [
                              _ActionButton(
                                icon: Icons.settings,
                                label: 'Settings',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SettingsScreen(
                                        device: device,
                                        bleService: widget.bleService,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                icon: Icons.note_add,
                                label: 'Add Note',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AddNoteDialog(
                                        onNoteAdded: (Note newNote) {},
                                        device: device,
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        // Emission Controls
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 52,
                              height: 52,
                              child: TimedBinaryButton(
                                key: UniqueKey(),
                                periodicEmissionEnabled: device.isPeriodicEmissionEnabled,
                                periodicEmissionTimerDuration: device.releaseInterval1,
                                activeColor: Colors.blue[600]!,
                                inactiveColor: Colors.blue[100]!,
                                iconData: Icons.air,
                                buttonSize: 52.0,
                                iconSize: 28.0,
                                autoTurnOffDuration: device.emission1Duration,
                                autoTurnOffEnabled: true,
                                onPressedTurnOn: () => _sendCommand(BleConstants.CMD_LED_RED),
                                onPressedTurnOff: () => _sendCommand(BleConstants.CMD_LED_OFF),
                                isConnected: device.isBleConnected,
                                device: device,
                                bleService: widget.bleService,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 52,
                              height: 52,
                              child: TimedBinaryButton(
                                key: UniqueKey(),
                                periodicEmissionEnabled: device.isPeriodicEmissionEnabled2,
                                periodicEmissionTimerDuration: device.releaseInterval2,
                                activeColor: Colors.green[600]!,
                                inactiveColor: Colors.green[100]!,
                                iconData: Icons.air,
                                buttonSize: 52.0,
                                iconSize: 28.0,
                                autoTurnOffDuration: device.emission2Duration,
                                autoTurnOffEnabled: true,
                                onPressedTurnOn: () => _sendCommand(BleConstants.CMD_LED_GREEN),
                                onPressedTurnOff: () => _sendCommand(BleConstants.CMD_LED_OFF),
                                isConnected: device.isBleConnected,
                                device: device,
                                bleService: widget.bleService,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}