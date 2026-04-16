import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_gate.dart'; // Kvůli globalServisId

class SkladPage extends StatefulWidget {
  const SkladPage({super.key});

  @override
  State<SkladPage> createState() => _SkladPageState();
}

class _SkladPageState extends State<SkladPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (globalServisId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPartDialog(context, isDark),
        label: const Text('NOVÝ DÍL',
            style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_box),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Vyhledávací lišta
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Hledat kód, název nebo výrobce...',
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
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

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sklad')
                  .where('servis_id', isEqualTo: globalServisId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text('Chyba: ${snapshot.error}'));
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final searchField =
                      "${data['nazev']} ${data['kod']} ${data['vyrobce']}"
                          .toLowerCase();
                  return searchField.contains(_searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child: Text('Sklad je prázdný nebo díl nebyl nalezen.',
                        style: TextStyle(color: Colors.grey)),
                  );
                }

                // Řazení abecedně podle názvu
                docs.sort((a, b) {
                  final nameA = (a.data() as Map<String, dynamic>)['nazev']
                          ?.toString()
                          .toLowerCase() ??
                      '';
                  final nameB = (b.data() as Map<String, dynamic>)['nazev']
                          ?.toString()
                          .toLowerCase() ??
                      '';
                  return nameA.compareTo(nameB);
                });

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;

                    final double stav = (data['skladem'] ?? 0).toDouble();
                    final double minStav = (data['min_stav'] ?? 0).toDouble();
                    final bool isLowStock = stav <= minStav;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: isLowStock
                              ? Colors.red.withOpacity(0.5)
                              : Colors.transparent,
                          width: isLowStock ? 2 : 0,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        leading: CircleAvatar(
                          backgroundColor: isLowStock
                              ? Colors.red.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          child: Icon(
                            isLowStock
                                ? Icons.warning_amber_rounded
                                : Icons.inventory_2,
                            color: isLowStock ? Colors.red : Colors.orange,
                          ),
                        ),
                        title: Text(data['nazev'] ?? 'Bez názvu',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(
                            'Kód: ${data['kod'] ?? '-'} | Výrobce: ${data['vyrobce'] ?? '-'}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${stav.toStringAsFixed(stav.truncateToDouble() == stav ? 0 : 2)} ${data['jednotka'] ?? 'ks'}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isLowStock ? Colors.red : Colors.green,
                              ),
                            ),
                            Text('${data['cena_prodej'] ?? 0} Kč',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        onTap: () {
                          // Zatím jen ukázka detailu, sem přidáme později naskladňování a úpravy
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Detail dílu připravujeme v dalším kroku.')));
                        },
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

  // =====================================================================
  // VYSKAKOVACÍ FORMULÁŘ PRO PŘIDÁNÍ NOVÉHO DÍLU
  // =====================================================================
  void _showAddPartDialog(BuildContext context, bool isDark) {
    final nazevCtrl = TextEditingController();
    final kodCtrl = TextEditingController();
    final vyrobceCtrl = TextEditingController();
    final nakupCenaCtrl = TextEditingController();
    final prodejCenaCtrl = TextEditingController();
    final minStavCtrl = TextEditingController(text: '0');
    final pocatecniStavCtrl = TextEditingController(text: '0');
    String vybranaJednotka = 'ks';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
              ),
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
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Nová skladová karta',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    // Základní údaje
                    _buildModalTextField(
                        nazevCtrl, 'Název dílu *', Icons.build, isDark),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                            child: _buildModalTextField(
                                kodCtrl, 'Kód / OEM', Icons.qr_code, isDark)),
                        const SizedBox(width: 15),
                        Expanded(
                            child: _buildModalTextField(vyrobceCtrl, 'Výrobce',
                                Icons.precision_manufacturing, isDark)),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Ceny
                    Row(
                      children: [
                        Expanded(
                            child: _buildModalTextField(nakupCenaCtrl,
                                'Nákupní cena', Icons.attach_money, isDark,
                                isNumber: true)),
                        const SizedBox(width: 15),
                        Expanded(
                            child: _buildModalTextField(prodejCenaCtrl,
                                'Prodejní cena', Icons.price_check, isDark,
                                isNumber: true)),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Skladové stavy a jednotky
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildModalTextField(pocatecniStavCtrl,
                              'Úvodní stav', Icons.add_box, isDark,
                              isNumber: true),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: vybranaJednotka,
                            decoration: InputDecoration(
                              labelText: 'Jednotka',
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.grey[100],
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                            ),
                            items: ['ks', 'l', 'm', 'bal', 'sada']
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (v) =>
                                setModalState(() => vybranaJednotka = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildModalTextField(
                        minStavCtrl,
                        'Upozornit při poklesu pod (Min. stav)',
                        Icons.warning_amber,
                        isDark,
                        isNumber: true),
                    const SizedBox(height: 30),

                    // Uložit
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (nazevCtrl.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Název dílu je povinný!')));
                                  return;
                                }

                                setModalState(() => isSaving = true);
                                try {
                                  double pocatecniStav = double.tryParse(
                                          pocatecniStavCtrl.text
                                              .replaceAll(',', '.')) ??
                                      0.0;
                                  double nakup = double.tryParse(nakupCenaCtrl
                                          .text
                                          .replaceAll(',', '.')) ??
                                      0.0;
                                  double prodej = double.tryParse(prodejCenaCtrl
                                          .text
                                          .replaceAll(',', '.')) ??
                                      0.0;
                                  double minStav = double.tryParse(minStavCtrl
                                          .text
                                          .replaceAll(',', '.')) ??
                                      0.0;

                                  // 1. Vytvoření karty dílu
                                  DocumentReference partRef =
                                      await FirebaseFirestore.instance
                                          .collection('sklad')
                                          .add({
                                    'servis_id': globalServisId,
                                    'nazev': nazevCtrl.text.trim(),
                                    'kod': kodCtrl.text.trim(),
                                    'vyrobce': vyrobceCtrl.text.trim(),
                                    'cena_nakup': nakup,
                                    'cena_prodej': prodej,
                                    'jednotka': vybranaJednotka,
                                    'skladem': pocatecniStav,
                                    'min_stav': minStav,
                                    'vytvoreno': FieldValue.serverTimestamp(),
                                  });

                                  // 2. Pokud se naskladnily nějaké kusy, zapíšeme to do historie
                                  if (pocatecniStav > 0) {
                                    await FirebaseFirestore.instance
                                        .collection('skladove_pohyby')
                                        .add({
                                      'servis_id': globalServisId,
                                      'sklad_id': partRef.id,
                                      'nazev_dilu': nazevCtrl.text.trim(),
                                      'typ_pohybu': 'příjem',
                                      'mnozstvi': pocatecniStav,
                                      'poznamka': 'Úvodní naskladnění',
                                      'datum': FieldValue.serverTimestamp(),
                                      'uzivatel_id': FirebaseAuth
                                          .instance.currentUser?.uid,
                                    });
                                  }

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Díl byl úspěšně přidán do skladu.'),
                                          backgroundColor: Colors.green),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text('Chyba: $e'),
                                            backgroundColor: Colors.red));
                                  }
                                } finally {
                                  setModalState(() => isSaving = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        child: isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('ULOŽIT DO SKLADU',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Pomocný widget pro textová pole ve vyskakovacím okně
  Widget _buildModalTextField(
      TextEditingController ctrl, String label, IconData icon, bool isDark,
      {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }
}
