import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import '../core/design_tokens.dart';
import '../core/subscription_service.dart';
import '../core/torkis_ui.dart';
import '../l10n/app_localizations.dart';
import 'auth_gate.dart';

class PaywallScreen extends StatefulWidget {
  final int? zbyvajiciDniTrialu;

  const PaywallScreen({super.key, this.zbyvajiciDniTrialu});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

enum _Period { monthly, yearly }

class _PaywallScreenState extends State<PaywallScreen> {
  Map<String, Package> _packages = {};
  bool _loading = true;
  bool _purchasing = false;
  String? _errorMessage;
  _Period _period = _Period.monthly;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final list = await SubscriptionService.getPackages();
    final map = <String, Package>{};
    for (final pkg in list) {
      map[pkg.identifier] = pkg;
    }
    if (mounted) {
      setState(() {
        _packages = map;
        _loading = false;
      });
    }
  }

  Future<void> _purchase(Package? package) async {
    if (package == null) return;
    setState(() {
      _purchasing = true;
      _errorMessage = null;
    });
    try {
      final ok = await SubscriptionService.purchasePackage(package);
      if (ok && mounted) _restartApp();
    } catch (e) {
      if (mounted) setState(() => _errorMessage = AppLocalizations.of(context).predChybaNakup(e.toString()));
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() {
      _purchasing = true;
      _errorMessage = null;
    });
    try {
      final ok = await SubscriptionService.restorePurchases();
      if (mounted) {
        if (ok) {
          _restartApp();
        } else {
          setState(
              () => _errorMessage = AppLocalizations.of(context).paywallZadnePredplatne);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = AppLocalizations.of(context).paywallChybaObnoveni(e.toString()));
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  void _restartApp() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (_) => false,
    );
  }

  Future<void> _kontaktovatCustom() async {
    final subject =
        Uri.encodeComponent('Poptávka individuálního plánu Torkis');
    final body = Uri.encodeComponent(
      'Dobrý den,\n\n'
      'Mám zájem o individuální nabídku plánu Custom pro svůj autoservis.\n\n'
      'Informace o servisu:\n'
      '  Servis ID: ${globalServisId ?? "neznámé"}\n'
      '  Aktuální plán: ${globalPlanTyp.toUpperCase()}\n\n'
      'Prosím o zaslání nabídky.\n\n'
      's pozdravem',
    );
    final uri = Uri.parse(
        'mailto:$kKontaktEmail?subject=$subject&body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).predChybaEmailKlient)),
      );
    }
  }

  Package? _packageFor(String tier) {
    final suffix = _period == _Period.monthly ? 'monthly' : 'yearly';
    return _packages['${tier}_$suffix'];
  }

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    final l10n = AppLocalizations.of(context);
    final jeTrialAktivni = (widget.zbyvajiciDniTrialu ?? 0) > 0;

