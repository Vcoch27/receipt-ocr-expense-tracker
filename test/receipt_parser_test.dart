import 'package:flutter_test/flutter_test.dart';
import 'package:smart_expense_capture/services/receipt_parser.dart';

void main() {
  const parser = ReceiptParser();

  test('extracts accented Vietnamese total, merchant, and date', () {
    final result = parser.parse(
      'CỬA HÀNG MINH AN\nHÓA ĐƠN BÁN HÀNG\nNgày: 01/10/2026\nTổng tiền: 150.000 đ',
    );
    expect(result.merchant, 'CỬA HÀNG MINH AN');
    expect(result.date, DateTime(2026, 10, 1));
    expect(result.total, 150000);
  });

  test('handles comma thousands and unaccented keyword', () {
    expect(
      parser.parse('ABC MART\nNgay 02/10/2026\nTong tien 150,000 VNĐ').total,
      150000,
    );
  });

  test('handles ungrouped amount and payment keyword', () {
    expect(parser.parse('SHOP TEST\nThanh toan 150000').total, 150000);
  });

  test('handles amount on the line after total label', () {
    expect(parser.parse('SHOP TEST\nCộng tiền\n150.000').total, 150000);
  });

  test('leaves total null without a reliable total cue', () {
    expect(parser.parse('SHOP TEST\nSản phẩm A 150.000').total, isNull);
  });

  test('leaves malformed OCR fields null', () {
    final result = parser.parse('###\n***\nTOTAL: OOO.OOO\n32/13/2026');
    expect(result.merchant, isNull);
    expect(result.total, isNull);
    expect(result.date, isNull);
  });

  test('rejects invalid dates rather than normalizing them', () {
    expect(
      parser.parse('SHOP TEST\nNgày 31/02/2026\nTotal 10.000').date,
      isNull,
    );
  });

  test('parses common whole-VND formats', () {
    for (final format in [
      '150000',
      '150.000',
      '150,000',
      '150.000 đ',
      '150,000 VNĐ',
    ]) {
      expect(ReceiptParser.parseVnd(format), 150000, reason: format);
    }
    expect(ReceiptParser.parseVnd('150,50'), isNull);
  });
}
