import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'auth_gate.dart';
import 'prubeh_tab_otevreno.dart' show buildSearchBar;

/// Záložka s historií ukončených zakázek.
class UkonceneTab extends StatelessWidget {
  final bool isDark;
  final String searchClosed;
  final void Function(String) onSearchChanged;

  /// Callback volaný po klepnutí na kartu zakázky.
  /// Parametry: documentId, cisloZakazky, spz
  final void Function(String docId, String cisloZakazky, String spz)
      onTapZakazka;

  const UkonceneTab({
    super.key,
    required this.isDark,
    required this.searchClosed,
    required this.onSearchChanged,
    required this.onTapZakazka,
  });

  String _formatDateShort(dynamic timestamp) {
    if (timestamp == null) return "Neuvedeno";
    DateTime dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 15, 30, 10),
          child: buildSearchBar(
            isDark: isDark,
            hint: 'Hledat v historii (SPZ, VIN, číslo)...',
            icon: Icons.history,
            onChanged: onSearchChanged,
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('zakazky')
                .where('servis_id', isEqualTo: globalServisId)
                .where('stav_zakazky', isEqualTo: 'Dokončeno')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Chyba: ${snapshot.error}"));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final cislo =
                    data['cislo_zakazky']?.toString().toLowerCase() ?? '';
                final spz = data['spz']?.toString().toLowerCase() ?? '';
                final vin = data['vin']?.toString().toLowerCase() ?? '';
                final zakaznik =
                    data['zakaznik']?['jmeno']?.toString().toLowerCase() ?? '';
                return cislo.contains(searchClosed) ||
                    spz.contains(searchClosed) ||
                    vin.contains(searchClosed) ||
                    zakaznik.contains(searchClosed);
              }).toList();

              docs.sort((a, b) {
                final timeA = (a.data() as Map)['cas_ukonceni'] as Timestamp?;
                final timeB = (b.data() as Map)['cas_ukonceni'] as Timestamp?;
                if (timeA == null || timeB == null) return 0;
                return timeB.compareTo(timeA);
              });

              if (docs.isEmpty) {
                return const Center(child: Text('Historie je zatím prázdná.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;
                  final bool isMechanik = globalUserRole == 'mechanik';
                  final double celkovaCena =
                      (data['celkova_castka'] as num?)?.toDouble() ?? 0.0;
                  final znacka = data['znacka']?.toString() ?? '';
                  final model = data['model']?.toString() ?? '';
                  final vin = data['vin']?.toString() ?? '';
                  final zakaznikJmeno =
                      data['zakaznik']?['jmeno']?.toString() ?? 'Neuvedeno';

                  return Card(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withValues(alpha: 0.1),
                        child:
                            const Icon(Icons.check_circle, color: Colors.green),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${data['spz']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          if (!isMechanik && celkovaCena > 0)
                            Text(
                              '${celkovaCena.toStringAsFixed(0)} Kč',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Zakázka: ${data['cislo_zakazky']}',
                                style: const TextStyle(fontSize: 13)),
                            Text(zakaznikJmeno,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[500])),
                            if (znacka.isNotEmpty)
                              Text('$znacka $model'.trim(),
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[500])),
                            if (vin.isNotEmpty)
                              Text('VIN: $vin',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500])),
                            const SizedBox(height: 2),
                            Text(
                                'Ukončeno: ${_formatDateShort(data['cas_ukonceni'])}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => onTapZakazka(
                        docId,
                        data['cislo_zakazky'].toString(),
                        data['spz'].toString(),
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
