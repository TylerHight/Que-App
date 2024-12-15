// lib/core/database/repositories/note_repository.dart

import 'package:que_app/core/models/note.dart';
import '../database/abstracts/crud_repository.dart';
import '../database/providers/sqlite_provider.dart';
import 'device_repository.dart';

class NoteRepository implements CrudRepository<Note> {
  final SQLiteProvider _provider;
  static const String _tableName = 'notes';

  NoteRepository({required SQLiteProvider provider}) : _provider = provider;

  @override
  Future<Note> create(Note note) async {
    try {
      final id = await _provider.insert(_tableName, _toMap(note));
      return note.copy(id: id.toString());
    } catch (e) {
      throw DatabaseException('Failed to create note: $e');
    }
  }

  @override
  Future<Note?> read(String id) async {
    try {
      final maps = await _provider.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return _fromMap(maps.first);
    } catch (e) {
      throw DatabaseException('Failed to read note: $e');
    }
  }

  @override
  Future<List<Note>> getAll() async {
    try {
      final maps = await _provider.query(_tableName);
      return maps.map(_fromMap).toList();
    } catch (e) {
      throw DatabaseException('Failed to get all notes: $e');
    }
  }

  Future<List<Note>> getNotesForDevice(String deviceId) async {
    try {
      final maps = await _provider.query(
        _tableName,
        where: 'deviceId = ?',
        whereArgs: [deviceId],
        orderBy: 'creationDate DESC',
      );
      return maps.map(_fromMap).toList();
    } catch (e) {
      throw DatabaseException('Failed to get notes for device: $e');
    }
  }

  @override
  Future<bool> update(Note note) async {
    try {
      final count = await _provider.update(
        _tableName,
        _toMap(note),
        where: 'id = ?',
        whereArgs: [note.id],
      );
      return count > 0;
    } catch (e) {
      throw DatabaseException('Failed to update note: $e');
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      final count = await _provider.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      throw DatabaseException('Failed to delete note: $e');
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      final count = await _provider.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      return count.isNotEmpty;
    } catch (e) {
      throw DatabaseException('Failed to check note existence: $e');
    }
  }

  @override
  Future<int> count() async {
    try {
      final result = await _provider.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
      return result.first['count'] as int;
    } catch (e) {
      throw DatabaseException('Failed to count notes: $e');
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _provider.delete(_tableName);
    } catch (e) {
      throw DatabaseException('Failed to delete all notes: $e');
    }
  }

  Map<String, dynamic> _toMap(Note note) {
    return {
      'id': note.id,
      'content': note.content,
      'creationDate': note.creationDate.toIso8601String(),
      'deviceId': note.device?.id,
    };
  }

  Note _fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      content: map['content'] as String,
      creationDate: DateTime.parse(map['creationDate'] as String),
      device: null, // Device will need to be set separately
    );
  }
}