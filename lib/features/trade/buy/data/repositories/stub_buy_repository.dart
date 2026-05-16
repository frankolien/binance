import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:decimal/decimal.dart';

import '../../../../../core/error/failures.dart';
import '../../../../markets/domain/repositories/markets_repository.dart';
import '../../domain/entities/buy_draft.dart';
import '../../domain/entities/buy_receipt.dart';
import '../../domain/repositories/buy_repository.dart';

/// Simulates a card-payment on-ramp: 2.5s processing, ~10% failure to exercise
/// the error UI. Swap for a real MoonPay/Yellow Card impl later — interface
/// stays.
class StubBuyRepository implements BuyRepository {
  StubBuyRepository(this._markets);

  final MarketsRepository _markets;
  final _random = Random();

  @override
  Future<Either<Failure, BuyReceipt>> submit(BuyDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 2500));

    if (_random.nextInt(10) == 0) {
      return const Left(
        ServerFailure('Card declined by issuer. Try another card.'),
      );
    }

    // Resolve a price for the asset → quote in USDT, which we treat as USD 1:1
    // for the stub. Real impl would consult a quote endpoint.
    final symbol = '${draft.assetSymbol}USDT';
    final tickerResult = await _markets.getTicker(symbol);

    final price = tickerResult.fold<Decimal>(
      (_) => Decimal.one,
      (t) => t.lastPrice == Decimal.zero ? Decimal.one : t.lastPrice,
    );

    final crypto = (draft.fiatAmount / price)
        .toDecimal(scaleOnInfinitePrecision: 8);

    return Right(BuyReceipt(
      transactionId: _generateTxId(),
      fiatAmount: draft.fiatAmount,
      cryptoAmount: crypto,
      assetSymbol: draft.assetSymbol,
      cardLast4: draft.card.last4,
      timestamp: DateTime.now(),
    ));
  }

  String _generateTxId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(12, (_) => chars[_random.nextInt(chars.length)])
        .join();
  }
}
