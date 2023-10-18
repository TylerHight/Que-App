import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../device_data.dart';
import 'utils/device_remote.dart';
import 'device_settings_screen.dart';
import 'utils/device_name_dialog.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceData = Provider.of<DeviceData>(context);
    final deviceTitles = deviceData.deviceTitles;

    void addDevice(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) => DeviceNameDialog(
          onDeviceNameEntered: (deviceName) {
            deviceData.addDeviceTitle(deviceName);
          },
        ),
      );
    }

    void deleteDevice(int index) {
      deviceData.deleteDeviceTitle(index);
    }

    void navigateToDeviceSettings(BuildContext context, int index) {
      final deviceTitle = deviceTitles[index];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeviceSettingsScreen(
            deviceTitle: deviceTitle,
            onDelete: () {
              deleteDevice(index);
              Navigator.pop(context);
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Devices',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 4.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              addDevice(context);
            },
          ),
        ],
      ),
      body: deviceTitles.isEmpty
          ? Center(
        child: Text(
          'You have no devices. Add new devices with the plus button at the top right.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        itemCount: deviceTitles.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(2.0),
            child: DeviceRemote(
              title: deviceTitles[index],
              onTap: () {
                navigateToDeviceSettings(context, index);
              },
            ),
          );
        },
      ),
    );
  }
}
