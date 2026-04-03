import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/debt_record_model.dart';
import '../../shared/providers/firebase_providers.dart';
import '../transactions/transaction_providers.dart';
import 'debt_service.dart';

final debtServiceProvider = Provider<DebtService>((ref) {
  return DebtService(firestore: ref.watch(firestoreProvider));
});

final debtsProvider = StreamProvider<List<DebtRecordModel>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) {
    return Stream<List<DebtRecordModel>>.value(const <DebtRecordModel>[]);
  }
  return ref.watch(debtServiceProvider).watchDebts(uid);
});

final borrowedDebtsProvider = Provider<List<DebtRecordModel>>((ref) {
  final debts =
      ref.watch(debtsProvider).asData?.value ?? const <DebtRecordModel>[];
  final items = debts.where((debt) => debt.isBorrowed).toList(growable: false);
  items.sort(_sortDebts);
  return items;
});

final lentDebtsProvider = Provider<List<DebtRecordModel>>((ref) {
  final debts =
      ref.watch(debtsProvider).asData?.value ?? const <DebtRecordModel>[];
  final items = debts.where((debt) => debt.isLent).toList(growable: false);
  items.sort(_sortDebts);
  return items;
});

final debtOverviewProvider = Provider<DebtOverview>((ref) {
  final debts =
      ref.watch(debtsProvider).asData?.value ?? const <DebtRecordModel>[];
  var borrowedOutstanding = 0.0;
  var lentOutstanding = 0.0;
  var borrowedActive = 0;
  var lentActive = 0;
  var overdueCount = 0;
  var dueSoonCount = 0;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dueSoonLimit = today.add(const Duration(days: 7));

  for (final debt in debts) {
    if (debt.isBorrowed) {
      borrowedOutstanding += debt.remainingAmount;
    } else if (debt.isLent) {
      lentOutstanding += debt.remainingAmount;
    }

    if (!debt.isSettled) {
      if (debt.isBorrowed) {
        borrowedActive += 1;
      } else if (debt.isLent) {
        lentActive += 1;
      }

      if (debt.isOverdue) {
        overdueCount += 1;
      } else {
        final dueDate = DateTime(
          debt.dueDate.year,
          debt.dueDate.month,
          debt.dueDate.day,
        );
        if (!dueDate.isBefore(today) && !dueDate.isAfter(dueSoonLimit)) {
          dueSoonCount += 1;
        }
      }
    }
  }

  return DebtOverview(
    borrowedOutstanding: borrowedOutstanding,
    lentOutstanding: lentOutstanding,
    borrowedActive: borrowedActive,
    lentActive: lentActive,
    overdueCount: overdueCount,
    dueSoonCount: dueSoonCount,
  );
});

final debtActionControllerProvider =
    AsyncNotifierProvider<DebtActionController, void>(DebtActionController.new);

class DebtActionController extends AsyncNotifier<void> {
  DebtService get _service => ref.read(debtServiceProvider);

  @override
  Future<void> build() async {}

  Future<DebtRecordModel> saveDebt(DebtRecordModel debt) async {
    final uid = _requireUserId();
    DebtRecordModel? result;
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      result = await _service.saveDebt(uid, debt);
    });
    if (state.hasError) {
      throw state.error!;
    }
    return result!;
  }

  Future<void> deleteDebt(String debtId) async {
    final uid = _requireUserId();
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() => _service.deleteDebt(uid, debtId));
    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<DebtRecordModel> addPayment({
    required String debtId,
    required double amount,
    required DateTime date,
    required String note,
  }) async {
    final uid = _requireUserId();
    DebtRecordModel? result;
    state = const AsyncLoading<void>();
    state = await AsyncValue.guard(() async {
      result = await _service.addPayment(
        uid,
        debtId: debtId,
        amount: amount,
        date: date,
        note: note,
      );
    });
    if (state.hasError) {
      throw state.error!;
    }
    return result!;
  }

  String _requireUserId() {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) {
      throw StateError('User is not signed in.');
    }
    return uid;
  }
}

class DebtOverview {
  const DebtOverview({
    required this.borrowedOutstanding,
    required this.lentOutstanding,
    required this.borrowedActive,
    required this.lentActive,
    required this.overdueCount,
    required this.dueSoonCount,
  });

  final double borrowedOutstanding;
  final double lentOutstanding;
  final int borrowedActive;
  final int lentActive;
  final int overdueCount;
  final int dueSoonCount;
}

int _sortDebts(DebtRecordModel a, DebtRecordModel b) {
  if (a.isSettled != b.isSettled) {
    return a.isSettled ? 1 : -1;
  }
  if (a.isOverdue != b.isOverdue) {
    return a.isOverdue ? -1 : 1;
  }
  final dueCompare = a.dueDate.compareTo(b.dueDate);
  if (dueCompare != 0) {
    return dueCompare;
  }
  return b.updatedAt.compareTo(a.updatedAt);
}
