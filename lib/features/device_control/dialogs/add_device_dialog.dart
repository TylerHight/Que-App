// lib/screens/device_control/dialogs/add_device_dialog.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:que_app/core/services/ble/ble_service.dart';
import 'package:que_app/core/utils/ble/ble_utils.dart';
import 'package:que_app/core/models/device/index.dart';
import 'package:provider/provider.dart';
import 'package:que_app/core/models/device_list.dart';

class AddDeviceDialog extends StatefulWidget {
  final Function(Device) onDeviceAdded;
  final bool includeNameField;
  final BleService bleService;

  const AddDeviceDialog({
    super.key,
    required this.onDeviceAdded,
    required this.bleService,
    this.includeNameField = true,
  });

  @override
  _AddDeviceDialogState createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  late BleUtils bleUtils;
  List<BluetoothDevice> nearbyDevices = [];
  BluetoothDevice? selectedDevice;
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  StreamSubscription? _deviceStateSubscription;
  StreamSubscription? _connectionStatusSubscription;
  StreamSubscription? _bluetoothStateSubscription;

  bool _isScanning = false;
  bool _isConnecting = false;
  String _statusMessage = "";
  bool _isCompleted = false;
  int _connectionRetries = 0;
  static const int MAX_RETRIES = 3;
  static const Duration CONNECTION_TIMEOUT = Duration(seconds: 10);
  static const Duration RETRY_DELAY = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    bleUtils = BleUtils();
    _setupSubscriptions();
    _checkBluetoothState();
  }

  Future<void> _checkBluetoothState() async {
    try {
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        if (mounted) {
          setState(() => _statusMessage = "Bluetooth not supported on this device");
        }
        return;
      }

      final isOn = await FlutterBluePlus.isOn;
      if (!isOn) {
        if (mounted) {
          setState(() => _statusMessage = "Please enable Bluetooth");
          _showBluetoothDialog();
        }
        return;
      }

      _startScan();
    } catch (e) {
      if (mounted) {
        setState(() => _statusMessage = "Error checking Bluetooth: $e");
      }
    }
  }

  void _showBluetoothDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth Required'),
          content: const Text('Please enable Bluetooth to scan for devices.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close add device dialog
              },
            ),
            TextButton(
              child: const Text('Enable'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await FlutterBluePlus.turnOn();
                  _startScan();
                } catch (e) {
                  if (mounted) {
                    setState(() => _statusMessage = "Failed to enable Bluetooth");
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _setupSubscriptions() {
    _deviceStateSubscription = widget.bleService.deviceStateStream.listen(
          (message) {
        if (mounted) {
          setState(() => _statusMessage = message);
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _statusMessage = "Error: $error";
            _isConnecting = false;
          });
        }
      },
    );

    _connectionStatusSubscription = widget.bleService.connectionStatusStream.listen(
          (isConnected) {
        if (!mounted) return;
        if (!isConnected && _isConnecting) {
          setState(() {
            _statusMessage = "Device disconnected";
            _isConnecting = false;
          });
          _handleConnectionFailure();
        }
      },
    );

    _bluetoothStateSubscription = FlutterBluePlus.adapterState.listen(
          (BluetoothAdapterState state) {
        if (state == BluetoothAdapterState.off) {
          if (mounted) {
            setState(() => _statusMessage = "Bluetooth is turned off");
            _showBluetoothDialog();
          }
        }
      },
    );
  }

  Future<void> _startScan() async {
    if (!mounted) return;

    setState(() {
      _isScanning = true;
      _statusMessage = "Scanning for devices...";
      nearbyDevices.clear();
      selectedDevice = null;
    });

    try {
      final devices = await bleUtils.startScan();
      if (mounted) {
        setState(() {
          nearbyDevices = devices;
          _statusMessage = devices.isEmpty ? "No devices found" : "";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = "Scan failed: ${e.toString()}";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<bool> _connectWithRetry() async {
    while (_connectionRetries < MAX_RETRIES) {
      try {
        await widget.bleService.connectToDevice(selectedDevice!);

        // Wait for connection confirmation with timeout
        final completer = Completer<bool>();
        Timer? timeoutTimer;

        timeoutTimer = Timer(CONNECTION_TIMEOUT, () {
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        });

        StreamSubscription? subscription;
        subscription = widget.bleService.connectionStatusStream.listen((connected) {
          if (connected && !completer.isCompleted) {
            timeoutTimer?.cancel();
            subscription?.cancel();
            completer.complete(true);
          }
        });

        final connected = await completer.future;

        if (connected) {
          return true;
        }

        _connectionRetries++;
        if (_connectionRetries < MAX_RETRIES) {
          if (mounted) {
            setState(() => _statusMessage = "Retrying connection (${_connectionRetries + 1}/$MAX_RETRIES)...");
          }
          await Future.delayed(RETRY_DELAY);
        }
      } catch (e) {
        _connectionRetries++;
        if (_connectionRetries < MAX_RETRIES) {
          if (mounted) {
            setState(() => _statusMessage = "Connection attempt failed, retrying...");
          }
          await Future.delayed(RETRY_DELAY);
        } else {
          throw Exception("Failed to connect after $_connectionRetries attempts: $e");
        }
      }
    }
    return false;
  }

  void _handleConnectionFailure() async {
    if (_connectionRetries < MAX_RETRIES) {
      _connectionRetries++;
      if (mounted) {
        setState(() => _statusMessage = "Connection lost, retrying...");
      }
      await _connectWithRetry();
    }
  }

  Future<void> _addDevice() async {
    if (!_formKey.currentState!.validate()) return;

    // If a device is selected, connect to it
    if (selectedDevice != null) {
      if (!mounted) return;
      setState(() {
        _isConnecting = true;
        _statusMessage = "Connecting to ${selectedDevice!.platformName}...";
      });

      try {
        final connected = await _connectWithRetry();
        if (!connected) {
          throw Exception("Failed to establish connection");
        }

        // Create the device
        final name = _nameController.text;
        final deviceList = Provider.of<DeviceList>(context, listen: false);

        final newDevice = Device(
          id: UniqueKey().toString(),
          deviceName: name,
          connectedQueName: selectedDevice?.platformName ?? '',
          bluetoothDevice: selectedDevice,
          bleService: widget.bleService,
        );

        // Set completion flag before closing dialog
        _isCompleted = true;
        deviceList.add(newDevice);
        widget.onDeviceAdded(newDevice);

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isConnecting = false;
            _statusMessage = "Connection failed: ${e.toString()}";
          });
        }
      }
    } else {
      // Handle case where no device is selected
      final name = _nameController.text;
      final deviceList = Provider.of<DeviceList>(context, listen: false);

      final newDevice = Device(
        id: UniqueKey().toString(),
        deviceName: name,
        connectedQueName: '',
        bluetoothDevice: null,
        bleService: widget.bleService,
      );

      _isCompleted = true;
      deviceList.add(newDevice);
      widget.onDeviceAdded(newDevice);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _deviceStateSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    _bluetoothStateSubscription?.cancel();
    if (!_isCompleted && _isConnecting) {
      widget.bleService.disconnectFromDevice();
    }
    super.dispose();
  }

  List<BluetoothDevice> getDevicesWithNames() {
    return nearbyDevices.where((device) => device.platformName.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Add Que',
        style: TextStyle(color: Colors.black),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (widget.includeNameField)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_isConnecting,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<BluetoothDevice>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Select Que (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedDevice,
                    onChanged: _isConnecting ? null : (BluetoothDevice? device) {
                      setState(() => selectedDevice = device);
                    },
                    items: [
                      const DropdownMenuItem<BluetoothDevice>(
                        value: null,
                        child: Text('None'),
                      ),
                      ...getDevicesWithNames()
                          .map((device) => DropdownMenuItem(
                        value: device,
                        child: Text(
                          device.platformName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                          .toList(),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _isConnecting ? null : () => _startScan(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: Text(_isScanning ? 'Scanning...' : 'Rescan'),
                ),
                if (_statusMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _statusMessage.contains('Error') ||
                            _statusMessage.contains('failed') ||
                            _statusMessage.contains('timeout')
                            ? Colors.red
                            : Colors.blue,
                      ),
                    ),
                  ),
                if (_isConnecting || _isScanning)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isConnecting ? null : () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isConnecting || _isScanning ? null : _addDevice,
          child: Text(_isConnecting ? 'Connecting...' : 'Add'),
        ),
      ],
    );
  }
}