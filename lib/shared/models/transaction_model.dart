import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionSplitItem {
  const TransactionSplitItem({required this.categoryId, required this.amount});

  final String categoryId;
  final double amount;

  factory TransactionSplitItem.fromMap(Map<String, dynamic> data) {
    return TransactionSplitItem(
      categoryId: data['categoryId'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'categoryId': categoryId, 'amount': amount};
  }

  TransactionSplitItem copyWith({String? categoryId, double? amount}) {
    return TransactionSplitItem(
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
    );
  }
}

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.walletId,
    required this.isTransfer,
    required this.note,
    required this.date,
    required this.createdAt,
    this.transferWalletId,
    this.linkedTransactionId,
    this.splitItems = const <TransactionSplitItem>[],
    this.categoryIds = const <String>[],
  });

  final String id;
  final double amount;
  final String type;
  final String categoryId;
  final String walletId;
  final bool isTransfer;
  final String note;
  final DateTime date;
  final DateTime createdAt;
  final String? transferWalletId;
  final String? linkedTransactionId;
  final List<TransactionSplitItem> splitItems;
  final List<String> categoryIds;

  bool get isSplit => !isTransfer && normalizedSplitItems.length > 1;

  List<TransactionSplitItem> get normalizedSplitItems {
    if (isTransfer) {
      return const <TransactionSplitItem>[];
    }
    if (splitItems.isNotEmpty) {
      return splitItems
          .where((item) => item.categoryId.trim().isNotEmpty && item.amount > 0)
          .toList(growable: false);
    }
    if (categoryId.trim().isEmpty || amount <= 0) {
      return const <TransactionSplitItem>[];
    }
    return <TransactionSplitItem>[
      TransactionSplitItem(categoryId: categoryId, amount: amount),
    ];
  }

  List<String> get normalizedCategoryIds {
    final fromSplits = normalizedSplitItems
        .map((item) => item.categoryId)
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (fromSplits.isNotEmpty) {
      return fromSplits;
    }
    if (categoryIds.isNotEmpty) {
      return categoryIds
          .where((id) => id.trim().isNotEmpty)
          .toSet()
          .toList(growable: false);
    }
    if (categoryId.trim().isEmpty) {
      return const <String>[];
    }
    return <String>[categoryId];
  }

  factory TransactionModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final dateValue = data['date'];
    final createdAtValue = data['createdAt'];
    final rawSplitItems = data['splitItems'] as List<dynamic>? ?? const [];
    final parsedSplitItems = rawSplitItems
        .whereType<Map<String, dynamic>>()
        .map(TransactionSplitItem.fromMap)
        .where((item) => item.categoryId.trim().isNotEmpty && item.amount > 0)
        .toList(growable: false);
    final categoryId = data['categoryId'] as String? ?? '';

    final rawCategoryIds = (data['categoryIds'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toList(growable: false);

    return TransactionModel(
      id: doc.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      type: data['type'] as String? ?? 'expense',
      categoryId: categoryId,
      walletId: data['walletId'] as String? ?? '',
      isTransfer: data['isTransfer'] as bool? ?? false,
      note: data['note'] as String? ?? '',
      date: dateValue is Timestamp ? dateValue.toDate() : DateTime.now(),
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
      transferWalletId: data['transferWalletId'] as String?,
      linkedTransactionId: data['linkedTransactionId'] as String?,
      splitItems: parsedSplitItems,
      categoryIds: rawCategoryIds,
    );
  }

  Map<String, dynamic> toMap() {
    final normalizedItems = normalizedSplitItems;
    final primaryCategoryId = normalizedItems.isNotEmpty
        ? normalizedItems.first.categoryId
        : categoryId;

    return <String, dynamic>{
      'amount': amount,
      'type': type,
      'categoryId': primaryCategoryId,
      'walletId': walletId,
      'isTransfer': isTransfer,
      'note': note,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'transferWalletId': transferWalletId,
      'linkedTransactionId': linkedTransactionId,
      'splitItems': normalizedItems.map((item) => item.toMap()).toList(),
      'categoryIds': normalizedCategoryIds,
    };
  }

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? type,
    String? categoryId,
    String? walletId,
    bool? isTransfer,
    String? note,
    DateTime? date,
    DateTime? createdAt,
    String? transferWalletId,
    bool clearTransferWalletId = false,
    String? linkedTransactionId,
    bool clearLinkedTransactionId = false,
    List<TransactionSplitItem>? splitItems,
    List<String>? categoryIds,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      isTransfer: isTransfer ?? this.isTransfer,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      transferWalletId: clearTransferWalletId
          ? null
          : transferWalletId ?? this.transferWalletId,
      linkedTransactionId: clearLinkedTransactionId
          ? null
          : linkedTransactionId ?? this.linkedTransactionId,
      splitItems: splitItems ?? this.splitItems,
      categoryIds: categoryIds ?? this.categoryIds,
    );
  }
}
