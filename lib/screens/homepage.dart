// Homepage screen showing pending tasks

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/settings_provider.dart';
import '../models/enums.dart';
import '../models/task.dart';
import '../widgets/task_list_item.dart';
import 'record_progress_page.dart';

/// Homepage displaying pending tasks with options to add and record progress
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _briefController = TextEditingController();
  DateTime? _selectedDeadline;
  Priority _selectedPriority = Priority.p2;

  @override
  void dispose() {
    _briefController.dispose();
    super.dispose();
  }

  /// Show date picker for deadline selection
  Future<void> _selectDeadline() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDeadline = pickedDate;
      });
    }
  }

  /// Save the new task
  Future<void> _saveTask() async {
    if (_briefController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task description')),
      );
      return;
    }

    final task = Task(
      brief: _briefController.text.trim(),
      deadline: _selectedDeadline,
      priority: _selectedPriority,
    );

    await context.read<TaskProvider>().addTask(task);

    // Clear the form after adding
    setState(() {
      _briefController.clear();
      _selectedDeadline = null;
      _selectedPriority = Priority.p2;
    });
  }

  /// Navigate to record progress page
  void _navigateToRecordProgress() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecordProgressPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Tracker'),
        actions: [
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return PopupMenuButton<SortBy>(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort by',
                onSelected: (sortBy) async {
                  await settingsProvider.setSortBy(sortBy);
                  if (mounted) {
                    await context.read<TaskProvider>().loadTasks(sortBy: sortBy);
                  }
                },
                itemBuilder: (context) => SortBy.values.map((sortBy) {
                  return PopupMenuItem(
                    value: sortBy,
                    child: Row(
                      children: [
                        if (settingsProvider.currentSort == sortBy)
                          const Icon(Icons.check, size: 20),
                        if (settingsProvider.currentSort == sortBy)
                          const SizedBox(width: 8),
                        Text(sortBy.displayName),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _navigateToRecordProgress,
              icon: const Icon(Icons.edit_calendar),
              label: const Text('Record Today\'s Work'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                if (taskProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter to show only pending tasks (not completed)
                final pendingTasks = taskProvider.tasks
                    .where((task) => task.status != TaskStatus.completed)
                    .toList();

                if (pendingTasks.isEmpty) {
                  return const Center(
                    child: Text(
                      'No pending tasks!\nAdd a task below to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: pendingTasks.length,
                  itemBuilder: (context, index) {
                    final task = pendingTasks[index];
                    return TaskListItem(task: task);
                  },
                );
              },
            ),
          ),
          // Add Task Card - fixed at bottom
          Card(
            margin: EdgeInsets.all(10),
            elevation: 8,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))
                // topLeft: Radius.circular(16),
                // topRight: Radius.circular(16),
              // ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add New Task',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _briefController,
                    decoration: const InputDecoration(
                      labelText: 'Task Description',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _saveTask(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectDeadline,
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            _selectedDeadline == null
                                ? 'Set Deadline'
                                : DateFormat('MMM dd, yyyy').format(_selectedDeadline!),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      if (_selectedDeadline != null)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedDeadline = null;
                            });
                          },
                          icon: const Icon(Icons.clear, size: 20),
                          tooltip: 'Clear deadline',
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<Priority>(
                          initialValue: _selectedPriority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            border: OutlineInputBorder(),
                            isDense: true,
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _saveTask,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Task'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

