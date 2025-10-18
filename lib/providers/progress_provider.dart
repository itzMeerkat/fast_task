// Provider for managing progress record state

import 'package:flutter/foundation.dart';
import '../repositories/progress_repository.dart';
import '../models/progress_record.dart';

/// Provider for managing progress record state and operations
class ProgressProvider extends ChangeNotifier {
  final ProgressRepository _repository;
  List<ProgressRecord> _records = [];

  ProgressProvider() : _repository = ProgressRepository();

  /// Get copy of progress records list
  List<ProgressRecord> get records => List.unmodifiable(_records);

  /// Add a new progress record
  Future<void> addProgress(ProgressRecord record) async {
    await _repository.insertProgress(record);
    notifyListeners();
  }

  /// Load all progress records
  Future<void> loadAllProgress() async {
    _records = await _repository.getAllProgress();
    notifyListeners();
  }

  /// Get progress records for a specific task
  Future<List<ProgressRecord>> getProgressForTask(int taskId) async {
    return await _repository.getProgressByTaskId(taskId);
  }
}

