# Smart Expense Capture & Tracker

A Flutter and Dart expense tracker for Vietnamese payments. Import a bank or
e-wallet payment screenshot, scan a paper receipt, or enter an expense manually.
Images are recognized **on the device** with ML Kit. Every OCR result opens a
Review & Verification form before anything is written to SQLite.

The [course PRD](MiniProject3_Receipt_OCR_Expense_Tracker_PRD.md) distinguishes
the required Mini-Project 3 receipt workflow from the primary everyday payment
screenshot extension. The receipt path remains fully available.

## Features

- Payment screenshot import from the gallery; deterministic bank/e-wallet
  classification, status detection, amount/date/time/recipient parsing, and
  optional provider/reference/note.
- Receipt capture with the camera or gallery; merchant/date/total heuristics
  for Vietnamese receipts and VND separators.
- One review form with explicit confirmation, validation, correction,
  manual fallback, and a non-blocking duplicate warning.
- Local SQLite CRUD, persistent image copies, reactive Riverpod 2 history,
  and custom animated category donut and weekly bar charts.
- Material 3, light/dark/system appearance, responsive layout, and empty,
  loading, and error states.

## Architecture

    Camera/gallery receipt ─┐
                            ├→ image_picker → ML Kit OCR
    Payment screenshot ─────┘                    ↓
                                      source-specific parser
                                      ↓
    Manual entry ──────────→ Review & Verification
                            ↓
                     validation + duplicate warning
                            ↓
                     SQLite ExpenseDatabase
                            ↓
                     Riverpod ExpensesNotifier
                            ↓
                     history + CustomPainter charts

| Directory | Responsibility |
|---|---|
| [lib/models](lib/models) | Expense, parsed draft, source, status, analytics data |
| [lib/services](lib/services) | ML Kit, capture, parsers, classifier, duplicate matching, images, SQLite |
| [lib/state](lib/state) | Riverpod providers and mutations |
| [lib/screens](lib/screens) | Dashboard, capture, review, history, detail, analytics |
| [lib/widgets](lib/widgets) | Reusable cards, states, and custom charts |
| [lib/routing](lib/routing) | GoRouter paths and bottom navigation |
| [lib/core](lib/core) | Theme, categories, formatting, validation |

## Packages

| Package | Purpose |
|---|---|
| image_picker | Camera and gallery acquisition |
| google_mlkit_text_recognition | Native on-device OCR |
| flutter_riverpod 2 | Async state and service injection |
| sqflite | Persistent local CRUD |
| go_router | Declarative navigation |
| path_provider / path | App-owned image storage and paths |
| intl | Vietnamese VND and date formatting |
| sqflite_common_ffi (dev) | SQLite CRUD tests |
| integration_test (dev) | Mocked capture-to-analytics flow on Android |

## OCR and parsing

ML Kit returns raw text. The chosen capture action routes it to either the
ReceiptParser or PaymentScreenshotParser. Payment text is also classified as
bank or e-wallet using known wallet names. Both parsers are independently
testable and return nullable fields. No OCR value is saved without review.

| Field | Heuristic | Failure behavior |
|---|---|---|
| Receipt total | Weighted total, tổng tiền, thanh toán, cộng tiền, amount due lines; adjacent line when needed | Blank amount |
| VND amount | Integer or grouped thousands: 150000, 150.000, 150,000, with VNĐ/đ | Reject ambiguous decimals |
| Receipt merchant | First plausible header, excluding invoice/date/address/phone labels | Blank merchant |
| Date | Strict dd/MM/yyyy or yyyy-MM-dd; reject impossible days | Blank date |
| Payment amount | Prioritize số tiền/amount labels and currency lines | Blank amount |
| Recipient | Người nhận/recipient/beneficiary labels; cautious unlabeled name immediately after the payment timestamp | Blank recipient |
| Status | Detect failure and pending before success phrases | Requires successful verification |
| Provider/reference | Known provider names and labelled reference fields; account numbers are never treated as references | Optional blanks |
| Transfer note | Labelled nội dung/ghi chú, transfer phrases, or text immediately after a destination account number | Optional editable note |

Payment OCR text is shown in memory during review but **not persisted**, as it
can contain account numbers. The screenshot image remains in app-owned local
storage. No OCR text or images are uploaded. Normal history does not display
account details.

## Database and state

SQLite table expenses stores ID, merchant/recipient, integer VND amount, ISO
date/time, category, source, optional payment status/provider/reference/note,
image path, optional receipt OCR text, and creation/update timestamps.
Database version 2 adds payment fields through an additive migration for
version 1 records. ExpenseDatabase owns SQL; ExpensesNotifier owns CRUD and
refreshes the reactive list. Analytics aggregates the stored list by category
and day of the current week.

## Setup

1. Install Flutter 3.47.5 or a compatible stable version, Dart 3.13+, Android
   SDK, and a supported JDK. iOS requires macOS, Xcode, CocoaPods, and iOS
   15.5+ for ML Kit.
2. Run flutter doctor, install any missing Android command-line tools, and
   accept Android SDK licenses in your own SDK setup.
3. Run flutter pub get.
4. Connect an Android device with USB debugging and run flutter run -d DEVICE_ID.

The Android application ID is vn.vku.smart_expense_capture; minimum Android
SDK is 24 (Flutter 3.47 default). The core flow works without a network connection.

## Tests and analysis

    dart format .
    dart analyze
    flutter test
    flutter test integration_test -d DEVICE_ID

The integration test replaces the picker and native ML Kit boundary with
deterministic text fixtures; it exercises real parsers, review, state, history,
and analytics. The signed release was also tested on a Samsung SM-A115F with
three real payment-success images: native ML Kit reached review and extracted
amount, date/time, status, recipient and transfer note. These private images
and OCR text are not included in the repository. A paper receipt camera test
remains part of the manual demo checklist.

## Release APK

Release signing reads the **ignored** android/key.properties, which points to
a private PKCS12 keystore outside Git. Back up both files securely. To create
the universal signed APK:

    flutter build apk --release

Output: build/app/outputs/flutter-apk/app-release.apk. Install with
adb install -r on a physical Android device. Never commit signing credentials.

## Screenshots and demo

The [light home](docs/screenshots/light-home.png),
[dark home](docs/screenshots/dark-home.png),
[review](docs/screenshots/dark-review.png), and
[analytics](docs/screenshots/dark-weekly.png) screenshots were captured on an
Android device. The [technical report](output/pdf/smart_expense_technical_report.pdf)
contains the architecture diagram, heuristic table, and light/dark screenshots.
Use [docs/demo-flow.md](docs/demo-flow.md) to record the live receipt scan and
payment screenshot demonstration. A demo video is not bundled.

## Known limitations

- OCR accuracy depends on image quality and the Latin-script model.
  Handwritten or damaged receipts need manual correction.
- Ambiguous VND decimals remain blank rather than guessed.
- Bank and wallet layouts vary; unknown fields remain editable. Source
  classification uses deterministic cues, not an ML model.
- Duplicate detection warns on matching reference or
  amount/date/recipient/source; it cannot prove duplicates.
- Native payment OCR has been checked on Samsung; physical receipt camera OCR
  still needs validation with an actual paper receipt.
- iOS requires a Mac/Xcode build and a compatible device; it has not been
  validated on iPhone from this Windows workspace.
