import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/expense_providers.dart';
import '../l10n/l10n.dart';
import '../widgets/expense_state.dart';
import '../widgets/expense_tile.dart';
import '../widgets/page_container.dart';

class ExpenseHistoryScreen extends ConsumerWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.expenseHistory)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scan'),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.add),
      ),
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
              data: (items) => items.isEmpty
                  ? ExpenseState(
                      icon: Icons.receipt_long_outlined,
                      title: context.l10n.noSavedExpenses,
                      message: context.l10n.emptyExpenseHint,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ExpenseTile(
                          key: ValueKey(item.id),
                          item: item,
                          onTap: () => context.push('/expense/${item.id}'),
                        );
                      },
                    ),
            ),
      ),
    );
  }
}
