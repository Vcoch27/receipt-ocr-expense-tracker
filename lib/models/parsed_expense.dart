import 'expense_source.dart';
import 'parsed_receipt.dart';

class ParsedExpense {
  const ParsedExpense({
    required this.source,
    this.merchant,
    this.amount,
    this.date,
    this.status,
    this.paymentProvider,
    this.transactionReference,
    this.note,
    required this.rawText,
    this.imagePath,
  });

  final ExpenseSource source;
  final String? merchant;
  final int? amount;
  final DateTime? date;
  final PaymentStatus? status;
  final String? paymentProvider;
  final String? transactionReference;
  final String? note;
  final String rawText;
  final String? imagePath;

  factory ParsedExpense.fromReceipt(ParsedReceipt receipt) => ParsedExpense(
    source: ExpenseSource.receipt,
    merchant: receipt.merchant,
    amount: receipt.total,
    date: receipt.date,
    rawText: receipt.rawText,
    imagePath: receipt.imagePath,
  );

  const ParsedExpense.manual()
    : source = ExpenseSource.manual,
      merchant = null,
      amount = null,
      date = null,
      status = null,
      paymentProvider = null,
      transactionReference = null,
      note = null,
      rawText = '',
      imagePath = null;
}
