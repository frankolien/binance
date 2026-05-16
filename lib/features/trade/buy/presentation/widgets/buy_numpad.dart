import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/theme/app_colors.dart';

/// In-screen numpad. Three columns, four rows: 1-9, decimal, 0, backspace.
class BuyNumpad extends StatelessWidget {
  const BuyNumpad({
    super.key,
    required this.onDigit,
    required this.onDecimal,
    required this.onBackspace,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDecimal;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2.2,
        children: [
          for (final d in const ['1', '2', '3', '4', '5', '6', '7', '8', '9'])
            _Key(label: d, onTap: () => onDigit(d)),
          _Key(label: '.', onTap: onDecimal),
          _Key(label: '0', onTap: () => onDigit('0')),
          _IconKey(icon: PhosphorIconsRegular.backspace, onTap: onBackspace),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
        ),
      ),
    );
  }
}

class _IconKey extends StatelessWidget {
  const _IconKey({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: Icon(icon, size: 26, color: AppColors.lightTextPrimary),
      ),
    );
  }
}
