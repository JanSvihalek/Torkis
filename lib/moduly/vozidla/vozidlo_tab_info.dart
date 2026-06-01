import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../zakaznici/zakaznik_detail.dart';
import '../prijem/prijem_vozidla_tablet_layout.dart' show kTabletBreakpoint;
import '../../core/design_tokens.dart';

class VozidloInfoTab extends StatelessWidget {
  final bool isDark;
  final User user;
  final Map<String, dynamic> autoData;
  final String spz;
  final String zakaznikId;
  final String znackaNazev;
  final String palivo;
  final String prevodovka;
  final String tacho;
  final String stkM;
  final String stkR;

  const VozidloInfoTab({
    super.key,
    required this.isDark,
    required this.user,
    required this.autoData,
    required this.spz,
    required this.zakaznikId,
    required this.znackaNazev,
    required this.palivo,
    required this.prevodovka,
    required this.tacho,
    required this.stkM,
    required this.stkR,
  });

  // ── Helpers ────────────────────────────────────────────────────────────────

  String get _vehicleTitle =>
      '${autoData['znacka'] ?? ''} ${autoData['model'] ?? ''}'.trim();

  String get _vehicleSubtitle {
    final parts = <String>[
      if ((autoData['motorizace']?.toString() ?? '').isNotEmpty)
        autoData['motorizace'].toString(),
      if ((autoData['rok_vyroby']?.toString() ?? '').isNotEmpty)
        autoData['rok_vyroby'].toString(),
      if (palivo.isNotEmpty) palivo,
    ];
    return parts.join(' · ');
  }

