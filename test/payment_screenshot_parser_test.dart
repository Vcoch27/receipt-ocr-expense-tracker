import 'package:flutter_test/flutter_test.dart';
import 'package:smart_expense_capture/models/expense_source.dart';
import 'package:smart_expense_capture/services/expense_source_classifier.dart';
import 'package:smart_expense_capture/services/payment_screenshot_parser.dart';

void main() {
  const parser = PaymentScreenshotParser(ExpenseSourceClassifier());

  test('extracts successful bank transfer with time and reference', () {
    final result = parser.parse(
      'Vietcombank\nChuyển khoản thành công\n'
      'Số tiền: 150.000 đ\nNgười nhận: NGUYEN VAN A\n'
      'Thời gian: 01/10/2026 14:30\nMã giao dịch: FT12345678',
    );
    expect(result.source, ExpenseSource.bankScreenshot);
    expect(result.amount, 150000);
    expect(result.merchant, 'NGUYEN VAN A');
    expect(result.date, DateTime(2026, 10, 1, 14, 30));
    expect(result.status, PaymentStatus.successful);
    expect(result.paymentProvider, 'Vietcombank');
    expect(result.transactionReference, 'FT12345678');
  });

  test('extracts MoMo wallet payment with comma separator', () {
    final result = parser.parse(
      'MoMo\nThanh toán thành công\nSố tiền 150,000 VNĐ\n'
      'Đến: Nguyễn Văn Bình\nNgày 02/10/2026',
    );
    expect(result.source, ExpenseSource.eWalletScreenshot);
    expect(result.amount, 150000);
    expect(result.merchant, 'Nguyễn Văn Bình');
    expect(result.status, PaymentStatus.successful);
  });

  test('missing recipient remains null', () {
    final result = parser.parse(
      'BIDV\nGiao dịch thành công\nSố tiền 50.000đ\nNgày 01/10/2026',
    );
    expect(result.merchant, isNull);
  });

  test('missing date and reference remain null', () {
    final result = parser.parse(
      'ZaloPay\nThanh toán thành công\nSố tiền 50.000đ\nNgười nhận: Shop A',
    );
    expect(result.date, isNull);
    expect(result.transactionReference, isNull);
  });

  test('detects failed and pending before generic success words', () {
    expect(
      parser.parse('Giao dịch không thành công\nSố tiền 150.000đ').status,
      PaymentStatus.failed,
    );
    expect(
      parser.parse('Giao dịch đang xử lý\nSố tiền 150.000đ').status,
      PaymentStatus.pending,
    );
  });

  test('noisy OCR does not fabricate missing fields', () {
    final result = parser.parse('### M0M0\nG!ao dich ???\n1SO.OOO');
    expect(result.amount, isNull);
    expect(result.date, isNull);
    expect(result.merchant, isNull);
    expect(result.status, PaymentStatus.unknown);
  });

  test('preserves duplicate matching metadata', () {
    final result = parser.parse(
      'MB Bank\nGiao dịch thành công\nSố tiền 250.000 đ\n'
      'Người nhận: Mai An\nNgày 03/10/2026\nMã giao dịch: MB778899',
    );
    expect(result.amount, 250000);
    expect(result.merchant, 'Mai An');
    expect(result.transactionReference, 'MB778899');
  });

  test('reads unlabeled recipient and transfer note on bank confirmation', () {
    final result = parser.parse(
      'Chuyển tiền thành công\n600,000 VND\n22:34 - 18/09/2026\n'
      'TRAN VAN MAI\nVietcombank (VCB)\n9876543210\n'
      'Hen gap lai 85+ 400k\nCảm ơn bạn đã sử dụng dịch vụ của MBBank',
    );
    expect(result.merchant, 'TRAN VAN MAI');
    expect(result.note, 'Hen gap lai 85+ 400k');
    expect(result.paymentProvider, 'MB Bank');
    expect(result.transactionReference, isNull);
  });

  test('reads transfer content phrase after recipient without a label', () {
    final result = parser.parse(
      'Chuyển tiền thành công\n2,000,000 VND\n20:35 - 21/09/2026\n'
      'MB Transfer\nLE VAN AN\nBIDV\nNGUYEN VAN NAM chuyen tien\n'
      '9876543210\nCảm ơn bạn đã sử dụng dịch vụ của MBBank',
    );
    expect(result.merchant, 'LE VAN AN');
    expect(result.note, 'NGUYEN VAN NAM chuyen tien');
    expect(result.paymentProvider, 'MB Bank');
  });

  test('reads a transfer description on the line after its label', () {
    final result = parser.parse(
      'Chuyển tiền thành công\n50.000 VND\n01/10/2026\n'
      'Người nhận: Shop A\nNội dung chuyển khoản:\nThanh toán bữa trưa',
    );
    expect(result.note, 'Thanh toán bữa trưa');
  });
}
