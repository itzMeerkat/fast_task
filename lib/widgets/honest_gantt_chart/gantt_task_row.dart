// Widget representing one task row with label and timeline in the Gantt chart

import 'package:flutter/material.dart';
import 'task_progress_data.dart';
import 'gantt_day_bar.dart';
import '../../models/enums.dart';

/// Widget for displaying a single task row including label and day bars
class GanttTaskRow extends StatelessWidget {
  final TaskProgressData taskData;
  final DateTime startDate;
  final DateTime endDate;
  final double dayWidth;
  final double labelWidth;
  final double rowHeight;
  final double maxHeightHours;
  final double minPauseLineHeight;
  final Map<HoursOption, double> enumMapping;
  final ScrollController scrollController;
  final Color Function(Priority) getColorForPriority;

  const GanttTaskRow({
    super.key,
    required this.taskData,
    required this.startDate,
    required this.endDate,
    required this.dayWidth,
    required this.labelWidth,
    required this.rowHeight,
    required this.maxHeightHours,
    required this.minPauseLineHeight,
    required this.enumMapping,
    required this.scrollController,
    required this.getColorForPriority,
  });

  /// Build list of day bar widgets for each day in the date range
  List<Widget> _buildDayBars() {
    final List<Widget> dayBars = [];
    final numberOfDays = endDate.difference(startDate).inDays + 1;
    final color = getColorForPriority(taskData.task.priority);

    for (int i = 0; i < numberOfDays; i++) {
      final currentDay = startDate.add(Duration(days: i));
      final hours = taskData.getHoursForDate(currentDay, enumMapping);
      final isPaused = taskData.isPausedDay(currentDay, enumMapping);

      dayBars.add(
        GanttDayBar(
          width: dayWidth,
          hours: hours,
          maxHeightHours: maxHeightHours,
          rowHeight: rowHeight,
          minPauseLineHeight: minPauseLineHeight,
          color: color,
          isPaused: isPaused,
        ),
      );
    }

    return dayBars;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rowHeight,
      child: Row(children: [Row(children: _buildDayBars())]),
    );
  }
}
