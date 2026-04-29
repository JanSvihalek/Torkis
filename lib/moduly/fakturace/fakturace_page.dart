import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth_gate.dart';
import 'faktura_detail.dart';
import 'faktura_manual.dart';

class FakturacePage extends StatefulWidget {
  const FakturacePage({super.key});

  @override
  State<FakturacePage> createState() => _FakturacePageState();
}

class _FakturacePageState extends State<FakturacePage> {
  String _searchQuery = '';

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "-";
    DateTime dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy').format(dt);
  }

  Future<void> _oznacitJakoUhrazene(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('faktury')
          .doc(docId)
          .update({'stav_platby': 'Uhrazeno'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faktura byla označena jako uhrazená.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba při aktualizaci: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (globalServisId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ManualInvoiceScreen()),
        ),
        label: const Text('NOVÁ FAKTURA'),
        icon: const Icon(Icons.add_shopping_cart),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fakturace',
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text(
                  'Přehled vystavených faktur a úprava položek.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _searchQuery = value.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Hledat číslo faktury, SPZ nebo jméno...',
                      prefixIcon: const Icon(Icons.search, color: Colors.blue),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('faktury')
                  .where('servis_id', isEqualTo: globalServisId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Chyba databáze: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final cislo =
                      data['cislo_faktury']?.toString().toLowerCase() ?? '';
                  final spz = data['spz']?.toString().toLowerCase() ?? '';
                  final zakaznik =
                      data['zakaznik_jmeno']?.toString().toLowerCase() ?? '';
                  return cislo.contains(_searchQuery) ||
                      spz.contains(_searchQuery) ||
                      zakaznik.contains(_searchQuery);
                }).toList();

                docs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  final timeA = dataA['datum_vystaveni'] as Timestamp?;
                  final timeB = dataB['datum_vystaveni'] as Timestamp?;
                  if (timeA == null && timeB == null) return 0;
                  if (timeA == null) return 1;
                  if (timeB == null) return -1;
                  return timeB.compareTo(timeA);
                });

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined,
                            size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Zatím nebyly vystaveny žádné faktury.'
                              : 'Nic nenalezeno.',
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;

                    final stavPlatby = data['stav_platby'] ?? 'Neuhrazeno';
                    final jeUhrazeno = stavPlatby == 'Uhrazeno';
                    final jeStornovano = stavPlatby == 'Stornováno';

                    Color barvaStavu = Colors.orange;
                    if (jeUhrazeno) barvaStavu = Colors.green;
                    if (jeStornovano) barvaStavu = Colors.redAccent;

                    return Card(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.only(bottom: 15),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FakturaDetailScreen(
                              fakturaDocId: docId,
                              zakazkaId: data['cislo_zakazky'].toString(),
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
                                    '${data['cislo_faktury']}',
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
                                    '${(data['celkova_castka'] ?? 0.0).toStringAsFixed(2)} Kč',
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
                                          'Zákazník: ${data['zakaznik_jmeno']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        if (data['spz'] != null &&
                                            data['spz'].toString().isNotEmpty)
                                          Text(
                                            'Vozidlo (SPZ): ${data['spz']}',
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
                                          'Vystaveno: ${_formatDate(data['datum_vystaveni'])}',
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 13),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Splatnost: ${_formatDate(data['datum_splatnosti'])}',
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
                                      onPressed: () =>
                                          _oznacitJakoUhrazene(docId),
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
            ),
          ),
        ],
      ),
    );
  }
}
