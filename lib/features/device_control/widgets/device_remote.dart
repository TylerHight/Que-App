// lib/features/device_control/widgets/device_remote.dart

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
  bool _isConnected = false;
  bool _isConnecting = false;
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
          _isConnected = status;
          _isConnecting = false;
          widget.device.isBleConnected = status;
          if (status) {
            _lastError = '';
          }
        });
      },
      onError: (error) {
        setState(() {
          _lastError = 'Connection error: $error';
          _isConnected = false;
          _isConnecting = false;
          widget.device.isBleConnected = false;
        });
      },
    );

    _deviceStateSubscription = widget.bleService.deviceStateStream.listen(
          (state) {
        if (mounted) {
          setState(() {
            _isConnecting = state.toLowerCase().contains('connecting');
            if (state.contains('error')) {
              _lastError = state;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state)),
              );
            }
          });
        }
      },
    );
  }

  Future<void> _sendCommand(int command) async {
    if (!_isConnected) return;

    try {
      await widget.bleService.setLedColor(command);
    } catch (e) {
      if (mounted) {
        setState(() => _lastError = e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send command: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildConnectionIndicator() {
    Color bgColor;
    Color iconColor;
    IconData iconData;
    String? message;

    if (_isConnecting) {
      bgColor = Colors.orange.shade50;
      iconColor = Colors.orange.shade600;
      iconData = Icons.bluetooth_searching;
      message = "Connecting...";
    } else if (_isConnected) {
      bgColor = Colors.blue.shade50;
      iconColor = Colors.blue.shade600;
      iconData = Icons.bluetooth_connected;
    } else {
      bgColor = Colors.grey.shade100;
      iconColor = Colors.grey.shade400;
      iconData = Icons.bluetooth_disabled;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _isConnecting
              ? Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                iconData,
                color: iconColor,
                size: 24,
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                ),
              ),
            ],
          )
              : Icon(
            iconData,
            color: iconColor,
            size: 24,
          ),
        ),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    color: iconColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _buildConnectionIndicator(),
                    const SizedBox(width: 12),
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
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
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
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ActionButton(
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
                          ),
                        ],
                      ),
                    ),
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
                            isConnected: _isConnected,
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
                            isConnected: _isConnected,
                            device: device,
                            bleService: widget.bleService,
                          ),
                        ),
                      ],
                    ),
                  ],
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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