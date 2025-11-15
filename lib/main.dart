import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'providers/lifecycle_provider.dart';
import 'providers/pin_provider.dart';
import 'ui/screens/pin_entry_screen.dart';
import 'ui/screens/notes_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable screenshots on Android
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    const ProviderScope(
      child: PinNotesApp(),
    ),
  );
}

class PinNotesApp extends ConsumerWidget {
  const PinNotesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize lifecycle observer to lock vault when app is backgrounded
    ref.watch(lifecycleObserverProvider);

    // Watch the PIN to determine which screen to show
    final pin = ref.watch(pinProvider);

    return MaterialApp(
      title: 'PIN Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,

        // Card theme for consistent elevation and shape
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Input decoration theme for text fields
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),

        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),

        // Floating action button theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // AppBar theme
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ...FlutterQuillLocalizations.localizationsDelegates,
      ],
      supportedLocales: FlutterQuillLocalizations.supportedLocales,
      // Show notes list if PIN is set, otherwise show PIN entry
      home: pin != null ? const NotesListScreen() : const PinEntryScreen(),
    );
  }
}
