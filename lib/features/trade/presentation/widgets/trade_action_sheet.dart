import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

class TradeActionSheet extends StatelessWidget {
  const TradeActionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.lightSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const TradeActionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Handle(),
            const SizedBox(height: 12),
            _ActionRow(
              icon: PhosphorIconsRegular.shoppingBag,
              title: 'Buy',
              subtitle: 'Buy crypto with USD',
              onTap: () {
                Navigator.of(context).pop();
                context.router.push(const BuyRoute());
              },
            ),
            _ActionRow(
              icon: PhosphorIconsRegular.handCoins,
              title: 'Sell',
              subtitle: 'Sell crypto to USD',
              onTap: () => _onAction(context, 'Sell'),
            ),
            _ActionRow(
              icon: PhosphorIconsRegular.arrowsLeftRight,
              title: 'Convert',
              subtitle: 'Swap currencies and trade instantly',
              onTap: () => _onAction(context, 'Convert'),
            ),
            _ActionRow(
              icon: PhosphorIconsRegular.arrowDown,
              title: 'Deposit',
              subtitle: 'Deposit with fiat and crypto currency',
              onTap: () => _onAction(context, 'Deposit'),
            ),
            const SizedBox(height: 16),
            _CloseButton(onTap: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }

  void _onAction(BuildContext context, String label) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label coming soon')),
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.lightLine,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 28, color: AppColors.lightTextPrimary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightTextPrimary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.close, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
