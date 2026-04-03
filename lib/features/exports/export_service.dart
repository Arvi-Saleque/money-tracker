import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/locale_formatters.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/transaction_model.dart';
import '../../shared/models/wallet_model.dart';
import '../transactions/finance_catalog.dart';
import '../transactions/transaction_service.dart';
import 'export_storage.dart';

class ExportFilters {
  const ExportFilters({
    this.type,
    this.categoryId,
    this.walletId,
    this.startDate,
    this.endDate,
  });

  final String? type;
  final String? categoryId;
  final String? walletId;
  final DateTime? startDate;
  final DateTime? endDate;
}

enum ExportReportPeriod { monthly, yearly }

class ExportFileResult {
  const ExportFileResult({
    required this.bytes,
    required this.displayName,
    required this.mimeType,
    this.savedPath,
  });

  final Uint8List bytes;
  final String displayName;
  final String mimeType;
  final String? savedPath;
}

class ExportService {
  ExportService({required TransactionService transactionService})
    : _transactionService = transactionService;

  final TransactionService _transactionService;

  Future<ExportFileResult> exportCsv({
    required String uid,
    required ExportFilters filters,
    required List<CategoryModel> categories,
    required List<WalletModel> wallets,
    required String languageCode,
  }) async {
    final transactions = await _loadFilteredTransactions(uid, filters: filters);
    if (transactions.isEmpty) {
      throw StateError('No transactions available for export.');
    }

    final categoryMap = {
      for (final category in categories) category.id: category,
    };
    final walletMap = {for (final wallet in wallets) wallet.id: wallet};
    final rows = <List<String>>[
      <String>[
        _pdfText(languageCode, 'Date', 'তারিখ'),
        _pdfText(languageCode, 'Type', 'ধরন'),
        _pdfText(languageCode, 'Category', 'ক্যাটাগরি'),
        _pdfText(languageCode, 'Amount', 'পরিমাণ'),
        _pdfText(languageCode, 'Wallet', 'ওয়ালেট'),
        _pdfText(languageCode, 'Note', 'নোট'),
      ],
      ...transactions.map((transaction) {
        final wallet = walletMap[transaction.walletId];
        return <String>[
          LocaleFormatters.formatDate(
            transaction.date,
            'yyyy-MM-dd HH:mm',
            languageCode,
          ),
          _transactionTypeLabel(transaction, languageCode),
          _categoryLabel(transaction.categoryId, categoryMap, languageCode),
          transaction.amount.toStringAsFixed(2),
          _walletLabel(wallet, languageCode),
          transaction.note.replaceAll('\n', ' '),
        ];
      }),
    ];

    final content = rows.map(_csvRow).join('\n');
    final fileName =
        'transactions_${DateTime.now().millisecondsSinceEpoch}.csv';
    final bytes = Uint8List.fromList(utf8.encode(content));
    final savedPath = await saveExportBytes(bytes: bytes, fileName: fileName);

    return ExportFileResult(
      bytes: bytes,
      displayName: fileName,
      mimeType: 'text/csv',
      savedPath: savedPath,
    );
  }

