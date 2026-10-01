import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_expense_capture/models/expense_item.dart';
import 'package:smart_expense_capture/l10n/app_localizations.dart';
import 'package:smart_expense_capture/models/expense_source.dart';
import 'package:smart_expense_capture/models/parsed_expense.dart';
import 'package:smart_expense_capture/routing/app_router.dart';
import 'package:smart_expense_capture/screens/review_screen.dart';
import 'package:smart_expense_capture/services/expense_database.dart';
import 'package:smart_expense_capture/state/expense_providers.dart';

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

Future<void> _pumpReview(
  WidgetTester tester,
  _MemoryRepository repository,
  ParsedExpense draft, {
  Locale locale = const Locale('en'),
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => ReviewScreen(args: ReviewArgs(draft: draft)),
      ),
      GoRoute(
        path: '/expenses',
        builder: (_, _) => const Scaffold(body: Text('Saved history')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [expenseRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(
        routerConfig: router,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapSave(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('confirm_save'));
  await tester.scrollUntilVisible(
    button,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  const receipt = ParsedExpense(
    source: ExpenseSource.receipt,
    merchant: 'Cửa hàng An',
    amount: 150000,
    rawText: 'Cửa hàng An\nTổng tiền 150.000',
  );

  testWidgets('review shows parsed values and requires a valid date', (
    tester,
  ) async {
    final repo = _MemoryRepository();
    await _pumpReview(tester, repo, receipt);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('merchant_field')))
          .controller!
          .text,
      'Cửa hàng An',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('amount_field')))
          .controller!
          .text,
      '150000',
    );
    await _tapSave(tester);
    expect(find.text('Enter a valid date (dd/MM/yyyy)'), findsOneWidget);
    expect(repo.items, isEmpty);
  });

  testWidgets('merchant and amount validation block a save', (tester) async {
    final repo = _MemoryRepository();
    await _pumpReview(
      tester,
      repo,
      const ParsedExpense(source: ExpenseSource.receipt, rawText: ''),
    );
    await tester.enterText(
      find.byKey(const ValueKey('date_field')),
      '01/10/2026',
    );
    await _tapSave(tester);
    expect(find.text('Enter a merchant or recipient'), findsOneWidget);
    expect(find.text('Enter a positive amount'), findsOneWidget);
    expect(repo.items, isEmpty);
  });

  testWidgets('corrected values are the values persisted', (tester) async {
    final repo = _MemoryRepository();
    await _pumpReview(tester, repo, receipt);
    await tester.enterText(
      find.byKey(const ValueKey('merchant_field')),
      'Minh Market',
    );
    await tester.enterText(
      find.byKey(const ValueKey('amount_field')),
      '175.000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('date_field')),
      '01/10/2026',
    );
    await _tapSave(tester);
    expect(repo.items, hasLength(1));
    expect(repo.items.single.merchant, 'Minh Market');
    expect(repo.items.single.amount, 175000);
    expect(find.text('Saved history'), findsOneWidget);
  });

  testWidgets('pending screenshot cannot be saved as completed', (
    tester,
  ) async {
    final repo = _MemoryRepository();
    await _pumpReview(
      tester,
      repo,
      ParsedExpense(
        source: ExpenseSource.bankScreenshot,
        merchant: 'Mai An',
        amount: 100000,
        date: DateTime(2026, 10, 1),
        status: PaymentStatus.pending,
        rawText: 'Đang xử lý',
      ),
    );
    await _tapSave(tester);
    expect(find.text('Verify that this payment succeeded'), findsOneWidget);
    expect(repo.items, isEmpty);
  });

  testWidgets(
    'Vietnamese review localizes validation without changing stored values',
    (tester) async {
      final repo = _MemoryRepository();
      await _pumpReview(
        tester,
        repo,
        const ParsedExpense(source: ExpenseSource.receipt, rawText: ''),
        locale: const Locale('vi'),
      );
      expect(find.text('Kiểm tra & xác nhận'), findsOneWidget);
      await _tapSave(tester);
      expect(find.text('Nhập người nhận hoặc cửa hàng'), findsOneWidget);
      expect(find.text('Nhập số tiền lớn hơn 0'), findsOneWidget);
      expect(repo.items, isEmpty);
    },
  );
}
