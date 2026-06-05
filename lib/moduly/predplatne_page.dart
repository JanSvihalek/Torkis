import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import '../core/design_tokens.dart';
import '../core/subscription_service.dart';
import '../core/torkis_ui.dart';
import '../l10n/app_localizations.dart';
import 'auth_gate.dart';
import 'paywall_screen.dart';

class PredplatnePage extends StatefulWidget {
  const PredplatnePage({super.key});

  @override
  State<PredplatnePage> createState() => _PredplatnePageState();
}

enum _Period { monthly, yearly }

class _PredplatnePageState extends State<PredplatnePage> {
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
      if (ok && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = AppLocalizations.of(context).predChybaNakup(e.toString()));
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _kontaktovatCustom() async {
    final subject = Uri.encodeComponent('Poptávka individuálního plánu Torkis');
    final body = Uri.encodeComponent(
      'Dobrý den,\n\n'
      'Mám zájem o individuální nabídku plánu Custom pro svůj autoservis.\n\n'
      'Informace o servisu:\n'
      '  Servis ID: ${globalServisId ?? "neznámé"}\n'
      '  Aktuální plán: ${globalPlanTyp.toUpperCase()}\n\n'
      'Prosím o zaslání nabídky.\n\n'
      's pozdravem',
    );
    final uri = Uri.parse('mailto:$kKontaktEmail?subject=$subject&body=$body');
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
    final aktualniPlan = globalPlanTyp;
    final jeTrial = aktualniPlan == 'trial';

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
                title: l10n.predTitle,
                subtitle: l10n.predSubtitle,
              ),
              const SizedBox(height: TokSpace.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: TokSpace.xl),
                child: TorkisInfoBanner(
                  icon: jeTrial
                      ? Icons.access_time_rounded
                      : Icons.workspace_premium_outlined,
                  accentColor: jeTrial ? TokColors.warning : TokColors.success,
                  title: jeTrial
                      ? l10n.predTrialBannerTitle
                      : l10n.predAktivniPlanTitle(aktualniPlan.toUpperCase()),
                  subtitle: jeTrial
                      ? l10n.predTrialBannerSubtitle
                      : l10n.predAktivniPlanSubtitle,
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
                          l10n.predFeat30Vin,
                          l10n.predFeat1TrzniHodnota,
                          l10n.predFeatNeomezStk,
                          l10n.predFeatFotodok,
                          l10n.predFeatEvidZak,
                          l10n.predFeatHistorie,
                          l10n.predFeatSpravaTymu,
                        ],
                        package: _packageFor('basic'),
                        periodMonthly: _period == _Period.monthly,
                        purchasing: _purchasing,
                        onPurchase: _purchase,
                        isCurrentPlan: aktualniPlan == 'basic',
                      ),
                      PaywallPlanCard(
                        name: 'Standard',
                        description: l10n.predStandardDesc,
                        featured: aktualniPlan != 'standard',
                        features: [
                          l10n.predFeat150Zaznamu,
                          l10n.predFeat10Uziv,
                          l10n.predFeat75Vin,
                          l10n.predFeat3TrzniHodnota,
                          l10n.predFeatNeomezStk,
                          l10n.predFeatVseBasic,
                          l10n.predFeatReporty,
                          l10n.predFeatChat,
                          l10n.predFeatWebPortal,
                        ],
                        package: _packageFor('standard'),
                        periodMonthly: _period == _Period.monthly,
                        purchasing: _purchasing,
                        onPurchase: _purchase,
                        isCurrentPlan: aktualniPlan == 'standard',
                      ),
                      PaywallPlanCard(
                        name: 'Pro',
                        description: l10n.predProDesc,
                        features: [
                          l10n.predFeatNeomezZaznamu,
                          l10n.predFeatNeomezUziv,
                          l10n.predFeatVseStandard,
                          l10n.predFeat150Vin,
                          l10n.predFeat5TrzniHodnota,
                          l10n.predFeatNeomezStk,
                          l10n.predFeatPrioritniPodpora,
                          l10n.predFeatPokrocileStatistiky,
                          l10n.predFeatVicenasobinaVzd,
                        ],
                        package: _packageFor('pro'),
                        periodMonthly: _period == _Period.monthly,
                        purchasing: _purchasing,
                        onPurchase: _purchase,
                        isCurrentPlan: aktualniPlan == 'pro',
                      ),
                      PaywallPlanCard(
                        name: 'Custom',
                        description: l10n.predCustomDesc,
                        features: [
                          l10n.predFeatErp,
                          l10n.predFeatNeomezVin,
                          l10n.predFeatNeomezTrzni,
                          l10n.predFeatPrioritniSla,
                        ],
                        package: null,
                        periodMonthly: _period == _Period.monthly,
                        purchasing: false,
                        isCustom: true,
                        onContact: _kontaktovatCustom,
                        isCurrentPlan: aktualniPlan == 'custom',
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
}
