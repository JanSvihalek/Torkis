import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../zakazka/prubeh.dart';
import '../../core/constants.dart';
import '../../core/shared_widgets.dart';

class VozidloZakazkyTab extends StatelessWidget {
  final bool isDark;
  final User user;
  final String spz;

  const VozidloZakazkyTab({
    super.key,
    required this.isDark,
    required this.user,
    required this.spz,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('zakazky')
            .where('servis_id', isEqualTo: user.uid)
            .where('spz', isEqualTo: spz)
            .snapshots(),
        builder: (context, historySnap) {
          if (historySnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!historySnap.hasData || historySnap.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Vozidlo zatím nemá žádné zakázky.',
                    style: TextStyle(color: Colors.grey)),
              ),
            );
          }

          final docs = historySnap.data!.docs.toList();
          docs.sort((a, b) {
            final dA = a.data() as Map<String, dynamic>;
            final dB = b.data() as Map<String, dynamic>;
            final tA = dA['cas_prijeti'] as Timestamp?;
            final tB = dB['cas_prijeti'] as Timestamp?;
            if (tA == null && tB == null) return 0;
            if (tA == null) return 1;
            if (tB == null) return -1;
            return tB.compareTo(tA);
          });

          return Column(
            children: docs.map((doc) {
              final zakazka = doc.data() as Map<String, dynamic>;
              final stav = zakazka['stav_zakazky'] ?? 'Přijato';
              final barvaStavu = getStatusColor(stav);

              double celkovaCena = 0.0;
              final prace =
                  zakazka['provedene_prace'] as List<dynamic>? ?? [];
              for (var p in prace) {
                final polozky = p['polozky'] as List<dynamic>?;
                if (polozky != null) {
                  for (var item in polozky) {
                    double mnoz =
                        double.tryParse(item['mnozstvi'].toString()) ?? 1.0;
                    double cena =
                        double.tryParse(item['cena_s_dph'].toString()) ?? 0.0;
                    celkovaCena += mnoz * cena;
                  }
                }
              }

              return Card(
                color: isDark ? const Color(0xFF1E3A5F) : Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
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
                      builder: (context) => ActiveJobScreen(
                        documentId: doc.id,
                        zakazkaId: zakazka['cislo_zakazky'].toString(),
                        spz: spz,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${zakazka['cislo_zakazky']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: barvaStavu.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: barvaStavu, width: 0.5),
                                  ),
                                  child: Text(
                                    stav,
                                    style: TextStyle(
                                        color: barvaStavu,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_ios,
                                    size: 14, color: Colors.grey),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          formatDateCz(zakazka['cas_prijeti'],
                              fallback: 'Neznámé datum'),
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${prace.length} úkonů',
                                style: const TextStyle(fontSize: 13)),
                            Text(
                              '${celkovaCena.toStringAsFixed(2)} Kč',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.greenAccent
                                      : Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
