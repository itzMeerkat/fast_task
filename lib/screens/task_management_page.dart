// Task management page for editing and deleting tasks

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/settings_provider.dart';
import '../models/task.dart';
import '../models/enums.dart';
import '../widgets/task_list_item.dart';
import '../widgets/task_edit_modal.dart';

/// Page for managing all tasks with search and edit capabilities
class TaskManagementPage extends StatefulWidget {
  const TaskManagementPage({super.key});

  @override
  State<TaskManagementPage> createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Handle search query changes
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    final settingsProvider = context.read<SettingsProvider>();
    context.read<TaskProvider>().searchTasks(
          query,
          sortBy: settingsProvider.currentSort,
        );
  }

  /// Show edit modal for a task
  void _showEditModal(Task task) {
    showDialog(
      context: context,
      builder: (context) => TaskEditModal(task: task),
    );
  }

  /// Delete a task with confirmation
  Future<void> _deleteTask(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<TaskProvider>().deleteTask(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (taskProvider.tasks.isEmpty) {
            return Center(
              child: Text(
                _searchQuery.isEmpty
                    ? 'No tasks yet.\nGo to Home to add tasks.'
                    : 'No tasks found.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          // Sort completed tasks to bottom
          final sortedTasks = List<Task>.from(taskProvider.tasks);
          sortedTasks.sort((a, b) {
            if (a.status == TaskStatus.completed &&
                b.status != TaskStatus.completed) {
              return 1;
            } else if (a.status != TaskStatus.completed &&
                b.status == TaskStatus.completed) {
              return -1;
            }
            return 0;
          });

          return ListView.builder(
            itemCount: sortedTasks.length,
            itemBuilder: (context, index) {
              final task = sortedTasks[index];
              return TaskListItem(
                task: task,
                onTap: () => _showEditModal(task),
                onDelete: () => _deleteTask(task.id!),
                showActions: true,
              );
            },
          );
        },
      ),
    );
  }
}

