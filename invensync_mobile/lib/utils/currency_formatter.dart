import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String? currency}) {
    final cur = currency ?? 'ETB';
    return NumberFormat.currency(
      symbol: '$cur ',
      decimalDigits: 2,
    ).format(amount);
  }

  static String compact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}