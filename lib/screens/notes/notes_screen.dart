import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que_app/models/note.dart';
import 'package:que_app/models/notes_list.dart';
import '../device_control/add_note_dialog.dart';

class NotesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500, // Slightly reduce the font weight
          ),
        ),
        backgroundColor: Colors.white, // Set the AppBar background color to white
        iconTheme: IconThemeData(color: Colors.black), // Set the color of icons in AppBar
        elevation: 0.0, // Remove the shadow/depth of the AppBar
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0), // Add padding to the right
            child: Container(
              width: 35.0, // Slightly reduce the size of the circle
              height: 35.0,
              decoration: BoxDecoration(
                color: Colors.blue, // Blue background
                shape: BoxShape.circle, // Circle shape
              ),
              child: Center(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.add, color: Colors.white), // White "add" icon
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddNoteDialog(
                          onNoteAdded: (Note newNote) {
                            Provider.of<NotesList>(context, listen: false).add(newNote);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
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
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding
                  child: ListTile(
                    title: Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Device: ${note.device?.deviceName ?? "N/A"}'),
                        Text('Created on: ${note.creationDate.toLocal().toString().split('.')[0]}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
