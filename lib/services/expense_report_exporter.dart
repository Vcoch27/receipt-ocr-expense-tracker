import '../core/formatters.dart';
import '../models/expense_item.dart';
import '../models/expense_source.dart';

/// Builds an Excel-friendly CSV from verified records only.
class ExpenseReportExporter {
  const ExpenseReportExporter._();

  static String csv(
    Iterable<ExpenseItem> items, {
    required List<String> headers,
    required String Function(String) categoryLabel,
    required String Function(ExpenseSource) sourceLabel,
  }) {
    if (headers.length != 8) {
      throw ArgumentError.value(headers.length, 'headers');
    }
    final rows = <List<String>>[
      headers,
      for (final item in items)
        [
          formatDate(item.date),
          item.merchant,
          item.amount.toString(),
          categoryLabel(item.category),
          sourceLabel(item.source),
          item.paymentProvider ?? '',
          item.transactionReference ?? '',
          item.note ?? '',
        ],
    ];
    return '\uFEFF${rows.map((row) => row.map(_cell).join(',')).join('\r\n')}\r\n';
  }

  static String _cell(String input) {
    var value = input.replaceAll('\r\n', '\n');
    // Spreadsheet apps can execute text starting with formula characters.
    if (RegExp(r'^\s*[=+\-@]').hasMatch(value)) value = "'$value";
    return '"${value.replaceAll('"', '""')}"';
  }
}
