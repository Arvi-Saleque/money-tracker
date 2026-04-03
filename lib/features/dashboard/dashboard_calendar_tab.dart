import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/transaction_model.dart';
import '../../shared/models/wallet_model.dart';
import '../../shared/widgets/premium_card.dart';
import '../profile/profile_providers.dart';
import '../transactions/finance_catalog.dart';
import '../transactions/transaction_editor_sheet.dart';
import '../transactions/transaction_providers.dart';
import 'dashboard_ui_parts.dart';

class CalendarTabView extends ConsumerStatefulWidget {
  const CalendarTabView({super.key});

  @override
  ConsumerState<CalendarTabView> createState() => _CalendarTabViewState();
}

class _CalendarTabViewState extends ConsumerState<CalendarTabView> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final monthStart = _monthStart(_focusedDay);
    final calendarAsync = ref.watch(monthCalendarProvider(monthStart));
    final categories =
        ref.watch(allCategoriesProvider).asData?.value ??
        const <CategoryModel>[];
    final wallets =
        ref.watch(walletsProvider).asData?.value ?? const <WalletModel>[];
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final currency = profile?.currency ?? AppConstants.defaultCurrency;
    final languageCode =
        profile?.language ?? Localizations.localeOf(context).languageCode;
    final categoryMap = {
      for (final category in categories) category.id: category,
    };
    final walletMap = {for (final wallet in wallets) wallet.id: wallet};
    final localeCode = Localizations.localeOf(context).languageCode;

    return calendarAsync.when(
      data: (calendarData) {
        final selectedSummary =
            calendarData.daySummaries[_dayKey(_selectedDay)] ??
            DayTransactionSummary.empty(_dayKey(_selectedDay));

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          children: <Widget>[
            buildPremiumCard(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: _pickMonth,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  DateFormat(
                                    'MMMM yyyy',
                                    localeCode,
                                  ).format(_focusedDay),
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.keyboard_arrow_down_rounded),
                              ],
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _moveFocusedMonth(-1),
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      IconButton(
                        onPressed: () => _moveFocusedMonth(1),
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      _CalendarModeChip(
                        label: 'Month view',
                        selected: _calendarFormat == CalendarFormat.month,
                        onTap: () {
                          setState(() {
                            _calendarFormat = CalendarFormat.month;
                          });
                        },
                      ),
                      _CalendarModeChip(
                        label: 'Week view',
                        selected: _calendarFormat == CalendarFormat.week,
                        onTap: () {
                          setState(() {
                            _calendarFormat = CalendarFormat.week;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TableCalendar<TransactionModel>(
                    locale: localeCode,
                    firstDay: DateTime(DateTime.now().year - 5),
                    lastDay: DateTime(DateTime.now().year + 5),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    headerVisible: false,
                    availableCalendarFormats: const <CalendarFormat, String>{},
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      _openDayDetailSheet(
                        summary:
                            calendarData.daySummaries[_dayKey(selectedDay)] ??
                            DayTransactionSummary.empty(_dayKey(selectedDay)),
                        categoryMap: categoryMap,
                        walletMap: walletMap,
                        currency: currency,
                        languageCode: languageCode,
                      );
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: true,
                      defaultDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      todayDecoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      weekendTextStyle: Theme.of(context).textTheme.bodyMedium!,
                      outsideTextStyle: Theme.of(context).textTheme.bodySmall!
                          .copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.5),
                          ),
                      markerMargin: const EdgeInsets.only(top: 8),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekendStyle: Theme.of(context).textTheme.labelMedium!,
                      weekdayStyle: Theme.of(context).textTheme.labelMedium!,
                    ),
                    calendarBuilders: CalendarBuilders<TransactionModel>(
                      markerBuilder: (context, day, _) {
                        final summary = calendarData.daySummaries[_dayKey(day)];
                        if (summary == null ||
                            (summary.totalIncome == 0 &&
                                summary.totalExpense == 0)) {
                          return const SizedBox.shrink();
                        }

                        return Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              if (summary.totalIncome > 0)
                                const _CalendarMarkerDot(
                                  color: Color(0xFF2ECC9A),
                                ),
                              if (summary.totalIncome > 0 &&
                                  summary.totalExpense > 0)
                                const SizedBox(width: 4),
                              if (summary.totalExpense > 0)
                                const _CalendarMarkerDot(
                                  color: Color(0xFFE85D5D),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SelectedDayPreviewCard(
              summary: selectedSummary,
              currency: currency,
              localeCode: localeCode,
              onOpenDetails: () => _openDayDetailSheet(
                summary: selectedSummary,
                categoryMap: categoryMap,
                walletMap: walletMap,
                currency: currency,
                languageCode: languageCode,
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
        children: <Widget>[
          EmptyFinanceCard(
            title: 'Calendar is loading',
            subtitle: error.toString(),
          ),
        ],
      ),
    );
  }

  void _moveFocusedMonth(int delta) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + delta, 1);
      if (_focusedDay.month != _selectedDay.month ||
          _focusedDay.year != _selectedDay.year) {
        _selectedDay = _focusedDay;
      }
    });
  }

  Future<void> _pickMonth() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select month',
    );

    if (selected == null) {
      return;
    }

    final normalized = DateTime(selected.year, selected.month, 1);
    setState(() {
      _focusedDay = normalized;
      _selectedDay = normalized;
    });
  }

  Future<void> _openDayDetailSheet({
    required DayTransactionSummary summary,
    required Map<String, CategoryModel> categoryMap,
    required Map<String, WalletModel> walletMap,
    required String currency,
    required String languageCode,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.68,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      DateFormat(
                        'dd MMMM yyyy',
                        Localizations.localeOf(context).languageCode,
                      ).format(summary.date),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Income, expense, and transaction details for the selected day.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.74),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _DayMetricCard(
                            label: 'Income',
                            value: _formatCurrency(
                              summary.totalIncome,
                              currency,
                            ),
                            color: const Color(0xFF2ECC9A),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DayMetricCard(
                            label: 'Expense',
                            value: _formatCurrency(
                              summary.totalExpense,
                              currency,
                            ),
                            color: const Color(0xFFE85D5D),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DayMetricCard(
                            label: 'Net',
                            value: _formatCurrency(
                              summary.totalIncome - summary.totalExpense,
                              currency,
                            ),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: summary.transactions.isEmpty
                          ? const EmptyFinanceCard(
                              title: 'No transaction on this day',
                              subtitle:
                                  'Pick another date or add a new entry to start building your calendar.',
                            )
                          : ListView.separated(
                              controller: scrollController,
                              itemCount: summary.transactions.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final transaction = summary.transactions[index];
                                final category =
                                    categoryMap[transaction.categoryId];
                                final wallet = walletMap[transaction.walletId];
                                final color =
                                    transaction.type ==
                                        FinanceCatalog.incomeType
                                    ? const Color(0xFF2ECC9A)
                                    : const Color(0xFFE85D5D);

                                return FinanceTransactionTile(
                                  title:
                                      category?.localizedName(languageCode) ??
                                      'Category',
                                  subtitle: _buildCalendarSubtitle(
                                    transaction: transaction,
                                    wallet: wallet,
                                  ),
                                  amount:
                                      '${transaction.type == FinanceCatalog.incomeType ? '+' : '-'}${_formatCurrency(transaction.amount, currency)}',
                                  icon: FinanceCatalog.iconForKey(
                                    category?.iconKey ?? 'category',
                                  ),
                                  color: color,
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    await openTransactionEditorPage(
                                      this.context,
                                      transaction: transaction,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MonthCalendarData {
  const MonthCalendarData({
    required this.monthStart,
    required this.daySummaries,
    required this.transactions,
  });

  final DateTime monthStart;
  final Map<DateTime, DayTransactionSummary> daySummaries;
  final List<TransactionModel> transactions;
}

class DayTransactionSummary {
  const DayTransactionSummary({
    required this.date,
    required this.totalIncome,
    required this.totalExpense,
    required this.transactions,
  });

  factory DayTransactionSummary.empty(DateTime date) {
    return DayTransactionSummary(
      date: date,
      totalIncome: 0,
      totalExpense: 0,
      transactions: const <TransactionModel>[],
    );
  }

  final DateTime date;
  final double totalIncome;
  final double totalExpense;
  final List<TransactionModel> transactions;
}

final monthCalendarProvider =
    StreamProvider.family<MonthCalendarData, DateTime>((ref, monthStart) {
      final uid = ref.watch(currentUserIdProvider);
      if (uid == null) {
        return Stream<MonthCalendarData>.value(
          MonthCalendarData(
            monthStart: monthStart,
            daySummaries: const <DateTime, DayTransactionSummary>{},
            transactions: const <TransactionModel>[],
          ),
        );
      }

      final normalizedMonth = _monthStart(monthStart);
      final end = DateTime(normalizedMonth.year, normalizedMonth.month + 1, 1);

      return ref
          .watch(transactionServiceProvider)
          .watchTransactionsInRange(uid, start: normalizedMonth, end: end)
          .map((transactions) {
            final grouped = <DateTime, List<TransactionModel>>{};

            for (final transaction in transactions) {
              final key = _dayKey(transaction.date);
              grouped.putIfAbsent(key, () => <TransactionModel>[]);
              grouped[key]!.add(transaction);
            }

            final summaries = <DateTime, DayTransactionSummary>{};
            for (final entry in grouped.entries) {
              double income = 0;
              double expense = 0;
              final sortedTransactions = entry.value.toList()
                ..sort((a, b) => b.date.compareTo(a.date));

              for (final transaction in sortedTransactions) {
                if (transaction.type == FinanceCatalog.incomeType) {
                  income += transaction.amount;
                } else {
                  expense += transaction.amount;
                }
              }

              summaries[entry.key] = DayTransactionSummary(
                date: entry.key,
                totalIncome: income,
                totalExpense: expense,
                transactions: List<TransactionModel>.unmodifiable(
                  sortedTransactions,
                ),
              );
            }

            return MonthCalendarData(
              monthStart: normalizedMonth,
              daySummaries: summaries,
              transactions: transactions,
            );
          });
    });

class _CalendarModeChip extends StatelessWidget {
  const _CalendarModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.14)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected
                ? theme.colorScheme.primary
                : theme.textTheme.bodyMedium?.color,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CalendarMarkerDot extends StatelessWidget {
  const _CalendarMarkerDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SelectedDayPreviewCard extends StatelessWidget {
  const _SelectedDayPreviewCard({
    required this.summary,
    required this.currency,
    required this.localeCode,
    required this.onOpenDetails,
  });

  final DayTransactionSummary summary;
  final String currency;
  final String localeCode;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final net = summary.totalIncome - summary.totalExpense;

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final titleBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Selected day snapshot',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy', localeCode).format(summary.date),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.74),
                    ),
                  ),
                ],
              );

              final button = OutlinedButton.icon(
                onPressed: onOpenDetails,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open details'),
              );

              if (constraints.maxWidth < 360) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    titleBlock,
                    const SizedBox(height: 12),
                    button,
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(child: titleBlock),
                  const SizedBox(width: 12),
                  button,
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _DayMetricCard(
                label: 'Income',
                value: _formatCurrency(summary.totalIncome, currency),
                color: const Color(0xFF2ECC9A),
              ),
              _DayMetricCard(
                label: 'Expense',
                value: _formatCurrency(summary.totalExpense, currency),
                color: const Color(0xFFE85D5D),
              ),
              _DayMetricCard(
                label: 'Net',
                value: _formatCurrency(net, currency),
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayMetricCard extends StatelessWidget {
  const _DayMetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

DateTime _monthStart(DateTime date) => DateTime(date.year, date.month, 1);

DateTime _dayKey(DateTime date) => DateTime(date.year, date.month, date.day);

String _formatCurrency(double amount, String currency) {
  return NumberFormat.currency(
    locale: 'en_US',
    symbol: currency,
    decimalDigits: 0,
  ).format(amount);
}

String _buildCalendarSubtitle({
  required TransactionModel transaction,
  required WalletModel? wallet,
}) {
  final pieces = <String>[];
  if (wallet != null) {
    pieces.add(wallet.name);
  }
  if (transaction.note.trim().isNotEmpty) {
    pieces.add(transaction.note.trim());
  }
  pieces.add(DateFormat('hh:mm a').format(transaction.date));
  return pieces.join('  •  ');
}
