import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SquareEmptyTab extends StatelessWidget {
  const SquareEmptyTab({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.lightTextTertiary),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
