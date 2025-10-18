// Main entry point for the Task Tracker app

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';
import 'providers/progress_provider.dart';
// import 'services/notification_service.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  // await NotificationService.instance.initialize();
  
  runApp(const MyApp());
}

/// Root application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: MaterialApp(
        title: 'Task Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AppInitializer(),
      ),
    );
  }
}

/// Widget that handles initial app setup and data loading
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /// Initialize app data and schedule notifications if needed
  Future<void> _initialize() async {
    final settingsProvider = context.read<SettingsProvider>();
    final taskProvider = context.read<TaskProvider>();

    // Load settings
    await settingsProvider.loadPreferences();

    // Load tasks
    await taskProvider.loadTasks(sortBy: settingsProvider.currentSort);

    // Check if there are incomplete tasks and schedule notification
    // final hasIncompleteTasks = await taskProvider.hasIncompleteTasks();
    // if (hasIncompleteTasks) {
    //   await NotificationService.instance.scheduleProgressReminder();
    // }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return const MainScreen();
  }
}
