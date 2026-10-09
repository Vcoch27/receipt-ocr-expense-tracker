import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/expense_item.dart';
import '../models/expense_analytics.dart';
import '../services/duplicate_matcher.dart';
import '../services/ai_receipt_service.dart';
import '../services/expense_database.dart';
import '../services/expense_source_classifier.dart';
import '../services/ocr_service.dart';
import '../services/payment_screenshot_parser.dart';
import '../services/receipt_image_store.dart';
import '../services/receipt_parser.dart';
import '../services/receipt_scan_service.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => ExpenseDatabase(enableAutoSeed: true),
);
final monthlyBudgetProvider = FutureProvider.family<int?, int>((ref, monthKey) {
  final repository = ref.read(expenseRepositoryProvider);
  return repository is BudgetRepository
      ? (repository as BudgetRepository).budgetForMonth(monthKey)
      : Future<int?>.value();
});
final imageStoreProvider = Provider<ReceiptImageStore>(
  (ref) => ReceiptImageStore(),
);
final ocrServiceProvider = Provider<OcrService>((ref) => MlKitOcrService());
final aiReceiptServiceProvider = Provider<AiReceiptService>(
  (ref) => const ProxyAiReceiptService(String.fromEnvironment('AI_PROXY_URL')),
);
final receiptParserProvider = Provider<ReceiptParser>(
  (ref) => const ReceiptParser(),
);
final paymentParserProvider = Provider<PaymentScreenshotParser>(
  (ref) => const PaymentScreenshotParser(ExpenseSourceClassifier()),
);
final receiptScanServiceProvider = Provider<ExpenseCaptureService>(
  (ref) => ReceiptScanService(
    picker: ImagePicker(),
    ocr: ref.read(ocrServiceProvider),
    receiptParser: ref.read(receiptParserProvider),
    paymentParser: ref.read(paymentParserProvider),
  ),
);
final duplicateMatcherProvider = Provider<DuplicateMatcher>(
  (ref) => const DuplicateMatcher(),
);

final expensesProvider =
    AsyncNotifierProvider<ExpensesNotifier, List<ExpenseItem>>(
      ExpensesNotifier.new,
    );

final expenseAnalyticsProvider = Provider<AsyncValue<ExpenseAnalytics>>(
  (ref) => ref.watch(expensesProvider).whenData(ExpenseAnalytics.fromItems),
);

final expenseMonthAnalyticsProvider =
    Provider.family<AsyncValue<ExpenseAnalytics>, int>((ref, monthKey) {
      final year = (monthKey - 1) ~/ 12;
      final month = monthKey - year * 12;
      return ref
          .watch(expensesProvider)
          .whenData(
            (items) =>
                ExpenseAnalytics.fromItems(items, month: DateTime(year, month)),
          );
    });

class ExpensesNotifier extends AsyncNotifier<List<ExpenseItem>> {
  @override
  Future<List<ExpenseItem>> build() =>
      ref.read(expenseRepositoryProvider).all();

  Future<ExpenseItem> save(ExpenseItem draft) async {
    final store = ref.read(imageStoreProvider);
    final repository = ref.read(expenseRepositoryProvider);
    String? permanentImage;
    if (draft.imagePath != null) {
      permanentImage = await store.persist(draft.imagePath!);
    }
    late final ExpenseItem saved;
    try {
      saved = await repository.insert(
        draft.copyWith(imagePath: permanentImage),
      );
    } catch (_) {
      await store.remove(permanentImage);
      rethrow;
    }
    await _refresh(repository);
    return saved;
  }

  Future<void> updateExpense(ExpenseItem item) async {
    final repository = ref.read(expenseRepositoryProvider);
    await repository.update(item);
    await _refresh(repository);
  }

  Future<void> deleteExpense(ExpenseItem item) async {
    final repository = ref.read(expenseRepositoryProvider);
    await repository.delete(item.id!);
    await _refresh(repository);
    try {
      await ref.read(imageStoreProvider).remove(item.imagePath);
    } catch (_) {
      // The database deletion succeeded. An orphaned image is safer than
      // reporting the record as still present to the user.
    }
  }

  Future<void> _refresh(ExpenseRepository repository) async {
    try {
      state = AsyncData(await repository.all());
    } catch (_) {
      // The write already committed. Reload on the next read rather than
      // reporting a failed save/delete and encouraging a duplicate retry.
      ref.invalidateSelf();
    }
  }
}
