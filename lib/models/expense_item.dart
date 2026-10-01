import 'expense_source.dart';

class ExpenseItem {
  const ExpenseItem({
    this.id,
    required this.merchant,
    required this.amount,
    required this.date,
    required this.category,
    required this.source,
    this.status,
    this.paymentProvider,
    this.transactionReference,
    this.note,
    this.imagePath,
    this.rawOcrText,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String merchant;
  final int amount;
  final DateTime date;
  final String category;
  final ExpenseSource source;
  final PaymentStatus? status;
  final String? paymentProvider;
  final String? transactionReference;
  final String? note;
  final String? imagePath;
  final String? rawOcrText;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseItem copyWith({
    int? id,
    String? merchant,
    int? amount,
    DateTime? date,
    String? category,
    ExpenseSource? source,
    PaymentStatus? status,
    String? paymentProvider,
    String? transactionReference,
    String? note,
    String? imagePath,
    String? rawOcrText,
    DateTime? updatedAt,
  }) => ExpenseItem(
    id: id ?? this.id,
    merchant: merchant ?? this.merchant,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    category: category ?? this.category,
    source: source ?? this.source,
    status: status ?? this.status,
    paymentProvider: paymentProvider ?? this.paymentProvider,
    transactionReference: transactionReference ?? this.transactionReference,
    note: note ?? this.note,
    imagePath: imagePath ?? this.imagePath,
    rawOcrText: rawOcrText ?? this.rawOcrText,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, Object?> toMap() => {
    'merchant': merchant,
    'amount': amount,
    'date': date.toIso8601String(),
    'category': category,
    'source': source.name,
    'status': status?.name,
    'payment_provider': paymentProvider,
    'transaction_reference': transactionReference,
    'note': note,
    'image_path': imagePath,
    'raw_ocr_text': rawOcrText,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory ExpenseItem.fromMap(Map<String, Object?> map) => ExpenseItem(
    id: map['id'] as int,
    merchant: map['merchant'] as String,
    amount: map['amount'] as int,
    date: DateTime.parse(map['date'] as String),
    category: map['category'] as String,
    source: ExpenseSource.values.byName(
      (map['source'] as String?) ?? 'receipt',
    ),
    status: (map['status'] as String?) == null
        ? null
        : PaymentStatus.values.byName(map['status'] as String),
    paymentProvider: map['payment_provider'] as String?,
    transactionReference: map['transaction_reference'] as String?,
    note: map['note'] as String?,
    imagePath: map['image_path'] as String?,
    rawOcrText: map['raw_ocr_text'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );
}
