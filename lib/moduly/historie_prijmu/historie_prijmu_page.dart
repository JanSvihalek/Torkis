import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../auth_gate.dart';
import '../../core/constants.dart';
import '../../core/shared_widgets.dart';
import 'prijem_detail.dart';

class HistoriePrijmuPage extends StatefulWidget {
  const HistoriePrijmuPage({super.key});

  @override
  State<HistoriePrijmuPage> createState() => _HistoriePrijmuPageState();
}

class _HistoriePrijmuPageState extends State<HistoriePrijmuPage> {
  String _searchQuery = '';

  String _formatDateHeader(dynamic timestamp) {
    if (timestamp == null) return 'Zpracovává se...';
    final dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd. MM. yyyy  HH:mm').format(dt);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (globalServisId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Historie příjmů',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Přehled všech přijatých vozidel a jejich protokolů.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  onChanged: (v) =>
                      setState(() => _searchQuery = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Hledat SPZ, zákazníka nebo vozidlo...',
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                          color: isDark
                              ? Colors.grey[800]!
                              : Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                          color: isDark
                              ? Colors.grey[800]!
                              : Colors.grey[300]!),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('zakazky')
                .where('servis_id', isEqualTo: globalServisId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Chyba: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var docs = snapshot.data!.docs.where((doc) {
                if (_searchQuery.isEmpty) return true;
                final d = doc.data() as Map<String, dynamic>;
                final spz =
                    d['spz']?.toString().toLowerCase() ?? '';
                final jmeno =
                    ((d['zakaznik'] as Map?)?['jmeno'] ?? '')
                        .toString()
                        .toLowerCase();
                final znackaModel =
                    '${d['znacka'] ?? ''} ${d['model'] ?? ''}'
                        .trim()
                        .toLowerCase();
                return spz.contains(_searchQuery) ||
                    jmeno.contains(_searchQuery) ||
                    znackaModel.contains(_searchQuery);
              }).toList();

              docs.sort((a, b) {
                final tA =
                    (a.data() as Map)['cas_prijeti'] as Timestamp?;
                final tB =
                    (b.data() as Map)['cas_prijeti'] as Timestamp?;
                if (tA == null && tB == null) return 0;
                if (tA == null) return 1;
                if (tB == null) return -1;
                return tB.compareTo(tA);
              });

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    'Zatím žádné záznamy o příjmu.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;
                  final spz = data['spz']?.toString() ?? '';
                  final jmeno = (data['zakaznik'] as Map?)?['jmeno']?.toString() ?? '';
                  final znacka = data['znacka']?.toString() ?? '';
                  final model = data['model']?.toString() ?? '';
                  final stavVozidla = (data['stav_vozidla'] as Map<String, dynamic>?) ?? {};
                  final tacho = stavVozidla['tachometr']?.toString() ?? '';
                  final fotografieMap = (data['fotografie_urls'] as Map<String, dynamic>?) ?? {};
                  int pocetFotek = 0;
                  for (final urls in fotografieMap.values) {
                    pocetFotek += (urls as List<dynamic>).length;
                  }
                  final maPodpis = data['podpis_url']?.toString().isNotEmpty == true;
                  final prijal = data['prijal_jmeno']?.toString() ?? '';
                  final cisloZakazky = data['cislo_zakazky']?.toString() ?? '';
                  final stav = data['stav']?.toString() ?? 'Přijato';
                  final stavColor = getStatusColor(stav);

                  return Card(
                    elevation: 2,
                    shadowColor: Colors.black.withValues(alpha: 0.12),
                    margin: const EdgeInsets.only(bottom: 14),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrijemDetailScreen(
                            docId: docId,
                            data: data,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Tmavý header ──────────────────────────────
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF0D2137), Color(0xFF1E3A5F)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: stavColor,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      stav.toUpperCase(),
                                      style: TextStyle(
                                        color: stavColor.withValues(alpha: 0.9),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatDateHeader(data['cas_prijeti']),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Číslo zakázky',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      cisloZakazky,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (prijal.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Přijal',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.blue,
                                            ),
                                            child: Center(
                                              child: Text(
                                                _initials(prijal),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            prijal,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // ── Bílé tělo ─────────────────────────────────
                          Container(
                            color: isDark ? const Color(0xFF1A2B3C) : Colors.white,
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blue.withValues(alpha: 0.1),
                                      ),
                                      child: const Icon(Icons.directions_car,
                                          color: Colors.blue, size: 17),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        znacka.isNotEmpty
                                            ? '$znacka $model'.trim()
                                            : 'Nespecifikováno',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (spz.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 9, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(7),
                                        ),
                                        child: Text(
                                          spz,
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (jmeno.isNotEmpty) ...[
                                  Divider(
                                    height: 14,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.grey.withValues(alpha: 0.15),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.teal.withValues(alpha: 0.1),
                                        ),
                                        child: const Icon(Icons.person,
                                            color: Colors.teal, size: 17),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          jmeno,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (pocetFotek > 0 || maPodpis || tacho.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      if (pocetFotek > 0)
                                        buildBadge(Icons.photo_library,
                                            '$pocetFotek foto', Colors.blue),
                                      if (maPodpis) ...[
                                        const SizedBox(width: 6),
                                        buildBadge(Icons.draw, 'Podepsáno', Colors.green),
                                      ],
                                      if (tacho.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        buildBadge(Icons.speed, '$tacho km', Colors.teal),
                                      ],
                                      const Spacer(),
                                      const Icon(Icons.arrow_forward_ios,
                                          size: 14, color: Colors.grey),
                                    ],
                                  ),
                                ] else
                                  const Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: Icon(Icons.arrow_forward_ios,
                                          size: 14, color: Colors.grey),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
