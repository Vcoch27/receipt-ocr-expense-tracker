// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Sổ chi tiêu';

  @override
  String get appearance => 'Giao diện';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get systemTheme => 'Theo hệ thống';

  @override
  String get lightMode => 'Chế độ sáng';

  @override
  String get darkMode => 'Chế độ tối';

  @override
  String get home => 'Trang chủ';

  @override
  String get history => 'Lịch sử';

  @override
  String get insights => 'Thống kê';

  @override
  String get tryAgain => 'Thử lại';

  @override
  String get retryHint => 'Vui lòng thử lại sau ít phút.';

  @override
  String get add => 'Thêm';

  @override
  String get addExpense => 'Thêm khoản chi';

  @override
  String get couldNotLoadExpenses => 'Không tải được khoản chi';

  @override
  String get captureHeadline => 'Ghi lại từng khoản chi';

  @override
  String get captureSubtitle =>
      'Lưu giao dịch ngân hàng, ví điện tử và hóa đơn giấy tại một nơi.';

  @override
  String get spentThisMonth => 'Đã chi trong tháng';

  @override
  String get firstExpenseHint => 'Thêm khoản chi đầu tiên bên dưới';

  @override
  String expenseRecords(int count) {
    return '$count khoản chi';
  }

  @override
  String get recentActivity => 'Gần đây';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get noExpensesYet => 'Chưa có khoản chi';

  @override
  String get emptyExpenseHint =>
      'Nhập ảnh thanh toán, quét hóa đơn hoặc thêm thủ công.';

  @override
  String get chooseSource => 'Chọn nguồn khoản chi';

  @override
  String get localPrivacyHint =>
      'Ảnh chỉ ở trên thiết bị. Bạn luôn kiểm tra kết quả OCR trước khi lưu.';

  @override
  String get importPaymentScreenshot => 'Nhập ảnh thanh toán';

  @override
  String get paymentSourceHint =>
      'Chuyển khoản ngân hàng, MoMo, ZaloPay, VNPay hoặc ví khác';

  @override
  String get scanReceipt => 'Quét hóa đơn';

  @override
  String get scanReceiptHint => 'Chụp hóa đơn giấy bằng camera';

  @override
  String get chooseReceiptPhoto => 'Chọn ảnh hóa đơn';

  @override
  String get chooseReceiptPhotoHint => 'Chọn ảnh hóa đơn giấy trong thư viện';

  @override
  String get manualEntry => 'Nhập thủ công';

  @override
  String get manualEntryHint => 'Thêm khoản chi không cần ảnh';

  @override
  String get readingImage => 'Đang đọc ảnh trên thiết bị…';

  @override
  String get ocrTimeout =>
      'Nhận dạng quá lâu. Hãy chọn ảnh rõ hơn hoặc nhập thủ công.';

  @override
  String get ocrError =>
      'Không đọc được ảnh. Kiểm tra quyền camera hoặc ảnh rồi thử lại.';

  @override
  String get reviewVerify => 'Kiểm tra & xác nhận';

  @override
  String get editExpense => 'Sửa khoản chi';

  @override
  String get reviewHeadline => 'Kiểm tra trước khi lưu';

  @override
  String get editHeadline => 'Cập nhật thông tin đã lưu';

  @override
  String get reviewHint =>
      'OCR có thể đọc sai số tiền và tên. Hãy sửa các trường còn thiếu hoặc chưa đúng.';

  @override
  String get imagePreviewUnavailable => 'Không xem trước được ảnh';

  @override
  String get noOcrText =>
      'Không nhận dạng được chữ. Hãy nhập thông tin từ ảnh thủ công.';

  @override
  String get recipientOrMerchant => 'Người nhận hoặc cửa hàng';

  @override
  String get merchant => 'Cửa hàng';

  @override
  String get notDetected => 'Chưa nhận dạng — hãy nhập thủ công';

  @override
  String get merchantRequired => 'Nhập người nhận hoặc cửa hàng';

  @override
  String get amountVnd => 'Số tiền (VND)';

  @override
  String get amountHint => 'Dùng chữ số hoặc dấu tách hàng nghìn';

  @override
  String get amountRequired => 'Nhập số tiền lớn hơn 0';

  @override
  String get transactionDate => 'Ngày giao dịch';

  @override
  String get chooseDate => 'Chọn ngày';

  @override
  String get dateRequired => 'Nhập ngày hợp lệ (dd/MM/yyyy)';

  @override
  String get timeOptional => 'Giờ (không bắt buộc)';

  @override
  String get timeInvalid => 'Dùng định dạng 24 giờ (HH:mm)';

  @override
  String get transactionStatus => 'Trạng thái giao dịch';

  @override
  String get successfulOnly => 'Chỉ lưu giao dịch đã xác nhận thành công';

  @override
  String get verifySuccess => 'Hãy xác minh giao dịch đã thành công';

  @override
  String get bankWalletOptional => 'Ngân hàng hoặc ví (không bắt buộc)';

  @override
  String get referenceOptional => 'Mã giao dịch (không bắt buộc)';

  @override
  String get category => 'Danh mục';

  @override
  String get noteOptional => 'Nội dung chuyển khoản / ghi chú (không bắt buộc)';

  @override
  String get viewRecognizedText => 'Xem văn bản OCR';

  @override
  String get saving => 'Đang lưu…';

  @override
  String get confirmSave => 'Xác nhận & lưu';

  @override
  String get saveChanges => 'Lưu thay đổi';

  @override
  String get possibleDuplicate => 'Có thể bị trùng';

  @override
  String duplicateMessage(String source, String merchant) {
    return 'Đã có khoản chi $source tương tự cho $merchant. Bạn vẫn muốn lưu?';
  }

  @override
  String get reviewAgain => 'Kiểm tra lại';

  @override
  String get saveAnyway => 'Vẫn lưu';

  @override
  String get expenseSaved => 'Đã lưu khoản chi';

  @override
  String get expenseUpdated => 'Đã cập nhật khoản chi';

  @override
  String get couldNotSave => 'Không lưu được khoản chi. Hãy thử lại.';

  @override
  String get expenseHistory => 'Lịch sử chi tiêu';

  @override
  String get historyUnavailable => 'Không tải được lịch sử';

  @override
  String get noSavedExpenses => 'Chưa lưu khoản chi nào';

  @override
  String get expenseDetails => 'Chi tiết khoản chi';

  @override
  String get couldNotLoadExpense => 'Không tải được khoản chi';

  @override
  String get expenseNotFound => 'Không tìm thấy khoản chi';

  @override
  String get mayHaveBeenDeleted => 'Khoản chi có thể đã bị xóa.';

  @override
  String get deleteExpenseQuestion => 'Xóa khoản chi?';

  @override
  String get deleteExpenseHint => 'Bản ghi và ảnh đã lưu sẽ bị xóa.';

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';

  @override
  String get deleteFailed => 'Không xóa được khoản chi.';

  @override
  String get date => 'Ngày';

  @override
  String get source => 'Nguồn';

  @override
  String get time => 'Giờ';

  @override
  String get provider => 'Ngân hàng / ví';

  @override
  String get reference => 'Mã giao dịch';

  @override
  String get note => 'Ghi chú';

  @override
  String get imageUnavailable => 'Không có ảnh';

  @override
  String get savedRecordUsable => 'Bạn vẫn có thể xem bản ghi đã lưu.';

  @override
  String get deleteExpense => 'Xóa khoản chi';

  @override
  String get insightsUnavailable => 'Không tải được thống kê';

  @override
  String get nothingToChart => 'Chưa có dữ liệu biểu đồ';

  @override
  String get emptyChartHint => 'Khoản chi đã lưu sẽ xuất hiện tại đây.';

  @override
  String get spendingOverview => 'Tổng quan chi tiêu';

  @override
  String get byCategory => 'Theo danh mục';

  @override
  String get thisWeek => 'Tuần này';

  @override
  String fromDate(String date) {
    return 'Từ $date';
  }

  @override
  String get allSpending => 'Tổng chi';

  @override
  String categoryChartSemantics(String amount) {
    return 'Chi tiêu theo danh mục, tổng $amount';
  }

  @override
  String weekChartSemantics(String amount) {
    return 'Chi tiêu tuần này $amount';
  }

  @override
  String get pageUnavailable => 'Không mở được trang';

  @override
  String get pageNotFound => 'Không tìm thấy trang';

  @override
  String get receipt => 'Hóa đơn';

  @override
  String get bankTransfer => 'Chuyển khoản';

  @override
  String get eWallet => 'Ví điện tử';

  @override
  String get manual => 'Thủ công';

  @override
  String get successful => 'Thành công';

  @override
  String get pending => 'Đang xử lý';

  @override
  String get failed => 'Thất bại';

  @override
  String get needsVerification => 'Cần xác minh';

  @override
  String get foodDrink => 'Ăn uống';

  @override
  String get transport => 'Di chuyển';

  @override
  String get shopping => 'Mua sắm';

  @override
  String get study => 'Học tập';

  @override
  String get other => 'Khác';

  @override
  String get mon => 'T2';

  @override
  String get tue => 'T3';

  @override
  String get wed => 'T4';

  @override
  String get thu => 'T5';

  @override
  String get fri => 'T6';

  @override
  String get sat => 'T7';

  @override
  String get sun => 'CN';
}
