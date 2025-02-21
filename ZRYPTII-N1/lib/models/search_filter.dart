import 'package:intl/intl.dart';
import 'package:zryptii/services/recent_files_service.dart';

enum DateFilter {
  all,
  today,
  lastWeek,
  lastMonth,
  custom,
}

enum SizeFilter {
  all,
  lessThan1MB,
  lessThan10MB,
  lessThan100MB,
  moreThan100MB,
  custom,
}

class SearchFilter {
  final String query;
  final List<String> fileTypes;
  final DateFilter dateFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final SizeFilter sizeFilter;
  final int? customMinSize;
  final int? customMaxSize;

  SearchFilter({
    this.query = '',
    this.fileTypes = const [],
    this.dateFilter = DateFilter.all,
    this.customStartDate,
    this.customEndDate,
    this.sizeFilter = SizeFilter.all,
    this.customMinSize,
    this.customMaxSize,
  });

  SearchFilter copyWith({
    String? query,
    List<String>? fileTypes,
    DateFilter? dateFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
    SizeFilter? sizeFilter,
    int? customMinSize,
    int? customMaxSize,
  }) {
    return SearchFilter(
      query: query ?? this.query,
      fileTypes: fileTypes ?? this.fileTypes,
      dateFilter: dateFilter ?? this.dateFilter,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      sizeFilter: sizeFilter ?? this.sizeFilter,
      customMinSize: customMinSize ?? this.customMinSize,
      customMaxSize: customMaxSize ?? this.customMaxSize,
    );
  }

  bool matches(RecentFile file) {
    if (query.isNotEmpty) {
      final searchQuery = query.toLowerCase();
      if (!file.name.toLowerCase().contains(searchQuery) &&
          !file.fileType.toLowerCase().contains(searchQuery)) {
        return false;
      }
    }

    if (fileTypes.isNotEmpty &&
        !fileTypes.contains(file.fileType.toLowerCase())) {
      return false;
    }

    if (!_matchesDateFilter(file.lastOpened)) {
      return false;
    }

    if (!_matchesSizeFilter(file.fileSize)) {
      return false;
    }

    return true;
  }

  bool _matchesDateFilter(DateTime date) {
    final now = DateTime.now();
    switch (dateFilter) {
      case DateFilter.all:
        return true;
      case DateFilter.today:
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case DateFilter.lastWeek:
        final weekAgo = now.subtract(const Duration(days: 7));
        return date.isAfter(weekAgo);
      case DateFilter.lastMonth:
        final monthAgo = DateTime(now.year, now.month - 1, now.day);
        return date.isAfter(monthAgo);
      case DateFilter.custom:
        if (customStartDate != null && date.isBefore(customStartDate!)) {
          return false;
        }
        if (customEndDate != null && date.isAfter(customEndDate!)) {
          return false;
        }
        return true;
    }
  }

  bool _matchesSizeFilter(int size) {
    switch (sizeFilter) {
      case SizeFilter.all:
        return true;
      case SizeFilter.lessThan1MB:
        return size < 1024 * 1024;
      case SizeFilter.lessThan10MB:
        return size < 10 * 1024 * 1024;
      case SizeFilter.lessThan100MB:
        return size < 100 * 1024 * 1024;
      case SizeFilter.moreThan100MB:
        return size >= 100 * 1024 * 1024;
      case SizeFilter.custom:
        if (customMinSize != null && size < customMinSize!) {
          return false;
        }
        if (customMaxSize != null && size > customMaxSize!) {
          return false;
        }
        return true;
    }
  }

  String getDateFilterLabel() {
    switch (dateFilter) {
      case DateFilter.all:
        return 'All Time';
      case DateFilter.today:
        return 'Today';
      case DateFilter.lastWeek:
        return 'Last 7 Days';
      case DateFilter.lastMonth:
        return 'Last 30 Days';
      case DateFilter.custom:
        if (customStartDate != null && customEndDate != null) {
          final formatter = DateFormat('MMM d, y');
          return '${formatter.format(customStartDate!)} - ${formatter.format(customEndDate!)}';
        }
        return 'Custom Range';
    }
  }

  String getSizeFilterLabel() {
    switch (sizeFilter) {
      case SizeFilter.all:
        return 'Any Size';
      case SizeFilter.lessThan1MB:
        return '< 1 MB';
      case SizeFilter.lessThan10MB:
        return '< 10 MB';
      case SizeFilter.lessThan100MB:
        return '< 100 MB';
      case SizeFilter.moreThan100MB:
        return '> 100 MB';
      case SizeFilter.custom:
        if (customMinSize != null && customMaxSize != null) {
          return '${(customMinSize! / (1024 * 1024)).toStringAsFixed(1)} MB - ${(customMaxSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
        }
        return 'Custom Range';
    }
  }
}
