import 'package:flutter/material.dart';
import 'device_remote.dart';
import 'device_settings.dart'; // Import the DeviceSettingsScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int numberOfItems = 10; // Change this to the number of desired items
  final List<String> deviceTitles = List.generate(10, (index) => 'Item $index');

  void addDevice() {
    setState(() {
      deviceTitles.add('New Device');
    });
  }

  void deleteDevice(String deviceName) {
    // Implement your logic to delete the device
    // You can use the deviceName to identify the device to delete
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Devices',
          style: TextStyle(color: Colors.white), // Set title text color
        ),
        centerTitle: true,
        backgroundColor: Colors.blue, // Set the background color
        iconTheme: IconThemeData(color: Colors.black), // Set icon color to black
        elevation: 4.0, // Set elevation to alter shadow
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white, // Set the plus icon color to white
            ),
            onPressed: addDevice, // Call the addDevice function when pressed
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: deviceTitles.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(2.0), // Add spacing between cards
            child: DeviceRemote(
              title: deviceTitles[index], // Pass the title from the list
              onDelete: () {
                // Show the DeviceSettingsScreen and provide the deviceName
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceSettingsScreen(
                      deviceName: deviceTitles[index], // Provide the deviceName
                      onDelete: () {
                        // Implement your logic to delete the device here
                        deleteDevice(deviceTitles[index]);
                        // Now you can delete the device using the provided deviceName
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
