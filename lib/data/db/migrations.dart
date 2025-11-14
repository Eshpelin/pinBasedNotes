import 'package:sqflite_sqlcipher/sqflite.dart';

class DatabaseMigrations {
  /// Initial database version
  static const int initialVersion = 1;

  /// Current database version
  static const int currentVersion = 2;

  /// Run all migrations up to the current version
  static Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    // Run migrations sequentially from oldVersion to newVersion
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      await _runMigration(db, version);
    }
  }

  /// Run a specific migration version
  static Future<void> _runMigration(Database db, int version) async {
    switch (version) {
      case 1:
        await _migration1(db);
        break;
      case 2:
        await _migration2(db);
        break;
      default:
        throw Exception('Unknown migration version: $version');
    }
  }

  /// Migration 1: Create the notes table
  static Future<void> _migration1(Database db) async {
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Create an index on updatedAt for faster sorting
    await db.execute('''
      CREATE INDEX idx_notes_updatedAt ON notes(updatedAt DESC)
    ''');
  }

  /// Migration 2: Add title column to notes table
  static Future<void> _migration2(Database db) async {
    // Add title column with default empty string
    await db.execute('''
      ALTER TABLE notes ADD COLUMN title TEXT NOT NULL DEFAULT ''
    ''');
  }
}
