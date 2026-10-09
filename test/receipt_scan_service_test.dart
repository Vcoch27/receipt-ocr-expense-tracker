import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_expense_capture/models/expense_source.dart';
import 'package:smart_expense_capture/services/expense_source_classifier.dart';
import 'package:smart_expense_capture/services/ocr_service.dart';
import 'package:smart_expense_capture/services/payment_screenshot_parser.dart';
import 'package:smart_expense_capture/services/receipt_parser.dart';
import 'package:smart_expense_capture/services/receipt_scan_service.dart';

class _Picker extends ImagePicker {
  _Picker(this.file);
  final File file;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async => XFile(file.path);
}

class _FailingOcr implements OcrService {
  @override
  Future<String> recognize(String imagePath) async =>
      throw const FileSystemException('Native OCR unavailable');
}

void main() {
  test('OCR failure still reaches editable receipt review draft', () async {
    final directory = await Directory.systemTemp.createTemp('capture-fallback');
    final image = File('${directory.path}/receipt.jpg');
    await image.writeAsBytes([0xff, 0xd8, 0xff]);
    addTearDown(() => directory.delete(recursive: true));
    final service = ReceiptScanService(
      picker: _Picker(image),
      ocr: _FailingOcr(),
      receiptParser: const ReceiptParser(),
      paymentParser: const PaymentScreenshotParser(ExpenseSourceClassifier()),
    );

    final receipt = await service.captureReceipt(ImageSource.gallery);
    expect(receipt, isNotNull);
    expect(receipt!.source, ExpenseSource.receipt);
    expect(receipt.imagePath, image.path);
    expect(receipt.rawText, isEmpty);
    expect(receipt.amount, isNull);

    final payment = await service.importPaymentScreenshot();
    expect(payment, isNotNull);
    expect(payment!.source, ExpenseSource.bankScreenshot);
    expect(payment.status, PaymentStatus.unknown);
    expect(payment.rawText, isEmpty);
  });
}
