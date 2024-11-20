// lib/tools/ble_development_tool.dart

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(BleDevTool());
}

class BleDevTool extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Que Device Development Tool',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: BleDevToolHome(),
    );
  }
}

class BleDevToolHome extends StatefulWidget {
  @override
  _BleDevToolHomeState createState() => _BleDevToolHomeState();
}

class _BleDevToolHomeState extends State<BleDevToolHome> {
  // UUIDs matching Arduino implementation
  static const String SERVICE_UUID = "0000180a-0000-1000-8000-00805f9b34fb";
  static const String CONTROL_CHARACTERISTIC_UUID = "00002a57-0000-1000-8000-00805f9b34fb";

  // Command constants
  static const int FAN1_ON = 0;
  static const int FAN1_OFF = 1;
  static const int FAN2_ON = 2;
  static const int FAN2_OFF = 3;
  static const int SET_FAN1_DURATION = 4;
  static const int SET_FAN2_DURATION = 5;
  static const int SET_EMISSION_INTERVAL = 6;
  static const int PERIODIC_EMISSION_ON = 7;
  static const int PERIODIC_EMISSION_OFF = 8;

  BluetoothCharacteristic? _controlCharacteristic;
  bool _isConnected = false;
  List<ScanResult> _devices = [];
  final _durationController = TextEditingController();
  String _status = 'Ready to scan';

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  Future<void> _initializeBluetooth() async {
    try {
      if (!await FlutterBluePlus.isSupported) {
        setState(() => _status = 'Bluetooth not supported');
        return;
      }

      if (!await FlutterBluePlus.isOn) {
        await FlutterBluePlus.turnOn();
      }

      _startScan();
    } catch (e) {
      setState(() => _status = 'Initialization error: $e');
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _devices.clear();
      _status = 'Scanning...';
    });

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
        androidScanMode: AndroidScanMode.lowLatency,
      );

      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          _devices = results.where((result) =>
          result.device.platformName.isNotEmpty).toList();
          _status = 'Found ${_devices.length} devices';
        });
      });
    } catch (e) {
      setState(() => _status = 'Scan error: $e');
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() => _status = 'Connecting to ${device.platformName}...');

    try {
      await device.connect(timeout: const Duration(seconds: 4));

      // Monitor connection state
      device.connectionState.listen((BluetoothConnectionState state) {
        setState(() {
          _isConnected = state == BluetoothConnectionState.connected;
          _status = _isConnected ? 'Connected' : 'Disconnected';
        });
      });

      await Future.delayed(const Duration(seconds: 1));
      await _discoverServices(device);
    } catch (e) {
      setState(() => _status = 'Connection error: $e');
    }
  }

  Future<void> _discoverServices(BluetoothDevice device) async {
    try {
      final services = await device.discoverServices();

      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == SERVICE_UUID.toLowerCase()) {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() ==
                CONTROL_CHARACTERISTIC_UUID.toLowerCase()) {
              _controlCharacteristic = characteristic;
              setState(() => _status = 'Ready to send commands');
              return;
            }
          }
        }
      }

      setState(() => _status = 'Required service not found');
    } catch (e) {
      setState(() => _status = 'Service discovery error: $e');
    }
  }

  Future<void> _sendCommand(int command) async {
    try {
      if (_controlCharacteristic == null) {
        throw Exception('Device not properly connected');
      }
      await _controlCharacteristic!.write([command], withoutResponse: false);
      setState(() => _status = 'Command $command sent');
    } catch (e) {
      setState(() => _status = 'Command error: $e');
    }
  }

  Future<void> _sendSetting(int settingType, int value) async {
    try {
      if (_controlCharacteristic == null) {
        throw Exception('Device not properly connected');
      }
      // Send setting type
      await _controlCharacteristic!.write([settingType], withoutResponse: false);
      // Send value
      await _controlCharacteristic!.write([value], withoutResponse: false);
      setState(() => _status = 'Setting $settingType = $value sent');
    } catch (e) {
      setState(() => _status = 'Setting error: $e');
    }
  }

  Widget _buildDurationDialog(String title, int settingType) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Duration (seconds)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Text(_status, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final duration = int.tryParse(_durationController.text) ?? 0;
            _sendSetting(settingType, duration);
            Navigator.pop(context);
          },
          child: Text('Set'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Que Device Development Tool'),
        actions: [
          Icon(
            _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: _isConnected ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(_status,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Expanded(
            child: _isConnected
                ? _buildControlPanel()
                : _buildDeviceList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isConnected ? () async {
          await FlutterBluePlus.stopScan();
          _startScan();
        } : _startScan,
        child: Icon(_isConnected ? Icons.refresh : Icons.bluetooth_searching),
      ),
    );
  }

  Widget _buildDeviceList() {
    return ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index].device;
        return ListTile(
          title: Text(device.platformName),
          subtitle: Text('RSSI: ${_devices[index].rssi}'),
          trailing: Icon(Icons.bluetooth),
          onTap: () => _connectToDevice(device),
        );
      },
    );
  }

  Widget _buildControlPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCommandButton('Fan 1 On', () => _sendCommand(FAN1_ON)),
          _buildCommandButton('Fan 1 Off', () => _sendCommand(FAN1_OFF)),
          _buildCommandButton('Fan 2 On', () => _sendCommand(FAN2_ON)),
          _buildCommandButton('Fan 2 Off', () => _sendCommand(FAN2_OFF)),
          const SizedBox(height: 16),
          _buildSettingButton('Set Fan 1 Duration', SET_FAN1_DURATION),
          _buildSettingButton('Set Fan 2 Duration', SET_FAN2_DURATION),
          _buildSettingButton('Set Emission Interval', SET_EMISSION_INTERVAL),
          const SizedBox(height: 16),
          _buildCommandButton('Enable Periodic Emissions',
                  () => _sendCommand(PERIODIC_EMISSION_ON)),
          _buildCommandButton('Disable Periodic Emissions',
                  () => _sendCommand(PERIODIC_EMISSION_OFF)),
        ],
      ),
    );
  }

  Widget _buildCommandButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 48),
        ),
      ),
    );
  }

  Widget _buildSettingButton(String label, int settingType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: OutlinedButton(
        onPressed: () {
          _durationController.clear();
          showDialog(
            context: context,
            builder: (context) => _buildDurationDialog(label, settingType),
          );
        },
        child: Text(label),
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, 48),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }
}