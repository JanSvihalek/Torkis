import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'; // Pro skenování čárových kódů
import 'auth_gate.dart';
import 'prubeh.dart'; // Pro proklik do zakázky
import 'fakturace.dart'; // Pro proklik do faktury
import '../core/pdf_generator.dart'; // Pro generování PDF při pultovém prodeji

class SkladPage extends StatefulWidget {
  const SkladPage({super.key});

  @override
  State<SkladPage> createState() => _SkladPageState();
}

class _SkladPageState extends State<SkladPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (globalServisId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text('Skladové hospodářství',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.orange,
            indicatorWeight: 3,
            isScrollable: false, // Pevné ukotvení
            labelPadding: EdgeInsets.zero,
            labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            tabs: [
              Tab(icon: Icon(Icons.inventory_2), text: 'Sklad'),
              Tab(icon: Icon(Icons.add_shopping_cart), text: 'Příjem'),
              Tab(icon: Icon(Icons.point_of_sale), text: 'Prodej'),
              Tab(icon: Icon(Icons.history), text: 'Historie'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _StavSkladuTab(),
            _PrijemSkladuTab(),
            _PultovyProdejTab(),
            _HistorieSkladuTab(),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 1. ZÁLOŽKA: STAV SKLADU (KARTY DÍLŮ)
// ============================================================================
class _StavSkladuTab extends StatefulWidget {
  const _StavSkladuTab();

  @override
  State<_StavSkladuTab> createState() => _StavSkladuTabState();
}

class _StavSkladuTabState extends State<_StavSkladuTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Hledat díl, kód nebo výrobce...',
              prefixIcon: const Icon(Icons.search, color: Colors.orange),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
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
                    child: Text('Nebyly nalezeny žádné skladové karty.',
                        style: TextStyle(color: Colors.grey)));
              }

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
                      onTap: () =>
                          _showEditPartDialog(context, docId, data, isDark),
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

  void _showEditPartDialog(BuildContext context, String docId,
      Map<String, dynamic> existingData, bool isDark) {
    final nazevCtrl = TextEditingController(text: existingData['nazev'] ?? '');
    final kodCtrl = TextEditingController(text: existingData['kod'] ?? '');
    final vyrobceCtrl =
        TextEditingController(text: existingData['vyrobce'] ?? '');
    final nakupCenaCtrl = TextEditingController(
        text: existingData['cena_nakup']?.toString() ?? '');
    final prodejCenaCtrl = TextEditingController(
        text: existingData['cena_prodej']?.toString() ?? '');
    final minStavCtrl = TextEditingController(
        text: existingData['min_stav']?.toString() ?? '0');
    String vybranaJednotka = existingData['jednotka'] ?? 'ks';
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
                    const Text('Úprava karty dílu',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
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
                    Row(
                      children: [
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
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 2,
                          child: _buildModalTextField(minStavCtrl, 'Min. stav',
                              Icons.warning_amber, isDark,
                              isNumber: true),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10, left: 5),
                      child: Text(
                          'Pro úpravu aktuálního množství použijte záložku Příjem nebo Prodej.',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                    const SizedBox(height: 30),
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

                                  Map<String, dynamic> updateData = {
                                    'nazev': nazevCtrl.text.trim(),
                                    'kod': kodCtrl.text.trim(),
                                    'vyrobce': vyrobceCtrl.text.trim(),
                                    'cena_nakup': nakup,
                                    'cena_prodej': prodej,
                                    'jednotka': vybranaJednotka,
                                    'min_stav': minStav,
                                  };

                                  await FirebaseFirestore.instance
                                      .collection('sklad')
                                      .doc(docId)
                                      .update(updateData);

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Díl byl úspěšně upraven.'),
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
                            : const Text('ULOŽIT ZMĚNY',
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

  Widget _buildModalTextField(
      TextEditingController ctrl, String label, IconData icon, bool isDark,
      {bool isNumber = false, bool readOnly = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      readOnly: readOnly,
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

// ============================================================================
// 2. ZÁLOŽKA: PŘÍJEM (NASKLADNĚNÍ A ZAKLÁDÁNÍ SE SKENOVÁNÍM)
// ============================================================================
class _PrijemSkladuTab extends StatefulWidget {
  const _PrijemSkladuTab();

  @override
  State<_PrijemSkladuTab> createState() => _PrijemSkladuTabState();
}

class _PrijemSkladuTabState extends State<_PrijemSkladuTab> {
  String? _vybranyDilId;

  final _nazevCtrl = TextEditingController();
  final _kodCtrl = TextEditingController();
  final _vyrobceCtrl = TextEditingController();
  String _vybranaJednotka = 'ks';
  final _minStavCtrl = TextEditingController(text: '0');

  final _mnozstviCtrl = TextEditingController();
  final _nakupkaCtrl = TextEditingController();
  final _prodejkaCtrl = TextEditingController();
  final _dodavatelCtrl = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nazevCtrl.dispose();
    _kodCtrl.dispose();
    _vyrobceCtrl.dispose();
    _minStavCtrl.dispose();
    _mnozstviCtrl.dispose();
    _nakupkaCtrl.dispose();
    _prodejkaCtrl.dispose();
    _dodavatelCtrl.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nazevCtrl.clear();
    _kodCtrl.clear();
    _vyrobceCtrl.clear();
    _minStavCtrl.text = '0';
    _mnozstviCtrl.clear();
    _nakupkaCtrl.clear();
    _prodejkaCtrl.clear();
    _dodavatelCtrl.clear();
    _vybranaJednotka = 'ks';
  }

  Future<void> _skenovatKod(List<QueryDocumentSnapshot> dily) async {
    try {
      String naskenovanyKod = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Zrušit',
        true,
        ScanMode.BARCODE,
      );

      if (naskenovanyKod != '-1') {
        try {
          final nalezenyDil = dily.firstWhere((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['kod']?.toString() == naskenovanyKod;
          });

          final data = nalezenyDil.data() as Map<String, dynamic>;

          setState(() {
            _vybranyDilId = nalezenyDil.id;
            _nazevCtrl.text = data['nazev'] ?? '';
            _kodCtrl.text = data['kod'] ?? '';
            _vyrobceCtrl.text = data['vyrobce'] ?? '';
            _vybranaJednotka = data['jednotka'] ?? 'ks';
            _minStavCtrl.text = data['min_stav']?.toString() ?? '0';
            _nakupkaCtrl.text = data['cena_nakup']?.toString() ?? '';
            _prodejkaCtrl.text = data['cena_prodej']?.toString() ?? '';
            _mnozstviCtrl.clear();
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Díl nalezen: ${data['nazev']}'),
                  backgroundColor: Colors.green),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Díl s tímto kódem není v databázi. Můžete ho založit.'),
                  backgroundColor: Colors.orange),
            );
            setState(() {
              _vybranyDilId = null;
              _clearForm();
              _kodCtrl.text = naskenovanyKod;
            });
          }
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Chyba skeneru.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Příjem a evidence nového dílu',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
              'Vyberte existující díl z roletky, naskenujte jeho kód, nebo zadejte zcela nový.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('sklad')
                      .where('servis_id', isEqualTo: globalServisId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const CircularProgressIndicator();
                    final dily = snapshot.data!.docs;

                    return Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String?>(
                            decoration: const InputDecoration(
                              labelText: 'Vyberte existující díl ze skladu',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.inventory_2),
                            ),
                            value: _vybranyDilId,
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('➕ PŘIDAT JAKO NOVÝ DÍL',
                                    style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold)),
                              ),
                              ...dily.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return DropdownMenuItem<String?>(
                                  value: doc.id,
                                  child: Text(
                                      '${data['nazev']} (${data['kod'] ?? '-'})'),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _vybranyDilId = val;
                                if (val == null) {
                                  _clearForm();
                                } else {
                                  final selectedDoc =
                                      dily.firstWhere((d) => d.id == val);
                                  final data = selectedDoc.data()
                                      as Map<String, dynamic>;

                                  _nazevCtrl.text = data['nazev'] ?? '';
                                  _kodCtrl.text = data['kod'] ?? '';
                                  _vyrobceCtrl.text = data['vyrobce'] ?? '';
                                  _vybranaJednotka = data['jednotka'] ?? 'ks';
                                  _minStavCtrl.text =
                                      data['min_stav']?.toString() ?? '0';
                                  _nakupkaCtrl.text =
                                      data['cena_nakup']?.toString() ?? '';
                                  _prodejkaCtrl.text =
                                      data['cena_prodej']?.toString() ?? '';
                                  _mnozstviCtrl.clear();
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () => _skenovatKod(dily),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.qr_code_scanner,
                                color: Colors.white, size: 28),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                const Text('Údaje o dílu',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 10),
                _buildInput(
                    controller: _nazevCtrl,
                    label: 'Název dílu *',
                    icon: Icons.build),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                        child: _buildInput(
                            controller: _kodCtrl,
                            label: 'Kód / OEM',
                            icon: Icons.qr_code)),
                    const SizedBox(width: 15),
                    Expanded(
                        child: _buildInput(
                            controller: _vyrobceCtrl,
                            label: 'Výrobce',
                            icon: Icons.precision_manufacturing)),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _vybranaJednotka,
                        decoration: const InputDecoration(
                            labelText: 'Jednotka',
                            border: OutlineInputBorder()),
                        items: ['ks', 'l', 'm', 'bal', 'sada']
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _vybranaJednotka = v!),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 3,
                      child: _buildInput(
                          controller: _minStavCtrl,
                          label: 'Min. stav',
                          icon: Icons.warning_amber,
                          isNumber: true),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                const Text('Naskladnění a ceny',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _buildInput(
                            controller: _nakupkaCtrl,
                            label: 'Nákupní cena',
                            icon: Icons.attach_money,
                            isNumber: true)),
                    const SizedBox(width: 15),
                    Expanded(
                        child: _buildInput(
                            controller: _prodejkaCtrl,
                            label: 'Prodejní cena',
                            icon: Icons.price_check,
                            isNumber: true)),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildInput(
                          controller: _mnozstviCtrl,
                          label: 'Množství k přijetí *',
                          icon: Icons.add_shopping_cart,
                          isNumber: true),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 3,
                      child: _buildInput(
                          controller: _dodavatelCtrl,
                          label: 'Dodavatel / Poznámka',
                          icon: Icons.local_shipping),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _prijmoutNaSklad,
                    icon: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.download),
                    label: Text(_isSaving ? 'ZPRACOVÁVÁM...' : 'NASKLADNIT DÍL',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Future<void> _prijmoutNaSklad() async {
    if (_nazevCtrl.text.trim().isEmpty || _mnozstviCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Název dílu a množství jsou povinné!'),
          backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isSaving = true);
    try {
      double mnozstvi =
          double.tryParse(_mnozstviCtrl.text.replaceAll(',', '.')) ?? 0.0;
      double nakupka =
          double.tryParse(_nakupkaCtrl.text.replaceAll(',', '.')) ?? 0.0;
      double prodejka =
          double.tryParse(_prodejkaCtrl.text.replaceAll(',', '.')) ?? 0.0;
      double minStav =
          double.tryParse(_minStavCtrl.text.replaceAll(',', '.')) ?? 0.0;

      String partIdToLog = '';
      String finalName = _nazevCtrl.text.trim();

      if (_vybranyDilId == null) {
        DocumentReference ref =
            await FirebaseFirestore.instance.collection('sklad').add({
          'servis_id': globalServisId,
          'nazev': finalName,
          'kod': _kodCtrl.text.trim(),
          'vyrobce': _vyrobceCtrl.text.trim(),
          'cena_nakup': nakupka,
          'cena_prodej': prodejka,
          'jednotka': _vybranaJednotka,
          'skladem': mnozstvi,
          'min_stav': minStav,
          'vytvoreno': FieldValue.serverTimestamp(),
        });
        partIdToLog = ref.id;
      } else {
        partIdToLog = _vybranyDilId!;
        await FirebaseFirestore.instance
            .collection('sklad')
            .doc(partIdToLog)
            .update({
          'nazev': finalName,
          'kod': _kodCtrl.text.trim(),
          'vyrobce': _vyrobceCtrl.text.trim(),
          'jednotka': _vybranaJednotka,
          'min_stav': minStav,
          'skladem': FieldValue.increment(mnozstvi),
          'cena_nakup': nakupka,
          'cena_prodej': prodejka,
        });
      }

      if (mnozstvi > 0) {
        await FirebaseFirestore.instance.collection('skladove_pohyby').add({
          'servis_id': globalServisId,
          'sklad_id': partIdToLog,
          'nazev_dilu': finalName,
          'typ_pohybu': 'příjem',
          'mnozstvi': mnozstvi,
          'poznamka': _dodavatelCtrl.text.trim(),
          'cena_nakup': nakupka,
          'datum': FieldValue.serverTimestamp(),
          'uzivatel_id': FirebaseAuth.instance.currentUser?.uid,
        });
      }

      if (mounted) {
        _clearForm();
        setState(() => _vybranyDilId = null);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Naskladnění proběhlo úspěšně.'),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chyba: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isSaving = false);
    }
  }
}

// ============================================================================
// 3. ZÁLOŽKA: PULTOVÝ PRODEJ (KOŠÍK + ZÁKAZNÍK + SKENOVÁNÍ)
// ============================================================================
class _PultovyProdejTab extends StatefulWidget {
  const _PultovyProdejTab();

  @override
  State<_PultovyProdejTab> createState() => _PultovyProdejTabState();
}

class _PultovyProdejTabState extends State<_PultovyProdejTab> {
  Map<String, dynamic>? _vybranyZakaznik;
  final _jmenoCtrl = TextEditingController();
  final _telefonCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _adresaCtrl = TextEditingController();
  final _icoCtrl = TextEditingController();
  final _dicCtrl = TextEditingController();

  String? _vybranyDilId;
  Map<String, dynamic>? _vybranyDilData;
  final _mnozstviCtrl = TextEditingController(text: '1');

  List<Map<String, dynamic>> _kosik = [];
  bool _isSaving = false;
  String _formaUhrady = 'Hotově';

  double get _celkemKosik {
    double sum = 0;
    for (var p in _kosik) {
      sum += (p['mnozstvi'] * p['cena_prodej']);
    }
    return sum;
  }

  @override
  void dispose() {
    _jmenoCtrl.dispose();
    _telefonCtrl.dispose();
    _emailCtrl.dispose();
    _adresaCtrl.dispose();
    _icoCtrl.dispose();
    _dicCtrl.dispose();
    _mnozstviCtrl.dispose();
    super.dispose();
  }

  Future<void> _skenovatKodDoProdeje(List<QueryDocumentSnapshot> dily) async {
    try {
      String naskenovanyKod = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Zrušit',
        true,
        ScanMode.BARCODE,
      );

      if (naskenovanyKod != '-1') {
        try {
          final nalezenyDil = dily.firstWhere((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['kod']?.toString() == naskenovanyKod;
          });

          setState(() {
            _vybranyDilId = nalezenyDil.id;
            _vybranyDilData = nalezenyDil.data() as Map<String, dynamic>;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Připraveno: ${_vybranyDilData!['nazev']}'),
                  backgroundColor: Colors.green),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Díl s tímto kódem nebyl ve skladu nalezen.'),
                  backgroundColor: Colors.red),
            );
          }
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Chyba skeneru.'), backgroundColor: Colors.red));
    }
  }

  void _pridatDoKosiku() {
    if (_vybranyDilId == null || _vybranyDilData == null) return;

    double mnozstvi =
        double.tryParse(_mnozstviCtrl.text.replaceAll(',', '.')) ?? 1.0;
    if (mnozstvi <= 0) return;

    double aktualniStav = (_vybranyDilData!['skladem'] ?? 0).toDouble();
    if (mnozstvi > aktualniStav) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Chyba: Požadované množství ($mnozstvi) převyšuje stav skladu ($aktualniStav).'),
          backgroundColor: Colors.red));
      return;
    }

    setState(() {
      int existujiciIndex =
          _kosik.indexWhere((p) => p['sklad_id'] == _vybranyDilId);
      if (existujiciIndex >= 0) {
        _kosik[existujiciIndex]['mnozstvi'] += mnozstvi;
      } else {
        _kosik.add({
          'sklad_id': _vybranyDilId,
          'nazev': _vybranyDilData!['nazev'],
          'kod': _vybranyDilData!['kod'] ?? '',
          'jednotka': _vybranyDilData!['jednotka'] ?? 'ks',
          'cena_prodej': (_vybranyDilData!['cena_prodej'] ?? 0).toDouble(),
          'mnozstvi': mnozstvi,
        });
      }
      _vybranyDilId = null;
      _vybranyDilData = null;
      _mnozstviCtrl.text = '1';
    });
  }

  void _zobrazitKosik() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
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
                  const Text('Nákupní košík',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _kosik.isEmpty
                        ? const Center(
                            child: Text('Košík je prázdný.',
                                style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: _kosik.length,
                            itemBuilder: (context, index) {
                              final p = _kosik[index];
                              return ListTile(
                                title: Text(p['nazev'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    '${p['mnozstvi']} ${p['jednotka']} x ${p['cena_prodej']} Kč'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red, size: 20),
                                  onPressed: () {
                                    setState(() => _kosik.removeAt(index));
                                    setModalState(() {});
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                  const Divider(height: 30),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Forma úhrady',
                        border: OutlineInputBorder()),
                    value: _formaUhrady,
                    items: ['Hotově', 'Kartou', 'Převodem']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setModalState(() => _formaUhrady = v!),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Celkem k úhradě:',
                          style: TextStyle(fontSize: 16)),
                      Text('${_celkemKosik.toStringAsFixed(2)} Kč',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _kosik.isEmpty || _isSaving
                          ? null
                          : () async {
                              setModalState(() => _isSaving = true);
                              await _dokoncitProdej();
                              if (mounted) Navigator.pop(context);
                            },
                      icon: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.point_of_sale),
                      label: Text(
                          _isSaving ? 'ZPRACOVÁVÁM...' : 'DOKONČIT PRODEJ',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _dokoncitProdej() async {
    setState(() => _isSaving = true);

    try {
      // 1. NAČTENÍ NASTAVENÍ
      final docNast = await FirebaseFirestore.instance
          .collection('nastaveni_servisu')
          .doc(globalServisId)
          .get();
      String sNazev = docNast.data()?['nazev_servisu'] ?? 'Servis';
      String sIco = docNast.data()?['ico_servisu'] ?? '';
      String prefix = docNast.data()?['prefix_faktury'] ?? 'FAK';

      // 2. BEZPEČNÉ GENEROVÁNÍ ČÍSLA PŘES TRANSAKCI (INKREMENT)
      final ted = DateTime.now();
      String datumPart = DateFormat('yyMMdd').format(ted);

      // Vytvoříme počítadlo specifické pro daný den a servis
      final counterRef = FirebaseFirestore.instance
          .collection('citace_faktur')
          .doc('${globalServisId}_$datumPart');

      String cisloFaktury =
          await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(counterRef);
        int currentCount = 1;
        if (snapshot.exists) {
          currentCount = (snapshot.data()?['pocet'] ?? 0) + 1;
        }
        transaction.set(
            counterRef, {'pocet': currentCount}, SetOptions(merge: true));

        // Převede číslo 1 na "0001"
        String sequencePart = currentCount.toString().padLeft(4, '0');
        return '$prefix$datumPart$sequencePart';
      });

      List<Map<String, dynamic>> polozkyProFakturu = [];

      for (var p in _kosik) {
        await FirebaseFirestore.instance
            .collection('sklad')
            .doc(p['sklad_id'])
            .update({
          'skladem': FieldValue.increment(-p['mnozstvi']),
        });

        await FirebaseFirestore.instance.collection('skladove_pohyby').add({
          'servis_id': globalServisId,
          'sklad_id': p['sklad_id'],
          'nazev_dilu': p['nazev'],
          'typ_pohybu': 'výdej',
          'mnozstvi': -p['mnozstvi'],
          'poznamka': 'Pultový prodej',
          'zakazka_id': cisloFaktury,
          'datum': FieldValue.serverTimestamp(),
          'uzivatel_id': FirebaseAuth.instance.currentUser?.uid,
        });

        polozkyProFakturu.add({
          'typ': 'Materiál',
          'cislo': p['kod'],
          'nazev': p['nazev'],
          'mnozstvi': p['mnozstvi'],
          'jednotka': p['jednotka'],
          'cena_s_dph': p['cena_prodej'],
          'sleva': 0.0,
          'sklad_id': p['sklad_id'],
        });
      }

      Map<String, dynamic> finalCustomerData = {
        'id_zakaznika': _vybranyZakaznik?['id_zakaznika'] ?? '',
        'jmeno': _jmenoCtrl.text.trim().isNotEmpty
            ? _jmenoCtrl.text.trim()
            : 'Pultový prodej',
        'telefon': _telefonCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'adresa': _adresaCtrl.text.trim(),
        'ico': _icoCtrl.text.trim(),
        'dic': _dicCtrl.text.trim(),
      };

      Map<String, dynamic> invoiceData = {
        'zakaznik': finalCustomerData,
        'cislo_zakazky': 'PULTOVÝ PRODEJ',
        'spz': '',
        'cas_prijeti': Timestamp.fromDate(ted),
        'splatnost_dny': _formaUhrady == 'Převodem' ? 14 : 0,
        'provedene_prace': [
          {
            'nazev': 'Přímý prodej dílů',
            'cas': Timestamp.fromDate(ted),
            'polozky': polozkyProFakturu,
          }
        ],
      };

      // 3. VYGENERUJEME PDF
      final pdfBytes = await GlobalPdfGenerator.generateDocument(
        data: invoiceData,
        servisNazev: sNazev,
        servisIco: sIco,
        typ: PdfTyp.faktura,
      );

      Reference pdfRef = FirebaseStorage.instance
          .ref()
          .child('servisy/$globalServisId/faktury/$cisloFaktury.pdf');
      await pdfRef.putData(
          pdfBytes, SettableMetadata(contentType: 'application/pdf'));
      String pdfUrl = await pdfRef.getDownloadURL();

      // 4. ULOŽÍME FAKTURU
      await FirebaseFirestore.instance
          .collection('faktury')
          .doc('${globalServisId}_$cisloFaktury')
          .set({
        'servis_id': globalServisId,
        'cislo_faktury': cisloFaktury,
        'cislo_zakazky': 'PULTOVÝ PRODEJ',
        'zakaznik_id': finalCustomerData['id_zakaznika'],
        'zakaznik_jmeno': finalCustomerData['jmeno'],
        'zakaznik': finalCustomerData,
        'datum_vystaveni': Timestamp.fromDate(ted),
        'datum_splatnosti': Timestamp.fromDate(
            ted.add(Duration(days: _formaUhrady == 'Převodem' ? 14 : 0))),
        'forma_uhrady': _formaUhrady,
        'celkova_castka': _celkemKosik,
        'stav_platby': (_formaUhrady == 'Hotově' || _formaUhrady == 'Kartou')
            ? 'Uhrazeno'
            : 'Čeká na platbu',
        'pdf_url': pdfUrl,
        'provedene_prace': invoiceData['provedene_prace'],
        'vytvoreno': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _kosik.clear();
          _jmenoCtrl.clear();
          _telefonCtrl.clear();
          _emailCtrl.clear();
          _adresaCtrl.clear();
          _icoCtrl.clear();
          _dicCtrl.clear();
          _vybranyZakaznik = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Prodej dokončen, faktura vytvořena.'),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Chyba prodeje: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          bottom: 80,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pultový prodej',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Card(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.person, color: Colors.blue),
                            SizedBox(width: 10),
                            Text('Zákazník (nepovinné)',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('zakaznici')
                              .where('servis_id', isEqualTo: globalServisId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return const SizedBox(
                                  height: 50,
                                  child: Center(
                                      child: CircularProgressIndicator()));
                            final zakaznici = snapshot.data!.docs;
                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white10
                                    : Colors.blue.withOpacity(0.05),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none),
                              ),
                              hint: const Text('Vyberte uloženého zákazníka...',
                                  style: TextStyle(color: Colors.blue)),
                              value:
                                  _vybranyZakaznik?['id_zakaznika']?.toString(),
                              items:
                                  zakaznici.map<DropdownMenuItem<String>>((z) {
                                final d = z.data() as Map<String, dynamic>;
                                return DropdownMenuItem<String>(
                                    value: d['id_zakaznika']?.toString(),
                                    child:
                                        Text(d['jmeno']?.toString() ?? '---'));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  final selected = zakaznici.firstWhere((z) =>
                                      (z.data() as Map)['id_zakaznika']
                                          ?.toString() ==
                                      val);
                                  final data =
                                      selected.data() as Map<String, dynamic>;
                                  setState(() {
                                    _vybranyZakaznik = data;
                                    _jmenoCtrl.text =
                                        data['jmeno']?.toString() ?? '';
                                    _telefonCtrl.text =
                                        data['telefon']?.toString() ?? '';
                                    _emailCtrl.text =
                                        data['email']?.toString() ?? '';
                                    _adresaCtrl.text =
                                        data['adresa']?.toString() ?? '';
                                    _icoCtrl.text =
                                        data['ico']?.toString() ?? '';
                                    _dicCtrl.text =
                                        data['dic']?.toString() ?? '';
                                  });
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        _buildInput(
                            controller: _jmenoCtrl,
                            label: 'Jméno a Příjmení / Název firmy',
                            icon: Icons.badge),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                                child: _buildInput(
                                    controller: _telefonCtrl,
                                    label: 'Telefon',
                                    icon: Icons.phone)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _buildInput(
                                    controller: _emailCtrl,
                                    label: 'E-mail',
                                    icon: Icons.email)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildInput(
                            controller: _adresaCtrl,
                            label: 'Adresa',
                            icon: Icons.location_on),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                                child: _buildInput(
                                    controller: _icoCtrl,
                                    label: 'IČO',
                                    icon: Icons.business)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _buildInput(
                                    controller: _dicCtrl,
                                    label: 'DIČ',
                                    icon: Icons.account_balance_wallet)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.inventory_2, color: Colors.orange),
                            SizedBox(width: 10),
                            Text('Výběr dílů z regálu',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('sklad')
                              .where('servis_id', isEqualTo: globalServisId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData)
                              return const CircularProgressIndicator();
                            final dily = snapshot.data!.docs;

                            return Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Vyhledejte díl...',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      prefixIcon: const Icon(Icons.search),
                                    ),
                                    value: _vybranyDilId,
                                    items: dily.map((doc) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      return DropdownMenuItem<String>(
                                        value: doc.id,
                                        child: Text(
                                            '${data['nazev']} (Skladem: ${data['skladem']}) - ${data['cena_prodej']} Kč'),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _vybranyDilId = val;
                                        _vybranyDilData = dily
                                            .firstWhere((d) => d.id == val)
                                            .data() as Map<String, dynamic>;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                InkWell(
                                  onTap: () => _skenovatKodDoProdeje(dily),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.qr_code_scanner,
                                        color: Colors.white, size: 28),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        if (_vybranyDilData != null) ...[
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.blue.withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Název: ${_vybranyDilData!['nazev']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            'Kód/OEM: ${_vybranyDilData!['kod'] ?? '-'}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                            'Dostupné: ${_vybranyDilData!['skladem']} ${_vybranyDilData!['jednotka']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange)),
                                        Text(
                                            'Cena: ${_vybranyDilData!['cena_prodej'] ?? 0} Kč',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildInput(
                                  controller: _mnozstviCtrl,
                                  label: 'Množství',
                                  icon: Icons.format_list_numbered,
                                  isNumber: true),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 55,
                                child: ElevatedButton.icon(
                                  onPressed: _pridatDoKosiku,
                                  icon: const Icon(Icons.add_shopping_cart),
                                  label: const Text('PŘIDAT DO KOŠÍKU',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : Colors.white,
              boxShadow: [
                const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5))
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('V košíku: ${_kosik.length} položek',
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      Text('${_celkemKosik.toStringAsFixed(2)} Kč',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _kosik.isEmpty ? null : _zobrazitKosik,
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: const Text('ZOBRAZIT A DOKONČIT',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInput(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
  }
}

// ============================================================================
// 4. ZÁLOŽKA: HISTORIE POHYBŮ
// ============================================================================
class _HistorieSkladuTab extends StatelessWidget {
  const _HistorieSkladuTab();

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "-";
    DateTime dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  Future<DocumentSnapshot?> _fetchRelatedDoc(String zakazkaId) async {
    if (globalServisId == null) return null;

    var doc = await FirebaseFirestore.instance
        .collection('zakazky')
        .doc('${globalServisId}_$zakazkaId')
        .get();
    if (doc.exists) return doc;

    doc = await FirebaseFirestore.instance
        .collection('faktury')
        .doc('${globalServisId}_$zakazkaId')
        .get();
    if (doc.exists) return doc;

    return null;
  }

  void _showPohybDetail(
      BuildContext context, Map<String, dynamic> data, bool isDark) {
    final isPrijem = data['typ_pohybu'] == 'příjem';
    final color = isPrijem ? Colors.green : Colors.red;
    final znaminko = isPrijem ? '+' : '';
    final zakazkaId = data['zakazka_id']?.toString() ?? '';

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: const EdgeInsets.all(25),
            child: Column(
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
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withOpacity(0.1),
                      child: Icon(
                          isPrijem ? Icons.arrow_downward : Icons.arrow_upward,
                          color: color),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              isPrijem
                                  ? 'Příjemka na sklad'
                                  : 'Výdejka ze skladu',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(_formatDate(data['datum']),
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text('$znaminko${data['mnozstvi']}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            color: color)),
                  ],
                ),
                const SizedBox(height: 30),
                Card(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.grey.withOpacity(0.2))),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildDetailRow(
                            'Název dílu:', data['nazev_dilu'] ?? '-'),
                        const Divider(height: 20),
                        _buildDetailRow(
                            isPrijem ? 'Dodavatel / Pozn.:' : 'Poznámka:',
                            data['poznamka'] ?? '-'),
                        if (isPrijem && data['cena_nakup'] != null) ...[
                          const Divider(height: 20),
                          _buildDetailRow(
                              'Nákupní cena:', '${data['cena_nakup']} Kč / ks'),
                        ],
                      ],
                    ),
                  ),
                ),
                if (zakazkaId.isNotEmpty) ...[
                  const SizedBox(height: 25),
                  const Text('Vazba na doklad',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  FutureBuilder<DocumentSnapshot?>(
                      future: _fetchRelatedDoc(zakazkaId),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator()));
                        }

                        if (!snap.hasData ||
                            snap.data == null ||
                            !snap.data!.exists) {
                          return Card(
                            color: Colors.orange.withOpacity(0.1),
                            elevation: 0,
                            child: ListTile(
                              leading: const Icon(Icons.link_off,
                                  color: Colors.orange),
                              title: const Text('Doklad nenalezen'),
                              subtitle: Text('ID: $zakazkaId'),
                            ),
                          );
                        }

                        final rData = snap.data!.data() as Map<String, dynamic>;
                        final isFaktura =
                            snap.data!.reference.path.contains('faktury');

                        String zakName = '-';
                        if (isFaktura) {
                          zakName = rData['zakaznik_jmeno'] ?? '-';
                        } else {
                          zakName = (rData['zakaznik']
                                  as Map<String, dynamic>?)?['jmeno'] ??
                              '-';
                        }

                        return Card(
                          color: Colors.blue.withOpacity(0.05),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                  color: Colors.blue.withOpacity(0.2))),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              child: Icon(
                                  isFaktura ? Icons.receipt_long : Icons.build),
                            ),
                            title: Text(
                                isFaktura
                                    ? 'Faktura: ${rData['cislo_faktury']}'
                                    : 'Zakázka: ${rData['cislo_zakazky']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                'Zákazník: $zakName\n${rData['spz'] != null && rData['spz'].toString().isNotEmpty ? 'Vozidlo: ${rData['spz']}' : ''}'),
                            isThreeLine: rData['spz'] != null &&
                                rData['spz'].toString().isNotEmpty,
                            trailing: const Icon(Icons.open_in_new,
                                color: Colors.blue),
                            onTap: () {
                              Navigator.pop(context);
                              if (isFaktura) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            FakturaDetailScreen(
                                              fakturaDocId: snap.data!.id,
                                              zakazkaId: rData['cislo_zakazky']
                                                      ?.toString() ??
                                                  '',
                                            )));
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ActiveJobScreen(
                                              documentId: snap.data!.id,
                                              zakazkaId: rData['cislo_zakazky']
                                                      ?.toString() ??
                                                  '',
                                              spz: rData['spz']?.toString() ??
                                                  '',
                                            )));
                              }
                            },
                          ),
                        );
                      }),
                ]
              ],
            ),
          );
        });
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.grey))),
        Expanded(
            flex: 3,
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('skladove_pohyby')
          .where('servis_id', isEqualTo: globalServisId)
          .orderBy('datum', descending: true)
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text('Chyba: ${snapshot.error}'));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
              child: Text('Zatím neevidujeme žádné skladové pohyby.',
                  style: TextStyle(color: Colors.grey)));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final isPrijem = data['typ_pohybu'] == 'příjem';
            final color = isPrijem ? Colors.green : Colors.red;
            final znaminko = isPrijem ? '+' : '';

            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _showPohybDetail(context, data, isDark),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(
                        isPrijem ? Icons.arrow_downward : Icons.arrow_upward,
                        color: color),
                  ),
                  title: Text(data['nazev_dilu'] ?? 'Neznámý díl',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${_formatDate(data['datum'])} | ${data['poznamka'] ?? (data['zakazka_id'] != null ? 'Zakázka ${data['zakazka_id']}' : '-')}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$znaminko${data['mnozstvi']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: color)),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey),
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
