import 'dart:typed_data';

import 'export_storage_stub.dart'
    if (dart.library.io) 'export_storage_io.dart'
    as impl;

Future<String?> saveExportBytes({
  required Uint8List bytes,
  required String fileName,
}) {
  return impl.saveExportBytes(bytes: bytes, fileName: fileName);
}
