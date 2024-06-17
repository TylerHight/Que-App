import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que_app/models/note.dart';
import 'package:que_app/models/notes_list.dart';
import '../device_control/add_note_dialog.dart';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _isSelectionMode = false;
  Set<Note> _selectedNotes = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedNotes.clear();
    });
  }

  void _deleteSelectedNotes() {
    Provider.of<NotesList>(context, listen: false).removeMultiple(_selectedNotes.toList());
    _toggleSelectionMode();
  }

  void _toggleNoteSelection(Note note) {
    setState(() {
      if (_selectedNotes.contains(note)) {
        _selectedNotes.remove(note);
      } else {
        _selectedNotes.add(note);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400, // Decrease the font weight
          ),
        ),
        backgroundColor: Colors.white, // Set the AppBar background color to white
        iconTheme: IconThemeData(color: Colors.black), // Set the color of icons in AppBar
        elevation: 0.0, // Remove the shadow/depth of the AppBar
        actions: <Widget>[
          if (_isSelectionMode)
            Transform.scale(
              scale: 1.2, // Increase the size of the delete icon
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: _selectedNotes.isEmpty ? null : _deleteSelectedNotes,
                padding: EdgeInsets.symmetric(horizontal: 5.0), // Reduce padding around the trash icon
              ),
            ),
          Transform.scale(
            scale: 1.3, // Increase the size of the Checkbox
            child: Checkbox(
              value: _isSelectionMode,
              onChanged: (value) {
                _toggleSelectionMode();
              },
            ),
          ),
          SizedBox(width: 9.0), // Adjust spacing between the Checkbox and the Add Icon
          Padding(
            padding: const EdgeInsets.only(right: 14.0), // Add padding to the right
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
                            // Do nothing here, as the note is already added in AddNoteDialog
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
            // If no notes, display a message with padding
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Horizontal padding added
                child: Text(
                  'No notes yet. Tap the "+" button to add a note or use the note icon on each device.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300), // Decrease the font weight
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else {
            // If there are notes, display them using ListView.builder
            final reversedNotes = notesList.notes.reversed.toList();
            return ListView.builder(
              itemCount: reversedNotes.length,
              itemBuilder: (context, index) {
                final note = reversedNotes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding
                  child: ListTile(
                    onLongPress: () {
                      if (!_isSelectionMode) {
                        _toggleSelectionMode();
                      }
                      _toggleNoteSelection(note);
                    },
                    onTap: () {
                      if (_isSelectionMode) {
                        _toggleNoteSelection(note);
                      }
                    },
                    title: Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Device: ${note.device?.deviceName ?? "N/A"}'),
                        Text('${note.creationDate.toLocal().toString().split('.')[0]}'),
                      ],
                    ),
                    trailing: _isSelectionMode
                        ? Transform.scale(
                      scale: 1.2, // Slightly increase the size of the selection checkboxes
                      child: Checkbox(
                        value: _selectedNotes.contains(note),
                        onChanged: (value) {
                          _toggleNoteSelection(note);
                        },
                      ),
                    )
                        : null,
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
