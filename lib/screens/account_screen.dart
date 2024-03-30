import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Name'), // Add your account name here
      ),
      body: const Center(
        child: Text('Account Screen'),
      ),
    );
  }
}
