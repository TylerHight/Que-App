import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que_app/models/device_list.dart';
import 'device_remote.dart';
import 'package:que_app/models/device.dart';
import 'package:que_app/services/ble_service.dart';
import 'package:que_app/screens/device_control/add_device_dialog.dart';

class DeviceControlScreen extends StatefulWidget {
  @override
  _DeviceControlScreenState createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Control',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddDeviceDialog(
                    onDeviceAdded: (Device newDevice) {
                      Provider.of<DeviceList>(context, listen: false).add(newDevice);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: Provider.of<DeviceList>(context).devices.length,
        itemBuilder: (context, index) {
          final device = Provider.of<DeviceList>(context).devices[index];
          return Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: ChangeNotifierProvider.value(
              value: device,
              child: DeviceRemote(
                device: device,
                bleService: BleService(),
              ),
            ),
          );
        },
      ),
    );
  }
}
