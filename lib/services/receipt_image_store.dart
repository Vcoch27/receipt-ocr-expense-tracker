import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ReceiptImageStore {
  Future<String> persist(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw const FileSystemException('Receipt image unavailable');
    }
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(documents.path, 'receipts'));
    await directory.create(recursive: true);
    final suffix = p.extension(sourcePath).toLowerCase();
    final extension = ['.jpg', '.jpeg', '.png', '.heic'].contains(suffix)
        ? suffix
        : '.jpg';
    final name = 'receipt_${DateTime.now().microsecondsSinceEpoch}$extension';
    return (await source.copy(p.join(directory.path, name))).path;
  }

  Future<void> remove(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
