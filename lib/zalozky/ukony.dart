import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_gate.dart'; // Kvůli globalServisId

class UkonyPage extends StatefulWidget {
  const UkonyPage({super.key});

  @override
  State<UkonyPage> createState() => _UkonyPageState();
}

class _UkonyPageState extends State<UkonyPage> {
  final _nazevController = TextEditingController();
  final _cenaController = TextEditingController();
  final _casController = TextEditingController(text: '1.0');

  String _vybranaKategorie = 'Mechanika';
  String _vybranaJednotka = 'hod';
  final List<String> _kategorie = [
    'Mechanika',
    'Pneuservis',
    'Elektrika',
    'Lakovna',
    'Karosárna',
    'Ostatní'
  ];

  bool _isSaving = false;

  Future<void> _pridatUkon() async {
    final nazev = _nazevController.text.trim();
    if (nazev.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Zadejte název úkonu.'),
          backgroundColor: Colors.orange));
      return;
    }

    if (globalServisId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Chyba: Neznámé ID servisu.'),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Převedeme cenu a čas na čísla (pokud je pole prázdné, dáme 0)
      double cena =
          double.tryParse(_cenaController.text.replaceAll(',', '.')) ?? 0.0;
      double cas =
          double.tryParse(_casController.text.replaceAll(',', '.')) ?? 1.0;

      // Zápis nového úkonu do samostatné kolekce
      await FirebaseFirestore.instance.collection('ukony').add({
        'servis_id': globalServisId,
        'nazev': nazev,
        'cena_bez_dph': cena,
        'sazba_dph':
            21, // Výchozí sazba, případně ji můžeš napojit na plátce DPH z nastavení
        'odhadovany_cas': cas,
        'jednotka_casu': _vybranaJednotka,
        'kategorie': _vybranaKategorie,
        'aktivni': true,
        'vytvoreno': FieldValue.serverTimestamp(),
      });

      _nazevController.clear();
      _cenaController.clear();
      _casController.text = '1.0';
      setState(() => _vybranaJednotka = 'hod');
      FocusScope.of(context).unfocus(); // Zavře klávesnici

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Úkon byl úspěšně přidán.'),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Chyba při ukládání: $e'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _editovatUkon(String docId, Map<String, dynamic> data) async {
    final nazevCtrl =
        TextEditingController(text: data['nazev']?.toString() ?? '');
    final cenaCtrl = TextEditingController(
        text: (data['cena_bez_dph'] ?? 0.0).toString());
    final casCtrl = TextEditingController(
        text: (data['odhadovany_cas'] ?? 1.0).toString());
    String jednotka = data['jednotka_casu']?.toString() ?? 'hod';
    String kategorie = data['kategorie']?.toString() ?? 'Mechanika';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const Text('Upravit úkon',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: nazevCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Název úkonu',
                    prefixIcon:
                        const Icon(Icons.build_circle, color: Colors.blue),
                    filled: true,
                    fillColor:
                        isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cenaCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Cena bez DPH (Kč)',
                          prefixIcon: const Icon(Icons.attach_money,
                              color: Colors.green),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF2C2C2C)
                              : Colors.grey[50],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: casCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Čas',
                          prefixIcon: const Icon(Icons.schedule,
                              color: Colors.orange),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF2C2C2C)
                              : Colors.grey[50],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ToggleButtons(
                      isSelected: [
                        jednotka == 'hod',
                        jednotka == 'min'
                      ],
                      onPressed: (i) =>
                          setSheet(() => jednotka = i == 0 ? 'hod' : 'min'),
                      borderRadius: BorderRadius.circular(12),
                      constraints: const BoxConstraints(
                          minWidth: 44, minHeight: 55),
                      children: const [Text('hod'), Text('min')],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  initialValue: kategorie,
                  decoration: InputDecoration(
                    labelText: 'Kategorie',
                    prefixIcon:
                        const Icon(Icons.category, color: Colors.purple),
                    filled: true,
                    fillColor:
                        isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                  ),
                  items: _kategorie
                      .map((k) =>
                          DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (val) =>
                      setSheet(() => kategorie = val!),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () async {
                      final nazev = nazevCtrl.text.trim();
                      if (nazev.isEmpty) return;
                      await FirebaseFirestore.instance
                          .collection('ukony')
                          .doc(docId)
                          .update({
                        'nazev': nazev,
                        'cena_bez_dph': double.tryParse(
                                cenaCtrl.text.replaceAll(',', '.')) ??
                            0.0,
                        'odhadovany_cas': double.tryParse(
                                casCtrl.text.replaceAll(',', '.')) ??
                            1.0,
                        'jednotka_casu': jednotka,
                        'kategorie': kategorie,
                      });
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('ULOŽIT ZMĚNY',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _skrytUkon(String docId) async {
    if (globalServisId == null) return;

    try {
      // Úkon nemažeme úplně, abychom nerozbili historii u starých zakázek
      // Jen ho přepneme jako neaktivní, takže se přestane nabízet v rezervacích
      await FirebaseFirestore.instance
          .collection('ukony')
          .doc(docId)
          .update({'aktivni': false});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Úkon byl skryt.'), backgroundColor: Colors.orange));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Chyba při mazání: $e'),
            backgroundColor: Colors.red));
      }
    }
  }

  @override
  void dispose() {
    _nazevController.dispose();
    _cenaController.dispose();
    _casController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (globalServisId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Katalog úkonů',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text(
                  'Spravujte si seznam úkonů a ceník. Tyto položky se vám budou nabízet pro rychlé přidání při příjmu vozidla.',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 25),

              // --- FORMULÁŘ PRO PŘIDÁNÍ NOVÉHO ÚKONU ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                    ],
                    border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nazevController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Název úkonu (např. Výměna brzd. destiček)',
                        prefixIcon:
                            const Icon(Icons.build_circle, color: Colors.blue),
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cenaController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Cena bez DPH (Kč)',
                              prefixIcon: const Icon(Icons.attach_money,
                                  color: Colors.green),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.grey[50],
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _casController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Čas',
                              prefixIcon: const Icon(Icons.schedule,
                                  color: Colors.orange),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.grey[50],
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ToggleButtons(
                          isSelected: [_vybranaJednotka == 'hod', _vybranaJednotka == 'min'],
                          onPressed: (i) => setState(() => _vybranaJednotka = i == 0 ? 'hod' : 'min'),
                          borderRadius: BorderRadius.circular(12),
                          constraints: const BoxConstraints(minWidth: 44, minHeight: 55),
                          children: const [Text('hod'), Text('min')],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _vybranaKategorie,
                            decoration: InputDecoration(
                              labelText: 'Kategorie',
                              prefixIcon: const Icon(Icons.category,
                                  color: Colors.purple),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.grey[50],
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none),
                            ),
                            items: _kategorie
                                .map((k) =>
                                    DropdownMenuItem(value: k, child: Text(k)))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _vybranaKategorie = val!),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _pridatUkon,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('PŘIDAT',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 10),

        // --- VÝPIS ULOŽENÝCH ÚKONŮ Z KOLEKCE 'ukony' ---
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('ukony')
                .where('servis_id', isEqualTo: globalServisId)
                .where('aktivni', isEqualTo: true) // Zobrazujeme jen ty aktivní
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Center(child: Text("Chyba: ${snapshot.error}"));
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());

              final ukonyDocs = snapshot.data?.docs ?? [];

              if (ukonyDocs.isEmpty) {
                return const Center(
                    child: Text('Zatím nemáte v katalogu žádné úkony.'));
              }

              // Seřadíme úkony lokálně podle abecedy
              ukonyDocs.sort((a, b) {
                String nazevA =
                    (a.data() as Map<String, dynamic>)['nazev']?.toString() ??
                        '';
                String nazevB =
                    (b.data() as Map<String, dynamic>)['nazev']?.toString() ??
                        '';
                return nazevA.compareTo(nazevB);
              });

              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                itemCount: ukonyDocs.length,
                itemBuilder: (context, index) {
                  final doc = ukonyDocs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  final nazev = data['nazev'] ?? 'Neznámý úkon';
                  final cena = data['cena_bez_dph'] ?? 0.0;
                  final cas = data['odhadovany_cas'] ?? 1.0;
                  final kategorie = data['kategorie'] ?? 'Ostatní';

                  return Card(
                    elevation: 0,
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                            color: isDark
                                ? Colors.grey[800]!
                                : Colors.grey[200]!)),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: const Icon(Icons.build,
                            color: Colors.blue, size: 20),
                      ),
                      title: Text(nazev,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.category,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(kategorie,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12)),
                            const SizedBox(width: 15),
                            Icon(Icons.schedule,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('$cas h',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12)),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$cena Kč',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: Colors.blue),
                            onPressed: () => _editovatUkon(doc.id, data),
                            tooltip: 'Upravit úkon',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () => _skrytUkon(doc.id),
                            tooltip: 'Odebrat úkon',
                          ),
                        ],
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
