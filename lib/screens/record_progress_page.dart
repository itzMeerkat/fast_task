// Record progress page for logging daily work on tasks

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/progress_card.dart';
import 'completion_screen.dart';

/// Page for recording progress on tasks one by one
class RecordProgressPage extends StatefulWidget {
  const RecordProgressPage({super.key});

  @override
  State<RecordProgressPage> createState() => _RecordProgressPageState();
}

class _RecordProgressPageState extends State<RecordProgressPage> {
  int _currentIndex = 0;
  List<Task> _tasksToReview = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  /// Load tasks that need review
  void _loadTasks() {
    // Use already loaded tasks from provider instead of reloading
    final tasks = context.read<TaskProvider>().getInProgressTasks();
    setState(() {
      _tasksToReview = tasks;
      _isLoading = false;
    });

    // If no tasks to review, navigate to completion screen immediately
    if (_tasksToReview.isEmpty) {
      _navigateToCompletion();
    }
  }

  /// Handle moving to next task
  void _onNext() {
    setState(() {
      _currentIndex++;
    });

    // Check if we've reviewed all tasks
    if (_currentIndex >= _tasksToReview.length) {
      _navigateToCompletion();
    }
  }

  /// Navigate to completion screen
  void _navigateToCompletion() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => CompletionScreen(tasksReviewed: _tasksToReview.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_tasksToReview.isEmpty || _currentIndex >= _tasksToReview.length) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Progress ${_currentIndex + 1} of ${_tasksToReview.length}'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ProgressCard(
            task: _tasksToReview[_currentIndex],
            onNext: _onNext,
          ),
        ),
      ),
    );
  }
}

