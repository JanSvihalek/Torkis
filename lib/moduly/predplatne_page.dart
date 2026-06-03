import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import '../core/design_tokens.dart';
import '../core/subscription_service.dart';
import '../core/torkis_ui.dart';
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
      if (mounted) setState(() => _errorMessage = 'Nákup se nepodařil: $e');
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
        const SnackBar(
            content: Text('Nepodařilo se otevřít e-mailového klienta.')),
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
              const TorkisPageTitle(
                title: 'Vaše předplatné',
                subtitle:
                    'Spravujte plán svého servisu a podle potřeby ho upgradujte.',
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
                      ? 'Aktivní zkušební doba'
                      : 'Aktivní plán: ${aktualniPlan.toUpperCase()}',
                  subtitle: jeTrial
                      ? 'Po skončení trialu si vyberete plán, který vám sedne.'
                      : 'Děkujeme, že používáte TORKIS.',
                ),
              ),
              const SizedBox(height: TokSpace.lg),
              Center(
                child: TorkisSegmented<_Period>(
                  selected: _period,
                  onChanged: (p) => setState(() => _period = p),
                  options: const [
                    (value: _Period.monthly, label: 'Měsíčně', badge: null),
                    (value: _Period.yearly, label: 'Ročně', badge: '−19 %'),
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
                        description: 'Pro malé autoservisy a OSVČ.',
                        features: const [
                          '50 záznamů/měsíc',
                          '3 uživatelé max.',
                          '30 dekodovaných VIN měsíčně',
                          'Fotodokumentace',
                          'Evidence zákazníků a vozidel',
                          'Historie záznamů',
                          'Správa týmu',
                        ],
                        package: _packageFor('basic'),
                        periodMonthly: _period == _Period.monthly,
                        purchasing: _purchasing,
                        onPurchase: _purchase,
                        isCurrentPlan: aktualniPlan == 'basic',
                      ),
                      PaywallPlanCard(
                        name: 'Standard',
                        description:
                            'Pro střední servisy do 150 zakázek měsíčně.',
                        featured: aktualniPlan != 'standard',
                        features: const [
                          '150 záznamů/měsíc',
                          '10 uživatelů max.',
                          '150 dekodovaných VIN měsíčně',
                          'Vše z Basic',
                          'Reporty a statistiky',
                          'Chat se zákazníkem',
                          'Webový portál pro správu vozidel a zákazníků',
                        ],
                        package: _packageFor('standard'),
                        periodMonthly: _period == _Period.monthly,
                        purchasing: _purchasing,
                        onPurchase: _purchase,
                        isCurrentPlan: aktualniPlan == 'standard',
                      ),
                      PaywallPlanCard(
                        name: 'Pro',
                        description:
                            'Pro velké servisy a sítě bez limitu záznamů.',
                        features: const [
                          'Neomezené záznamy',
                          'Neomezený počet uživatelů',
                          'Vše ze Standard',
                          '500 dekodovaných VIN měsíčně',
                          'Prioritní podpora',
                          'Pokročilé statistiky',
                          'Vícenásobná pracoviště',
                        ],
                        package: _packageFor('pro'),
                        periodMonthly: _period == _Period.monthly,
                        purchasing: _purchasing,
                        onPurchase: _purchase,
                        isCurrentPlan: aktualniPlan == 'pro',
                      ),
                      PaywallPlanCard(
                        name: 'Custom',
                        description:
                            'Individuální úprava pro speciální požadavky a integrace.',
                        features: const [
                          'Napojení na vaše ERP/DMS',
                          'Neomezený počet dekodovaných VIN měsíčně',
                          'Prioritní podpora s SLA',
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
                  'Bez závazku · Zrušení kdykoli · Ceny bez DPH',
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
