import 'package:bloc/bloc.dart';
import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../domain/entities/buy_draft.dart';
import '../../domain/entities/buy_receipt.dart';
import '../../domain/repositories/buy_repository.dart';

part 'buy_flow_event.dart';
part 'buy_flow_state.dart';

class BuyFlowBloc extends Bloc<BuyFlowEvent, BuyFlowState> {
  BuyFlowBloc(this._repository) : super(BuyFlowState.initial()) {
    on<BuyAssetPicked>(_onAssetPicked);
    on<BuyAmountChanged>(_onAmountChanged);
    on<BuyFiatCurrencyChanged>(_onFiatCurrencyChanged);
    on<BuyAdvanceToPayment>(_onAdvanceToPayment);
    on<BuyAdvanceToAddCard>(_onAdvanceToAddCard);
    on<BuyCardDraftChanged>(_onCardDraftChanged);
    on<BuyCardConfirmed>(_onCardConfirmed);
    on<BuyCardSelected>(_onCardSelected);
    on<BuySubmitted>(_onSubmitted);
    on<BuyBack>(_onBack);
    on<BuyReset>(_onReset);
  }

  final BuyRepository _repository;

  void _onAssetPicked(BuyAssetPicked e, Emitter<BuyFlowState> emit) {
    emit(state.copyWith(assetSymbol: e.assetSymbol, step: BuyStep.amount));
  }

  void _onAmountChanged(BuyAmountChanged e, Emitter<BuyFlowState> emit) {
    emit(state.copyWith(fiatAmount: e.amount));
  }

  void _onFiatCurrencyChanged(
    BuyFiatCurrencyChanged e,
    Emitter<BuyFlowState> emit,
  ) {
    emit(state.copyWith(fiatCurrency: e.currency));
  }

  void _onAdvanceToPayment(
    BuyAdvanceToPayment e,
    Emitter<BuyFlowState> emit,
  ) {
    if (state.fiatAmount <= Decimal.zero) return;
    emit(state.copyWith(step: BuyStep.paymentMethod));
  }

  void _onAdvanceToAddCard(
    BuyAdvanceToAddCard e,
    Emitter<BuyFlowState> emit,
  ) {
    emit(state.copyWith(step: BuyStep.addCard));
  }

  void _onCardDraftChanged(
    BuyCardDraftChanged e,
    Emitter<BuyFlowState> emit,
  ) {
    emit(state.copyWith(cardDraft: e.card));
  }

  void _onCardConfirmed(BuyCardConfirmed e, Emitter<BuyFlowState> emit) {
    if (!state.cardDraft.isValid) return;
    final saved = [...state.savedCards, state.cardDraft];
    emit(state.copyWith(
      savedCards: saved,
      selectedCardIndex: saved.length - 1,
      cardDraft: const BuyCardDraft(),
      step: BuyStep.paymentMethod,
    ));
  }

  void _onCardSelected(BuyCardSelected e, Emitter<BuyFlowState> emit) {
    emit(state.copyWith(selectedCardIndex: e.index));
  }

  Future<void> _onSubmitted(
    BuySubmitted e,
    Emitter<BuyFlowState> emit,
  ) async {
    final card = state.selectedCard;
    if (card == null) return;

    emit(state.copyWith(step: BuyStep.processing, clearFailure: true));

    final draft = BuyDraft(
      fiatAmount: state.fiatAmount,
      assetSymbol: state.assetSymbol,
      card: card,
    );
    final result = await _repository.submit(draft);

    result.fold(
      (failure) =>
          emit(state.copyWith(step: BuyStep.result, failure: failure)),
      (receipt) =>
          emit(state.copyWith(step: BuyStep.result, receipt: receipt)),
    );
  }

  void _onBack(BuyBack e, Emitter<BuyFlowState> emit) {
    switch (state.step) {
      case BuyStep.chooseCrypto:
      case BuyStep.processing:
        return;
      case BuyStep.amount:
        emit(state.copyWith(step: BuyStep.chooseCrypto));
      case BuyStep.paymentMethod:
        emit(state.copyWith(step: BuyStep.amount));
      case BuyStep.addCard:
        emit(state.copyWith(step: BuyStep.paymentMethod));
      case BuyStep.result:
        if (state.failure != null) {
          emit(state.copyWith(
            step: BuyStep.paymentMethod,
            clearFailure: true,
          ));
        }
    }
  }

  void _onReset(BuyReset e, Emitter<BuyFlowState> emit) {
    emit(BuyFlowState.initial());
  }
}
