import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../historie_prijmu/prijem_detail.dart';
import '../../core/shared_widgets.dart';

class ZakaznikPrijemTab extends StatelessWidget {
  final bool isDark;
  final dynamic zakaznikId;
  final dynamic servisId;

  const ZakaznikPrijemTab({
    super.key,
    required this.isDark,
    required this.zakaznikId,
    required this.servisId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('zakazky')
          .where('servis_id', isEqualTo: servisId)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allDocs = snap.data?.docs ?? [];
        final docs = allDocs.where((doc) {
          final d = doc.data() as Map<String, dynamic>;
          final zId1 = d['zakaznik_id']?.toString() ?? '';
          final zId2 = (d['zakaznik']
                      as Map<String, dynamic>?)?['id_zakaznika']
                  ?.toString() ??
              '';
          return zId1 == zakaznikId || zId2 == zakaznikId;
        }).toList();

        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                  'Zákazník zatím nemá žádné záznamy o příjmu.',
                  style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        docs.sort((a, b) {
          final tA = (a.data() as Map)['cas_prijeti'] as Timestamp?;
          final tB = (b.data() as Map)['cas_prijeti'] as Timestamp?;
          if (tA == null && tB == null) return 0;
          if (tA == null) return 1;
          if (tB == null) return -1;
          return tB.compareTo(tA);
        });

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;
            final spz = data['spz']?.toString() ?? '';
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
            final prijal = data['prijal_jmeno']?.toString() ?? '';

            return Card(
              elevation: 0,
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                    builder: (context) =>
                        PrijemDetailScreen(docId: docId, data: data),
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
                            formatDateTimeCz(data['cas_prijeti']),
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
                                color: Colors.grey[500])),
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
                              fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                      if (poskozeni.isNotEmpty &&
                          !(poskozeni.length == 1 &&
                              poskozeni.first == 'Neuvedeno')) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Poškození: ${poskozeni.join(', ')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.orange),
                        ),
                      ],
                      if (nahledFotek.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: nahledFotek.length,
                            itemBuilder: (context, i) => Padding(
                              padding:
                                  const EdgeInsets.only(right: 6),
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
                            buildBadge(Icons.person_outline, prijal,
                                Colors.grey),
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
    );
  }
}
