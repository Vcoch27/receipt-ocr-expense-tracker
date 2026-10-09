import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_expense_capture/main.dart';
import 'package:smart_expense_capture/models/expense_item.dart';
import 'package:smart_expense_capture/routing/app_router.dart';
import 'package:smart_expense_capture/services/expense_database.dart';
import 'package:smart_expense_capture/state/expense_providers.dart';

class _EmptyRepository implements ExpenseRepository {
  @override
  Future<List<ExpenseItem>> all() async => [];
  @override
  Future<ExpenseItem> insert(ExpenseItem item) async => item;
  @override
  Future<void> update(ExpenseItem item) async {}
  @override
  Future<void> delete(int id) async {}
}

void main() {
  testWidgets('Vietnamese is primary and the user can switch to English', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    appRouter.go('/');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(_EmptyRepository()),
        ],
        child: const SmartExpenseApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('ĐÃ CHI TRONG THÁNG'), findsOneWidget);
    expect(find.text('Lịch sử'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Ngôn ngữ'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('SPENT THIS MONTH'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
