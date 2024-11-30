import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que_app/core/models/note.dart';
import 'package:que_app/core/models/notes_list.dart';
import '../dialogs/add_note_dialog.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _isSelectionMode = false;
  final Set<Note> _selectedNotes = {};

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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        // Add leading close button when in selection mode
        leading: _isSelectionMode
            ? IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: _toggleSelectionMode,
          tooltip: 'Cancel selection',
        )
            : null,
        title: Text(
          _isSelectionMode ? '${_selectedNotes.length} selected' : 'My Notes',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: _isSelectionMode ? FontWeight.w500 : FontWeight.w600,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          if (_isSelectionMode)
            TextButton.icon(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: Text(
                'Delete',
                style: TextStyle(
                  color: _selectedNotes.isEmpty ? Colors.grey : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: _selectedNotes.isEmpty ? null : _deleteSelectedNotes,
            )
          else
            IconButton(
              icon: const Icon(Icons.checklist, color: Colors.black54),
              onPressed: _toggleSelectionMode,
              tooltip: 'Select notes',
            ),
          if (!_isSelectionMode)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Material(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AddNoteDialog(onNoteAdded: (_) {}),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 20),
                        SizedBox(width: 4),
                        Text(
                          'New Note',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Consumer<NotesList>(
        builder: (context, notesList, _) {
          if (notesList.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.note_alt_outlined,
                      size: 48,
                      color: Colors.blue[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No notes yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap "New Note" to create your first note\nor use the note icon on each device.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final reversedNotes = notesList.notes.reversed.toList();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reversedNotes.length,
            itemBuilder: (context, index) {
              final note = reversedNotes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onLongPress: () {
                    if (!_isSelectionMode) {
                      _toggleSelectionMode();
                      _toggleNoteSelection(note);
                    }
                  },
                  onTap: () {
                    if (_isSelectionMode) {
                      _toggleNoteSelection(note);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: _selectedNotes.contains(note)
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.devices,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  note.device?.deviceName ?? 'No Device',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              if (_isSelectionMode)
                                Transform.scale(
                                  scale: 1.1,
                                  child: Checkbox(
                                    value: _selectedNotes.contains(note),
                                    onChanged: (_) => _toggleNoteSelection(note),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            note.content,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatDate(note.creationDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}