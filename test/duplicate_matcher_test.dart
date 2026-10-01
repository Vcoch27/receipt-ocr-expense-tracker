import 'package:flutter_test/flutter_test.dart';
import 'package:smart_expense_capture/models/expense_analytics.dart';
import 'package:smart_expense_capture/models/expense_item.dart';
import 'package:smart_expense_capture/models/expense_source.dart';
import 'package:smart_expense_capture/services/duplicate_matcher.dart';

ExpenseItem expense({
  int? id,
  String merchant = 'Mai An',
  int amount = 150000,
  ExpenseSource source = ExpenseSource.bankScreenshot,
  String? reference,
}) => ExpenseItem(
  id: id,
  merchant: merchant,
  amount: amount,
  date: DateTime(2026, 10, 1),
  category: 'Shopping',
  source: source,
  transactionReference: reference,
  createdAt: DateTime(2026, 10, 1),
  updatedAt: DateTime(2026, 10, 1),
);

void main() {
  const matcher = DuplicateMatcher();

  test('warns on duplicate screenshot reference', () {
    final existing = expense(id: 1, reference: 'FT123456');
    final candidate = expense(
      amount: 175000,
      merchant: 'OCR typo',
      reference: 'ft123456',
    );
    expect(matcher.find(candidate, [existing]), same(existing));
  });

  test('warns on matching amount/date/recipient/source', () {
    final existing = expense(id: 1, merchant: 'Mai An');
    final candidate = expense(merchant: 'MAI AN');
    expect(matcher.find(candidate, [existing]), same(existing));
  });

  test('does not block different sources or editing the same record', () {
    final existing = expense(id: 1);
    expect(
      matcher.find(expense(source: ExpenseSource.receipt), [existing]),
      isNull,
    );
    expect(matcher.find(expense(id: 1), [existing]), isNull);
  });

  test('all sources contribute to common category and weekly totals', () {
    final analytics = ExpenseAnalytics.fromItems([
      expense(id: 1, source: ExpenseSource.receipt),
      expense(id: 2, source: ExpenseSource.eWalletScreenshot, amount: 220000),
      expense(id: 3, source: ExpenseSource.manual, amount: 50000),
    ], now: DateTime(2026, 10, 1));
    expect(analytics.total, 420000);
    expect(analytics.byCategory['Shopping'], 420000);
    expect(analytics.weekly.fold<int>(0, (a, b) => a + b), 420000);
  });
}