  int _stkRemainingMonths() {
    final m = int.tryParse(stkM) ?? 0;
    final y = int.tryParse(stkR) ?? 0;
    if (m == 0 || y == 0) return 0;
    final now = DateTime.now();
    return (y - now.year) * 12 + (m - now.month);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    return FutureBuilder<int>(
      future: _fetchPrijmuCount(),
      builder: (context, prijmuSnap) {
        final prijmuCount = prijmuSnap.data ?? 0;
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= kTabletBreakpoint &&
                MediaQuery.orientationOf(context) == Orientation.landscape) {
              return _buildTabletLayout(context, tok, prijmuCount);
            }
            return _buildMobileLayout(context, tok, prijmuCount);
          },
        );
      },
    );
  }

  Future<int> _fetchPrijmuCount() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('zakazky')
          .where('servis_id', isEqualTo: user.uid)
          .where('spz', isEqualTo: spz)
          .get();
      return snap.docs.length;
    } catch (_) {
      return 0;
    }
  }

  // ── Tablet layout ──────────────────────────────────────────────────────────

  Widget _buildTabletLayout(
      BuildContext context, TorkisTokens tok, int prijmuCount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Levý tmavý panel
        _buildLeftPanel(prijmuCount),
        // Střed: technické údaje
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(TokSpace.xl),
            child: Column(
              children: [
                _techCard(tok),
                const SizedBox(height: TokSpace.xl),
              ],
            ),
          ),
        ),
        // Pravý panel: majitel
        if (zakaznikId.isNotEmpty)
          SizedBox(
            width: 300,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(TokSpace.xl),
              child: Column(
                children: [
                  _ownerCard(context, tok),
                  const SizedBox(height: TokSpace.xl),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLeftPanel(int prijmuCount) {
    return Container(
      width: 280,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [TokColors.ink, TokColors.inkSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(right: BorderSide(color: TokColors.darkLine)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(TokSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: TokSpace.lg),
            // Ikona auta
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_car_rounded,
                  size: 36, color: TokColors.steelSoft),
            ),
            const SizedBox(height: TokSpace.lg),
            // SPZ
            _buildSpzPlate(),
            const SizedBox(height: TokSpace.lg),
            // Název
            if (_vehicleTitle.isNotEmpty)
              Text(
                _vehicleTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            if (_vehicleSubtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _vehicleSubtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: TokSpace.xl),
            // Stats
            _buildStatsRow(prijmuCount),
            const SizedBox(height: TokSpace.lg),
            // STK banner
            _buildStkBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildSpzPlate() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(TokRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            padding: const EdgeInsets.symmetric(vertical: 3),
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: TokColors.accent2,
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🇨🇿', style: TextStyle(fontSize: 9)),
                Text('CZ',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text(
            spz.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              letterSpacing: 2,
              color: TokColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int prijmuCount) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(TokRadius.md),
      ),
      padding: const EdgeInsets.symmetric(vertical: TokSpace.md),
      child: Row(
        children: [
          _statItem('TACHOMETR', tacho.isNotEmpty ? '$tacho km' : '—'),
          _statDivider(),
          _statItem('STK DO',
              stkM.isNotEmpty && stkR.isNotEmpty ? '$stkM / $stkR' : '—'),
          _statDivider(),
          _statItem('PŘÍJMŮ', '$prijmuCount'),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Colors.white.withValues(alpha: 0.45)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
        width: 1, height: 32, color: Colors.white.withValues(alpha: 0.12));
  }

  Widget _buildStkBanner() {
    if (stkM.isEmpty || stkR.isEmpty) return const SizedBox.shrink();
    final remaining = _stkRemainingMonths();
    final isValid = remaining >= 0;
    final color = isValid ? const Color(0xFF22C55E) : Colors.redAccent;
    final icon = isValid ? Icons.verified_outlined : Icons.warning_amber_outlined;
    final title = isValid ? 'STK platná' : 'STK prošlá';
    final subtitle = isValid
        ? 'Vyprší $stkM/$stkR · zbývá $remaining měsíců'
        : 'Vypršela $stkM/$stkR';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: TokSpace.md, vertical: TokSpace.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(TokRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: TokSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
                Text(subtitle,
                    style: TextStyle(
                        color: color.withValues(alpha: 0.75), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile layout ──────────────────────────────────────────────────────────

  Widget _buildMobileLayout(
      BuildContext context, TorkisTokens tok, int prijmuCount) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMobileHeader(prijmuCount),
          Padding(
            padding: const EdgeInsets.all(TokSpace.xl),
            child: Column(
              children: [
                _techCard(tok),
                if (zakaznikId.isNotEmpty) ...[
                  const SizedBox(height: TokSpace.lg),
                  _ownerCard(context, tok),
                ],
                const SizedBox(height: TokSpace.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(int prijmuCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          TokSpace.xl, TokSpace.xxl, TokSpace.xl, TokSpace.xl),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [TokColors.ink, TokColors.inkSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_car_rounded,
                size: 30, color: TokColors.steelSoft),
          ),
          const SizedBox(height: TokSpace.lg),
          _buildSpzPlate(),
          if (_vehicleTitle.isNotEmpty) ...[
            const SizedBox(height: TokSpace.md),
            Text(_vehicleTitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ],
          if (_vehicleSubtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(_vehicleSubtitle,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12)),
          ],
          const SizedBox(height: TokSpace.xl),
          _buildStatsRow(prijmuCount),
          const SizedBox(height: TokSpace.lg),
          _buildStkBanner(),
        ],
      ),
    );
  }

  // ── Cards ──────────────────────────────────────────────────────────────────

  Widget _techCard(TorkisTokens tok) {
    return _sectionCard(
      tok,
      icon: Icons.directions_car_outlined,
      title: 'Technické údaje',
      children: [
        _infoRow(tok, 'Značka & Model', _vehicleTitle),
        _infoRow(tok, 'Motorizace', autoData['motorizace']),
        _infoRow(tok, 'VIN', autoData['vin']),
        _infoRow(tok, 'Rok výroby', autoData['rok_vyroby']),
        _infoRow(tok, 'Palivo', autoData['palivo']),
        _infoRow(tok, 'Převodovka', autoData['prevodovka']),
        _infoRow(tok, 'Tachometr', tacho.isNotEmpty ? '$tacho km' : null),
      ],
    );
  }

  Widget _ownerCard(BuildContext context, TorkisTokens tok) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('zakaznici')
          .where('servis_id', isEqualTo: user.uid)
          .where('id_zakaznika', isEqualTo: zakaznikId)
          .limit(1)
          .get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const SizedBox();
        }
        final zd = snap.data!.docs.first.data() as Map<String, dynamic>;
        final telefon = zd['telefon']?.toString() ?? '';
        final email = zd['email']?.toString() ?? '';

        return _sectionCard(
          tok,
          icon: Icons.person_outline_rounded,
          title: 'Majitel vozidla',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ZakaznikDetailScreen(zakaznikData: zd)),
          ),
          children: [
            _infoRow(tok, 'Jméno', zd['jmeno']),
            _infoRow(tok, 'Telefon', telefon),
            _infoRow(tok, 'E-mail', email),
            if (telefon.isNotEmpty || email.isNotEmpty) ...[
              const SizedBox(height: TokSpace.md),
              Row(
                children: [
                  if (telefon.isNotEmpty)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            launchUrl(Uri.parse('tel:$telefon')),
                        icon: const Icon(Icons.phone_outlined, size: 16),
                        label: const Text('Volat'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: tok.accent,
                          side: BorderSide(color: tok.line),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(TokRadius.md)),
                        ),
                      ),
                    ),
                  if (telefon.isNotEmpty && email.isNotEmpty)
                    const SizedBox(width: TokSpace.sm),
                  if (email.isNotEmpty)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            launchUrl(Uri.parse('mailto:$email')),
                        icon: const Icon(Icons.mail_outline_rounded,
                            size: 16),
                        label: const Text('E-mail'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: tok.accent,
                          side: BorderSide(color: tok.line),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(TokRadius.md)),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _sectionCard(
    TorkisTokens tok, {
    required IconData icon,
    required String title,
    required List<Widget> children,
    VoidCallback? onTap,
  }) {
    final container = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tok.surface,
        borderRadius: BorderRadius.circular(TokRadius.xl),
        border: Border.all(color: tok.line),
      ),
      padding: const EdgeInsets.all(TokSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: tok.accent, size: 20),
              const SizedBox(width: TokSpace.sm),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: tok.textPrimary)),
              ),
              if (onTap != null)
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: tok.textSecondary),
            ],
          ),
          Divider(height: TokSpace.xl, color: tok.line),
          ...children,
        ],
      ),
    );
    if (onTap == null) return container;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TokRadius.xl),
      child: container,
    );
  }

  Widget _infoRow(TorkisTokens tok, String label, dynamic value) {
    final val = value?.toString() ?? '';
    if (val.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: TokSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(color: tok.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(val,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: tok.textPrimary)),
          ),
        ],
      ),
    );
  }
}
