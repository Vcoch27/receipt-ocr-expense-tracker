import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/formatters.dart';
import '../core/expense_validation.dart';
import '../core/app_theme.dart';
import '../l10n/l10n.dart';
import '../models/expense_item.dart';
import '../models/parsed_expense.dart';
import '../routing/app_router.dart';
import '../state/expense_providers.dart';
import '../services/expense_database.dart';
import '../widgets/app_header.dart';
import '../widgets/expense_state.dart';
import '../widgets/expense_tile.dart';
import '../widgets/page_container.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppHeader(subtitle: context.l10n.overview),
    body: PageContainer(
      child: ref
          .watch(expensesProvider)
          .when(
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

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.items});
  final List<ExpenseItem> items;

  Future<void> _editBudget(
    BuildContext context,
    WidgetRef ref,
    int monthKey,
    int? current,
  ) async {
    final controller = TextEditingController(text: current?.toString() ?? '');
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<int?>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.monthlyBudget),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: context.l10n.amountVnd),
            validator: (value) => ExpenseValidation.amount(value ?? '') == null
                ? context.l10n.amountRequired
                : null,
          ),
        ),
        actions: [
          if (current != null)
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 0),
              child: Text(context.l10n.removeBudget),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(
                  dialogContext,
                  ExpenseValidation.amount(controller.text),
                );
              }
            },
            child: Text(context.l10n.saveChanges),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || !context.mounted) return;
    try {
      final repository = ref.read(expenseRepositoryProvider);
      if (repository is BudgetRepository) {
        await (repository as BudgetRepository).setBudgetForMonth(
          monthKey,
          result == 0 ? null : result,
        );
        ref.invalidate(monthlyBudgetProvider(monthKey));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.budgetSaveError)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final monthly = items
        .where(
          (item) => item.date.year == now.year && item.date.month == now.month,
        )
        .toList();
    final total = monthly.fold<int>(0, (sum, item) => sum + item.amount);
    final monthKey = now.year * 12 + now.month;
    final budget = ref.watch(monthlyBudgetProvider(monthKey)).valueOrNull;
    final budgetAvailable =
        ref.read(expenseRepositoryProvider) is BudgetRepository;
    final previous = DateTime(now.year, now.month - 1);
    final previousTotal = items
        .where(
          (item) =>
              item.date.year == previous.year &&
              item.date.month == previous.month,
        )
        .fold<int>(0, (sum, item) => sum + item.amount);
    final change = previousTotal > 0
        ? ((total - previousTotal) / previousTotal * 100).round()
        : null;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final monthLabel = context.l10n.monthYear(now.month, now.year);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        monthLabel,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Chip(label: Text(context.l10n.expenseRecords(monthly.length))),
                const SizedBox(height: 12),
                Text(
                  context.l10n.spentThisMonth.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatVnd(total),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                    letterSpacing: -1.3,
                  ),
                ),
                if (change != null && change != 0) ...[
                  const SizedBox(height: 12),
                  Chip(
                    avatar: Icon(
                      change > 0 ? Icons.trending_up : Icons.trending_down,
                      size: 18,
                    ),
                    label: Text(
                      change > 0
                          ? context.l10n.monthIncrease(change.abs())
                          : context.l10n.monthDecrease(change.abs()),
                    ),
                    backgroundColor: change > 0
                        ? scheme.errorContainer
                        : scheme.secondaryContainer,
                  ),
                ],
                if (budgetAvailable) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.monthlyBudget,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            _editBudget(context, ref, monthKey, budget),
                        child: Text(
                          budget == null
                              ? context.l10n.setBudget
                              : context.l10n.editBudget,
                        ),
                      ),
                    ],
                  ),
                  if (budget != null) ...[
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: (total / budget).clamp(0.0, 1.0),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      total <= budget
                          ? context.l10n.budgetRemaining(
                              formatVnd(budget - total),
                            )
                          : context.l10n.budgetExceeded(
                              formatVnd(total - budget),
                            ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          color: AppTheme.teal,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.addExpense,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.document_scanner_outlined,
                        label: context.l10n.scanOrImport,
                        onTap: () => context.go('/scan'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.edit_note_outlined,
                        label: context.l10n.manualEntry,
                        onTap: () => context.push(
                          '/review',
                          extra: const ReviewArgs(
                            draft: ParsedExpense.manual(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 20,
                color: scheme.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.localPrivacyHint,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.recentActivity,
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
        const SizedBox(height: 6),
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

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white.withValues(alpha: .13),
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              maxLines: 2,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}
