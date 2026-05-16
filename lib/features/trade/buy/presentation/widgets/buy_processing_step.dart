import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../../core/constants/app_assets.dart';

class BuyProcessingStep extends StatelessWidget {
  const BuyProcessingStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Lottie.asset(AppAssets.lottieLoadingYellow, repeat: true),
          ),
          const SizedBox(height: 24),
          Text('Processing payment…', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Authorizing with your card issuer.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
