import 'package:flutter_test/flutter_test.dart';
import 'package:smart_expense_capture/models/expense_analytics.dart';
import 'package:smart_expense_capture/models/expense_item.dart';
import 'package:smart_expense_capture/models/expense_source.dart';

void main() {
  test(
    'selected month total and current week use verified transaction dates',
    () {
      ExpenseItem item(int amount, DateTime date) => ExpenseItem(
        merchant: 'Test',
        amount: amount,
        date: date,
        category: 'Other',
        source: ExpenseSource.receipt,
        createdAt: DateTime(2026, 2, 12),
        updatedAt: DateTime(2026, 2, 12),
      );
      final items = [
        item(100000, DateTime(2026, 1, 20)),
        item(33000, DateTime(2026, 2, 10)),
      ];
      final result = ExpenseAnalytics.fromItems(
        items,
        now: DateTime(2026, 2, 12),
        month: DateTime(2026, 1),
      );
      expect(result.total, 100000);
      expect(result.byCategory['Other'], 100000);
      expect(result.weekly[1], 33000);
    },
  );
}
