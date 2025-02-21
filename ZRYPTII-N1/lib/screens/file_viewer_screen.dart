import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:zryptii/services/file_operation_service.dart';
import 'package:zryptii/utils/file_utils.dart';
import 'package:zryptii/widgets/viewers/document_viewer.dart';
import 'package:zryptii/widgets/viewers/image_viewer.dart';
import 'package:zryptii/widgets/viewers/text_viewer.dart';
import 'package:zryptii/widgets/file_info_dialog.dart';
import 'package:zryptii/services/file_loading_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class FileViewerScreen extends StatefulWidget {
  final String filePath;

  const FileViewerScreen({
    super.key,
    required this.filePath,
  });

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  bool _isLoading = true;
  String? _error;
  double _loadingProgress = 0.0;
  bool _isLargeFile = false;

  @override
  void initState() {
    super.initState();
    _initializeViewer();
  }

  Future<void> _initializeViewer() async {
    try {
      _isLargeFile = FileLoadingService.isLargeFile(widget.filePath);
      if (_isLargeFile) {
        setState(() {
          _loadingProgress = 0.0;
        });
      }

      final isReadOnly =
          await FileOperationService.isFileReadOnly(widget.filePath);
      if (!isReadOnly) {
        await FileOperationService.preventFileModification(widget.filePath);
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Could not secure file access. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(path.basename(widget.filePath)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLargeFile) ...[
                Text(
                  'Loading large file...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    value: _loadingProgress,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_loadingProgress * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ] else
                const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(path.basename(widget.filePath)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(path.basename(widget.filePath)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareFile(),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showFileInfo(context),
          ),
        ],
      ),
      body: _buildViewer(),
    );
  }

  Widget _buildViewer() {
    final extension = path.extension(widget.filePath).toLowerCase();

    switch (FileUtils.getFileType(extension)) {
      case FileType.image:
        return ImageViewer(
          filePath: widget.filePath,
          isLargeFile: _isLargeFile,
          onProgress: _updateProgress,
        );
      case FileType.document:
        return DocumentViewer(
          filePath: widget.filePath,
          isLargeFile: _isLargeFile,
          onProgress: _updateProgress,
        );
      case FileType.text:
        return TextViewer(
          filePath: widget.filePath,
          isLargeFile: _isLargeFile,
          onProgress: _updateProgress,
        );
      default:
        return const Center(
          child: Text('Unsupported file format'),
        );
    }
  }

  void _showFileInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FileInfoDialog(filePath: widget.filePath),
    );
  }

  void _updateProgress(double progress) {
    setState(() {
      _loadingProgress = progress;
    });
  }

  Future<void> _shareFile() async {
    try {
      final file = File(widget.filePath);
      if (!await file.exists()) {
        throw 'File not found';
      }

      await Share.shareXFiles(
        [XFile(widget.filePath)],
        subject: 'Sharing ${path.basename(widget.filePath)}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not share file: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
