import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Smart Expense'**
  String get appName;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System theme'**
  String get systemTheme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @monthYear.
  ///
  /// In en, this message translates to:
  /// **'{month}/{year}'**
  String monthYear(int month, int year);

  /// No description provided for @scanOrImport.
  ///
  /// In en, this message translates to:
  /// **'Scan / import'**
  String get scanOrImport;

  /// No description provided for @monthIncrease.
  ///
  /// In en, this message translates to:
  /// **'Up {percent}% vs last month'**
  String monthIncrease(int percent);

  /// No description provided for @monthDecrease.
  ///
  /// In en, this message translates to:
  /// **'Down {percent}% vs last month'**
  String monthDecrease(int percent);

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @retryHint.
  ///
  /// In en, this message translates to:
  /// **'Please try again in a moment.'**
  String get retryHint;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpense;

  /// No description provided for @couldNotLoadExpenses.
  ///
  /// In en, this message translates to:
  /// **'Could not load expenses'**
  String get couldNotLoadExpenses;

  /// No description provided for @captureHeadline.
  ///
  /// In en, this message translates to:
  /// **'Capture what you spend'**
  String get captureHeadline;

  /// No description provided for @captureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bank payments, wallet screenshots, and paper receipts in one place.'**
  String get captureSubtitle;

  /// No description provided for @spentThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Spent this month'**
  String get spentThisMonth;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get monthlyBudget;

  /// No description provided for @setBudget.
  ///
  /// In en, this message translates to:
  /// **'Set budget'**
  String get setBudget;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit budget'**
  String get editBudget;

  /// No description provided for @removeBudget.
  ///
  /// In en, this message translates to:
  /// **'Remove budget'**
  String get removeBudget;

  /// No description provided for @budgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining in budget'**
  String budgetRemaining(String amount);

  /// No description provided for @budgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'Over budget by {amount}'**
  String budgetExceeded(String amount);

  /// No description provided for @budgetSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save budget. Please try again.'**
  String get budgetSaveError;

  /// No description provided for @firstExpenseHint.
  ///
  /// In en, this message translates to:
  /// **'Your first expense starts below'**
  String get firstExpenseHint;

  /// No description provided for @expenseRecords.
  ///
  /// In en, this message translates to:
  /// **'{count} expense records'**
  String expenseRecords(int count);

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noExpensesYet;

  /// No description provided for @emptyExpenseHint.
  ///
  /// In en, this message translates to:
  /// **'Import a payment screenshot, scan a receipt, or add an expense manually.'**
  String get emptyExpenseHint;

  /// No description provided for @chooseSource.
  ///
  /// In en, this message translates to:
  /// **'Choose a source'**
  String get chooseSource;

  /// No description provided for @threeStepFlow.
  ///
  /// In en, this message translates to:
  /// **'THREE SIMPLE STEPS'**
  String get threeStepFlow;

  /// No description provided for @stepPick.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get stepPick;

  /// No description provided for @stepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stepReview;

  /// No description provided for @stepSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get stepSave;

  /// No description provided for @localPrivacyHint.
  ///
  /// In en, this message translates to:
  /// **'OCR runs on this device. AI upload is optional and requires your consent during review.'**
  String get localPrivacyHint;

  /// No description provided for @importPaymentScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Import Payment Screenshot'**
  String get importPaymentScreenshot;

  /// No description provided for @paymentSourceHint.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer, MoMo, ZaloPay, VNPay, or another wallet'**
  String get paymentSourceHint;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get scanReceipt;

  /// No description provided for @scanReceiptHint.
  ///
  /// In en, this message translates to:
  /// **'Photograph a paper receipt with your camera'**
  String get scanReceiptHint;

  /// No description provided for @chooseReceiptPhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose Receipt Photo'**
  String get chooseReceiptPhoto;

  /// No description provided for @chooseReceiptPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Select a paper receipt image from your gallery'**
  String get chooseReceiptPhotoHint;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get manualEntry;

  /// No description provided for @manualEntryHint.
  ///
  /// In en, this message translates to:
  /// **'Add an expense without an image'**
  String get manualEntryHint;

  /// No description provided for @readingImage.
  ///
  /// In en, this message translates to:
  /// **'Reading image on this device…'**
  String get readingImage;

  /// No description provided for @ocrTimeout.
  ///
  /// In en, this message translates to:
  /// **'Recognition took too long. Try a clearer image or enter details manually.'**
  String get ocrTimeout;

  /// No description provided for @ocrError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the image. Check camera or photo access and try again.'**
  String get ocrError;

  /// No description provided for @reviewVerify.
  ///
  /// In en, this message translates to:
  /// **'Review & Verify'**
  String get reviewVerify;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get editExpense;

  /// No description provided for @reviewHeadline.
  ///
  /// In en, this message translates to:
  /// **'Check every detail before saving'**
  String get reviewHeadline;

  /// No description provided for @editHeadline.
  ///
  /// In en, this message translates to:
  /// **'Update the saved details'**
  String get editHeadline;

  /// No description provided for @reviewHint.
  ///
  /// In en, this message translates to:
  /// **'OCR can misread amounts and names. Correct any field that is missing or wrong.'**
  String get reviewHint;

  /// No description provided for @aiReadAgain.
  ///
  /// In en, this message translates to:
  /// **'Read again with AI'**
  String get aiReadAgain;

  /// No description provided for @aiReading.
  ///
  /// In en, this message translates to:
  /// **'AI is reading…'**
  String get aiReading;

  /// No description provided for @aiConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Send this image to Gemini?'**
  String get aiConsentTitle;

  /// No description provided for @aiConsentBody.
  ///
  /// In en, this message translates to:
  /// **'The image and on-device OCR text will be sent to Gemini through your configured proxy. This is optional. Google\'s free tier may use submitted content to improve products. Check privacy terms before sending bank details, then verify every suggestion.'**
  String get aiConsentBody;

  /// No description provided for @aiSendImage.
  ///
  /// In en, this message translates to:
  /// **'Send image'**
  String get aiSendImage;

  /// No description provided for @aiSuggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'AI suggestions'**
  String get aiSuggestionTitle;

  /// No description provided for @aiSuggestionHint.
  ///
  /// In en, this message translates to:
  /// **'AI can make mistakes. Apply these suggestions only after comparing them with the image. You can edit every field afterward.'**
  String get aiSuggestionHint;

  /// No description provided for @aiApplySuggestion.
  ///
  /// In en, this message translates to:
  /// **'Apply suggestions'**
  String get aiApplySuggestion;

  /// No description provided for @aiNoSuggestion.
  ///
  /// In en, this message translates to:
  /// **'AI could not confidently identify any fields. Enter them manually.'**
  String get aiNoSuggestion;

  /// No description provided for @aiReadError.
  ///
  /// In en, this message translates to:
  /// **'AI could not read this image. Check the image format, size, and proxy connection, or continue manually.'**
  String get aiReadError;

  /// No description provided for @imagePreviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image preview unavailable'**
  String get imagePreviewUnavailable;

  /// No description provided for @noOcrText.
  ///
  /// In en, this message translates to:
  /// **'No text was recognized. Enter the details from the image manually.'**
  String get noOcrText;

  /// No description provided for @recipientOrMerchant.
  ///
  /// In en, this message translates to:
  /// **'Recipient or merchant'**
  String get recipientOrMerchant;

  /// No description provided for @merchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get merchant;

  /// No description provided for @notDetected.
  ///
  /// In en, this message translates to:
  /// **'Not detected — enter this manually'**
  String get notDetected;

  /// No description provided for @merchantRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a merchant or recipient'**
  String get merchantRequired;

  /// No description provided for @amountVnd.
  ///
  /// In en, this message translates to:
  /// **'Amount (VND)'**
  String get amountVnd;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'Use digits or Vietnamese thousands separators'**
  String get amountHint;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive amount'**
  String get amountRequired;

  /// No description provided for @transactionDate.
  ///
  /// In en, this message translates to:
  /// **'Transaction date'**
  String get transactionDate;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get chooseDate;

  /// No description provided for @dateRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid date (dd/MM/yyyy)'**
  String get dateRequired;

  /// No description provided for @timeOptional.
  ///
  /// In en, this message translates to:
  /// **'Time (optional)'**
  String get timeOptional;

  /// No description provided for @timeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use 24-hour time (HH:mm)'**
  String get timeInvalid;

  /// No description provided for @transactionStatus.
  ///
  /// In en, this message translates to:
  /// **'Transaction status'**
  String get transactionStatus;

  /// No description provided for @successfulOnly.
  ///
  /// In en, this message translates to:
  /// **'Only confirmed successful payments can be saved'**
  String get successfulOnly;

  /// No description provided for @verifySuccess.
  ///
  /// In en, this message translates to:
  /// **'Verify that this payment succeeded'**
  String get verifySuccess;

  /// No description provided for @bankWalletOptional.
  ///
  /// In en, this message translates to:
  /// **'Bank or wallet (optional)'**
  String get bankWalletOptional;

  /// No description provided for @referenceOptional.
  ///
  /// In en, this message translates to:
  /// **'Transaction reference (optional)'**
  String get referenceOptional;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @viewRecognizedText.
  ///
  /// In en, this message translates to:
  /// **'View recognized text'**
  String get viewRecognizedText;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @confirmSave.
  ///
  /// In en, this message translates to:
  /// **'Confirm & save'**
  String get confirmSave;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @possibleDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicate'**
  String get possibleDuplicate;

  /// No description provided for @duplicateMessage.
  ///
  /// In en, this message translates to:
  /// **'A similar {source} expense for {merchant} is already saved. Save this one too?'**
  String duplicateMessage(String source, String merchant);

  /// No description provided for @reviewAgain.
  ///
  /// In en, this message translates to:
  /// **'Review again'**
  String get reviewAgain;

  /// No description provided for @saveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get saveAnyway;

  /// No description provided for @expenseSaved.
  ///
  /// In en, this message translates to:
  /// **'Expense saved'**
  String get expenseSaved;

  /// No description provided for @expenseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Expense updated'**
  String get expenseUpdated;

  /// No description provided for @couldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save expense. Please try again.'**
  String get couldNotSave;

  /// No description provided for @expenseHistory.
  ///
  /// In en, this message translates to:
  /// **'Expense history'**
  String get expenseHistory;

  /// No description provided for @searchExpenses.
  ///
  /// In en, this message translates to:
  /// **'Search name, amount, or note'**
  String get searchExpenses;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get lastMonth;

  /// No description provided for @chooseMonth.
  ///
  /// In en, this message translates to:
  /// **'Choose month'**
  String get chooseMonth;

  /// No description provided for @noCurrentWeekExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses this week.'**
  String get noCurrentWeekExpenses;

  /// No description provided for @historySummary.
  ///
  /// In en, this message translates to:
  /// **'{count} expenses'**
  String historySummary(int count);

  /// No description provided for @noMatchingExpenses.
  ///
  /// In en, this message translates to:
  /// **'No matching expenses'**
  String get noMatchingExpenses;

  /// No description provided for @adjustFilters.
  ///
  /// In en, this message translates to:
  /// **'Try another search or filter.'**
  String get adjustFilters;

  /// No description provided for @historyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'History unavailable'**
  String get historyUnavailable;

  /// No description provided for @noSavedExpenses.
  ///
  /// In en, this message translates to:
  /// **'No saved expenses'**
  String get noSavedExpenses;

  /// No description provided for @expenseDetails.
  ///
  /// In en, this message translates to:
  /// **'Expense details'**
  String get expenseDetails;

  /// No description provided for @couldNotLoadExpense.
  ///
  /// In en, this message translates to:
  /// **'Could not load expense'**
  String get couldNotLoadExpense;

  /// No description provided for @expenseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Expense not found'**
  String get expenseNotFound;

  /// No description provided for @mayHaveBeenDeleted.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted.'**
  String get mayHaveBeenDeleted;

  /// No description provided for @deleteExpenseQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete expense?'**
  String get deleteExpenseQuestion;

  /// No description provided for @deleteExpenseHint.
  ///
  /// In en, this message translates to:
  /// **'This record and its stored image will be removed.'**
  String get deleteExpenseHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete this expense.'**
  String get deleteFailed;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @imageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get imageUnavailable;

  /// No description provided for @savedRecordUsable.
  ///
  /// In en, this message translates to:
  /// **'The saved text record is still usable.'**
  String get savedRecordUsable;

  /// No description provided for @deleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete expense'**
  String get deleteExpense;

  /// No description provided for @insightsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Insights unavailable'**
  String get insightsUnavailable;

  /// No description provided for @nothingToChart.
  ///
  /// In en, this message translates to:
  /// **'Nothing to chart yet'**
  String get nothingToChart;

  /// No description provided for @emptyChartHint.
  ///
  /// In en, this message translates to:
  /// **'Your saved expenses will appear here.'**
  String get emptyChartHint;

  /// No description provided for @noCurrentPeriodExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month or week. Older records remain in History.'**
  String get noCurrentPeriodExpenses;

  /// No description provided for @spendingOverview.
  ///
  /// In en, this message translates to:
  /// **'Spending overview'**
  String get spendingOverview;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get byCategory;

  /// No description provided for @spendingNote.
  ///
  /// In en, this message translates to:
  /// **'From your data'**
  String get spendingNote;

  /// No description provided for @topCategoryInsight.
  ///
  /// In en, this message translates to:
  /// **'Largest category: {category}, {percent}% of spending in the selected month.'**
  String topCategoryInsight(String category, int percent);

  /// No description provided for @noExpensesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month.'**
  String get noExpensesThisMonth;

  /// No description provided for @chartUsesTransactionDate.
  ///
  /// In en, this message translates to:
  /// **'Bars use the verified transaction date.'**
  String get chartUsesTransactionDate;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String fromDate(String date);

  /// No description provided for @allSpending.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get allSpending;

  /// No description provided for @categoryChartSemantics.
  ///
  /// In en, this message translates to:
  /// **'Spending by category, total {amount}'**
  String categoryChartSemantics(String amount);

  /// No description provided for @weekChartSemantics.
  ///
  /// In en, this message translates to:
  /// **'This week spending {amount}'**
  String weekChartSemantics(String amount);

  /// No description provided for @pageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Page unavailable'**
  String get pageUnavailable;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get bankTransfer;

  /// No description provided for @eWallet.
  ///
  /// In en, this message translates to:
  /// **'E-wallet'**
  String get eWallet;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @successful.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get successful;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @needsVerification.
  ///
  /// In en, this message translates to:
  /// **'Needs verification'**
  String get needsVerification;

  /// No description provided for @foodDrink.
  ///
  /// In en, this message translates to:
  /// **'Food & drink'**
  String get foodDrink;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @study.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get study;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
