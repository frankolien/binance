import 'package:dartz/dartz.dart';

import '../../../../../core/error/failures.dart';
import '../entities/buy_draft.dart';
import '../entities/buy_receipt.dart';

abstract class BuyRepository {
  Future<Either<Failure, BuyReceipt>> submit(BuyDraft draft);
}
