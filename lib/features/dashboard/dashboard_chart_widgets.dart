import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/gradient_colors.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/premium_card.dart';
import 'dashboard_analytics.dart';

class AnalyticsMetricCard extends StatelessWidget {
  const AnalyticsMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.highlight,
    this.toneColor,
  });

  final String label;
  final String value;
  final String? highlight;
  final Color? toneColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = toneColor ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.74),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (highlight != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              highlight!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ExpenseTrendChartCard extends StatelessWidget {
  const ExpenseTrendChartCard({
    super.key,
    required this.analytics,
    required this.title,
    required this.subtitle,
  });

  final PeriodAnalytics analytics;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradients = theme.extension<GradientColors>()!;
    final spots = analytics.buckets
        .map((bucket) => FlSpot(bucket.index.toDouble(), bucket.expense))
        .toList(growable: false);
    final maxY = _roundedMaxY(
      analytics.buckets.map((bucket) => bucket.expense).toList(),
    );

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.74),
            ),
          ),
          const SizedBox(height: 20),
          if (spots.every((spot) => spot.y == 0))
            _EmptyChartHint(
              label: context.l10n.isBangla
                  ? 'এই সময়ের খরচ যোগ করলে ট্রেন্ড লাইন দেখা যাবে।'
                  : 'Add expenses this period to reveal the trend line.',
            )
          else
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.dividerColor.withValues(alpha: 0.6),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: maxY / 4,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            value.round().toString(),
                            style: theme.textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final index = value.round();
                          if (index < 0 || index >= analytics.buckets.length) {
                            return const SizedBox.shrink();
                          }
                          if (!_shouldShowXAxisLabel(
                            index,
                            analytics.buckets.length,
                          )) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              analytics.buckets[index].label,
                              style: theme.textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: const LineTouchData(enabled: false),
                  lineBarsData: <LineChartBarData>[
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3.2,
                      color: theme.colorScheme.primary,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            gradients.chartGradient.colors.first.withValues(
                              alpha: 0.38,
                            ),
                            gradients.chartGradient.colors.last.withValues(
                              alpha: 0.04,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NetWorthTrendChartCard extends StatelessWidget {
  const NetWorthTrendChartCard({
    super.key,
    required this.trend,
    required this.title,
    required this.subtitle,
  });

  final NetWorthTrend trend;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradients = theme.extension<GradientColors>()!;
    final values = trend.buckets
        .map((bucket) => bucket.netWorth)
        .toList(growable: false);
    final spots = trend.buckets
        .map((bucket) => FlSpot(bucket.index.toDouble(), bucket.netWorth))
        .toList(growable: false);
    final minY = _roundedMinY(values);
    final maxY = _roundedMaxY(values);

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.74),
            ),
          ),
          const SizedBox(height: 20),
          if (spots.isEmpty || spots.every((spot) => spot.y.abs() <= 0.009))
            _EmptyChartHint(
              label: context.l10n.isBangla
                  ? 'নেট ওয়ার্থের ট্রেন্ড দেখতে আরও কিছু আর্থিক কার্যকলাপ যোগ করুন।'
                  : 'Add more financial activity to reveal your net worth trend.',
            )
          else
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: ((maxY - minY).abs() / 4).clamp(
                      1,
                      double.infinity,
                    ),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.dividerColor.withValues(alpha: 0.6),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        interval: ((maxY - minY).abs() / 4).clamp(
                          1,
                          double.infinity,
                        ),
                        getTitlesWidget: (value, meta) {
                          if ((value - minY).abs() <= 0.009 && minY != 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            value.round().toString(),
                            style: theme.textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final index = value.round();
                          if (index < 0 || index >= trend.buckets.length) {
                            return const SizedBox.shrink();
                          }
                          if (!_shouldShowXAxisLabel(
                            index,
                            trend.buckets.length,
                          )) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              trend.buckets[index].label,
                              style: theme.textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineTouchData: const LineTouchData(enabled: false),
                  lineBarsData: <LineChartBarData>[
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3.2,
                      color: const Color(0xFF54A7FF),
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            gradients.chartGradient.colors.first.withValues(
                              alpha: 0.34,
                            ),
                            gradients.chartGradient.colors.last.withValues(
                              alpha: 0.05,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class IncomeExpenseBarChartCard extends StatelessWidget {
  const IncomeExpenseBarChartCard({
    super.key,
    required this.analytics,
    required this.title,
  });

  final PeriodAnalytics analytics;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final incomeColor = const Color(0xFF2ECC9A);
    final expenseColor = const Color(0xFFE85D5D);
    final maxY = _roundedMaxY(
      analytics.buckets
          .expand((bucket) => <double>[bucket.income, bucket.expense])
          .toList(),
    );

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: <Widget>[
              _ChartLegend(
                label: context.l10n.incomeTypeLabel,
                color: const Color(0xFF2ECC9A),
              ),
              _ChartLegend(
                label: context.l10n.expenseTypeLabel,
                color: const Color(0xFFE85D5D),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (analytics.totalIncome == 0 && analytics.totalExpense == 0)
            _EmptyChartHint(
              label: context.l10n.isBangla
                  ? 'এই সময়ের লেনদেন যোগ করলে বার চার্ট দেখা যাবে।'
                  : 'Your bar chart will appear once you add transactions in this period.',
            )
          else
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  minY: 0,
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.dividerColor.withValues(alpha: 0.6),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        interval: maxY / 4,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            value.round().toString(),
                            style: theme.textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.round();
                          if (index < 0 || index >= analytics.buckets.length) {
                            return const SizedBox.shrink();
                          }
                          if (!_shouldShowXAxisLabel(
                            index,
                            analytics.buckets.length,
                          )) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              analytics.buckets[index].label,
                              style: theme.textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: const BarTouchData(enabled: false),
                  barGroups: analytics.buckets
                      .map((bucket) {
                        return BarChartGroupData(
                          x: bucket.index,
                          barsSpace: 6,
                          barRods: <BarChartRodData>[
                            BarChartRodData(
                              toY: bucket.income,
                              width: 8,
                              borderRadius: BorderRadius.circular(999),
                              color: incomeColor,
                            ),
                            BarChartRodData(
                              toY: bucket.expense,
                              width: 8,
                              borderRadius: BorderRadius.circular(999),
                              color: expenseColor,
                            ),
                          ],
                        );
                      })
                      .toList(growable: false),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CategoryBreakdownViewData {
  const CategoryBreakdownViewData({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;
}

class CategoryBreakdownChartCard extends StatelessWidget {
  const CategoryBreakdownChartCard({
    super.key,
    required this.items,
    required this.title,
  });

  final List<CategoryBreakdownViewData> items;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);

    return buildPremiumCard(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          if (items.isEmpty || total == 0)
            _EmptyChartHint(
              label: context.l10n.isBangla
                  ? 'এই সময়ে এখনো কোনো ব্যয়ের ক্যাটাগরি নেই।'
                  : 'No expense categories yet for this period.',
            )
          else
            Column(
              children: <Widget>[
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 52,
                      sectionsSpace: 3,
                      pieTouchData: PieTouchData(enabled: false),
                      sections: items
                          .map((item) {
                            return PieChartSectionData(
                              value: item.amount,
                              color: item.color,
                              title: '',
                              radius: 56,
                            );
                          })
                          .toList(growable: false),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ...items.map((item) {
                  final share = total == 0 ? 0 : (item.amount / total) * 100;
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${share.toStringAsFixed(0)}%',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmptyChartHint extends StatelessWidget {
  const _EmptyChartHint({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.76),
        ),
      ),
    );
  }
}

double _roundedMinY(List<double> values) {
  if (values.isEmpty) {
    return 0;
  }
  final min = values.reduce((a, b) => a < b ? a : b);
  if (min >= 0) {
    return 0;
  }
  final magnitude = min.abs();
  final base = magnitude <= 250
      ? 50
      : magnitude <= 1000
      ? 100
      : magnitude <= 5000
      ? 500
      : 1000;
  return -((magnitude / base).ceil() * base).toDouble();
}

bool _shouldShowXAxisLabel(int index, int total) {
  if (total <= 8) {
    return true;
  }
  if (total <= 16) {
    return index.isEven;
  }
  return index % 4 == 0 || index == total - 1;
}

double _roundedMaxY(List<double> values) {
  final maxValue = values.fold<double>(0, (current, value) {
    return value > current ? value : current;
  });
  if (maxValue <= 0) {
    return 100;
  }
  return (maxValue * 1.25).ceilToDouble();
}
