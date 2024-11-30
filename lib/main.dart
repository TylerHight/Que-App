import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            iconTheme: IconThemeData(color: Colors.white),
          ),
          dialogTheme: const DialogTheme(
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            contentTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
            backgroundColor: Colors.white,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const MyHomePage(),
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
        iconSize: 30.0,
        selectedLabelStyle: const TextStyle(fontSize: 15.0),
        unselectedLabelStyle: const TextStyle(fontSize: 13.0),
      ),
    );
  }
}