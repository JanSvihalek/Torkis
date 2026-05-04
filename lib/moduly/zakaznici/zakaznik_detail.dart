import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth_gate.dart';
import 'zakaznici_constants.dart';
import 'zakaznik_tab_info.dart';
import 'zakaznik_tab_zakazky.dart';
import 'zakaznik_tab_faktury.dart';
import 'zakaznik_tab_prijem.dart';

class ZakaznikDetailScreen extends StatelessWidget {
  final Map<String, dynamic> zakaznikData;

  const ZakaznikDetailScreen({super.key, required this.zakaznikData});

  void _otevritEditaci(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final jmenoCtrl =
        TextEditingController(text: data['jmeno']?.toString() ?? '');
    String telPredvolba = '+420';
    String telefonRaw = data['telefon']?.toString() ?? '';
    for (final p in kPredvolby) {
      if (telefonRaw.startsWith(p['kod']!)) {
        telPredvolba = p['kod']!;
        telefonRaw = telefonRaw.substring(p['kod']!.length).trim();
        break;
      }
    }
    final telCtrl = TextEditingController(text: telefonRaw);
    final emailCtrl =
        TextEditingController(text: data['email']?.toString() ?? '');
    final adresaCtrl =
        TextEditingController(text: data['adresa']?.toString() ?? '');
    final icoCtrl =
        TextEditingController(text: data['ico']?.toString() ?? '');
    final dicCtrl =
        TextEditingController(text: data['dic']?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Úprava zákazníka',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: jmenoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Jméno a Příjmení / Název firmy',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text('Telefon',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  const SizedBox(height: 8),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (_) => Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(25)),
                              ),
                              padding: const EdgeInsets.fromLTRB(
                                  20, 16, 20, 30),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 4,
                                    margin: const EdgeInsets.only(
                                        bottom: 16),
                                    decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  const Text('Vyberte předvolbu',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight:
                                              FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  ...kPredvolby.map((p) => ListTile(
                                        leading: Text(p['vlajka']!,
                                            style: const TextStyle(
                                                fontSize: 24)),
                                        title: Text(p['nazev']!),
                                        trailing: Text(p['kod']!,
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                                color: Colors.blue)),
                                        selected:
                                            p['kod'] == telPredvolba,
                                        selectedColor: Colors.blue,
                                        onTap: () {
                                          setSheetState(() =>
                                              telPredvolba =
                                                  p['kod']!);
                                          Navigator.pop(context);
                                        },
                                      )),
                                ],
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  kPredvolby.firstWhere(
                                      (p) => p['kod'] == telPredvolba,
                                      orElse: () =>
                                          kPredvolby.first)['vlajka']!,
                                  style:
                                      const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 6),
                                Text(telPredvolba,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const Icon(Icons.arrow_drop_down,
                                    size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: telCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                                labelText: 'Číslo',
                                border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                        labelText: 'E-mail',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: adresaCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Adresa',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: icoCtrl,
                        decoration: const InputDecoration(
                            labelText: 'IČO',
                            border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        controller: dicCtrl,
                        decoration: const InputDecoration(
                            labelText: 'DIČ',
                            border: OutlineInputBorder()),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('zakaznici')
                            .doc(docId)
                            .update({
                          'jmeno': jmenoCtrl.text.trim(),
                          'telefon':
                              '$telPredvolba${telCtrl.text.trim()}',
                          'email': emailCtrl.text.trim(),
                          'adresa': adresaCtrl.text.trim(),
                          'ico': icoCtrl.text.trim(),
                          'dic': dicCtrl.text.trim(),
                        });
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('ULOŽIT ZMĚNY',
                          style:
                              TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (globalServisId == null) {
      return const Scaffold(
          body: Center(child: Text('Zpracovávám data...')));
    }

    final zakaznikId = zakaznikData['id_zakaznika'] ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('zakaznici')
          .where('servis_id', isEqualTo: globalServisId)
          .where('id_zakaznika', isEqualTo: zakaznikId)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text("Chyba: ${snapshot.error}")));
        }
        if (!snapshot.hasData) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()));
        }

        if (snapshot.data!.docs.isEmpty) {
          return _buildScreen(
              context, isDark, zakaznikData, "UNKNOWN", globalServisId!);
        }

        final doc = snapshot.data!.docs.first;
        final aktualniData = doc.data() as Map<String, dynamic>;
        final docId = doc.id;

        return _buildScreen(
            context, isDark, aktualniData, docId, globalServisId!);
      },
    );
  }

  Widget _buildScreen(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> aktualniData,
    String docId,
    String servisId,
  ) {
    final zakaznikId = aktualniData['id_zakaznika'] ?? '';

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            aktualniData['jmeno'] ?? 'Karta zákazníka',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor:
              isDark ? const Color(0xFF1E3A5F) : Colors.white,
          elevation: 0,
          actions: [
            if (docId != "UNKNOWN")
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                tooltip: 'Upravit údaje',
                onPressed: () =>
                    _otevritEditaci(context, docId, aktualniData),
              ),
          ],
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorWeight: 3,
            tabs: [
              Tab(
                  icon: Icon(Icons.person),
                  text: 'Info & Vozidla'),
              Tab(icon: Icon(Icons.build), text: 'Zakázky'),
              Tab(
                  icon: Icon(Icons.receipt_long),
                  text: 'Faktury'),
              Tab(
                  icon: Icon(
                      Icons.assignment_turned_in_outlined),
                  text: 'Příjem'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ZakaznikInfoTab(
              isDark: isDark,
              dataZakaznika: aktualniData,
              zakaznikId: zakaznikId,
              servisId: servisId,
            ),
            ZakaznikZakazkyTab(
              isDark: isDark,
              zakaznikId: zakaznikId,
              servisId: servisId,
            ),
            ZakaznikFakturyTab(
              isDark: isDark,
              zakaznikId: zakaznikId,
              servisId: servisId,
            ),
            ZakaznikPrijemTab(
              isDark: isDark,
              zakaznikId: zakaznikId,
              servisId: servisId,
            ),
          ],
        ),
      ),
    );
  }
}
