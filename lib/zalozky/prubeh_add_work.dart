import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'auth_gate.dart';

class PolozkaInput {
  String typ = 'Materiál';
  final cislo = TextEditingController();
  final nazev = TextEditingController();
  final mnozstvi = TextEditingController(text: '1');
  String jednotka = 'ks';
  final cenaBezDph = TextEditingController(text: '0');
  final cenaSDph = TextEditingController(text: '0');
  final sleva = TextEditingController(text: '0');

  // ID skladu pro novou položku (bude dekrementována při uložení, pak nulována)
  String? skladDocId;
  // ID skladu pro existující položku (načtena z Firestore – nikdy nulována)
  String? existingSkladId;

  void dispose() {
    cislo.dispose();
    nazev.dispose();
    mnozstvi.dispose();
    cenaBezDph.dispose();
    cenaSDph.dispose();
    sleva.dispose();
  }
}

// Obrazovka pro záznam provedené práce.
// Obsahuje: název úkonu, volitelné položky (materiál/práce s cenou a DPH),
// přidání fotek z galerie/fotoaparátu a pole pro počet hodin.
// Lze použít jak pro nový záznam, tak pro editaci existujícího (editIndex != null).
class AddWorkScreen extends StatefulWidget {
  final String documentId;
  final String zakazkaId;
  final String? initialTitle;
  final Map<String, dynamic>? existingWork;
  final int? editIndex;

  const AddWorkScreen({
    super.key,
    required this.documentId,
    required this.zakazkaId,
    this.initialTitle,
    this.existingWork,
    this.editIndex,
  });

  @override
  State<AddWorkScreen> createState() => _AddWorkScreenState();
}

class _AddWorkScreenState extends State<AddWorkScreen> {
  final _nazevController = TextEditingController();
  final _popisController = TextEditingController();

  final List<PolozkaInput> _polozkyInputs = [];
  final List<XFile> _workImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isSaving = false;
  double _hodinovaSazba = 0.0;
  bool _jePlatceDph = false;
  double _celkovaCenaSDph = 0.0;

