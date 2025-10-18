// Provider for managing task state

import 'package:flutter/foundation.dart';
import '../repositories/task_repository.dart';
import '../models/task.dart';
import '../models/enums.dart';

/// Provider for managing task state and operations
class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository;
  List<Task> _tasks = [];
  bool _isLoading = false;
  SortBy? _currentSort;

  TaskProvider() : _repository = TaskRepository();

  /// Get copy of tasks list
  List<Task> get tasks => List.unmodifiable(_tasks);

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get current sort preference
  SortBy? get currentSort => _currentSort;

  /// Load all tasks with optional sorting
  Future<void> loadTasks({SortBy? sortBy}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Remember the sort preference for future reloads
      if (sortBy != null) {
        _currentSort = sortBy;
      }
      _tasks = await _repository.getAllTasks(sortBy: sortBy ?? _currentSort);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new task
  Future<void> addTask(Task task) async {
    await _repository.insertTask(task);
    // Reload with current sort preference
    await loadTasks(sortBy: _currentSort);
  }

  /// Update an existing task
  Future<void> updateTask(Task task) async {
    final updatedTask = task.copyWith(updateTime: DateTime.now());
    await _repository.updateTask(updatedTask);
    // Reload with current sort preference
    await loadTasks(sortBy: _currentSort);
  }

  /// Delete a task
  Future<void> deleteTask(int id) async {
    await _repository.deleteTask(id);
    // Reload with current sort preference
    await loadTasks(sortBy: _currentSort);
  }

  /// Search tasks by brief
  Future<void> searchTasks(String query, {SortBy? sortBy}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Remember the sort preference
      if (sortBy != null) {
        _currentSort = sortBy;
      }
      final effectiveSort = sortBy ?? _currentSort;
      
      if (query.isEmpty) {
        _tasks = await _repository.getAllTasks(sortBy: effectiveSort);
      } else {
        _tasks = await _repository.searchTasks(query, sortBy: effectiveSort);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark a task as completed
  Future<void> markTaskComplete(int id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    final completedTask = task.copyWith(
      status: TaskStatus.completed,
      updateTime: DateTime.now(),
    );
    await _repository.updateTask(completedTask);
    // Reload with current sort preference
    await loadTasks(sortBy: _currentSort);
  }

  /// Check if there are incomplete tasks
  Future<bool> hasIncompleteTasks() async {
    return await _repository.hasIncompleteTasks();
  }

  /// Get list of in-progress and not-started tasks
  List<Task> getInProgressTasks() {
    return _tasks
        .where((task) =>
            task.status == TaskStatus.inProgress ||
            task.status == TaskStatus.notStarted)
        .toList();
  }
}

