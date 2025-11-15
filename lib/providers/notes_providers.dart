import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/models/note.dart';
import '../data/repositories/notes_repository.dart';
import 'db_provider.dart';

/// Provider for the NotesRepository
/// Not using autoDispose to prevent disposal during navigation
/// which could interrupt pending save operations
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final dbAsync = ref.watch(vaultDbProvider);

  return dbAsync.when(
    data: (db) => NotesRepository(db),
    loading: () => throw Exception('Database is loading'),
    error: (error, stack) => throw error,
  );
});

/// Provider that fetches all notes sorted by updatedAt DESC
final notesListProvider = FutureProvider.autoDispose<List<Note>>((ref) async {
  final repository = ref.watch(notesRepositoryProvider);
  return repository.getAllNotes();
});

/// Provider that fetches a single note by ID
final noteProvider =
    FutureProvider.autoDispose.family<Note?, String>((ref, noteId) async {
  final repository = ref.watch(notesRepositoryProvider);
  return repository.getNoteById(noteId);
});

/// Provider for the notes count
final notesCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.watch(notesRepositoryProvider);
  return repository.getNotesCount();
});

/// Notifier for managing note operations
/// Not using AutoDispose to prevent disposal during navigation
class NotesNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No initial state needed
  }

  NotesRepository get _repository => ref.read(notesRepositoryProvider);

  /// Create a new note
  Future<Note> createNote() async {
    final note = await _repository.createNote();
    // Invalidate the notes list to trigger a refresh
    ref.invalidate(notesListProvider);
    return note;
  }

  /// Update a note's title and/or content
  Future<void> updateNote(String id, {String? title, String? content}) async {
    await _repository.updateNote(id, title: title, content: content);
    // Invalidate providers to trigger refresh
    ref.invalidate(notesListProvider);
    ref.invalidate(noteProvider(id));
  }

  /// Delete a note
  Future<void> deleteNote(String id) async {
    await _repository.deleteNote(id);
    // Invalidate the notes list to trigger a refresh
    ref.invalidate(notesListProvider);
  }
}

/// Provider for the NotesNotifier
/// Not using AutoDispose to prevent disposal during navigation
final notesNotifierProvider =
    AsyncNotifierProvider<NotesNotifier, void>(() {
  return NotesNotifier();
});
