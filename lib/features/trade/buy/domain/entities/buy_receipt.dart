import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

class BuyReceipt extends Equatable {
  const BuyReceipt({
    required this.transactionId,
    required this.fiatAmount,
    required this.cryptoAmount,
    required this.assetSymbol,
    required this.cardLast4,
    required this.timestamp,
  });

  final String transactionId;
  final Decimal fiatAmount;
  final Decimal cryptoAmount;
  final String assetSymbol;
  final String cardLast4;
  final DateTime timestamp;

  @override
  List<Object?> get props => [
        transactionId,
        fiatAmount,
        cryptoAmount,
        assetSymbol,
        cardLast4,
        timestamp,
      ];
}
