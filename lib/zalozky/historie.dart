import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import '../core/pdf_generator.dart';
import 'prubeh.dart'; // Importujeme ActiveJobScreen, abychom ho mohli znovu použít

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _searchQuery = '';

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "Neuvedeno";
    DateTime dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Center(child: Text("Nejste přihlášeni."));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HLAVIČKA
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Historie',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Archiv dokončených a stornovaných zakázek.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 15),
              // VYHLEDÁVÁNÍ
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    if (!isDark)
                      const BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                  ],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Hledat v historii (SPZ, VIN, Číslo)...',
                    prefixIcon: const Icon(Icons.history, color: Colors.blue),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),

        // SEZNAM HISTORIE
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('zakazky')
                .where('servis_id', isEqualTo: user.uid)
                .where('stav_zakazky', isEqualTo: 'Dokončeno')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Center(child: Text("Chyba: ${snapshot.error}"));
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final cislo =
                    data['cislo_zakazky']?.toString().toLowerCase() ?? '';
                final spz = data['spz']?.toString().toLowerCase() ?? '';
                final vin = data['vin']?.toString().toLowerCase() ?? '';
                final zakaznik =
                    data['zakaznik']?['jmeno']?.toString().toLowerCase() ?? '';

                return cislo.contains(_searchQuery) ||
                    spz.contains(_searchQuery) ||
                    vin.contains(_searchQuery) ||
                    zakaznik.contains(_searchQuery);
              }).toList();

              // Řazení podle času ukončení (nejnovější nahoře)
              docs.sort((a, b) {
                final dataA = a.data() as Map<String, dynamic>;
                final dataB = b.data() as Map<String, dynamic>;
                final timeA = dataA['cas_ukonceni'] as Timestamp?;
                final timeB = dataB['cas_ukonceni'] as Timestamp?;
                if (timeA == null || timeB == null) return 0;
                return timeB.compareTo(timeA);
              });

              if (docs.isEmpty) {
                return const Center(child: Text('Historie je zatím prázdná.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;
                  final casUkonceni = _formatDate(data['cas_ukonceni']);
                  final celkovaCena = data['celkova_castka'] ?? 0.0;

                  return Card(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child:
                            const Icon(Icons.check_circle, color: Colors.green),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${data['spz']}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(
                            '${celkovaCena.toStringAsFixed(0)} Kč',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text('Zakázka: ${data['cislo_zakazky']}'),
                          Text(
                              'Zákazník: ${data['zakaznik']?['jmeno'] ?? 'Neuvedeno'}'),
                          Text('Ukončeno: $casUkonceni',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Přechod na stejný detail, který se používá u aktivních zakázek
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ActiveJobScreen(
                              documentId: docId,
                              zakazkaId: data['cislo_zakazky'].toString(),
                              spz: data['spz'].toString(),
                            ),
                          ),
                        );
                      },
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
