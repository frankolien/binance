import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../bloc/buy_flow_bloc.dart';
import 'buy_numpad.dart';
import 'fiat_currency_sheet.dart';

class BuyAmountStep extends StatefulWidget {
  const BuyAmountStep({super.key});

  @override
  State<BuyAmountStep> createState() => _BuyAmountStepState();
}

class _BuyAmountStepState extends State<BuyAmountStep> {
  // Local string state so leading zeros / trailing decimals are preserved
  // during entry. Bloc gets a parsed Decimal each change.
  String _input = '';

  Decimal get _decimal => Decimal.tryParse(_input) ?? Decimal.zero;

  void _onDigit(String d) {
    setState(() {
      // Avoid leading zeros like "007".
      if (_input == '0' && d != '.') {
        _input = d;
      } else {
        _input += d;
      }
      _push();
    });
  }

  void _onDecimal() {
    if (_input.contains('.')) return;
    setState(() {
      _input = _input.isEmpty ? '0.' : '$_input.';
      _push();
    });
  }

  void _onBackspace() {
    if (_input.isEmpty) return;
    setState(() {
      _input = _input.substring(0, _input.length - 1);
      _push();
    });
  }

  void _push() {
    context.read<BuyFlowBloc>().add(BuyAmountChanged(_decimal));
  }

  Future<void> _pickFiat() async {
    final state = context.read<BuyFlowBloc>().state;
    final picked = await FiatCurrencySheet.show(context, state.fiatCurrency);
    if (picked != null && mounted) {
      context.read<BuyFlowBloc>().add(BuyFiatCurrencyChanged(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<BuyFlowBloc, BuyFlowState>(
      buildWhen: (p, c) =>
          p.fiatAmount != c.fiatAmount || p.fiatCurrency != c.fiatCurrency,
      builder: (context, state) {
        final fiat = fiatByCode(state.fiatCurrency);
        final amount = _decimal;
        final inRange = amount >= Decimal.fromInt(fiat.minAmount.toInt()) &&
            amount <= Decimal.fromInt(fiat.maxAmount.toInt());
        return SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('I want to pay', style: theme.textTheme.bodyMedium),
                    Row(
                      children: [
                        Text('By Crypto',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(width: 4),
                        const Icon(Icons.swap_horiz,
                            size: 18, color: AppColors.lightTextPrimary),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _AmountField(
                  input: _input,
                  fiat: fiat,
                  onPickFiat: _pickFiat,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_fmt(fiat.minAmount)}–${_fmt(fiat.maxAmount)} ${fiat.code}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
              const Spacer(),
              BuyNumpad(
                onDigit: _onDigit,
                onDecimal: _onDecimal,
                onBackspace: _onBackspace,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandYellow,
                      foregroundColor: AppColors.lightTextPrimary,
                      disabledBackgroundColor: AppColors.lightSurfaceAlt,
                      disabledForegroundColor: AppColors.lightTextTertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: inRange
                        ? () => context
                            .read<BuyFlowBloc>()
                            .add(const BuyAdvanceToPayment())
                        : null,
                    child: const Text(
                      'Select Payment method',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(num n) => NumberFormat('#,##0.00').format(n);
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.input,
    required this.fiat,
    required this.onPickFiat,
  });

  final String input;
  final FiatOption fiat;
  final VoidCallback onPickFiat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.lightSurfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 22,
            color: AppColors.brandYellow,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              input.isEmpty ? 'Please enter amount' : input,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: input.isEmpty
                    ? AppColors.lightTextTertiary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            color: AppColors.lightLine,
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onPickFiat,
            child: Row(
              children: [
                Text(fiat.flag, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 6),
                Text(
                  fiat.code,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Icon(Icons.arrow_drop_down, size: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
