import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_gate.dart';
import '../core/constants.dart';

class _UkonData {
  final TextEditingController nazev;
  final TextEditingController cena;
  final TextEditingController cas;
  final TextEditingController celkovaCena;
  bool syncing = false;
  String kategorie;
  String jednotkaCasu;

  _UkonData(
      {String nazevText = '',
      this.kategorie = 'Mechanika',
      this.jednotkaCasu = 'hod'})
      : nazev = TextEditingController(text: nazevText),
        cena = TextEditingController(),
        cas = TextEditingController(text: '1.0'),
        celkovaCena = TextEditingController(text: '0.00');

  void dispose() {
    nazev.dispose();
    cena.dispose();
    cas.dispose();
    celkovaCena.dispose();
  }
}

// Průvodce prvním spuštěním (onboarding) — zobrazí se novému uživateli místo hlavní obrazovky.
// Po dokončení se vše uloží batch zápisem do Firestore a uživatel je přesměrován do aplikace.
// Kroky:
//   1) Informace o servisu + profil majitele (admin účet)
//   2) Přednastavený katalog úkonů (název, cena, čas, kategorie)
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

  bool _defaultOdeslatEmaily = true;
  bool _tmavyRezim = false;

  // KROK 2: Předpřipravené úkony
  final List<_UkonData> _ukony = [];

  static const List<String> _kategorieUkonu = [
    'Mechanika',
    'Pneuservis',
    'Elektrika',
    'Lakovna',
    'Karosárna',
    'Ostatní'
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
        final finalniUkony =
            _ukony.where((u) => u.nazev.text.trim().isNotEmpty).toList();

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
            'cena_bez_dph':
                double.tryParse(ukon.cena.text.replaceAll(',', '.')) ?? 0.0,
            'sazba_dph': 0,
            'odhadovany_cas':
                double.tryParse(ukon.cas.text.replaceAll(',', '.')) ?? 1.0,
            'jednotka_casu': ukon.jednotkaCasu,
            'kategorie': ukon.kategorie,
            'aktivni': true,
          });
        }

        // Trial předplatné — 30 dní zdarma bez platební karty
        batch.set(
          FirebaseFirestore.instance.collection('predplatne').doc(user.uid),
          {
            'servis_id': user.uid,
            'plan_typ': 'trial',
            'trial_zacatek': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

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

    if (_currentPage == 1) {
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
                              color: _currentPage == 1
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
                  _buildStep3(isDark),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E3A5F) : Colors.white,
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
                              _currentPage == 1
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

  // ── KROK 1: Základní informace ──────────────────────────────────────────
  // IČO (ARES lookup), název servisu, zápis v rejstříku, e-mail, přepínač e-mailů,
  // tmavý režim, jméno majitele (vytvoří se jako admin účet v kolekci 'uzivatele').
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
              fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
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
              fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
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
              fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
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
              fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
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
                color: isDark ? const Color(0xFF1E3A5F) : Colors.white,
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
              fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
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
                color: isDark ? const Color(0xFF1E3A5F) : Colors.white,
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

  // ── KROK 3: Katalog úkonů ───────────────────────────────────────────────
  // Přednastavené úkony servisu — každý má název, cenu bez DPH, odhadovaný čas,
  // jednotku času (hod/min) a kategorii. Uloží se do samostatné kolekce 'ukony'.
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
          final fillColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[50]!;
          final border = OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
          );
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3A5F) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.redAccent, size: 20),
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
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (val) {
                          if (ukon.syncing) return;
                          ukon.syncing = true;
                          final c =
                              double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                          final t = double.tryParse(
                                  ukon.cas.text.replaceAll(',', '.')) ??
                              0.0;
                          ukon.celkovaCena.text = (c * t).toStringAsFixed(2);
                          ukon.syncing = false;
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: 'Jedn. cena (Kč)',
                          filled: true,
                          fillColor: fillColor,
                          border: border,
                          enabledBorder: border,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: ukon.cas,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onChanged: (val) {
                          if (ukon.syncing) return;
                          ukon.syncing = true;
                          final t =
                              double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                          final c = double.tryParse(
                                  ukon.cena.text.replaceAll(',', '.')) ??
                              0.0;
                          ukon.celkovaCena.text = (c * t).toStringAsFixed(2);
                          ukon.syncing = false;
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: 'Čas',
                          filled: true,
                          fillColor: fillColor,
                          border: border,
                          enabledBorder: border,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ToggleButtons(
                      isSelected: [
                        ukon.jednotkaCasu == 'hod',
                        ukon.jednotkaCasu == 'min'
                      ],
                      onPressed: (i) => setState(
                          () => ukon.jednotkaCasu = i == 0 ? 'hod' : 'min'),
                      borderRadius: BorderRadius.circular(10),
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 48),
                      children: const [Text('hod'), Text('min')],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: ukon.celkovaCena,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) {
                    if (ukon.syncing) return;
                    ukon.syncing = true;
                    final celkova =
                        double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
                    final t =
                        double.tryParse(ukon.cas.text.replaceAll(',', '.')) ??
                            0.0;
                    ukon.cena.text =
                        t > 0 ? (celkova / t).toStringAsFixed(2) : '0.00';
                    ukon.syncing = false;
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'Celková cena (Kč)',
                    filled: true,
                    fillColor: fillColor,
                    border: border,
                    enabledBorder: border,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  items: _kategorieUkonu
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => ukon.kategorie = val ?? ukon.kategorie),
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
