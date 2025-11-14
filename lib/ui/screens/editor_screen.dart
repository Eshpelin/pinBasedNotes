import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/notes_providers.dart';
import '../../utils/debounce.dart';
import '../../utils/date_format.dart';
import '../../utils/ml_title_generator.dart';

class EditorScreen extends HookConsumerWidget {
  final String noteId;

  const EditorScreen({super.key, required this.noteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteProvider(noteId));
    final controller = useMemoized(() => QuillController.basic());
    final titleController = useTextEditingController();
    final focusNode = useFocusNode();
    final scrollController = useScrollController();

    final debouncer = useMemoized(
      () => Debouncer(duration: const Duration(milliseconds: 300)),
    );
    final isSaving = useState(false);
    final lastSaved = useState<int?>(null);
    final hasUnsavedChanges = useState(false);
    final isInitialLoad = useState(true);
    final isTitleManuallyEdited = useState(false);

    // Dispose resources when widget is disposed
    useEffect(() {
      return () {
        debouncer.dispose();
        controller.dispose();
      };
    }, []);

    // Load note content and title into controllers
    useEffect(() {
      noteAsync.whenData((note) {
        if (note != null) {
          try {
            final delta = Delta.fromJson(jsonDecode(note.content) as List);
            // Only update on initial load to avoid cursor jumping during editing
            if (isInitialLoad.value) {
              controller.document = Document.fromDelta(delta);
              titleController.text = note.title;

              // Check if title appears to be auto-generated using ML
              final plainText = controller.document.toPlainText().trim();
              final (_, isGibberish) = MLTitleGenerator.generateTitle(plainText);
              // If title is empty or looks auto-generated, allow ML to regenerate
              isTitleManuallyEdited.value = note.title.isNotEmpty &&
                  !plainText.toLowerCase().startsWith(note.title.toLowerCase());

              lastSaved.value = note.updatedAt;
              hasUnsavedChanges.value = false;
              isInitialLoad.value = false;
            } else if (!hasUnsavedChanges.value) {
              // Only update if there are no unsaved changes (e.g., external update)
              // Save cursor position before update
              final selection = controller.selection;
              controller.document = Document.fromDelta(delta);
              titleController.text = note.title;
              // Restore cursor position if valid
              if (selection.isValid && selection.end <= controller.document.length) {
                controller.updateSelection(selection, ChangeSource.local);
              }
              lastSaved.value = note.updatedAt;
            }
          } catch (e) {
            // If JSON parsing fails, treat as plain text
            if (isInitialLoad.value) {
              controller.document = Document()..insert(0, note.content);
              titleController.text = note.title;
              isInitialLoad.value = false;
            }
          }
        }
      });
      return null;
    }, [noteAsync]);

    // Auto-save functionality
    void saveNote({bool forceTitleUpdate = false}) {
      if (!hasUnsavedChanges.value && !forceTitleUpdate) return;

      debouncer(() async {
        isSaving.value = true;
        try {
          final delta = controller.document.toDelta();
          final deltaJson = jsonEncode(delta.toJson());

          // Auto-generate title using ML if it hasn't been manually edited
          String titleToSave = titleController.text;
          if (!isTitleManuallyEdited.value || forceTitleUpdate) {
            final plainText = controller.document.toPlainText().trim();
            final (generated, isGibberish) = MLTitleGenerator.generateTitle(plainText);
            if (generated.isNotEmpty) {
              titleToSave = generated;
              titleController.text = titleToSave;

              // Show a subtle indicator for gibberish detection
              if (isGibberish && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎲 Gibberish detected! Generated a funny title'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          }

          final notifier = ref.read(notesNotifierProvider.notifier);
          await notifier.updateNote(noteId, title: titleToSave, content: deltaJson);
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

      final subscription = controller.document.changes.listen((_) => listener());
      return subscription.cancel;
    }, [controller]);

    // Image insertion methods
    Future<void> insertImage(ImageSource source) async {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );

        if (image == null) return;

        // Read image as bytes and convert to base64
        final bytes = await File(image.path).readAsBytes();
        final base64Image = base64Encode(bytes);
        final dataUrl = 'data:image/${image.path.split('.').last};base64,$base64Image';

        // Insert image at current cursor position
        final index = controller.selection.baseOffset;
        final length = controller.selection.extentOffset - index;

        controller.document.delete(index, length);
        controller.document.insert(index, BlockEmbed.image(dataUrl));

        // Move cursor after the image
        controller.updateSelection(
          TextSelection.collapsed(offset: index + 1),
          ChangeSource.local,
        );

        hasUnsavedChanges.value = true;
        saveNote();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to insert image: $e')),
          );
        }
      }
    }

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

            // Auto-generate title using ML if needed
            String titleToSave = titleController.text;
            if (!isTitleManuallyEdited.value) {
              final plainText = controller.document.toPlainText().trim();
              final (generated, _) = MLTitleGenerator.generateTitle(plainText);
              if (generated.isNotEmpty) {
                titleToSave = generated;
              }
            }

            final notifier = ref.read(notesNotifierProvider.notifier);
            await notifier.updateNote(noteId, title: titleToSave, content: deltaJson);
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
                // Title TextField
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: TextField(
                    controller: titleController,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Note Title',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (value) {
                      // Mark as manually edited when user types
                      if (value.isNotEmpty) {
                        isTitleManuallyEdited.value = true;
                      }
                      hasUnsavedChanges.value = true;
                      saveNote();
                    },
                  ),
                ),

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

                // Custom image/camera toolbar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: Colors.grey.shade100,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_library, size: 20),
                        tooltip: 'Insert from Gallery',
                        onPressed: () => insertImage(ImageSource.gallery),
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt, size: 20),
                        tooltip: 'Take Photo',
                        onPressed: () => insertImage(ImageSource.camera),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Insert Image',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
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
