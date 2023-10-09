// info_screen.dart

import 'package:flutter/material.dart';

// InfoScreen for displaying additional information
class InfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Info Screen'),
      ),
      body: Center(
        child: Text('This is the Info Screen.'),
      ),
    );
  }
}