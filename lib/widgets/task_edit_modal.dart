// Modal widget for editing an existing task

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/enums.dart';
import '../providers/task_provider.dart';

/// Modal dialog for editing an existing task
class TaskEditModal extends StatefulWidget {
  final Task task;

  const TaskEditModal({super.key, required this.task});

  @override
  State<TaskEditModal> createState() => _TaskEditModalState();
}

class _TaskEditModalState extends State<TaskEditModal> {
  late TextEditingController _briefController;
  late DateTime? _selectedDeadline;
  late Priority _selectedPriority;

  @override
  void initState() {
    super.initState();
    _briefController = TextEditingController(text: widget.task.brief);
    _selectedDeadline = widget.task.deadline;
    _selectedPriority = widget.task.priority;
  }

  @override
  void dispose() {
    _briefController.dispose();
    super.dispose();
  }

  /// Show date picker for deadline selection
  Future<void> _selectDeadline() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDeadline = pickedDate;
      });
    }
  }

  /// Clear the deadline
  void _clearDeadline() {
    setState(() {
      _selectedDeadline = null;
    });
  }

  /// Update the task
  Future<void> _updateTask() async {
    if (_briefController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task description')),
      );
      return;
    }

    final updatedTask = widget.task.copyWith(
      brief: _briefController.text.trim(),
      deadline: _selectedDeadline,
      priority: _selectedPriority,
    );

    await context.read<TaskProvider>().updateTask(updatedTask);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return AlertDialog(
      title: const Text('Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _briefController,
              decoration: const InputDecoration(
                labelText: 'Task Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDeadline == null
                        ? 'No deadline'
                        : 'Due: ${dateFormat.format(_selectedDeadline!)}',
                  ),
                ),
                if (_selectedDeadline != null)
                  IconButton(
                    onPressed: _clearDeadline,
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear deadline',
                  ),
                TextButton.icon(
                  onPressed: _selectDeadline,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Select'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Priority>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: Priority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPriority = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateTask,
          child: const Text('Update'),
        ),
      ],
    );
  }
}

