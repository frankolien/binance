import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class MarketsHeader extends StatelessWidget {
  const MarketsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
      child: Row(
        children: [
          const _BinanceMark(),
          const Spacer(),
          _IconButton(
            child: SvgPicture.asset(
              AppAssets.icSearchAlt,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                Theme.of(context).iconTheme.color ?? Colors.black,
                BlendMode.srcIn,
              ),
            ),
            onTap: () {},
          ),
          //const SizedBox(width: 8),
          _IconButton(
            child: Icon(
              PhosphorIconsRegular.scan,
              size: 20,
              color: Theme.of(context).iconTheme.color,
            ),
            onTap: () {},
          ),
          //const SizedBox(width: 8),
          _IconButton(
            child: SvgPicture.asset(
              AppAssets.icPay,
              width: 20,
              height: 20,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _BinanceMark extends StatelessWidget {
  const _BinanceMark();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color.fromARGB(217, 252, 212, 53),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            AppAssets.binanceLogo,
            width: 32,
            height: 32,
            colorFilter:
                const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
        ),
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.sell,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: SizedBox(width: 24, height: 24, child: Center(child: child)),
      ),
    );
  }
}
