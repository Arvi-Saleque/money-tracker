import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../transactions/transaction_providers.dart';
import 'export_service.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(
    transactionService: ref.watch(transactionServiceProvider),
  );
});
