import 'package:sqflite_sqlcipher/sqflite.dart';
import '../models/note.dart';

class NotesRepository {
  final Database _db;

  NotesRepository(this._db);

  /// Get all notes sorted by updatedAt DESC
  Future<List<Note>> getAllNotes() async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        'notes',
        orderBy: 'updatedAt DESC',
      );

      return maps.map((map) => Note.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load notes: $e');
    }
  }

  /// Get a single note by ID
  Future<Note?> getNoteById(String id) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return Note.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to load note: $e');
    }
  }

  /// Create a new note
  ///
  /// According to the spec, notes are created immediately with empty content
  /// to prevent data loss if the app crashes mid-edit
  Future<Note> createNote() async {
    try {
      final note = Note.create();
      await _db.insert(
        'notes',
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return note;
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  /// Update a note's content
  ///
  /// This is called by the auto-save mechanism (300ms debounce)
  /// Updates both content and updatedAt timestamp
  Future<void> updateNote(String id, String content) async {
    try {
      final updatedAt = DateTime.now().millisecondsSinceEpoch;
      final rowsAffected = await _db.update(
        'notes',
        {
          'content': content,
          'updatedAt': updatedAt,
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw Exception('Note not found: $id');
      }
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  /// Delete a note by ID
  Future<void> deleteNote(String id) async {
    try {
      final rowsAffected = await _db.delete(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        throw Exception('Note not found: $id');
      }
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  /// Get the count of notes in the vault
  Future<int> getNotesCount() async {
    try {
      final result = await _db.rawQuery('SELECT COUNT(*) as count FROM notes');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to count notes: $e');
    }
  }

  /// Search notes by content
  ///
  /// Optional feature - not in original spec but useful
  Future<List<Note>> searchNotes(String query) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        'notes',
        where: 'content LIKE ?',
        whereArgs: ['%$query%'],
        orderBy: 'updatedAt DESC',
      );

      return maps.map((map) => Note.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to search notes: $e');
    }
  }
}
