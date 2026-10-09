import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_expense_capture/models/expense_source.dart';
import 'package:smart_expense_capture/models/parsed_expense.dart';
import 'package:smart_expense_capture/services/ai_receipt_service.dart';

void main() {
  test('accepts grounded fields and a valid ISO date', () {
    final result = AiExpenseSuggestion.fromJson({
      'merchant': '  Quán Cà Phê ',
      'amount': 150000,
      'date': '2026-10-09',
      'note': 'Cà phê',
    });
    expect(result.merchant, 'Quán Cà Phê');
    expect(result.amount, 150000);
    expect(result.date, DateTime(2026, 10, 9));
    expect(result.note, 'Cà phê');
  });

  test('rejects fabricated-looking or invalid values', () {
    final result = AiExpenseSuggestion.fromJson({
      'merchant': '',
      'amount': '150.000',
      'date': '2026-02-30',
      'note': null,
    });
    expect(result.isEmpty, isTrue);
  });

  test('sends a picked WebP image to the local proxy', () async {
    final directory = await Directory.systemTemp.createTemp('ai-receipt-test');
    final image = File('${directory.path}/receipt.webp');
    const imageBytes = [82, 73, 70, 70, 4, 0, 0, 0, 87, 69, 66, 80];
    await image.writeAsBytes(imageBytes);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() async {
      await server.close(force: true);
      await directory.delete(recursive: true);
    });
    final requestHandled = server.first.then((request) async {
      final body = jsonDecode(
        await utf8.decoder.bind(request).join(),
      ) as Map<String, dynamic>;
      expect(body['mimeType'], 'image/webp');
      expect(body['rawText'], 'Tổng tiền 150.000');
      expect(body['source'], 'receipt');
      expect(base64Decode(body['imageBase64'] as String), imageBytes);
      request.response.headers.contentType = ContentType.json;
      request.response.write(
        jsonEncode({
          'merchant': 'Test Shop',
          'amount': 150000,
          'date': '2026-10-09',
        }),
      );
      await request.response.close();
    });
    final client = ProxyAiReceiptService(
      'http://127.0.0.1:${server.port}/analyze',
    );
    final suggestion = await client.suggest(
      ParsedExpense(
        source: ExpenseSource.receipt,
        rawText: 'Tổng tiền 150.000',
        imagePath: image.path,
      ),
    );
    await requestHandled;
    expect(suggestion.amount, 150000);
    expect(suggestion.merchant, 'Test Shop');
  });

  test('uses JPEG MIME for JPEG bytes in a .webp picker cache file', () async {
    final directory = await Directory.systemTemp.createTemp('ai-picker-test');
    final image = File('${directory.path}/scaled_receipt.webp');
    await image.writeAsBytes([0xff, 0xd8, 0xff, 0xe1, 0, 0]);
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() async {
      await server.close(force: true);
      await directory.delete(recursive: true);
    });
    final requestHandled = server.first.then((request) async {
      final body = jsonDecode(
        await utf8.decoder.bind(request).join(),
      ) as Map<String, dynamic>;
      expect(body['mimeType'], 'image/jpeg');
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'merchant': 'Test Shop'}));
      await request.response.close();
    });
    final service = ProxyAiReceiptService(
      'http://127.0.0.1:${server.port}/analyze',
    );
    final result = await service.suggest(
      ParsedExpense(
        source: ExpenseSource.receipt,
        rawText: '',
        imagePath: image.path,
      ),
    );
    await requestHandled;
    expect(result.merchant, 'Test Shop');
  });
}
