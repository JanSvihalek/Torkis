import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'auth_gate.dart';
import '../core/constants.dart';

class _UkonData {
  final TextEditingController nazev;
  final TextEditingController cena;
  final TextEditingController cas;
  String kategorie;
  String jednotkaCasu;

  _UkonData({String nazevText = '', this.kategorie = 'Mechanika', this.jednotkaCasu = 'hod'})
      : nazev = TextEditingController(text: nazevText),
        cena = TextEditingController(),
        cas = TextEditingController(text: '1.0');

  void dispose() {
    nazev.dispose();
    cena.dispose();
    cas.dispose();
  }
}

class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSaving = false;
  bool _isLoadingAres = false;

  // KROK 1: Základní údaje servisu
  final _nazevController = TextEditingController();
  final _icoController = TextEditingController();
  final _registraceController = TextEditingController();
  final _emailServisuController = TextEditingController();
  final _jmenoMajiteleController = TextEditingController();

  // KROK 2: Fakturace a Ceny
  final _sazbaController = TextEditingController();
  final _bankaController = TextEditingController();
  final _dicController = TextEditingController();
  final _prefixZakazkaController = TextEditingController(text: 'ZAK');
  final _prefixFakturaController = TextEditingController(text: 'FAK');

  bool _jePlatceDph = false;
  bool _defaultOdeslatEmaily = true;
  bool _tmavyRezim = false;

  // Číslování - Zakázky
  String _zakazkaRokFormat = '{YYYY}';
  String _zakazkaMessicFormat = '{MM}';
  String _zakazkaOddelovac = '-';
  double _zakazkaDelkaPocitadla = 5.0;

  // Číslování - Faktury
  String _fakturaRokFormat = '{YYYY}';
  String _fakturaMessicFormat = '{MM}';
  String _fakturaOddelovac = '-';
  double _fakturaDelkaPocitadla = 5.0;

  // KROK 3: Předpřipravené úkony
  final List<_UkonData> _ukony = [];

  static const List<String> _kategorieUkonu = [
    'Mechanika', 'Pneuservis', 'Elektrika', 'Lakovna', 'Karosárna', 'Ostatní'
  ];

  static const List<String> _vychoziUkony = [
    'Výměna oleje a filtrů',
    'Kontrola brzd',
    'Servis klimatizace',
    'Příprava a provedení STK',
    'Geometrie kol',
    'Pneuservis (přezutí)',
    'Diagnostika závad',
  ];

  @override
  void initState() {
    super.initState();
    for (final nazev in _vychoziUkony) {
      _ukony.add(_UkonData(nazevText: nazev));
    }
  }

  @override
  void dispose() {
    _nazevController.dispose();
    _icoController.dispose();
    _registraceController.dispose();
    _emailServisuController.dispose();
    _jmenoMajiteleController.dispose();
    _sazbaController.dispose();
    _bankaController.dispose();
    _dicController.dispose();
    _prefixZakazkaController.dispose();
    _prefixFakturaController.dispose();
    for (final u in _ukony) {
      u.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchAresData() async {
    final ico = _icoController.text.trim();
    if (ico.isEmpty || ico.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Zadejte platné 8místné IČO.'),
          backgroundColor: Colors.orange));
      return;
    }
    setState(() => _isLoadingAres = true);
    try {
      final response = await http.get(Uri.parse(
          'https://ares.gov.cz/ekonomicke-subjekty-v-be/rest/ekonomicke-subjekty/$ico'));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _nazevController.text = data['obchodniJmeno'] ?? '';
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Údaje z ARES byly načteny.'),
            backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Zadané IČO nebylo v registru ARES nalezeno.'),
            backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Chyba při komunikaci s ARES: $e'),
          backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoadingAres = false);
    }
  }

  void _pridatPrazdnyUkon() {
    setState(() {
      _ukony.add(_UkonData());
    });
  }

  void _odebratUkon(int index) {
    setState(() {
      _ukony[index].dispose();
      _ukony.removeAt(index);
    });
  }

  Future<void> _dokoncitNastaveni() async {
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final finalniUkony = _ukony
            .where((u) => u.nazev.text.trim().isNotEmpty)
            .toList();

        // POUŽIJEME BATCH ZÁPIS - Zapíše všechny dokumenty najednou a bezpečně
        WriteBatch batch = FirebaseFirestore.instance.batch();

        // 1. ZÁPIS NASTAVENÍ SERVISU
        DocumentReference nastaveniRef = FirebaseFirestore.instance
            .collection('nastaveni_servisu')
            .doc(user.uid);
        batch.set(
            nastaveniRef,
            {
              'nazev_servisu': _nazevController.text.trim(),
              'ico_servisu': _icoController.text.trim(),
              'registrace_servisu': _registraceController.text.trim(),
              'email_servisu': _emailServisuController.text.trim(),
              'default_odesilat_emaily': _defaultOdeslatEmaily,
              'tmavy_rezim': _tmavyRezim,
              'hodinova_sazba':
                  double.tryParse(_sazbaController.text.replaceAll(',', '.')) ??
                      0.0,
              'platce_dph': _jePlatceDph,
              'dic_servisu': _dicController.text.trim(),
              'banka_servisu': _bankaController.text.trim(),
              'prefix_zakazky': _prefixZakazkaController.text.trim().isEmpty
                  ? 'ZAK'
                  : _prefixZakazkaController.text.trim().toUpperCase(),
              'prefix_zakazka': _prefixZakazkaController.text.trim().isEmpty
                  ? 'ZAK'
                  : _prefixZakazkaController.text.trim().toUpperCase(),
              'prefix_faktury': _prefixFakturaController.text.trim().isEmpty
                  ? 'FAK'
                  : _prefixFakturaController.text.trim().toUpperCase(),
              'prefix_faktura': _prefixFakturaController.text.trim().isEmpty
                  ? 'FAK'
                  : _prefixFakturaController.text.trim().toUpperCase(),
              'maska_zakazka': _vygenerujMasku(
                  _prefixZakazkaController.text.trim().isEmpty
                      ? 'ZAK'
                      : _prefixZakazkaController.text.trim().toUpperCase(),
                  _zakazkaRokFormat,
                  _zakazkaMessicFormat,
                  _zakazkaOddelovac,
                  _zakazkaDelkaPocitadla.toInt()),
              'cfg_rok_zakazka': _zakazkaRokFormat,
              'cfg_mesic_zakazka': _zakazkaMessicFormat,
              'cfg_oddelovac_zakazka': _zakazkaOddelovac,
              'cfg_delka_zakazka': _zakazkaDelkaPocitadla.toInt(),
              'maska_faktura': _vygenerujMasku(
                  _prefixFakturaController.text.trim().isEmpty
                      ? 'FAK'
                      : _prefixFakturaController.text.trim().toUpperCase(),
                  _fakturaRokFormat,
                  _fakturaMessicFormat,
                  _fakturaOddelovac,
                  _fakturaDelkaPocitadla.toInt()),
              'cfg_rok_faktura': _fakturaRokFormat,
              'cfg_mesic_faktura': _fakturaMessicFormat,
              'cfg_oddelovac_faktura': _fakturaOddelovac,
              'cfg_delka_faktura': _fakturaDelkaPocitadla.toInt(),
              // Pole 'rychle_ukony' bylo smazáno, ukládáme to teď do samostatné kolekce (viz krok 3)
              'prvni_spusteni_dokonceno': true,
              'vytvoreno': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));

        // 2. VYTVOŘENÍ PROFILU ADMINA (ZAKLADATELE)
        DocumentReference adminRef =
            FirebaseFirestore.instance.collection('uzivatele').doc(user.uid);
        batch.set(adminRef, {
          'uid': user.uid,
          'email': user.email,
          'role': 'admin',
          'servis_id': user.uid,
          'jmeno': _jmenoMajiteleController.text.trim().isNotEmpty
              ? _jmenoMajiteleController.text.trim()
              : (user.email ?? ''),
          'prava': {
            'zakazky': true,
            'sklad': true,
            'fakturace': true,
            'zamestnanci': true,
            'nastaveni': true,
          },
          'vytvoreno': FieldValue.serverTimestamp(),
        });

        // 3. VYTVOŘENÍ JEDNOTLIVÝCH ÚKONŮ DO SAMOSTATNÉ KOLEKCE
        for (final ukon in finalniUkony) {
          final ukonRef = FirebaseFirestore.instance.collection('ukony').doc();
          batch.set(ukonRef, {
            'servis_id': user.uid,
            'nazev': ukon.nazev.text.trim(),
            'cena_bez_dph': double.tryParse(ukon.cena.text.replaceAll(',', '.')) ?? 0.0,
            'sazba_dph': _jePlatceDph ? 21 : 0,
            'odhadovany_cas': double.tryParse(ukon.cas.text.replaceAll(',', '.')) ?? 1.0,
            'jednotka_casu': ukon.jednotkaCasu,
            'kategorie': ukon.kategorie,
            'aktivni': true,
          });
        }

        // SPUŠTĚNÍ DÁVKOVÉHO ZÁPISU
        await batch.commit();

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AuthGate()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Chyba při ukládání: $e'),
          backgroundColor: Colors.red));
      setState(() => _isSaving = false);
    }
  }

  void _moveNext() {
    if (_currentPage == 0 && _nazevController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Název servisu je povinný pro pokračování.'),
          backgroundColor: Colors.orange));
      return;
    }

    if (_currentPage == 2) {
      _dokoncitNastaveni();
    } else {
      FocusScope.of(context).unfocus();
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _moveBack() {
    FocusScope.of(context).unfocus();
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(3)))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                              color: _currentPage >= 1
                                  ? Colors.blue
                                  : (isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[300]),
                              borderRadius: BorderRadius.circular(3)))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                              color: _currentPage == 2
                                  ? Colors.blue
                                  : (isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[300]),
                              borderRadius: BorderRadius.circular(3)))),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildStep1(isDark),
                  _buildStep2(isDark),
                  _buildStep3(isDark),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5))
                ],
              ),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton.filledTonal(
                      onPressed: _moveBack,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      padding: const EdgeInsets.all(15),
                      style: IconButton.styleFrom(
                        backgroundColor: isDark ? Colors.grey[800] : null,
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _moveNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(
                              _currentPage == 2
                                  ? 'DOKONČIT NASTAVENÍ'
                                  : 'POKRAČOVAT',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _vygenerujMasku(String prefix, String rokFormat, String mesicFormat,
      String oddelovac, int delka) {
    List<String> casti = [];
    if (prefix.isNotEmpty) casti.add('{PREFIX}');
    if (rokFormat.isNotEmpty) casti.add(rokFormat);
    if (mesicFormat.isNotEmpty) casti.add(mesicFormat);
    casti.add('{NUM$delka}');
    return casti.join(oddelovac);
  }

  String _vygenerujNahled(String prefix, String rokFormat, String mesicFormat,
      String oddelovac, int delka) {
    final ted = DateTime.now();
    String nahled =
        _vygenerujMasku(prefix, rokFormat, mesicFormat, oddelovac, delka);
    nahled = nahled.replaceAll('{PREFIX}', prefix.toUpperCase());
    nahled = nahled.replaceAll('{YYYY}', DateFormat('yyyy').format(ted));
    nahled = nahled.replaceAll('{YY}', DateFormat('yy').format(ted));
    nahled = nahled.replaceAll('{MM}', DateFormat('MM').format(ted));
    nahled = nahled.replaceAll('{NUM$delka}', '1'.padLeft(delka, '0'));
    return nahled;
  }

  Widget _buildCislovaniSekce({
    required String nazev,
    required Color barva,
    required IconData ikona,
    required TextEditingController prefixCtrl,
    required String rokFormat,
    required String mesicFormat,
    required String oddelovac,
    required double delkaPocitadla,
    required void Function(String) onRokChanged,
    required void Function(String) onMesicChanged,
    required void Function(String) onOddelovacChanged,
    required void Function(double) onDelkaChanged,
    required bool isDark,
  }) {
    final prefix = prefixCtrl.text.trim().isEmpty
        ? (nazev == 'Faktury' ? 'FAK' : 'ZAK')
        : prefixCtrl.text.trim().toUpperCase();
    final nahled = _vygenerujNahled(
        prefix, rokFormat, mesicFormat, oddelovac, delkaPocitadla.toInt());

    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final fillColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey[50]!;
    final inputBorder =
        OutlineInputBorder(borderRadius: BorderRadius.circular(10));
    final enabledBorder = OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor));

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border:
            Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ikona, color: barva, size: 20),
              const SizedBox(width: 8),
              Text(nazev,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16, color: barva)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            decoration: BoxDecoration(
              color: barva.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: barva.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text('Náhled:',
                    style: TextStyle(
                        color: barva,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(nahled,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: barva)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: prefixCtrl,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Prefix',
                    filled: true,
                    fillColor: fillColor,
                    border: inputBorder,
                    enabledBorder: enabledBorder,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: oddelovac,
                  decoration: InputDecoration(
                    labelText: 'Oddělovač',
                    filled: true,
                    fillColor: fillColor,
                    border: inputBorder,
                    enabledBorder: enabledBorder,
                  ),
                  items: const [
                    DropdownMenuItem(value: '-', child: Text('Pomlčka (-)')),
                    DropdownMenuItem(value: '/', child: Text('Lomítko (/)')),
                    DropdownMenuItem(value: '_', child: Text('Podtržítko (_)')),
                    DropdownMenuItem(value: '', child: Text('Bez oddělovače')),
                  ],
                  onChanged: (val) => onOddelovacChanged(val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: rokFormat,
                  decoration: InputDecoration(
                    labelText: 'Formát roku',
                    filled: true,
                    fillColor: fillColor,
                    border: inputBorder,
                    enabledBorder: enabledBorder,
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: '{YYYY}', child: Text('4 cifry (2026)')),
                    DropdownMenuItem(
                        value: '{YY}', child: Text('2 cifry (26)')),
                    DropdownMenuItem(value: '', child: Text('Bez roku')),
                  ],
                  onChanged: (val) => onRokChanged(val!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: mesicFormat,
                  decoration: InputDecoration(
                    labelText: 'Formát měsíce',
                    filled: true,
                    fillColor: fillColor,
                    border: inputBorder,
                    enabledBorder: enabledBorder,
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: '{MM}', child: Text('2 cifry (04)')),
                    DropdownMenuItem(value: '', child: Text('Bez měsíce')),
                  ],
                  onChanged: (val) => onMesicChanged(val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Délka pořadového čísla: ${delkaPocitadla.toInt()}',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Slider(
            value: delkaPocitadla,
            min: 3,
            max: 6,
            divisions: 3,
            activeColor: barva,
            label: delkaPocitadla.toInt().toString(),
            onChanged: onDelkaChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.handshake, color: Colors.blue, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('Vítejte ve TORKIS!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
              'Nejprve vyplníme základní informace o vašem servisu. Ty se pak budou automaticky propisovat do faktur a protokolů.',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 40),
          const Text('IČO (ARES vyhledávání)',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _icoController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Např. 12345678',
              prefixIcon: const Icon(Icons.business, color: Colors.blue),
              suffixIcon: _isLoadingAres
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)))
                  : IconButton(
                      icon: const Icon(Icons.search, color: Colors.blue),
                      onPressed: _fetchAresData,
                      tooltip: 'Načíst z ARES'),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[400]!)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[300]!)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Název servisu / Jméno *',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _nazevController,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Zadejte název...',
              prefixIcon: const Icon(Icons.storefront, color: Colors.blue),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[400]!)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[300]!)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Zápis v rejstříku (nepovinné)',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _registraceController,
            decoration: InputDecoration(
              hintText: 'Např. zapsán v ŽR u MÚ...',
              prefixIcon: const Icon(Icons.gavel, color: Colors.blueGrey),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[400]!)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[300]!)),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),
          const Text('Komunikace a vzhled',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
              'E-mailová adresa (z níž budou odcházet e-maily zákazníkům)',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _emailServisuController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Např. info@autoservis.cz',
              prefixIcon: const Icon(Icons.email, color: Colors.blue),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[400]!)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[300]!)),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.grey[300]!)),
            child: SwitchListTile(
              title: const Text('Automaticky zasílat e-maily',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text(
                  'Zákazníkům bude v nabídkách a při ukončení předzaškrtnuta možnost odeslání PDF e-mailem.',
                  style: TextStyle(fontSize: 12)),
              value: _defaultOdeslatEmaily,
              activeColor: Colors.blue,
              onChanged: (val) => setState(() => _defaultOdeslatEmaily = val),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),
          const Text('Váš účet (administrátor)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text(
              'Zadejte své jméno — budete přidáni jako hlavní správce servisu.',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 15),
          TextField(
            controller: _jmenoMajiteleController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Jméno a příjmení *',
              hintText: 'Např. Jan Novák',
              prefixIcon: const Icon(Icons.person, color: Colors.blue),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[400]!)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[300]!)),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.grey[300]!)),
            child: SwitchListTile(
              title: const Text('Vynutit tmavý režim',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text(
                  'Aplikace bude okamžitě přepnuta do tmavého vzhledu.',
                  style: TextStyle(fontSize: 12)),
              value: _tmavyRezim,
              activeColor: Colors.blue,
              onChanged: (val) {
                setState(() => _tmavyRezim = val);
                themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStep2(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.payments, color: Colors.green, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('Fakturace a Ceny',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Nastavte si výchozí sazby a účetní údaje.',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 30),
          const Text('Základní hodinová sazba bez DPH (Kč)',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _sazbaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Např. 800',
              prefixIcon: const Icon(Icons.attach_money, color: Colors.green),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[400]!)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[300]!)),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.grey[300]!)),
            child: SwitchListTile(
              title: const Text('Jsem plátce DPH',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              value: _jePlatceDph,
              activeColor: Colors.blue,
              onChanged: (val) => setState(() => _jePlatceDph = val),
            ),
          ),
          if (_jePlatceDph) ...[
            const SizedBox(height: 20),
            const Text('DIČ',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _dicController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Např. CZ12345678',
                prefixIcon:
                    const Icon(Icons.assignment_ind, color: Colors.blue),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[400]!)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!)),
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Text('Bankovní účet (pro QR platbu)',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _bankaController,
            decoration: InputDecoration(
              hintText: 'Číslo účtu / Kód banky',
              prefixIcon:
                  const Icon(Icons.account_balance, color: Colors.blueGrey),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[400]!)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[300]!)),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),
          const Text('Číslování dokladů',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text('Nastavte formát čísel pro zakázky a faktury.',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 15),
          _buildCislovaniSekce(
            nazev: 'Zakázky',
            barva: Colors.blue,
            ikona: Icons.build_circle_outlined,
            prefixCtrl: _prefixZakazkaController,
            rokFormat: _zakazkaRokFormat,
            mesicFormat: _zakazkaMessicFormat,
            oddelovac: _zakazkaOddelovac,
            delkaPocitadla: _zakazkaDelkaPocitadla,
            onRokChanged: (val) => setState(() => _zakazkaRokFormat = val),
            onMesicChanged: (val) => setState(() => _zakazkaMessicFormat = val),
            onOddelovacChanged: (val) =>
                setState(() => _zakazkaOddelovac = val),
            onDelkaChanged: (val) =>
                setState(() => _zakazkaDelkaPocitadla = val),
            isDark: isDark,
          ),
          const SizedBox(height: 15),
          _buildCislovaniSekce(
            nazev: 'Faktury',
            barva: Colors.green,
            ikona: Icons.receipt_outlined,
            prefixCtrl: _prefixFakturaController,
            rokFormat: _fakturaRokFormat,
            mesicFormat: _fakturaMessicFormat,
            oddelovac: _fakturaOddelovac,
            delkaPocitadla: _fakturaDelkaPocitadla,
            onRokChanged: (val) => setState(() => _fakturaRokFormat = val),
            onMesicChanged: (val) => setState(() => _fakturaMessicFormat = val),
            onOddelovacChanged: (val) =>
                setState(() => _fakturaOddelovac = val),
            onDelkaChanged: (val) =>
                setState(() => _fakturaDelkaPocitadla = val),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(30),
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.1),
              shape: BoxShape.circle),
          child: const Icon(Icons.playlist_add_check_circle,
              color: Colors.deepOrange, size: 40),
        ),
        const SizedBox(height: 20),
        const Text('Nejčastější úkony',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text(
            'Připravili jsme pro vás seznam typických úkonů. Můžete je libovolně přepsat, smazat nebo si přidat další. Budou se vám nabízet pro rychlé přidání při příjmu vozu.',
            style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 30),
        ...List.generate(_ukony.length, (index) {
          final ukon = _ukony[index];
          final fillColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey[50]!;
          final border = OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
          );
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ukon.nazev,
                        decoration: InputDecoration(
                          labelText: 'Název úkonu',
                          filled: true,
                          fillColor: fillColor,
                          border: border,
                          enabledBorder: border,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                      onPressed: () => _odebratUkon(index),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ukon.cena,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Cena (Kč)',
                          filled: true,
                          fillColor: fillColor,
                          border: border,
                          enabledBorder: border,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: ukon.cas,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Čas',
                          filled: true,
                          fillColor: fillColor,
                          border: border,
                          enabledBorder: border,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ToggleButtons(
                      isSelected: [ukon.jednotkaCasu == 'hod', ukon.jednotkaCasu == 'min'],
                      onPressed: (i) => setState(() => ukon.jednotkaCasu = i == 0 ? 'hod' : 'min'),
                      borderRadius: BorderRadius.circular(10),
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 48),
                      children: const [Text('hod'), Text('min')],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: ukon.kategorie,
                  decoration: InputDecoration(
                    labelText: 'Kategorie',
                    filled: true,
                    fillColor: fillColor,
                    border: border,
                    enabledBorder: border,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: _kategorieUkonu
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (val) => setState(() => ukon.kategorie = val ?? ukon.kategorie),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 10),
        TextButton.icon(
            onPressed: _pridatPrazdnyUkon,
            icon: const Icon(Icons.add),
            label: const Text('Přidat další úkon',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        const SizedBox(height: 20),
      ],
    );
  }
}
