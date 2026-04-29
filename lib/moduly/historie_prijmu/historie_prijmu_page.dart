import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../auth_gate.dart';
import '../../core/shared_widgets.dart';
import 'prijem_detail.dart';

class HistoriePrijmuPage extends StatefulWidget {
  const HistoriePrijmuPage({super.key});

  @override
  State<HistoriePrijmuPage> createState() => _HistoriePrijmuPageState();
}

class _HistoriePrijmuPageState extends State<HistoriePrijmuPage> {
  String _searchQuery = '';

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Zpracovává se...';
    final dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
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
                    fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                  final data =
                      docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;
                  final spz = data['spz']?.toString() ?? '';
                  final jmeno =
                      (data['zakaznik'] as Map?)?['jmeno']?.toString() ??
                          '';
                  final znacka = data['znacka']?.toString() ?? '';
                  final model = data['model']?.toString() ?? '';
                  final vin = data['vin']?.toString() ?? '';
                  final stavVozidla =
                      (data['stav_vozidla'] as Map<String, dynamic>?) ?? {};
                  final tacho =
                      stavVozidla['tachometr']?.toString() ?? '';
                  final poskozeni =
                      (stavVozidla['poskozeni'] as List<dynamic>?) ?? [];
                  final pozadavky =
                      (data['pozadavky_zakaznika'] as List<dynamic>?) ?? [];
                  final fotografieMap =
                      (data['fotografie_urls'] as Map<String, dynamic>?) ??
                          {};
                  int pocetFotek = 0;
                  final List<String> nahledFotek = [];
                  for (final urls in fotografieMap.values) {
                    final list = urls as List<dynamic>;
                    pocetFotek += list.length;
                    if (nahledFotek.length < 4 && list.isNotEmpty) {
                      nahledFotek.add(list.first.toString());
                    }
                  }
                  final maPodpis =
                      data['podpis_url']?.toString().isNotEmpty == true;
                  final prijal =
                      data['prijal_jmeno']?.toString() ?? '';

                  return Card(
                    elevation: 0,
                    color:
                        isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                          color: isDark
                              ? Colors.grey[800]!
                              : Colors.grey[200]!),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrijemDetailScreen(
                            docId: docId,
                            data: data,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  spz.isNotEmpty
                                      ? spz
                                      : 'Zakázka ${data['cislo_zakazky']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  _formatDate(data['cas_prijeti']),
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            if (spz.isNotEmpty)
                              Text(
                                'Zakázka ${data['cislo_zakazky']}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500]),
                              ),
                            if (jmeno.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(jmeno,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600])),
                            ],
                            if (znacka.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                '$znacka $model'.trim(),
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[500]),
                              ),
                            ],
                            if (vin.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'VIN: $vin',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[500]),
                              ),
                            ],
                            if (tacho.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.speed,
                                      size: 14, color: Colors.teal),
                                  const SizedBox(width: 4),
                                  Text('$tacho km',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.teal)),
                                ],
                              ),
                            ],
                            if (pozadavky.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                pozadavky.take(2).join(', '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600]),
                              ),
                            ],
                            if (poskozeni.isNotEmpty &&
                                !(poskozeni.length == 1 &&
                                    poskozeni.first ==
                                        'Neuvedeno')) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Poškození: ${poskozeni.join(', ')}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange),
                              ),
                            ],
                            if (nahledFotek.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 60,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: nahledFotek.length,
                                  itemBuilder: (context, i) =>
                                      Padding(
                                    padding: const EdgeInsets.only(
                                        right: 6),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(6),
                                      child: Image.network(
                                        nahledFotek[i],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) =>
                                            Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                              Icons.broken_image,
                                              color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (pocetFotek > 0)
                                  buildBadge(Icons.photo_library,
                                      '$pocetFotek foto', Colors.blue),
                                if (maPodpis) ...[
                                  const SizedBox(width: 6),
                                  buildBadge(Icons.draw, 'Podepsáno',
                                      Colors.green),
                                ],
                                if (prijal.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  buildBadge(Icons.person_outline,
                                      prijal, Colors.grey),
                                ],
                                const Spacer(),
                                const Icon(Icons.arrow_forward_ios,
                                    size: 14, color: Colors.grey),
                              ],
                            ),
                          ],
                        ),
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
