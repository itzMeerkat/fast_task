// Widget representing a single day segment in the Gantt chart

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget for displaying a single day bar in the Gantt chart timeline
class GanttDayBar extends StatelessWidget {
  final double width;
  final double hours;
  final double maxHeightHours;
  final double rowHeight;
  final double minPauseLineHeight;
  final Color color;
  final bool isPaused;

  const GanttDayBar({
    super.key,
    required this.width,
    required this.hours,
    required this.maxHeightHours,
    required this.rowHeight,
    required this.minPauseLineHeight,
    required this.color,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    final double barHeight;
    
    if (isPaused) {
      barHeight = minPauseLineHeight;
    } else {
      barHeight = (hours / maxHeightHours) * rowHeight;
    }
    
    final clampedHeight = math.max(minPauseLineHeight, math.min(barHeight, rowHeight));
    
    return Container(
      width: width,
      height: rowHeight,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: width,
        height: clampedHeight,
        decoration: BoxDecoration(
          color: color,
        ),
      ),
    );
  }
}

