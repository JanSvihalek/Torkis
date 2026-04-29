import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../fakturace/faktura_detail.dart';
import '../../core/shared_widgets.dart';

class ZakaznikFakturyTab extends StatelessWidget {
  final bool isDark;
  final dynamic zakaznikId;
  final dynamic servisId;

  const ZakaznikFakturyTab({
    super.key,
    required this.isDark,
    required this.zakaznikId,
    required this.servisId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('faktury')
          .where('servis_id', isEqualTo: servisId)
          .snapshots(),
      builder: (context, invoiceSnap) {
        if (invoiceSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allDocs = invoiceSnap.data?.docs ?? [];
        final fakturyDocs = allDocs.where((doc) {
          final fData = doc.data() as Map<String, dynamic>;
          final fId1 = fData['zakaznik_id']?.toString() ?? '';
          final fId2 = (fData['zakaznik']
                      as Map<String, dynamic>?)?['id_zakaznika']
                  ?.toString() ??
              '';
          return fId1 == zakaznikId || fId2 == zakaznikId;
        }).toList();

        if (fakturyDocs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                'K tomuto zákazníkovi neevidujeme žádné faktury.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        fakturyDocs.sort((a, b) {
          final tA =
              (a.data() as Map)['datum_vystaveni'] as Timestamp?;
          final tB =
              (b.data() as Map)['datum_vystaveni'] as Timestamp?;
          if (tA == null && tB == null) return 0;
          if (tA == null) return 1;
          if (tB == null) return -1;
          return tB.compareTo(tA);
        });

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          itemCount: fakturyDocs.length,
          itemBuilder: (context, index) {
            final fDoc = fakturyDocs[index];
            final faktura = fDoc.data() as Map<String, dynamic>;
            final docId = fDoc.id;

            final stavPlatby =
                faktura['stav_platby'] ?? 'Čeká na platbu';
            final jeUhrazeno = stavPlatby == 'Uhrazeno';
            final jeStornovano = stavPlatby == 'Stornováno';

            Color barvaStavu = Colors.redAccent;
            if (jeUhrazeno) barvaStavu = Colors.green;
            if (jeStornovano) barvaStavu = Colors.grey;

            return Card(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.only(bottom: 15),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FakturaDetailScreen(
                      fakturaDocId: docId,
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
                              fontSize: 18,
                              decoration: jeStornovano
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: jeStornovano ? Colors.grey : null,
                            ),
                          ),
                          Text(
                            '${(faktura['celkova_castka'] ?? 0.0).toStringAsFixed(2)} Kč',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: jeStornovano
                                  ? Colors.grey
                                  : (isDark
                                      ? Colors.white
                                      : Colors.blue[900]!),
                              fontSize: 18,
                              decoration: jeStornovano
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Zákazník: ${faktura['zakaznik_jmeno'] ?? ''}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                if (faktura['spz'] != null &&
                                    faktura['spz']
                                        .toString()
                                        .isNotEmpty)
                                  Text(
                                    'Vozidlo (SPZ): ${faktura['spz']}',
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Vystaveno: ${formatDateCz(faktura['datum_vystaveni'])}',
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Splatnost: ${formatDateCz(faktura['datum_splatnosti'])}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: jeUhrazeno || jeStornovano
                                        ? Colors.grey
                                        : Colors.red,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2C2C2C)
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              stavPlatby,
                              style: TextStyle(
                                color: barvaStavu,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (!jeUhrazeno && !jeStornovano)
                            TextButton.icon(
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.green, size: 18),
                              label: const Text('ZAPLACENO',
                                  style:
                                      TextStyle(color: Colors.green)),
                              onPressed: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('faktury')
                                      .doc(docId)
                                      .update(
                                          {'stav_platby': 'Uhrazeno'});
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Faktura byla označena jako uhrazená.'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text('Chyba: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.grey),
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
