// Database helper singleton for managing SQLite database

import 'dart:io' as io;
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'tables.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Singleton class for database operations
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  /// Database version
  static const int databaseVersion = 2;

  /// Database filename
  static const String databaseName = 'task_tracker.db';

  DatabaseHelper._();

  /// Get singleton instance
  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  /// Get database instance, initializing if necessary
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final io.Directory appDocumentsDir =
        await getApplicationDocumentsDirectory();
    // final databasesPath = await getDatabasesPath();
    final path = join(appDocumentsDir.path, "fast_task", databaseName);
    print('Database path: $path');
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  /// Create tables on database creation
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(createTaskTableSql);
    await db.execute(createProgressTableSql);
    await db.execute(createProgressIndexSql);
  }

  /// Upgrade database schema
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migrate to version 2: Add unique constraint on (task_id, date)
      // Get existing progress records
      final records = await db.query(progressTableName);

      // Drop old table
      await db.execute('DROP TABLE IF EXISTS $progressTableName');

      // Create new table with unique constraint
      await db.execute(createProgressTableSql);
      await db.execute(createProgressIndexSql);

      // Re-insert records with normalized dates (start of day)
      for (final record in records) {
        final date = DateTime.fromMillisecondsSinceEpoch(record['date'] as int);
        final startOfDay = DateTime(date.year, date.month, date.day);

        await db.insert(progressTableName, {
          'task_id': record['task_id'],
          'date': startOfDay.millisecondsSinceEpoch,
          'hours_spent': record['hours_spent'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
