import 'package:flutter/material.dart';
import 'package:zryptii/services/recent_files_service.dart';
import 'package:zryptii/screens/file_viewer_screen.dart';
import 'package:intl/intl.dart';
import 'package:zryptii/widgets/search_bar.dart';
import 'package:zryptii/models/search_filter.dart';

class RecentFilesList extends StatefulWidget {
  const RecentFilesList({super.key});

  @override
  State<RecentFilesList> createState() => _RecentFilesListState();
}

class _RecentFilesListState extends State<RecentFilesList> {
  SortOption _currentSort = SortOption.dateDesc;
  SearchFilter _filter = SearchFilter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FileSearchBar(
          searchQuery: _filter.query,
          filter: _filter,
          onChanged: (query) => setState(() {
            _filter = _filter.copyWith(query: query);
          }),
          onClear: () => setState(() {
            _filter = _filter.copyWith(query: '');
          }),
          onFilterChanged: (filter) => setState(() {
            _filter = filter;
          }),
        ),
        const SizedBox(height: 16),
        _buildSortBar(),
        const SizedBox(height: 8),
        _buildList(),
      ],
    );
  }

  Widget _buildSortBar() {
    return Row(
      children: [
        const Text('Sort by:'),
        const SizedBox(width: 8),
        DropdownButton<SortOption>(
          value: _currentSort,
          items: SortOption.values.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(_getSortLabel(option)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _currentSort = value);
            }
          },
        ),
      ],
    );
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
        return 'Name (A-Z)';
      case SortOption.nameDesc:
        return 'Name (Z-A)';
      case SortOption.dateAsc:
        return 'Date (Oldest)';
      case SortOption.dateDesc:
        return 'Date (Newest)';
      case SortOption.sizeAsc:
        return 'Size (Smallest)';
      case SortOption.sizeDesc:
        return 'Size (Largest)';
      case SortOption.typeAsc:
        return 'Type (A-Z)';
      case SortOption.typeDesc:
        return 'Type (Z-A)';
    }
  }

  Widget _buildList() {
    return FutureBuilder<List<RecentFile>>(
      future: RecentFilesService.getRecentFiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No recent files'),
          );
        }

        var filteredFiles = snapshot.data!.where(_filter.matches).toList();

        if (filteredFiles.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No files match the current filters',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        final sortedFiles = RecentFilesService.sortFiles(
          filteredFiles,
          _currentSort,
        );

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedFiles.length,
          itemBuilder: (context, index) {
            final file = sortedFiles[index];
            return ListTile(
              leading: _getFileIcon(file.fileType),
              title: Text.rich(
                TextSpan(
                  children: _highlightSearchQuery(
                    file.name,
                    _filter.query,
                  ),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${DateFormat('MMM d, y HH:mm').format(file.lastOpened)} • ${file.formattedSize}',
              ),
              trailing: Text(
                file.fileType.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FileViewerScreen(filePath: file.path),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<TextSpan> _highlightSearchQuery(String text, String query) {
    if (query.isEmpty) return [TextSpan(text: text)];

    final matches = query.toLowerCase();
    final textLower = text.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;

    while (true) {
      final index = textLower.indexOf(matches, start);
      if (index == -1) {
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start)));
        }
        break;
      }

      if (start < index) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + matches.length),
          style: const TextStyle(
            backgroundColor: Colors.yellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = index + matches.length;
    }

    return spans;
  }

  Widget _getFileIcon(String fileType) {
    IconData iconData;
    switch (fileType.toLowerCase()) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        break;
      case 'docx':
      case 'txt':
        iconData = Icons.description;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        iconData = Icons.image;
        break;
      default:
        iconData = Icons.insert_drive_file;
    }
    return Icon(iconData);
  }
}
