import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'trial_welcome_screen.dart';
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

  // Počet kroků průvodce (firma → provoz → úkony).
  static const int _pocetKroku = 3;

  // KROK 1: Základní údaje servisu + sídlo a kontakt
  final _nazevController = TextEditingController();
  final _icoController = TextEditingController();
  final _dicController = TextEditingController();
  final _registraceController = TextEditingController();
  final _adresaController = TextEditingController();
  final _mestoController = TextEditingController();
  final _pscController = TextEditingController();
  final _telefonController = TextEditingController();
  final _emailServisuController = TextEditingController();
  final _jmenoMajiteleController = TextEditingController();

  bool _defaultOdeslatEmaily = true;
  bool _tmavyRezim = false;

  // KROK 2: Provoz a automatizace
  bool _autoCisloZakazky = true;
  bool _podpisPovolen = true;
  bool _spzPovinne = true;
  final List<String> _typyZaznamu = ['Servis', 'Výkup'];
  String _defaultTypZaznamu = 'Servis';

  // KROK 2: Osobní nastavení
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _spoustVlevo = false;

  // KROK 3: Předpřipravené úkony
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
    _zjistitBiometrii();
  }

  /// Zjistí, zda zařízení podporuje biometrii — podle toho se v kroku 2
  /// zobrazí (nebo skryje) přepínač biometrického přihlášení.
  Future<void> _zjistitBiometrii() async {
    try {
      final canBio = await LocalAuthentication().canCheckBiometrics;
      if (mounted) setState(() => _biometricAvailable = canBio);
    } catch (_) {
      // Biometrie není dostupná — přepínač zůstane skrytý.
    }
  }

  @override
  void dispose() {
    _nazevController.dispose();
    _icoController.dispose();
    _dicController.dispose();
    _registraceController.dispose();
    _adresaController.dispose();
    _mestoController.dispose();
    _pscController.dispose();
    _telefonController.dispose();
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

  /// Přepne biometrické přihlášení. Při zapnutí vyžádá ověření, aby se
  /// předešlo zapnutí cizí osobou.
  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      try {
        final ok = await LocalAuthentication().authenticate(
          localizedReason:
              'Potvrďte svou totožnost pro zapnutí biometrického přihlášení',
          options: const AuthenticationOptions(stickyAuth: true),
        );
        if (!ok) return;
      } catch (_) {
        return;
      }
    }
    setState(() => _biometricEnabled = value);
  }

  void _otevritDialogTypuZaznamu({String? initialText, int? editIndex}) {
    final ctrl = TextEditingController(text: initialText ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E3A5F) : Colors.white,
        title: Text(editIndex != null ? 'Upravit typ' : 'Nový typ záznamu'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Název typu (např. Servis, Výkup...)',
            filled: true,
            fillColor:
                isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[100],
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Zrušit'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = ctrl.text.trim();
              if (text.isEmpty) return;
              setState(() {
                if (editIndex != null) {
                  if (_defaultTypZaznamu == _typyZaznamu[editIndex]) {
                    _defaultTypZaznamu = text;
                  }
                  _typyZaznamu[editIndex] = text;
                } else {
                  _typyZaznamu.add(text);
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Uložit'),
          ),
        ],
      ),
    );
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
              'dic_servisu': _dicController.text.trim(),
              'registrace_servisu': _registraceController.text.trim(),
              'adresa_servisu': _adresaController.text.trim(),
              'mesto_servisu': _mestoController.text.trim(),
              'psc_servisu': _pscController.text.trim(),
              'telefon_servisu': _telefonController.text.trim(),
              'email_servisu': _emailServisuController.text.trim(),
              'default_odesilat_emaily': _defaultOdeslatEmaily,
              'auto_cislo_zakazky': _autoCisloZakazky,
              'podpis_povolen': _podpisPovolen,
              'spz_povinne': _spzPovinne,
              'typy_zaznamu': _typyZaznamu,
              'default_typ_zaznamu': _defaultTypZaznamu,
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
          // Osobní nastavení — Nastavení je čte z dokumentu uživatele.
          'tmavy_rezim': _tmavyRezim,
          'kamera_spoust_vlevo': _spoustVlevo,
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

        // Lokální nastavení (čtená přímo ze zařízení, ne z Firestore)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('biometric_enabled', _biometricEnabled);
        await prefs.setBool(kPrefKameraSpoustVlevo, _spoustVlevo);
        await prefs.setBool('tmavy_rezim', _tmavyRezim);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const TrialWelcomeScreen()),
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

    if (_currentPage == _pocetKroku - 1) {
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
                  for (int i = 0; i < _pocetKroku; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                        child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                                color: _currentPage >= i
                                    ? Colors.blue
                                    : (isDark
                                        ? Colors.grey[800]
                                        : Colors.grey[300]),
                                borderRadius: BorderRadius.circular(3)))),
                  ],
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
                              _currentPage == _pocetKroku - 1
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

  // Jednotná dekorace polí v průvodci (sjednocený vzhled napříč kroky).
  InputDecoration _onbInput(bool isDark,
      {String? hint, IconData? icon, Color iconColor = Colors.blue}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: iconColor) : null,
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
    );
  }

  // Pojmenované textové pole (popisek nad polem) ve stylu průvodce.
  Widget _onbField(bool isDark,
      {required String label,
      required TextEditingController ctrl,
      String? hint,
      IconData? icon,
      Color iconColor = Colors.blue,
      TextInputType? keyboard}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          decoration:
              _onbInput(isDark, hint: hint, icon: icon, iconColor: iconColor),
        ),
      ],
    );
  }

  // Přepínací karta (SwitchListTile) ve stylu průvodce.
  Widget _onbSwitch(bool isDark,
      {required String title,
      required String subtitle,
      required bool value,
      required ValueChanged<bool> onChanged,
      IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E3A5F) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[300]!)),
      child: SwitchListTile(
        secondary: icon != null ? Icon(icon, color: Colors.blue) : null,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        activeColor: Colors.blue,
        onChanged: onChanged,
      ),
    );
  }

  // ── KROK 1: Základní informace ──────────────────────────────────────────
  // IČO (ARES lookup), název servisu, DIČ, zápis v rejstříku, sídlo a kontakt,
  // e-mail, přepínač e-mailů, tmavý režim, jméno majitele (admin účet).
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
              'Nejprve vyplníme základní informace o vás nebo o vaší společnosti.',
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
          _onbField(isDark,
              label: 'DIČ (nepovinné)',
              ctrl: _dicController,
              hint: 'Např. CZ12345678',
              icon: Icons.badge,
              iconColor: Colors.blueGrey),
          const SizedBox(height: 20),
          _onbField(isDark,
              label: 'Zápis v rejstříku (nepovinné)',
              ctrl: _registraceController,
              hint: 'Např. zapsán v ŽR u MÚ...',
              icon: Icons.gavel,
              iconColor: Colors.blueGrey),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),
          const Text('Sídlo a kontakt',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Údaje se použijí na nabídkách, fakturách a v komunikaci.',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          _onbField(isDark,
              label: 'Ulice a č.p.',
              ctrl: _adresaController,
              hint: 'Např. Hlavní 123',
              icon: Icons.map),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _onbField(isDark,
                    label: 'Město',
                    ctrl: _mestoController,
                    hint: 'Např. Brno',
                    icon: Icons.location_city),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: _onbField(isDark,
                    label: 'PSČ',
                    ctrl: _pscController,
                    hint: '60200',
                    icon: Icons.markunread_mailbox,
                    keyboard: TextInputType.number),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _onbField(isDark,
              label: 'Telefon servisu',
              ctrl: _telefonController,
              hint: 'Např. +420 777 123 456',
              icon: Icons.phone,
              keyboard: TextInputType.phone),
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

  // ── KROK 2: Provoz a automatizace ───────────────────────────────────────
  // Automatizace zakázek (číslo, podpis, SPZ), typy záznamu a osobní přepínače
  // (biometrie, režim pro leváky). Uloží se do nastaveni_servisu / uzivatele.
  Widget _buildStep2(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(30),
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.settings_suggest,
              color: Colors.purple, size: 40),
        ),
        const SizedBox(height: 20),
        const Text('Provoz a automatizace',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text(
            'Nastavte chování příjmu vozidla. Vše lze později kdykoliv změnit v Nastavení.',
            style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 30),
        _onbSwitch(isDark,
            title: 'Automaticky generovat číslo zakázky',
            subtitle:
                'Při příjmu vozidla se číslo zakázky předvyplní automaticky. Vypnutím umožníte ruční zadání.',
            value: _autoCisloZakazky,
            onChanged: (v) => setState(() => _autoCisloZakazky = v)),
        _onbSwitch(isDark,
            title: 'Vyžadovat podpis zákazníka',
            subtitle:
                'Při vypnutí se krok s podpisem v příjmu zobrazí bez podpisového plátna.',
            value: _podpisPovolen,
            onChanged: (v) => setState(() => _podpisPovolen = v)),
        _onbSwitch(isDark,
            title: 'Povinná SPZ vozidla',
            subtitle:
                'Při vypnutí lze příjem odeslat i bez vyplněné SPZ (např. vozidla bez registrace).',
            value: _spzPovinne,
            onChanged: (v) => setState(() => _spzPovinne = v)),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        const Text('Typy záznamu',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        const Text(
            'Slouží k rozlišení příjmu vozidla (např. Servis, Výkup). První typ je výchozí.',
            style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 16),
        for (int i = 0; i < _typyZaznamu.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3A5F) : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
            ),
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              title: Text(_typyZaznamu[i],
                  style: const TextStyle(fontSize: 14)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_defaultTypZaznamu == _typyZaznamu[i])
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Chip(
                        label: Text('výchozí',
                            style: TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 18, color: Colors.blue),
                    onPressed: () => _otevritDialogTypuZaznamu(
                        initialText: _typyZaznamu[i], editIndex: i),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: Colors.redAccent),
                    onPressed: _typyZaznamu.length <= 1
                        ? null
                        : () => setState(() {
                              final deleted = _typyZaznamu[i];
                              _typyZaznamu.removeAt(i);
                              if (_defaultTypZaznamu == deleted) {
                                _defaultTypZaznamu = _typyZaznamu.first;
                              }
                            }),
                  ),
                ],
              ),
              onLongPress: () =>
                  setState(() => _defaultTypZaznamu = _typyZaznamu[i]),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _otevritDialogTypuZaznamu(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Přidat typ'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.indigo,
              side: const BorderSide(color: Colors.indigo),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text('Dlouhý stisk = nastavit jako výchozí.',
            style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        const Text('Osobní nastavení',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (_biometricAvailable)
          _onbSwitch(isDark,
              icon: Icons.fingerprint,
              title: 'Biometrické přihlášení',
              subtitle: 'Face ID / otisk prstu při každém spuštění.',
              value: _biometricEnabled,
              onChanged: _toggleBiometric),
        _onbSwitch(isDark,
            icon: Icons.pan_tool_alt,
            title: 'Režim pro leváky',
            subtitle:
                'Spoušť fotoaparátu vlevo, když je zařízení na šířku.',
            value: _spoustVlevo,
            onChanged: (v) => setState(() => _spoustVlevo = v)),
      ],
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
