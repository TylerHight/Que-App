import 'package:flutter/material.dart';
import 'device_remote.dart';
import 'device_settings.dart'; // Import the DeviceSettingsScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> deviceNames = []; // Create a list to store device names

  @override
  void initState() {
    super.initState();
    // Initialize the list with some default device names
    deviceNames.addAll(List.generate(3, (index) => 'Item $index'));
  }

  void addDevice() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newDeviceName = ""; // Store the entered device name

        return AlertDialog(
          title: Text('Add New Device'),
          content: TextField(
            onChanged: (value) {
              newDeviceName = value; // Update the entered device name
            },
            decoration: InputDecoration(labelText: 'Device Name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newDeviceName.isNotEmpty) {
                  // Add the new device name to the list
                  setState(() {
                    deviceNames.add(newDeviceName);
                  });
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void deleteDevice(String deviceName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Device'),
          content: Text('Delete device $deviceName?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                // Remove the deviceName from the deviceNames list
                setState(() {
                  deviceNames.remove(deviceName);
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
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
        itemCount: deviceNames.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(2.0), // Add spacing between cards
            child: DeviceRemote(
              title: deviceNames[index], // Pass the title from the list
              onDelete: () {
                // Show the DeviceSettingsScreen and provide the deviceName
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceSettingsScreen(
                      deviceName: deviceNames[index], // Provide the deviceName
                      onDelete: () {
                        // Implement your logic to delete the device here
                        deleteDevice(deviceNames[index]);
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
