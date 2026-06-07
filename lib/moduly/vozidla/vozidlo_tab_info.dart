import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../zakaznici/zakaznik_detail.dart';
import '../prijem/prijem_vozidla_tablet_layout.dart' show kTabletBreakpoint;
import '../../core/design_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../auth_gate.dart';

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

  static const _flags = {
    'CZ': '🇨🇿',
    'SK': '🇸🇰',
    'DE': '🇩🇪',
    'AT': '🇦🇹',
    'PL': '🇵🇱',
    'HU': '🇭🇺',
    'FR': '🇫🇷',
    'IT': '🇮🇹',
    'GB': '🇬🇧',
    'NL': '🇳🇱',
    'UA': '🇺🇦',
  };

  String get _zeme => (autoData['zeme_registrace']?.toString() ?? 'CZ').toUpperCase();

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

  /// Naformátuje km s mezerami po tisících (320000 → "320 000").
  String _formatKm(String raw) {
    final n = int.tryParse(raw.replaceAll(RegExp(r'\D'), ''));
    if (n == null) return raw;
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  /// Zformátuje SPZ pro zobrazení (CZ 7znaková: "8H3 8179").
  String _formatPlate() {
    final s = spz.toUpperCase().replaceAll(' ', '');
    if (_zeme == 'CZ' && s.length == 7) {
      return '${s.substring(0, 3)} ${s.substring(3)}';
    }
    return s;
  }

  int _stkRemainingMonths() {
    final m = int.tryParse(stkM) ?? 0;
    final y = int.tryParse(stkR) ?? 0;
    if (m == 0 || y == 0) return 0;
    final now = DateTime.now();
    return (y - now.year) * 12 + (m - now.month);
  }

  String get _stkValue => (stkM.isNotEmpty && stkR.isNotEmpty)
      ? '${stkM.padLeft(2, '0')} / $stkR'
      : '—';

  /// Načte počet příjmů a URL loga značky jedním průchodem.
  Future<({int prijmu, String? logo})> _fetchHeaderData() async {
    int count = 0;
    String? logo;
    if (spz.isNotEmpty) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('zakazky')
            .where('servis_id', isEqualTo: globalServisId ?? user.uid)
            .where('spz', isEqualTo: spz)
            .get();
        count = snap.docs.length;
      } catch (_) {}
    }
    if (znackaNazev.isNotEmpty) {
      try {
        final q = await FirebaseFirestore.instance
            .collection('znacka')
            .where('nazev', isEqualTo: znackaNazev)
            .limit(1)
            .get();
        if (q.docs.isNotEmpty) {
          logo = q.docs.first.data()['logo']?.toString();
        }
      } catch (_) {}
    }
    return (prijmu: count, logo: (logo?.isNotEmpty ?? false) ? logo : null);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    return FutureBuilder<({int prijmu, String? logo})>(
      future: _fetchHeaderData(),
      builder: (context, headerSnap) {
        final prijmuCount = headerSnap.data?.prijmu ?? 0;
        final logoUrl = headerSnap.data?.logo;
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= kTabletBreakpoint &&
                MediaQuery.orientationOf(context) == Orientation.landscape) {
              return _buildTabletLayout(context, tok, prijmuCount, logoUrl);
            }
            return _buildMobileLayout(context, tok, prijmuCount, logoUrl);
          },
        );
      },
    );
  }

  // ── Tablet layout ──────────────────────────────────────────────────────────

  Widget _buildTabletLayout(
      BuildContext context, TorkisTokens tok, int prijmuCount, String? logo) {
    return Padding(
      padding: const EdgeInsets.all(TokSpace.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 320,
            child: _vehicleCard(context, prijmuCount, logo),
          ),
          const SizedBox(width: TokSpace.lg),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _techCard(context, tok),
                  if (autoData['technicke_udaje'] is Map &&
                      (autoData['technicke_udaje'] as Map).isNotEmpty) ...[
                    const SizedBox(height: TokSpace.lg),
                    _vinUdajeCard(context, tok),
                  ],
                ],
              ),
            ),
          ),
          if (zakaznikId.isNotEmpty) ...[
            const SizedBox(width: TokSpace.lg),
            SizedBox(
              width: 320,
              child: Align(
                alignment: Alignment.topCenter,
                child: _ownerCard(context, tok),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Mobile layout ──────────────────────────────────────────────────────────

  Widget _buildMobileLayout(
      BuildContext context, TorkisTokens tok, int prijmuCount, String? logo) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMobileHeader(context, prijmuCount, logo),
          Padding(
            padding: const EdgeInsets.all(TokSpace.xl),
            child: Column(
              children: [
                _techCard(context, tok),
                if (autoData['technicke_udaje'] is Map &&
                    (autoData['technicke_udaje'] as Map).isNotEmpty) ...[
                  const SizedBox(height: TokSpace.lg),
                  _vinUdajeCard(context, tok),
                ],
                if (zakaznikId.isNotEmpty) ...[
                  const SizedBox(height: TokSpace.lg),
                  _ownerCard(context, tok),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context, int prijmuCount, String? logo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          TokSpace.xl, TokSpace.xl, TokSpace.xl, TokSpace.xl),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [TokColors.ink, TokColors.inkSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          _logoBadge(logo),
          const SizedBox(height: TokSpace.lg),
          if (spz.isNotEmpty) ...[
            _buildSpzPlate(),
            const SizedBox(height: TokSpace.md),
          ],
          if (_vehicleTitle.isNotEmpty)
            Text(
              _vehicleTitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          if (_vehicleSubtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _vehicleSubtitle,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: TokSpace.xl),
          _buildStatsRow(context, prijmuCount),
          const SizedBox(height: TokSpace.lg),
          _buildStkBanner(context),
        ],
      ),
    );
  }

  // ── Levá / horní karta vozidla ───────────────────────────────────────────

  Widget _vehicleCard(BuildContext context, int prijmuCount, String? logo) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TokColors.ink, TokColors.inkSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(TokRadius.xl),
      ),
      padding: const EdgeInsets.all(TokSpace.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: TokSpace.sm),
          _logoBadge(logo),
          const SizedBox(height: TokSpace.lg),
          if (spz.isNotEmpty) ...[
            _buildSpzPlate(),
            const SizedBox(height: TokSpace.lg),
          ],
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
          _buildStatsRow(context, prijmuCount),
          const SizedBox(height: TokSpace.lg),
          _buildStkBanner(context),
        ],
      ),
    );
  }

  Widget _logoBadge(String? logo) {
    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(TokRadius.lg),
      ),
      child: logo != null
          ? Image.network(
              logo,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.directions_car_rounded,
                  size: 32,
                  color: TokColors.ink),
            )
          : const Icon(Icons.directions_car_rounded,
              size: 32, color: TokColors.ink),
    );
  }

  Widget _buildSpzPlate() {
    final flag = _flags[_zeme];
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (flag != null)
                  Text(flag, style: const TextStyle(fontSize: 9)),
                Text(_zeme,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text(
            _formatPlate(),
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

  Widget _buildStatsRow(BuildContext context, int prijmuCount) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(TokRadius.md),
      ),
      padding: const EdgeInsets.symmetric(
          vertical: TokSpace.md, horizontal: TokSpace.sm),
      child: Row(
        children: [
          _statItem(AppLocalizations.of(context).vozidloStatTacho, tacho.isNotEmpty ? '${_formatKm(tacho)} km' : '—'),
          _statDivider(),
          _statItem(AppLocalizations.of(context).vozidloStatStkDo, _stkValue),
          _statDivider(),
          _statItem(AppLocalizations.of(context).vozidloStatPrijmu, '$prijmuCount'),
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
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
        width: 1, height: 32, color: Colors.white.withValues(alpha: 0.12));
  }

  Widget _buildStkBanner(BuildContext context) {
    if (stkM.isEmpty || stkR.isEmpty) return const SizedBox.shrink();
    final remaining = _stkRemainingMonths();
    final isValid = remaining >= 0;
    final color = isValid ? const Color(0xFF22C55E) : Colors.redAccent;
    final icon = isValid ? Icons.verified_outlined : Icons.warning_amber_outlined;
    final l10n = AppLocalizations.of(context);
    final title = isValid ? l10n.vozidloStkPlatna : l10n.vozidloStkProsla;
    final subtitle = isValid
        ? l10n.vozidloStkVyprsiBehemMesicu(stkM, stkR, remaining)
        : l10n.vozidloStkVyprsela(stkM, stkR);

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

  // ── Karty ────────────────────────────────────────────────────────────────

  Widget _techCard(BuildContext context, TorkisTokens tok) {
    final l10n = AppLocalizations.of(context);
    return _sectionCard(
      tok,
      icon: Icons.directions_car_outlined,
      title: l10n.vozidloTechnickeUdaje,
      children: [
        _infoRow(tok, l10n.vozidloZnackaModel, _vehicleTitle),
        _infoRow(tok, l10n.vozidloMotorizace, autoData['motorizace']),
        _infoRow(tok, l10n.vozidloVin, autoData['vin']),
        _infoRow(tok, l10n.vozidloRokVyroby, autoData['rok_vyroby']),
        _infoRow(tok, l10n.vozidloPalivo, autoData['palivo']),
        _infoRow(tok, l10n.vozidloPrevodovka, autoData['prevodovka']),
        _infoRow(tok, l10n.vozidloBarva, autoData['barva']),
        _infoRow(tok, l10n.vozidloVykon, _vykonValue),
        _infoRow(tok, l10n.vozidloPocetMistDveri, _mistDveriValue),
        _infoRow(tok, l10n.vozidloRozmery, _rozmeryValue),
        _infoRow(tok, l10n.vozidloTachometrLabel,
            tacho.isNotEmpty ? '${_formatKm(tacho)} km' : null),
      ],
    );
  }

  String? get _vykonValue {
    final v = autoData['vykon_kw']?.toString() ?? '';
    return v.isEmpty ? null : '$v kW';
  }

  String? get _mistDveriValue {
    final mist = autoData['pocet_mist']?.toString() ?? '';
    final dveri = autoData['pocet_dveri']?.toString() ?? '';
    if (mist.isEmpty && dveri.isEmpty) return null;
    final parts = <String>[
      if (mist.isNotEmpty) '$mist míst',
      if (dveri.isNotEmpty) '$dveri dveří',
    ];
    return parts.join(' · ');
  }

  String? get _rozmeryValue {
    final d = autoData['delka_mm']?.toString() ?? '';
    final s = autoData['sirka_mm']?.toString() ?? '';
    final v = autoData['vyska_mm']?.toString() ?? '';
    if (d.isEmpty && s.isEmpty && v.isEmpty) return null;
    return '${d.isEmpty ? '?' : d} × ${s.isEmpty ? '?' : s} × ${v.isEmpty ? '?' : v} mm';
  }

  /// Read-only karta s kompletními technickými daty z VIN dekodéru.
  Widget _vinUdajeCard(BuildContext context, TorkisTokens tok) {
    final l10n = AppLocalizations.of(context);
    final raw = autoData['technicke_udaje'];
    if (raw is! Map || raw.isEmpty) return const SizedBox.shrink();
    final udaje = Map<String, dynamic>.from(raw);
    final klice = udaje.keys.toList()..sort();
    return _sectionCard(
      tok,
      icon: Icons.fact_check_outlined,
      title: l10n.vozidloUdajeZVin,
      children: [
        for (final k in klice) _infoRow(tok, k, udaje[k]),
      ],
    );
  }

  Widget _ownerCard(BuildContext context, TorkisTokens tok) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('zakaznici')
          .where('servis_id', isEqualTo: globalServisId ?? user.uid)
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

        final l10n = AppLocalizations.of(context);
        return _sectionCard(
          tok,
          icon: Icons.person_outline_rounded,
          title: l10n.vozidloMajitel,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ZakaznikDetailScreen(zakaznikData: zd)),
          ),
          children: [
            _infoRow(tok, l10n.vozidloJmeno, zd['jmeno']),
            _infoRow(tok, l10n.vozidloTelefon, telefon),
            _infoRow(tok, l10n.vozidloEmail, email),
            if (telefon.isNotEmpty || email.isNotEmpty) ...[
              const SizedBox(height: TokSpace.md),
              Row(
                children: [
                  if (telefon.isNotEmpty)
                    Expanded(
                      child: _ownerAction(
                        tok,
                        icon: Icons.phone_outlined,
                        label: l10n.vozidloVolat,
                        filled: true,
                        onTap: () => launchUrl(Uri.parse('tel:$telefon')),
                      ),
                    ),
                  if (telefon.isNotEmpty && email.isNotEmpty)
                    const SizedBox(width: TokSpace.sm),
                  if (email.isNotEmpty)
                    Expanded(
                      child: _ownerAction(
                        tok,
                        icon: Icons.mail_outline_rounded,
                        label: l10n.vozidloEmail,
                        filled: false,
                        onTap: () => launchUrl(Uri.parse('mailto:$email')),
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

  Widget _ownerAction(
    TorkisTokens tok, {
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    final primary = tok.isDark ? TokColors.accent : TokColors.ink;
    if (filled) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TokRadius.md)),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: tok.textPrimary,
        side: BorderSide(color: tok.line),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TokRadius.md)),
      ),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TokColors.accentSoft,
                  borderRadius: BorderRadius.circular(TokRadius.sm),
                ),
                child: Icon(icon, color: TokColors.accent, size: 18),
              ),
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
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: tok.textSecondary, fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(val,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: tok.textPrimary)),
          ),
        ],
      ),
    );
  }
}
