import 'package:flutter/foundation.dart';
import 'note.dart';

class NotesList extends ChangeNotifier {
  final List<Note> _notes = [];

  List<Note> get notes => _notes;

  void add(Note note) {
    _notes.add(note);
    notifyListeners();
  }

  void remove(Note note) {
    _notes.remove(note);
    notifyListeners();
  }

  void removeMultiple(List<Note> notes) {
    _notes.removeWhere((note) => notes.contains(note));
    notifyListeners();
  }
}
