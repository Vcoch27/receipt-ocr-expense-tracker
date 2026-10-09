import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../core/categories.dart';
import '../core/formatters.dart';
import '../l10n/expense_labels.dart';
import '../l10n/l10n.dart';
import '../models/expense_analytics.dart';
import '../state/expense_providers.dart';
import '../services/expense_report_exporter.dart';
import '../widgets/app_header.dart';
import '../widgets/donut_chart.dart';
import '../widgets/expense_state.dart';
import '../widgets/page_container.dart';
import '../widgets/weekly_bar_chart.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  Future<void> _chooseMonth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: context.l10n.chooseMonth,
    );
    if (date != null) setState(() => _month = DateTime(date.year, date.month));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final current = DateTime(now.year, now.month);
    final previous = DateTime(now.year, now.month - 1);
    final locale = Localizations.localeOf(context).languageCode;
    final monthLabel = DateFormat.yMMMM(locale).format(_month);
    final analytics = ref.watch(
      expenseMonthAnalyticsProvider(_month.year * 12 + _month.month),
    );
    return Scaffold(
      appBar: AppHeader(subtitle: context.l10n.insights),
      body: PageContainer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text(context.l10n.thisMonth),
                      selected: _sameMonth(_month, current),
                      onSelected: (_) => setState(() => _month = current),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ChoiceChip(
                      label: Text(context.l10n.lastMonth),
                      selected: _sameMonth(_month, previous),
                      onSelected: (_) => setState(() => _month = previous),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filledTonal(
                    onPressed: _chooseMonth,
                    tooltip: context.l10n.chooseMonth,
                    icon: const Icon(Icons.calendar_month_outlined),
                  ),
                ],
              ),
            ),
            Expanded(
              child: analytics.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => ExpenseState(
                  icon: Icons.error_outline,
                  title: context.l10n.insightsUnavailable,
                  message: context.l10n.retryHint,
                ),
                data: (data) => _AnalyticsContent(
                  data: data, monthLabel: monthLabel, month: _month,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _sameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

class _AnalyticsContent extends ConsumerWidget {
  const _AnalyticsContent({required this.data, required this.monthLabel,
      required this.month});
  final ExpenseAnalytics data;
  final String monthLabel;
  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.spentThisMonth.toUpperCase(),
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  formatVnd(data.total),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.chartUsesTransactionDate,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(context.l10n.byCategory, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: data.total == 0
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Column(
                      children: [
                        Icon(
                          Icons.donut_large_outlined,
                          size: 44,
                          color: scheme.outline,
                        ),
                        const SizedBox(height: 12),
                        Text(context.l10n.noExpensesThisMonth),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.go('/scan'),
                          child: Text(context.l10n.addExpense),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      DonutChart(
                        values: data.byCategory,
                        periodLabel: monthLabel,
                      ),
                      ...data.byCategory.entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 6,
                                backgroundColor: categoryColor(entry.key),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  localizedCategory(context, entry.key),
                                ),
                              ),
                              Text(
                                formatVnd(entry.value),
                                style: theme.textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (data.byCategory.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            color: scheme.secondaryContainer.withValues(alpha: .6),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.insights_outlined, color: scheme.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.spendingNote,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(_topCategoryText(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text(context.l10n.thisWeek, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.fromDate(formatDate(data.weekStart)),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.chartUsesTransactionDate,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                if (data.weekly.every((value) => value == 0))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: Center(
                      child: Text(context.l10n.noCurrentWeekExpenses),
                    ),
                  )
                else
                  WeeklyBarChart(values: data.weekly),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _topCategoryText(BuildContext context) {
    final top = data.byCategory.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    final percent = (top.value / data.total * 100).round();
    return context.l10n.topCategoryInsight(
      localizedCategory(context, top.key),
      percent,
    );
  }
}
