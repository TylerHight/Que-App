import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arduino Nano BLE Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String serviceUUID = "0000180a-0000-1000-8000-00805f9b34fb";
  final String controlCharacteristicUUID = "00002a57-0000-1000-8000-00805f9b34fb";
  final String settingCharacteristicUUID = "19b10001-e8f2-537e-4f6c-d104768a1214";
  BluetoothCharacteristic? controlCharacteristic;
  BluetoothCharacteristic? settingCharacteristic;
  bool connected = false;
  TextEditingController _fan1DurationController = TextEditingController();

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];

  void _startScan() {
    // start scanning
    flutterBlue.startScan(timeout: const Duration(seconds: 4));

    // listen to scan results
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        print('${result.device.name} found! rssi: ${result.rssi}');
        if (!devices.contains(result.device)) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      print("Stopping BLE scan");
      flutterBlue.stopScan();
      print('Connecting to device: ${device.name}');
      await device.connect();

      print("Waiting to discover services...");
      // Add a delay of 1 second before discovering services
      await Future.delayed(const Duration(seconds: 1));

      print("Discovering services...");
      List<BluetoothService> services = await device.discoverServices();
      print("Available services on ${device.name}:");
      for (var service in services) {
        print("- Service UUID: ${service.uuid}");
        if (service.uuid.toString() == serviceUUID) {
          print("Target service found.");
          print("Searching for matching characteristic(s) in service...");
          for (var characteristic in service.characteristics) {
            print("Found characteristic UUIDs: $characteristic.uuid");
            if (characteristic.uuid.toString() == controlCharacteristicUUID) {
              print("Control characteristic found: ${characteristic.uuid}");
              controlCharacteristic = characteristic;
            } else if (characteristic.uuid.toString() == settingCharacteristicUUID) {
              print("Setting characteristic found: ${characteristic.uuid}");
              settingCharacteristic = characteristic;
            } else {
              print("UUIDs did not match");
            }
          }
          print("Exiting _connectToDevice method");
          break; // Exit the loop once the target service is found
        }
      }

      setState(() {
        connected = true;
      });
    } catch (e) {
      print("Error connecting to device: $e");
    }
  }

  void _disconnectFromDevice() async {
    try {
      await flutterBlue.connectedDevices
          .then((List<BluetoothDevice> devices) async {
        devices.forEach((device) async {
          await device.disconnect();
        });
      });

      setState(() {
        connected = false;
      });
    } catch (e) {
      print("Error disconnecting from device: $e");
    }
  }

  void sendCommand(int value) async {
    final characteristic = controlCharacteristic;
    if (characteristic != null) {
      List<int> data = [value];
      print("Sending control command to Arduino: $data");
      await characteristic.write(data);
      print("Command sent successfully!");
    } else {
      print("Characteristic is null. Cannot send command to Arduino.");
    }
  }

  void sendSetting(int value1, int value2) async {
    final characteristic = controlCharacteristic;
    if (characteristic != null) {
      try {
        // Send the first integer
        await characteristic.write([value1]);
        print("Setting 1 sent successfully!");

        // Send the second integer
        await characteristic.write([value2]);
        print("Setting 2 sent successfully!");
      } catch (e) {
        print("Error sending setting: $e");
      }
    } else {
      print("Characteristic is null. Cannot send setting to Arduino.");
    }
  }


  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arduino Nano BLE Control'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            connected
                ? ElevatedButton(
              onPressed: () {
                sendCommand(0);
              },
              child: Text('Turn fan1 on'),
            )
                : SizedBox(),
            connected
                ? Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    sendCommand(1);
                  },
                  child: Text('Turn fan1 off'),
                ),
                ElevatedButton(
                  onPressed: () {
                    sendCommand(2);
                  },
                  child: Text('Turn fan2 On'),
                ),
                ElevatedButton(
                  onPressed: () {
                    sendCommand(3);
                  },
                  child: Text('Turn fan2 off'),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Set fan1 duration'),
                        content: TextFormField(
                          controller: _fan1DurationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Enter seconds',
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              int seconds = int.tryParse(_fan1DurationController.text) ?? 0;
                              sendSetting(4, seconds);
                              Navigator.of(context).pop();
                            },
                            child: Text('Set'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('Set fan1 duration'),
                ),
              ],
            )
                : SizedBox(),
            SizedBox(height: 20),
            connected
                ? FloatingActionButton(
              onPressed: _disconnectFromDevice,
              tooltip: 'Disconnect',
              child: Icon(Icons.bluetooth_disabled),
            )
                : SizedBox(),
            SizedBox(height: 20),
            connected
                ? SizedBox()
                : Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(devices[index].name),
                    onTap: () {
                      _connectToDevice(devices[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
