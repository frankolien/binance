import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../bloc/buy_flow_bloc.dart';

class BuyResultStep extends StatelessWidget {
  const BuyResultStep({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BuyFlowBloc>().state;
    final theme = Theme.of(context);

    if (state.failure != null) {
      return _Result(
        icon: Icons.error_outline,
        iconColor: AppColors.sell,
        title: 'Payment failed',
        body: state.failure!.message,
        primary: _PrimaryButton(
          label: 'Try again',
          onPressed: () =>
              context.read<BuyFlowBloc>().add(const BuyBack()),
        ),
      );
    }

    final receipt = state.receipt;
    if (receipt == null) return const SizedBox.shrink();

    return _Result(
      icon: Icons.check_circle,
      iconColor: AppColors.buy,
      title: 'Purchase complete',
      body:
          'You bought ${receipt.cryptoAmount.toStringAsFixed(8)} ${receipt.assetSymbol} '
          'for \$${receipt.fiatAmount} on card •• ${receipt.cardLast4}.',
      footer: Text(
        'Transaction ID  ${receipt.transactionId}',
        style: theme.textTheme.bodySmall,
      ),
      primary: _PrimaryButton(
        label: 'Done',
        onPressed: () => context.router.maybePop(),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.primary,
    this.footer,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final Widget primary;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Icon(icon, size: 72, color: iconColor),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium),
          if (footer != null) ...[
            const SizedBox(height: 16),
            footer!,
          ],
          const Spacer(),
          primary,
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brandYellow,
          foregroundColor: AppColors.lightTextPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        onPressed: onPressed,
        child: Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
