import 'package:sqflite/sqflite.dart';

import '../models/expense_item.dart';
import '../models/expense_source.dart';

class DemoDataSeeder {
  static const int currentMonthKey = 2026 * 12 + 10; // 24322 (Oct 2026)
  static const int previousMonthKey = 2026 * 12 + 9; // 24321 (Sep 2026)
  static const int currentMonthBudget = 8000000; // 8.000.000 VND
  static const int previousMonthBudget = 7000000; // 7.000.000 VND

  static List<ExpenseItem> getDemoExpenses() {
    return [
      // --- THÁNG 10/2026 (TUẦN NÀY: 05/10 - 11/10) ---
      // Thứ 6 (09/10/2026 - Hôm nay)
      ExpenseItem(
        merchant: 'Highlands Coffee',
        amount: 59000,
        date: DateTime(2026, 10, 9, 8, 30),
        category: 'Food & drink',
        source: ExpenseSource.eWalletScreenshot,
        status: PaymentStatus.successful,
        paymentProvider: 'MoMo',
        transactionReference: 'MM2610098821',
        note: 'Phin sữa đá cỡ lớn sáng thứ 6',
        rawOcrText:
            'MoMo\nThanh toán thành công\nSố tiền: 59.000 đ\nĐến: Highlands Coffee\nThời gian: 09/10/2026 08:30\nMã GD: MM2610098821',
        createdAt: DateTime(2026, 10, 9, 8, 31),
        updatedAt: DateTime(2026, 10, 9, 8, 31),
      ),
      ExpenseItem(
        merchant: 'Phở Thìn Lò Đúc',
        amount: 65000,
        date: DateTime(2026, 10, 9, 12, 15),
        category: 'Food & drink',
        source: ExpenseSource.bankScreenshot,
        status: PaymentStatus.successful,
        paymentProvider: 'Vietcombank',
        transactionReference: 'VCB2610094510',
        note: 'Ăn trưa phở tái lăn',
        rawOcrText:
            'Vietcombank\nChuyển khoản thành công\nSố tiền: 65.000 đ\nNgười nhận: PHO THIN LO DUC\nThời gian: 09/10/2026 12:15\nMã giao dịch: VCB2610094510',
        createdAt: DateTime(2026, 10, 9, 12, 16),
        updatedAt: DateTime(2026, 10, 9, 12, 16),
      ),
      ExpenseItem(
        merchant: 'Nhà thuốc FPT Long Châu',
        amount: 145000,
        date: DateTime(2026, 10, 9, 17, 45),
        category: 'Other',
        source: ExpenseSource.receipt,
        status: PaymentStatus.successful,
        note: 'Vitamin C sủi & khẩu trang y tế',
        rawOcrText:
            'NHA THUOC FPT LONG CHAU\nHOA DON BAN LE\nNgay: 09/10/2026 17:45\n1. Vitamin C Effervescent: 75.000\n2. Khau trang 4 lop: 70.000\nTong tien: 145.000 d\nCam on quy khach!',
        createdAt: DateTime(2026, 10, 9, 17, 46),
        updatedAt: DateTime(2026, 10, 9, 17, 46),
      ),

      // Thứ 5 (08/10/2026)
      ExpenseItem(
        merchant: 'Xanh SM Taxi',
        amount: 78000,
        date: DateTime(2026, 10, 8, 9, 10),
        category: 'Transport',
        source: ExpenseSource.eWalletScreenshot,
        status: PaymentStatus.successful,
        paymentProvider: 'ZaloPay',
        transactionReference: 'ZP2610089012',
        note: 'Xe điện Xanh SM đi trường VKU',
        rawOcrText:
            'ZaloPay\nGiao dịch thành công\nSố tiền: 78.000 đ\nĐến: GSM Smart Mobility (Xanh SM)\nThời gian: 08/10/2026 09:10\nMã GD: ZP2610089012',
        createdAt: DateTime(2026, 10, 8, 9, 11),
        updatedAt: DateTime(2026, 10, 8, 9, 11),
      ),
      ExpenseItem(
        merchant: 'ShopeeFood - Cơm gà',
        amount: 55000,
        date: DateTime(2026, 10, 8, 19, 30),
        category: 'Food & drink',
        source: ExpenseSource.eWalletScreenshot,
        status: PaymentStatus.successful,
        paymentProvider: 'ShopeePay',
        transactionReference: 'SP2610083319',
        note: 'Cơm gà xối mỡ tối thứ 5',
        rawOcrText:
            'ShopeePay\nThanh toán thành công\nSố tiền: 55.000 VNĐ\nĐến: ShopeeFood - Com ga\nThời gian: 08/10/2026 19:30',
        createdAt: DateTime(2026, 10, 8, 19, 31),
        updatedAt: DateTime(2026, 10, 8, 19, 31),
      ),

      // Thứ 4 (07/10/2026)
      ExpenseItem(
        merchant: 'Nhà sách Fahasa',
        amount: 285000,
        date: DateTime(2026, 10, 7, 14, 20),
        category: 'Study',
        source: ExpenseSource.receipt,
        status: PaymentStatus.successful,
        note: 'Giáo trình Lập trình di động Flutter & sổ tay',
        rawOcrText:
            'NHA SACH FAHASA DA NANG\nHOA DON GTGT\nNgay: 07/10/2026 14:20\n1. Flutter in Action: 220.000\n2. So tay A5: 65.000\nTong thanh toan: 285.000 VND',
        createdAt: DateTime(2026, 10, 7, 14, 21),
        updatedAt: DateTime(2026, 10, 7, 14, 21),
      ),
      ExpenseItem(
        merchant: 'Cơm tấm Sài Gòn',
        amount: 45000,
        date: DateTime(2026, 10, 7, 18, 0),
        category: 'Food & drink',
        source: ExpenseSource.manual,
        status: PaymentStatus.successful,
        note: 'Cơm sườn chả trứng - Tiền mặt',
        createdAt: DateTime(2026, 10, 7, 18, 1),
        updatedAt: DateTime(2026, 10, 7, 18, 1),
      ),

      // Thứ 3 (06/10/2026)
      ExpenseItem(
        merchant: 'Petrolimex Sông Hàn',
        amount: 70000,
        date: DateTime(2026, 10, 6, 8, 0),
        category: 'Transport',
        source: ExpenseSource.bankScreenshot,
        status: PaymentStatus.successful,
        paymentProvider: 'MB Bank',
        transactionReference: 'MB2610065123',
        note: 'Đổ xăng xe máy Ron 95',
        rawOcrText:
            'MB Bank\nChuyển khoản thành công\nSố tiền: 70.000 đ\nNgười nhận: PETROLIMEX\nThời gian: 06/10/2026 08:00\nMã GD: MB2610065123',
        createdAt: DateTime(2026, 10, 6, 8, 1),
        updatedAt: DateTime(2026, 10, 6, 8, 1),
      ),
      ExpenseItem(
        merchant: 'Trà sữa Phúc Long',
        amount: 65000,
        date: DateTime(2026, 10, 6, 15, 30),
        category: 'Food & drink',
        source: ExpenseSource.eWalletScreenshot,
        status: PaymentStatus.successful,
        paymentProvider: 'MoMo',
        transactionReference: 'MM2610067710',
        note: 'Trà lài đác thơm Phúc Long',
        rawOcrText:
            'MoMo\nThanh toán thành công\nSố tiền: 65.000 đ\nĐến: Phuc Long Coffee & Tea\nThời gian: 06/10/2026 15:30',
        createdAt: DateTime(2026, 10, 6, 15, 31),
        updatedAt: DateTime(2026, 10, 6, 15, 31),
      ),

      // Thứ 2 (05/10/2026 - Đầu tuần)
      ExpenseItem(
        merchant: 'GrabBike',
        amount: 32000,
        date: DateTime(2026, 10, 5, 10, 15),
        category: 'Transport',
        source: ExpenseSource.bankScreenshot,
        status: PaymentStatus.successful,
        paymentProvider: 'Vietcombank',
        transactionReference: 'VCB2610051189',
        note: 'Chuyến xe Grab sang thư viện',
        rawOcrText:
            'Vietcombank\nChuyển khoản thành công\nSố tiền: 32.000 đ\nNgười nhận: Grab Vietnam\nThời gian: 05/10/2026 10:15',
        createdAt: DateTime(2026, 10, 5, 10, 16),
        updatedAt: DateTime(2026, 10, 5, 10, 16),
      ),
      ExpenseItem(
        merchant: 'Siêu thị WinMart+',
        amount: 235000,
        date: DateTime(2026, 10, 5, 19, 40),
        category: 'Shopping',
        source: ExpenseSource.receipt,
        status: PaymentStatus.successful,
        note: 'Thực phẩm tuần mới: sữa, hoa quả, mì',
        rawOcrText:
            'WINMART+\nHOA DON BAN HANG\nNgay: 05/10/2026 19:40\nSua tuoi Vinamilk: 65.000\nBanh mi: 30.000\nTao Envy: 140.000\nTong tien: 235.000 VND',
        createdAt: DateTime(2026, 10, 5, 19, 41),
        updatedAt: DateTime(2026, 10, 5, 19, 41),
      ),

      // Các khoản đầu tháng 10
      ExpenseItem(
        merchant: 'Shopee - Phụ kiện điện tử',
        amount: 265000,
        date: DateTime(2026, 10, 4, 11, 20),
        category: 'Shopping',
        source: ExpenseSource.eWalletScreenshot,
        status: PaymentStatus.pending,
        paymentProvider: 'ShopeePay',
        transactionReference: 'SP2610041288',
        note: 'Chuột không dây & lót chuột (đang xử lý)',
        rawOcrText:
            'ShopeePay\nGiao dịch đang xử lý\nSố tiền: 265.000 VNĐ\nĐến: Shopee Express\nThời gian: 04/10/2026 11:20',
        createdAt: DateTime(2026, 10, 4, 11, 21),
        updatedAt: DateTime(2026, 10, 4, 11, 21),
      ),
      ExpenseItem(
        merchant: 'Uniqlo Vincom',
        amount: 499000,
        date: DateTime(2026, 10, 3, 14, 0),
        category: 'Shopping',
        source: ExpenseSource.receipt,
        status: PaymentStatus.successful,
        note: 'Áo polo công sở',
        rawOcrText:
            'UNIQLO VINCOM\nHOA DON\nNgay: 03/10/2026 14:00\nAirism Polo: 499.000\nTong cong: 499.000 VND',
        createdAt: DateTime(2026, 10, 3, 14, 1),
        updatedAt: DateTime(2026, 10, 3, 14, 1),
      ),
      ExpenseItem(
        merchant: 'Pizza 4P\'s',
        amount: 420000,
        date: DateTime(2026, 10, 2, 20, 30),
        category: 'Food & drink',
        source: ExpenseSource.bankScreenshot,
        status: PaymentStatus.successful,
        paymentProvider: 'Techcombank',
        transactionReference: 'TCB2610029981',
        note: 'Ăn tối họp nhóm đồ án',
        rawOcrText:
            'Techcombank\nChuyển khoản thành công\nSố tiền: 420.000 đ\nNgười nhận: PIZZA 4PS\nThời gian: 02/10/2026 20:30\nMã giao dịch: TCB2610029981',
        createdAt: DateTime(2026, 10, 2, 20, 31),
        updatedAt: DateTime(2026, 10, 2, 20, 31),
      ),
      ExpenseItem(
        merchant: 'Tiền phòng trọ T10',
        amount: 2600000,
        date: DateTime(2026, 10, 1, 10, 0),
        category: 'Other',
        source: ExpenseSource.bankScreenshot,
        status: PaymentStatus.successful,
        paymentProvider: 'Vietcombank',
        transactionReference: 'VCB2610010045',
        note: 'Tiền phòng trọ + điện nước tháng 10',
        rawOcrText:
            'Vietcombank\nChuyển khoản thành công\nSố tiền: 2.600.000 đ\nNgười nhận: NGUYEN THI MAI (CHU NHA)\nThời gian: 01/10/2026 10:00\nMã GD: VCB2610010045',
        createdAt: DateTime(2026, 10, 1, 10, 1),
        updatedAt: DateTime(2026, 10, 1, 10, 1),
      ),
      ExpenseItem(
        merchant: 'Tài liệu môn Học máy & AI',
        amount: 180000,
        date: DateTime(2026, 10, 1, 16, 30),
        category: 'Study',
        source: ExpenseSource.manual,
        status: PaymentStatus.successful,
        note: 'In ấn tài liệu slide và đề cương',
        createdAt: DateTime(2026, 10, 1, 16, 31),
        updatedAt: DateTime(2026, 10, 1, 16, 31),
      ),

      // --- THÁNG 9/2026 (THÁNG TRƯỚC ĐỂ SO SÁNH) ---
      ExpenseItem(
        merchant: 'Siêu thị Co.opmart',
        amount: 350000,
        date: DateTime(2026, 9, 25, 18, 30),
        category: 'Shopping',
        source: ExpenseSource.receipt,
        status: PaymentStatus.successful,
        note: 'Đồ dùng cá nhân',
        createdAt: DateTime(2026, 9, 25, 18, 31),
        updatedAt: DateTime(2026, 9, 25, 18, 31),
      ),
      ExpenseItem(
        merchant: 'GrabBike',
        amount: 42000,
        date: DateTime(2026, 9, 22, 11, 0),
        category: 'Transport',
        source: ExpenseSource.bankScreenshot,
        status: PaymentStatus.successful,
        paymentProvider: 'Vietcombank',
        transactionReference: 'VCB2609228811',
        createdAt: DateTime(2026, 9, 22, 11, 1),
        updatedAt: DateTime(2026, 9, 22, 11, 1),
      ),
      ExpenseItem(
        merchant: 'Highlands Coffee',
        amount: 55000,
        date: DateTime(2026, 9, 18, 8, 45),
        category: 'Food & drink',
        source: ExpenseSource.eWalletScreenshot,
        status: PaymentStatus.successful,
        paymentProvider: 'MoMo',
        transactionReference: 'MM2609183421',
        createdAt: DateTime(2026, 9, 18, 8, 46),
        updatedAt: DateTime(2026, 9, 18, 8, 46),
      ),
      ExpenseItem(
        merchant: 'Giáo trình Cấu trúc dữ liệu',
        amount: 195000,
        date: DateTime(2026, 9, 15, 15, 0),
        category: 'Study',
        source: ExpenseSource.manual,
        status: PaymentStatus.successful,
        createdAt: DateTime(2026, 9, 15, 15, 1),
        updatedAt: DateTime(2026, 9, 15, 15, 1),
      ),
      ExpenseItem(
        merchant: 'Tiền phòng trọ T9',
        amount: 2600000,
        date: DateTime(2026, 9, 10, 9, 30),
        category: 'Other',
        source: ExpenseSource.bankScreenshot,
        status: PaymentStatus.successful,
        paymentProvider: 'Vietcombank',
        transactionReference: 'VCB2609104412',
        createdAt: DateTime(2026, 9, 10, 9, 31),
        updatedAt: DateTime(2026, 9, 10, 9, 31),
      ),
      ExpenseItem(
        merchant: 'Cơm niêu gia đình',
        amount: 310000,
        date: DateTime(2026, 9, 5, 19, 0),
        category: 'Food & drink',
        source: ExpenseSource.receipt,
        status: PaymentStatus.successful,
        createdAt: DateTime(2026, 9, 5, 19, 1),
        updatedAt: DateTime(2026, 9, 5, 19, 1),
      ),
      ExpenseItem(
        merchant: 'Xăng xe Petrolimex',
        amount: 80000,
        date: DateTime(2026, 9, 2, 8, 15),
        category: 'Transport',
        source: ExpenseSource.manual,
        status: PaymentStatus.successful,
        createdAt: DateTime(2026, 9, 2, 8, 16),
        updatedAt: DateTime(2026, 9, 2, 8, 16),
      ),
    ];
  }

  static Future<void> seedIfEmpty(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM expenses'),
    );
    if (count == null || count == 0) {
      await seed(db);
    }
  }

  static Future<void> seed(Database db, {bool clearFirst = false}) async {
    await db.transaction((txn) async {
      if (clearFirst) {
        await txn.delete('expenses');
        await txn.delete('monthly_budgets');
      }

      // Đặt ngân sách tháng 10 và tháng 9
      await txn.insert(
        'monthly_budgets',
        {'month_key': currentMonthKey, 'amount': currentMonthBudget},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'monthly_budgets',
        {'month_key': previousMonthKey, 'amount': previousMonthBudget},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Thêm các khoản chi
      for (final item in getDemoExpenses()) {
        await txn.insert('expenses', item.toMap());
      }
    });
  }
}
