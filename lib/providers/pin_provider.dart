import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider that holds the current active PIN
///
/// When null, no vault is open and the user should be on the PIN entry screen
/// When non-null, a vault is open with that PIN
final pinProvider = StateProvider<String?>((ref) => null);
