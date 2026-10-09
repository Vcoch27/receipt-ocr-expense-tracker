import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_expense_capture/models/expense_item.dart';
import 'package:smart_expense_capture/models/expense_source.dart';
import 'package:smart_expense_capture/services/expense_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test(
    'SQLite inserts, reads, updates, and deletes a normalized expense',
    () async {
      final db = ExpenseDatabase(
        factory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      );
      final now = DateTime(2026, 10, 1);
      final draft = ExpenseItem(
        merchant: 'Mai An',
        amount: 150000,
        date: now,
        category: 'Shopping',
        source: ExpenseSource.eWalletScreenshot,
        status: PaymentStatus.successful,
        paymentProvider: 'MoMo',
        transactionReference: 'MM123456',
        createdAt: now,
        updatedAt: now,
      );
      final saved = await db.insert(draft);
      expect(saved.id, isNotNull);
      final fetched = await db.all();
      expect(fetched, hasLength(1));
      expect(fetched.single.amount, 150000);
      expect(fetched.single.source, ExpenseSource.eWalletScreenshot);
      expect(fetched.single.transactionReference, 'MM123456');

      await db.update(saved.copyWith(amount: 175000));
      expect((await db.all()).single.amount, 175000);

      await db.delete(saved.id!);
      expect(await db.all(), isEmpty);

      final monthKey = 2026 * 12 + 10;
      expect(await db.budgetForMonth(monthKey), isNull);
      await db.setBudgetForMonth(monthKey, 8000000);
      expect(await db.budgetForMonth(monthKey), 8000000);
      await db.setBudgetForMonth(monthKey, 9000000);
      expect(await db.budgetForMonth(monthKey), 9000000);
      await db.setBudgetForMonth(monthKey, null);
      expect(await db.budgetForMonth(monthKey), isNull);
    },
  );

  test('version 2 expenses survive the budget migration', () async {
    final directory = await Directory.systemTemp.createTemp(
      'expense-migration',
    );
    addTearDown(() => directory.delete(recursive: true));
    final path = '${directory.path}/expenses.db';
    final old = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, _) async {
          await db.execute('''CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        merchant TEXT NOT NULL, amount INTEGER NOT NULL,
        date TEXT NOT NULL, category TEXT NOT NULL,
        source TEXT NOT NULL, status TEXT, payment_provider TEXT,
        transaction_reference TEXT, note TEXT, image_path TEXT,
        raw_ocr_text TEXT, created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL)''');
        },
      ),
    );
    final date = DateTime(2026, 10, 1).toIso8601String();
    await old.insert('expenses', {
      'merchant': 'Test Market',
      'amount': 33000,
      'date': date,
      'category': 'Other',
      'source': 'receipt',
      'created_at': date,
      'updated_at': date,
    });
    await old.close();

    final upgraded = ExpenseDatabase(
      factory: databaseFactoryFfi,
      databasePath: path,
    );
    expect((await upgraded.all()).single.amount, 33000);
    await upgraded.setBudgetForMonth(2026 * 12 + 10, 1000000);
    expect(await upgraded.budgetForMonth(2026 * 12 + 10), 1000000);
    expect((await upgraded.all()).single.merchant, 'Test Market');
    await upgraded.close();
  });
}
