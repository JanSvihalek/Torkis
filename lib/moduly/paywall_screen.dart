import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../core/design_tokens.dart';
import '../core/subscription_service.dart';
import '../core/torkis_ui.dart';
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
      if (mounted) setState(() => _errorMessage = 'Nákup se nepodařil: $e');
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
              () => _errorMessage = 'Nenalezeno žádné aktivní předplatné.');
        }
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Chyba obnovení: $e');
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

  Package? _packageFor(String tier) {
    final suffix = _period == _Period.monthly ? 'monthly' : 'yearly';
    return _packages['${tier}_$suffix'];
  }

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
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
                title: 'Vyberte plán',
                subtitle: jeTrialAktivni
                    ? 'Vaše zkušební období brzy končí. Vyberte plán pro pokračování.'
                    : 'Vaše zkušební období skončilo. Vyberte plán odpovídající velikosti servisu.',
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
                      ? 'Zbývá ${widget.zbyvajiciDniTrialu} ${_dayWord(widget.zbyvajiciDniTrialu!)} zkušebního období'
                      : 'Zkušební období vypršelo',
                  subtitle:
                      'Vaše data jsou v bezpečí. Po výběru plánu vše obnovíme.',
                ),
              ),
              const SizedBox(height: TokSpace.lg),
              Center(
                child: TorkisSegmented<_Period>(
                  selected: _period,
                  onChanged: (p) => setState(() => _period = p),
                  options: const [
                    (value: _Period.monthly, label: 'Měsíčně', badge: null),
                    (value: _Period.yearly, label: 'Ročně', badge: '−15 %'),
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
                      _PlanCard(
                        name: 'Basic',
                        description: 'Pro malé autoservisy a OSVČ.',
                        features: const [
                          '50 příjmů / měsíc',
                          '3 uživatelé max.',
                          'Fotodokumentace',
                          'Evidence zákazníků a vozidel',
                          'Historie příjmů',
                          'Správa týmu',
                        ],
                        package: _packageFor('basic'),
                        period: _period,
                        purchasing: _purchasing,
                        onPurchase: _purchase,
                        featured: false,
                      ),
                      const SizedBox(height: TokSpace.md),
                      _PlanCard(
                        name: 'Standard',
                        description:
                            'Pro střední servisy do 150 zakázek měsíčně.',
                        featured: true,
                        features: const [
                          '150 příjmů / měsíc',
                          '10 uživatelů max.',
                          'Vše z Basic',
                          'Reporty a statistiky',
                          'Chat se zákazníkem',
                          'Webový portál pro správu vozidel a zákazníků',
                        ],
                        package: _packageFor('standard'),
                        period: _period,
                        purchasing: _purchasing,
                        onPurchase: _purchase,
                      ),
                      const SizedBox(height: TokSpace.md),
                      _PlanCard(
                        name: 'Pro',
                        description:
                            'Pro velké servisy a sítě bez limitu příjmů.',
                        features: const [
                          'Neomezené příjmy',
                          'Neomezený počet uživatelů',
                          'Vše ze Standard',
                          'Prioritní podpora',
                          'Pokročilé statistiky',
                          'Vícenásobná pracoviště',
                        ],
                        package: _packageFor('pro'),
                        period: _period,
                        purchasing: _purchasing,
                        onPurchase: _purchase,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: TokSpace.lg),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: TokSpace.lg),
                child: _TrustStrip(),
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
                    'Obnovit nákupy',
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
                    'Odhlásit se',
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

  String _dayWord(int n) {
    if (n == 1) return 'den';
    if (n >= 2 && n <= 4) return 'dny';
    return 'dní';
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String description;
  final List<String> features;
  final Package? package;
  final _Period period;
  final bool purchasing;
  final bool featured;
  final Future<void> Function(Package?) onPurchase;

  const _PlanCard({
    required this.name,
    required this.description,
    required this.features,
    required this.package,
    required this.period,
    required this.purchasing,
    required this.onPurchase,
    this.featured = false,
  });

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    // Featured = vždy deep ink (kontrast v light i dark modu).
    final bg = featured ? TokColors.ink : tok.surface;
    final fg = featured ? Colors.white : tok.textPrimary;
    final subFg = featured ? TokColors.steelSoft : tok.textSecondary;
    final accentLabel = featured ? TokColors.accent : tok.textSecondary;

    final priceString =
        package?.storeProduct.priceString ?? '—';
    final periodLabel =
        period == _Period.monthly ? 'měsíčně' : 'ročně';

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(22),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      priceString,
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
              ...features.map((f) => TorkisFeatureCheck(text: f, dark: featured)),
              const SizedBox(height: TokSpace.md),
              SizedBox(
                height: 46,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (purchasing || package == null)
                      ? null
                      : () => onPurchase(package),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        featured ? TokColors.accent : tok.bg,
                    foregroundColor: featured ? Colors.white : tok.textPrimary,
                    side: featured
                        ? null
                        : BorderSide(color: tok.line),
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
                            Text('Vybrat $name',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 14),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
        if (featured)
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: TokColors.accent,
                borderRadius: BorderRadius.circular(TokRadius.round),
              ),
              child: const Text(
                'DOPORUČUJEME',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: TokSpace.md, vertical: TokSpace.md),
      decoration: BoxDecoration(
        color: tok.surface,
        border: Border.all(color: tok.line),
        borderRadius: BorderRadius.circular(TokRadius.xl),
      ),
      child: Row(
        children: const [
          Expanded(
            child: _TrustItem(
              icon: Icons.cloud_done_outlined,
              title: '99,9 % dostupnost',
              subtitle: 'Garantovaná uptime SLA',
            ),
          ),
          _TrustDivider(),
          Expanded(
            child: _TrustItem(
              icon: Icons.download_done_rounded,
              title: 'Export dat zdarma',
              subtitle: 'Vaše data jsou vždy vaše',
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
