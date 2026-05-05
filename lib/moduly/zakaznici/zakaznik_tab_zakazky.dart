import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../zakazka/prubeh.dart';
import '../../core/constants.dart';
import '../../core/shared_widgets.dart';

class ZakaznikZakazkyTab extends StatelessWidget {
  final bool isDark;
  final dynamic zakaznikId;
  final dynamic servisId;

  const ZakaznikZakazkyTab({
    super.key,
    required this.isDark,
    required this.zakaznikId,
    required this.servisId,
  });

  @override
  Widget build(BuildContext context) {
    if (!maPristupModul('zakazky')) {
      return buildZamcenyModul(context, nazevModulu: 'Zakázky');
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('zakazky')
          .where('servis_id', isEqualTo: servisId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allDocs = snapshot.data?.docs ?? [];
        final docs = allDocs.where((doc) {
          final zData = doc.data() as Map<String, dynamic>;
          final zId1 = zData['zakaznik_id']?.toString() ?? '';
          final zId2 = (zData['zakaznik']
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
                'Zákazník zatím nemá žádné servisní záznamy.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        docs.sort((a, b) {
          final timeA =
              (a.data() as Map)['cas_prijeti'] as Timestamp?;
          final timeB =
              (b.data() as Map)['cas_prijeti'] as Timestamp?;
          if (timeA == null && timeB == null) return 0;
          if (timeA == null) return 1;
          if (timeB == null) return -1;
          return timeB.compareTo(timeA);
        });

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;
            final stav = data['stav_zakazky'] ?? 'Přijato';
            final jeDokonceno = stav == 'Dokončeno';
            final znacka = data['znacka']?.toString() ?? '';
            final model = data['model']?.toString() ?? '';
            final vin = data['vin']?.toString() ?? '';
            final celkovaCena =
                (data['celkova_castka'] as num?)?.toDouble() ?? 0.0;

            return Card(
              elevation: 0,
              color: isDark ? const Color(0xFF1E3A5F) : Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                    color: isDark
                        ? Colors.grey[800]!
                        : Colors.grey[200]!),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(15),
                leading: CircleAvatar(
                  backgroundColor: jeDokonceno
                      ? Colors.green.withValues(alpha: 0.1)
                      : getStatusColor(stav).withValues(alpha: 0.1),
                  child: Icon(
                    jeDokonceno ? Icons.check_circle : Icons.build,
                    color: jeDokonceno
                        ? Colors.green
                        : getStatusColor(stav),
                    size: 20,
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['spz']?.toString() ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    if (jeDokonceno && celkovaCena > 0)
                      Text(
                        '${celkovaCena.toStringAsFixed(0)} Kč',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      )
                    else if (!jeDokonceno)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: getStatusColor(stav)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          stav,
                          style: TextStyle(
                              color: getStatusColor(stav),
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Zakázka: ${data['cislo_zakazky']}',
                          style: const TextStyle(fontSize: 13)),
                      if (znacka.isNotEmpty)
                        Text('$znacka $model'.trim(),
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500])),
                      if (vin.isNotEmpty)
                        Text('VIN: $vin',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500])),
                      const SizedBox(height: 2),
                      Text(
                        jeDokonceno
                            ? 'Ukončeno: ${formatDateTimeCz(data['cas_ukonceni'])}'
                            : 'Příjem: ${formatDateTimeCz(data['cas_prijeti'])}',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActiveJobScreen(
                      documentId: docId,
                      zakazkaId: data['cislo_zakazky'].toString(),
                      spz: data['spz']?.toString() ?? '',
                    ),
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
