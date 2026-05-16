import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../bloc/buy_flow_bloc.dart';
import '../widgets/buy_add_card_step.dart';
import '../widgets/buy_amount_step.dart';
import '../widgets/buy_choose_crypto_step.dart';
import '../widgets/buy_payment_method_step.dart';
import '../widgets/buy_processing_step.dart';
import '../widgets/buy_result_step.dart';

@RoutePage()
class BuyPage extends StatelessWidget {
  const BuyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BuyFlowBloc>(
      create: (_) => getIt<BuyFlowBloc>(),
      child: const _BuyView(),
    );
  }
}

class _BuyView extends StatelessWidget {
  const _BuyView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyFlowBloc, BuyFlowState>(
      buildWhen: (p, c) =>
          p.step != c.step || (p.failure == null) != (c.failure == null),
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.lightSurface,
          appBar: AppBar(
            backgroundColor: AppColors.lightSurface,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: _LeadingButton(state: state),
            title: Text(
              _titleFor(state.step),
              style: const TextStyle(
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            actions: [
              if (state.step == BuyStep.amount)
                IconButton(
                  icon: const Icon(Icons.history,
                      color: AppColors.lightTextPrimary),
                  onPressed: () {},
                ),
            ],
            automaticallyImplyLeading: false,
          ),
          body: switch (state.step) {
            BuyStep.chooseCrypto => const BuyChooseCryptoStep(),
            BuyStep.amount => const BuyAmountStep(),
            BuyStep.paymentMethod => const BuyPaymentMethodStep(),
            BuyStep.addCard => const BuyAddCardStep(),
            BuyStep.processing => const BuyProcessingStep(),
            BuyStep.result => const BuyResultStep(),
          },
        );
      },
    );
  }

  String _titleFor(BuyStep step) {
    return switch (step) {
      BuyStep.chooseCrypto => 'Choose Crypto',
      BuyStep.amount => 'Buy',
      BuyStep.paymentMethod => 'Select Payment Method',
      BuyStep.addCard => 'Add New Card',
      BuyStep.processing => '',
      BuyStep.result => '',
    };
  }
}

class _LeadingButton extends StatelessWidget {
  const _LeadingButton({required this.state});
  final BuyFlowState state;

  @override
  Widget build(BuildContext context) {
    if (state.step == BuyStep.processing) return const SizedBox.shrink();

    // Result-success → close button that exits the flow.
    if (state.step == BuyStep.result && state.failure == null) {
      return IconButton(
        icon: const Icon(Icons.close, color: AppColors.lightTextPrimary),
        onPressed: () => context.router.maybePop(),
      );
    }

    return IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.lightTextPrimary),
      onPressed: () {
        if (state.step == BuyStep.chooseCrypto) {
          context.router.maybePop();
        } else {
          context.read<BuyFlowBloc>().add(const BuyBack());
        }
      },
    );
  }
}
