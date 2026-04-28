import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../domain/entities/coin_about.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({
    required this.about,
    required this.tickerSymbol,
    super.key,
  });

  final CoinAbout about;
  final String tickerSymbol;

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final about = widget.about;
    final ticker = widget.tickerSymbol;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About $ticker',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 18),
          if (about.circulatingSupply != null)
            _StatRow(
              label: 'Circulation Supply',
              value: _supply(about.circulatingSupply!, ticker),
            ),
          if (about.maxSupply != null)
            _StatRow(
              label: 'Max Supply',
              value: _supply(about.maxSupply!, ticker),
            ),
          if (about.totalSupply != null)
            _StatRow(
              label: 'Total Supply',
              value: _supply(about.totalSupply!, ticker),
            ),
          if (about.issuePriceUsd != null)
            _StatRow(
              label: 'Issue Price',
              value: PriceFormatter.formatUsd(about.issuePriceUsd!),
              subValue: '≈${PriceFormatter.formatUsd(about.issuePriceUsd!)}',
            ),
          if (about.issueDate != null)
            _StatRow(
              label: 'Issue Date',
              value: _date(about.issueDate!),
            ),
          if (about.allTimeHighUsd != null)
            _StatRow(
              label: 'All Time High',
              labelDashed: true,
              value: PriceFormatter.formatUsd(about.allTimeHighUsd!),
              subValue: about.allTimeHighDate != null
                  ? '≈${PriceFormatter.formatUsd(about.allTimeHighUsd!)}\n${_date(about.allTimeHighDate!)}'
                  : null,
            ),
          if (about.allTimeLowUsd != null)
            _StatRow(
              label: 'All Time Low',
              labelDashed: true,
              value: PriceFormatter.formatUsd(about.allTimeLowUsd!),
              subValue: about.allTimeLowDate != null
                  ? '≈${PriceFormatter.formatUsd(about.allTimeLowUsd!)}\n${_date(about.allTimeLowDate!)}'
                  : null,
            ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Text(
            'Resources',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.lightTextTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          if (about.websiteUrl != null)
            _ResourceLink(
              icon: Icons.link,
              label: 'Official Website',
              url: about.websiteUrl!,
            ),
          if (about.blockExplorerUrl != null)
            _ResourceLink(
              icon: Icons.open_in_browser,
              label: 'Block explorer',
              url: about.blockExplorerUrl!,
            ),
          if (about.introduction != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 20),
            Text(
              'Introduction',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _IntroductionText(
              text: about.introduction!,
              expanded: _expanded,
              onToggle: () => setState(() => _expanded = !_expanded),
            ),
          ],
        ],
      ),
    );
  }

  static String _supply(Decimal value, String ticker) {
    final v = value.toDouble();
    final formatter = NumberFormat.compact();
    return '${formatter.format(v)} $ticker';
  }

  static String _date(DateTime d) {
    return DateFormat('yyyy-MM-dd').format(d);
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.subValue,
    this.labelDashed = false,
  });

  final String label;
  final String value;
  final String? subValue;
  final bool labelDashed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.lightTextTertiary,
      fontWeight: FontWeight.w400,
      decoration: labelDashed ? TextDecoration.underline : null,
      decorationStyle:
          labelDashed ? TextDecorationStyle.dashed : null,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subValue != null) ...[
                const SizedBox(height: 2),
                Text(
                  subValue!,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ResourceLink extends StatelessWidget {
  const _ResourceLink({
    required this.icon,
    required this.label,
    required this.url,
  });

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: url));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Copied: $url')),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.brandYellowPressed),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.brandYellowPressed,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroductionText extends StatelessWidget {
  const _IntroductionText({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onToggle,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: expanded
                  ? text
                  : text.length > 220
                      ? '${text.substring(0, 220)}… '
                      : text,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
            if (text.length > 220)
              TextSpan(
                text: expanded ? '  Less' : 'More',
                style: const TextStyle(
                  color: AppColors.brandYellowPressed,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
