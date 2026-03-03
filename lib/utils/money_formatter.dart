import 'package:intl/intl.dart';

class MoneyFormatter {
  static final NumberFormat _ngnWith2 = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 2,
  );

  static final NumberFormat _ngnWith0 = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 0,
  );

  static String ngn(num? amount, {int decimalDigits = 2}) {
    final value = amount ?? 0;
    if (decimalDigits == 0) {
      return _ngnWith0.format(value);
    }
    return _ngnWith2.format(value);
  }
}
