import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<String?> saveExportBytes({
  required Uint8List bytes,
  required String fileName,
}) async {
  final downloads = await getDownloadsDirectory();
  final baseDirectory =
      downloads ??
      (Platform.isAndroid || Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : await getTemporaryDirectory());
  final exportDirectory = Directory(
    '${baseDirectory.path}${Platform.pathSeparator}exports',
  );
  if (!exportDirectory.existsSync()) {
    exportDirectory.createSync(recursive: true);
  }

  final file = File(
    '${exportDirectory.path}${Platform.pathSeparator}$fileName',
  );
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
