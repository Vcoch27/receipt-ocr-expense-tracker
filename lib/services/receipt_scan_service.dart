import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../models/parsed_expense.dart';
import 'ocr_service.dart';
import 'payment_screenshot_parser.dart';
import 'receipt_parser.dart';

abstract class ExpenseCaptureService {
  Future<ParsedExpense?> captureReceipt(ImageSource source);
  Future<ParsedExpense?> importPaymentScreenshot();
}

class ReceiptScanService implements ExpenseCaptureService {
  ReceiptScanService({
    required this.picker,
    required this.ocr,
    required this.receiptParser,
    required this.paymentParser,
  });

  final ImagePicker picker;
  final OcrService ocr;
  final ReceiptParser receiptParser;
  final PaymentScreenshotParser paymentParser;

  @override
  Future<ParsedExpense?> captureReceipt(ImageSource source) async {
    final image = await _pick(source);
    if (image == null) return null;
    final rawText = await ocr
        .recognize(image.path)
        .timeout(const Duration(seconds: 40));
    final receipt = receiptParser.parse(rawText, imagePath: image.path);
    return ParsedExpense.fromReceipt(receipt);
  }

  @override
  Future<ParsedExpense?> importPaymentScreenshot() async {
    final image = await _pick(ImageSource.gallery);
    if (image == null) return null;
    final rawText = await ocr
        .recognize(image.path)
        .timeout(const Duration(seconds: 40));
    return paymentParser.parse(rawText, imagePath: image.path);
  }

  Future<XFile?> _pick(ImageSource source) async {
    final image = await picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2200,
    );
    if (image == null) return null;
    if (!await File(image.path).exists()) {
      throw const FileSystemException('Selected receipt image is unavailable');
    }
    return image;
  }
}
