import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import '../../providers/notes_providers.dart';
import '../../utils/debounce.dart';
import '../../utils/date_format.dart';

class EditorScreen extends HookConsumerWidget {
  final String noteId;

  const EditorScreen({super.key, required this.noteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteProvider(noteId));
    final controller = useMemoized(() => QuillController.basic());
    final focusNode = useFocusNode();
    final scrollController = useScrollController();

    final debouncer = useMemoized(
      () => Debouncer(duration: const Duration(milliseconds: 300)),
    );
    final isSaving = useState(false);
    final lastSaved = useState<int?>(null);
    final hasUnsavedChanges = useState(false);

    // Dispose resources when widget is disposed
    useEffect(() {
      return () {
        debouncer.dispose();
        controller.dispose();
      };
    }, []);

    // Load note content into controller
    useEffect(() {
      noteAsync.whenData((note) {
        if (note != null) {
          try {
            final delta = Delta.fromJson(jsonDecode(note.content) as List);
            // Only update if content has changed to avoid cursor jumping
            if (controller.document.toDelta() != delta) {
              controller.document = Document.fromDelta(delta);
            }
            lastSaved.value = note.updatedAt;
            hasUnsavedChanges.value = false;
          } catch (e) {
            // If JSON parsing fails, treat as plain text
            controller.document = Document()..insert(0, note.content);
          }
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
          final delta = controller.document.toDelta();
          final deltaJson = jsonEncode(delta.toJson());

          final notifier = ref.read(notesNotifierProvider.notifier);
          await notifier.updateNote(noteId, deltaJson);
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

    // Listen to document changes
    useEffect(() {
      void listener() {
        hasUnsavedChanges.value = true;
        saveNote();
      }

      controller.document.changes.listen((_) => listener());
      return null;
    }, [controller]);

    return PopScope(
      canPop: !hasUnsavedChanges.value,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && hasUnsavedChanges.value) {
          // Force save before popping
          debouncer.cancel();
          isSaving.value = true;
          try {
            final delta = controller.document.toDelta();
            final deltaJson = jsonEncode(delta.toJson());
            final notifier = ref.read(notesNotifierProvider.notifier);
            await notifier.updateNote(noteId, deltaJson);
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

            return Column(
              children: [
                // Rich text toolbar
                QuillSimpleToolbar(
                  controller: controller,
                  config: const QuillSimpleToolbarConfig(
                    showAlignmentButtons: true,
                    showBackgroundColorButton: false,
                    showClearFormat: true,
                    showCodeBlock: true,
                    showFontFamily: false,
                    showFontSize: false,
                    showHeaderStyle: true,
                    showInlineCode: false,
                    showLink: false,
                    showListBullets: true,
                    showListCheck: false,
                    showListNumbers: true,
                    showQuote: true,
                    showRedo: true,
                    showSearchButton: false,
                    showSmallButton: false,
                    showStrikeThrough: true,
                    showSubscript: false,
                    showSuperscript: false,
                    showUnderLineButton: true,
                    showUndo: true,
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                // Rich text editor
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: QuillEditor.basic(
                      controller: controller,
                      focusNode: focusNode,
                      scrollController: scrollController,
                      config: const QuillEditorConfig(
                        padding: EdgeInsets.zero,
                        scrollable: true,
                        autoFocus: false,
                        expands: false,
                        placeholder: 'Start typing...',
                      ),
                    ),
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
