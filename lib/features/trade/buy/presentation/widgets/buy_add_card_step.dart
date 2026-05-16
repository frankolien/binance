import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/domain/entities/user_profile.dart';
import '../../../../auth/domain/repositories/user_profile_repository.dart';
import '../../domain/entities/buy_draft.dart';
import '../bloc/buy_flow_bloc.dart';

const _countries = ['Nigeria', 'United States', 'United Kingdom', 'Germany'];

class BuyAddCardStep extends StatefulWidget {
  const BuyAddCardStep({super.key});

  @override
  State<BuyAddCardStep> createState() => _BuyAddCardStepState();
}

class _BuyAddCardStepState extends State<BuyAddCardStep> {
  late final TextEditingController _name;
  late final TextEditingController _number;
  late final TextEditingController _expiry;
  late final TextEditingController _cvv;
  late final TextEditingController _address;
  late final TextEditingController _city;
  late final TextEditingController _postal;

  late String _country;
  bool _autofill = true;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _profile = getIt<UserProfileRepository>().current();
    _country = _profile?.country ?? _countries.first;

    final c = context.read<BuyFlowBloc>().state.cardDraft;
    _name = TextEditingController(
        text: c.holderName.isNotEmpty ? c.holderName : (_profile?.fullName ?? ''));
    _number = TextEditingController(text: c.number);
    _expiry = TextEditingController(text: c.expiry);
    _cvv = TextEditingController(text: c.cvv);
    _address = TextEditingController(
        text: _autofill ? (_profile?.address ?? '') : '');
    _city = TextEditingController(
        text: _autofill ? (_profile?.city ?? '') : '');
    _postal = TextEditingController(
        text: _autofill ? (_profile?.postalCode ?? '') : '');

