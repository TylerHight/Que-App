import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'screens/device_control/device_control_screen.dart';
import 'screens/notes/notes_screen.dart';
import 'screens/device_settings/device_settings.dart'; // Import the SettingsScreen widget
import 'models/device.dart'; // Import the Device class
import 'models/device_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider( // Change to MultiProvider
      providers: [
        ChangeNotifierProvider(create: (_) => DeviceList()), // Provide the DeviceList
        // Add other providers if needed
      ],
      child: MaterialApp(
        title: 'Que App',
        debugShowCheckedModeBanner: false,  // Add this line
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white), // Set icon color to white
          ),
          textTheme: TextTheme(headline6: TextStyle(color: Colors.white)), // Set text color to white
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey[400], // Set unselected item color to white
          ),
        ),
        initialRoute: '/', // Define initial route
        routes: {
          '/': (context) => MyHomePage(), // Define the home route
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    DeviceControlScreen(),
    NotesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue, // Set the background color to blue
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'Device Control',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton( // Add FloatingActionButton for settings
        onPressed: () {
          Navigator.pushNamed(context, '/settings');
        },
        child: Icon(Icons.settings),
      ) : null,
    );
  }
}
