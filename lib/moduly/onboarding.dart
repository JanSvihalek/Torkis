import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'trial_welcome_screen.dart';
import '../core/constants.dart';
import '../l10n/app_localizations.dart';

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
  // Formát automaticky generovaného čísla zakázky (typDokladu = 'zakazka').
  // Stejné klíče čte generátor v prijem_vozidla.dart i konfigurátor v nastavení.
  String _cisloPrefix = 'ZAK';
  String _cisloRokFormat = '{YYYY}'; // '{YYYY}', '{YY}', ''
  String _cisloMesicFormat = '{MM}'; // '{MM}', ''
  String _cisloOddelovac = '-'; // '-', '/', '_', ''
  double _cisloDelka = 5.0; // 3 až 6
  bool _podpisPovolen = true;
  bool _spzPovinne = true;
  final List<String> _typyZaznamu = ['Servis', 'Výkup'];
  String _defaultTypZaznamu = 'Servis';
  // Předdefinované popisy poškození pro značení ve fotodokumentaci.
  final List<String> _vzoryPoskozeni = [];
  // Checklist příjmu (panel při příjmu na tabletu).
  bool _checklistPovolen = false;
  final List<String> _checklistPolozky = [];

  // KROK 2: Osobní nastavení
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _spoustVlevo = false;
  bool _ukladatDoZarizeni = false;

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
    final l10n = AppLocalizations.of(context);
    final ico = _icoController.text.trim();
    if (ico.isEmpty || ico.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.onbAresChybaIco),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.onbAresNacteno),
            backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.onbAresNenalezeno),
            backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.onbAresChyba(e.toString())),
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
    final l10n = AppLocalizations.of(context);
    if (value) {
      try {
        final ok = await LocalAuthentication().authenticate(
          localizedReason: l10n.onbBiometricReason,
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
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: initialText ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E3A5F) : Colors.white,
        title: Text(editIndex != null ? l10n.onbDialogUpravitTyp : l10n.onbDialogNovyTyp),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.onbDialogNazevTypuHint,
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
            child: Text(l10n.onbZrusit),
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
            child: Text(l10n.onbUlozit),
          ),
        ],
      ),
    );
  }

  /// Dialog pro přidání/úpravu vzoru popisu poškození.
  void _otevritDialogVzoru({String? initialText, int? editIndex}) {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: initialText ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E3A5F) : Colors.white,
        title: Text(
            editIndex != null ? l10n.onbDialogUpravitVzor : l10n.onbDialogNovyVzor),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: l10n.onbVzorHint,
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
            child: Text(l10n.onbZrusit),
          ),
          ElevatedButton(
            onPressed: () {
              final text = ctrl.text.trim();
              if (text.isEmpty) return;
              setState(() {
                if (editIndex != null) {
                  _vzoryPoskozeni[editIndex] = text;
                } else {
                  _vzoryPoskozeni.add(text);
                }
              });
              Navigator.pop(ctx);
            },
            child: Text(l10n.onbUlozit),
          ),
        ],
      ),
    );
  }

  /// Dialog pro přidání/úpravu položky checklistu příjmu.
  void _otevritDialogChecklistu({String? initialText, int? editIndex}) {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController(text: initialText ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E3A5F) : Colors.white,
        title: Text(editIndex != null
            ? l10n.nastUpravitChecklistPolozku
            : l10n.nastNovaChecklistPolozka),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: l10n.nastChecklistPolozkaHint,
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
            child: Text(l10n.onbZrusit),
          ),
          ElevatedButton(
            onPressed: () {
              final text = ctrl.text.trim();
              if (text.isEmpty) return;
              setState(() {
                if (editIndex != null) {
                  _checklistPolozky[editIndex] = text;
                } else {
                  _checklistPolozky.add(text);
                }
              });
              Navigator.pop(ctx);
            },
            child: Text(l10n.onbUlozit),
          ),
        ],
      ),
    );
  }

  Future<void> _dokoncitNastaveni() async {
    final l10n = AppLocalizations.of(context);
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
              // Formát čísla zakázky (čte generátor v prijem_vozidla.dart).
              'prefix_zakazka': _cisloPrefix.trim().toUpperCase(),
              'cfg_rok_zakazka': _cisloRokFormat,
              'cfg_mesic_zakazka': _cisloMesicFormat,
              'cfg_oddelovac_zakazka': _cisloOddelovac,
              'cfg_delka_zakazka': _cisloDelka.toInt(),
              'podpis_povolen': _podpisPovolen,
              'spz_povinne': _spzPovinne,
              'typy_zaznamu': _typyZaznamu,
              'default_typ_zaznamu': _defaultTypZaznamu,
              'vzory_poskozeni': _vzoryPoskozeni,
              'checklist_povolen': _checklistPovolen,
              'checklist_polozky': _checklistPolozky,
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
        await prefs.setBool(kPrefUkladatFotoDoZarizeni, _ukladatDoZarizeni);
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
          content: Text(l10n.onbChybaUkladani(e.toString())),
          backgroundColor: Colors.red));
      setState(() => _isSaving = false);
    }
  }

  void _moveNext() {
    final l10n = AppLocalizations.of(context);
    if (_currentPage == 0 && _nazevController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.onbChybaNazev),
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
    final l10n = AppLocalizations.of(context);

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
                                  ? l10n.onbDokoncit
                                  : l10n.onbPokracovat,
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

  // Řádek editovatelného seznamu (vzory poškození, položky checklistu).
  Widget _buildSeznamPolozka(bool isDark,
      {required String text,
      required VoidCallback onEdit,
      required VoidCallback onDelete}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A5F) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        title: Text(text, style: const TextStyle(fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  // Maska formátu (interní zápis), shodná s konfigurátorem v nastavení.
  String _cisloMaska() {
    final casti = <String>[];
    if (_cisloPrefix.isNotEmpty) casti.add('{PREFIX}');
    if (_cisloRokFormat.isNotEmpty) casti.add(_cisloRokFormat);
    if (_cisloMesicFormat.isNotEmpty) casti.add(_cisloMesicFormat);
    casti.add('{NUM${_cisloDelka.toInt()}}');
    return casti.join(_cisloOddelovac);
  }

  // Živý náhled čísla pro aktuální datum (bez závislosti na intl).
  String _cisloNahled() {
    final ted = DateTime.now();
    final delka = _cisloDelka.toInt();
    String n = _cisloMaska();
    n = n.replaceAll('{PREFIX}', _cisloPrefix.toUpperCase());
    n = n.replaceAll('{YYYY}', ted.year.toString());
    n = n.replaceAll('{YY}', (ted.year % 100).toString().padLeft(2, '0'));
    n = n.replaceAll('{MM}', ted.month.toString().padLeft(2, '0'));
    n = n.replaceAll('{NUM$delka}', '1'.padLeft(delka, '0'));
    return n;
  }

  // Konfigurátor formátu čísla zakázky — zobrazí se pod přepínačem auto-čísla.
  Widget _buildFormatCisla(bool isDark, AppLocalizations l10n) {
    final fill = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white;
    InputDecoration dek(String label) => InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: fill,
        );
    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A5F) : Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.nastFormatZakazek,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          // Živý náhled
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(l10n.nastNahledLabel,
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(_cisloNahled(),
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.blue)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _cisloPrefix,
                  textCapitalization: TextCapitalization.characters,
                  decoration: dek(l10n.nastPrefix),
                  onChanged: (val) => setState(() => _cisloPrefix = val.trim()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _cisloOddelovac,
                  decoration: dek(l10n.nastOddelovac),
                  items: [
                    DropdownMenuItem(
                        value: '-', child: Text(l10n.nastOddelovacPomlcka)),
                    DropdownMenuItem(
                        value: '/', child: Text(l10n.nastOddelovacLomitko)),
                    DropdownMenuItem(
                        value: '_', child: Text(l10n.nastOddelovacPodtrzitko)),
                    DropdownMenuItem(
                        value: '', child: Text(l10n.nastOddelovacBez)),
                  ],
                  onChanged: (val) =>
                      setState(() => _cisloOddelovac = val ?? ''),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _cisloRokFormat,
                  decoration: dek(l10n.nastRokFormat),
                  items: [
                    DropdownMenuItem(
                        value: '{YYYY}', child: Text(l10n.nastRok4)),
                    DropdownMenuItem(value: '{YY}', child: Text(l10n.nastRok2)),
                    DropdownMenuItem(value: '', child: Text(l10n.nastBezRoku)),
                  ],
                  onChanged: (val) =>
                      setState(() => _cisloRokFormat = val ?? ''),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _cisloMesicFormat,
                  decoration: dek(l10n.nastMesicFormat),
                  items: [
                    DropdownMenuItem(
                        value: '{MM}', child: Text(l10n.nastMesic2)),
                    DropdownMenuItem(
                        value: '', child: Text(l10n.nastBezMesice)),
                  ],
                  onChanged: (val) =>
                      setState(() => _cisloMesicFormat = val ?? ''),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.nastDelkaCitadla(_cisloDelka.toInt()),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Slider(
            value: _cisloDelka,
            min: 3,
            max: 6,
            divisions: 3,
            activeColor: Colors.blue,
            label: _cisloDelka.toInt().toString(),
            onChanged: (val) => setState(() => _cisloDelka = val),
          ),
        ],
      ),
    );
  }

  // ── KROK 1: Základní informace ──────────────────────────────────────────
  // IČO (ARES lookup), název servisu, DIČ, zápis v rejstříku, sídlo a kontakt,
  // e-mail, přepínač e-mailů, tmavý režim, jméno majitele (admin účet).
  Widget _buildStep1(bool isDark) {
    final l10n = AppLocalizations.of(context);
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
          Text(l10n.onbKrok1Nadpis,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(l10n.onbKrok1Popis,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 40),
          Text(l10n.onbIcoLabel,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _icoController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: l10n.onbIcoHint,
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
                      tooltip: l10n.onbAresLoadTooltip),
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
          Text(l10n.onbNazevLabel,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _nazevController,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: l10n.onbNazevHint,
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
              label: l10n.onbDicLabel,
              ctrl: _dicController,
              hint: l10n.onbDicHint,
              icon: Icons.badge,
              iconColor: Colors.blueGrey),
          const SizedBox(height: 20),
          _onbField(isDark,
              label: l10n.onbRegistraceLabel,
              ctrl: _registraceController,
              hint: l10n.onbRegistraceHint,
              icon: Icons.gavel,
              iconColor: Colors.blueGrey),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),
          Text(l10n.onbSidloNadpis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(l10n.onbSidloPopis,
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          _onbField(isDark,
              label: l10n.onbUliceLabel,
              ctrl: _adresaController,
              hint: l10n.onbUliceHint,
              icon: Icons.map),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _onbField(isDark,
                    label: l10n.onbMestoLabel,
                    ctrl: _mestoController,
                    hint: l10n.onbMestoHint,
                    icon: Icons.location_city),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: _onbField(isDark,
                    label: l10n.onbPscLabel,
                    ctrl: _pscController,
                    hint: '60200',
                    icon: Icons.markunread_mailbox,
                    keyboard: TextInputType.number),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _onbField(isDark,
              label: l10n.onbTelefonLabel,
              ctrl: _telefonController,
              hint: l10n.onbTelefonHint,
              icon: Icons.phone,
              keyboard: TextInputType.phone),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),
          Text(l10n.onbKomunikaceNadpis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(l10n.onbEmailLabel,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _emailServisuController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: l10n.onbEmailHint,
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
              title: Text(l10n.onbEmailySwitchTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(l10n.onbEmailySwitchSubtitle,
                  style: const TextStyle(fontSize: 12)),
              value: _defaultOdeslatEmaily,
              activeColor: Colors.blue,
              onChanged: (val) => setState(() => _defaultOdeslatEmaily = val),
            ),
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),
          Text(l10n.onbAdminNadpis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(l10n.onbAdminPopis,
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 15),
          TextField(
            controller: _jmenoMajiteleController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.onbJmenoLabel,
              hintText: l10n.onbJmenoHint,
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
              title: Text(l10n.onbTmavyRezimTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(l10n.onbTmavyRezimSubtitle,
                  style: const TextStyle(fontSize: 12)),
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
    final l10n = AppLocalizations.of(context);
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
        Text(l10n.onbKrok2Nadpis,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(l10n.onbKrok2Popis,
            style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 30),
        _onbSwitch(isDark,
            title: l10n.onbAutoCisloTitle,
            subtitle: l10n.onbAutoCisloSubtitle,
            value: _autoCisloZakazky,
            onChanged: (v) => setState(() => _autoCisloZakazky = v)),
        if (_autoCisloZakazky) _buildFormatCisla(isDark, l10n),
        _onbSwitch(isDark,
            title: l10n.onbPodpisTitle,
            subtitle: l10n.onbPodpisSubtitle,
            value: _podpisPovolen,
            onChanged: (v) => setState(() => _podpisPovolen = v)),
        _onbSwitch(isDark,
            title: l10n.onbSpzTitle,
            subtitle: l10n.onbSpzSubtitle,
            value: _spzPovinne,
            onChanged: (v) => setState(() => _spzPovinne = v)),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        Text(l10n.onbTypyNadpis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(l10n.onbTypyPopis,
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
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
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Chip(
                        label: Text(l10n.onbTypyVychozi,
                            style: const TextStyle(fontSize: 11)),
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
            label: Text(l10n.onbPridatTyp),
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
        Text(l10n.onbTypyHint,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        // ── Vzory popisů poškození ──────────────────────────────────────
        Text(l10n.onbVzoryNadpis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(l10n.onbVzoryPopis,
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 16),
        if (_vzoryPoskozeni.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(l10n.onbVzoryPrazdne,
                style: TextStyle(fontSize: 13, color: Colors.grey[400])),
          ),
        for (int i = 0; i < _vzoryPoskozeni.length; i++)
          _buildSeznamPolozka(
            isDark,
            text: _vzoryPoskozeni[i],
            onEdit: () => _otevritDialogVzoru(
                initialText: _vzoryPoskozeni[i], editIndex: i),
            onDelete: () => setState(() => _vzoryPoskozeni.removeAt(i)),
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _otevritDialogVzoru(),
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.onbPridatVzor),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.deepOrange,
              side: const BorderSide(color: Colors.deepOrange),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        // ── Checklist příjmu ────────────────────────────────────────────
        Text(l10n.nastChecklistTitul,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _onbSwitch(isDark,
            icon: Icons.checklist_rounded,
            title: l10n.nastChecklistPovolen,
            subtitle: l10n.nastChecklistPovolenSub,
            value: _checklistPovolen,
            onChanged: (v) => setState(() => _checklistPovolen = v)),
        if (_checklistPovolen) ...[
          if (_checklistPolozky.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(l10n.nastChecklistPrazdny,
                  style: TextStyle(fontSize: 13, color: Colors.grey[400])),
            ),
          for (int i = 0; i < _checklistPolozky.length; i++)
            _buildSeznamPolozka(
              isDark,
              text: _checklistPolozky[i],
              onEdit: () => _otevritDialogChecklistu(
                  initialText: _checklistPolozky[i], editIndex: i),
              onDelete: () => setState(() => _checklistPolozky.removeAt(i)),
            ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _otevritDialogChecklistu(),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.nastPridatChecklistPolozku),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 20),
        Text(l10n.onbOsobniNadpis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (_biometricAvailable)
          _onbSwitch(isDark,
              icon: Icons.fingerprint,
              title: l10n.onbBiometrieTitle,
              subtitle: l10n.onbBiometrieSubtitle,
              value: _biometricEnabled,
              onChanged: _toggleBiometric),
        _onbSwitch(isDark,
            icon: Icons.pan_tool_alt,
            title: l10n.onbLevacTitle,
            subtitle: l10n.onbLevacSubtitle,
            value: _spoustVlevo,
            onChanged: (v) => setState(() => _spoustVlevo = v)),
        _onbSwitch(isDark,
            icon: Icons.photo_library_outlined,
            title: l10n.nastUlozitDoZarizeniTitle,
            subtitle: l10n.nastUlozitDoZarizeniSub,
            value: _ukladatDoZarizeni,
            onChanged: (v) => setState(() => _ukladatDoZarizeni = v)),
      ],
    );
  }

  // ── KROK 3: Katalog úkonů ───────────────────────────────────────────────
  // Přednastavené úkony servisu — každý má název, cenu bez DPH, odhadovaný čas,
  // jednotku času (hod/min) a kategorii. Uloží se do samostatné kolekce 'ukony'.
  Widget _buildStep3(bool isDark) {
    final l10n = AppLocalizations.of(context);
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
        Text(l10n.onbKrok3Nadpis,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(l10n.onbKrok3Popis,
            style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
                          labelText: l10n.onbUkonNazevLabel,
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
                          labelText: l10n.onbUkonCenaLabel,
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
                          labelText: l10n.onbUkonCasLabel,
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
                      children: [Text(l10n.onbUkonHod), Text(l10n.onbUkonMin)],
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
                    labelText: l10n.onbUkonCelkovaCenaLabel,
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
                    labelText: l10n.onbUkonKategorieLabel,
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
            label: Text(l10n.onbPridatUkon,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        const SizedBox(height: 20),
      ],
    );
  }
}