    if (_name.text.isNotEmpty) _push();
  }

  void _onAutofillChanged(bool v) {
    setState(() {
      _autofill = v;
      if (v && _profile != null) {
        _address.text = _profile!.address;
        _city.text = _profile!.city;
        _postal.text = _profile!.postalCode;
        _country = _profile!.country;
      } else {
        _address.clear();
        _city.clear();
        _postal.clear();
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    _expiry.dispose();
    _cvv.dispose();
    _address.dispose();
    _city.dispose();
    _postal.dispose();
    super.dispose();
  }

  void _push() {
    context.read<BuyFlowBloc>().add(BuyCardDraftChanged(BuyCardDraft(
          number: _number.text,
          expiry: _expiry.text,
          cvv: _cvv.text,
          holderName: _name.text,
        )));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<BuyFlowBloc, BuyFlowState>(
      buildWhen: (p, c) => p.cardDraft != c.cardDraft,
      builder: (context, state) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Banner(),
                const SizedBox(height: 20),
                Text('Card Information', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _GreyField(
                  controller: _name,
                  hint: 'CARDHOLDER NAME',
                  onChanged: (_) => _push(),
                ),
                const SizedBox(height: 10),
                _GreyField(
                  controller: _number,
                  hint: '1234 1234 1234 1234',
                  keyboardType: TextInputType.number,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(19),
                    _CardNumberFormatter(),
                  ],
                  onChanged: (_) => _push(),
                  suffix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BrandPip(brand: _detectBrand(_number.text)),
                      const SizedBox(width: 8),
                      const Icon(PhosphorIconsRegular.camera, size: 22),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _GreyField(
                        controller: _expiry,
                        hint: 'Expiry Date',
                        keyboardType: TextInputType.number,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          _ExpiryFormatter(),
                        ],
                        onChanged: (_) => _push(),
                        suffix: const Icon(Icons.arrow_drop_down, size: 22),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _GreyField(
                        controller: _cvv,
                        hint: 'CVV',
                        keyboardType: TextInputType.number,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        onChanged: (_) => _push(),
                        suffix: const Icon(Icons.info_outline, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text('Billing Address', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _AutofillToggle(
                  value: _autofill,
                  onChanged: _onAutofillChanged,
                ),
                const SizedBox(height: 12),
                _GreyField(
                  controller: _address,
                  hint: 'Street address',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _GreyField(
                        controller: _city,
                        hint: 'City',
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _GreyField(
                        controller: _postal,
                        hint: 'Postal Code',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _CountryField(
                  value: _country,
                  onChanged: (v) => setState(() => _country = v),
                ),
                const SizedBox(height: 12),
                Text(
                  'Please ensure the billing address is correct, or the transactions will fail.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: state.cardDraft.isValid
                          ? AppColors.brandYellow
                          : AppColors.brandYellow.withValues(alpha: 0.3),
                      foregroundColor: AppColors.lightTextPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: state.cardDraft.isValid
                        ? () => context
                            .read<BuyFlowBloc>()
                            .add(const BuyCardConfirmed())
                        : null,
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  CardBrand _detectBrand(String number) {
    final d = number.replaceAll(RegExp(r'\s'), '');
    if (d.isEmpty) return CardBrand.unknown;
    if (d.startsWith('4')) return CardBrand.visa;
    if (d.startsWith('5') ||
        (d.length >= 4 &&
            int.tryParse(d.substring(0, 4)) != null &&
            int.parse(d.substring(0, 4)) >= 2221 &&
            int.parse(d.substring(0, 4)) <= 2720)) {
      return CardBrand.mastercard;
    }
    if (d.startsWith('34') || d.startsWith('37')) return CardBrand.amex;
    return CardBrand.unknown;
  }
}

enum CardBrand { visa, mastercard, amex, unknown }

class _Banner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7DC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline,
              size: 18, color: AppColors.lightTextPrimary),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                    color: AppColors.lightTextPrimary,
                    fontSize: 13,
                    fontFamily: 'BinancePlex'),
                children: [
                  TextSpan(
                      text:
                          'The card from your residential country is not support. '),
                  TextSpan(
                    text: 'Rec.Banks',
                    style: TextStyle(
                      color: AppColors.brandYellowPressed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Icon(Icons.close, size: 18, color: AppColors.lightTextTertiary),
        ],
      ),
    );
  }
}

class _GreyField extends StatelessWidget {
  const _GreyField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.keyboardType,
    this.formatters,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatters;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: formatters,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AppColors.lightTextTertiary,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}

class _BrandPip extends StatelessWidget {
  const _BrandPip({required this.brand});
  final CardBrand brand;

  @override
  Widget build(BuildContext context) {
    if (brand == CardBrand.unknown) {
      return Row(
        children: [
          _circle(const Color(0xFF1A1F71), 'V'),
          const SizedBox(width: 4),
          _circle(const Color(0xFFEB001B), 'M'),
        ],
      );
    }
    switch (brand) {
      case CardBrand.visa:
        return _circle(const Color(0xFF1A1F71), 'V');
      case CardBrand.mastercard:
        return _circle(const Color(0xFFEB001B), 'M');
      case CardBrand.amex:
        return _circle(const Color(0xFF2E77BC), 'A');
      case CardBrand.unknown:
        return const SizedBox.shrink();
    }
  }

  Widget _circle(Color color, String letter) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AutofillToggle extends StatelessWidget {
  const _AutofillToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Autofill Verification Address',
            style: Theme.of(context).textTheme.bodyLarge),
        InkWell(
          onTap: () => onChanged(!value),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.lightTextPrimary
                  : AppColors.lightSurfaceAlt,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: value
                    ? AppColors.lightTextPrimary
                    : AppColors.lightLine,
              ),
            ),
            child: value
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
      ],
    );
  }
}

class _CountryField extends StatelessWidget {
  const _CountryField({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: [
            for (final c in _countries)
              DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged: (v) => v == null ? null : onChanged(v),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length && i < 4; i++) {
      if (i == 2) buf.write('/');
      buf.write(digits[i]);
    }
    final s = buf.toString();
    return TextEditingValue(
      text: s,
      selection: TextSelection.collapsed(offset: s.length),
    );
  }
}
