part of 'buy_flow_bloc.dart';

sealed class BuyFlowEvent extends Equatable {
  const BuyFlowEvent();

  @override
  List<Object?> get props => [];
}

class BuyAssetPicked extends BuyFlowEvent {
  const BuyAssetPicked(this.assetSymbol);
  final String assetSymbol;

  @override
  List<Object?> get props => [assetSymbol];
}

class BuyAmountChanged extends BuyFlowEvent {
  const BuyAmountChanged(this.amount);
  final Decimal amount;

  @override
  List<Object?> get props => [amount];
}

class BuyFiatCurrencyChanged extends BuyFlowEvent {
  const BuyFiatCurrencyChanged(this.currency);
  final String currency;

  @override
  List<Object?> get props => [currency];
}

class BuyAdvanceToPayment extends BuyFlowEvent {
  const BuyAdvanceToPayment();
}

class BuyAdvanceToAddCard extends BuyFlowEvent {
  const BuyAdvanceToAddCard();
}

class BuyCardDraftChanged extends BuyFlowEvent {
  const BuyCardDraftChanged(this.card);
  final BuyCardDraft card;

  @override
  List<Object?> get props => [card];
}

class BuyCardConfirmed extends BuyFlowEvent {
  const BuyCardConfirmed();
}

class BuyCardSelected extends BuyFlowEvent {
  const BuyCardSelected(this.index);
  final int index;

  @override
  List<Object?> get props => [index];
}

class BuySubmitted extends BuyFlowEvent {
  const BuySubmitted();
}

class BuyBack extends BuyFlowEvent {
  const BuyBack();
}

class BuyReset extends BuyFlowEvent {
  const BuyReset();
}
