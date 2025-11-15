import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'pin_provider.dart';

/// Provider that tracks app lifecycle state
final appLifecycleProvider = StateProvider<AppLifecycleState>((ref) {
  return AppLifecycleState.resumed;
});

/// Provider to track when system UI (image picker, etc.) is open
/// When true, prevents vault from auto-locking
final isSystemUiOpenProvider = StateProvider<bool>((ref) => false);

/// Observer that watches app lifecycle and locks vault when backgrounded
class AppLifecycleObserver extends WidgetsBindingObserver {
  final Ref ref;

  AppLifecycleObserver(this.ref);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Update the lifecycle state
    ref.read(appLifecycleProvider.notifier).state = state;

    // Check if system UI (like image picker) is open
    final isSystemUiOpen = ref.read(isSystemUiOpenProvider);

    // Lock vault when app goes to background
    // Note: Don't lock on 'inactive' state - this happens when system dialogs appear
    // or when the image picker is opened. Only lock when truly backgrounded.
    // Also don't lock if system UI (image picker) is currently open
    if ((state == AppLifecycleState.paused || state == AppLifecycleState.detached)
        && !isSystemUiOpen) {
      // Clear the PIN to lock the vault
      // This will trigger the database to close via the vaultDbProvider's onDispose
      ref.read(pinProvider.notifier).state = null;
    }
  }
}

/// Provider that creates and manages the lifecycle observer
final lifecycleObserverProvider = Provider<AppLifecycleObserver>((ref) {
  final observer = AppLifecycleObserver(ref);

  // Register the observer
  WidgetsBinding.instance.addObserver(observer);

  // Remove the observer when disposed
  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(observer);
  });

  return observer;
});
