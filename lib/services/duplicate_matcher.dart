import '../models/expense_item.dart';
import 'text_normalization.dart';

class DuplicateMatcher {
  const DuplicateMatcher();

  ExpenseItem? find(ExpenseItem candidate, Iterable<ExpenseItem> existing) {
    for (final item in existing) {
      if (item.id == candidate.id || item.source != candidate.source) continue;
      final aRef = candidate.transactionReference?.trim().toLowerCase();
      final bRef = item.transactionReference?.trim().toLowerCase();
      if (aRef != null && aRef.isNotEmpty && aRef == bRef) return item;
      if (item.amount == candidate.amount &&
          item.date.year == candidate.date.year &&
          item.date.month == candidate.date.month &&
          item.date.day == candidate.date.day &&
          foldVietnamese(item.merchant.trim()) ==
              foldVietnamese(candidate.merchant.trim())) {
        return item;
      }
    }
    return null;
  }
}
