import '../models/parsed_receipt.dart';
import 'text_normalization.dart';

/// Conservative OCR parsing: uncertain fields remain null for manual review.
class ReceiptParser {
  const ReceiptParser();

  // ML Kit may insert a space inside a thousands group, e.g. `537, 000`.
  static final _numbers = RegExp(r'(?<!\d)\d+(?:[.,]\s*[\dOo]+)*(?!\d)');
  static final _standaloneAmount = RegExp(
    r'^\d+(?:[.,]\s*[\dOo]+)*(?:\s*(?:VNĐ|VND|₫|đ))?$',
    caseSensitive: false,
  );
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
    final cues = <({int index, int priority})>[];
    for (var i = 0; i < lines.length; i++) {
      final normalized = foldVietnamese(lines[i]);
      final priority = _totalPriority(normalized);
      if (priority != null) cues.add((index: i, priority: priority));
    }
    if (cues.isEmpty) return null;
    final highestPriority = cues
        .map((cue) => cue.priority)
        .reduce((a, b) => a > b ? a : b);
    final strongest = cues.where((cue) => cue.priority == highestPriority);
    for (final cue in strongest.toList().reversed) {
      final inline = _amounts(lines[cue.index]).toList();
      if (inline.isNotEmpty) return inline.reduce((a, b) => a > b ? a : b);
      if (cue.index + 1 < lines.length &&
          _standaloneAmount.hasMatch(lines[cue.index + 1])) {
        final adjacent = _amounts(lines[cue.index + 1]).toList();
        if (adjacent.isNotEmpty) return adjacent.last;
      }
    }

    // ML Kit often reads a receipt's text column before its price column.
    // A final payable label can therefore precede a whole block of prices.
    // Accept the trailing amount only when it is the largest plausible amount
    // in that block; otherwise keep the field blank for human review.
    final lastCue = strongest.last.index;
    final trailing = <int>[];
    for (final line in lines.skip(lastCue + 1)) {
      if (_standaloneAmount.hasMatch(line)) {
        trailing.addAll(_amounts(line).where((amount) => amount >= 1000));
      }
    }
    if (trailing.isEmpty) return null;
    final last = trailing.last;
    return last == trailing.reduce((a, b) => a > b ? a : b) ? last : null;
  }

  int? _totalPriority(String line) {
    if (RegExp(r'\b(tong hoa don|khach phai tra|grand total|amount due)\b')
        .hasMatch(line)) {
      return 5;
    }
    if (RegExp(r'\b(total|tong tien|thanh toan|cong tien)\b').hasMatch(line) &&
        !line.contains('tong tien hang') &&
        !line.contains('tong tien gio')) {
      return 4;
    }
    if (RegExp(r'\b(tong tien hang|tong dich vu|tong tien gio)\b')
        .hasMatch(line)) {
      return 2;
    }
    if (RegExp(r'\btien mat\b').hasMatch(line) &&
        !line.contains('tien khach dua')) {
      return 1;
    }
    return null;
  }

  Iterable<int> _amounts(String line) sync* {
    for (final match in _numbers.allMatches(line)) {
      final raw = match.group(0)!;
      // Leading-zero identifiers are not VND totals.
      if (raw.startsWith('0') &&
          raw.replaceAll(RegExp(r'\D'), '').length >= 6) {
        continue;
      }
      final value = parseVnd(raw);
      if (value != null && value > 0) yield value;
    }
  }

  /// Parse an integer VND amount without guessing ambiguous decimals.
  static int? parseVnd(String text) {
    var value = text.trim().replaceAll(
      RegExp(r'\s*(VNĐ|VND|₫|đ)$', caseSensitive: false),
      '',
    );
    // Only correct the common OCR O/0 confusion inside complete three-digit
    // thousands groups. A free-standing O or ambiguous decimal stays invalid.
    if (RegExp(r'^\d{1,3}(?:[.,]\s*[\dOo]{3})+$').hasMatch(value)) {
      value = value.replaceAll(RegExp(r'[Oo]'), '0');
    }
    value = value.replaceAllMapped(RegExp(r'([.,])\s+'), (match) => match[1]!);
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
    // Many receipts put the shop in the header. Some column-ordered OCR output
    // starts with an address and moves the brand after “Hóa đơn bán hàng”.
    for (final line in lines.take(4)) {
      if (_isMerchantLine(line)) return line;
    }
    final invoiceIndex = lines.indexWhere(
      (line) =>
          RegExp(r'\b(hoa don|receipt|invoice)\b')
              .hasMatch(foldVietnamese(line)),
    );
    if (invoiceIndex >= 0) {
      for (final line in lines.skip(invoiceIndex + 1).take(6)) {
        if (_isMerchantLine(line)) return line;
      }
    }
    for (final line in lines.take(20)) {
      if (_isMerchantLine(line)) return line;
    }
    return null;
  }

  bool _isMerchantLine(String line) {
    final folded = foldVietnamese(line);
    if (line.length < 3 || line.length > 70 || line.endsWith(',')) return false;
    if (!RegExp(r'[a-zA-ZÀ-ỹ]').hasMatch(line)) return false;
    if (RegExp(r'\d{4,}').hasMatch(line)) return false;
    if (RegExp(
      r'\b(hoa don|receipt|invoice|ngay|date|dia chi|address|tel|phone|mst|ma so thue|total|tong tien|thanh toan|tien mat|khach phai tra|phi giao hang|chiet khau|tong so luong|tien tra lai)\b',
    ).hasMatch(folded)) {
      return false;
    }
    if (RegExp(r'^(thon|xa|huyen|phuong|thanh pho|duong)\b').hasMatch(folded) ||
        RegExp(r'\b(xa|huyen|thanh pho)\b').hasMatch(folded)) {
      return false;
    }
    return true;
  }
}
