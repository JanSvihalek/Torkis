import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth_gate.dart';
import 'faktura_detail.dart';

class PolozkaInput {
  String typ = 'Materiál';
  final cislo = TextEditingController();
  final nazev = TextEditingController();
  final mnozstvi = TextEditingController(text: '1');
  String jednotka = 'ks';
  final cenaBezDph = TextEditingController(text: '0');
  final cenaSDph = TextEditingController(text: '0');
  final sleva = TextEditingController(text: '0');

  String? skladDocId;

  void dispose() {
    cislo.dispose();
    nazev.dispose();
    mnozstvi.dispose();
    cenaBezDph.dispose();
    cenaSDph.dispose();
    sleva.dispose();
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
  State<EditFakturaWorkScreen> createState() =>
      _EditFakturaWorkScreenState();
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
          input.cenaBezDph.text =
              (p['cena_bez_dph'] ?? 0.0).toStringAsFixed(2);
          input.cenaSDph.text = (p['cena_s_dph'] ?? 0.0).toStringAsFixed(2);
          String slevaVal = (p['sleva'] ?? 0.0).toString();
          input.sleva.text = slevaVal.endsWith('.0')
              ? slevaVal.replaceAll('.0', '')
              : slevaVal;
          _polozkyInputs.add(input);
        }
      } else {
        if ((widget.existingWork!['cena_s_dph'] ?? 0) > 0 ||
            (widget.existingWork!['delka_prace']
                    ?.toString()
                    .isNotEmpty ==
                true)) {
          final input = PolozkaInput();
          input.typ = 'Práce';
          input.cislo.text = '';
          input.nazev.text = 'Práce mechanika';
          input.mnozstvi.text =
              (widget.existingWork!['delka_prace'] ?? 1).toString();
          input.jednotka = 'h';
          input.cenaBezDph.text =
              (widget.existingWork!['cena_bez_dph'] ?? 0.0)
                  .toStringAsFixed(2);
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
          input.cenaBezDph.text =
              (d['cena_bez_dph'] ?? 0.0).toStringAsFixed(2);
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
          _hodinovaSazba =
              (doc.data()?['hodinova_sazba'] ?? 0.0).toDouble();
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

    bool maChybu = false;
    for (var p in _polozkyInputs) {
      if (p.nazev.text.trim().isEmpty) {
        maChybu = true;
        break;
      }
    }
    if (maChybu) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vyplňte názvy u všech položek!')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
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
              })
          .where((d) => d['nazev'].toString().isNotEmpty)
          .toList();

      Map<String, dynamic> novyUkon = {
        'nazev': _nazevController.text.trim(),
        'popis': _popisController.text.trim(),
        'polozky': zpracovanePolozky,
        'cas': widget.existingWork?['cas'] ?? Timestamp.now(),
        'fotografie_urls':
            widget.existingWork?['fotografie_urls'] ?? [],
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Chyba: $e')));
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.existingWork != null
            ? 'Úprava faktury'
            : 'Přidat do faktury'),
        backgroundColor:
            isDark ? const Color(0xFF1E3A5F) : Colors.white,
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
                    color: isDark
                        ? const Color(0xFF1E3A5F)
                        : Colors.white,
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
                    color: isDark
                        ? const Color(0xFF1E3A5F)
                        : Colors.white,
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
                          ...List.generate(_polozkyInputs.length,
                              (index) {
                            final polozka = _polozkyInputs[index];
                            double dPocet = double.tryParse(polozka
                                    .mnozstvi.text
                                    .replaceAll(',', '.')) ??
                                0.0;
                            double dCena = double.tryParse(polozka
                                    .cenaSDph.text
                                    .replaceAll(',', '.')) ??
                                0.0;
                            double dSleva = double.tryParse(polozka
                                    .sleva.text
                                    .replaceAll(',', '.')) ??
                                0.0;
                            double rCelkem =
                                (dPocet * dCena) * (1 - (dSleva / 100));

                            return _buildPolozkaCard(
                                index, polozka, rCelkem, isDark);
                          }),
                          TextButton.icon(
                            onPressed: () => setState(
                                () => _polozkyInputs.add(PolozkaInput())),
                            icon: const Icon(Icons.add),
                            label:
                                const Text('Přidat další položku'),
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
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0D2040)
                  : Colors.white,
              boxShadow: const [
                BoxShadow(
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
                        const Text('Celkem po úpravě',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 12)),
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
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check),
                    label: Text(
                      _isSaving
                          ? 'ZPRACOVÁVÁM...'
                          : 'ULOŽIT A PŘEGENEROVAT',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
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

  Widget _buildPolozkaCard(
      int index, PolozkaInput polozka, double rCelkem, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A5F) : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildTypDropdown(polozka, isDark),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: _buildTextField(polozka.cislo, 'Číslo dílu',
                    isDark, compact: true),
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
          _buildTextField(polozka.nazev, 'Název položky *', isDark,
              compact: true),
          const SizedBox(height: 8),
          _buildCenovyRadek(polozka, isDark),
          const SizedBox(height: 10),
          _buildCelkemZaPolozku(rCelkem),
        ],
      ),
    );
  }

  Widget _buildTypDropdown(PolozkaInput polozka, bool isDark) {
    return DropdownButtonFormField<String>(
      value: polozka.typ,
      style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white : Colors.black),
      items: ['Práce', 'Materiál']
          .map((t) => DropdownMenuItem(
              value: t,
              child: Text(t, style: const TextStyle(fontSize: 12))))
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
                    polozka, polozka.cenaBezDph.text);
              }
            }
            if (val == 'Materiál') polozka.jednotka = 'ks';
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Typ',
        labelStyle: const TextStyle(fontSize: 12),
        filled: true,
        fillColor:
            isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildCenovyRadek(PolozkaInput polozka, bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildTextField(polozka.mnozstvi, 'Mn.', isDark,
              isNumber: true,
              compact: true,
              onChanged: (v) => _prepocitatCelkem()),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 2,
          child: _buildJednotkaDropdown(polozka, isDark),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 2,
          child: _buildTextField(polozka.sleva, 'Sleva %', isDark,
              isNumber: true,
              compact: true,
              onChanged: (v) => _prepocitatCelkem()),
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
                  _prepocitatDphPolozky(polozka, v)),
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
              onChanged: (v) => _prepocitatCelkem()),
        ),
      ],
    );
  }

  Widget _buildJednotkaDropdown(PolozkaInput polozka, bool isDark) {
    return DropdownButtonFormField<String>(
      value: polozka.jednotka,
      style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white : Colors.black),
      items: ['ks', 'h', 'min', 'l', 'm', 'bal', 'sada', 'úkon']
          .map((j) => DropdownMenuItem(
              value: j,
              child: Text(j, style: const TextStyle(fontSize: 12))))
          .toList(),
      onChanged: (val) {
        if (val != null) setState(() => polozka.jednotka = val);
      },
      decoration: InputDecoration(
        labelText: 'Jedn.',
        labelStyle: const TextStyle(fontSize: 12),
        filled: true,
        fillColor:
            isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildCelkemZaPolozku(double rCelkem) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Celkem za položku: ',
              style: TextStyle(color: Colors.blue, fontSize: 12)),
          Text('${rCelkem.toStringAsFixed(2)} Kč',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 14)),
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
        fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
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
