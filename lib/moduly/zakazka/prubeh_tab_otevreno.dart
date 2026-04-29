import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../auth_gate.dart';

/// Záložka se seznamem otevřených (aktivních) zakázek.
class OtevrenTab extends StatelessWidget {
  final bool isDark;
  final String searchOpen;
  final void Function(String) onSearchChanged;

  /// Callback volaný po klepnutí na kartu zakázky.
  /// Parametry: documentId, cisloZakazky, spz
  final void Function(String docId, String cisloZakazky, String spz) onTapZakazka;

  const OtevrenTab({
    super.key,
    required this.isDark,
    required this.searchOpen,
    required this.onSearchChanged,
    required this.onTapZakazka,
  });

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "Zpracovává se...";
    DateTime dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 15, 30, 10),
          child: buildSearchBar(
            isDark: isDark,
            hint: 'Hledat SPZ, VIN nebo číslo...',
            icon: Icons.search,
            onChanged: onSearchChanged,
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
                return Center(child: Text("Chyba databáze: ${snapshot.error}"));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['stav_zakazky'] == 'Dokončeno') return false;
                final cislo =
                    data['cislo_zakazky']?.toString().toLowerCase() ?? '';
                final spz = data['spz']?.toString().toLowerCase() ?? '';
                final vin = data['vin']?.toString().toLowerCase() ?? '';
                return cislo.contains(searchOpen) ||
                    spz.contains(searchOpen) ||
                    vin.contains(searchOpen);
              }).toList();

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

              if (docs.isEmpty) {
                return const Center(
                    child: Text('Žádné aktivní zakázky k zobrazení.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;
                  final stav = data['stav_zakazky'] ?? 'Přijato';

                  final znacka = data['znacka']?.toString() ?? '';
                  final model = data['model']?.toString() ?? '';
                  final vin = data['vin']?.toString() ?? '';
                  final zakaznikJmeno =
                      data['zakaznik']?['jmeno']?.toString() ?? '';

                  return Card(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${data['spz']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: getStatusColor(stav).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(stav,
                                style: TextStyle(
                                    color: getStatusColor(stav),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
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
                            if (zakaznikJmeno.isNotEmpty)
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
                                'Příjem: ${_formatDate(data['cas_prijeti'])}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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

/// Sdílená komponenta vyhledávacího pole — používá se v obou záložkách.
Widget buildSearchBar({
  required bool isDark,
  required String hint,
  required IconData icon,
  required void Function(String) onChanged,
}) {
  return Container(
    decoration: BoxDecoration(
      boxShadow: [
        if (!isDark)
          const BoxShadow(
              color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4)),
      ],
      borderRadius: BorderRadius.circular(15),
    ),
    child: TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    ),
  );
}
