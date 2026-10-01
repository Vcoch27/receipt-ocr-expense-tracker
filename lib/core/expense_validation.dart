import '../services/receipt_parser.dart';

class ExpenseValidation {
  const ExpenseValidation._();

  static int? amount(String text) {
    final value = ReceiptParser.parseVnd(text.trim());
    return value != null && value > 0 ? value : null;
  }

  static DateTime? dateTime(String dateText, [String? timeText]) {
    final match = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$')
        .firstMatch(dateText.trim());
    if (match == null) return null;
    final day = int.parse(match[1]!);
    final month = int.parse(match[2]!);
    final year = int.parse(match[3]!);
    if (year < 2000 || year > 2100 || month < 1 || month > 12) return null;
    var hour = 0;
    var minute = 0;
    if (timeText != null && timeText.trim().isNotEmpty) {
      final time = RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$')
          .firstMatch(timeText.trim());
      if (time == null) return null;
      hour = int.parse(time[1]!);
      minute = int.parse(time[2]!);
    }
    final date = DateTime(year, month, day, hour, minute);
    return date.year == year && date.month == month && date.day == day
        ? date
        : null;
  }
}
