import 'package:flutter/material.dart';

import 'skeleton.dart';

/// Skeleton row that mirrors a coin/ticker row: icon, name + ticker, price.
class CoinRowSkeleton extends StatelessWidget {
  const CoinRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Skeleton.circle(size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Skeleton.rect(width: 90, height: 14),
                SizedBox(height: 6),
                Skeleton.rect(width: 40, height: 10),
              ],
            ),
          ),
          const Skeleton.rect(width: 70, height: 14),
        ],
      ),
    );
  }
}

/// Skeleton card that mirrors a Square feed post.
class SquarePostSkeleton extends StatelessWidget {
  const SquarePostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Skeleton.circle(size: 36),
              SizedBox(width: 10),
              Skeleton.rect(width: 120, height: 14),
            ],
          ),
          const SizedBox(height: 12),
          const Skeleton.rect(height: 14, radius: 4),
          const SizedBox(height: 6),
          const Skeleton.rect(width: 240, height: 14),
          const SizedBox(height: 12),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
