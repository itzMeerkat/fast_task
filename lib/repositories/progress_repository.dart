// Repository for progress record data operations

import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../database/tables.dart';
import '../models/progress_record.dart';

/// Repository for managing progress record data in the database
class ProgressRepository {
  final DatabaseHelper _dbHelper;

  ProgressRepository() : _dbHelper = DatabaseHelper.instance;

  /// Insert a new progress record or update existing one for the same task and date
  Future<int> insertProgress(ProgressRecord record) async {
    final db = await _dbHelper.database;
    
    // Normalize date to start of day for uniqueness constraint
    final startOfDay = DateTime(record.date.year, record.date.month, record.date.day);
    
    // Create a normalized record
    final normalizedRecord = ProgressRecord(
      id: record.id,
      taskId: record.taskId,
      date: startOfDay,
      hoursSpent: record.hoursSpent,
    );
    
    // Use INSERT OR REPLACE for atomic upsert
    return await db.insert(
      progressTableName,
      normalizedRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all progress records for a specific task
  Future<List<ProgressRecord>> getProgressByTaskId(int taskId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      progressTableName,
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'date DESC',
    );

    return maps.map((map) => ProgressRecord.fromMap(map)).toList();
  }

  /// Get all progress records for a specific date
  Future<List<ProgressRecord>> getProgressByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      progressTableName,
      where: 'date >= ? AND date < ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
    );

    return maps.map((map) => ProgressRecord.fromMap(map)).toList();
  }

  /// Check if a task has progress recorded for today
  Future<bool> hasProgressForToday(int taskId) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.query(
      progressTableName,
      where: 'task_id = ? AND date >= ? AND date < ?',
      whereArgs: [
        taskId,
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  /// Get all progress records
  Future<List<ProgressRecord>> getAllProgress() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      progressTableName,
      orderBy: 'date DESC',
    );

    return maps.map((map) => ProgressRecord.fromMap(map)).toList();
  }
}

