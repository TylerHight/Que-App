import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'screens/device_control/device_control_screen.dart';
import 'screens/notes/notes_screen.dart';
import 'package:que_app/models/notes_list.dart';
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
        ChangeNotifierProvider(create: (_) => NotesList()), // Provide the NotesList
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
            backgroundColor: Colors.white, // Set the background color to white
            selectedItemColor: Colors.blue, // Set the selected item color to blue
            unselectedItemColor: Colors.grey, // Set the unselected item color to grey
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_remote),
            label: 'Control',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        iconSize: 29.0, // Set the size of the icons
        selectedLabelStyle: TextStyle(fontSize: 15.0), // Set the size of the selected text
        unselectedLabelStyle: TextStyle(fontSize: 13.0), // Set the size of the unselected text
      ),
    );
  }
}
