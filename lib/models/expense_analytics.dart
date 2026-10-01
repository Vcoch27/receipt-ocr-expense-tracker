import 'expense_item.dart';

class ExpenseAnalytics {
  const ExpenseAnalytics({
    required this.total,
    required this.byCategory,
    required this.weekly,
    required this.weekStart,
  });

  final int total;
  final Map<String, int> byCategory;
  final List<int> weekly;
  final DateTime weekStart;

  factory ExpenseAnalytics.fromItems(
    Iterable<ExpenseItem> items, {
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final start = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - 1));
    final categories = <String, int>{};
    final days = List<int>.filled(7, 0);
    var total = 0;
    for (final item in items) {
      total += item.amount;
      categories.update(
        item.category,
        (value) => value + item.amount,
        ifAbsent: () => item.amount,
      );
      final date = DateTime(item.date.year, item.date.month, item.date.day);
      final dayIndex = date.difference(start).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        days[dayIndex] += item.amount;
      }
    }
    return ExpenseAnalytics(
      total: total,
      byCategory: categories,
      weekly: days,
      weekStart: start,
    );
  }
}
