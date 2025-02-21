import 'package:flutter/material.dart';
import 'package:zryptii/models/search_filter.dart';
import 'package:zryptii/widgets/search_filter_dialog.dart';

class FileSearchBar extends StatelessWidget {
  final String searchQuery;
  final SearchFilter filter;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<SearchFilter> onFilterChanged;

  const FileSearchBar({
    super.key,
    required this.searchQuery,
    required this.filter,
    required this.onChanged,
    required this.onClear,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: searchQuery)
                    ..selection = TextSelection.fromPosition(
                      TextPosition(offset: searchQuery.length),
                    ),
                  decoration: InputDecoration(
                    hintText: 'Search files...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: onClear,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: _hasActiveFilters() ? Colors.blue : null,
                ),
                onPressed: () => _showFilterDialog(context),
              ),
            ],
          ),
        ),
        if (_hasActiveFilters()) ...[
          const SizedBox(height: 8),
          _buildActiveFilters(context),
        ],
      ],
    );
  }

  bool _hasActiveFilters() {
    return filter.fileTypes.isNotEmpty ||
        filter.dateFilter != DateFilter.all ||
        filter.sizeFilter != SizeFilter.all;
  }

  Widget _buildActiveFilters(BuildContext context) {
    final chips = <Widget>[];

    // Add date filter chip
    if (filter.dateFilter != DateFilter.all) {
      chips.add(Chip(
        label: Text(filter.getDateFilterLabel()),
        onDeleted: () => onFilterChanged(
          filter.copyWith(dateFilter: DateFilter.all),
        ),
      ));
    }

    // Add size filter chip
    if (filter.sizeFilter != SizeFilter.all) {
      chips.add(Chip(
        label: Text(filter.getSizeFilterLabel()),
        onDeleted: () => onFilterChanged(
          filter.copyWith(sizeFilter: SizeFilter.all),
        ),
      ));
    }

    // Add file type chips
    for (final type in filter.fileTypes) {
      chips.add(Chip(
        label: Text(type.toUpperCase()),
        onDeleted: () {
          final types = List<String>.from(filter.fileTypes)..remove(type);
          onFilterChanged(filter.copyWith(fileTypes: types));
        },
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          ...chips.map((chip) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: chip,
              )),
          if (chips.length > 1)
            TextButton(
              onPressed: () => onFilterChanged(SearchFilter()),
              child: const Text('Clear All'),
            ),
        ],
      ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => SearchFilterDialog(
        currentFilter: filter,
        onFilterChanged: onFilterChanged,
      ),
    );
  }
}
