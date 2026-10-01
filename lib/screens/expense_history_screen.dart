import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/expense_providers.dart';
import '../widgets/expense_state.dart';
import '../widgets/expense_tile.dart';
import '../widgets/page_container.dart';

class ExpenseHistoryScreen extends ConsumerWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense history')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scan'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: PageContainer(
        child: ref
            .watch(expensesProvider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ExpenseState(
                icon: Icons.error_outline,
                title: 'History unavailable',
                message: error.toString(),
                action: FilledButton(
                  onPressed: () => ref.invalidate(expensesProvider),
                  child: const Text('Try again'),
                ),
              ),
              data: (items) => items.isEmpty
                  ? const ExpenseState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No saved expenses',
                      message: 'Import a payment screenshot, scan a receipt, or add an expense manually.',
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
