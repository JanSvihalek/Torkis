import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../zakaznici/zakaznik_detail.dart';
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tmavý header s SPZ ──────────────────────────────────
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('znacka').get(),
            builder: (context, snap) {
              String logoUrl = '';
              if (snap.hasData && znackaNazev.isNotEmpty) {
                for (var doc in snap.data!.docs) {
                  final d = doc.data() as Map<String, dynamic>;
                  final dbNazev =
                      (d['nazev']?.toString() ?? doc.id).trim().toLowerCase();
                  if (dbNazev == znackaNazev.toLowerCase()) {
                    logoUrl = d['logo']?.toString() ??
                        d['logo_url']?.toString() ??
                        '';
                    break;
                  }
                }
              }
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.network(
                          logoUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // SPZ tabulka
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 14,
                            height: 24,
                            color: Colors.blue[700],
                            margin: const EdgeInsets.only(right: 12),
                          ),
                          Text(
                            spz.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              letterSpacing: 2,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (znackaNazev.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        '${autoData['znacka'] ?? ''} ${autoData['model'] ?? ''}'
                            .trim(),
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
            },
          ),

          // ── Sekce karet ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _sectionCard(
                  isDark,
                  icon: Icons.directions_car,
                  color: Colors.blue,
                  title: 'Technické údaje',
                  children: [
                    _infoRow('Značka a model',
                        '${autoData['znacka'] ?? ''} ${autoData['model'] ?? ''}'
                            .trim()),
                    _infoRow('Motorizace', autoData['motorizace']),
                    _infoRow('VIN', autoData['vin']),
                    _infoRow('Rok výroby', autoData['rok_vyroby']),
                    _infoRow('Palivo', autoData['palivo']),
                    _infoRow('Převodovka', autoData['prevodovka']),
                    _infoRow(
                      'Tachometr',
                      tacho.isNotEmpty ? '$tacho km' : null,
                    ),
                    _infoRow(
                      'Platnost STK',
                      stkM.isNotEmpty && stkR.isNotEmpty
                          ? '$stkM / $stkR'
                          : null,
                    ),
                  ],
                ),
                if (zakaznikId.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('zakaznici')
                        .where('servis_id', isEqualTo: user.uid)
                        .where('id_zakaznika', isEqualTo: zakaznikId)
                        .limit(1)
                        .get(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (!snap.hasData || snap.data!.docs.isEmpty) {
                        return const SizedBox();
                      }
                      final zd = snap.data!.docs.first.data()
                          as Map<String, dynamic>;
                      return _sectionCard(
                        isDark,
                        icon: Icons.person,
                        color: Colors.teal,
                        title: 'Majitel vozidla',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ZakaznikDetailScreen(zakaznikData: zd),
                          ),
                        ),
                        children: [
                          _infoRow('Jméno', zd['jmeno']),
                          _infoRow('Telefon', zd['telefon']),
                          _infoRow('E-mail', zd['email']),
                          _infoRow('Adresa', zd['adresa']),
                        ],
                      );
                    },
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    bool isDark, {
    required IconData icon,
    required Color color,
    required String title,
    required List<Widget> children,
    VoidCallback? onTap,
  }) {
    final filtered = children.where((w) => w is! SizedBox).toList();
    if (filtered.isEmpty) return const SizedBox();
    final container = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? TokColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: color)),
              ),
              if (onTap != null)
                Icon(Icons.arrow_forward_ios, size: 14, color: color),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
    if (onTap == null) return container;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: container,
    );
  }

  Widget _infoRow(String label, dynamic value) {
    final val = value?.toString() ?? '';
    if (val.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(val,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
