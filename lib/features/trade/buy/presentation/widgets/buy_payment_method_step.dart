import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../markets/domain/repositories/markets_repository.dart';
import '../bloc/buy_flow_bloc.dart';

class BuyPaymentMethodStep extends StatefulWidget {
  const BuyPaymentMethodStep({super.key});

  @override
  State<BuyPaymentMethodStep> createState() => _BuyPaymentMethodStepState();
}

class _BuyPaymentMethodStepState extends State<BuyPaymentMethodStep> {
  Decimal? _priceUsdt; // last refreshed price
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final state = context.read<BuyFlowBloc>().state;
    setState(() => _loading = true);
    final res = await getIt<MarketsRepository>()
        .getTicker('${state.assetSymbol}USDT');
    if (!mounted) return;
    setState(() {
      _priceUsdt = res.fold((_) => null, (t) => t.lastPrice);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<BuyFlowBloc, BuyFlowState>(
      builder: (context, state) {
        final crypto = _priceUsdt != null && _priceUsdt! > Decimal.zero
            ? (state.fiatAmount / _priceUsdt!)
                .toDecimal(scaleOnInfinitePrecision: 8)
            : null;

        return SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 32),
              Text('You will pay', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                '${state.fiatAmount} ${state.fiatCurrency}',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightLine),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Card/Bank Accounts/Others',
                            style: TextStyle(
                              color: AppColors.lightTextTertiary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (state.savedCards.isEmpty)
                        _AddCardRow(
                          onTap: () => context
                              .read<BuyFlowBloc>()
                              .add(const BuyAdvanceToAddCard()),
                          cryptoText: crypto != null
                              ? '${crypto.toStringAsFixed(8)} ${state.assetSymbol}'
                              : null,
                        )
                      else
                        for (var i = 0; i < state.savedCards.length; i++)
                          _SavedCardRow(
                            card: state.savedCards[i],
                            selected: state.selectedCardIndex == i,
                            cryptoText: crypto != null
                                ? '${crypto.toStringAsFixed(8)} ${state.assetSymbol}'
                                : null,
                            onTap: () => context
                                .read<BuyFlowBloc>()
                                .add(BuyCardSelected(i)),
                          ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              _Footer(
                state: state,
                priceLoaded: _priceUsdt != null,
                loading: _loading,
                onRefresh: _refresh,
                onBuy: () =>
                    context.read<BuyFlowBloc>().add(const BuySubmitted()),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddCardRow extends StatelessWidget {
  const _AddCardRow({required this.onTap, required this.cryptoText});

  final VoidCallback onTap;
  final String? cryptoText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.lightSurfaceAlt,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.lightLine),
              ),
              alignment: Alignment.center,
              child: const Text(
                'VISA',
                style: TextStyle(
                  color: Color(0xFF1A1F71),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card (VISA/Mastercard)',
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      Text('Add',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.lightTextTertiary)),
                      const Icon(Icons.chevron_right,
                          size: 16, color: AppColors.lightTextTertiary),
                    ],
                  ),
                ],
              ),
            ),
            if (cryptoText != null)
              Text(cryptoText!, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _SavedCardRow extends StatelessWidget {
  const _SavedCardRow({
    required this.card,
    required this.selected,
    required this.cryptoText,
    required this.onTap,
  });

  final dynamic card; // BuyCardDraft from the state
  final bool selected;
  final String? cryptoText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.lightSurfaceAlt,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.lightLine),
              ),
              alignment: Alignment.center,
              child: const Text(
                'VISA',
                style: TextStyle(
                  color: Color(0xFF1A1F71),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('•• ${card.last4}',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
            if (cryptoText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(cryptoText!, style: theme.textTheme.bodyMedium),
              ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected
                  ? AppColors.lightTextPrimary
                  : AppColors.lightTextTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.state,
    required this.priceLoaded,
    required this.loading,
    required this.onRefresh,
    required this.onBuy,
  });

  final BuyFlowState state;
  final bool priceLoaded;
  final bool loading;
  final VoidCallback onRefresh;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCard = state.selectedCard != null;
    final canBuy = hasCard && priceLoaded;
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.lightLine)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You will pay', style: theme.textTheme.bodySmall),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${state.fiatAmount}',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 4),
                    Text(state.fiatCurrency,
                        style: theme.textTheme.bodySmall),
                  ],
                ),
                if (!hasCard)
                  Text(
                    'Add a card to continue',
                    style: theme.textTheme.bodySmall,
                  )
                else
                  Text(
                    'Please refresh to get new price',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandYellow,
                foregroundColor: AppColors.lightTextPrimary,
                disabledBackgroundColor: AppColors.lightSurfaceAlt,
                disabledForegroundColor: AppColors.lightTextTertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              onPressed: loading
                  ? null
                  : (canBuy ? onBuy : onRefresh),
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.lightTextPrimary),
                    )
                  : Text(
                      canBuy ? 'Buy' : 'Refresh Price',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