  Future<ExportFileResult> exportPdf({
    required String uid,
    required ExportReportPeriod period,
    required int year,
    int? month,
    required List<CategoryModel> categories,
    required List<WalletModel> wallets,
    required String currency,
    required String languageCode,
  }) async {
    final start = period == ExportReportPeriod.monthly
        ? DateTime(year, month ?? 1)
        : DateTime(year);
    final end = period == ExportReportPeriod.monthly
        ? DateTime(year, (month ?? 1) + 1, 0)
        : DateTime(year, 12, 31);

    final transactions = await _loadFilteredTransactions(
      uid,
      filters: ExportFilters(startDate: start, endDate: end),
    );
    if (transactions.isEmpty) {
      throw StateError('No transactions available for export.');
    }

    final categoryMap = {
      for (final category in categories) category.id: category,
    };
    final walletMap = {for (final wallet in wallets) wallet.id: wallet};
    final font = await PdfGoogleFonts.notoSansBengaliRegular();
    final boldFont = await PdfGoogleFonts.notoSansBengaliBold();

    final doc = pw.Document();
    final reportTitle = period == ExportReportPeriod.monthly
        ? '${AppConstants.appName} - ${LocaleFormatters.formatDate(start, 'MMMM yyyy', languageCode)}'
        : '${AppConstants.appName} - ${_pdfText(languageCode, '$year Summary', '${LocaleFormatters.formatNumber(year, languageCode)} সালের সারাংশ')}';

    final incomeTransactions = transactions
        .where(
          (item) => !item.isTransfer && item.type == FinanceCatalog.incomeType,
        )
        .toList(growable: false);
    final expenseTransactions = transactions
        .where(
          (item) => !item.isTransfer && item.type == FinanceCatalog.expenseType,
        )
        .toList(growable: false);
    final totalIncome = incomeTransactions.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final totalExpense = expenseTransactions.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final netBalance = totalIncome - totalExpense;

    final categoryTotals = <String, double>{};
    for (final transaction in expenseTransactions) {
      categoryTotals.update(
        transaction.categoryId,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final categoryRows = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final groupedRows = <_PdfSummaryRow>[];
    final groupedTotals = <String, _RunningTotals>{};
    for (final transaction in transactions.where((item) => !item.isTransfer)) {
      final key = period == ExportReportPeriod.monthly
          ? LocaleFormatters.formatDate(
              transaction.date,
              'dd MMM',
              languageCode,
            )
          : LocaleFormatters.formatDate(transaction.date, 'MMM', languageCode);
      final totals = groupedTotals.putIfAbsent(key, _RunningTotals.new);
      if (transaction.type == FinanceCatalog.incomeType) {
        totals.income += transaction.amount;
      } else if (transaction.type == FinanceCatalog.expenseType) {
        totals.expense += transaction.amount;
      }
    }

    groupedTotals.forEach((label, totals) {
      groupedRows.add(
        _PdfSummaryRow(
          label: label,
          income: totals.income,
          expense: totals.expense,
        ),
      );
    });

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        ),
        build: (context) => <pw.Widget>[
          pw.Text(
            reportTitle,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 22,
              color: PdfColor.fromHex('#1D3F8A'),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            period == ExportReportPeriod.monthly
                ? _pdfText(
                    languageCode,
                    'Monthly financial summary',
                    'মাসিক আর্থিক সারাংশ',
                  )
                : _pdfText(
                    languageCode,
                    'Yearly financial summary',
                    'বার্ষিক আর্থিক সারাংশ',
                  ),
          ),
          pw.SizedBox(height: 18),
          _buildSummaryTable(
            currency: currency,
            income: totalIncome,
            expense: totalExpense,
            net: netBalance,
            languageCode: languageCode,
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            _pdfText(languageCode, 'Category breakdown', 'ক্যাটাগরি বিশ্লেষণ'),
            style: pw.TextStyle(font: boldFont),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(font: boldFont, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF1D3F8A),
            ),
            headers: <String>[
              _pdfText(languageCode, 'Category', 'ক্যাটাগরি'),
              _pdfText(languageCode, 'Expense', 'খরচ'),
            ],
            data: categoryRows.take(8).map((entry) {
              final label = _categoryLabel(
                entry.key,
                categoryMap,
                languageCode,
              );
              return <String>[
                label,
                LocaleFormatters.formatCurrency(
                  entry.value,
                  currency,
                  languageCode,
                ),
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            _pdfText(languageCode, 'Period breakdown', 'সময়ভিত্তিক বিশ্লেষণ'),
            style: pw.TextStyle(font: boldFont),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(font: boldFont, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF1D3F8A),
            ),
            headers: <String>[
              period == ExportReportPeriod.monthly
                  ? _pdfText(languageCode, 'Day', 'দিন')
                  : _pdfText(languageCode, 'Month', 'মাস'),
              _pdfText(languageCode, 'Income', 'আয়'),
              _pdfText(languageCode, 'Expense', 'খরচ'),
              _pdfText(languageCode, 'Net', 'নিট'),
            ],
            data: groupedRows.map((row) {
              return <String>[
                row.label,
                LocaleFormatters.formatCurrency(
                  row.income,
                  currency,
                  languageCode,
                ),
                LocaleFormatters.formatCurrency(
                  row.expense,
                  currency,
                  languageCode,
                ),
                LocaleFormatters.formatCurrency(
                  row.income - row.expense,
                  currency,
                  languageCode,
                ),
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            _pdfText(languageCode, 'Recent transactions', 'সাম্প্রতিক লেনদেন'),
            style: pw.TextStyle(font: boldFont),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(font: boldFont, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF1D3F8A),
            ),
            headers: <String>[
              _pdfText(languageCode, 'Date', 'তারিখ'),
              _pdfText(languageCode, 'Type', 'ধরন'),
              _pdfText(languageCode, 'Category', 'ক্যাটাগরি'),
              _pdfText(languageCode, 'Wallet', 'ওয়ালেট'),
              _pdfText(languageCode, 'Amount', 'পরিমাণ'),
            ],
            data: transactions.reversed.take(14).map((transaction) {
              return <String>[
                LocaleFormatters.formatDate(
                  transaction.date,
                  'dd MMM yyyy',
                  languageCode,
                ),
                _transactionTypeLabel(transaction, languageCode),
                _categoryLabel(
                  transaction.categoryId,
                  categoryMap,
                  languageCode,
                ),
                _walletLabel(walletMap[transaction.walletId], languageCode),
                LocaleFormatters.formatCurrency(
                  transaction.amount,
                  currency,
                  languageCode,
                ),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    final fileName =
        '${period == ExportReportPeriod.monthly ? 'monthly_report' : 'yearly_report'}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final savedPath = await saveExportBytes(bytes: bytes, fileName: fileName);

    return ExportFileResult(
      bytes: bytes,
      displayName: fileName,
      mimeType: 'application/pdf',
      savedPath: savedPath,
    );
  }

  Future<List<TransactionModel>> _loadFilteredTransactions(
    String uid, {
    required ExportFilters filters,
  }) async {
    final transactions = await _transactionService.fetchTransactionsForExport(
      uid,
      startDate: filters.startDate,
      endDate: filters.endDate,
    );

    return transactions
        .where((transaction) {
          if (filters.type != null && filters.type!.isNotEmpty) {
            if (filters.type == FinanceCatalog.transferType) {
              if (!transaction.isTransfer) {
                return false;
              }
            } else if (transaction.type != filters.type ||
                transaction.isTransfer) {
              return false;
            }
          }
          if (filters.categoryId != null &&
              filters.categoryId!.isNotEmpty &&
              transaction.categoryId != filters.categoryId) {
            return false;
          }
          if (filters.walletId != null &&
              filters.walletId!.isNotEmpty &&
              transaction.walletId != filters.walletId) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  String _csvRow(List<String> values) {
    return values
        .map((value) {
          final escaped = value.replaceAll('"', '""');
          return '"$escaped"';
        })
        .join(',');
  }

  String _transactionTypeLabel(
    TransactionModel transaction,
    String languageCode,
  ) {
    if (transaction.isTransfer) {
      return _pdfText(languageCode, 'Transfer', 'ট্রান্সফার');
    }
    if (transaction.type == FinanceCatalog.incomeType) {
      return _pdfText(languageCode, 'Income', 'আয়');
    }
    return _pdfText(languageCode, 'Expense', 'খরচ');
  }

  String _categoryLabel(
    String categoryId,
    Map<String, CategoryModel> categoryMap,
    String languageCode,
  ) {
    final category = categoryMap[categoryId];
    if (category != null) {
      final localized = category.localizedName(languageCode).trim();
      if (localized.isNotEmpty) {
        return localized;
      }
    }

    for (final template in <FinanceCategoryTemplate>[
      ...FinanceCatalog.defaultCategoryTemplates,
      ...FinanceCatalog.quickCategoryTemplates,
    ]) {
      if (template.id == categoryId) {
        return languageCode == 'bn' && template.nameBn.trim().isNotEmpty
            ? template.nameBn
            : template.name;
      }
    }

    return category?.name ?? categoryId;
  }

  String _walletLabel(WalletModel? wallet, String languageCode) {
    if (wallet == null) {
      return '';
    }

    if (languageCode != 'bn') {
      return wallet.name;
    }

    final defaultEnglishLabel = FinanceCatalog.walletTypeFor(wallet.type).label;
    if (wallet.name == defaultEnglishLabel || wallet.name == wallet.type) {
      switch (wallet.type) {
        case FinanceCatalog.walletTypeCash:
          return 'ক্যাশ';
        case FinanceCatalog.walletTypeBank:
          return 'ব্যাংক';
        case FinanceCatalog.walletTypeBkash:
          return 'বিকাশ';
        case FinanceCatalog.walletTypeNagad:
          return 'নগদ';
        case FinanceCatalog.walletTypeSavings:
          return 'সেভিংস';
      }
    }

    return wallet.name;
  }

  pw.Widget _buildSummaryTable({
    required String currency,
    required double income,
    required double expense,
    required double net,
    required String languageCode,
  }) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF1D3F8A),
      ),
      headers: <String>[
        _pdfText(languageCode, 'Metric', 'মেট্রিক'),
        _pdfText(languageCode, 'Value', 'মান'),
      ],
      data: <List<String>>[
        <String>[
          _pdfText(languageCode, 'Total income', 'মোট আয়'),
          LocaleFormatters.formatCurrency(income, currency, languageCode),
        ],
        <String>[
          _pdfText(languageCode, 'Total expense', 'মোট খরচ'),
          LocaleFormatters.formatCurrency(expense, currency, languageCode),
        ],
        <String>[
          _pdfText(languageCode, 'Net balance', 'নিট ব্যালেন্স'),
          LocaleFormatters.formatCurrency(net, currency, languageCode),
        ],
      ],
    );
  }

  String _pdfText(String languageCode, String en, String bn) {
    return languageCode == 'bn' ? bn : en;
  }
}

class _RunningTotals {
  double income = 0;
  double expense = 0;
}

class _PdfSummaryRow {
  const _PdfSummaryRow({
    required this.label,
    required this.income,
    required this.expense,
  });

  final String label;
  final double income;
  final double expense;
}
