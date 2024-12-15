// lib/features/device_control/widgets/device_remote.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:que_app/features/device_settings/views/settings_screen.dart';
import 'package:que_app/features/device_control/bloc/device_control_bloc.dart';
import 'package:que_app/features/device_control/bloc/device_control_event.dart';
import 'package:que_app/core/models/device/index.dart';
import 'package:que_app/core/services/ble/ble_service.dart';
import '../../notes/dialogs/add_note_dialog.dart';
import 'package:que_app/core/models/note.dart';
import 'emission_controls.dart';
import 'connection_indicator.dart';

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
    _isConnected = widget.device.isBleConnected;
    _setupSubscriptions();
  }

  void _setupSubscriptions() {
    _connectionSubscription = widget.bleService.connectionStatusStream.listen(
          (status) {
        if (mounted) {
          setState(() {
            _isConnected = status;
            _isConnecting = false;
            if (status) {
              _lastError = '';
              context.read<DeviceControlBloc>().add(
                UpdateDeviceConnection(
                  device: widget.device,
                  isConnected: true,
                ),
              );
            }
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _lastError = 'Connection error: $error';
            _isConnected = false;
            _isConnecting = false;
            context.read<DeviceControlBloc>().add(
              UpdateDeviceConnection(
                device: widget.device,
                isConnected: false,
              ),
            );
          });
        }
      },
    );

    _deviceStateSubscription = widget.bleService.deviceStateStream.listen(
          (state) {
        if (mounted) {
          setState(() {
            _isConnecting = state.toLowerCase().contains('connecting');
            if (state.contains('error')) {
              _lastError = state;
              _showError(state);
            }
          });
        }
      },
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _sendCommand(int command) async {
    if (!_isConnected) return;

    try {
      await widget.bleService.setLedColor(command);
    } catch (e) {
      _showError('Failed to send command: $e');
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
                ConnectionIndicator(
                  isConnected: _isConnected,
                  isConnecting: _isConnecting,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.device.deviceName,
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
                          onPressed: () => _navigateToSettings(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.note_add,
                          label: 'Add Note',
                          onPressed: () => _showAddNoteDialog(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                EmissionControls(
                  device: widget.device,
                  isConnected: _isConnected,
                  onCommand: _sendCommand,
                  bleService: widget.bleService,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          device: widget.device,
          bleService: widget.bleService,
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddNoteDialog(
          onNoteAdded: (Note newNote) {},
          device: widget.device,
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