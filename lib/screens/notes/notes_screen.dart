import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que_app/models/note.dart';
import 'package:que_app/models/notes_list.dart';

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
              // Handle adding a new note
            },
          ),
        ],
      ),
      body: Consumer<NotesList>(
        builder: (context, notesList, _) {
          // Check if there are notes in the list
          if (notesList.notes.isEmpty) {
            // If no notes, display a message
            return Center(
              child: Text(
                'No notes available',
                style: TextStyle(fontSize: 18),
              ),
            );
          } else {
            // If there are notes, display them using ListView.builder
            return ListView.builder(
              itemCount: notesList.notes.length,
              itemBuilder: (context, index) {
                final note = notesList.notes[index];
                return ListTile(
                  title: Text(note.content),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Device: ${note.device?.deviceName ?? "N/A"}'),
                      Text('Created on: ${note.creationDate.toLocal().toString().split('.')[0]}'),
                    ],
                  ),
                  // Add any other relevant information you want to display
                );
              },
            );
          }
        },
      ),
    );
  }
}
