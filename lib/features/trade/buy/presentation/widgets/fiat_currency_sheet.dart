import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class FiatOption {
  const FiatOption(
    this.code,
    this.symbol,
    this.flag,
    this.minAmount,
    this.maxAmount,
  );
  final String code;
  final String symbol;
  final String flag; // emoji
  final num minAmount;
  final num maxAmount;
}

const supportedFiats = <FiatOption>[
  FiatOption('USD', r'$', '🇺🇸', 10, 40007),
  FiatOption('NGN', '₦', '🇳🇬', 5000, 50000000),
  FiatOption('EUR', '€', '🇪🇺', 10, 35000),
];

FiatOption fiatByCode(String code) =>
    supportedFiats.firstWhere((f) => f.code == code,
        orElse: () => supportedFiats.first);

class FiatCurrencySheet extends StatelessWidget {
  const FiatCurrencySheet({super.key, required this.selected});

  final String selected;

  static Future<String?> show(BuildContext context, String selected) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FiatCurrencySheet(selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightLine,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Select currency',
                    style: theme.textTheme.titleMedium),
              ),
            ),
            const SizedBox(height: 8),
            for (final f in supportedFiats)
              ListTile(
                onTap: () => Navigator.of(context).pop(f.code),
                leading: Text(f.flag, style: const TextStyle(fontSize: 28)),
                title: Text(f.code,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text(f.symbol, style: theme.textTheme.bodySmall),
                trailing: f.code == selected
                    ? const Icon(Icons.check_circle,
                        color: AppColors.buy, size: 22)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}
