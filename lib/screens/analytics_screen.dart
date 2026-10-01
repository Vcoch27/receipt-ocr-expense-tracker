import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/categories.dart';
import '../core/formatters.dart';
import '../l10n/expense_labels.dart';
import '../l10n/l10n.dart';
import '../state/expense_providers.dart';
import '../widgets/donut_chart.dart';
import '../widgets/expense_state.dart';
import '../widgets/page_container.dart';
import '../widgets/weekly_bar_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(expenseAnalyticsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.insights)),
      body: PageContainer(
        child: analytics.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => ExpenseState(
            icon: Icons.error_outline,
            title: context.l10n.insightsUnavailable,
            message: context.l10n.retryHint,
          ),
          data: (data) => data.total == 0
              ? ExpenseState(
                  icon: Icons.donut_large_outlined,
                  title: context.l10n.nothingToChart,
                  message: context.l10n.emptyChartHint,
                  action: FilledButton(
                    onPressed: () => context.push('/scan'),
                    child: Text(context.l10n.addExpense),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  children: [
                    Text(
                      context.l10n.spendingOverview,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.byCategory,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            DonutChart(values: data.byCategory),
                            ...data.byCategory.entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
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
                                    Text(formatVnd(entry.value)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.thisWeek,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.fromDate(formatDate(data.weekStart)),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 20),
                            WeeklyBarChart(values: data.weekly),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
