import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../data/db/vault_manager.dart';
import 'pin_provider.dart';

/// Provider that manages the vault database instance
///
/// Opens the database for the current PIN
/// Automatically closes when the PIN changes or is cleared
final vaultDbProvider = FutureProvider.autoDispose<Database>((ref) async {
  final pin = ref.watch(pinProvider);

  if (pin == null) {
    throw Exception('No PIN set');
  }

  // Open the vault with the PIN
  final db = await VaultManager.openVault(pin);

  // Close the database when this provider is disposed
  ref.onDispose(() {
    VaultManager.closeVault(db);
  });

  return db;
});
