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

  test('finds a final invoice total when ML Kit reads price columns last', () {
    final result = parser.parse(
      'BIDA SAMPLE\nTổng dịch vụ:\nTổng tiền giờ:\nTổng hóa đơn:\n'
      'Giá\n20.000\n25.000\nTổng\n40.000\n125.000\n11.000\n136.000',
    );
    expect(result.total, 136000);
  });

  test('prioritizes customer payable over item subtotal', () {
    final result = parser.parse(
      'SHOP TEST\nTổng tiền hàng\nKhách phải trả\nTiền khách đưa\n'
      '900,000\n35,000\n935,000\n935,000',
    );
    expect(result.total, 935000);
  });

  test(
    'finds store name after an invoice title when OCR begins with address',
    () {
      final result = parser.parse(
        'Ngày bán\nThôn Đa, Di Trạch, Huyện Hoài Đức,\nHoài Đức,\nNN\nKH\n'
        'Áo sơ mi kẻ sọc -L\n450,000\nHÓA ĐƠN BÁN HÀNG\nTiền mặt\n'
        'thietbisieuthi\nTổng tiền hàng\nKhách phải trả\n'
        '900,000\n935,000',
      );
      expect(result.merchant, 'thietbisieuthi');
    },
  );

  test('handles a cash-total column with OCR spaces after commas', () {
    final result = parser.parse(
      'FOOD SHOP\nTIEN MAT\n000887\n42,000\n37, 000\n'
      '172, 000\n537, O00\nCAM ON QUY KHACH',
    );
    expect(result.total, 537000);
  });

  test(
    'keeps an ambiguous column blank when the last amount is not largest',
    () {
      expect(
        parser
            .parse('SHOP TEST\nKhách phải trả\nMã hóa đơn\n900.000\n35.000')
            .total,
        isNull,
      );
    },
  );

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
      '537, 000',
      '537, O00',
    ]) {
      expect(
        ReceiptParser.parseVnd(format),
        format.startsWith('537') ? 537000 : 150000,
        reason: format,
      );
    }
    expect(ReceiptParser.parseVnd('150,50'), isNull);
    expect(ReceiptParser.parseVnd('O00'), isNull);
  });
}
