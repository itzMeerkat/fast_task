// Enums and their extensions for the Task Tracker app

/// Priority levels for tasks, descending in importance
enum Priority {
  p00,
  p0,
  p1,
  p2,
  p3,
  p4,
}

extension PriorityExtension on Priority {
  /// Convert priority to integer for database storage
  int toInt() {
    return index;
  }

  /// Convert integer from database to Priority enum
  static Priority fromInt(int value) {
    return Priority.values[value];
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case Priority.p00:
        return 'P00';
      case Priority.p0:
        return 'P0';
      case Priority.p1:
        return 'P1';
      case Priority.p2:
        return 'P2';
      case Priority.p3:
        return 'P3';
      case Priority.p4:
        return 'P4';
    }
  }
}

/// Status of a task
enum TaskStatus {
  notStarted,
  inProgress,
  completed,
}

extension TaskStatusExtension on TaskStatus {
  /// Convert status to integer for database storage
  int toInt() {
    return index;
  }

  /// Convert integer from database to TaskStatus enum
  static TaskStatus fromInt(int value) {
    return TaskStatus.values[value];
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case TaskStatus.notStarted:
        return 'Not Started';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
    }
  }
}

/// Sorting options for task lists
enum SortBy {
  createTime,
  deadline,
  priority,
}

extension SortByExtension on SortBy {
  /// Convert to integer for storage
  int toInt() {
    return index;
  }

  /// Convert integer to SortBy enum
  static SortBy fromInt(int value) {
    return SortBy.values[value];
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case SortBy.createTime:
        return 'Create Time';
      case SortBy.deadline:
        return 'Deadline';
      case SortBy.priority:
        return 'Priority';
    }
  }
}

/// Hour options for progress recording
enum HoursOption {
  notAtAll,
  lessThan2,
  from2To4,
  from4To8,
}

extension HoursOptionExtension on HoursOption {
  /// Convert to negative integer for database storage
  double toDouble() {
    switch (this) {
      case HoursOption.notAtAll:
        return 0.0;
      case HoursOption.lessThan2:
        return 1.0;
      case HoursOption.from2To4:
        return 3.0;
      case HoursOption.from4To8:
        return 6.0;
    }
  }

  /// Convert negative value from database to HoursOption enum
  static HoursOption? fromDouble(double value) {
    if (value == -1.0) return HoursOption.notAtAll;
    if (value == -2.0) return HoursOption.lessThan2;
    if (value == -3.0) return HoursOption.from2To4;
    if (value == -4.0) return HoursOption.from4To8;
    return null;
  }

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case HoursOption.notAtAll:
        return 'Not at all';
      case HoursOption.lessThan2:
        return 'Less than 2 hours';
      case HoursOption.from2To4:
        return '2 to 4 hours';
      case HoursOption.from4To8:
        return '4-8 hours';
    }
  }
}

