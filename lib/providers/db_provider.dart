import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../data/db/vault_manager.dart';
import 'pin_provider.dart';

/// Provider that manages the vault database instance
///
/// Opens the database for the current PIN
/// Automatically closes when the PIN changes or is cleared
///
/// NOT using autoDispose because:
/// - Database must stay open across screen navigations
/// - Closing DB during navigation breaks pending save operations
/// - Database lifecycle tied to PIN, not to widget lifecycle
final vaultDbProvider = FutureProvider<Database>((ref) async {
  final pin = ref.watch(pinProvider);

  if (pin == null) {
    throw Exception('No PIN set');
  }

  // Open the vault with the PIN
  final db = await VaultManager.openVault(pin);

  // Close the database when the PIN changes or provider is disposed
  ref.onDispose(() {
    VaultManager.closeVault(db);
  });

  return db;
});
