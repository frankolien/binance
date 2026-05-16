import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

class BuyCardDraft extends Equatable {
  const BuyCardDraft({
    this.number = '',
    this.expiry = '',
    this.cvv = '',
    this.holderName = '',
  });

  final String number;
  final String expiry;
  final String cvv;
  final String holderName;

  String get last4 =>
      number.length >= 4 ? number.substring(number.length - 4) : number;

  bool get isValid {
    final digits = number.replaceAll(RegExp(r'\s'), '');
    if (digits.length < 13 || digits.length > 19) return false;
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) return false;
    if (cvv.length < 3 || cvv.length > 4) return false;
    if (holderName.trim().isEmpty) return false;
    return true;
  }

  BuyCardDraft copyWith({
    String? number,
    String? expiry,
    String? cvv,
    String? holderName,
  }) {
    return BuyCardDraft(
      number: number ?? this.number,
      expiry: expiry ?? this.expiry,
      cvv: cvv ?? this.cvv,
      holderName: holderName ?? this.holderName,
    );
  }

  @override
  List<Object?> get props => [number, expiry, cvv, holderName];
}

class BuyDraft extends Equatable {
  const BuyDraft({
    required this.fiatAmount,
    required this.assetSymbol,
    required this.card,
  });

  final Decimal fiatAmount;
  final String assetSymbol;
  final BuyCardDraft card;

  @override
  List<Object?> get props => [fiatAmount, assetSymbol, card];
}
