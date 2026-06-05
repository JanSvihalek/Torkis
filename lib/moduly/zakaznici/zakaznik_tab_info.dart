import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../vozidla/vozidlo_detail.dart';
import '../prijem/prijem_vozidla.dart';
import '../prijem/prijem_vozidla_tablet_layout.dart' show kTabletBreakpoint;
import '../../core/design_tokens.dart';
import '../../l10n/app_localizations.dart';

class ZakaznikInfoTab extends StatelessWidget {
  final bool isDark;
  final Map<String, dynamic> dataZakaznika;
  final dynamic zakaznikId;
  final dynamic servisId;

  const ZakaznikInfoTab({
    super.key,
    required this.isDark,
    required this.dataZakaznika,
    required this.zakaznikId,
    required this.servisId,
  });

  // ── Helpers (data) ──────────────────────────────────────────────────────

  String get _jmeno => dataZakaznika['jmeno']?.toString().trim() ?? '';
  String get _ico => dataZakaznika['ico']?.toString() ?? '';
  String get _dic => dataZakaznika['dic']?.toString() ?? '';
  String get _telefon => dataZakaznika['telefon']?.toString() ?? '';
  String get _email => dataZakaznika['email']?.toString() ?? '';
  String get _adresa => dataZakaznika['adresa']?.toString() ?? '';
  bool get _jeFirma => _ico.isNotEmpty;

  String _initials(String jmeno) {
    final slova =
        jmeno.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (slova.isEmpty) return '?';
    if (slova.length == 1) return slova.first.characters.first.toUpperCase();
    return (slova.first.characters.first + slova[1].characters.first)
        .toUpperCase();
  }

