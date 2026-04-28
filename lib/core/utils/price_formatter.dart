import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

class PriceFormatter {
  PriceFormatter._();

  /// Formats a price with smart precision matching Binance:
  /// - >= 1: thousands separators + 2 decimals (e.g. "$75,519.54").
  /// - 0.01..1: 4 decimals (e.g. "$0.4902").
  /// - < 0.01: enough decimals to show ~4 significant digits (e.g.
  ///   "$0.05772", "$0.00000378").
  /// - 0: "$0.00".
  static String formatUsd(Decimal value) => '\$${formatPlain(value)}';

  static String formatPlain(Decimal value) {
    if (value == Decimal.zero) return '0.00';

    final isNegative = value < Decimal.zero;
    final abs = isNegative ? -value : value;

    String formatted;
    if (abs >= Decimal.one) {
      formatted = NumberFormat('#,##0.00').format(abs.toDouble());
    } else if (abs >= Decimal.parse('0.01')) {
      formatted = abs.toDouble().toStringAsFixed(4);
    } else {
      formatted = _formatTinyValue(abs);
    }

    return isNegative ? '-$formatted' : formatted;
  }

  /// For sub-cent values: keep ~4 significant digits after the leading zeros.
  static String _formatTinyValue(Decimal value) {
    final d = value.toDouble();
    if (d == 0) return '0.00';

    final str = d.toStringAsFixed(20);
    final dotIdx = str.indexOf('.');
    if (dotIdx == -1) return str;
    final fractional = str.substring(dotIdx + 1);

    int leadingZeros = 0;
    for (final ch in fractional.split('')) {
      if (ch != '0') break;
      leadingZeros++;
    }

    const sigDigits = 4;
    final keep = leadingZeros + sigDigits;
    final truncated = fractional.substring(0, keep.clamp(0, fractional.length));
    final trimmed = truncated.replaceAll(RegExp(r'0+$'), '');
    return '0.${trimmed.isEmpty ? '0' : trimmed}';
  }

  /// 24h change as "+1.20%" or "-0.91%" with sign.
  static String formatPercent(double percent) {
    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(2)}%';
  }
}
