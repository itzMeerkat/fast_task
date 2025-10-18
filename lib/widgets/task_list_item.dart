// Widget for displaying a task in a list

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/enums.dart';

/// Widget that displays a single task item in a list with enhanced visual design
class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showActions;

  const TaskListItem({
    super.key,
    required this.task,
    this.onTap,
    this.onDelete,
    this.showActions = false,
  });

  /// Get color based on priority
  Color _getPriorityColor() {
    switch (task.priority) {
      case Priority.p00:
        return Colors.red.shade900;
      case Priority.p0:
        return Colors.red.shade600;
      case Priority.p1:
        return Colors.orange.shade700;
      case Priority.p2:
        return Colors.blue.shade600;
      case Priority.p3:
        return Colors.grey.shade600;
      case Priority.p4:
        return Colors.grey.shade400;
    }
  }

  /// Check if task is overdue
  bool _isOverdue() {
    if (task.deadline == null) return false;
    return task.deadline!.isBefore(DateTime.now()) &&
        task.status != TaskStatus.completed;
  }

  @override
  Widget build(BuildContext context) {
    final startDate = task.createTime;
    final endDate = task.deadline;
    final duration = endDate?.difference(startDate).inDays;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with priority indicator, title, and status
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.brief,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 8,
                  //     vertical: 4,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: task.status == TaskStatus.completed
                  //         ? Colors.green.shade100
                  //         : Colors.blue.shade100,
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Text(
                  //     task.status.displayName,
                  //     style: TextStyle(
                  //       fontSize: 12,
                  //       color: task.status == TaskStatus.completed
                  //           ? Colors.green.shade900
                  //           : Colors.blue.shade900,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 8),
              // Date range - only show if deadline exists
              if (endDate != null)
                Text(
                  '${DateFormat('MMM dd, yyyy').format(startDate)} → ${DateFormat('MMM dd, yyyy').format(endDate)}',
                  style: TextStyle(
                    color: _isOverdue() ? Colors.red.shade700 : Colors.grey.shade700,
                    fontSize: 14,
                    fontWeight: _isOverdue() ? FontWeight.bold : null,
                  ),
                )
              else
                Text(
                  'Created: ${DateFormat('MMM dd, yyyy').format(startDate)}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 8),
              // Duration and priority row
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (duration != null)
                          Text(
                            'Duration: $duration days',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          )
                        else
                          Text(
                            'No deadline',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Text(
                          'Priority: ${task.priority.displayName}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action buttons for Tasks tab
                  if (showActions) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onTap,
                      tooltip: 'Edit',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: onDelete,
                      tooltip: 'Delete',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
              // Progress bar - only show if deadline exists
              if (endDate != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: task.status == TaskStatus.completed
                        ? 1.0
                        : task.status == TaskStatus.inProgress
                            ? 0.5
                            : 0.0,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getPriorityColor(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

