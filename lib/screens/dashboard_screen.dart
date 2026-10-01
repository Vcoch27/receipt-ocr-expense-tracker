import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/formatters.dart';
import '../l10n/l10n.dart';
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/brand/receipt-mark.png', width: 30, height: 30),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                context.l10n.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<Locale>(
            tooltip: context.l10n.language,
            icon: const Icon(Icons.language_outlined),
            onSelected: (locale) =>
                ref.read(localeProvider.notifier).state = locale,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: const Locale('vi'),
                child: Text(context.l10n.vietnamese),
              ),
              PopupMenuItem(
                value: const Locale('en'),
                child: Text(context.l10n.english),
              ),
            ],
          ),
          PopupMenuButton<ThemeMode>(
            tooltip: context.l10n.appearance,
            icon: const Icon(Icons.brightness_6_outlined),
            onSelected: (mode) =>
                ref.read(themeModeProvider.notifier).state = mode,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: ThemeMode.system,
                child: Text(context.l10n.systemTheme),
              ),
              PopupMenuItem(
                value: ThemeMode.light,
                child: Text(context.l10n.lightMode),
              ),
              PopupMenuItem(
                value: ThemeMode.dark,
                child: Text(context.l10n.darkMode),
              ),
            ],
          ),
        ],
      ),
      body: PageContainer(
        child: expenses.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => ExpenseState(
            icon: Icons.cloud_off_outlined,
            title: context.l10n.couldNotLoadExpenses,
            message: context.l10n.retryHint,
            action: FilledButton(
              onPressed: () => ref.invalidate(expensesProvider),
              child: Text(context.l10n.tryAgain),
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
          context.l10n.captureHeadline,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(context.l10n.captureSubtitle, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 24),
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.spentThisMonth,
                  style: theme.textTheme.titleMedium,
                ),
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
                      ? context.l10n.firstExpenseHint
                      : context.l10n.expenseRecords(monthly.length),
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
          label: Text(context.l10n.addExpense),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                context.l10n.recentActivity,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge,
              ),
            ),
            if (items.isNotEmpty)
              TextButton(
                onPressed: () => context.go('/expenses'),
                child: Text(context.l10n.viewAll),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          ExpenseState(
            icon: Icons.account_balance_wallet_outlined,
            title: context.l10n.noExpensesYet,
            message: context.l10n.emptyExpenseHint,
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
