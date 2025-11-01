// Gantt chart page for visualizing task progress

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fast_task/models/task.dart';
import '../widgets/honest_gantt_chart/honest_gantt_chart.dart';
import '../widgets/honest_gantt_chart/task_progress_data.dart';
import '../providers/task_provider.dart';
import '../repositories/progress_repository.dart';
import '../models/gantt_sort_option.dart';

/// Page displaying Gantt chart visualization of tasks
class GanttChartPage extends StatefulWidget {
  const GanttChartPage({super.key});

  @override
  State<GanttChartPage> createState() => _GanttChartPageState();
}

class _GanttChartPageState extends State<GanttChartPage> {
  final ProgressRepository _progressRepository = ProgressRepository();
  Future<List<TaskProgressData>>? _dataFuture;
  GanttSortOption _currentSortOption = GanttSortOption.recentProgress;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when dependencies change (e.g., when navigating back)
    _loadData();
  }

  /// Trigger data loading
  void _loadData() {
    final tasks = context.read<TaskProvider>().tasks;
    if (tasks.isNotEmpty) {
      setState(() {
        _dataFuture = _loadTaskProgressData(tasks);
      });
    }
  }

  /// Load task progress data from real data sources
  Future<List<TaskProgressData>> _loadTaskProgressData(List<Task> tasks) async {
    final List<TaskProgressData> taskProgressDataList = [];

    for (final task in tasks) {
      // Fetch progress records for this task
      final progressRecords = await _progressRepository.getProgressByTaskId(task.id!);
      
      taskProgressDataList.add(
        TaskProgressData(
          task: task,
          progressRecords: progressRecords,
        ),
      );
    }
    return taskProgressDataList;
  }

  /// Sort task progress data based on selected sort option
  List<TaskProgressData> _sortTaskProgressData(
    List<TaskProgressData> data,
    GanttSortOption sortOption,
  ) {
    final sortedData = List<TaskProgressData>.from(data);
    
    switch (sortOption) {
      case GanttSortOption.nameAscending:
        sortedData.sort((a, b) => 
          a.task.brief.toLowerCase().compareTo(b.task.brief.toLowerCase())
        );
        break;
      case GanttSortOption.nameDescending:
        sortedData.sort((a, b) => 
          b.task.brief.toLowerCase().compareTo(a.task.brief.toLowerCase())
        );
        break;
      case GanttSortOption.recentProgress:
        sortedData.sort((a, b) {
          final aDate = a.lastProgressDate;
          final bDate = b.lastProgressDate;
          
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          
          return bDate.compareTo(aDate);
        });
        break;
    }
    
    return sortedData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Honest Gantt Chart'),
        centerTitle: false,
        // backgroundColor: Theme.of(context).colorScheme.primary,
        // foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          DropdownButton<GanttSortOption>(
            value: _currentSortOption,
            // dropdownColor: Theme.of(context).colorScheme.primary,
            icon: Icon(
              Icons.arrow_drop_down,
              // color: Theme.of(context).colorScheme.onPrimary,
            ),
            underline: Container(),
            items: GanttSortOption.values.map((GanttSortOption option) {
              return DropdownMenuItem<GanttSortOption>(
                value: option,
                child: Text(
                  option.displayName,
                  style: TextStyle(
                    // color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: (GanttSortOption? newValue) {
              if (newValue != null) {
                setState(() {
                  _currentSortOption = newValue;
                });
              }
            },
          ),
          // const SizedBox(width: 8),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Use all tasks (not just pending ones) for Gantt chart
          final tasks = taskProvider.tasks;

          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                'No tasks available.\nCreate some tasks to see them here!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return FutureBuilder<List<TaskProgressData>>(
            key: ValueKey(tasks.length), // Rebuild when tasks count changes
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading data: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final taskProgressData = snapshot.data ?? [];
              final sortedTaskProgressData = _sortTaskProgressData(
                taskProgressData,
                _currentSortOption,
              );

              return  Padding(
                padding: const EdgeInsets.all(16.0),
                child: HonestGanttChart(
                  taskProgressData: sortedTaskProgressData,
                  maxHeightHours: 10.0,
                  labelWidth: 200.0,
                  rowHeight: 70.0,
                  dayWidth: 60.0,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

