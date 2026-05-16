import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';

/// Wraps any subtree with the shimmer animation. Place this above a group of
/// [Skeleton] boxes so they animate together.
class SkeletonGroup extends StatelessWidget {
  const SkeletonGroup({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightLine,
      highlightColor: AppColors.lightSurfaceAlt,
      child: child,
    );
  }
}

/// A single shimmer-coloured placeholder. Use rectangles for text, circles for
/// avatars/icons.
class Skeleton extends StatelessWidget {
  const Skeleton.rect({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 4,
  }) : _isCircle = false;

  const Skeleton.circle({super.key, required double size})
      : width = size,
        height = size,
        radius = 0,
        _isCircle = true;

  final double? width;
  final double height;
  final double radius;
  final bool _isCircle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: _isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: _isCircle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}
