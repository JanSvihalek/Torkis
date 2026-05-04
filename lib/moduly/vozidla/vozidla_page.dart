import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'vozidlo_detail.dart';

class VozidlaPage extends StatefulWidget {
  const VozidlaPage({super.key});

  @override
  State<VozidlaPage> createState() => _VozidlaPageState();
}

class _VozidlaPageState extends State<VozidlaPage> {
  String _searchQuery = '';
  Map<String, String> _logaZnacek = {};
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nactiLogaZnacek();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _scanSpz() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Skenování funguje pouze v nainstalované aplikaci (APK/iOS).'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4)));
      return;
    }
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return;
      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      final spz = recognizedText.text
          .replaceAll(RegExp(r'[^A-Z0-9]'), '')
          .toUpperCase();
      textRecognizer.close();
      if (!mounted) return;
      setState(() {
        _searchController.text = spz;
        _searchQuery = spz.toLowerCase();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Chyba skenování: $e'), backgroundColor: Colors.red));
    }
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
                  controller: _searchController,
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Hledat SPZ, Značku nebo VIN...',
                    prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.document_scanner, color: Colors.teal),
                      onPressed: _scanSpz,
                      tooltip: 'Naskenovat SPZ fotoaparátem',
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
