import 'package:flutter/material.dart';

import '../core/design_tokens.dart';
import '../core/torkis_ui.dart';
import 'auth_gate.dart';

/// Welcome obrazovka zobrazená po dokončení onboardingu.
/// Informuje uživatele o 30-denní zkušební době zdarma bez závazků.
class TrialWelcomeScreen extends StatelessWidget {
  const TrialWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TokColors.ink,
      body: Stack(
        children: [
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      TokColors.accent.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.65],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const TorkisMark(
                    size: 64,
                    color: TokColors.paper,
                    inner: TokColors.ink,
                  ),
                  const SizedBox(height: 20),

                  // Velký pill „30 DNÍ ZDARMA"
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: TokColors.accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(TokRadius.round),
                      border: Border.all(
                        color: TokColors.accent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Text(
                      '30 DNÍ ZDARMA',
                      style: TextStyle(
                        color: TokColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Vítejte v TORKISu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: TokColors.paper,
                      letterSpacing: -0.4,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Spustili jsme vám zkušební dobu na 30 dní zdarma — '
                    'bez platební karty a bez závazků.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: TokColors.steelSoft,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Seznam benefitů
                  _BenefitRow(
                    icon: Icons.check_circle_outline_rounded,
                    text:
                        'Neomezený počet záznamů vozidel a zákazníků',
                  ),
                  _BenefitRow(
                    icon: Icons.check_circle_outline_rounded,
                    text:
                        '10 dekodovaných VINů',
                  ),
                                    _BenefitRow(
                    icon: Icons.check_circle_outline_rounded,
                    text:
                        '5 zjištěných tržních hodnot vozidel podle VIN',
                  ),
                  _BenefitRow(
                    icon: Icons.check_circle_outline_rounded,
                    text:
                        'Plný přístup ke všem funkcím aplikace.',
                  ),
                  const SizedBox(height: 14),
                  _BenefitRow(
                    icon: Icons.credit_card_off_rounded,
                    text:
                        'Žádné platební údaje. Bez automatického strhávání.',
                  ),
                  const SizedBox(height: 14),
                  _BenefitRow(
                    icon: Icons.download_done_rounded,
                    text:
                        'Vaše data jsou vždy vaše — export kdykoli zdarma.',
                  ),

                  const Spacer(),

                  TorkisPrimaryButton(
                    label: 'Začít používat aplikaci',
                    dark: true,
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AuthGate()),
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Po skončení trialu si vyberete plán, který vám sedne.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: TokColors.steelSoft,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: TokColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(TokRadius.sm),
          ),
          child: Icon(icon, color: TokColors.accent, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: TokColors.paper,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
