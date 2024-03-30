// info_screen.dart

import 'package:flutter/material.dart';

// InfoScreen for displaying additional information
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Screen'),
      ),
      body: const Center(
        child: Text('This is the Info Screen.'),
      ),
    );
  }
}