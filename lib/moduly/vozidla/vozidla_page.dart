import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vozidlo_detail.dart';

class VozidlaPage extends StatefulWidget {
  const VozidlaPage({super.key});

  @override
  State<VozidlaPage> createState() => _VozidlaPageState();
}

class _VozidlaPageState extends State<VozidlaPage> {
  String _searchQuery = '';
  Map<String, String> _logaZnacek = {};

  @override
  void initState() {
    super.initState();
    _nactiLogaZnacek();
  }

  Future<void> _nactiLogaZnacek() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('znacka').get();
      final map = <String, String>{};
      for (var doc in snap.docs) {
        final data = doc.data();
        final nazev =
            (data['nazev']?.toString() ?? doc.id).trim().toLowerCase();
        final logoUrl =
            data['logo']?.toString() ?? data['logo_url']?.toString() ?? '';
        if (nazev.isNotEmpty && logoUrl.isNotEmpty) {
          map[nazev] = logoUrl;
        }
      }
      if (mounted) {
        setState(() {
          _logaZnacek = map;
        });
      }
    } catch (e) {
      debugPrint('Chyba při načítání log značek: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Center(child: Text("Nejste přihlášeni."));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Databáze vozidel',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Přehled všech servisovaných aut.',
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
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Hledat SPZ, Značku nebo VIN...',
                    prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    filled: true,
                    fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Colors.teal,
                        width: 2,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
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
                .collection('vozidla')
                .where('servis_id', isEqualTo: user.uid)
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
                final spz = data['spz']?.toString().toLowerCase() ?? '';
                final znacka = data['znacka']?.toString().toLowerCase() ?? '';
                final vin = data['vin']?.toString().toLowerCase() ?? '';
                return spz.contains(_searchQuery) ||
                    znacka.contains(_searchQuery) ||
                    vin.contains(_searchQuery);
              }).toList();

              docs.sort((a, b) {
                final dataA = a.data() as Map<String, dynamic>;
                final dataB = b.data() as Map<String, dynamic>;
                final spzA = dataA['spz']?.toString() ?? '';
                final spzB = dataB['spz']?.toString() ?? '';
                return spzA.compareTo(spzB);
              });

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    'Zatím nemáte v databázi žádná vozidla.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;

                  final znackaNazev =
                      (data['znacka']?.toString() ?? '').trim().toLowerCase();
                  final logoUrl = _logaZnacek[znackaNazev];

                  final tacho = data['tachometr']?.toString() ?? '';
                  final stkM = data['stk_mesic']?.toString() ?? '';
                  final stkR = data['stk_rok']?.toString() ?? '';
                  final maStk = stkM.isNotEmpty && stkR.isNotEmpty;

                  return Card(
                    color: isDark ? const Color(0xFF1E3A5F) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      leading: Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.teal.withValues(alpha: 0.3),
                          ),
                        ),
                        child: logoUrl != null && logoUrl.isNotEmpty
                            ? Image.network(
                                logoUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.directions_car,
                                  color: Colors.teal,
                                ),
                              )
                            : const Icon(
                                Icons.directions_car,
                                color: Colors.teal,
                              ),
                      ),
                      title: Text(
                        '${data['spz']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data['znacka'] ?? ''} ${data['model'] ?? ''} ${data['motorizace'] != null && data['motorizace'].toString().isNotEmpty ? '(${data['motorizace']})' : ''}',
                            ),
                            if (data['vin'] != null &&
                                data['vin'].toString().isNotEmpty)
                              Text(
                                'VIN: ${data['vin']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            const SizedBox(height: 4),
                            if (tacho.isNotEmpty || maStk)
                              Text(
                                '${tacho.isNotEmpty ? 'Tachometr: $tacho km' : ''}${tacho.isNotEmpty && maStk ? ' • ' : ''}${maStk ? 'STK: $stkM/$stkR' : ''}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.teal,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VozidloDetailScreen(vozidloDocId: docId),
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
