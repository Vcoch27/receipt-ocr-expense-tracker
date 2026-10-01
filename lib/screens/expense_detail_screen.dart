import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/formatters.dart';
import '../l10n/expense_labels.dart';
import '../l10n/l10n.dart';
import '../models/expense_item.dart';
import '../models/expense_source.dart';
import '../routing/app_router.dart';
import '../state/expense_providers.dart';
import '../widgets/expense_state.dart';
import '../widgets/page_container.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  const ExpenseDetailScreen({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.expenseDetails)),
      body: PageContainer(
        child: expenses.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => ExpenseState(
            icon: Icons.error_outline,
            title: context.l10n.couldNotLoadExpense,
            message: context.l10n.retryHint,
          ),
          data: (items) {
            ExpenseItem? item;
            for (final candidate in items) {
              if (candidate.id == id) {
                item = candidate;
                break;
              }
            }
            if (item == null) {
              return ExpenseState(
                icon: Icons.search_off_outlined,
                title: context.l10n.expenseNotFound,
                message: context.l10n.mayHaveBeenDeleted,
              );
            }
            return _Detail(item: item);
          },
        ),
      ),
    );
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.item});
  final ExpenseItem item;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.deleteExpenseQuestion),
        content: Text(context.l10n.deleteExpenseHint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(expensesProvider.notifier).deleteExpense(item);
      if (context.mounted) context.go('/expenses');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.deleteFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPayment =
        item.source == ExpenseSource.bankScreenshot ||
        item.source == ExpenseSource.eWalletScreenshot;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(item.merchant, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          formatVnd(item.amount),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DetailRow(
                  label: context.l10n.date,
                  value: formatDate(item.date),
                ),
                _DetailRow(
                  label: context.l10n.source,
                  value: localizedSource(context, item.source),
                ),
                _DetailRow(
                  label: context.l10n.category,
                  value: localizedCategory(context, item.category),
                ),
                if (isPayment && item.date.hour + item.date.minute > 0)
                  _DetailRow(
                    label: context.l10n.time,
                    value:
                        '${item.date.hour.toString().padLeft(2, '0')}:${item.date.minute.toString().padLeft(2, '0')}',
                  ),
                if (item.paymentProvider?.isNotEmpty == true)
                  _DetailRow(
                    label: context.l10n.provider,
                    value: item.paymentProvider!,
                  ),
                if (item.transactionReference?.isNotEmpty == true)
                  _DetailRow(
                    label: context.l10n.reference,
                    value: item.transactionReference!,
                  ),
                if (item.note?.isNotEmpty == true)
                  _DetailRow(label: context.l10n.note, value: item.note!),
              ],
            ),
          ),
        ),
        if (item.imagePath != null) ...[
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(item.imagePath!),
              height: 240,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => ExpenseState(
                icon: Icons.broken_image_outlined,
                title: context.l10n.imageUnavailable,
                message: context.l10n.savedRecordUsable,
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () =>
              context.push('/review', extra: ReviewArgs(existing: item)),
          icon: const Icon(Icons.edit_outlined),
          label: Text(context.l10n.editExpense),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _delete(context, ref),
          icon: const Icon(Icons.delete_outline),
          label: Text(context.l10n.deleteExpense),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
