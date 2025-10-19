// Enum for Gantt chart sort options

/// Defines the available sort options for the Gantt chart
enum GanttSortOption {
  nameAscending,
  nameDescending,
  recentProgress,
}

/// Extension providing display names for Gantt sort options
extension GanttSortOptionExtension on GanttSortOption {
  /// Returns the display name for each sort option
  String get displayName {
    switch (this) {
      case GanttSortOption.nameAscending:
        return 'Sort by: Name (A-Z)';
      case GanttSortOption.nameDescending:
        return 'Sort by: Name (Z-A)';
      case GanttSortOption.recentProgress:
        return 'Sort by: Recent Progress';
    }
  }

  /// Convert enum to integer value
  int toInt() {
    return index;
  }

  /// Convert integer to enum value
  static GanttSortOption fromInt(int value) {
    return GanttSortOption.values[value];
  }
}

