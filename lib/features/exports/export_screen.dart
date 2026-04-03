import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/locale_formatters.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/providers/firebase_providers.dart';
import '../../shared/widgets/premium_card.dart';
import '../profile/profile_providers.dart';
import '../transactions/finance_catalog.dart';
import '../transactions/transaction_providers.dart';
import 'export_providers.dart';
import 'export_service.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String? _csvType;
  String? _categoryId;
  String? _walletId;
  DateTimeRange? _csvRange;
  ExportReportPeriod _reportPeriod = ExportReportPeriod.monthly;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  int _selectedYear = DateTime.now().year;
  bool _csvBusy = false;
  bool _pdfBusy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final categories =
        ref.watch(allCategoriesProvider).asData?.value ?? const [];
    final wallets = ref.watch(walletsProvider).asData?.value ?? const [];
    final languageCode =
        profile?.language ?? Localizations.localeOf(context).languageCode;
    final years = List<int>.generate(
      6,
      (index) => DateTime.now().year - 3 + index,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exportDataTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildPremiumCard(
                    context: context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.exportDataTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(l10n.exportDataSubtitle),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  buildPremiumCard(
                    context: context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.exportCsvTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(l10n.csvFiltersLabel),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String?>(
                          initialValue: _csvType,
                          decoration: InputDecoration(
                            labelText: l10n.exportTypeLabel,
                          ),
                          items: <DropdownMenuItem<String?>>[
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(l10n.allLabel),
                            ),
                            DropdownMenuItem<String?>(
                              value: FinanceCatalog.incomeType,
                              child: Text(l10n.incomeTypeLabel),
                            ),
                            DropdownMenuItem<String?>(
                              value: FinanceCatalog.expenseType,
                              child: Text(l10n.expenseTypeLabel),
                            ),
                            DropdownMenuItem<String?>(
                              value: FinanceCatalog.transferType,
                              child: Text(l10n.transferLabel),
                            ),
                          ],
                          onChanged: _csvBusy
                              ? null
                              : (value) => setState(() => _csvType = value),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String?>(
                          initialValue: _categoryId,
                          decoration: InputDecoration(
                            labelText: l10n.categoryFilterLabel(0),
                          ),
                          items: <DropdownMenuItem<String?>>[
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(l10n.allLabel),
                            ),
                            ...categories.map(
                              (category) => DropdownMenuItem<String?>(
                                value: category.id,
                                child: Text(
                                  category.localizedName(languageCode),
                                ),
                              ),
                            ),
                          ],
                          onChanged: _csvBusy
                              ? null
                              : (value) => setState(() => _categoryId = value),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String?>(
                          initialValue: _walletId,
                          decoration: InputDecoration(
                            labelText: l10n.walletFilterLabel(0),
                          ),
                          items: <DropdownMenuItem<String?>>[
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(l10n.allLabel),
                            ),
                            ...wallets.map(
                              (wallet) => DropdownMenuItem<String?>(
                                value: wallet.id,
                                child: Text(wallet.name),
                              ),
                            ),
                          ],
                          onChanged: _csvBusy
                              ? null
                              : (value) => setState(() => _walletId = value),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.dateRangeLabel),
                          subtitle: Text(
                            _csvRange == null
                                ? l10n.allDatesLabel
                                : '${LocaleFormatters.formatDate(_csvRange!.start, 'dd MMM yyyy', languageCode)} - ${LocaleFormatters.formatDate(_csvRange!.end, 'dd MMM yyyy', languageCode)}',
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: <Widget>[
                              OutlinedButton(
                                onPressed: _csvBusy ? null : _pickCsvRange,
                                child: Text(l10n.pickDateRangeAction),
                              ),
                              if (_csvRange != null)
                                TextButton(
                                  onPressed: _csvBusy
                                      ? null
                                      : () => setState(() => _csvRange = null),
                                  child: Text(l10n.clearDateRangeAction),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: <Widget>[
                            FilledButton.icon(
                              onPressed: _csvBusy
                                  ? null
                                  : () =>
                                        _runCsvExport(shareAfterExport: false),
                              icon: _csvBusy
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.download_rounded),
                              label: Text(l10n.exportNowAction),
                            ),
                            OutlinedButton.icon(
                              onPressed: _csvBusy
                                  ? null
                                  : () => _runCsvExport(shareAfterExport: true),
                              icon: const Icon(Icons.share_rounded),
                              label: Text(l10n.shareFileAction),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  buildPremiumCard(
                    context: context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.exportPdfTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: <Widget>[
                            ChoiceChip(
                              label: Text(l10n.monthlyReportLabel),
                              selected:
                                  _reportPeriod == ExportReportPeriod.monthly,
                              onSelected: _pdfBusy
                                  ? null
                                  : (_) => setState(
                                      () => _reportPeriod =
                                          ExportReportPeriod.monthly,
                                    ),
                            ),
                            ChoiceChip(
                              label: Text(l10n.yearlyReportLabel),
                              selected:
                                  _reportPeriod == ExportReportPeriod.yearly,
                              onSelected: _pdfBusy
                                  ? null
                                  : (_) => setState(
                                      () => _reportPeriod =
                                          ExportReportPeriod.yearly,
                                    ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_reportPeriod == ExportReportPeriod.monthly)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(l10n.reportMonthLabel),
                            subtitle: Text(
                              LocaleFormatters.formatDate(
                                _selectedMonth,
                                'MMMM yyyy',
                                languageCode,
                              ),
                            ),
                            trailing: OutlinedButton(
                              onPressed: _pdfBusy ? null : _pickReportMonth,
                              child: Text(l10n.changeAction),
                            ),
                          )
                        else
                          DropdownButtonFormField<int>(
                            initialValue: _selectedYear,
                            decoration: InputDecoration(
                              labelText: l10n.reportYearLabel,
                            ),
                            items: years
                                .map(
                                  (year) => DropdownMenuItem<int>(
                                    value: year,
                                    child: Text(
                                      LocaleFormatters.formatNumber(
                                        year,
                                        languageCode,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: _pdfBusy
                                ? null
                                : (value) {
                                    if (value == null) {
                                      return;
                                    }
                                    setState(() => _selectedYear = value);
                                  },
                          ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: <Widget>[
                            FilledButton.icon(
                              onPressed: _pdfBusy
                                  ? null
                                  : () =>
                                        _runPdfExport(shareAfterExport: false),
                              icon: _pdfBusy
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.picture_as_pdf_rounded),
                              label: Text(l10n.exportNowAction),
                            ),
                            OutlinedButton.icon(
                              onPressed: _pdfBusy
                                  ? null
                                  : () => _runPdfExport(shareAfterExport: true),
                              icon: const Icon(Icons.share_rounded),
                              label: Text(l10n.shareFileAction),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickCsvRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _csvRange,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _csvRange = picked;
    });
  }

  Future<void> _pickReportMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _selectedMonth = DateTime(picked.year, picked.month);
    });
  }

  Future<void> _runCsvExport({required bool shareAfterExport}) async {
    final l10n = context.l10n;
    final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
    final profile = ref.read(currentUserProfileProvider).asData?.value;
    final categories =
        ref.read(allCategoriesProvider).asData?.value ?? const [];
    final wallets = ref.read(walletsProvider).asData?.value ?? const [];

    if (uid == null) {
      _showMessage(l10n.exportFailedMessage('User not signed in.'));
      return;
    }

    setState(() => _csvBusy = true);
    try {
      final result = await ref
          .read(exportServiceProvider)
          .exportCsv(
            uid: uid,
            filters: ExportFilters(
              type: _csvType,
              categoryId: _categoryId,
              walletId: _walletId,
              startDate: _csvRange?.start,
              endDate: _csvRange?.end,
            ),
            categories: categories,
            wallets: wallets,
            languageCode: profile?.language ?? AppConstants.defaultLanguageCode,
          );
      if (!mounted) {
        return;
      }
      if (shareAfterExport) {
        await SharePlus.instance.share(
          ShareParams(
            files: <XFile>[
              XFile.fromData(
                result.bytes,
                mimeType: result.mimeType,
                name: result.displayName,
              ),
            ],
            subject: result.displayName,
          ),
        );
      } else {
        _showMessage(
          result.savedPath == null
              ? l10n.exportedFileSaved
              : '${l10n.exportedFileSaved}\n${result.savedPath}',
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(_friendlyExportError(error));
    } finally {
      if (mounted) {
        setState(() => _csvBusy = false);
      }
    }
  }

  Future<void> _runPdfExport({required bool shareAfterExport}) async {
    final l10n = context.l10n;
    final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
    final profile = ref.read(currentUserProfileProvider).asData?.value;
    final categories =
        ref.read(allCategoriesProvider).asData?.value ?? const [];
    final wallets = ref.read(walletsProvider).asData?.value ?? const [];

    if (uid == null) {
      _showMessage(l10n.exportFailedMessage('User not signed in.'));
      return;
    }

    setState(() => _pdfBusy = true);
    try {
      final result = await ref
          .read(exportServiceProvider)
          .exportPdf(
            uid: uid,
            period: _reportPeriod,
            year: _reportPeriod == ExportReportPeriod.monthly
                ? _selectedMonth.year
                : _selectedYear,
            month: _reportPeriod == ExportReportPeriod.monthly
                ? _selectedMonth.month
                : null,
            categories: categories,
            wallets: wallets,
            currency: profile?.currency ?? AppConstants.defaultCurrency,
            languageCode: profile?.language ?? AppConstants.defaultLanguageCode,
          );
      if (!mounted) {
        return;
      }
      if (shareAfterExport) {
        await SharePlus.instance.share(
          ShareParams(
            files: <XFile>[
              XFile.fromData(
                result.bytes,
                mimeType: result.mimeType,
                name: result.displayName,
              ),
            ],
            subject: result.displayName,
          ),
        );
      } else {
        _showMessage(
          result.savedPath == null
              ? l10n.exportedFileSaved
              : '${l10n.exportedFileSaved}\n${result.savedPath}',
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showMessage(_friendlyExportError(error));
    } finally {
      if (mounted) {
        setState(() => _pdfBusy = false);
      }
    }
  }

  String _friendlyExportError(Object error) {
    final message = error.toString();
    if (message.contains('No transactions available for export')) {
      return context.l10n.noTransactionsToExport;
    }
    return context.l10n.exportFailedMessage(message);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
