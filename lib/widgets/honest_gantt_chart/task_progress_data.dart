// Data model encapsulating a task and its associated progress records for Gantt chart visualization

import '../../models/task.dart';
import '../../models/progress_record.dart';
import '../../models/enums.dart';

/// Encapsulates a task with its progress records for Gantt chart display
class TaskProgressData {
  final Task task;
  final List<ProgressRecord> progressRecords;

  TaskProgressData({
    required this.task,
    required this.progressRecords,
  });

  /// Returns true if there are any progress records for this task
  bool get hasProgress => progressRecords.isNotEmpty;

  /// Returns the date of the earliest progress record, or null if no records exist
  DateTime? get firstProgressDate {
    if (progressRecords.isEmpty) return null;
    return progressRecords
        .map((record) => record.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  /// Returns the date of the latest progress record, or null if no records exist
  DateTime? get lastProgressDate {
    if (progressRecords.isEmpty) return null;
    return progressRecords
        .map((record) => record.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// Get hours spent on a specific date, converting enum values to hours using the provided mapping
  double getHoursForDate(DateTime date, Map<HoursOption, double> enumMapping) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    for (final record in progressRecords) {
      final recordDate = DateTime(record.date.year, record.date.month, record.date.day);
      if (recordDate.isAtSameMomentAs(normalizedDate)) {
        if (record.hoursSpent < 0) {
          final hoursOption = HoursOptionExtension.fromDouble(record.hoursSpent);
          if (hoursOption != null) {
            return enumMapping[hoursOption] ?? 0.0;
          }
        } else {
          return record.hoursSpent;
        }
      }
    }
    
    return 0.0;
  }

  /// Determine if a specific date is a paused day (within active range but no work done)
  bool isPausedDay(DateTime date, Map<HoursOption, double> enumMapping) {
    if (!hasProgress) return false;
    
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final firstDate = firstProgressDate;
    final lastDate = lastProgressDate;
    
    if (firstDate == null || lastDate == null) return false;
    
    final normalizedFirstDate = DateTime(firstDate.year, firstDate.month, firstDate.day);
    final normalizedLastDate = DateTime(lastDate.year, lastDate.month, lastDate.day);
    
    if (normalizedDate.isBefore(normalizedFirstDate) || normalizedDate.isAfter(normalizedLastDate)) {
      return false;
    }
    
    final hours = getHoursForDate(date, enumMapping);
    return hours == 0.0;
  }
}

