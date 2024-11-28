import 'package:flutter/material.dart';
import 'package:que_app/core/models/note.dart';
import 'package:que_app/core/models/notes_list.dart';
import 'package:provider/provider.dart';
import '../../../core/models/device/index.dart';

class AddNoteDialog extends StatefulWidget {
  final Function(Note) onNoteAdded;
  final Device? device;

  const AddNoteDialog({
    super.key,
    required this.onNoteAdded,
    this.device,
  });

  @override
  _AddNoteDialogState createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _contentController = TextEditingController();
  bool _isInputValid = false;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_validateInput);
  }

  void _validateInput() {
    setState(() {
      _isInputValid = _contentController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _contentController.removeListener(_validateInput);
    _contentController.dispose();
    super.dispose();
  }

  void _addNote() {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    final newNote = Note(
      id: UniqueKey().toString(),
      content: content,
      creationDate: DateTime.now(),
      device: widget.device,
    );

    Provider.of<NotesList>(context, listen: false).add(newNote);
    widget.onNoteAdded(newNote);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.note_add_outlined,
                  size: 24,
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Add Note',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  color: Colors.grey[600],
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (widget.device != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.devices,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.device!.deviceName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: _contentController,
              maxLines: 5,
              maxLength: 500,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Write your note here...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isInputValid ? _addNote : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Add Note'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}