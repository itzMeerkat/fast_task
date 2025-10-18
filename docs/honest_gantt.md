# Honest Gantt Chart Widget Requirements

## Overview
A custom Gantt chart widget that visualizes task progress with emphasis on daily time spent. Unlike traditional Gantt charts that show continuous time ranges, this widget displays multiple work sessions per task and uses bar height to represent hours spent each day.

## Key Differences from Traditional Gantt Chart
- **Multiple ranges per task**: Records "pauses" in task work (days with no activity)
- **Height-based visualization**: Bar height represents hours spent per day, not just presence/absence
- **Honest tracking**: Thin lines show days where tasks are active but no work was done

## Widget Specifications

### Location
- Path: `/lib/widgets/honest_gantt_chart/`
- Type: StatefulWidget or StatelessWidget (as needed for scroll controllers)
- Rendering: Basic Flutter widgets only (Container, Row, Column, Stack, etc.)
- **No direct database coupling** - receives data from parent

### Data Input
- **New data class required**: Encapsulate task + associated progress records
- Widget receives structured data from parent component
- Parent handles provider integration and data fetching

### Visual Layout

#### Overall Structure
- Traditional Gantt layout: horizontal timeline, one task per row
- **Horizontal scroll**: Navigate through timeline dates
- **Vertical scroll**: Navigate through task list (when many tasks)
- Responsive: Timeline width adapts to widget width

#### Task Row Components
1. **Task Label** (left side, fixed position)
   - Task brief text
   - Color indicator based on priority

2. **Timeline Bar** (scrollable area)
   - Each day is a visual segment
   - Height varies based on hours spent that day
   - Continuous/smooth appearance for height transitions
   - Priority-based colors (same as existing app)

#### Day Segment Heights
- **Active work days**: Height = (hoursSpent / maxHeightHours) × fullBarHeight
- **Paused days** (no record OR hoursSpent = -1): Thin line (2-3px) in task color
- **No progress records at all**: Show label only, no bar/line

### Configuration Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `taskProgressData` | `List<TaskProgressData>` | Required | List of tasks with their progress records |
| `maxHeightHours` | `double` | `8.0` | Maximum hours for full bar height scaling |
| `dateRangeStart` | `DateTime` | 2 weeks ago | Timeline start date |
| `dateRangeEnd` | `DateTime` | Today | Timeline end date |
| `enumToHoursMapping` | `Map<HoursOption, double>` | See below | Mapping from enum values to hour representations |
| `filterOption` | `FilterOption` | `all` | Show all tasks or only in-progress |
| `sortOption` | `SortBy` | Inherited | How to sort tasks (createTime/deadline/priority) |
| `rowHeight` | `double` | `60.0` | Height of each task row |
| `minPauseLineHeight` | `double` | `2.0` | Height of thin line for paused days |

#### Default Enum to Hours Mapping
```dart
{
  HoursOption.notAtAll: 0.0,        // Treated as paused day
  HoursOption.lessThan2: 1.0,       // Midpoint
  HoursOption.from2To4: 3.0,        // Midpoint
  HoursOption.from4To8: 6.0,        // Midpoint
}
```

### Color Scheme
Follow existing priority-based colors:
- P00: `Colors.red.shade900`
- P0: `Colors.red.shade600`
- P1: `Colors.orange.shade700`
- P2: `Colors.blue.shade600`
- P3: `Colors.grey.shade600`
- P4: `Colors.grey.shade400`

### Sizing & Constraints

#### Responsive Width
- Timeline width = widget width (determined by parent)
- Day width = timeline width / number of days in range
- Dynamically calculated, responsive to zoom/date range changes

#### Date Range Constraints
- **Maximum range**: 6 months
- **Minimum range**: 1 day
- Default: Past 2 weeks from today

### Zoom Functionality
- Zoom = changing dateRangeStart and dateRangeEnd parameters
- Controlled externally (parent component responsibility)
- Widget responds to parameter changes
- Does NOT affect granularity (always shows individual days)

### Filtering & Sorting

#### Filter Options
1. **All tasks**: Show all tasks regardless of status
2. **In-progress only**: Show only tasks with status = IN_PROGRESS

#### Sort Options
Use existing `SortBy` enum:
1. By create time
2. By deadline
3. By priority

### Interaction Requirements
- **No bar interaction**: Bars are not clickable/hoverable
- **Scrollable**: Both horizontal (timeline) and vertical (task list)
- **Read-only visualization**: Display purposes only

### Edge Cases

#### Tasks Without Progress Records
- Display task label and color indicator
- Do NOT display any bars or lines in timeline
- Still occupies a row in the layout

#### Tasks With Sparse Progress
- Show bars only for days with actual progress records (hoursSpent > 0 or enum != notAtAll)
- Show thin lines for paused days (within task's active range)
- Active range = from first progress record to last progress record

#### Very Long Date Ranges
- Maximum 6 months enforced
- Parent should handle validation
- Widget should handle gracefully if exceeded (truncate or show error)

#### Many Tasks (100+)
- Vertical scroll handles this naturally
- Consider virtual scrolling if performance issues arise
- Initial implementation: standard ListView

### Performance Considerations
- Avoid rebuilding entire widget on small data changes
- Use `const` constructors where possible
- Efficient day-by-day rendering (avoid nested loops where possible)
- Consider lazy loading for very long task lists

## Data Model Design

### TaskProgressData Class
New class to encapsulate task and its progress records:

```dart
class TaskProgressData {
  final Task task;
  final List<ProgressRecord> progressRecords;
  
  // Computed properties
  DateTime? get firstProgressDate;
  DateTime? get lastProgressDate;
  bool get hasProgress;
  double getHoursForDate(DateTime date, Map<HoursOption, double> enumMapping);
}
```

## Implementation Notes

### File Structure
```
lib/widgets/honest_gantt_chart/
├── honest_gantt_chart.dart          # Main widget
├── task_progress_data.dart          # Data model
├── gantt_timeline.dart              # Timeline header (dates)
├── gantt_task_row.dart              # Individual task row
└── gantt_day_bar.dart               # Day segment with varying height
```

### Widget Hierarchy
```
HonestGanttChart (main widget)
├── Column
│   ├── GanttTimeline (date headers, fixed/sticky)
│   └── ListView (vertical scroll for tasks)
│       └── GanttTaskRow (for each task)
│           ├── Task Label (fixed width)
│           └── SingleChildScrollView (horizontal scroll)
│               └── Row (days)
│                   └── GanttDayBar (for each day)
```

### Smooth Height Transitions
- Use `AnimatedContainer` for smooth height changes (optional, if not too complex)
- OR simple `Container` with calculated heights (simpler approach)
- Prefer simpler approach to avoid over-engineering

## Integration Example

The parent page (e.g., `gantt_chart_page.dart`) will:
1. Fetch tasks from `TaskProvider`
2. Fetch progress records from `ProgressProvider`
3. Combine into `List<TaskProgressData>`
4. Pass to `HonestGanttChart` widget with configuration parameters
5. Handle zoom controls and filter/sort UI
6. Update parameters to trigger widget rebuild

## Future Enhancements (Out of Scope)
- Click on day bar to see details
- Drag to adjust hours
- Add new progress record from chart
- Export chart as image
- Multiple task selection
- Task dependencies visualization

