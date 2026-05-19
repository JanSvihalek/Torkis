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
  List<Package> _packages = [];
  bool _loading = true;
  bool _purchasing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final packages = await SubscriptionService.getPackages();
    if (mounted) setState(() { _packages = packages; _loading = false; });
  }

  Future<void> _purchase(Package package) async {
    setState(() { _purchasing = true; _errorMessage = null; });
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
    setState(() { _purchasing = true; _errorMessage = null; });
    try {
      final ok = await SubscriptionService.restorePurchases();
      if (mounted) {
        if (ok) {
          _restartApp();
        } else {
          setState(() => _errorMessage = 'Nenalezeno žádné aktivní předplatné.');
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

  String _formatPrice(Package package) {
    final product = package.storeProduct;
    return product.priceString;
  }

  String _formatPeriod(Package package) {
    switch (package.packageType) {
      case PackageType.monthly:    return '/ měsíc';
      case PackageType.annual:     return '/ rok';
      case PackageType.weekly:     return '/ týden';
      case PackageType.lifetime:   return 'jednorázově';
      default:                     return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final jeTrialAktivni = (widget.zbyvajiciDniTrialu ?? 0) > 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1A2E) : const Color(0xFFF5F8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Logo + název
              Image.asset('assets/images/torkis-app-icon-192.png', width: 72, height: 72),
              const SizedBox(height: 14),
              Text('TORKIS',
                  style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1,
                    color: isDark ? Colors.white : const Color(0xFF0B1A2E),
                  )),
              const SizedBox(height: 32),

              // Stav trialu
              if (jeTrialAktivni) ...[
                _infoBanner(
                  icon: Icons.access_time_rounded,
                  color: Colors.orange,
                  text: 'Zbývá ${widget.zbyvajiciDniTrialu} dní bezplatného zkušebního období.',
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                Text('Pokračujte s plným přístupem\npodle vašeho výběru.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54)),
              ] else ...[
                _infoBanner(
                  icon: Icons.lock_outline_rounded,
                  color: Colors.redAccent,
                  text: 'Zkušební období vypršelo.',
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                Text('Pro pokračování v používání Torkis\naktivujte předplatné.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54)),
              ],

              const SizedBox(height: 32),

              // Co zahrnuje předplatné
              _featureList(isDark),

              const SizedBox(height: 28),

              // Balíčky z RevenueCat
              if (_loading)
                const CircularProgressIndicator()
              else if (_packages.isEmpty)
                _placeholderPricing(isDark)
              else
                ..._packages.map((pkg) => _packageCard(pkg, isDark)),

              const SizedBox(height: 16),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ),

              // Obnovit nákupy
              TextButton(
                onPressed: _purchasing ? null : _restore,
                child: Text('Obnovit nákupy',
                    style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38, fontSize: 13)),
              ),

              // Odhlásit se
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: Text('Odhlásit se',
                    style: TextStyle(
                        color: isDark ? Colors.white24 : Colors.black26, fontSize: 12)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBanner({required IconData icon, required Color color, required String text, required bool isDark}) {
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
          Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _featureList(bool isDark) {
    final features = [
      'Příjem vozidla s fotodokumentací',
      'Historie příjmů a zákazníků',
      'Evidence vozidel',
      'Plánovač a statistiky',
      'Správa týmu a práv',
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A5F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Co předplatné zahrnuje:',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 13)),
          const SizedBox(height: 10),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text(f, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _packageCard(Package package, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _purchasing ? null : () => _purchase(package),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _purchasing
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Column(
                  children: [
                    Text(package.storeProduct.title.isNotEmpty
                            ? package.storeProduct.title
                            : 'Torkis předplatné',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${_formatPrice(package)} ${_formatPeriod(package)}',
                        style: const TextStyle(fontSize: 13, color: Colors.white70)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _placeholderPricing(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A5F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium_outlined, color: Colors.blue, size: 36),
          const SizedBox(height: 10),
          const Text('Předplatné se připravuje',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text('Pro aktivaci kontaktujte podporu na\npodpora@torkis.cz',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white54 : Colors.black45)),
        ],
      ),
    );
  }
}
