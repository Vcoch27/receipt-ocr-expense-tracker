---
name: receipt-ocr-expense-tracker
description: Build and maintain this repository's Flutter receipt OCR and expense tracking app according to its course PRD.
---

# Receipt OCR & Expense Tracker

Read MiniProject3_Receipt_OCR_Expense_Tracker_PRD.md before changing product behavior. Its product extension makes **Smart Expense Capture & Tracker** support payment screenshots as the primary Vietnam use case while retaining the original course-required receipt workflow. Course rubric requirements take precedence over generic design advice. Use official Flutter and Dart guidance. Target a physical Android device, with Material 3, accessible light/dark themes, and responsive mobile layouts.

## Required pipeline

`image_picker` camera or gallery input → on-device `google_mlkit_text_recognition` → raw OCR text → dedicated `ReceiptParser` using Dart `RegExp` and heuristics → `ParsedReceipt` → **Review & Verification** → form validation → `sqflite` → Riverpod 2 state → history and analytics. No OCR result may be saved directly to SQLite. A user must inspect and explicitly confirm editable merchant, date, total, and applicable other fields. Empty or uncertain extraction stays blank for manual correction; never fabricate a value.

The parser must handle Vietnamese receipts, accented and unaccented total keywords (`total`, `tổng tiền`, `tong tien`, `thanh toán`, `thanh toan`, `cộng tiền`, `cong tien`, `amount due`), and VND formats including `150000`, `150.000`, `150,000`, `150.000 đ`, `150,000 VNĐ`. Keep OCR and parsing outside widgets. Preserve raw text for traceability.

The main Add Expense entry offers **Import Payment Screenshot**, **Scan Receipt**, and **Manual Entry**. A screenshot uses the same OCR service, then a deterministic ExpenseSourceClassifier and an independent PaymentScreenshotParser. Normalize both parsers into one expense draft/model. Store source (receipt, bankScreenshot, eWalletScreenshot, or manual) with every record. Payment parsing attempts amount, date/time, recipient, and transaction status; provider, reference, and note are optional. Show and edit these in the same review screen. Unknown, failed, or pending payment status must not silently become a completed expense. Warn about likely duplicates during verification using reference or amount/date/recipient/source, without auto-blocking. Keep screenshots and OCR text on-device; avoid collecting or displaying account numbers.

## Architecture and UI

Keep models (`ExpenseItem`, `ParsedReceipt`), OCR/parser/database services, Riverpod state, GoRouter routing, screens, and reusable widgets in separate `lib/` folders. Use `ConsumerWidget` or `ConsumerStatefulWidget`, `ref.watch` for reactive values and `ref.read` for actions; show async loading/error/data states. Keep SQLite calls in a service/repository layer. Provide persistent CRUD and retain the receipt image path in app-managed storage. Use lazy history lists with record keys and visible detail, edit, and delete actions.

The mandatory review screen uses `Form`, `GlobalKey<FormState>`, `TextEditingController`, and `TextFormField`; dispose controllers and any focus nodes. Validate nonblank merchant, valid date, numeric positive amount. Show image preview and clear prompts for missing OCR values. Handle cancelled picker, permissions, invalid image, empty OCR, processing errors, long processing, database failure, and unavailable stored image.

Use `CustomPainter` and Canvas to draw an animated category donut with `drawArc` and a weekly bar chart with `drawRRect` or `drawRect`. Derive both from saved records, handle no data, and dispose animation controllers. Keep parsing, OCR, and database computation out of `build()`. Prefer const widgets, intentional `shouldRepaint`, readable forms, accessible touch targets, and restrained motion. UI/UX Pro Max may guide design details but cannot change PRD architecture or rubric features.

## Verification and deliverables

Cover parser edge cases (Vietnamese keywords, separators, malformed/missing values, merchant and date), review validation/correction, database CRUD, and a mocked scan-to-analytics integration path. Also validate camera and ML Kit manually on a physical Android device. Run `dart format .`, `dart analyze`, `flutter test`, and `flutter test integration_test` when present. Fix meaningful findings rather than suppressing them.

Maintain a comprehensive README with setup, packages, architecture, OCR/parser/database/state flows, build and run instructions, screenshots, and limitations. Prepare a signed `app-release.apk`, physical device check, demo video flow, and 2–4 page report material including architecture diagram, regex table, light/dark screenshots, and limitations. Never claim external release, device validation, screenshots, or video is complete without actual evidence.
