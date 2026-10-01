import '../models/expense_source.dart';
import '../models/parsed_expense.dart';
import 'expense_source_classifier.dart';
import 'receipt_parser.dart';
import 'text_normalization.dart';

class PaymentScreenshotParser {
  const PaymentScreenshotParser(this.classifier);

  final ExpenseSourceClassifier classifier;

  static final _number = RegExp(r'(?<!\d)\d+(?:[.,]\d+)*(?!\d)');
  static final _dateDmy = RegExp(
    r'(?<!\d)(\d{1,2})[\/.\-](\d{1,2})[\/.\-](\d{4})(?!\d)',
  );
  static final _dateYmd = RegExp(
    r'(?<!\d)(\d{4})[\/.\-](\d{1,2})[\/.\-](\d{1,2})(?!\d)',
  );
  static final _time = RegExp(r'(?<!\d)([01]?\d|2[0-3]):([0-5]\d)(?!\d)');

  ParsedExpense parse(String rawText, {String? imagePath}) {
    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim().replaceAll(RegExp(r'\s+'), ' '))
        .where((line) => line.isNotEmpty)
        .toList();
    return ParsedExpense(
      source: classifier.classifyPayment(rawText),
      merchant: _recipient(lines),
      amount: _amount(lines),
      date: _dateTime(lines),
      status: _status(rawText),
      paymentProvider: _provider(rawText),
      transactionReference: _reference(lines),
      note: _note(lines),
      rawText: rawText,
      imagePath: imagePath,
    );
  }

  PaymentStatus _status(String text) {
    final folded = foldVietnamese(text);
    if (RegExp(
      r'(that bai|khong thanh cong|khong thanh toan|bi huy|giao dich loi|failed|unsuccessful|cancelled)',
    ).hasMatch(folded)) {
      return PaymentStatus.failed;
    }
    if (RegExp(
      r'(dang xu ly|cho xu ly|dang cho|pending|processing|in progress)',
    ).hasMatch(folded)) {
      return PaymentStatus.pending;
    }
    if (RegExp(r'(thanh cong|hoan tat|completed|success|successful)')
        .hasMatch(folded)) {
      return PaymentStatus.successful;
    }
    return PaymentStatus.unknown;
  }

  int? _amount(List<String> lines) {
    final candidates = <({int value, int score})>[];
    for (var i = 0; i < lines.length; i++) {
      final folded = foldVietnamese(lines[i]);
      final labelled = RegExp(
        r'\b(so tien|tong tien|amount|da thanh toan|so tien chuyen|gia tri giao dich)\b',
      ).hasMatch(folded);
      final currency = RegExp(
        r'(vn[dđ]|[₫đ])',
        caseSensitive: false,
      ).hasMatch(lines[i]);
      if (!labelled && !currency) continue;
      final score = labelled ? 3 : 1;
      for (final value in _amounts(lines[i])) {
        candidates.add((value: value, score: score + (currency ? 1 : 0)));
      }
      if (labelled && i + 1 < lines.length) {
        for (final value in _amounts(lines[i + 1])) {
          candidates.add((value: value, score: 2));
        }
      }
    }
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final score = b.score.compareTo(a.score);
      return score != 0 ? score : b.value.compareTo(a.value);
    });
    return candidates.first.value;
  }

  Iterable<int> _amounts(String line) sync* {
    for (final match in _number.allMatches(line)) {
      final value = ReceiptParser.parseVnd(match.group(0)!);
      // Exclude small date/time pieces and implausible 1-2 digit amounts.
      if (value != null && value >= 100) yield value;
    }
  }

  DateTime? _dateTime(List<String> lines) {
    for (final line in lines) {
      final dmy = _dateDmy.firstMatch(line);
      final ymd = _dateYmd.firstMatch(line);
      if (dmy == null && ymd == null) continue;
      final match = dmy ?? ymd!;
      final year = int.parse(match[dmy == null ? 1 : 3]!);
      final month = int.parse(match[2]!);
      final day = int.parse(match[dmy == null ? 3 : 1]!);
      if (year < 2000 ||
          year > 2100 ||
          month < 1 ||
          month > 12 ||
          day < 1 ||
          day > 31) {
        continue;
      }
      final time =
          _time.firstMatch(line) ??
          lines.map(_time.firstMatch).whereType<RegExpMatch>().firstOrNull;
      final hour = time == null ? 0 : int.parse(time[1]!);
      final minute = time == null ? 0 : int.parse(time[2]!);
      final date = DateTime(year, month, day, hour, minute);
      if (date.year == year && date.month == month && date.day == day) {
        return date;
      }
    }
    return null;
  }

  String? _recipient(List<String> lines) {
    final label = RegExp(
      r'\b(nguoi nhan|nguoi thu huong|den|recipient|receiver|beneficiary)\b',
    );
    for (var i = 0; i < lines.length; i++) {
      final folded = foldVietnamese(lines[i]);
      final match = label.firstMatch(folded);
      if (match == null) continue;
      final inline = lines[i]
          .substring(match.end)
          .replaceFirst(RegExp(r'^[\s:–\-]+'), '')
          .trim();
      final candidate = inline.isNotEmpty
          ? inline
          : i + 1 < lines.length
          ? lines[i + 1]
          : '';
      if (_isName(candidate)) return candidate;
    }
    // Some bank confirmation screens show an unlabeled recipient immediately
    // below the transaction timestamp. Limit this guess to that small region.
    final dateIndex = lines.indexWhere(
      (line) => _dateDmy.hasMatch(line) || _dateYmd.hasMatch(line),
    );
    if (dateIndex >= 0) {
      final end = (dateIndex + 5).clamp(0, lines.length);
      for (var i = dateIndex + 1; i < end; i++) {
        if (_isUnlabelledName(lines[i])) return lines[i];
      }
    }
    return null;
  }

  bool _isUnlabelledName(String value) {
    final folded = foldVietnamese(value);
    if (value.length < 5 || value.length > 60 || value != value.toUpperCase()) {
      return false;
    }
    if (!RegExp(r'^[A-Za-zÀ-ỹ]+(?: [A-Za-zÀ-ỹ]+){1,5}$').hasMatch(value)) {
      return false;
    }
    return !RegExp(
      r'\b(chuyen|thanh cong|giao dich|cam on|ngan hang|bank|vnd|tien|sieu loi|mb|bidv)\b',
    ).hasMatch(folded);
  }

  bool _isName(String value) =>
      value.length >= 2 &&
      RegExp(r'[a-zA-ZÀ-ỹ]').hasMatch(value) &&
      !RegExp(r'\d{4,}').hasMatch(value);

  String? _provider(String text) {
    if (RegExp(
      r'\b(mbbank|mb bank|mb transfer)\b',
      caseSensitive: false,
    ).hasMatch(text)) {
      return 'MB Bank';
    }
    const names = [
      'MoMo',
      'ZaloPay',
      'VNPay',
      'ShopeePay',
      'Vietcombank',
      'BIDV',
      'MB Bank',
      'Techcombank',
      'VietinBank',
      'ACB',
      'TPBank',
      'VPBank',
      'Sacombank',
    ];
    for (final name in names) {
      if (text.toLowerCase().contains(name.toLowerCase())) return name;
    }
    return null;
  }

  String? _reference(List<String> lines) {
    final label = RegExp(
      r'\b(ma giao dich|ma tham chieu|transaction id|reference|trans id)\b',
    );
    for (var i = 0; i < lines.length; i++) {
      final match = label.firstMatch(foldVietnamese(lines[i]));
      if (match == null) continue;
      final value = lines[i]
          .substring(match.end)
          .replaceFirst(RegExp(r'^[\s:#–\-]+'), '')
          .trim();
      final candidate = value.isNotEmpty
          ? value
          : i + 1 < lines.length
          ? lines[i + 1]
          : '';
      if (RegExp(r'^[A-Za-z0-9\-]{5,40}$').hasMatch(candidate)) {
        return candidate;
      }
    }
    return null;
  }

  String? _note(List<String> lines) {
    final label = RegExp(
      r'\b(noi dung(?: chuyen khoan| giao dich)?|ghi chu|dien giai|description|message)\b',
    );
    for (var i = 0; i < lines.length; i++) {
      final match = label.firstMatch(foldVietnamese(lines[i]));
      if (match == null) continue;
      final value = lines[i]
          .substring(match.end)
          .replaceFirst(RegExp(r'^[\s:–\-]+'), '')
          .trim();
      if (value.isNotEmpty && value.length <= 120) return value;
      if (i + 1 < lines.length && _isTransferNote(lines[i + 1])) {
        return lines[i + 1];
      }
    }
    for (final line in lines) {
      final folded = foldVietnamese(line);
      if (RegExp(r'\bchuyen tien\b').hasMatch(folded) &&
          !RegExp(r'\b(thanh cong|that bai|dang xu ly)\b').hasMatch(folded) &&
          _isTransferNote(line)) {
        return line;
      }
    }
    // On compact confirmation screens the transfer description follows a
    // destination account number. Never include that number in the note.
    for (var i = 0; i + 1 < lines.length; i++) {
      if (RegExp(r'^\d{8,16}$').hasMatch(lines[i]) &&
          _isTransferNote(lines[i + 1])) {
        return lines[i + 1];
      }
    }
    return null;
  }

  bool _isTransferNote(String value) {
    final folded = foldVietnamese(value);
    return value.length >= 5 &&
        value.length <= 120 &&
        RegExp(r'[A-Za-zÀ-ỹ]').hasMatch(value) &&
        !RegExp(
          r'\b(cam on|dich vu|giao dich|luu anh|luu mau|chia se|saved image|message|ngan hang|bank|vnd|sieu loi|top 1)\b',
        ).hasMatch(folded);
  }
}
