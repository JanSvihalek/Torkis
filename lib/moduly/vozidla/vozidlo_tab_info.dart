import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('znacka').get(),
      builder: (context, snap) {
        String logoUrl = '';
        if (snap.hasData && znackaNazev.isNotEmpty) {
          for (var doc in snap.data!.docs) {
            final d = doc.data() as Map<String, dynamic>;
            final dbNazev =
                (d['nazev']?.toString() ?? doc.id).trim().toLowerCase();
            if (dbNazev == znackaNazev.toLowerCase()) {
              logoUrl =
                  d['logo']?.toString() ?? d['logo_url']?.toString() ?? '';
              break;
            }
          }
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= kTabletBreakpoint) {
              return _buildTabletLayout(context, tok, logoUrl);
            }
            return _buildMobileLayout(context, tok, logoUrl);
          },
        );
      },
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, TorkisTokens tok, String logoUrl) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _darkVehicleHeader(logoUrl),
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

  Widget _buildTabletLayout(
      BuildContext context, TorkisTokens tok, String logoUrl) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Levý panel: vozidlová karta ─────────────────────────
        Container(
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
              children: [
                const SizedBox(height: TokSpace.xl),
                if (logoUrl.isNotEmpty) ...[
                  Container(
                    height: 64,
                    constraints: const BoxConstraints(maxWidth: 140),
                    padding: const EdgeInsets.all(TokSpace.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(TokRadius.md),
                    ),
                    child: Image.network(
                      logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                  const SizedBox(height: TokSpace.xl),
                ],
                // SPZ tabulka
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(TokRadius.md),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 28,
                        color: TokColors.accent2,
                        margin: const EdgeInsets.only(right: 12),
                      ),
                      Text(
                        spz.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          letterSpacing: 2,
                          color: TokColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
                if (znackaNazev.isNotEmpty) ...[
                  const SizedBox(height: TokSpace.lg),
                  Text(
                    '${autoData['znacka'] ?? ''} ${autoData['model'] ?? ''}'
                        .trim(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if ((autoData['rok_vyroby']?.toString() ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      autoData['rok_vyroby'].toString(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: TokSpace.xxl),
                // Rychlé info
                _darkInfoRow(Icons.local_gas_station_outlined, 'Palivo', palivo),
                _darkInfoRow(Icons.settings_outlined, 'Převodovka', prevodovka),
                if (tacho.isNotEmpty)
                  _darkInfoRow(Icons.speed_outlined, 'Tachometr', '$tacho km'),
                if (stkM.isNotEmpty && stkR.isNotEmpty)
                  _darkInfoRow(
                      Icons.verified_outlined, 'STK', '$stkM / $stkR'),
              ],
            ),
          ),
        ),
        // ── Pravý panel: technické údaje + majitel ──────────────
        Expanded(
          child: SingleChildScrollView(
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
        ),
      ],
    );
  }

  Widget _darkVehicleHeader(String logoUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
          TokSpace.xl, TokSpace.xxl, TokSpace.xl, TokSpace.xxl),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [TokColors.ink, TokColors.inkSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          if (logoUrl.isNotEmpty) ...[
            Container(
              height: 56,
              constraints: const BoxConstraints(maxWidth: 120),
              padding: const EdgeInsets.all(TokSpace.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(TokRadius.md),
              ),
              child: Image.network(logoUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox()),
            ),
            const SizedBox(height: TokSpace.lg),
          ],
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(TokRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 24,
                  color: TokColors.accent2,
                  margin: const EdgeInsets.only(right: 12),
                ),
                Text(
                  spz.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    letterSpacing: 2,
                    color: TokColors.ink,
                  ),
                ),
              ],
            ),
          ),
          if (znackaNazev.isNotEmpty) ...[
            const SizedBox(height: TokSpace.md),
            Text(
              '${autoData['znacka'] ?? ''} ${autoData['model'] ?? ''}'.trim(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _darkInfoRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: TokSpace.md),
      child: Row(
        children: [
          Icon(icon, size: 16, color: TokColors.steelSoft),
          const SizedBox(width: TokSpace.sm),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: TokColors.steelSoft)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
      ),
    );
  }

  Widget _techCard(TorkisTokens tok) {
    return _sectionCard(
      tok,
      icon: Icons.directions_car,
      title: 'Technické údaje',
      children: [
        _infoRow(tok, 'Značka a model',
            '${autoData['znacka'] ?? ''} ${autoData['model'] ?? ''}'.trim()),
        _infoRow(tok, 'Motorizace', autoData['motorizace']),
        _infoRow(tok, 'VIN', autoData['vin']),
        _infoRow(tok, 'Rok výroby', autoData['rok_vyroby']),
        _infoRow(tok, 'Palivo', autoData['palivo']),
        _infoRow(tok, 'Převodovka', autoData['prevodovka']),
        _infoRow(tok, 'Tachometr', tacho.isNotEmpty ? '$tacho km' : null),
        _infoRow(tok, 'Platnost STK',
            stkM.isNotEmpty && stkR.isNotEmpty ? '$stkM / $stkR' : null),
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
        if (!snap.hasData || snap.data!.docs.isEmpty) return const SizedBox();
        final zd = snap.data!.docs.first.data() as Map<String, dynamic>;
        return _sectionCard(
          tok,
          icon: Icons.person,
          title: 'Majitel vozidla',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ZakaznikDetailScreen(zakaznikData: zd)),
          ),
          children: [
            _infoRow(tok, 'Jméno', zd['jmeno']),
            _infoRow(tok, 'Telefon', zd['telefon']),
            _infoRow(tok, 'E-mail', zd['email']),
            _infoRow(tok, 'Adresa', zd['adresa']),
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
    final filtered = children.where((w) => w is! SizedBox).toList();
    if (filtered.isEmpty) return const SizedBox();
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
            width: 140,
            child: Text(label,
                style: TextStyle(color: tok.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(val,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: tok.textPrimary)),
          ),
        ],
      ),
    );
  }
}
