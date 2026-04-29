import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/pdf_generator.dart';
import '../auth_gate.dart';
import 'faktura_edit_polozky.dart';

class ManualInvoiceScreen extends StatefulWidget {
  const ManualInvoiceScreen({super.key});

  @override
  State<ManualInvoiceScreen> createState() => _ManualInvoiceScreenState();
}

class _ManualInvoiceScreenState extends State<ManualInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

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
    if (globalServisId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('nastaveni_servisu')
          .doc(globalServisId)
          .get();
      if (doc.exists) {
        setState(() {
          _splatnostDny = doc.data()?['splatnost_dny'] ?? 14;
          _jePlatceDph = doc.data()?['platce_dph'] ?? false;
          _hodinovaSazba =
              (doc.data()?['hodinova_sazba'] ?? 0.0).toDouble();
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
      double sleva =
          double.tryParse(p.sleva.text.replaceAll(',', '.')) ?? 0.0;
      celkem += (pocet * cenaKs) * (1 - (sleva / 100));
    }
    setState(() => _celkovaCenaSDph = celkem);
  }

  void _prepocitatDphPolozky(PolozkaInput p, String bezDphText) {
    double bezDph =
        double.tryParse(bezDphText.replaceAll(',', '.')) ?? 0.0;
    double sDph = _jePlatceDph ? (bezDph * 1.21) : bezDph;
    p.cenaSDph.text = sDph.toStringAsFixed(2);
    _prepocitatCelkem();
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
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 20),
            const Text('Vybrat díl ze skladu',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('sklad')
                    .where('servis_id', isEqualTo: globalServisId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
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
                      final stav =
                          (data['skladem'] ?? 0.0) as double;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Colors.orange.withValues(alpha: 0.1),
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
                                _polozkyInputs[0].nazev.text.isEmpty) {
                              _polozkyInputs[0] = p;
                            } else {
                              _polozkyInputs.add(p);
                            }
                            _prepocitatCelkem();
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _ulozitFakturu() async {
    if (_jmenoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Zadejte prosím jméno nebo název zákazníka.')));
      return;
    }

    bool maChybu = false;
    for (var p in _polozkyInputs) {
      if (p.nazev.text.trim().isEmpty) {
        maChybu = true;
        break;
      }
    }
    if (maChybu) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Vyplňte názvy u všech položek.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (globalServisId == null) return;

      for (var p in _polozkyInputs) {
        if (p.skladDocId != null) {
          double qty =
              double.tryParse(p.mnozstvi.text.replaceAll(',', '.')) ??
                  0.0;
          if (qty > 0) {
            await FirebaseFirestore.instance
                .collection('sklad')
                .doc(p.skladDocId)
                .update({'skladem': FieldValue.increment(-qty)});
          }
        }
      }

      final ted = DateTime.now();
      final splatnost = ted.add(Duration(days: _splatnostDny));

      Map<String, dynamic> finalCustomerData = {
        'id_zakaznika': _vybranyZakaznik?['id_zakaznika'] ?? '',
        'jmeno': _jmenoController.text.trim(),
        'telefon': _telefonController.text.trim(),
        'email': _emailController.text.trim(),
        'adresa': _adresaController.text.trim(),
        'ico': _icoController.text.trim(),
        'dic': _dicController.text.trim(),
      };

      List<Map<String, dynamic>> zpracovanePolozky = _polozkyInputs
          .map((p) => {
                'typ': p.typ,
                'cislo': p.cislo.text.trim(),
                'nazev': p.nazev.text.trim(),
                'mnozstvi': double.tryParse(
                        p.mnozstvi.text.replaceAll(',', '.')) ??
                    1.0,
                'jednotka': p.jednotka,
                'cena_bez_dph': double.tryParse(
                        p.cenaBezDph.text.replaceAll(',', '.')) ??
                    0.0,
                'cena_s_dph': double.tryParse(
                        p.cenaSDph.text.replaceAll(',', '.')) ??
                    0.0,
                'sleva': double.tryParse(
                        p.sleva.text.replaceAll(',', '.')) ??
                    0.0,
                'sklad_id': p.skladDocId,
              })
          .where((d) => d['nazev'].toString().isNotEmpty)
          .toList();

      final docNast = await FirebaseFirestore.instance
          .collection('nastaveni_servisu')
          .doc(globalServisId)
          .get();
      String prefix = docNast.data()?['prefix_faktury'] ?? 'FAK';

      String datumPart = DateFormat('yyMMdd').format(ted);
      final counterRef = FirebaseFirestore.instance
          .collection('citace_faktur')
          .doc('${globalServisId}_$datumPart');

      String cisloFaktury = await FirebaseFirestore.instance
          .runTransaction((transaction) async {
        final snapshot = await transaction.get(counterRef);
        int currentCount = 1;
        if (snapshot.exists) {
          currentCount = (snapshot.data()?['pocet'] ?? 0) + 1;
        }
        transaction.set(
            counterRef, {'pocet': currentCount}, SetOptions(merge: true));
        String sequencePart =
            currentCount.toString().padLeft(4, '0');
        return '$prefix$datumPart$sequencePart';
      });

      for (var p in _polozkyInputs) {
        if (p.skladDocId != null) {
          double qty =
              double.tryParse(p.mnozstvi.text.replaceAll(',', '.')) ??
                  0.0;
          if (qty > 0) {
            await FirebaseFirestore.instance
                .collection('skladove_pohyby')
                .add({
              'servis_id': globalServisId,
              'sklad_id': p.skladDocId,
              'nazev_dilu': p.nazev.text.trim(),
              'typ_pohybu': 'výdej',
              'mnozstvi': -qty,
              'zakazka_id': cisloFaktury,
              'poznamka': 'Manuální faktura',
              'datum': FieldValue.serverTimestamp(),
              'uzivatel_id': FirebaseAuth.instance.currentUser?.uid,
            });
          }
        }
      }

      Map<String, dynamic> invoiceData = {
        'zakaznik': finalCustomerData,
        'cislo_zakazky': 'PRODEJ',
        'cislo_faktury': cisloFaktury,
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

      String sNazev = docNast.data()?['nazev_servisu'] ?? 'Servis';
      String sIco = docNast.data()?['ico_servisu'] ?? '';

      final pdfBytes = await GlobalPdfGenerator.generateDocument(
        data: invoiceData,
        servisNazev: sNazev,
        servisIco: sIco,
        typ: PdfTyp.faktura,
      );

      Reference pdfRef = FirebaseStorage.instance
          .ref()
          .child(
              'servisy/$globalServisId/faktury/$cisloFaktury.pdf');
      await pdfRef.putData(
          pdfBytes, SettableMetadata(contentType: 'application/pdf'));
      String pdfUrl = await pdfRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('faktury')
          .doc('${globalServisId}_$cisloFaktury')
          .set({
        'servis_id': globalServisId,
        'cislo_faktury': cisloFaktury,
        'zakaznik_id': finalCustomerData['id_zakaznika'],
        'zakaznik_jmeno': finalCustomerData['jmeno'],
        'zakaznik': finalCustomerData,
        'cislo_zakazky': 'PRODEJ',
        'datum_vystaveni': Timestamp.fromDate(ted),
        'datum_splatnosti': Timestamp.fromDate(splatnost),
        'forma_uhrady': _formaUhrady,
        'celkova_castka': _celkovaCenaSDph,
        'stav_platby':
            (_formaUhrady == 'Hotově' || _formaUhrady == 'Kartou')
                ? 'Uhrazeno'
                : 'Čeká na platbu',
        'pdf_url': pdfUrl,
        'provedene_prace': invoiceData['provedene_prace'],
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
              const Text('Zákazník (Odběratel)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('zakaznici')
                    .where('servis_id', isEqualTo: globalServisId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                        height: 50,
                        child:
                            Center(child: CircularProgressIndicator()));
                  }
                  final zakaznici = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark
                          ? Colors.white10
                          : Colors.blue.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.blue
                                  .withValues(alpha: 0.3))),
                    ),
                    hint: const Text(
                        'Vyberte uloženého zákazníka (nepovinné)',
                        style: TextStyle(color: Colors.blue)),
                    value: _vybranyZakaznik?['id_zakaznika']
                        ?.toString(),
                    items: zakaznici
                        .map<DropdownMenuItem<String>>((z) {
                      final d = z.data() as Map<String, dynamic>;
                      return DropdownMenuItem<String>(
                          value: d['id_zakaznika']?.toString(),
                          child: Text(
                              d['jmeno']?.toString() ?? '---'));
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
                          _jmenoController.text =
                              data['jmeno']?.toString() ?? '';
                          _telefonController.text =
                              data['telefon']?.toString() ?? '';
                          _emailController.text =
                              data['email']?.toString() ?? '';
                          _adresaController.text =
                              data['adresa']?.toString() ?? '';
                          _icoController.text =
                              data['ico']?.toString() ?? '';
                          _dicController.text =
                              data['dic']?.toString() ?? '';
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
                    side: BorderSide(
                        color:
                            Colors.grey.withValues(alpha: 0.2))),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _jmenoController,
                        decoration: const InputDecoration(
                            labelText:
                                'Jméno a Příjmení / Název firmy *'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _telefonController,
                              decoration: const InputDecoration(
                                  labelText: 'Telefon'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                  labelText: 'E-mail'),
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
                              decoration: const InputDecoration(
                                  labelText: 'IČO'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _dicController,
                              decoration: const InputDecoration(
                                  labelText: 'DIČ'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Položky dokladu',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              ...List.generate(_polozkyInputs.length, (index) {
                final polozka = _polozkyInputs[index];
                double dPocet = double.tryParse(
                        polozka.mnozstvi.text.replaceAll(',', '.')) ??
                    0.0;
                double dCena = double.tryParse(
                        polozka.cenaSDph.text.replaceAll(',', '.')) ??
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
                    border: Border.all(
                        color:
                            Colors.grey.withValues(alpha: 0.2)),
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
                                      if (_hodinovaSazba > 0) {
                                        polozka.cenaBezDph.text =
                                            _hodinovaSazba
                                                .toStringAsFixed(2);
                                        _prepocitatDphPolozky(polozka,
                                            polozka.cenaBezDph.text);
                                      }
                                    }
                                    if (val == 'Materiál') {
                                      polozka.jednotka = 'ks';
                                    }
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
                                        horizontal: 10, vertical: 10),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: _buildTextField(polozka.cislo,
                                'Číslo dílu', isDark,
                                compact: true),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 20),
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
                      _buildTextField(polozka.nazev, 'Název položky *',
                          isDark, compact: true),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                                polozka.mnozstvi, 'Mn.', isDark,
                                isNumber: true,
                                compact: true,
                                onChanged: (v) =>
                                    _prepocitatCelkem()),
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
                                if (val != null) {
                                  setState(
                                      () => polozka.jednotka = val);
                                }
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
                                        horizontal: 8, vertical: 10),
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
                                polozka.sleva, 'Sleva %', isDark,
                                isNumber: true,
                                compact: true,
                                onChanged: (v) =>
                                    _prepocitatCelkem()),
                          ),
                          const SizedBox(width: 4),
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
                                        polozka, v)),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            flex: 3,
                            child: _buildTextField(
                                polozka.cenaSDph,
                                _jePlatceDph ? 'S DPH' : 'Konečná',
                                isDark,
                                isNumber: true,
                                compact: true,
                                onChanged: (v) =>
                                    _prepocitatCelkem()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color:
                              Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Celkem za položku: ',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12)),
                            Text('${rCelkem.toStringAsFixed(2)} Kč',
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
                    onPressed: () =>
                        _vybratDilZeSkladu(context, isDark),
                    icon: const Icon(Icons.inventory_2,
                        color: Colors.orange),
                    label: const Text('Vybrat ze skladu',
                        style: TextStyle(color: Colors.orange)),
                    style: TextButton.styleFrom(
                      backgroundColor:
                          Colors.orange.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
              const Divider(height: 40),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: 'Forma úhrady'),
                      value: _formaUhrady,
                      items: ['Převodem', 'Hotově', 'Kartou']
                          .map((v) => DropdownMenuItem(
                              value: v, child: Text(v)))
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
                      decoration: const InputDecoration(
                          labelText: 'Splatnost (dny)'),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                          text: _splatnostDny.toString()),
                      onChanged: (v) =>
                          _splatnostDny = int.tryParse(v) ?? 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('CELKEM K ÚHRADĚ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Text(
                        '${_celkovaCenaSDph.toStringAsFixed(2)} Kč',
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
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Text('VYSTAVIT FAKTURU A PDF',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
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
            ? (compact
                ? const Color(0xFF1E1E1E)
                : const Color(0xFF2C2C2C))
            : Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 15,
          vertical: compact ? 10 : 15,
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
