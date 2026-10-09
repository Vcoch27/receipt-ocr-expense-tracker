import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'demo_data_seeder.dart';
import '../models/expense_item.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseItem>> all();
  Future<ExpenseItem> insert(ExpenseItem item);
  Future<void> update(ExpenseItem item);
  Future<void> delete(int id);
}

abstract class BudgetRepository {
  Future<int?> budgetForMonth(int monthKey);
  Future<void> setBudgetForMonth(int monthKey, int? amount);
}

class ExpenseDatabase implements ExpenseRepository, BudgetRepository {
  ExpenseDatabase({
    DatabaseFactory? factory,
    this._databasePath,
    this.enableAutoSeed = false,
  }) : _factory = factory ?? databaseFactory;

  final DatabaseFactory _factory;
  final String? _databasePath;
  final bool enableAutoSeed;
  Future<Database>? _opening;

  Future<Database> get _database async {
    try {
      return await (_opening ??= _open());
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<void> close() async {
    if (_opening != null) {
      await (await _opening!).close();
      _opening = null;
    }
  }

  Future<Database> _open() async {
    final path =
        _databasePath ?? p.join(await getDatabasesPath(), 'expenses.db');
    final db = await _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE expenses (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              merchant TEXT NOT NULL,
              amount INTEGER NOT NULL CHECK(amount > 0),
              date TEXT NOT NULL,
              category TEXT NOT NULL,
              source TEXT NOT NULL DEFAULT 'receipt',
              status TEXT,
              payment_provider TEXT,
              transaction_reference TEXT,
              note TEXT,
              image_path TEXT,
              raw_ocr_text TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
          await db.execute(
            'CREATE INDEX expenses_by_date ON expenses(date DESC)',
          );
          await db.execute('''
            CREATE TABLE monthly_budgets (
              month_key INTEGER PRIMARY KEY,
              amount INTEGER NOT NULL CHECK(amount > 0)
            )
          ''');
        },
        onUpgrade: (db, oldVersion, _) async {
          if (oldVersion < 2) {
            await db.execute(
              "ALTER TABLE expenses ADD COLUMN source TEXT NOT NULL DEFAULT 'receipt'",
            );
            await db.execute('ALTER TABLE expenses ADD COLUMN status TEXT');
            await db.execute(
              'ALTER TABLE expenses ADD COLUMN payment_provider TEXT',
            );
            await db.execute(
              'ALTER TABLE expenses ADD COLUMN transaction_reference TEXT',
            );
            await db.execute('ALTER TABLE expenses ADD COLUMN note TEXT');
          }
          if (oldVersion < 3) {
            await db.execute('''
              CREATE TABLE monthly_budgets (
                month_key INTEGER PRIMARY KEY,
                amount INTEGER NOT NULL CHECK(amount > 0)
              )
            ''');
          }
        },
      ),
    );
    if (enableAutoSeed) {
      await DemoDataSeeder.seedIfEmpty(db);
    }
    return db;
  }

  @override
  Future<List<ExpenseItem>> all() async {
    final rows = await (await _database).query(
      'expenses',
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(ExpenseItem.fromMap).toList(growable: false);
  }

  @override
  Future<ExpenseItem> insert(ExpenseItem item) async {
    final id = await (await _database).insert('expenses', item.toMap());
    return item.copyWith(id: id);
  }

  @override
  Future<void> update(ExpenseItem item) async {
    final id = item.id;
    if (id == null) throw ArgumentError('Cannot update an unsaved expense');
    final count = await (await _database).update(
      'expenses',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    if (count != 1) throw StateError('Expense $id was not found');
  }

  @override
  Future<void> delete(int id) async {
    final count = await (await _database).delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (count != 1) throw StateError('Expense $id was not found');
  }

  @override
  Future<int?> budgetForMonth(int monthKey) async {
    final rows = await (await _database).query(
      'monthly_budgets',
      columns: ['amount'],
      where: 'month_key = ?',
      whereArgs: [monthKey],
    );
    return rows.isEmpty ? null : rows.single['amount'] as int;
  }

  @override
  Future<void> setBudgetForMonth(int monthKey, int? amount) async {
    final db = await _database;
    if (amount == null) {
      await db.delete(
        'monthly_budgets',
        where: 'month_key = ?',
        whereArgs: [monthKey],
      );
    } else {
      if (amount <= 0) throw ArgumentError.value(amount, 'amount');
      await db.insert('monthly_budgets', {
        'month_key': monthKey,
        'amount': amount,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> seedDemoData({bool clearFirst = true}) async {
    final db = await _database;
    await DemoDataSeeder.seed(db, clearFirst: clearFirst);
  }

  Future<void> clearAll() async {
    final db = await _database;
    await db.delete('expenses');
    await db.delete('monthly_budgets');
  }
}
