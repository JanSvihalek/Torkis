import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../fakturace/faktura_detail.dart';
import '../../core/constants.dart';
import '../../core/shared_widgets.dart';

class VozidloFakturyTab extends StatelessWidget {
  final bool isDark;
  final User user;
  final String spz;

  const VozidloFakturyTab({
    super.key,
    required this.isDark,
    required this.user,
    required this.spz,
  });

  @override
  Widget build(BuildContext context) {
    if (!maPristupModul('fakturace')) {
      return buildZamcenyModul(context, nazevModulu: 'Fakturace');
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('faktury')
            .where('servis_id', isEqualTo: user.uid)
            .where('spz', isEqualTo: spz)
            .snapshots(),
        builder: (context, invoiceSnap) {
          if (invoiceSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!invoiceSnap.hasData || invoiceSnap.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('K tomuto vozidlu neevidujeme žádné faktury.',
                    style: TextStyle(color: Colors.grey)),
              ),
            );
          }

          final fakturyDocs = invoiceSnap.data!.docs.toList();
          fakturyDocs.sort((a, b) {
            final dA = a.data() as Map<String, dynamic>;
            final dB = b.data() as Map<String, dynamic>;
            final tA = dA['datum_vystaveni'] as Timestamp?;
            final tB = dB['datum_vystaveni'] as Timestamp?;
            if (tA == null && tB == null) return 0;
            if (tA == null) return 1;
            if (tB == null) return -1;
            return tB.compareTo(tA);
          });

          return Column(
            children: fakturyDocs.map((fDoc) {
              final faktura = fDoc.data() as Map<String, dynamic>;
              final stavPlatby =
                  faktura['stav_platby'] ?? 'Čeká na platbu';
              final isStorno = stavPlatby == 'Stornováno';

              final Color platbaColor;
              if (stavPlatby == 'Uhrazeno') {
                platbaColor = Colors.green;
              } else if (stavPlatby == 'Stornováno') {
                platbaColor = Colors.red;
              } else {
                platbaColor = Colors.orange;
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
                      builder: (context) => FakturaDetailScreen(
                        fakturaDocId: fDoc.id,
                        zakazkaId:
                            faktura['cislo_zakazky']?.toString() ?? '',
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
                              '${faktura['cislo_faktury']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: isStorno
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        platbaColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: platbaColor, width: 0.5),
                                  ),
                                  child: Text(
                                    stavPlatby,
                                    style: TextStyle(
                                        color: platbaColor,
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
                          formatDateCz(faktura['datum_vystaveni']),
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${(faktura['celkova_castka'] ?? 0.0).toStringAsFixed(2)} Kč',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isStorno
                                    ? Colors.grey
                                    : (isDark
                                        ? Colors.greenAccent
                                        : Colors.green),
                                decoration: isStorno
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
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
