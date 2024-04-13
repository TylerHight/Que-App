/// home_screen.dart
///
/// Main Screen
///
/// This file includes a list of the connected aromatherapy
/// devices and a "plus" button at the top right where new devices
/// can be connected. When the "plus" button is selected, a dialog
/// opens where a list of available bluetooth devices is shown.
/// Once the user selects the aromatherapy necklace, the user
/// chooses a name for the device and a widget for the device is
/// generated.
/// Each aromatherapy device has its own widget with four
/// buttons and the chosen title of the device. There is a power
/// button for turning the device on and off, a settings button
/// for changing the device settings, a positive emission button
/// for releasing a positive emission, and a negative emission button
/// for releasing a negative emission.
///
/// Author: Tyler Hight
///

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../device_data.dart';
import 'utils/device_remote.dart';
import 'device_settings_screen.dart';
import 'utils/add_device_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceData = Provider.of<DeviceData>(context);
    final deviceTitles = deviceData.deviceTitles;

    void addDevice(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) => DeviceNameDialog(
          onDeviceNameEntered: ({required String deviceName, required String bluetoothDeviceID}) { // Specify parameter types
            deviceData.addDeviceTitle(deviceName, bluetoothDeviceID: bluetoothDeviceID); // Pass both parameters to addDeviceTitle
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
        title: const Text(
          'Devices',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 4.0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              addDevice(context);
            },
          ),
          // TODO: Add settings button to change universal device settings
        ],
      ),
      body: deviceTitles.isEmpty
        ? const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding
            child: Text(
              'Add new devices with the plus button at the top right.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center, // Center the text
            ),
          ),
        )
      : ListView.builder(
        itemCount: deviceTitles.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(2.0),
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
