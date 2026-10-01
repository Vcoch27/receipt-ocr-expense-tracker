import 'package:intl/intl.dart';

final _money = NumberFormat.decimalPattern('vi_VN');

String formatVnd(int amount) => '${_money.format(amount)} ₫';

String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
