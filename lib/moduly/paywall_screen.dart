import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../core/subscription_service.dart';
import 'auth_gate.dart';

class PaywallScreen extends StatefulWidget {
  final int? zbyvajiciDniTrialu;

  const PaywallScreen({super.key, this.zbyvajiciDniTrialu});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Map<String, Package> _packages = {};
  bool _loading = true;
  bool _purchasing = false;
  String? _errorMessage;

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
    if (mounted)
      setState(() {
        _packages = map;
        _loading = false;
      });
  }

  Future<void> _purchase(Package package) async {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final jeTrialAktivni = (widget.zbyvajiciDniTrialu ?? 0) > 0;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0B1A2E) : const Color(0xFFF5F8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Image.asset('assets/images/torkis-app-icon-192.png',
                  width: 64, height: 64),
              const SizedBox(height: 12),
              Text('TORKIS',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: isDark ? Colors.white : const Color(0xFF0B1A2E),
                  )),
              const SizedBox(height: 24),
              if (jeTrialAktivni)
                _infoBanner(
                  icon: Icons.access_time_rounded,
                  color: Colors.orange,
                  text:
                      'Zbývá ${widget.zbyvajiciDniTrialu} dní zkušebního období.',
                  isDark: isDark,
                )
              else
                _infoBanner(
                  icon: Icons.lock_outline_rounded,
                  color: Colors.redAccent,
                  text: 'Zkušební období vypršelo. Vyberte plán.',
                  isDark: isDark,
                ),
              const SizedBox(height: 28),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(),
                )
              else ...[
                _planCard(
                  isDark: isDark,
                  planName: 'Basic',
                  limit: '50 příjmů / měsíc',
                  features: const [
                    'Příjem vozidla s fotodokumentací',
                    'Evidence zákazníků a vozidel',
                    'Historie příjmů',
                    'Správa týmu a práv',
                  ],
                  monthlyPkg: _packages['basic_monthly'],
                  yearlyPkg: _packages['basic_yearly'],
                  highlight: false,
                ),
                const SizedBox(height: 12),
                _planCard(
                  isDark: isDark,
                  planName: 'Standard',
                  limit: '150 příjmů / měsíc',
                  features: const [
                    'Příjem vozidla s fotodokumentací',
                    'Evidence zákazníků a vozidel',
                    'Historie příjmů',
                    'Správa týmu a práv',
                    'Statistiky',
                  ],
                  monthlyPkg: _packages['standard_monthly'],
                  yearlyPkg: _packages['standard_yearly'],
                  highlight: true,
                ),
                const SizedBox(height: 12),
                _planCard(
                  isDark: isDark,
                  planName: 'Pro',
                  limit: 'Neomezené příjmy',
                  features: const [
                    'Příjem vozidla s fotodokumentací',
                    'Evidence zákazníků a vozidel',
                    'Historie příjmů',
                    'Správa týmu a práv',
                    'Statistiky',
                  ],
                  monthlyPkg: _packages['pro_monthly'],
                  yearlyPkg: _packages['pro_yearly'],
                  highlight: false,
                ),
              ],
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 13)),
                ),
              TextButton(
                onPressed: _purchasing ? null : _restore,
                child: Text('Obnovit nákupy',
                    style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 13)),
              ),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: Text('Odhlásit se',
                    style: TextStyle(
                        color: isDark ? Colors.white24 : Colors.black26,
                        fontSize: 12)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _planCard({
    required bool isDark,
    required String planName,
    required String limit,
    required List<String> features,
    required Package? monthlyPkg,
    required Package? yearlyPkg,
    required bool highlight,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A5F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? Colors.blue
              : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
          width: highlight ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: highlight
                  ? Colors.blue.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(planName,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: isDark ? Colors.white : const Color(0xFF0B1A2E),
                    )),
                if (highlight)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Nejpopulárnější',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inbox_rounded,
                        size: 14, color: Colors.blue),
                    const SizedBox(width: 5),
                    Text(limit,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 10),
                ...features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: Icon(Icons.check_rounded,
                                size: 14, color: Colors.green),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(f,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87)),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _priceButton(monthlyPkg, '/ měsíc', isDark)),
                    const SizedBox(width: 8),
                    Expanded(child: _priceButton(yearlyPkg, '/ rok', isDark)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceButton(Package? pkg, String period, bool isDark) {
    if (pkg == null) {
      return Container(
        height: 54,
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text('—',
              style:
                  TextStyle(color: isDark ? Colors.white30 : Colors.black26)),
        ),
      );
    }
    return ElevatedButton(
      onPressed: _purchasing ? null : () => _purchase(pkg),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: _purchasing
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(pkg.storeProduct.priceString,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(period,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
    );
  }

  Widget _infoBanner({
    required IconData icon,
    required Color color,
    required String text,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14))),
        ],
      ),
    );
  }
}
