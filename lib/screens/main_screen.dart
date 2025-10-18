// Main screen with bottom navigation

import 'package:flutter/material.dart';
import 'homepage.dart';
import 'task_management_page.dart';
import 'gantt_chart_page.dart';
import 'settings_page.dart';

/// Main screen with bottom navigation bar
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Handle tab tap
  void _onTabTapped(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        children: const [
          Homepage(),
          TaskManagementPage(),
          GanttChartPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          return BottomNavigationBar(
            currentIndex: _tabController.index,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.task),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Gantt',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          );
        },
      ),
    );
  }
}

