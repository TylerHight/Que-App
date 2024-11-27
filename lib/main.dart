import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'core/services/database_service.dart';
import 'features/device_control/views/device_control_screen.dart';
import 'features/notes/views/notes_screen.dart';
import 'package:que_app/core/models/notes_list.dart';
import 'core/models/device_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>.value(
          value: DatabaseService.instance,
        ),
        ChangeNotifierProvider(create: (_) => DeviceList()),
        ChangeNotifierProvider(create: (_) => NotesList()),
      ],
      child: MaterialApp(
        title: 'Que App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white), // Set icon color to white
          ),
          textTheme: const TextTheme(titleLarge: TextStyle(color: Colors.white)), // Set text color to white
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white, // Set the background color to white
            selectedItemColor: Colors.blue, // Set the selected item color to blue
            unselectedItemColor: Colors.grey, // Set the unselected item color to grey
          ),
        ),
        initialRoute: '/', // Define initial route
        routes: {
          '/': (context) => const MyHomePage(), // Define the home route
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    const DeviceControlScreen(),
    const NotesScreen(),
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
            icon: Icon(Icons.edit_note),
            label: 'Notes',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        iconSize: 30.0, // Set the size of the icons
        selectedLabelStyle: const TextStyle(fontSize: 15.0), // Set the size of the selected text
        unselectedLabelStyle: const TextStyle(fontSize: 13.0), // Set the size of the unselected text
      ),
    );
  }
}