    return Scaffold(
      backgroundColor: tok.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: TokSpace.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TorkisBrandHeader(
                padding: EdgeInsets.fromLTRB(
                    TokSpace.xl, TokSpace.lg, TokSpace.xl, 4),
              ),
              TorkisPageTitle(
                title: l10n.paywallTitle,
                subtitle: jeTrialAktivni
                    ? l10n.paywallSubtitleTrialEnding
                    : l10n.paywallSubtitleTrialExpired,
              ),
              const SizedBox(height: TokSpace.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: TokSpace.xl),
                child: TorkisInfoBanner(
                  icon: jeTrialAktivni
                      ? Icons.access_time_rounded
                      : Icons.info_outline_rounded,
                  accentColor: jeTrialAktivni
                      ? TokColors.warning
                      : TokColors.accent,
                  title: jeTrialAktivni
                      ? l10n.paywallTrialZbyva(widget.zbyvajiciDniTrialu!, _dayWord(widget.zbyvajiciDniTrialu!))
                      : l10n.nastTrialVyprselo,
                  subtitle: l10n.paywallBezpeci,
                ),
              ),
              const SizedBox(height: TokSpace.lg),
              Center(
                child: TorkisSegmented<_Period>(
                  selected: _period,
                  onChanged: (p) => setState(() => _period = p),
                  options: [
                    (value: _Period.monthly, label: l10n.predMesicne, badge: null),
                    (value: _Period.yearly, label: l10n.predRocne, badge: '−19 %'),
                  ],
                ),
              ),
              const SizedBox(height: TokSpace.lg),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: TokSpace.lg),
                  child: Column(
                    children: [
                      PaywallPlanCard(
                        name: 'Basic',
                        description: l10n.predBasicDesc,
                        features: [
                          l10n.predFeat50Zaznamu,
                          l10n.predFeat3Uziv,
                          l10n.predFeatFotodok,
                          l10n.predFeatEvidZak,
                          l10n.predFeatHistorie,
                          l10n.predFeatSpravaTymu,
                        ],
                        package: _packageFor('basic'),
                        periodMonthly: _period == _Period.monthly,
                        purchasing: _purchasing,
                        onPurchase: _purchase,
                        featured: false,
                      ),
                      PaywallPlanCard(
                        name: 'Standard',
                        description: l10n.predStandardDesc,
                        featured: true,
                        features: [
                          l10n.predFeat150Zaznamu,
                          l10n.predFeat10Uziv,
                          l10n.predFeatVseBasic,
                          l10n.predFeatReporty,
                          l10n.predFeatChat,
                          l10n.predFeatWebPortal,
                        ],
                        package: _packageFor('standard'),
                        periodMonthly: _period == _Period.monthly,
                        purchasing: _purchasing,
                        onPurchase: _purchase,
                      ),
                      PaywallPlanCard(
                        name: 'Pro',
                        description: l10n.predProDesc,
                        features: [
                          l10n.predFeatNeomezZaznamu,
                          l10n.predFeatNeomezUziv,
                          l10n.predFeatVseStandard,
                          l10n.predFeat5TrzniHodnota,
                          l10n.predFeatPrioritniPodpora,
                          l10n.predFeatPokrocileStatistiky,
                          l10n.predFeatVicenasobinaVzd,
                        ],
                        package: _packageFor('pro'),
                        periodMonthly: _period == _Period.monthly,
                        purchasing: _purchasing,
                        onPurchase: _purchase,
                      ),
                      PaywallPlanCard(
                        name: 'Custom',
                        description: l10n.predCustomDesc,
                        features: [
                          l10n.predFeatErp,
                          l10n.predFeatNeomezVin,
                          l10n.predFeatPrioritniSla,
                        ],
                        package: null,
                        periodMonthly: _period == _Period.monthly,
                        purchasing: false,
                        isCustom: true,
                        onContact: () => _kontaktovatCustom(),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: TokSpace.lg),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: TokSpace.lg),
                child: PaywallTrustStrip(),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      TokSpace.xl, TokSpace.md, TokSpace.xl, 0),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: TokColors.danger,
                      fontSize: 13,
                    ),
                  ),
                ),
              const SizedBox(height: TokSpace.md),
              Center(
                child: TextButton(
                  onPressed: _purchasing ? null : _restore,
                  child: Text(
                    l10n.paywallObnovitNakupy,
                    style: TextStyle(
                      color: tok.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: Text(
                    l10n.mainOdhlasitSe,
                    style: TextStyle(
                      color: tok.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TokSpace.sm),
              Center(
                child: Text(
                  l10n.predFootnote,
                  style: TextStyle(
                    fontSize: 11,
                    color: tok.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dayWord(int n) {
    final l10n = AppLocalizations.of(context);
    if (n == 1) return l10n.nastDayJeden;
    if (n >= 2 && n <= 4) return l10n.nastDayNeco;
    return l10n.nastDayMnogo;
  }
}

class PaywallPlanCard extends StatelessWidget {
  final String name;
  final String description;
  final List<String> features;
  final Package? package;
  final bool periodMonthly; // true = měsíčně, false = ročně
  final bool purchasing;
  final bool featured;
  final Future<void> Function(Package?)? onPurchase;
  // Custom mód: bez ceny, jen kontakt přes externí akci (např. email).
  final bool isCustom;
  final VoidCallback? onContact;
  // Volitelný stav pro tlačítko (např. "Aktuální plán" disabled).
  final String? currentPlanLabel;
  final bool isCurrentPlan;

  const PaywallPlanCard({
    super.key,
    required this.name,
    required this.description,
    required this.features,
    required this.package,
    required this.periodMonthly,
    required this.purchasing,
    this.onPurchase,
    this.featured = false,
    this.isCustom = false,
    this.onContact,
    this.currentPlanLabel,
    this.isCurrentPlan = false,
  });

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    final l10n = AppLocalizations.of(context);
    final bg = featured ? TokColors.ink : tok.surface;
    final fg = featured ? Colors.white : tok.textPrimary;
    final subFg = featured ? TokColors.steelSoft : tok.textSecondary;
    final accentLabel = featured ? TokColors.accent : tok.textSecondary;

    final periodLabel = periodMonthly ? l10n.predPeriodMesic : l10n.predPeriodRoc;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          margin: const EdgeInsets.only(bottom: TokSpace.md),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(TokRadius.xl),
            border: featured ? null : Border.all(color: tok.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accentLabel,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              if (isCustom)
                Text(
                  l10n.predCenaNaMiru,
                  style: TextStyle(
                    fontFamily: 'IBMPlexMono',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: fg,
                    letterSpacing: -0.3,
                    height: 1,
                  ),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        package?.storeProduct.priceString ?? '—',
                        style: TextStyle(
                          fontFamily: 'IBMPlexMono',
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: fg,
                          letterSpacing: -0.6,
                          height: 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '/ $periodLabel',
                        style: TextStyle(fontSize: 13, color: subFg),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: subFg, height: 1.4),
              ),
              const SizedBox(height: TokSpace.md),
              ...features.map(
                  (f) => TorkisFeatureCheck(text: f, dark: featured)),
              const SizedBox(height: TokSpace.md),
              SizedBox(
                height: 46,
                width: double.infinity,
                child: _buildCta(context, tok, fg),
              ),
            ],
          ),
        ),
        if (featured)
          Positioned(
            top: 14,
            right: 14,
            child: _Pill(
              text: l10n.predDoporucujeme,
              bg: TokColors.accent,
              fg: Colors.white,
            ),
          ),
        if (isCurrentPlan)
          Positioned(
            top: 14,
            right: 14,
            child: _Pill(
              text: currentPlanLabel ?? l10n.predAktualniPlanPill,
              bg: TokColors.success,
              fg: Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildCta(BuildContext context, TorkisTokens tok, Color fg) {
    final l10n = AppLocalizations.of(context);
    if (isCurrentPlan) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: tok.bg,
          foregroundColor: tok.textSecondary,
          disabledBackgroundColor: tok.bg,
          disabledForegroundColor: tok.textSecondary,
          side: BorderSide(color: tok.line),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TokRadius.md),
          ),
        ),
        child: Text(l10n.predAktualneAktivni,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      );
    }

    if (isCustom) {
      return ElevatedButton(
        onPressed: onContact,
        style: ElevatedButton.styleFrom(
          backgroundColor: featured ? TokColors.accent : tok.bg,
          foregroundColor: featured ? Colors.white : tok.textPrimary,
          side: featured ? null : BorderSide(color: tok.line),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TokRadius.md),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mail_outline_rounded, size: 16),
            const SizedBox(width: 6),
            Text(l10n.predMamZajem,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return ElevatedButton(
      onPressed: (purchasing || package == null || onPurchase == null)
          ? null
          : () => onPurchase!(package),
      style: ElevatedButton.styleFrom(
        backgroundColor: featured ? TokColors.accent : tok.bg,
        foregroundColor: featured ? Colors.white : tok.textPrimary,
        side: featured ? null : BorderSide(color: tok.line),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TokRadius.md),
        ),
      ),
      child: purchasing
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.predVybrat(name),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, size: 14),
              ],
            ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Pill({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(TokRadius.round),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class PaywallTrustStrip extends StatelessWidget {
  const PaywallTrustStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: TokSpace.md, vertical: TokSpace.md),
      decoration: BoxDecoration(
        color: tok.surface,
        border: Border.all(color: tok.line),
        borderRadius: BorderRadius.circular(TokRadius.xl),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TrustItem(
              icon: Icons.cloud_done_outlined,
              title: l10n.paywallTrust1Title,
              subtitle: l10n.paywallTrust1Sub,
            ),
          ),
          const _TrustDivider(),
          Expanded(
            child: _TrustItem(
              icon: Icons.download_done_rounded,
              title: l10n.paywallTrust2Title,
              subtitle: l10n.paywallTrust2Sub,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: TokColors.accent),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: tok.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(fontSize: 10, color: tok.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _TrustDivider extends StatelessWidget {
  const _TrustDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: context.tok.line,
      margin: const EdgeInsets.symmetric(horizontal: TokSpace.sm),
    );
  }
}
