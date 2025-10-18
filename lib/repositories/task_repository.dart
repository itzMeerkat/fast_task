// Repository for task data operations

import '../database/database_helper.dart';
import '../database/tables.dart';
import '../models/task.dart';
import '../models/enums.dart';

/// Repository for managing task data in the database
class TaskRepository {
  final DatabaseHelper _dbHelper;

  TaskRepository() : _dbHelper = DatabaseHelper.instance;

  /// Insert a new task
  Future<int> insertTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.insert(taskTableName, task.toMap());
  }

  /// Update an existing task
  Future<int> updateTask(Task task) async {
    final db = await _dbHelper.database;
    return await db.update(
      taskTableName,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Delete a task by id
  Future<int> deleteTask(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      taskTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get a single task by id
  Future<Task?> getTaskById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      taskTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  /// Get all tasks with optional sorting
  Future<List<Task>> getAllTasks({SortBy? sortBy}) async {
    final db = await _dbHelper.database;
    String? orderBy;

    if (sortBy != null) {
      switch (sortBy) {
        case SortBy.createTime:
          orderBy = 'create_time DESC';
          break;
        case SortBy.deadline:
          orderBy = 'CASE WHEN deadline IS NULL THEN 1 ELSE 0 END ASC, deadline ASC';
          break;
        case SortBy.priority:
          orderBy = 'priority ASC';
          break;
      }
    }

    final List<Map<String, dynamic>> maps = await db.query(
      taskTableName,
      orderBy: orderBy,
    );

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  /// Get incomplete tasks (not completed)
  Future<List<Task>> getIncompleteTasks() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      taskTableName,
      where: 'status != ?',
      whereArgs: [TaskStatus.completed.toInt()],
    );

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  /// Search tasks by brief with optional sorting
  Future<List<Task>> searchTasks(String query, {SortBy? sortBy}) async {
    final db = await _dbHelper.database;
    String? orderBy;

    if (sortBy != null) {
      switch (sortBy) {
        case SortBy.createTime:
          orderBy = 'create_time DESC';
          break;
        case SortBy.deadline:
          orderBy = 'deadline ASC';
          break;
        case SortBy.priority:
          // Sort by priority first, then put tasks without deadline at the bottom
          orderBy = 'priority ASC, CASE WHEN deadline IS NULL THEN 1 ELSE 0 END ASC, deadline ASC';
          break;
      }
    }

    final List<Map<String, dynamic>> maps = await db.query(
      taskTableName,
      where: 'brief LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: orderBy,
    );

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  /// Check if there are any incomplete tasks
  Future<bool> hasIncompleteTasks() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      taskTableName,
      where: 'status != ?',
      whereArgs: [TaskStatus.completed.toInt()],
      limit: 1,
    );

    return result.isNotEmpty;
  }
}

