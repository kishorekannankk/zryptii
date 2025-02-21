import 'dart:io';
import 'dart:typed_data';

class FileLoadingService {
  static const int _chunkSize = 1024 * 1024; // 1MB chunks
  static const int _largeFileThreshold = 10 * 1024 * 1024; // 10MB

  static bool isLargeFile(String filePath) {
    final file = File(filePath);
    return file.lengthSync() > _largeFileThreshold;
  }

  static Stream<double> loadFileWithProgress(String filePath) async* {
    final file = File(filePath);
    final fileSize = await file.length();
    int bytesRead = 0;

    final stream = file.openRead();
    await for (List<int> chunk in stream) {
      bytesRead += chunk.length;
      yield bytesRead / fileSize;
    }
  }

  static Future<Uint8List> loadFileInChunks(
    String filePath,
    void Function(double progress)? onProgress,
  ) async {
    final file = File(filePath);
    final fileSize = await file.length();
    final chunks = <List<int>>[];
    int bytesRead = 0;

    final stream = file.openRead();
    await for (List<int> chunk in stream) {
      chunks.add(chunk);
      bytesRead += chunk.length;
      onProgress?.call(bytesRead / fileSize);
    }

    final result = BytesBuilder();
    for (var chunk in chunks) {
      result.add(chunk);
    }

    return result.takeBytes();
  }
}
