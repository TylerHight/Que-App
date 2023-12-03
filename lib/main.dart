/// main.dart
///
/// Description
///
/// Author: Tyler Hight

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen/home_screen.dart';
import 'screens/settings_screen/settings_screen.dart';
import 'screens/data_screen/data_screen.dart';
import 'screens/account_screen.dart';
import 'device_data.dart'; // Import the DeviceData class

void main() {
  runApp(const QueApp());
}

class QueApp extends StatelessWidget {
  const QueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DeviceData(), // Initialize the DeviceData provider
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // Set this property to false
        title: 'Que App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
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
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    SettingsScreen(),
    //DataScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        unselectedItemColor: Colors.grey[700],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          /// BottomNavigationBarItem(
          ///   icon: Icon(Icons.data_usage),
          ///   label: 'Data',
          /// ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
