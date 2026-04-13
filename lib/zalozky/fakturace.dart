import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import '../core/constants.dart';
import '../core/pdf_generator.dart';

import 'zakaznici.dart';
import 'vozidla.dart';
import 'prubeh.dart';

Future<void> syncAndRegenerateFaktura(
  String fakturaDocId,
  String zakazkaId,
  List<dynamic> updatedPrace,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  double celkovaSuma = 0.0;
  for (var prace in updatedPrace) {
    final polozky = prace['polozky'] as List<dynamic>?;
    if (polozky != null) {
      for (var p in polozky) {
        double mnoz = double.tryParse(p['mnozstvi'].toString()) ?? 1.0;
        double cena = double.tryParse(p['cena_s_dph'].toString()) ?? 0.0;
        celkovaSuma += (mnoz * cena);
      }
    } else {
      celkovaSuma += (prace['cena_s_dph'] ?? 0.0).toDouble();
      final dily = prace['pouzite_dily'] as List<dynamic>? ?? [];
      for (var dil in dily) {
        double p = double.tryParse(dil['pocet'].toString()) ?? 1.0;
        double c = double.tryParse(dil['cena_s_dph'].toString()) ?? 0.0;
        celkovaSuma += (p * c);
      }
    }
  }

  final zakazkaRef = FirebaseFirestore.instance
      .collection('zakazky')
      .doc('${user.uid}_$zakazkaId');
  final zakDoc = await zakazkaRef.get();
  if (!zakDoc.exists)
    throw Exception("Původní zakázka nenalezena pro přegenerování PDF.");
  final zakData = zakDoc.data()!;

  zakData['provedene_prace'] = updatedPrace;

  String odesilatelJmeno = 'Servis';
  String odesilatelIco = '';
  final docNastaveni = await FirebaseFirestore.instance
      .collection('nastaveni_servisu')
      .doc(user.uid)
      .get();
  if (docNastaveni.exists) {
    odesilatelJmeno = docNastaveni.data()?['nazev_servisu'] ?? 'Servis';
    odesilatelIco = docNastaveni.data()?['ico_servisu'] ?? '';
  }

  final pdfBytes = await GlobalPdfGenerator.generateDocument(
    data: zakData,
    servisNazev: odesilatelJmeno,
    servisIco: odesilatelIco,
    typ: PdfTyp.faktura,
  );

  Reference pdfRef = FirebaseStorage.instance.ref().child(
        'servisy/${user.uid}/zakazky/$zakazkaId/finalni_vyuctovani_$zakazkaId.pdf',
      );
  await pdfRef.putData(
    pdfBytes,
    SettableMetadata(contentType: 'application/pdf'),
  );
  String pdfUrl = await pdfRef.getDownloadURL();

  await FirebaseFirestore.instance
      .collection('faktury')
      .doc(fakturaDocId)
      .update({
    'provedene_prace': updatedPrace,
    'celkova_castka': celkovaSuma,
    'pdf_url': pdfUrl,
  });

  await zakazkaRef.update({
    'provedene_prace': updatedPrace,
    'vystupni_protokol_url': pdfUrl,
  });
}

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
      await FirebaseFirestore.instance.collection('faktury').doc(docId).update({
        'stav_platby': 'Uhrazeno',
      });

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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Center(child: Text("Nejste přihlášeni."));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ManualInvoiceScreen()),
        ),
        label: const Text('MANUÁLNÍ FAKTURA'),
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
                const Text(
                  'Fakturace',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
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
                        borderRadius: BorderRadius.circular(15),
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
                  .collection('faktury')
                  .where('servis_id', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(
                      child: Text("Chyba databáze: ${snapshot.error}"));
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

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
                        const Icon(
                          Icons.receipt_long_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Zatím nebyly vystaveny žádné faktury.'
                              : 'Nic nenalezeno.',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
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

                    final stavPlatby = data['stav_platby'] ?? 'Neznámý';
                    final jeUhrazeno = stavPlatby == 'Uhrazeno';
                    final barvaStavu =
                        jeUhrazeno ? Colors.green : Colors.redAccent;

                    return Card(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.only(bottom: 15),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FakturaDetailScreen(
                                fakturaDocId: docId,
                                zakazkaId: data['cislo_zakazky'].toString(),
                              ),
                            ),
                          );
                        },
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    '${(data['celkova_castka'] ?? 0.0).toStringAsFixed(2)} Kč',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.blue[900]!,
                                      fontSize: 18,
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
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (data['spz'] != null &&
                                            data['spz'].toString().isNotEmpty)
                                          Text(
                                            'Vozidlo (SPZ): ${data['spz']}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
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
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Splatnost: ${_formatDate(data['datum_splatnosti'])}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: jeUhrazeno
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
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
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
                                  if (!jeUhrazeno)
                                    TextButton.icon(
                                      icon: const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'ZAPLACENO',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                      onPressed: () =>
                                          _oznacitJakoUhrazene(docId),
                                    ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
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

class FakturaDetailScreen extends StatefulWidget {
  final String fakturaDocId;
  final String zakazkaId;

  const FakturaDetailScreen({
    super.key,
    required this.fakturaDocId,
    required this.zakazkaId,
  });

  @override
  State<FakturaDetailScreen> createState() => _FakturaDetailScreenState();
}

class _FakturaDetailScreenState extends State<FakturaDetailScreen> {
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "-";
    DateTime dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  void _zobrazitPdf(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Náhled dokladu')),
          body: PdfPreview(
            build: (format) async {
              final response = await http.get(Uri.parse(url));
              return response.bodyBytes;
            },
            allowSharing: true,
            allowPrinting: true,
            canChangeOrientation: false,
            canChangePageFormat: false,
            loadingWidget: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteWork(
    BuildContext context,
    Map<String, dynamic> workItem,
    List<dynamic> vsechnyPrace,
  ) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Smazat úkon?'),
        content: const Text(
          'Opravdu chcete tuto skupinu prací z faktury odstranit? Systém následně fakturu automaticky přegeneruje.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ZRUŠIT'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'SMAZAT',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        vsechnyPrace.remove(workItem);
        await syncAndRegenerateFaktura(
          widget.fakturaDocId,
          widget.zakazkaId,
          vsechnyPrace,
        );
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Smazáno a přegenerováno.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chyba: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _openEditDialog(
    BuildContext context,
    Map<String, dynamic>? existingWork,
    int? editIndex,
    List<dynamic> vsechnyPrace,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFakturaWorkScreen(
          fakturaDocId: widget.fakturaDocId,
          zakazkaId: widget.zakazkaId,
          existingWork: existingWork,
          editIndex: editIndex,
          vsechnyPrace: List.from(vsechnyPrace),
        ),
      ),
    );
  }

  Widget _buildClickableRow({
    required bool isDark,
    required String title,
    required String value,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        title: const Text(
          'Detail faktury',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('faktury')
            .doc(widget.fakturaDocId)
            .snapshots(),
        builder: (context, fakturaSnap) {
          if (fakturaSnap.hasError)
            return Center(child: Text("Chyba: ${fakturaSnap.error}"));
          if (!fakturaSnap.hasData)
            return const Center(child: CircularProgressIndicator());

          final fData = fakturaSnap.data!.data() as Map<String, dynamic>?;
          if (fData == null)
            return const Center(child: Text("Faktura nenalezena."));

          final provedenePrace =
              fData['provedene_prace'] as List<dynamic>? ?? [];
          final stavPlatby = fData['stav_platby'] ?? 'Neznámý';
          final jeUhrazeno = stavPlatby == 'Uhrazeno';

          // Ošetření pro manuální fakturu
          final bool isManual = fData['cislo_zakazky'] == 'PRODEJ';

          // ZDE JE TA HLAVNÍ OPRAVA (FutureBuilder<DocumentSnapshot?>)
          return FutureBuilder<DocumentSnapshot?>(
            future: isManual
                ? Future<DocumentSnapshot?>.value(null)
                : FirebaseFirestore.instance
                    .collection('zakazky')
                    .doc('${user?.uid}_${widget.zakazkaId}')
                    .get(),
            builder: (context, zakazkaSnap) {
              Map<String, dynamic> zakData = {};
              if (zakazkaSnap.hasData &&
                  zakazkaSnap.data != null &&
                  zakazkaSnap.data!.exists) {
                zakData = zakazkaSnap.data!.data() as Map<String, dynamic>;
              }

              // Pokud je manuální, bereme zákazníka přímo z fData (faktury)
              final pZakaznik = isManual
                  ? (fData['zakaznik'] as Map<String, dynamic>? ?? {})
                  : (zakData['zakaznik'] as Map<String, dynamic>? ?? {});
              final telefon = pZakaznik['telefon'] ?? '';
              final email = pZakaznik['email'] ?? '';
              final znacka = zakData['znacka'] ?? '';
              final model = zakData['model'] ?? '';
              final stavVozidla =
                  zakData['stav_vozidla'] as Map<String, dynamic>? ?? {};
              final tachometr = stavVozidla['tachometr'] ?? '';

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${fData['cislo_faktury']}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (fData['pdf_url'] != null &&
                                    fData['pdf_url'].toString().isNotEmpty) {
                                  _zobrazitPdf(context, fData['pdf_url']);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'PDF zatím není k dispozici.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('ZOBRAZIT DOKLAD'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildClickableRow(
                                    isDark: isDark,
                                    title: 'Zákazník',
                                    value: '${fData['zakaznik_jmeno']}',
                                    subtitle:
                                        (telefon.isNotEmpty || email.isNotEmpty)
                                            ? '$telefon \n$email'
                                            : null,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ZakaznikDetailScreen(
                                            zakaznikData: pZakaznik,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  if (!isManual) const SizedBox(height: 5),
                                  if (!isManual)
                                    _buildClickableRow(
                                      isDark: isDark,
                                      title: 'Vozidlo',
                                      value: '${fData['spz']}',
                                      subtitle: (znacka.isNotEmpty
                                              ? '$znacka $model\n'
                                              : '') +
                                          (tachometr.toString().isNotEmpty
                                              ? 'Najeto: $tachometr km'
                                              : ''),
                                      onTap: () {
                                        final vozidloDocId =
                                            '${user!.uid}_${fData['spz']}';
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                VozidloDetailScreen(
                                              vozidloDocId: vozidloDocId,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  if (!isManual) const SizedBox(height: 5),
                                  if (!isManual)
                                    _buildClickableRow(
                                      isDark: isDark,
                                      title: 'K zakázce',
                                      value: '${fData['cislo_zakazky']}',
                                      onTap: () {
                                        final docId =
                                            '${user!.uid}_${widget.zakazkaId}';
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ActiveJobScreen(
                                              documentId: docId,
                                              zakazkaId: widget.zakazkaId,
                                              spz: fData['spz'] ?? '',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF2C2C2C)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Celková částka',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${(fData['celkova_castka'] ?? 0.0).toStringAsFixed(2)} Kč',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    const Text(
                                      'Stav úhrady',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      stavPlatby,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: jeUhrazeno
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    const Text(
                                      'Vystaveno / Splatnost',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatDate(fData['datum_vystaveni'])} \n${_formatDate(fData['datum_splatnosti'])}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const Text(
                          'Rozpis položek dokladu:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        if (provedenePrace.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(30),
                              child: Text(
                                'Faktura neobsahuje žádné položky.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ...List.generate(provedenePrace.length, (index) {
                            final prace = provedenePrace[index];

                            List<dynamic> polozky =
                                prace['polozky'] as List<dynamic>? ?? [];
                            if (polozky.isEmpty) {
                              if ((prace['cena_s_dph'] ?? 0) > 0) {
                                polozky.add({
                                  'typ': 'Práce',
                                  'nazev': 'Práce',
                                  'cislo': '',
                                  'mnozstvi': prace['delka_prace'] ?? 1,
                                  'jednotka': 'h',
                                  'cena_s_dph': prace['cena_s_dph'],
                                });
                              }
                              for (var d
                                  in (prace['pouzite_dily'] as List<dynamic>? ??
                                      [])) {
                                polozky.add({
                                  'typ': 'Materiál',
                                  'nazev': d['nazev'],
                                  'cislo': d['cislo'] ?? '',
                                  'mnozstvi': d['pocet'] ?? 1,
                                  'jednotka': 'ks',
                                  'cena_s_dph': d['cena_s_dph'],
                                });
                              }
                            }

                            double celkemUkon = 0.0;
                            for (var p in polozky) {
                              celkemUkon +=
                                  (double.tryParse(p['mnozstvi'].toString()) ??
                                          1.0) *
                                      (double.tryParse(
                                            p['cena_s_dph'].toString(),
                                          ) ??
                                          0.0);
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 15),
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
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
                                        Expanded(
                                          child: Text(
                                            '${prace['nazev']} (${celkemUkon.toStringAsFixed(2)} Kč)',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (!isManual)
                                          IconButton(
                                            onPressed: () => _openEditDialog(
                                              context,
                                              prace,
                                              index,
                                              provedenePrace,
                                            ),
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                          ),
                                        if (!isManual)
                                          IconButton(
                                            onPressed: () => _deleteWork(
                                              context,
                                              prace,
                                              List.from(provedenePrace),
                                            ),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ...polozky.map((p) {
                                      double pMnoz = double.tryParse(
                                            p['mnozstvi'].toString(),
                                          ) ??
                                          1.0;
                                      double pCena = double.tryParse(
                                            p['cena_s_dph'].toString(),
                                          ) ??
                                          0.0;
                                      String pJedn = p['jednotka'] ?? 'ks';
                                      String cistyMnoz =
                                          pMnoz.toString().replaceAll(
                                                RegExp(r"([.]*0)(?!.*\d)"),
                                                "",
                                              );

                                      String cNum =
                                          p['cislo']?.toString() ?? '';
                                      String nDisp = cNum.trim().isNotEmpty
                                          ? '${p['nazev']} ($cNum)'
                                          : p['nazev'];

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4,
                                          left: 10,
                                        ),
                                        child: Text(
                                          '• [${p['typ']}] $nDisp - $cistyMnoz $pJedn - ${(pMnoz * pCena).toStringAsFixed(2)} Kč',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  if (!isManual)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        boxShadow: [
                          const BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 10,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _openEditDialog(
                              context,
                              null,
                              null,
                              provedenePrace,
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text(
                              'PŘIDAT ÚKON DO FAKTURY',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class PolozkaInput {
  String typ = 'Materiál';
  final cislo = TextEditingController();
  final nazev = TextEditingController();
  final mnozstvi = TextEditingController(text: '1');
  String jednotka = 'ks';
  final cenaBezDph = TextEditingController(text: '0');
  final cenaSDph = TextEditingController(text: '0');

  void dispose() {
    cislo.dispose();
    nazev.dispose();
    mnozstvi.dispose();
    cenaBezDph.dispose();
    cenaSDph.dispose();
  }
}

class EditFakturaWorkScreen extends StatefulWidget {
  final String fakturaDocId;
  final String zakazkaId;
  final Map<String, dynamic>? existingWork;
  final int? editIndex;
  final List<dynamic> vsechnyPrace;

  const EditFakturaWorkScreen({
    super.key,
    required this.fakturaDocId,
    required this.zakazkaId,
    this.existingWork,
    this.editIndex,
    required this.vsechnyPrace,
  });

  @override
  State<EditFakturaWorkScreen> createState() => _EditFakturaWorkScreenState();
}

class _EditFakturaWorkScreenState extends State<EditFakturaWorkScreen> {
  final _nazevController = TextEditingController();
  final _popisController = TextEditingController();

  final List<PolozkaInput> _polozkyInputs = [];

  bool _isSaving = false;
  double _hodinovaSazba = 0.0;
  bool _jePlatceDph = false;
  double _celkovaCenaSDph = 0.0;

  @override
  void initState() {
    super.initState();
    _nactiHodinovouSazbu();

    if (widget.existingWork != null) {
      _nazevController.text = widget.existingWork!['nazev'] ?? '';
      _popisController.text = widget.existingWork!['popis'] ?? '';

      final polozky = widget.existingWork!['polozky'] as List<dynamic>?;
      if (polozky != null) {
        for (var p in polozky) {
          final input = PolozkaInput();
          input.typ = p['typ'] ?? 'Materiál';
          input.cislo.text = p['cislo'] ?? '';
          input.nazev.text = p['nazev'] ?? '';
          input.mnozstvi.text = (p['mnozstvi'] ?? 1.0).toString();
          input.jednotka = p['jednotka'] ?? 'ks';
          input.cenaBezDph.text = (p['cena_bez_dph'] ?? 0.0).toStringAsFixed(2);
          input.cenaSDph.text = (p['cena_s_dph'] ?? 0.0).toStringAsFixed(2);
          _polozkyInputs.add(input);
        }
      } else {
        if ((widget.existingWork!['cena_s_dph'] ?? 0) > 0 ||
            (widget.existingWork!['delka_prace']?.toString().isNotEmpty ==
                true)) {
          final input = PolozkaInput();
          input.typ = 'Práce';
          input.cislo.text = '';
          input.nazev.text = 'Práce mechanika';
          input.mnozstvi.text =
              (widget.existingWork!['delka_prace'] ?? 1).toString();
          input.jednotka = 'h';
          input.cenaBezDph.text =
              (widget.existingWork!['cena_bez_dph'] ?? 0.0).toStringAsFixed(2);
          input.cenaSDph.text =
              (widget.existingWork!['cena_s_dph'] ?? 0.0).toStringAsFixed(2);
          _polozkyInputs.add(input);
        }
        final dily =
            widget.existingWork!['pouzite_dily'] as List<dynamic>? ?? [];
        for (var d in dily) {
          final input = PolozkaInput();
          input.typ = 'Materiál';
          input.cislo.text = d['cislo'] ?? '';
          input.nazev.text = d['nazev'] ?? '';
          input.mnozstvi.text = (d['pocet'] ?? 1.0).toString();
          input.jednotka = 'ks';
          input.cenaBezDph.text = (d['cena_bez_dph'] ?? 0.0).toStringAsFixed(2);
          input.cenaSDph.text = (d['cena_s_dph'] ?? 0.0).toStringAsFixed(2);
          _polozkyInputs.add(input);
        }
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prepocitatCelkem();
      });
    }

    if (_polozkyInputs.isEmpty) {
      _polozkyInputs.add(PolozkaInput());
    }
  }

  Future<void> _nactiHodinovouSazbu() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('nastaveni_servisu')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _hodinovaSazba = (doc.data()?['hodinova_sazba'] ?? 0.0).toDouble();
          _jePlatceDph = doc.data()?['platce_dph'] ?? false;
        });
      }
    }
  }

  void _prepocitatCelkem() {
    double celkem = 0.0;
    for (var p in _polozkyInputs) {
      double pocet =
          double.tryParse(p.mnozstvi.text.replaceAll(',', '.')) ?? 0.0;
      double cenaKs =
          double.tryParse(p.cenaSDph.text.replaceAll(',', '.')) ?? 0.0;
      celkem += (pocet * cenaKs);
    }
    setState(() {
      _celkovaCenaSDph = celkem;
    });
  }

  void _prepocitatDphPolozky(PolozkaInput p, String bezDphText) {
    double bezDph = double.tryParse(bezDphText.replaceAll(',', '.')) ?? 0.0;
    double sDph = _jePlatceDph ? (bezDph * 1.21) : bezDph;
    p.cenaSDph.text = sDph.toStringAsFixed(2);
    _prepocitatCelkem();
  }

  @override
  void dispose() {
    _nazevController.dispose();
    _popisController.dispose();
    for (var p in _polozkyInputs) {
      p.dispose();
    }
    super.dispose();
  }

  Future<void> _saveWork() async {
    if (_nazevController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zadejte alespoň hlavičku (Název skupiny).'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      List<Map<String, dynamic>> zpracovanePolozky = _polozkyInputs
          .map(
            (p) => {
              'typ': p.typ,
              'cislo': p.cislo.text.trim(),
              'nazev': p.nazev.text.trim(),
              'mnozstvi':
                  double.tryParse(p.mnozstvi.text.replaceAll(',', '.')) ?? 1.0,
              'jednotka': p.jednotka,
              'cena_bez_dph':
                  double.tryParse(p.cenaBezDph.text.replaceAll(',', '.')) ??
                      0.0,
              'cena_s_dph':
                  double.tryParse(p.cenaSDph.text.replaceAll(',', '.')) ?? 0.0,
            },
          )
          .where((d) => d['nazev'].toString().isNotEmpty)
          .toList();

      Map<String, dynamic> novyUkon = {
        'nazev': _nazevController.text.trim(),
        'popis': _popisController.text.trim(),
        'polozky': zpracovanePolozky,
        'cas': widget.existingWork?['cas'] ?? Timestamp.now(),
        'fotografie_urls': widget.existingWork?['fotografie_urls'] ?? [],
      };

      List<dynamic> aktualniPrace = widget.vsechnyPrace;

      if (widget.editIndex != null &&
          widget.editIndex! >= 0 &&
          widget.editIndex! < aktualniPrace.length) {
        aktualniPrace[widget.editIndex!] = novyUkon;
      } else {
        aktualniPrace.add(novyUkon);
      }

      await syncAndRegenerateFaktura(
        widget.fakturaDocId,
        widget.zakazkaId,
        aktualniPrace,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Chyba: $e')));
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.existingWork != null ? 'Úprava faktury' : 'Přidat do faktury',
        ),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.folder, color: Colors.blue),
                              SizedBox(width: 10),
                              Text(
                                'Hlavička (Skupina)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            _nazevController,
                            'Název úkonu na faktuře *',
                            isDark,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Card(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.format_list_bulleted,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Položky dokladu',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          ...List.generate(_polozkyInputs.length, (index) {
                            final polozka = _polozkyInputs[index];
                            double dPocet = double.tryParse(
                                  polozka.mnozstvi.text.replaceAll(',', '.'),
                                ) ??
                                0.0;
                            double dCena = double.tryParse(
                                  polozka.cenaSDph.text.replaceAll(',', '.'),
                                ) ??
                                0.0;
                            double rCelkem = dPocet * dCena;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2C2C2C)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: DropdownButtonFormField<String>(
                                          value: polozka.typ,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          items: ['Práce', 'Materiál']
                                              .map(
                                                (t) => DropdownMenuItem(
                                                  value: t,
                                                  child: Text(
                                                    t,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                polozka.typ = val;
                                                if (val == 'Práce') {
                                                  polozka.jednotka = 'h';
                                                  if (_hodinovaSazba > 0) {
                                                    polozka.cenaBezDph.text =
                                                        _hodinovaSazba
                                                            .toStringAsFixed(2);
                                                    _prepocitatDphPolozky(
                                                      polozka,
                                                      polozka.cenaBezDph.text,
                                                    );
                                                  }
                                                }
                                                if (val == 'Materiál')
                                                  polozka.jednotka = 'ks';
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Typ',
                                            labelStyle: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            filled: true,
                                            fillColor: isDark
                                                ? const Color(0xFF1E1E1E)
                                                : Colors.white,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 4,
                                        child: _buildTextField(
                                          polozka.cislo,
                                          'Číslo dílu',
                                          isDark,
                                          compact: true,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          setState(() {
                                            polozka.dispose();
                                            _polozkyInputs.removeAt(index);
                                            _prepocitatCelkem();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    polozka.nazev,
                                    'Název položky',
                                    isDark,
                                    compact: true,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: _buildTextField(
                                          polozka.mnozstvi,
                                          'Mn.',
                                          isDark,
                                          isNumber: true,
                                          compact: true,
                                          onChanged: (v) => _prepocitatCelkem(),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        flex: 3,
                                        child: DropdownButtonFormField<String>(
                                          value: polozka.jednotka,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          items: [
                                            'ks',
                                            'h',
                                            'min',
                                            'l',
                                            'm',
                                            'bal',
                                            'sada',
                                            'úkon',
                                          ]
                                              .map(
                                                (j) => DropdownMenuItem(
                                                  value: j,
                                                  child: Text(
                                                    j,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null)
                                              setState(
                                                () => polozka.jednotka = val,
                                              );
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Jedn.',
                                            labelStyle: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            filled: true,
                                            fillColor: isDark
                                                ? const Color(0xFF1E1E1E)
                                                : Colors.white,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 10,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        flex: 3,
                                        child: _buildTextField(
                                          polozka.cenaBezDph,
                                          _jePlatceDph ? 'Bez DPH' : 'Cena',
                                          isDark,
                                          isNumber: true,
                                          compact: true,
                                          onChanged: (v) =>
                                              _prepocitatDphPolozky(polozka, v),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        flex: 3,
                                        child: _buildTextField(
                                          polozka.cenaSDph,
                                          _jePlatceDph ? 'S DPH' : 'Konečná',
                                          isDark,
                                          isNumber: true,
                                          compact: true,
                                          onChanged: (v) => _prepocitatCelkem(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Celkem za položku: ',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          '${rCelkem.toStringAsFixed(2)} Kč',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          TextButton.icon(
                            onPressed: () => setState(
                              () => _polozkyInputs.add(PolozkaInput()),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Přidat další položku'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : Colors.white,
              boxShadow: [
                const BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Celkem po úpravě',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          '${_celkovaCenaSDph.toStringAsFixed(2)} Kč',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveWork,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      _isSaving ? 'ZPRACOVÁVÁM...' : 'ULOŽIT A PŘEGENEROVAT',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isDark, {
    bool isNumber = false,
    bool isBold = false,
    bool compact = false,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontSize: compact ? 12 : (isBold ? 16 : 14),
      ),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(fontSize: compact ? 12 : 14),
        filled: true,
        fillColor: isDark
            ? (compact ? const Color(0xFF1E1E1E) : const Color(0xFF2C2C2C))
            : Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 15,
          vertical: compact ? 10 : 15,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// OBRAZOVKA PRO MANUÁLNÍ VYTVOŘENÍ FAKTURY (Bez zakázky)
class ManualInvoiceScreen extends StatefulWidget {
  const ManualInvoiceScreen({super.key});

  @override
  State<ManualInvoiceScreen> createState() => _ManualInvoiceScreenState();
}

class _ManualInvoiceScreenState extends State<ManualInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Data zákazníka
  Map<String, dynamic>? _vybranyZakaznik;
  final _jmenoController = TextEditingController();
  final _telefonController = TextEditingController();
  final _emailController = TextEditingController();
  final _adresaController = TextEditingController();
  final _icoController = TextEditingController();
  final _dicController = TextEditingController();

  final List<PolozkaInput> _polozkyInputs = [];

  String _formaUhrady = 'Převodem';
  int _splatnostDny = 14;
  bool _isSaving = false;
  double _hodinovaSazba = 0.0;
  bool _jePlatceDph = false;
  double _celkovaCenaSDph = 0.0;

  @override
  void initState() {
    super.initState();
    _polozkyInputs.add(PolozkaInput());
    _nactiNastaveni();
  }

  @override
  void dispose() {
    _jmenoController.dispose();
    _telefonController.dispose();
    _emailController.dispose();
    _adresaController.dispose();
    _icoController.dispose();
    _dicController.dispose();
    for (var p in _polozkyInputs) {
      p.dispose();
    }
    super.dispose();
  }

  Future<void> _nactiNastaveni() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('nastaveni_servisu')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _splatnostDny = doc.data()?['splatnost_dny'] ?? 14;
          _jePlatceDph = doc.data()?['platce_dph'] ?? false;
          _hodinovaSazba = (doc.data()?['hodinova_sazba'] ?? 0.0).toDouble();
        });
      }
    }
  }

  void _prepocitatCelkem() {
    double celkem = 0.0;
    for (var p in _polozkyInputs) {
      double pocet =
          double.tryParse(p.mnozstvi.text.replaceAll(',', '.')) ?? 0.0;
      double cenaKs =
          double.tryParse(p.cenaSDph.text.replaceAll(',', '.')) ?? 0.0;
      celkem += (pocet * cenaKs);
    }
    setState(() {
      _celkovaCenaSDph = celkem;
    });
  }

  void _prepocitatDphPolozky(PolozkaInput p, String bezDphText) {
    double bezDph = double.tryParse(bezDphText.replaceAll(',', '.')) ?? 0.0;
    double sDph = _jePlatceDph ? (bezDph * 1.21) : bezDph;
    p.cenaSDph.text = sDph.toStringAsFixed(2);
    _prepocitatCelkem();
  }

  Future<void> _ulozitFakturu() async {
    if (_jmenoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Zadejte prosím jméno nebo název zákazníka.')));
      return;
    }

    // Zkontrolujeme, zda mají všechny položky název
    bool maChybu = false;
    for (var p in _polozkyInputs) {
      if (p.nazev.text.trim().isEmpty) {
        maChybu = true;
        break;
      }
    }

    if (maChybu) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vyplňte názvy u všech položek.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final ted = DateTime.now();
      final splatnost = ted.add(Duration(days: _splatnostDny));

      // Sestavení dat zákazníka
      Map<String, dynamic> finalCustomerData = {
        'id_zakaznika': _vybranyZakaznik?['id_zakaznika'] ?? '',
        'jmeno': _jmenoController.text.trim(),
        'telefon': _telefonController.text.trim(),
        'email': _emailController.text.trim(),
        'adresa': _adresaController.text.trim(),
        'ico': _icoController.text.trim(),
        'dic': _dicController.text.trim(),
      };

      // Zpracování položek ze složitého formuláře do formátu pro DB
      List<Map<String, dynamic>> zpracovanePolozky = _polozkyInputs
          .map(
            (p) => {
              'typ': p.typ,
              'cislo': p.cislo.text.trim(),
              'nazev': p.nazev.text.trim(),
              'mnozstvi':
                  double.tryParse(p.mnozstvi.text.replaceAll(',', '.')) ?? 1.0,
              'jednotka': p.jednotka,
              'cena_bez_dph':
                  double.tryParse(p.cenaBezDph.text.replaceAll(',', '.')) ??
                      0.0,
              'cena_s_dph':
                  double.tryParse(p.cenaSDph.text.replaceAll(',', '.')) ?? 0.0,
            },
          )
          .where((d) => d['nazev'].toString().isNotEmpty)
          .toList();

      // Generování čísla faktury
      String timestamp = ted.millisecondsSinceEpoch.toString().substring(7);
      String cisloFaktury = 'MAN-$timestamp';

      // Příprava dat pro PDF generátor
      Map<String, dynamic> invoiceData = {
        'zakaznik': finalCustomerData,
        'cislo_zakazky': 'PRODEJ',
        'spz': '',
        'cas_prijeti': Timestamp.fromDate(ted),
        'splatnost_dny': _splatnostDny,
        'provedene_prace': [
          {
            'nazev': 'Prodej / Služby',
            'polozky': zpracovanePolozky,
            'cas': Timestamp.fromDate(ted),
          }
        ],
      };

      // Načtení info o servisu
      final docNast = await FirebaseFirestore.instance
          .collection('nastaveni_servisu')
          .doc(user!.uid)
          .get();
      String sNazev = docNast.data()?['nazev_servisu'] ?? 'Servis';
      String sIco = docNast.data()?['ico_servisu'] ?? '';

      // Generování PDF
      final pdfBytes = await GlobalPdfGenerator.generateDocument(
        data: invoiceData,
        servisNazev: sNazev,
        servisIco: sIco,
        typ: PdfTyp.faktura,
      );

      // Upload PDF
      Reference pdfRef = FirebaseStorage.instance
          .ref()
          .child('servisy/${user.uid}/faktury/$cisloFaktury.pdf');
      await pdfRef.putData(
          pdfBytes, SettableMetadata(contentType: 'application/pdf'));
      String pdfUrl = await pdfRef.getDownloadURL();

      // Uložení do Firestore
      await FirebaseFirestore.instance
          .collection('faktury')
          .doc('${user.uid}_$cisloFaktury')
          .set({
        'servis_id': user.uid,
        'cislo_faktury': cisloFaktury,
        'zakaznik_id': finalCustomerData['id_zakaznika'],
        'zakaznik_jmeno': finalCustomerData['jmeno'],
        'zakaznik': finalCustomerData,
        'cislo_zakazky': 'PRODEJ',
        'datum_vystaveni': Timestamp.fromDate(ted),
        'datum_splatnosti': Timestamp.fromDate(splatnost),
        'forma_uhrady': _formaUhrady,
        'celkova_castka': _celkovaCenaSDph,
        'stav_platby': (_formaUhrady == 'Hotově' || _formaUhrady == 'Kartou')
            ? 'Uhrazeno'
            : 'Čeká na platbu',
        'pdf_url': pdfUrl,
        'vytvoreno': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Faktura byla úspěšně vytvořena.'),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Nová manuální faktura')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // VÝBĚR NEBO ZADÁNÍ ZÁKAZNÍKA
              const Text('Zákazník (Odběratel)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('zakaznici')
                    .where('servis_id',
                        isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const SizedBox(
                        height: 50,
                        child: Center(child: CircularProgressIndicator()));
                  final zakaznici = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark
                          ? Colors.white10
                          : Colors.blue.withOpacity(0.05),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.blue.withOpacity(0.3))),
                    ),
                    hint: const Text('Vyberte uloženého zákazníka (nepovinné)',
                        style: TextStyle(color: Colors.blue)),
                    value: _vybranyZakaznik?['id_zakaznika']?.toString(),
                    items: zakaznici.map<DropdownMenuItem<String>>((z) {
                      final d = z.data() as Map<String, dynamic>;
                      return DropdownMenuItem<String>(
                          value: d['id_zakaznika']?.toString(),
                          child: Text(d['jmeno']?.toString() ?? '---'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final selected = zakaznici.firstWhere((z) =>
                            (z.data() as Map)['id_zakaznika']?.toString() ==
                            val);
                        final data = selected.data() as Map<String, dynamic>;

                        setState(() {
                          _vybranyZakaznik = data;
                          _jmenoController.text =
                              data['jmeno']?.toString() ?? '';
                          _telefonController.text =
                              data['telefon']?.toString() ?? '';
                          _emailController.text =
                              data['email']?.toString() ?? '';
                          _adresaController.text =
                              data['adresa']?.toString() ?? '';
                          _icoController.text = data['ico']?.toString() ?? '';
                          _dicController.text = data['dic']?.toString() ?? '';
                        });
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 15),

              Card(
                elevation: 0,
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.withOpacity(0.2))),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _jmenoController,
                        decoration: const InputDecoration(
                            labelText: 'Jméno a Příjmení / Název firmy *'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _telefonController,
                              decoration:
                                  const InputDecoration(labelText: 'Telefon'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _emailController,
                              decoration:
                                  const InputDecoration(labelText: 'E-mail'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _adresaController,
                        decoration: const InputDecoration(
                            labelText: 'Fakturační adresa'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _icoController,
                              decoration:
                                  const InputDecoration(labelText: 'IČO'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _dicController,
                              decoration:
                                  const InputDecoration(labelText: 'DIČ'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // POLOŽKY V DETAILNÍM FORMÁTU
              const Text('Položky dokladu',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),

              ...List.generate(_polozkyInputs.length, (index) {
                final polozka = _polozkyInputs[index];
                double dPocet = double.tryParse(
                      polozka.mnozstvi.text.replaceAll(',', '.'),
                    ) ??
                    0.0;
                double dCena = double.tryParse(
                      polozka.cenaSDph.text.replaceAll(',', '.'),
                    ) ??
                    0.0;
                double rCelkem = dPocet * dCena;

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              value: polozka.typ,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              items: ['Práce', 'Materiál']
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(
                                        t,
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    polozka.typ = val;
                                    if (val == 'Práce') {
                                      polozka.jednotka = 'h';
                                      if (_hodinovaSazba > 0) {
                                        polozka.cenaBezDph.text =
                                            _hodinovaSazba.toStringAsFixed(2);
                                        _prepocitatDphPolozky(
                                          polozka,
                                          polozka.cenaBezDph.text,
                                        );
                                      }
                                    }
                                    if (val == 'Materiál')
                                      polozka.jednotka = 'ks';
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Typ',
                                labelStyle: const TextStyle(
                                  fontSize: 12,
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: _buildTextField(
                              polozka.cislo,
                              'Číslo dílu',
                              isDark,
                              compact: true,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() {
                                polozka.dispose();
                                _polozkyInputs.removeAt(index);
                                _prepocitatCelkem();
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        polozka.nazev,
                        'Název položky *',
                        isDark,
                        compact: true,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              polozka.mnozstvi,
                              'Mn.',
                              isDark,
                              isNumber: true,
                              compact: true,
                              onChanged: (v) => _prepocitatCelkem(),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              value: polozka.jednotka,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              items: [
                                'ks',
                                'h',
                                'min',
                                'l',
                                'm',
                                'bal',
                                'sada',
                                'úkon',
                              ]
                                  .map(
                                    (j) => DropdownMenuItem(
                                      value: j,
                                      child: Text(
                                        j,
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setState(
                                    () => polozka.jednotka = val,
                                  );
                              },
                              decoration: InputDecoration(
                                labelText: 'Jedn.',
                                labelStyle: const TextStyle(
                                  fontSize: 12,
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 3,
                            child: _buildTextField(
                              polozka.cenaBezDph,
                              _jePlatceDph ? 'Bez DPH' : 'Cena',
                              isDark,
                              isNumber: true,
                              compact: true,
                              onChanged: (v) =>
                                  _prepocitatDphPolozky(polozka, v),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 3,
                            child: _buildTextField(
                              polozka.cenaSDph,
                              _jePlatceDph ? 'S DPH' : 'Konečná',
                              isDark,
                              isNumber: true,
                              compact: true,
                              onChanged: (v) => _prepocitatCelkem(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Celkem za položku: ',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${rCelkem.toStringAsFixed(2)} Kč',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: () =>
                    setState(() => _polozkyInputs.add(PolozkaInput())),
                icon: const Icon(Icons.add),
                label: const Text('Přidat další položku'),
              ),
              const Divider(height: 40),

              // PLATEBNÍ ÚDAJE
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Forma úhrady'),
                      value: _formaUhrady,
                      items: ['Převodem', 'Hotově', 'Kartou']
                          .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) => setState(() {
                        _formaUhrady = v!;
                        _splatnostDny =
                            (v == 'Hotově' || v == 'Kartou') ? 0 : 14;
                      }),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      decoration:
                          const InputDecoration(labelText: 'Splatnost (dny)'),
                      keyboardType: TextInputType.number,
                      controller:
                          TextEditingController(text: _splatnostDny.toString()),
                      onChanged: (v) => _splatnostDny = int.tryParse(v) ?? 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // REKAPITULACE
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('CELKEM K ÚHRADĚ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('${_celkovaCenaSDph.toStringAsFixed(2)} Kč',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.blue)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _ulozitFakturu,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('VYSTAVIT FAKTURU A PDF',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isDark, {
    bool isNumber = false,
    bool isBold = false,
    bool compact = false,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontSize: compact ? 12 : (isBold ? 16 : 14),
      ),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(fontSize: compact ? 12 : 14),
        filled: true,
        fillColor: isDark
            ? (compact ? const Color(0xFF1E1E1E) : const Color(0xFF2C2C2C))
            : Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 15,
          vertical: compact ? 10 : 15,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
