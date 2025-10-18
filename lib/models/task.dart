// Task model representing a task in the task tracker

import 'enums.dart';

/// Represents a task with all its properties
class Task {
  final int? id;
  final String brief;
  final DateTime? deadline;
  final DateTime createTime;
  final DateTime updateTime;
  final Priority priority;
  final TaskStatus status;

  Task({
    this.id,
    required this.brief,
    this.deadline,
    DateTime? createTime,
    DateTime? updateTime,
    this.priority = Priority.p2,
    this.status = TaskStatus.notStarted,
  })  : createTime = createTime ?? DateTime.now(),
        updateTime = updateTime ?? DateTime.now();

  /// Create Task from database map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      brief: map['brief'] as String,
      deadline: map['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deadline'] as int)
          : null,
      createTime: DateTime.fromMillisecondsSinceEpoch(map['create_time'] as int),
      updateTime: DateTime.fromMillisecondsSinceEpoch(map['update_time'] as int),
      priority: PriorityExtension.fromInt(map['priority'] as int),
      status: TaskStatusExtension.fromInt(map['status'] as int),
    );
  }

  /// Convert Task to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'brief': brief,
      'deadline': deadline?.millisecondsSinceEpoch,
      'create_time': createTime.millisecondsSinceEpoch,
      'update_time': updateTime.millisecondsSinceEpoch,
      'priority': priority.toInt(),
      'status': status.toInt(),
    };
  }

  /// Create a copy of Task with modified fields
  Task copyWith({
    int? id,
    String? brief,
    DateTime? deadline,
    DateTime? createTime,
    DateTime? updateTime,
    Priority? priority,
    TaskStatus? status,
  }) {
    return Task(
      id: id ?? this.id,
      brief: brief ?? this.brief,
      deadline: deadline ?? this.deadline,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
      priority: priority ?? this.priority,
      status: status ?? this.status,
    );
  }
}

