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
    },
  );
}
