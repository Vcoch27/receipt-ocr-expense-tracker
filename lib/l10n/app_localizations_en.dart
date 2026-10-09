// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Smart Expense';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get systemTheme => 'System theme';

  @override
  String get lightMode => 'Light mode';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get insights => 'Insights';

  @override
  String get tryAgain => 'Try again';

  @override
  String get retryHint => 'Please try again in a moment.';

  @override
  String get add => 'Add';

  @override
  String get addExpense => 'Add expense';

  @override
  String get couldNotLoadExpenses => 'Could not load expenses';

  @override
  String get captureHeadline => 'Capture what you spend';

  @override
  String get captureSubtitle =>
      'Bank payments, wallet screenshots, and paper receipts in one place.';

  @override
  String get spentThisMonth => 'Spent this month';

  @override
  String get firstExpenseHint => 'Your first expense starts below';

  @override
  String expenseRecords(int count) {
    return '$count expense records';
  }

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get viewAll => 'View all';

  @override
  String get noExpensesYet => 'No expenses yet';

  @override
  String get emptyExpenseHint =>
      'Import a payment screenshot, scan a receipt, or add an expense manually.';

  @override
  String get chooseSource => 'Choose a source';

  @override
  String get localPrivacyHint =>
      'OCR runs on this device. AI upload is optional and requires your consent during review.';

  @override
  String get importPaymentScreenshot => 'Import Payment Screenshot';

  @override
  String get paymentSourceHint =>
      'Bank transfer, MoMo, ZaloPay, VNPay, or another wallet';

  @override
  String get scanReceipt => 'Scan Receipt';

  @override
  String get scanReceiptHint => 'Photograph a paper receipt with your camera';

  @override
  String get chooseReceiptPhoto => 'Choose Receipt Photo';

  @override
  String get chooseReceiptPhotoHint =>
      'Select a paper receipt image from your gallery';

  @override
  String get manualEntry => 'Manual Entry';

  @override
  String get manualEntryHint => 'Add an expense without an image';

  @override
  String get readingImage => 'Reading image on this device…';

  @override
  String get ocrTimeout =>
      'Recognition took too long. Try a clearer image or enter details manually.';

  @override
  String get ocrError =>
      'Could not read the image. Check camera or photo access and try again.';

  @override
  String get reviewVerify => 'Review & Verify';

  @override
  String get editExpense => 'Edit expense';

  @override
  String get reviewHeadline => 'Check every detail before saving';

  @override
  String get editHeadline => 'Update the saved details';

  @override
  String get reviewHint =>
      'OCR can misread amounts and names. Correct any field that is missing or wrong.';

  @override
  String get aiReadAgain => 'Read again with AI';

  @override
  String get aiReading => 'AI is reading…';

  @override
  String get aiConsentTitle => 'Send this image to Gemini?';

  @override
  String get aiConsentBody =>
      'The image and on-device OCR text will be sent to Gemini through your configured proxy. This is optional. Google\'s free tier may use submitted content to improve products. Check privacy terms before sending bank details, then verify every suggestion.';

  @override
  String get aiSendImage => 'Send image';

  @override
  String get aiSuggestionTitle => 'AI suggestions';

  @override
  String get aiSuggestionHint =>
      'AI can make mistakes. Apply these suggestions only after comparing them with the image. You can edit every field afterward.';

  @override
  String get aiApplySuggestion => 'Apply suggestions';

  @override
  String get aiNoSuggestion =>
      'AI could not confidently identify any fields. Enter them manually.';

  @override
  String get aiReadError =>
      'AI reading failed. Check the proxy connection or continue manually.';

  @override
  String get imagePreviewUnavailable => 'Image preview unavailable';

  @override
  String get noOcrText =>
      'No text was recognized. Enter the details from the image manually.';

  @override
  String get recipientOrMerchant => 'Recipient or merchant';

  @override
  String get merchant => 'Merchant';

  @override
  String get notDetected => 'Not detected — enter this manually';

  @override
  String get merchantRequired => 'Enter a merchant or recipient';

  @override
  String get amountVnd => 'Amount (VND)';

  @override
  String get amountHint => 'Use digits or Vietnamese thousands separators';

  @override
  String get amountRequired => 'Enter a positive amount';

  @override
  String get transactionDate => 'Transaction date';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get dateRequired => 'Enter a valid date (dd/MM/yyyy)';

  @override
  String get timeOptional => 'Time (optional)';

  @override
  String get timeInvalid => 'Use 24-hour time (HH:mm)';

  @override
  String get transactionStatus => 'Transaction status';

  @override
  String get successfulOnly =>
      'Only confirmed successful payments can be saved';

  @override
  String get verifySuccess => 'Verify that this payment succeeded';

  @override
  String get bankWalletOptional => 'Bank or wallet (optional)';

  @override
  String get referenceOptional => 'Transaction reference (optional)';

  @override
  String get category => 'Category';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get viewRecognizedText => 'View recognized text';

  @override
  String get saving => 'Saving…';

  @override
  String get confirmSave => 'Confirm & save';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get possibleDuplicate => 'Possible duplicate';

  @override
  String duplicateMessage(String source, String merchant) {
    return 'A similar $source expense for $merchant is already saved. Save this one too?';
  }

  @override
  String get reviewAgain => 'Review again';

  @override
  String get saveAnyway => 'Save anyway';

  @override
  String get expenseSaved => 'Expense saved';

  @override
  String get expenseUpdated => 'Expense updated';

  @override
  String get couldNotSave => 'Could not save expense. Please try again.';

  @override
  String get expenseHistory => 'Expense history';

  @override
  String get historyUnavailable => 'History unavailable';

  @override
  String get noSavedExpenses => 'No saved expenses';

  @override
  String get expenseDetails => 'Expense details';

  @override
  String get couldNotLoadExpense => 'Could not load expense';

  @override
  String get expenseNotFound => 'Expense not found';

  @override
  String get mayHaveBeenDeleted => 'It may have been deleted.';

  @override
  String get deleteExpenseQuestion => 'Delete expense?';

  @override
  String get deleteExpenseHint =>
      'This record and its stored image will be removed.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteFailed => 'Could not delete this expense.';

  @override
  String get date => 'Date';

  @override
  String get source => 'Source';

  @override
  String get time => 'Time';

  @override
  String get provider => 'Provider';

  @override
  String get reference => 'Reference';

  @override
  String get note => 'Note';

  @override
  String get imageUnavailable => 'Image unavailable';

  @override
  String get savedRecordUsable => 'The saved text record is still usable.';

  @override
  String get deleteExpense => 'Delete expense';

  @override
  String get insightsUnavailable => 'Insights unavailable';

  @override
  String get nothingToChart => 'Nothing to chart yet';

  @override
  String get emptyChartHint => 'Your saved expenses will appear here.';

  @override
  String get noCurrentPeriodExpenses =>
      'No expenses this month or week. Older records remain in History.';

  @override
  String get spendingOverview => 'Spending overview';

  @override
  String get byCategory => 'By category';

  @override
  String get noExpensesThisMonth => 'No expenses this month.';

  @override
  String get chartUsesTransactionDate =>
      'Bars use the verified transaction date.';

  @override
  String get thisWeek => 'This week';

  @override
  String fromDate(String date) {
    return 'From $date';
  }

  @override
  String get allSpending => 'This month';

  @override
  String categoryChartSemantics(String amount) {
    return 'This month\'s spending by category, total $amount';
  }

  @override
  String weekChartSemantics(String amount) {
    return 'This week spending $amount';
  }

  @override
  String get pageUnavailable => 'Page unavailable';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get receipt => 'Receipt';

  @override
  String get bankTransfer => 'Bank transfer';

  @override
  String get eWallet => 'E-wallet';

  @override
  String get manual => 'Manual';

  @override
  String get successful => 'Successful';

  @override
  String get pending => 'Pending';

  @override
  String get failed => 'Failed';

  @override
  String get needsVerification => 'Needs verification';

  @override
  String get foodDrink => 'Food & drink';

  @override
  String get transport => 'Transport';

  @override
  String get shopping => 'Shopping';

  @override
  String get study => 'Study';

  @override
  String get other => 'Other';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';
}