  @override
  void initState() {
    super.initState();
    _nactiHodinovouSazbu();

    if (widget.initialTitle != null) {
      _nazevController.text = widget.initialTitle!;
    }

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
          final skolSkladId = p['sklad_id']?.toString() ?? '';
          if (skolSkladId.isNotEmpty) input.existingSkladId = skolSkladId;

          String slevaVal = (p['sleva'] ?? 0.0).toString();
          input.sleva.text = slevaVal.endsWith('.0')
              ? slevaVal.replaceAll('.0', '')
              : slevaVal;

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
    if (globalServisId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('nastaveni_servisu')
          .doc(globalServisId)
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
      double sleva = double.tryParse(p.sleva.text.replaceAll(',', '.')) ?? 0.0;

      celkem += (pocet * cenaKs) * (1 - (sleva / 100));
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

  Future<void> _takePhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    if (photo != null) setState(() => _workImages.add(photo));
  }

  Future<void> _pickFromGallery() async {
    final photos = await _picker.pickMultiImage(
      imageQuality: 60,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    if (photos.isNotEmpty) setState(() => _workImages.addAll(photos));
  }

  void _vybratDilZeSkladu(BuildContext context, bool isDark) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 20),
              const Text('Vybrat díl ze skladu',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('sklad')
                          .where('servis_id', isEqualTo: globalServisId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return const Center(
                              child: CircularProgressIndicator());
                        final docs = snapshot.data!.docs;

                        if (docs.isEmpty) {
                          return const Center(
                            child: Text('Váš sklad je zatím prázdný.',
                                style: TextStyle(color: Colors.grey)),
                          );
                        }

                        return ListView.separated(
                            itemCount: docs.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final data =
                                  docs[index].data() as Map<String, dynamic>;
                              final docId = docs[index].id;
                              final stav = (data['skladem'] ?? 0.0) as double;

                              return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Colors.orange.withOpacity(0.1),
                                    child: const Icon(Icons.inventory_2,
                                        color: Colors.orange),
                                  ),
                                  title: Text(data['nazev'] ?? 'Bez názvu',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      'Skladem: $stav ${data['jednotka'] ?? 'ks'} • Kód: ${data['kod'] ?? '-'}'),
                                  trailing: Text(
                                      '${data['cena_prodej'] ?? 0} Kč',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  onTap: () {
                                    setState(() {
                                      final p = PolozkaInput();
                                      p.typ = 'Materiál';
                                      p.nazev.text = data['nazev'] ?? '';
                                      p.cislo.text = data['kod'] ?? '';
                                      p.jednotka = data['jednotka'] ?? 'ks';
                                      p.cenaSDph.text =
                                          (data['cena_prodej'] ?? 0.0)
                                              .toStringAsFixed(2);
                                      p.skladDocId = docId;

                                      if (_polozkyInputs.length == 1 &&
                                          _polozkyInputs[0]
                                              .nazev
                                              .text
                                              .isEmpty) {
                                        _polozkyInputs[0] = p;
                                      } else {
                                        _polozkyInputs.add(p);
                                      }
                                      _prepocitatCelkem();
                                    });
                                    Navigator.pop(context);
                                  });
                            });
                      }))
            ])));
  }

  void _vybratUkonZKatalogu(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            const Text('Katalog úkonů', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ukony')
                    .where('servis_id', isEqualTo: globalServisId)
                    .where('aktivni', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text('Váš katalog úkonů je zatím prázdný.', style: TextStyle(color: Colors.grey)));
                  }

                  var listDocs = docs.toList();
                  listDocs.sort((a, b) => (a['nazev'] ?? '').toString().compareTo((b['nazev'] ?? '').toString()));

                  return ListView.separated(
                    itemCount: listDocs.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final data = listDocs[index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child: const Icon(Icons.build, color: Colors.blue),
                        ),
                        title: Text(data['nazev'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Čas: ${data['odhadovany_cas'] ?? 1} h • Kategorie: ${data['kategorie'] ?? 'Ostatní'}'),
                        trailing: Text('${data['cena_bez_dph'] ?? 0} Kč', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                        onTap: () {
                          setState(() {
                            _nazevController.text = data['nazev'] ?? '';

                            PolozkaInput p;
                            if (_polozkyInputs.length == 1 && _polozkyInputs[0].nazev.text.isEmpty) {
                              p = _polozkyInputs[0];
                            } else {
                              p = PolozkaInput();
                              _polozkyInputs.add(p);
                            }

                            p.typ = 'Práce';
                            p.nazev.text = data['nazev'] ?? '';
                            p.mnozstvi.text = (data['odhadovany_cas'] ?? 1.0).toString();
                            p.jednotka = 'h';

                            double bezDph = (data['cena_bez_dph'] ?? 0.0).toDouble();
                            p.cenaBezDph.text = bezDph.toStringAsFixed(2);

                            double sDph = _jePlatceDph ? (bezDph * 1.21) : bezDph;
                            p.cenaSDph.text = sDph.toStringAsFixed(2);

                            _prepocitatCelkem();
                          });
                          Navigator.pop(context);
                        },
                      );
                    }
                  );
                }
              )
            )
          ]
        )
      )
    );
  }

  Future<void> _saveWork() async {
    if (_nazevController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Zadejte alespoň hlavičku (Název skupiny).'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (globalServisId == null) return;
      List<String> uploadedUrls = [];

      for (int i = 0; i < _workImages.length; i++) {
        String fileName =
            'prace_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        Reference ref = FirebaseStorage.instance.ref().child(
            'servisy/$globalServisId/zakazky/${widget.zakazkaId}/$fileName');
        await ref.putData(await _workImages[i].readAsBytes());
        uploadedUrls.add(await ref.getDownloadURL());
      }

      // Mapa se sestaví PŘED dekrementací — sklad_id musí být v dokumentu uložen,
      // aby ho bylo možné použít při pozdějším mazání nebo stornu zakázky.
      List<Map<String, dynamic>> zpracovanePolozky = _polozkyInputs
          .map((p) {
            final m = <String, dynamic>{
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
              'sleva':
                  double.tryParse(p.sleva.text.replaceAll(',', '.')) ?? 0.0,
            };
            final effectiveSkladId = p.existingSkladId ?? p.skladDocId;
            if (effectiveSkladId != null) m['sklad_id'] = effectiveSkladId;
            return m;
          })
          .where((d) => d['nazev'].toString().isNotEmpty)
          .toList();

      // Dekrement skladu pro nově přidané položky (existingSkladId = null → nové)
      for (var p in _polozkyInputs) {
        if (p.skladDocId != null) {
          double qty =
              double.tryParse(p.mnozstvi.text.replaceAll(',', '.')) ?? 0.0;
          if (qty > 0) {
            await FirebaseFirestore.instance
                .collection('sklad')
                .doc(p.skladDocId)
                .update({
              'skladem': FieldValue.increment(-qty),
            });
            await FirebaseFirestore.instance.collection('skladove_pohyby').add({
              'servis_id': globalServisId,
              'sklad_id': p.skladDocId,
              'nazev_dilu': p.nazev.text.trim(),
              'typ_pohybu': 'výdej',
              'mnozstvi': -qty,
              'zakazka_id': widget.zakazkaId,
              'datum': FieldValue.serverTimestamp(),
              'uzivatel_id': FirebaseAuth.instance.currentUser?.uid,
            });
            p.skladDocId = null;
          }
        }
      }

      List<String> finalFotky = [];
      if (widget.existingWork != null) {
        finalFotky.addAll(
            List<String>.from(widget.existingWork!['fotografie_urls'] ?? []));
      }
      finalFotky.addAll(uploadedUrls);

      Map<String, dynamic> novyUkon = {
        'nazev': _nazevController.text.trim(),
        'popis': _popisController.text.trim(),
        'polozky': zpracovanePolozky,
        'cas': widget.existingWork?['cas'] ?? Timestamp.now(),
        'fotografie_urls': finalFotky,
      };

      if (widget.editIndex != null) {
        final doc = await FirebaseFirestore.instance
            .collection('zakazky')
            .doc(widget.documentId)
            .get();
        List<dynamic> prace = List.from(doc.data()?['provedene_prace'] ?? []);
        if (widget.editIndex! >= 0 && widget.editIndex! < prace.length) {
          prace[widget.editIndex!] = novyUkon;
          await FirebaseFirestore.instance
              .collection('zakazky')
              .doc(widget.documentId)
              .update({'provedene_prace': prace});
        }
      } else {
        final doc = await FirebaseFirestore.instance
            .collection('zakazky')
            .doc(widget.documentId)
            .get();
        final List<dynamic> prace =
            List.from(doc.data()?['provedene_prace'] ?? []);
        prace.add(novyUkon);

        final Map<String, dynamic> updates = {
          'provedene_prace': prace,
        };

        if (widget.initialTitle != null) {
          updates['pozadavky_zakaznika'] =
              FieldValue.arrayRemove([widget.initialTitle]);
        }

        await FirebaseFirestore.instance
            .collection('zakazky')
            .doc(widget.documentId)
            .update(updates);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Chyba: $e')));
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isMechanik = globalUserRole == 'mechanik';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.existingWork != null ? 'Úprava úkonu' : 'Nový úkon'),
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
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.folder, color: Colors.blue),
                              SizedBox(width: 10),
                              Text('Hlavička (Skupina)',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(_nazevController,
                              'Název úkonu (např. Servis brzd) *', isDark,
                              isBold: true),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: () => _vybratUkonZKatalogu(context, isDark),
                            icon: const Icon(Icons.menu_book),
                            label: const Text('Vybrat úkon z katalogu', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: TextButton.styleFrom(foregroundColor: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Card(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.format_list_bulleted,
                                  color: Colors.orange),
                              SizedBox(width: 10),
                              Text('Položky dokladu',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          ...List.generate(_polozkyInputs.length, (index) {
                            final polozka = _polozkyInputs[index];
                            double dPocet = double.tryParse(polozka
                                    .mnozstvi.text
                                    .replaceAll(',', '.')) ??
                                0.0;
                            double dCena = double.tryParse(polozka.cenaSDph.text
                                    .replaceAll(',', '.')) ??
                                0.0;
                            double dSleva = double.tryParse(
                                    polozka.sleva.text.replaceAll(',', '.')) ??
                                0.0;
                            double rCelkem =
                                (dPocet * dCena) * (1 - (dSleva / 100));

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
                                                  : Colors.black),
                                          items: ['Práce', 'Materiál']
                                              .map((t) => DropdownMenuItem(
                                                  value: t,
                                                  child: Text(t,
                                                      style: const TextStyle(
                                                          fontSize: 12))))
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                polozka.typ = val;
                                                if (val == 'Práce') {
                                                  polozka.jednotka = 'h';
                                                  if (polozka.nazev.text
                                                      .trim()
                                                      .isEmpty) {
                                                    polozka.nazev.text =
                                                        'Práce mechanika';
                                                  }
                                                  if (_hodinovaSazba > 0) {
                                                    polozka.cenaBezDph.text =
                                                        _hodinovaSazba
                                                            .toStringAsFixed(2);
                                                    _prepocitatDphPolozky(
                                                        polozka,
                                                        polozka
                                                            .cenaBezDph.text);
                                                  }
                                                }
                                                if (val == 'Materiál')
                                                  polozka.jednotka = 'ks';
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Typ',
                                            labelStyle:
                                                const TextStyle(fontSize: 12),
                                            filled: true,
                                            fillColor: isDark
                                                ? const Color(0xFF1E1E1E)
                                                : Colors.white,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 10),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 4,
                                        child: _buildTextField(
                                            polozka.cislo, 'Číslo dílu', isDark,
                                            compact: true),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red, size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () async {
                                          // Pokud položka pochází ze skladu (existingSkladId),
                                          // vrátíme ji zpět před odstraněním.
                                          final retSkladId = polozka.existingSkladId;
                                          if (retSkladId != null) {
                                            final qty = double.tryParse(
                                                    polozka.mnozstvi.text.replaceAll(',', '.')) ??
                                                0.0;
                                            if (qty > 0) {
                                              await FirebaseFirestore.instance
                                                  .collection('sklad')
                                                  .doc(retSkladId)
                                                  .update({'skladem': FieldValue.increment(qty)});
                                              await FirebaseFirestore.instance
                                                  .collection('skladove_pohyby')
                                                  .add({
                                                'servis_id': globalServisId,
                                                'sklad_id': retSkladId,
                                                'nazev_dilu': polozka.nazev.text.trim(),
                                                'typ_pohybu': 'příjem',
                                                'mnozstvi': qty,
                                                'poznamka': 'Odebrání položky z úkonu v zakázce ${widget.zakazkaId}',
                                                'zakazka_id': widget.zakazkaId,
                                                'datum': FieldValue.serverTimestamp(),
                                                'uzivatel_id': FirebaseAuth.instance.currentUser?.uid,
                                              });
                                            }
                                          }
                                          if (mounted) {
                                            setState(() {
                                              polozka.dispose();
                                              _polozkyInputs.removeAt(index);
                                              _prepocitatCelkem();
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                      polozka.nazev, 'Název položky', isDark,
                                      compact: true),
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
                                      const SizedBox(width: 4),
                                      Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField<String>(
                                          value: polozka.jednotka,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black),
                                          items: [
                                            'ks',
                                            'h',
                                            'min',
                                            'l',
                                            'm',
                                            'bal',
                                            'sada',
                                            'úkon'
                                          ]
                                              .map((j) => DropdownMenuItem(
                                                  value: j,
                                                  child: Text(j,
                                                      style: const TextStyle(
                                                          fontSize: 12))))
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null)
                                              setState(
                                                  () => polozka.jednotka = val);
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Jedn.',
                                            labelStyle:
                                                const TextStyle(fontSize: 12),
                                            filled: true,
                                            fillColor: isDark
                                                ? const Color(0xFF1E1E1E)
                                                : Colors.white,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 10),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        flex: 2,
                                        child: _buildTextField(
                                          polozka.sleva,
                                          'Sleva %',
                                          isDark,
                                          isNumber: true,
                                          compact: true,
                                          onChanged: (v) => _prepocitatCelkem(),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      if (!isMechanik)
                                        Expanded(
                                          flex: 3,
                                          child: _buildTextField(
                                            polozka.cenaBezDph,
                                            _jePlatceDph ? 'Bez DPH' : 'Cena',
                                            isDark,
                                            isNumber: true,
                                            compact: true,
                                            onChanged: (v) =>
                                                _prepocitatDphPolozky(
                                                    polozka, v),
                                          ),
                                        ),
                                      const SizedBox(width: 4),
                                      if (!isMechanik)
                                        Expanded(
                                          flex: 3,
                                          child: _buildTextField(
                                            polozka.cenaSDph,
                                            _jePlatceDph ? 'S DPH' : 'Konečná',
                                            isDark,
                                            isNumber: true,
                                            compact: true,
                                            onChanged: (v) =>
                                                _prepocitatCelkem(),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  if (!isMechanik)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Text('Celkem za položku: ',
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 12)),
                                          Text(
                                              '${rCelkem.toStringAsFixed(2)} Kč',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                  fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              TextButton.icon(
                                onPressed: () => setState(
                                    () => _polozkyInputs.add(PolozkaInput())),
                                icon: const Icon(Icons.add),
                                label: const Text('Přidat ručně'),
                              ),
                              TextButton.icon(
                                onPressed: () => _vybratUkonZKatalogu(context, isDark),
                                icon: const Icon(Icons.menu_book, color: Colors.blue),
                                label: const Text('Katalog úkonů', style: TextStyle(color: Colors.blue)),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () =>
                                    _vybratDilZeSkladu(context, isDark),
                                icon: const Icon(Icons.inventory_2,
                                    color: Colors.orange),
                                label: const Text('Sklad',
                                    style: TextStyle(color: Colors.orange)),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Colors.orange.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Card(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.more_horiz, color: Colors.purple),
                              SizedBox(width: 10),
                              Text('Doplňující informace',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(_popisController,
                              'Interní poznámka k úkonu', isDark,
                              maxLines: 2),
                          const SizedBox(height: 20),
                          const Text('Fotodokumentace úkonu:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 80,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: _takePhoto,
                                  child: Container(
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.blue),
                                    ),
                                    child: const Icon(Icons.add_a_photo,
                                        color: Colors.blue),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: _pickFromGallery,
                                  child: Container(
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border:
                                          Border.all(color: Colors.blueGrey),
                                    ),
                                    child: const Icon(Icons.photo_library,
                                        color: Colors.blueGrey),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _workImages.length,
                                    itemBuilder: (c, i) => Stack(
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: kIsWeb
                                                ? Image.network(
                                                    _workImages[i].path,
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover)
                                                : Image.file(
                                                    File(_workImages[i].path),
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover),
                                          ),
                                        ),
                                        Positioned(
                                          top: 2,
                                          right: 12,
                                          child: GestureDetector(
                                            onTap: () => setState(
                                                () => _workImages.removeAt(i)),
                                            child: const CircleAvatar(
                                                radius: 10,
                                                backgroundColor: Colors.white,
                                                child: Icon(Icons.close,
                                                    size: 12,
                                                    color: Colors.red)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (!isMechanik)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Celkem za položku',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          Text('${_celkovaCenaSDph.toStringAsFixed(2)} Kč',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        ],
                      ),
                    ),
                  if (isMechanik) const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveWork,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check),
                    label: Text(_isSaving ? 'UKLÁDÁM...' : 'ULOŽIT ÚKON',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
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
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, bool isDark,
      {bool isNumber = false,
      bool isBold = false,
      bool compact = false,
      int maxLines = 1,
      Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: compact ? 12 : (isBold ? 16 : 14)),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(fontSize: compact ? 12 : 14),
        filled: true,
        fillColor: isDark
            ? (compact ? const Color(0xFF1E1E1E) : const Color(0xFF2C2C2C))
            : Colors.white,
        contentPadding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 15, vertical: compact ? 10 : 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