  Future<({int vozidla, int prijmy})> _fetchCounts() async {
    int v = 0, p = 0;
    try {
      final vs = await FirebaseFirestore.instance
          .collection('vozidla')
          .where('servis_id', isEqualTo: servisId)
          .where('zakaznik_id', isEqualTo: zakaznikId)
          .count()
          .get();
      v = vs.count ?? 0;
    } catch (_) {}
    try {
      final ps = await FirebaseFirestore.instance
          .collection('zakazky')
          .where('servis_id', isEqualTo: servisId)
          .where('zakaznik_id', isEqualTo: zakaznikId)
          .count()
          .get();
      p = ps.count ?? 0;
    } catch (_) {}
    return (vozidla: v, prijmy: p);
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    return FutureBuilder<({int vozidla, int prijmy})>(
      future: _fetchCounts(),
      builder: (context, snap) {
        final counts = snap.data ?? (vozidla: 0, prijmy: 0);
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= kTabletBreakpoint &&
                MediaQuery.orientationOf(context) == Orientation.landscape) {
              return _buildTabletLayout(context, tok, counts);
            }
            return _buildMobileLayout(context, tok, counts);
          },
        );
      },
    );
  }

  // ── Tablet layout ────────────────────────────────────────────────────────

  Widget _buildTabletLayout(BuildContext context, TorkisTokens tok,
      ({int vozidla, int prijmy}) counts) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(TokSpace.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 320, child: _identityCard(counts, rounded: true, l10n: l10n)),
          const SizedBox(width: TokSpace.lg),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: _contactCard(context, tok),
            ),
          ),
          const SizedBox(width: TokSpace.lg),
          SizedBox(
            width: 320,
            child: Align(
              alignment: Alignment.topCenter,
              child: _vozidlaCard(context, tok),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile layout ──────────────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context, TorkisTokens tok,
      ({int vozidla, int prijmy}) counts) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _identityCard(counts, rounded: false, l10n: l10n),
          Padding(
            padding: const EdgeInsets.all(TokSpace.xl),
            child: Column(
              children: [
                _contactCard(context, tok),
                const SizedBox(height: TokSpace.lg),
                _vozidlaCard(context, tok),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Identity karta (tmavý gradient) ───────────────────────────────────────

  Widget _identityCard(({int vozidla, int prijmy}) counts,
      {required bool rounded, required AppLocalizations l10n}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TokColors.ink, TokColors.inkSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: rounded ? BorderRadius.circular(TokRadius.xl) : null,
      ),
      padding: const EdgeInsets.all(TokSpace.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: TokSpace.sm),
          Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: TokColors.accent,
              shape: BoxShape.circle,
            ),
            child: Text(
              _initials(_jmeno),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: TokSpace.lg),
          Text(
            _jmeno.isEmpty ? l10n.zakNeznamyZakaznik : _jmeno,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TokSpace.sm),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: TokSpace.md, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(TokRadius.round),
            ),
            child: Text(
              _jeFirma ? l10n.zakFirma : l10n.zakSoukromaOsoba,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: TokSpace.xl),
          _statsRow(counts, l10n),
        ],
      ),
    );
  }

  Widget _statsRow(({int vozidla, int prijmy}) counts, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(TokRadius.md),
      ),
      padding: const EdgeInsets.symmetric(
          vertical: TokSpace.md, horizontal: TokSpace.sm),
      child: Row(
        children: [
          _statItem(l10n.zakStatVozidel, '${counts.vozidla}'),
          _statDivider(),
          _statItem(l10n.zakStatPrijmu, '${counts.prijmy}'),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: Colors.white.withValues(alpha: 0.45)),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
        width: 1, height: 32, color: Colors.white.withValues(alpha: 0.12));
  }

  // ── Kontaktní karta ────────────────────────────────────────────────────

  Widget _contactCard(BuildContext context, TorkisTokens tok) {
    final l10n = AppLocalizations.of(context);
    final tel = _telefon.replaceAll(' ', '');
    final actions = <Widget>[
      if (_telefon.isNotEmpty)
        _actionBtn(tok,
            icon: Icons.phone_outlined,
            label: l10n.zakVolat,
            filled: true,
            onTap: () => launchUrl(Uri.parse('tel:$tel'))),
      if (_telefon.isNotEmpty)
        _actionBtn(tok,
            icon: Icons.sms_outlined,
            label: l10n.zakSms,
            filled: false,
            onTap: () => launchUrl(Uri.parse('sms:$tel'))),
      if (_email.isNotEmpty)
        _actionBtn(tok,
            icon: Icons.mail_outline_rounded,
            label: l10n.zakEmailLabel,
            filled: false,
            onTap: () => launchUrl(Uri.parse('mailto:$_email'))),
    ];

    return _sectionCard(
      tok,
      icon: Icons.person_outline_rounded,
      title: l10n.zakKontaktniUdaje,
      children: [
        _infoRow(tok, l10n.zakIcoLabel, _ico),
        _infoRow(tok, l10n.zakDicLabel, _dic),
        _infoRow(tok, l10n.zakTelLabel, _telefon),
        _infoRow(tok, l10n.zakEmailLabel, _email),
        _infoRow(tok, l10n.zakAdresaLabel, _adresa),
        if (actions.isNotEmpty) ...[
          const SizedBox(height: TokSpace.md),
          Row(
            children: [
              for (int i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: TokSpace.sm),
                Expanded(child: actions[i]),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _actionBtn(
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

  // ── Karta vozidel zákazníka ──────────────────────────────────────────────

  Widget _vozidlaCard(BuildContext context, TorkisTokens tok) {
    final l10n = AppLocalizations.of(context);
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vozidla')
          .where('servis_id', isEqualTo: servisId)
          .where('zakaznik_id', isEqualTo: zakaznikId)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final waiting = snapshot.connectionState == ConnectionState.waiting;
        return _sectionCard(
          tok,
          icon: Icons.directions_car_outlined,
          title: l10n.zakVozidlaTitle,
          count: docs.isNotEmpty ? docs.length : null,
          trailing: TextButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MainWizardPage())),
            style: TextButton.styleFrom(
              foregroundColor: tok.accent,
              padding: const EdgeInsets.symmetric(horizontal: TokSpace.sm),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.zakPridat),
          ),
          children: [
            if (waiting)
              const Padding(
                padding: EdgeInsets.all(TokSpace.md),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (docs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: TokSpace.sm),
                child: Text(l10n.zakZadnaVozidla,
                    style:
                        TextStyle(color: tok.textSecondary, fontSize: 13)),
              )
            else
              for (int i = 0; i < docs.length; i++)
                _vozidloRow(context, tok, docs[i], isLast: i == docs.length - 1),
          ],
        );
      },
    );
  }

  Widget _vozidloRow(
      BuildContext context, TorkisTokens tok, QueryDocumentSnapshot doc,
      {required bool isLast}) {
    final l10n = AppLocalizations.of(context);
    final vozidlo = doc.data() as Map<String, dynamic>;
    final spz = vozidlo['spz']?.toString() ?? '';
    final znacka = vozidlo['znacka']?.toString() ?? '';
    final model = vozidlo['model']?.toString() ?? '';
    final motorizace = vozidlo['motorizace']?.toString() ?? '';
    final popis = [
      '$znacka $model'.trim(),
      if (motorizace.isNotEmpty) motorizace,
    ].where((s) => s.isNotEmpty).join(' · ');

    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(TokRadius.md),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => VozidloDetailScreen(vozidloDocId: doc.id)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: TokSpace.sm),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tok.accentSoft,
                    borderRadius: BorderRadius.circular(TokRadius.md),
                  ),
                  child: Icon(Icons.directions_car_outlined,
                      size: 20, color: tok.accent),
                ),
                const SizedBox(width: TokSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(spz.isEmpty ? l10n.zakBezSpz : spz,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: tok.textPrimary)),
                      if (popis.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(popis,
                            style: TextStyle(
                                fontSize: 13, color: tok.textSecondary)),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: tok.textSecondary),
              ],
            ),
          ),
        ),
        if (!isLast) Divider(height: 1, color: tok.line),
      ],
    );
  }

  // ── Sdílené ───────────────────────────────────────────────────────────────

  Widget _sectionCard(
    TorkisTokens tok, {
    required IconData icon,
    required String title,
    required List<Widget> children,
    int? count,
    Widget? trailing,
  }) {
    return Container(
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
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: tok.textPrimary)),
              if (count != null) ...[
                const SizedBox(width: TokSpace.sm),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: tok.accentSoft,
                    borderRadius: BorderRadius.circular(TokRadius.round),
                  ),
                  child: Text('$count',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: tok.accent)),
                ),
              ],
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          Divider(height: TokSpace.xl, color: tok.line),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(TorkisTokens tok, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: tok.textSecondary, fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
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
