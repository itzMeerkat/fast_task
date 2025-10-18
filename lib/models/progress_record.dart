// Progress record model for tracking daily work on tasks

import 'enums.dart';

/// Represents a progress record for a task on a specific date
class ProgressRecord {
  final int? id;
  final int taskId;
  final DateTime date;
  final double hoursSpent;

  ProgressRecord({
    this.id,
    required this.taskId,
    required this.date,
    required this.hoursSpent,
  });

  /// Create ProgressRecord from database map
  factory ProgressRecord.fromMap(Map<String, dynamic> map) {
    return ProgressRecord(
      id: map['id'] as int?,
      taskId: map['task_id'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      hoursSpent: map['hours_spent'] as double,
    );
  }

  /// Convert ProgressRecord to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'task_id': taskId,
      'date': date.millisecondsSinceEpoch,
      'hours_spent': hoursSpent,
    };
  }

  /// Check if this record uses an enum value (negative)
  bool get isEnumValue => hoursSpent < 0;

  /// Get display text for this progress record
  String get displayText {
    if (isEnumValue) {
      final option = HoursOptionExtension.fromDouble(hoursSpent);
      return option?.displayName ?? 'Unknown';
    } else {
      return '${hoursSpent.toStringAsFixed(1)} hours';
    }
  }
}

