import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/formatters.dart';
import '../main.dart';
import '../models/expense_item.dart';
import '../state/expense_providers.dart';
import '../widgets/expense_state.dart';
import '../widgets/expense_tile.dart';
import '../widgets/page_container.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Expense'),
        actions: [
          PopupMenuButton<ThemeMode>(
            tooltip: 'Appearance',
            icon: const Icon(Icons.brightness_6_outlined),
            onSelected: (mode) =>
                ref.read(themeModeProvider.notifier).state = mode,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: ThemeMode.system,
                child: Text('System theme'),
              ),
              PopupMenuItem(value: ThemeMode.light, child: Text('Light mode')),
              PopupMenuItem(value: ThemeMode.dark, child: Text('Dark mode')),
            ],
          ),
        ],
      ),
      body: PageContainer(
        child: expenses.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ExpenseState(
            icon: Icons.cloud_off_outlined,
            title: 'Could not load expenses',
            message: error.toString(),
            action: FilledButton(
              onPressed: () => ref.invalidate(expensesProvider),
              child: const Text('Try again'),
            ),
          ),
          data: (items) => _DashboardContent(items: items),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.items});
  final List<ExpenseItem> items;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthly = items.where(
      (item) => item.date.year == now.year && item.date.month == now.month,
    );
    final total = monthly.fold<int>(0, (sum, item) => sum + item.amount);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          'Capture what you spend',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Save bank payments, wallet screenshots, and paper receipts in one place.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Spent this month', style: theme.textTheme.titleMedium),
                const SizedBox(height: 10),
                Text(
                  formatVnd(total),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  items.isEmpty
                      ? 'Your first expense starts below'
                      : '${monthly.length} expense records',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          key: const ValueKey('add_expense'),
          onPressed: () => context.push('/scan'),
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Add expense'),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent activity', style: theme.textTheme.titleLarge),
            if (items.isNotEmpty)
              TextButton(
                onPressed: () => context.go('/expenses'),
                child: const Text('View all'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const ExpenseState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'No expenses yet',
            message: 'Import a payment screenshot, scan a receipt, or enter an expense manually.',
          )
        else
          ...items
              .take(3)
              .map(
                (item) => ExpenseTile(
                  key: ValueKey(item.id),
                  item: item,
                  onTap: () => context.push('/expense/${item.id}'),
                ),
              ),
      ],
    );
  }
}
