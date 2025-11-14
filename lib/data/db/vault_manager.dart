import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'migrations.dart';
import 'meta_db_manager.dart';

/// Exception thrown when the PIN is incorrect for an existing vault
class IncorrectPinException implements Exception {
  final String message;
  IncorrectPinException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when the user has exceeded the rate limit for PIN attempts
class RateLimitExceededException implements Exception {
  final String message;
  RateLimitExceededException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when vault operations fail
class VaultException implements Exception {
  final String message;
  VaultException(this.message);

  @override
  String toString() => message;
}

class VaultManager {
  /// The maximum number of unique PIN attempts per day
  static const int maxPinAttemptsPerDay = 10;

  /// Open or create a vault for the given PIN
  ///
  /// Returns a Database instance if successful
  /// Throws IncorrectPinException if the PIN is wrong for an existing vault
  /// Throws RateLimitExceededException if the user has tried too many unique PINs today
  /// Throws VaultException for other database errors
  static Future<Database> openVault(String pin) async {
    try {
      // Check rate limit before proceeding
      final attempts = await MetaDbManager.getUniquePinAttemptsToday();
      if (attempts >= maxPinAttemptsPerDay) {
        throw RateLimitExceededException('You have tried too many different PINs today. Please try again tomorrow.');
      }

      // Validate PIN
      if (pin.isEmpty || pin.length < 4 || pin.length > 10) {
        throw VaultException('PIN must be between 4 and 10 digits');
      }

      // Get the database path
      final dbPath = await _getVaultPath(pin);
      final dbExists = await File(dbPath).exists();

      // Open or create the encrypted database
      // The PIN is used directly as the encryption password
      final database = await openDatabase(
        dbPath,
        password: pin,
        version: DatabaseMigrations.currentVersion,
        onCreate: (db, version) async {
          // Run all migrations for a new database
          await DatabaseMigrations.migrate(db, 0, version);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          // Run migrations for an existing database
          await DatabaseMigrations.migrate(db, oldVersion, newVersion);
        },
      );

      // Test the database connection by running a simple query
      // This will fail if the PIN is incorrect for an existing database
      try {
        await database.rawQuery('SELECT 1');

        // If this is a NEW vault (didn't exist before), log the attempt
        // This enforces the rate limit on vault creation
        if (!dbExists) {
          await MetaDbManager.logPinAttempt(pin);
        }
      } catch (e) {
        await database.close();
        if (dbExists) {
          await MetaDbManager.logPinAttempt(pin);
          throw IncorrectPinException('Incorrect PIN. Try again.');
        }
        rethrow;
      }

      return database;
    } on IncorrectPinException {
      rethrow;
    } on RateLimitExceededException {
      rethrow;
    } on DatabaseException catch (e) {
      // SQLCipher throws DatabaseException when decryption fails
      if (e.toString().contains('file is not a database') ||
          e.toString().contains('file is encrypted') ||
          e.toString().contains('cipher')) {
        await MetaDbManager.logPinAttempt(pin);
        throw IncorrectPinException('Incorrect PIN. Try again.');
      }
      throw VaultException('Database error: ${e.toString()}');
    } catch (e) {
      throw VaultException('Failed to open vault: ${e.toString()}');
    }
  }

  /// Close a vault database
  static Future<void> closeVault(Database db) async {
    try {
      await db.close();
    } catch (e) {
      throw VaultException('Failed to close vault: ${e.toString()}');
    }
  }

  /// Delete a vault for the given PIN
  ///
  /// This will permanently delete the database file
  /// The vault must be closed before calling this method
  static Future<void> deleteVault(String pin) async {
    try {
      final dbPath = await _getVaultPath(pin);
      final file = File(dbPath);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw VaultException('Failed to delete vault: ${e.toString()}');
    }
  }

  /// Check if a vault exists for the given PIN
  static Future<bool> vaultExists(String pin) async {
    try {
      final dbPath = await _getVaultPath(pin);
      return await File(dbPath).exists();
    } catch (e) {
      return false;
    }
  }

  /// Get the file path for a vault database
  static Future<String> _getVaultPath(String pin) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(join(appDir.path, 'databases'));

    // Create databases directory if it doesn't exist
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    // Construct path: <app_dir>/databases/vault_<pin>.db
    return join(dbDir.path, 'vault_$pin.db');
  }
}
