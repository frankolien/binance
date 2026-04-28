import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

class Kline extends Equatable {
  const Kline({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final DateTime openTime;
  final Decimal open;
  final Decimal high;
  final Decimal low;
  final Decimal close;
  final Decimal volume;

  @override
  List<Object?> get props => [openTime, open, high, low, close, volume];
}
