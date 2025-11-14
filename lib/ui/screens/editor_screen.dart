import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../providers/notes_providers.dart';
import '../../utils/debounce.dart';
import '../../utils/date_format.dart';

class EditorScreen extends HookConsumerWidget {
  final String noteId;

  const EditorScreen({super.key, required this.noteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteProvider(noteId));
    final controller = useTextEditingController();
    final debouncer = useMemoized(
      () => Debouncer(duration: const Duration(milliseconds: 300)),
    );
    final isSaving = useState(false);
    final lastSaved = useState<int?>(null);
    final hasUnsavedChanges = useState(false);

    // Dispose debouncer when widget is disposed
    useEffect(() {
      return () => debouncer.dispose();
    }, []);

    // Load note content into controller
    useEffect(() {
      noteAsync.whenData((note) {
        if (note != null && controller.text != note.content) {
          controller.text = note.content;
          lastSaved.value = note.updatedAt;
          hasUnsavedChanges.value = false;
        }
      });
      return null;
    }, [noteAsync]);

    // Auto-save functionality
    void saveNote() {
      if (!hasUnsavedChanges.value) return;

      debouncer(() async {
        isSaving.value = true;
        try {
          final notifier = ref.read(notesNotifierProvider.notifier);
          await notifier.updateNote(noteId, controller.text);
          lastSaved.value = DateTime.now().millisecondsSinceEpoch;
          hasUnsavedChanges.value = false;
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save: $e')),
            );
          }
        } finally {
          isSaving.value = false;
        }
      });
    }

    // Listen to text changes
    useEffect(() {
      void listener() {
        hasUnsavedChanges.value = true;
        saveNote();
      }

      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    return PopScope(
      canPop: !hasUnsavedChanges.value,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && hasUnsavedChanges.value) {
          // Force save before popping
          debouncer.cancel();
          isSaving.value = true;
          try {
            final notifier = ref.read(notesNotifierProvider.notifier);
            await notifier.updateNote(noteId, controller.text);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save: $e')),
              );
            }
          } finally {
            isSaving.value = false;
            hasUnsavedChanges.value = false;
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Note'),
              if (lastSaved.value != null)
                Text(
                  'Last saved ${DateFormatter.formatTimestamp(lastSaved.value!)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
          actions: [
            if (isSaving.value)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              )
            else if (hasUnsavedChanges.value)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(Icons.circle, size: 12, color: Colors.orange),
              )
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(Icons.check_circle, size: 20, color: Colors.green),
              ),
          ],
        ),
        body: noteAsync.when(
          data: (note) {
            if (note == null) {
              return const Center(
                child: Text('Note not found'),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                autofocus: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Start typing...',
                  hintStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.5,
                ),
              ),
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
