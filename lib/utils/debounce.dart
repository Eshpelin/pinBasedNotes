import 'dart:async';

/// A debouncer that delays execution until after a specified duration
///
/// Used for auto-save: waits 300ms after the last keystroke before saving
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({required this.duration});

  /// Call the action after the debounce duration
  ///
  /// If called again before the duration expires, the previous call is cancelled
  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancel any pending action
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose of the debouncer
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
