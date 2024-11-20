import 'package:flutter/material.dart';
import 'package:que_app/models/note.dart';
import 'package:que_app/models/notes_list.dart';
import 'package:provider/provider.dart';
import '../../../models/device.dart';

class AddNoteDialog extends StatefulWidget {
  final Function(Note) onNoteAdded;
  final Device? device; // Optional device parameter

  AddNoteDialog({required this.onNoteAdded, this.device}); // Initialize the parameter

  @override
  _AddNoteDialogState createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Note',
        style: TextStyle(color: Colors.black), // Set the title color to black
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Add'),
          onPressed: () {
            _addNote();
          },
        ),
      ],
    );
  }

  void _addNote() {
    final content = _contentController.text;
    final newNote = Note(
      id: UniqueKey().toString(),
      content: content,
      creationDate: DateTime.now(),
      device: widget.device, // Set the device parameter if provided
    );

    // Add the new note to the NotesList
    Provider.of<NotesList>(context, listen: false).add(newNote);

    // Pass the new note back to the callback function
    widget.onNoteAdded(newNote);

    // Close the dialog
    Navigator.of(context).pop();
  }
}
