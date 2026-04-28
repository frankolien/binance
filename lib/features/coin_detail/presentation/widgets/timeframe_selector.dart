import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/coin_timeframe.dart';

class TimeframeSelector extends StatelessWidget {
  const TimeframeSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final CoinTimeframe selected;
  final ValueChanged<CoinTimeframe> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final tf in CoinTimeframe.values)
            Expanded(
              child: _TimeframePill(
                label: tf.label,
                active: tf == selected,
                onTap: () => onChanged(tf),
                theme: theme,
              ),
            ),
        ],
      ),
    );
  }
}

class _TimeframePill extends StatelessWidget {
  const _TimeframePill({
    required this.label,
    required this.active,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.lightSurfaceAlt : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: active
                ? theme.colorScheme.onSurface
                : AppColors.lightTextTertiary,
          ),
        ),
      ),
    );
  }
}
