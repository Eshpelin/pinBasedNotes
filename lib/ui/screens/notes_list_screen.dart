import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/db/vault_manager.dart';
import '../../data/models/note.dart';
import '../../providers/notes_providers.dart';
import '../../providers/pin_provider.dart';
import '../../providers/lifecycle_provider.dart';
import '../widgets/note_tile.dart';
import 'editor_screen.dart';
import 'pin_entry_screen.dart';

class NotesListScreen extends HookConsumerWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesListProvider);
    final pin = ref.watch(pinProvider);
    final searchQuery = useState('');
    final searchController = useTextEditingController();
    final isFabMenuOpen = useState(false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        automaticallyImplyLeading: false,
        actions: [
          // Settings/Menu
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'lock') {
                _lockVault(context, ref);
              } else if (value == 'delete_vault') {
                _showDeleteVaultDialog(context, ref, pin!);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'lock',
                child: Row(
                  children: [
                    Icon(Icons.lock_outline),
                    SizedBox(width: 8),
                    Text('Lock Vault'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_vault',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Vault', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: notesAsync.when(
        data: (notes) {
          // Filter notes based on search query
          final filteredNotes = searchQuery.value.isEmpty
              ? notes
              : notes.where((note) {
                  final query = searchQuery.value.toLowerCase();
                  final titleMatch = note.title.toLowerCase().contains(query);
                  final contentMatch = note.plainText.toLowerCase().contains(query);
                  return titleMatch || contentMatch;
                }).toList();

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SearchBar(
                  controller: searchController,
                  hintText: 'Search notes...',
                  leading: const Icon(Icons.search),
                  trailing: searchQuery.value.isNotEmpty
                      ? [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              searchQuery.value = '';
                            },
                          ),
                        ]
                      : null,
                  onChanged: (value) => searchQuery.value = value,
                  elevation: const WidgetStatePropertyAll(2),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Notes list or empty state
              Expanded(
                child: filteredNotes.isEmpty
                    ? searchQuery.value.isNotEmpty
                        ? _NoSearchResults(searchQuery: searchQuery.value)
                        : _EmptyState(onCreateNote: () => _createNote(context, ref))
                    : ListView.builder(
                        itemCount: filteredNotes.length,
                        itemBuilder: (context, index) {
                          final note = filteredNotes[index];
                          return NoteTile(
                            note: note,
                            onTap: () => _openEditor(context, note.id),
                            onDelete: () => _deleteNote(context, ref, note),
                            onDeleteConfirmed: () => _deleteNoteConfirmed(context, ref, note),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(notesListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // FAB Menu Options (shown when menu is open)
          if (isFabMenuOpen.value) ...[
            // Image Note
            _FabMenuItem(
              icon: Icons.image,
              label: 'Image Note',
              onPressed: () async {
                isFabMenuOpen.value = false;
                await _createImageNote(context, ref);
              },
            ),
            const SizedBox(height: 12),
            // Paste Text Note
            _FabMenuItem(
              icon: Icons.content_paste,
              label: 'Paste Text',
              onPressed: () async {
                isFabMenuOpen.value = false;
                await _createNoteFromClipboard(context, ref);
              },
            ),
            const SizedBox(height: 12),
            // Compose New
            _FabMenuItem(
              icon: Icons.edit,
              label: 'Compose New',
              onPressed: () async {
                isFabMenuOpen.value = false;
                await _createNote(context, ref);
              },
            ),
            const SizedBox(height: 16),
          ],
          // Main FAB
          FloatingActionButton(
            onPressed: () => isFabMenuOpen.value = !isFabMenuOpen.value,
            child: AnimatedRotation(
              turns: isFabMenuOpen.value ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(isFabMenuOpen.value ? Icons.close : Icons.add),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: FilledButton.icon(
              onPressed: () => _lockVault(context, ref),
              icon: const Icon(Icons.lock_outline),
              label: const Text('Lock Vault'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                padding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createNote(BuildContext context, WidgetRef ref) async {
    try {
      final notifier = ref.read(notesNotifierProvider.notifier);
      final note = await notifier.createNote();

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditorScreen(noteId: note.id),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create note: $e')),
        );
      }
    }
  }

  Future<void> _createImageNote(BuildContext context, WidgetRef ref) async {
    try {
      // Show bottom sheet to choose image source
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      // Set flag to prevent vault from locking while image picker is open
      ref.read(isSystemUiOpenProvider.notifier).state = true;

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      // Clear flag now that image picker is closed
      ref.read(isSystemUiOpenProvider.notifier).state = false;

      if (image == null) return;

      // Create note with image
      final notifier = ref.read(notesNotifierProvider.notifier);
      final note = await notifier.createNote();

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditorScreen(noteId: note.id),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note created - insert image in editor'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Make sure to clear flag even if there's an error
      ref.read(isSystemUiOpenProvider.notifier).state = false;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create image note: $e')),
        );
      }
    }
  }

  Future<void> _createNoteFromClipboard(BuildContext context, WidgetRef ref) async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');

      if (clipboardData?.text == null || clipboardData!.text!.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Clipboard is empty')),
          );
        }
        return;
      }

      final notifier = ref.read(notesNotifierProvider.notifier);
      final note = await notifier.createNote();

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditorScreen(
              noteId: note.id,
              initialText: clipboardData.text,
            ),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note created with clipboard text'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create note: $e')),
        );
      }
    }
  }

  void _openEditor(BuildContext context, String noteId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditorScreen(noteId: noteId),
      ),
    );
  }

  Future<void> _deleteNote(BuildContext context, WidgetRef ref, Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Delete "${note.title}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteNoteConfirmed(context, ref, note);
    }
  }

  Future<void> _deleteNoteConfirmed(BuildContext context, WidgetRef ref, Note note) async {
    try {
      final notifier = ref.read(notesNotifierProvider.notifier);
      await notifier.deleteNote(note.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete note: $e')),
        );
      }
    }
  }

  void _lockVault(BuildContext context, WidgetRef ref) {
    // Clear the PIN to lock the vault
    ref.read(pinProvider.notifier).state = null;

    // Navigate back to PIN entry screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const PinEntryScreen()),
      (route) => false,
    );
  }

  Future<void> _showDeleteVaultDialog(
    BuildContext context,
    WidgetRef ref,
    String pin,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vault'),
        content: const Text(
          'This will permanently delete ALL notes in this vault.\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Vault'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Clear the PIN first
        ref.read(pinProvider.notifier).state = null;

        // Delete the vault
        await VaultManager.deleteVault(pin);

        if (context.mounted) {
          // Navigate back to PIN entry
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const PinEntryScreen()),
            (route) => false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vault deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete vault: $e')),
          );
        }
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateNote;

  const _EmptyState({required this.onCreateNote});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_outlined,
            size: 96,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first note',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: onCreateNote,
            icon: const Icon(Icons.add),
            label: const Text('Create Note'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  final String searchQuery;

  const _NoSearchResults({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 96,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'No notes match "$searchQuery"',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Try a different search term',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class _FabMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _FabMenuItem({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          heroTag: label,
          onPressed: onPressed,
          child: Icon(icon),
        ),
      ],
    );
  }
}
