import '../models/expense_source.dart';
import 'text_normalization.dart';

class ExpenseSourceClassifier {
  const ExpenseSourceClassifier();

  ExpenseSource classifyPayment(String rawText) {
    final text = foldVietnamese(rawText);
    if (RegExp(r'\b(momo|zalopay|vnpay|shopeepay|vi dien tu|e-wallet)\b')
        .hasMatch(text)) {
      return ExpenseSource.eWalletScreenshot;
    }
    return ExpenseSource.bankScreenshot;
  }
}
