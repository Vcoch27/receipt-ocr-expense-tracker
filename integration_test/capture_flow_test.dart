import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smart_expense_capture/core/formatters.dart';
import 'package:smart_expense_capture/main.dart';
import 'package:smart_expense_capture/models/expense_item.dart';
import 'package:smart_expense_capture/models/parsed_expense.dart';
import 'package:smart_expense_capture/routing/app_router.dart';
import 'package:smart_expense_capture/services/expense_database.dart';
import 'package:smart_expense_capture/services/expense_source_classifier.dart';
import 'package:smart_expense_capture/services/payment_screenshot_parser.dart';
import 'package:smart_expense_capture/services/receipt_parser.dart';
import 'package:smart_expense_capture/services/receipt_scan_service.dart';
import 'package:smart_expense_capture/state/expense_providers.dart';
import 'package:smart_expense_capture/widgets/donut_chart.dart';
import 'package:smart_expense_capture/widgets/weekly_bar_chart.dart';

class _MemoryRepository implements ExpenseRepository {
  final items = <ExpenseItem>[];
  @override
  Future<List<ExpenseItem>> all() async => List.of(items);
  @override
  Future<ExpenseItem> insert(ExpenseItem item) async {
    final saved = item.copyWith(id: items.length + 1);
    items.add(saved);
    return saved;
  }

  @override
  Future<void> update(ExpenseItem item) async {
    final index = items.indexWhere((value) => value.id == item.id);
    items[index] = item;
  }

  @override
  Future<void> delete(int id) async {
    items.removeWhere((item) => item.id == id);
  }
}

/// The picker and native ML Kit calls are replaced; real parsers and the
/// review/state/history/analytics pipeline stay under test.
class _FakeCapture implements ExpenseCaptureService {
  @override
  Future<ParsedExpense> captureReceipt(ImageSource source) async {
    final text =
        'MINH MART\nNgày: ${formatDate(DateTime.now())}\nTổng tiền: 150.000 đ';
    return ParsedExpense.fromReceipt(const ReceiptParser().parse(text));
  }

  @override
  Future<ParsedExpense> importPaymentScreenshot() async {
    final text =
        'MoMo\nThanh toán thành công\nSố tiền: 200.000 đ\nNgười nhận: OCR NAME\nNgày: ${formatDate(DateTime.now())}';
    return const PaymentScreenshotParser(ExpenseSourceClassifier()).parse(text);
  }
}

Future<void> _confirm(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('confirm_save'));
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    button,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
  // The save confirmation snackbar temporarily covers the history FAB and
  // bottom navigation on a physical phone.
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('receipt and screenshot both reach history and analytics', (
    tester,
  ) async {
    final repository = _MemoryRepository();
    appRouter.go('/');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(repository),
          receiptScanServiceProvider.overrideWithValue(_FakeCapture()),
        ],
        child: const SmartExpenseApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('add_expense')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan Receipt'));
    await tester.pumpAndSettle();
    expect(find.text('Review & Verify'), findsOneWidget);
    await _confirm(tester);
    expect(repository.items, hasLength(1));
    expect(find.text('MINH MART'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Import Payment Screenshot'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('merchant_field')),
      'Mai An',
    );
    await tester.enterText(
      find.byKey(const ValueKey('amount_field')),
      '220.000',
    );
    await _confirm(tester);
    expect(repository.items, hasLength(2));
    expect(repository.items.last.merchant, 'Mai An');
    expect(repository.items.last.amount, 220000);
    expect(find.text('Mai An'), findsOneWidget);

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    expect(find.byType(DonutChart), findsOneWidget);
    expect(find.byType(WeeklyBarChart), findsOneWidget);
    expect(find.text(formatVnd(370000)), findsWidgets);
  });
}
