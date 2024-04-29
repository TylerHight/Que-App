import 'package:flutter/material.dart';

class NotesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Notes',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Handle your logic here
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Notes Screen',
        ),
      ),
    );
  }
}
