import '../models/parsed_receipt.dart';
import 'text_normalization.dart';

/// Conservative OCR parsing: uncertain fields remain null for manual review.
class ReceiptParser {
  const ReceiptParser();

  static final _numbers = RegExp(r'(?<!\d)\d+(?:[.,]\d+)*(?!\d)');
  static final _dateDmy = RegExp(
    r'(?<!\d)(\d{1,2})[\/.\-](\d{1,2})[\/.\-](\d{4})(?!\d)',
  );
  static final _dateYmd = RegExp(
    r'(?<!\d)(\d{4})[\/.\-](\d{1,2})[\/.\-](\d{1,2})(?!\d)',
  );

  ParsedReceipt parse(String rawText, {String? imagePath}) {
    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim().replaceAll(RegExp(r'\s+'), ' '))
        .where((line) => line.isNotEmpty)
        .toList();
    return ParsedReceipt(
      merchant: _merchant(lines),
      date: _date(lines),
      total: _total(lines),
      rawText: rawText,
      imagePath: imagePath,
    );
  }

  int? _total(List<String> lines) {
    final candidates = <({int amount, int score})>[];
    for (var i = 0; i < lines.length; i++) {
      final normalized = foldVietnamese(lines[i]);
      final isTotal = RegExp(
        r'\b(total|tong tien|thanh toan|cong tien|amount due)\b',
      ).hasMatch(normalized);
      if (!isTotal) continue;
      final score =
          normalized.contains('tong tien') || normalized.contains('amount due')
          ? 3
          : 2;
      for (final amount in _amounts(lines[i])) {
        candidates.add((amount: amount, score: score + 1));
      }
      // OCR often puts the label and amount on separate adjacent lines.
      if (i + 1 < lines.length &&
          !_dateDmy.hasMatch(lines[i + 1]) &&
          !_dateYmd.hasMatch(lines[i + 1])) {
        for (final amount in _amounts(lines[i + 1])) {
          candidates.add((amount: amount, score: score));
        }
      }
    }
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : b.amount.compareTo(a.amount);
    });
    return candidates.first.amount;
  }

  Iterable<int> _amounts(String line) sync* {
    for (final match in _numbers.allMatches(line)) {
      final value = parseVnd(match.group(0)!);
      if (value != null && value > 0) yield value;
    }
  }

  /// Parse an integer VND amount without guessing ambiguous decimals.
  static int? parseVnd(String text) {
    var value = text.trim().replaceAll(
      RegExp(r'\s*(VNĐ|VND|₫|đ)$', caseSensitive: false),
      '',
    );
    if (RegExp(r'^\d+$').hasMatch(value)) return int.tryParse(value);
    if (RegExp(r'^\d{1,3}([.,]\d{3})+$').hasMatch(value)) {
      return int.tryParse(value.replaceAll(RegExp(r'[.,]'), ''));
    }
    // Some receipts print whole VND followed by a zero decimal suffix.
    if (RegExp(r'^\d{1,3}([.,]\d{3})+[.,]00$').hasMatch(value)) {
      value = value.substring(0, value.length - 3);
      return int.tryParse(value.replaceAll(RegExp(r'[.,]'), ''));
    }
    return null;
  }

  DateTime? _date(List<String> lines) {
    // Prefer a date-labelled line; otherwise accept the first valid date.
    final ordered = [...lines]
      ..sort((a, b) {
        final aLabel =
            foldVietnamese(a).contains('ngay') ||
            foldVietnamese(a).contains('date');
        final bLabel =
            foldVietnamese(b).contains('ngay') ||
            foldVietnamese(b).contains('date');
        return (bLabel ? 1 : 0).compareTo(aLabel ? 1 : 0);
      });
    for (final line in ordered) {
      final dmy = _dateDmy.firstMatch(line);
      if (dmy != null) {
        final date = _checkedDate(
          int.parse(dmy[3]!),
          int.parse(dmy[2]!),
          int.parse(dmy[1]!),
        );
        if (date != null) return date;
      }
      final ymd = _dateYmd.firstMatch(line);
      if (ymd != null) {
        final date = _checkedDate(
          int.parse(ymd[1]!),
          int.parse(ymd[2]!),
          int.parse(ymd[3]!),
        );
        if (date != null) return date;
      }
    }
    return null;
  }

  static DateTime? _checkedDate(int year, int month, int day) {
    if (year < 2000 ||
        year > 2100 ||
        month < 1 ||
        month > 12 ||
        day < 1 ||
        day > 31) {
      return null;
    }
    final date = DateTime(year, month, day);
    return date.year == year && date.month == month && date.day == day
        ? date
        : null;
  }

  String? _merchant(List<String> lines) {
    for (final line in lines.take(6)) {
      final folded = foldVietnamese(line);
      if (line.length < 3 || line.length > 70) continue;
      if (!RegExp(r'[a-zA-ZÀ-ỹ]').hasMatch(line)) continue;
      if (RegExp(r'\d{4,}').hasMatch(line)) continue;
      if (RegExp(
        r'\b(hoa don|receipt|invoice|ngay|date|dia chi|address|tel|phone|mst|ma so thue|total|tong tien|thanh toan)\b',
      ).hasMatch(folded)) {
        continue;
      }
      return line;
    }
    return null;
  }
}
