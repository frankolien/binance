import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class BalanceHero extends StatelessWidget {
  const BalanceHero({
    required this.value,
    required this.hidden,
    required this.onToggleVisibility,
    required this.onAddFunds,
    super.key,
  });

  final String value;
  final bool hidden;
  final VoidCallback onToggleVisibility;
  final VoidCallback onAddFunds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Est. Total Value',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  hidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  hidden ? '\$******' : value,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              FilledButton(
                onPressed: onAddFunds,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandYellow,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Add Funds'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
