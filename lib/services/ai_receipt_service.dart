import 'dart:convert';
import 'dart:io';

import '../core/expense_validation.dart';
import '../models/parsed_expense.dart';

/// Optional, user-triggered second opinion. The Gemini key lives on the proxy.
abstract class AiReceiptService {
  bool get isAvailable;
  Future<AiExpenseSuggestion> suggest(ParsedExpense draft);
}

class AiExpenseSuggestion {
  const AiExpenseSuggestion({
    this.merchant,
    this.amount,
    this.date,
    this.note,
    this.transactionReference,
  });

  final String? merchant;
  final int? amount;
  final DateTime? date;
  final String? note;
  final String? transactionReference;

  bool get isEmpty =>
      merchant == null &&
      amount == null &&
      date == null &&
      note == null &&
      transactionReference == null;

  factory AiExpenseSuggestion.fromJson(Map<String, dynamic> json) {
    String? nonempty(Object? value) =>
        value is String && value.trim().isNotEmpty ? value.trim() : null;

    final rawAmount = json['amount'];
    final amount = rawAmount is int && rawAmount > 0 ? rawAmount : null;
    final rawDate = nonempty(json['date']);
    DateTime? date;
    if (rawDate != null) {
      final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(rawDate);
      if (match != null) {
        date = ExpenseValidation.dateTime(
          '${match[3]}/${match[2]}/${match[1]}',
        );
      }
    }
    return AiExpenseSuggestion(
      merchant: nonempty(json['merchant']),
      amount: amount,
      date: date,
      note: nonempty(json['note']),
      transactionReference: nonempty(json['transactionReference']),
    );
  }
}

class ProxyAiReceiptService implements AiReceiptService {
  const ProxyAiReceiptService(this.endpoint);

  final String endpoint;

  @override
  bool get isAvailable => endpoint.isNotEmpty;

  @override
  Future<AiExpenseSuggestion> suggest(ParsedExpense draft) async {
    if (!isAvailable || draft.imagePath == null) {
      throw const AiReceiptException('AI reader is unavailable');
    }
    final lowerPath = draft.imagePath!.toLowerCase();
    if (!lowerPath.endsWith('.jpg') &&
        !lowerPath.endsWith('.jpeg') &&
        !lowerPath.endsWith('.png')) {
      throw const AiReceiptException('Unsupported image format');
    }
    final uri = Uri.parse(endpoint);
    if (uri.scheme != 'https' &&
        !(uri.scheme == 'http' &&
            (uri.host == '127.0.0.1' || uri.host == 'localhost'))) {
      throw const AiReceiptException('A secure AI proxy URL is required');
    }
    final image = File(draft.imagePath!);
    final bytes = await image.readAsBytes();
    if (bytes.isEmpty || bytes.length > 6 * 1024 * 1024) {
      throw const AiReceiptException('Image is empty or too large');
    }
    final mimeType = lowerPath.endsWith('.png') ? 'image/png' : 'image/jpeg';
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client
          .postUrl(uri)
          .timeout(const Duration(seconds: 12));
      request.headers.contentType = ContentType.json;
      request.add(
        utf8.encode(
          jsonEncode({
            'imageBase64': base64Encode(bytes),
            'mimeType': mimeType,
            'rawText': draft.rawText.substring(
              0,
              draft.rawText.length.clamp(0, 12000),
            ),
            'source': draft.source.name,
          }),
        ),
      );
      final response = await request.close().timeout(
        const Duration(seconds: 40),
      );
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode != HttpStatus.ok) {
        throw AiReceiptException('AI proxy returned ${response.statusCode}');
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const AiReceiptException('Invalid AI response');
      }
      return AiExpenseSuggestion.fromJson(decoded);
    } finally {
      client.close(force: true);
    }
  }
}

class AiReceiptException implements Exception {
  const AiReceiptException(this.message);
  final String message;
  @override
  String toString() => message;
}
