import 'package:flutter/material.dart';

import '../core/categories.dart';
import '../core/formatters.dart';
import '../l10n/expense_labels.dart';
import '../models/expense_item.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.item, required this.onTap});
  final ExpenseItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        key: ValueKey('expense_${item.id}'),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: categoryColor(item.category).withValues(alpha: .14),
          child: Icon(
            Icons.payments_outlined,
            color: categoryColor(item.category),
          ),
        ),
        title: Text(
          item.merchant,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${formatDate(item.date)} · ${localizedSource(context, item.source)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatVnd(item.amount),
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              localizedCategory(context, item.category),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
