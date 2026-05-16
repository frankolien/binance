part of 'buy_flow_bloc.dart';

enum BuyStep { chooseCrypto, amount, paymentMethod, addCard, processing, result }

class BuyFlowState extends Equatable {
  const BuyFlowState({
    required this.step,
    required this.fiatAmount,
    required this.fiatCurrency,
    required this.assetSymbol,
    required this.cardDraft,
    required this.savedCards,
    this.selectedCardIndex,
    this.failure,
    this.receipt,
  });

  factory BuyFlowState.initial() => BuyFlowState(
        step: BuyStep.chooseCrypto,
        fiatAmount: Decimal.zero,
        fiatCurrency: 'USD',
        assetSymbol: '',
        cardDraft: const BuyCardDraft(),
        savedCards: const [],
      );

  final BuyStep step;
  final Decimal fiatAmount;
  final String fiatCurrency;
  final String assetSymbol;
  final BuyCardDraft cardDraft;
  final List<BuyCardDraft> savedCards;
  final int? selectedCardIndex;
  final Failure? failure;
  final BuyReceipt? receipt;

  BuyCardDraft? get selectedCard {
    final i = selectedCardIndex;
    if (i == null || i < 0 || i >= savedCards.length) return null;
    return savedCards[i];
  }

  BuyFlowState copyWith({
    BuyStep? step,
    Decimal? fiatAmount,
    String? fiatCurrency,
    String? assetSymbol,
    BuyCardDraft? cardDraft,
    List<BuyCardDraft>? savedCards,
    int? selectedCardIndex,
    Failure? failure,
    BuyReceipt? receipt,
    bool clearFailure = false,
    bool clearReceipt = false,
    bool clearSelectedCard = false,
  }) {
    return BuyFlowState(
      step: step ?? this.step,
      fiatAmount: fiatAmount ?? this.fiatAmount,
      fiatCurrency: fiatCurrency ?? this.fiatCurrency,
      assetSymbol: assetSymbol ?? this.assetSymbol,
      cardDraft: cardDraft ?? this.cardDraft,
      savedCards: savedCards ?? this.savedCards,
      selectedCardIndex: clearSelectedCard
          ? null
          : (selectedCardIndex ?? this.selectedCardIndex),
      failure: clearFailure ? null : (failure ?? this.failure),
      receipt: clearReceipt ? null : (receipt ?? this.receipt),
    );
  }

  @override
  List<Object?> get props => [
        step,
        fiatAmount,
        fiatCurrency,
        assetSymbol,
        cardDraft,
        savedCards,
        selectedCardIndex,
        failure,
        receipt,
      ];
}
