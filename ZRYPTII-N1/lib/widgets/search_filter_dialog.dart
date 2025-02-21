import 'package:flutter/material.dart';
import 'package:zryptii/models/search_filter.dart';

class SearchFilterDialog extends StatefulWidget {
  final SearchFilter currentFilter;
  final ValueChanged<SearchFilter> onFilterChanged;

  const SearchFilterDialog({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<SearchFilterDialog> createState() => _SearchFilterDialogState();
}

class _SearchFilterDialogState extends State<SearchFilterDialog> {
  late SearchFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search Filters'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateFilter(),
            const Divider(),
            _buildSizeFilter(),
            const Divider(),
            _buildFileTypeFilter(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onFilterChanged(_filter);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: DateFilter.values.map((filter) {
            return ChoiceChip(
              label: Text(filter == DateFilter.custom
                  ? _filter.getDateFilterLabel()
                  : _getDateFilterLabel(filter)),
              selected: _filter.dateFilter == filter,
              onSelected: (selected) {
                if (selected) {
                  if (filter == DateFilter.custom) {
                    _showDateRangePicker();
                  } else {
                    setState(() {
                      _filter = _filter.copyWith(dateFilter: filter);
                    });
                  }
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSizeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Size', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: SizeFilter.values.map((filter) {
            return ChoiceChip(
              label: Text(filter == SizeFilter.custom
                  ? _filter.getSizeFilterLabel()
                  : _getSizeFilterLabel(filter)),
              selected: _filter.sizeFilter == filter,
              onSelected: (selected) {
                if (selected) {
                  if (filter == SizeFilter.custom) {
                    _showSizeRangePicker();
                  } else {
                    setState(() {
                      _filter = _filter.copyWith(sizeFilter: filter);
                    });
                  }
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFileTypeFilter() {
    final availableTypes = ['pdf', 'docx', 'txt', 'jpg', 'png'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('File Types', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: availableTypes.map((type) {
            return FilterChip(
              label: Text(type.toUpperCase()),
              selected: _filter.fileTypes.contains(type),
              onSelected: (selected) {
                setState(() {
                  final types = List<String>.from(_filter.fileTypes);
                  if (selected) {
                    types.add(type);
                  } else {
                    types.remove(type);
                  }
                  _filter = _filter.copyWith(fileTypes: types);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _showDateRangePicker() async {
    final initialDateRange = DateTimeRange(
      start: _filter.customStartDate ?? DateTime.now(),
      end: _filter.customEndDate ?? DateTime.now(),
    );

    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedRange != null) {
      setState(() {
        _filter = _filter.copyWith(
          dateFilter: DateFilter.custom,
          customStartDate: pickedRange.start,
          customEndDate: pickedRange.end,
        );
      });
    }
  }

  Future<void> _showSizeRangePicker() async {
    // Show a custom dialog for size range input
    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) => _SizeRangeDialog(
        initialMin: _filter.customMinSize,
        initialMax: _filter.customMaxSize,
      ),
    );

    if (result != null) {
      setState(() {
        _filter = _filter.copyWith(
          sizeFilter: SizeFilter.custom,
          customMinSize: result['min'],
          customMaxSize: result['max'],
        );
      });
    }
  }

  String _getDateFilterLabel(DateFilter filter) {
    switch (filter) {
      case DateFilter.all:
        return 'All Time';
      case DateFilter.today:
        return 'Today';
      case DateFilter.lastWeek:
        return 'Last 7 Days';
      case DateFilter.lastMonth:
        return 'Last 30 Days';
      case DateFilter.custom:
        return 'Custom';
    }
  }

  String _getSizeFilterLabel(SizeFilter filter) {
    switch (filter) {
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
        return 'Custom';
    }
  }
}

class _SizeRangeDialog extends StatefulWidget {
  final int? initialMin;
  final int? initialMax;

  const _SizeRangeDialog({
    this.initialMin,
    this.initialMax,
  });

  @override
  State<_SizeRangeDialog> createState() => _SizeRangeDialogState();
}

class _SizeRangeDialogState extends State<_SizeRangeDialog> {
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: widget.initialMin != null
          ? (widget.initialMin! / (1024 * 1024)).toString()
          : '',
    );
    _maxController = TextEditingController(
      text: widget.initialMax != null
          ? (widget.initialMax! / (1024 * 1024)).toString()
          : '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom Size Range'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _minController,
            decoration: const InputDecoration(
              labelText: 'Minimum Size (MB)',
              suffixText: 'MB',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _maxController,
            decoration: const InputDecoration(
              labelText: 'Maximum Size (MB)',
              suffixText: 'MB',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final min = double.tryParse(_minController.text);
            final max = double.tryParse(_maxController.text);

            if (min != null && max != null && min <= max) {
              Navigator.pop(context, {
                'min': (min * 1024 * 1024).toInt(),
                'max': (max * 1024 * 1024).toInt(),
              });
            }
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }
}
