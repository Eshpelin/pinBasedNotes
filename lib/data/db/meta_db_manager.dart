import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class MetaDbManager {
  static const _dbName = 'meta.db';
  static const _dbVersion = 1;

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, _dbName);

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pin_attempts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pin_hash TEXT NOT NULL,
            attempted_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE INDEX idx_pin_attempts_attempted_at ON pin_attempts(attempted_at DESC)
        ''');
      },
    );
  }

  static Future<void> logPinAttempt(String pin) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final pinHash = _hashPin(pin);

    await db.insert(
      'pin_attempts',
      {
        'pin_hash': pinHash,
        'attempted_at': now,
      },
    );
  }

  static Future<int> getUniquePinAttemptsToday() async {
    final db = await database;
    final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).millisecondsSinceEpoch;

    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT pin_hash) as count FROM pin_attempts WHERE attempted_at >= ?',
      [todayStart],
    );

    return (result.first['count'] as int?) ?? 0;
  }

  static String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
