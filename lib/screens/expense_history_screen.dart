import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/categories.dart';
import '../core/formatters.dart';
import '../l10n/expense_labels.dart';
import '../l10n/l10n.dart';
import '../state/expense_providers.dart';
import '../widgets/app_header.dart';
import '../widgets/expense_state.dart';
import '../widgets/expense_tile.dart';
import '../widgets/page_container.dart';

class ExpenseHistoryScreen extends ConsumerStatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  ConsumerState<ExpenseHistoryScreen> createState() =>
      _ExpenseHistoryScreenState();
}

class _ExpenseHistoryScreenState extends ConsumerState<ExpenseHistoryScreen> {
  String _query = '';
  String? _category;
  bool _monthOnly = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    return Scaffold(
      appBar: AppHeader(subtitle: context.l10n.expenseHistory),
      body: PageContainer(
        child: ref
            .watch(expensesProvider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => ExpenseState(
                icon: Icons.error_outline,
                title: context.l10n.historyUnavailable,
                message: context.l10n.retryHint,
                action: FilledButton(
                  onPressed: () => ref.invalidate(expensesProvider),
                  child: Text(context.l10n.tryAgain),
                ),
              ),
              data: (items) {
                final q = _query.trim().toLowerCase();
                final filtered = items.where((item) {
                  if (_monthOnly &&
                      (item.date.year != now.year ||
                          item.date.month != now.month)) {
                    return false;
                  }
                  if (_category != null && item.category != _category) {
                    return false;
                  }
                  return q.isEmpty ||
                      item.merchant.toLowerCase().contains(q) ||
                      (item.note?.toLowerCase().contains(q) ?? false) ||
                      (item.paymentProvider?.toLowerCase().contains(q) ??
                          false) ||
                      item.amount.toString().contains(q);
                }).toList();
                final total = filtered.fold<int>(
                  0,
                  (sum, item) => sum + item.amount,
                );
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: TextField(
                        onChanged: (value) => setState(() => _query = value),
                        decoration: InputDecoration(
                          hintText: context.l10n.searchExpenses,
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHigh,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 66,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        children: [
                          FilterChip(
                            label: Text(context.l10n.thisMonth),
                            selected: _monthOnly,
                            onSelected: (selected) =>
                                setState(() => _monthOnly = selected),
                          ),
                          const SizedBox(width: 8),
                          ...categories.map(
                            (category) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  localizedCategory(context, category),
                                ),
                                selected: _category == category,
                                onSelected: (selected) => setState(
                                  () => _category = selected ? category : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.historySummary(filtered.length),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            formatVnd(total),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? ExpenseState(
                              icon: Icons.search_off_outlined,
                              title: items.isEmpty
                                  ? context.l10n.noSavedExpenses
                                  : context.l10n.noMatchingExpenses,
                              message: items.isEmpty
                                  ? context.l10n.emptyExpenseHint
                                  : context.l10n.adjustFilters,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                final previous = index == 0
                                    ? null
                                    : filtered[index - 1];
                                final showDate =
                                    previous == null ||
                                    !_sameDay(previous.date, item.date);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showDate)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          8,
                                          18,
                                          8,
                                          8,
                                        ),
                                        child: Text(
                                          DateFormat(
                                            'EEEE, dd/MM/yyyy',
                                            Localizations.localeOf(context)
                                                .languageCode,
                                          ).format(item.date),
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ),
                                    ExpenseTile(
                                      key: ValueKey(item.id),
                                      item: item,
                                      onTap: () =>
                                          context.push('/expense/${item.id}'),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
