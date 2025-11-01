// Main Gantt chart widget that orchestrates the entire visualization

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'task_progress_data.dart';
import '../../models/enums.dart';

/// Custom scroll behavior that enables mouse drag scrolling on desktop
class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}

/// Custom Gantt chart widget that visualizes task progress with daily hour tracking
class HonestGanttChart extends StatefulWidget {
  final List<TaskProgressData> taskProgressData;
  final double maxHeightHours;
  final DateTime? dateRangeStart;
  final DateTime? dateRangeEnd;
  final Map<HoursOption, double>? enumToHoursMapping;
  final double labelWidth;
  final double rowHeight;
  final double minPauseLineHeight;
  final double dateHeaderHeight;
  final double dayWidth;

  const HonestGanttChart({
    super.key,
    required this.taskProgressData,
    this.maxHeightHours = 8.0,
    this.dateRangeStart,
    this.dateRangeEnd,
    this.enumToHoursMapping,
    this.labelWidth = 150.0,
    this.rowHeight = 60.0,
    this.minPauseLineHeight = 2.0,
    this.dateHeaderHeight = 40.0,
    this.dayWidth = 50.0,
  });

  @override
  State<HonestGanttChart> createState() => _HonestGanttChartState();
}

class _HonestGanttChartState extends State<HonestGanttChart> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ScrollOffsetController _scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();

    // Jump to "today" (index 2000) after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _itemScrollController.jumpTo(index: 2000);
    });

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (widget.dateRangeStart != null) {
      _startDate = DateTime(
        widget.dateRangeStart!.year,
        widget.dateRangeStart!.month,
        widget.dateRangeStart!.day,
      );
    } else {
      _startDate = today.subtract(const Duration(days: 7));
    }

    if (widget.dateRangeEnd != null) {
      _endDate = DateTime(
        widget.dateRangeEnd!.year,
        widget.dateRangeEnd!.month,
        widget.dateRangeEnd!.day,
      );
    } else {
      _endDate = today;
    }

    if (_endDate.isBefore(_startDate)) {
      _endDate = _startDate;
    }

    final maxDuration = const Duration(days: 180);
    if (_endDate.difference(_startDate) > maxDuration) {
      _endDate = _startDate.add(maxDuration);
    }
  }

  @override
  void dispose() {
    // ItemScrollController doesn't need disposal
    super.dispose();
  }

  /// Map priority enum to color
  Color _getColorForPriority(Priority priority) {
    switch (priority) {
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

  Widget _buildTaskLabelList() {
    final List<Widget> taskLabels = [SizedBox(height: widget.rowHeight-15)];
    for (var task in widget.taskProgressData) {
      taskLabels.add(
        Container(
          height: widget.rowHeight,
          width: widget.labelWidth,
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
          decoration: BoxDecoration(
            border: task != widget.taskProgressData.last
                          ? Border(
                              bottom: BorderSide(
                                color: Colors.grey,
                                width:0.4,
                              ),
                            )
                          : null,
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getColorForPriority(task.task.priority),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.task.brief,
                  style: const TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(8, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(children: taskLabels),
    );
  }

  /// Build scrollable list of task rows with desktop mouse wheel support
  Widget _buildTaskList(double dayWidth) {
    return Expanded(
      child: Listener(
        onPointerSignal: (pointerSignal) {
          if (pointerSignal is PointerScrollEvent) {
            // Convert vertical scroll to horizontal scroll
            final scrollDelta = pointerSignal.scrollDelta.dy;

            // Get current scroll offset
            if (_itemPositionsListener.itemPositions.value.isNotEmpty) {
              final positions = _itemPositionsListener.itemPositions.value;
              final firstItem = positions.first;

              // Calculate new scroll position (adjust sensitivity as needed)
              final pixelsToScroll = scrollDelta;
              final itemsToScroll = (pixelsToScroll / dayWidth).round();

              if (itemsToScroll != 0) {
                final newIndex = (firstItem.index + itemsToScroll).clamp(
                  0,
                  3999,
                );
                _itemScrollController.jumpTo(index: newIndex);
              }
            }
          }
        },
        child: ScrollConfiguration(
          behavior: CustomScrollBehavior(),
          child: ScrollablePositionedList.builder(
            scrollDirection: Axis.horizontal,
            itemScrollController: _itemScrollController,
            scrollOffsetController: _scrollOffsetController,
            itemPositionsListener: _itemPositionsListener,
            // Use a large but finite item count (e.g., 4000 = ~5.5 years of history each direction)
            itemCount: 4000,
            itemBuilder: (context, i) {
              // print("building item $i");
              // Index 2000 is "today", so i-2000 gives days offset from today
              var cDatetime = DateTime.now().add(Duration(days: i - 2000));
              DateTime dateOnly = DateTime(
                cDatetime.year,
                cDatetime.month,
                cDatetime.day,
              );

              final List<Widget> cols = [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  child: SizedBox(
                    height: widget.rowHeight-15,
                    width: dayWidth,
                    child: Column(
                      children: [
                        Spacer(),
                        Text(
                          textAlign: TextAlign.center,
                          DateFormat.MMMd().format(dateOnly),
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          DateFormat.E().format(dateOnly),
                          style: const TextStyle(fontSize: 12),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ];
              for (var task in widget.taskProgressData) {
                var height = getCellHeight(task, dateOnly);
                cols.add(
                  Container(
                    decoration: BoxDecoration(
                      border: task != widget.taskProgressData.last
                          ? Border(
                              bottom: BorderSide(
                                color: Colors.grey,
                                width: 0.2,
                              ),
                            )
                          : null,
                    ),
                    child: SizedBox(
                      height: widget.rowHeight,
                      width: dayWidth,
                      child: height > 0
                          ? Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                height:
                                    height *
                                    widget
                                        .rowHeight, // Convert fraction to pixels
                                decoration: BoxDecoration(
                                  // borderRadius: const BorderRadius.all(
                                  //   Radius.circular(3),
                                  // ),
                                  color: _getColorForPriority(
                                    task.task.priority,
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              }
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                  color: dateOnly.weekday >5 ? Colors.grey.shade200:null
                ),
                child: Column(children: cols),
              );
            },
          ),
        ),
      ),
    );
  }

  // TODO: Optimization could be done here
  double getCellHeight(TaskProgressData task, DateTime date) {
    for (var d in task.progressRecords) {
      if (d.date == date) {
        return d.hoursSpent / widget.maxHeightHours;
      }
    }
    if (task.progressRecords.isEmpty) {
      return 0;
    }
    if ((task.progressRecords.first.date.isBefore(date) &&
            task.progressRecords.last.date.isAfter(date)) ||
        (task.task.status == TaskStatus.inProgress &&
            task.progressRecords.last.date.isBefore(date) &&
            DateTime.now().isAfter(date))) {
      return 0.02;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.taskProgressData.isEmpty) {
      return const Center(
        child: Text('No tasks to display', style: TextStyle(fontSize: 16)),
      );
    }

    // Calculate total height needed for all tasks
    final totalContentHeight =
        (1 + widget.taskProgressData.length) * (widget.rowHeight + 1);

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: SizedBox(
          height: totalContentHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildDateHeader(widget.dayWidth),
              _buildTaskLabelList(),
              _buildTaskList(widget.dayWidth),
            ],
          ),
        ),
      ),
    );
  }
}
