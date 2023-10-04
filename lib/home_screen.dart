import 'package:flutter/material.dart';
import 'device_remote.dart'; // Import the DeviceRemote class

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
            icon: Icon(Icons.add), // Plus icon
            onPressed: addDevice, // Call the addDevice function when pressed
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: deviceTitles.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(2.0), // Add spacing between cards
            child: DeviceRemote( // Create an instance of the DeviceRemote
              title: deviceTitles[index], // Pass the title from the list
            ),
          );
        },
      ),
    );
  }
}
