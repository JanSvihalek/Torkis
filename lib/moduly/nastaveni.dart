import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../core/constants.dart';
import '../core/design_tokens.dart';
import '../l10n/app_localizations.dart';
import 'auth_gate.dart'; // Kvůli globalUserRole a globalServisId
import 'main_screen.dart'; // Kvůli navOrderNotifier
import 'app_logger.dart'; // Přidán náš logger pro odchytávání chyb
import 'predplatne_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Kontroléry pro Admina
  final _nazevCtrl = TextEditingController();
  final _icoCtrl = TextEditingController();
  final _dicCtrl = TextEditingController();
  final _adresaCtrl = TextEditingController();
  final _mestoCtrl = TextEditingController();
  final _pscCtrl = TextEditingController();
  final _telefonCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _registraceCtrl = TextEditingController();

  bool _defaultEmail = true;
  bool _autoCisloZakazky = true;
  bool _podpisPovolen = true;
  bool _spzPovinne = true;
  List<String> _sablonyZprav = [];
  List<String> _typyZaznamu = ['Servis', 'Výkup'];
  String _defaultTypZaznamu = 'Servis';

  // Uživatelské nastavení (pro všechny)
  bool _tmavyRezim = false;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _spoustVlevo = false;
  bool _ukladatDoZarizeni = false;
  String? _jazyk; // null = systémový jazyk

  bool _isLoading = true;
  bool _isSaving = false;

  bool get _isAdmin => globalUserRole == 'admin';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _nazevCtrl.dispose();
    _icoCtrl.dispose();
    _dicCtrl.dispose();
    _adresaCtrl.dispose();
    _mestoCtrl.dispose();
    _pscCtrl.dispose();
    _telefonCtrl.dispose();
    _emailCtrl.dispose();
    _registraceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('uzivatele')
          .doc(user.uid)
          .get();
      final prefs = await SharedPreferences.getInstance();
      if (userDoc.exists) {
        final vlevo = userDoc.data()!['kamera_spoust_vlevo'] as bool? ?? false;
        setState(() {
          _tmavyRezim = userDoc.data()!['tmavy_rezim'] ?? false;
          _spoustVlevo = vlevo;
        });
        // Zrcadlíme do SharedPreferences — odtud čte fotoaparát.
        await prefs.setBool(kPrefKameraSpoustVlevo, vlevo);
      }

      _jazyk = prefs.getString('jazyk');

      final auth = LocalAuthentication();
      final canBio = await auth.canCheckBiometrics;
      setState(() {
        _biometricAvailable = canBio;
        _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
        _ukladatDoZarizeni =
            prefs.getBool(kPrefUkladatFotoDoZarizeni) ?? false;
      });

      if (_isAdmin && globalServisId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('nastaveni_servisu')
            .doc(globalServisId)
            .get();
        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _nazevCtrl.text = data['nazev_servisu'] ?? '';
            _icoCtrl.text = data['ico_servisu'] ?? '';
            _dicCtrl.text = data['dic_servisu'] ?? '';
            _adresaCtrl.text = data['adresa_servisu'] ?? '';
            _mestoCtrl.text = data['mesto_servisu'] ?? '';
            _pscCtrl.text = data['psc_servisu'] ?? '';
            _telefonCtrl.text = data['telefon_servisu'] ?? '';
            _emailCtrl.text = data['email_servisu'] ?? '';
            _registraceCtrl.text = data['registrace_servisu'] ?? '';
            _defaultEmail = data['default_odesilat_emaily'] ?? true;
            _autoCisloZakazky = data['auto_cislo_zakazky'] ?? true;
            _podpisPovolen = data['podpis_povolen'] as bool? ?? true;
            _spzPovinne = data['spz_povinne'] as bool? ?? true;
            _sablonyZprav = List<String>.from(data['sablony_zprav'] ?? []);
            _typyZaznamu = List<String>.from(
                data['typy_zaznamu'] ?? ['Servis', 'Výkup']);
            if (_typyZaznamu.isEmpty) _typyZaznamu = ['Servis', 'Výkup'];
            _defaultTypZaznamu = data['default_typ_zaznamu']?.toString() ??
                _typyZaznamu.first;
          });
        }
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('uzivatele')
            .doc(user.uid)
            .set({
          'tmavy_rezim': _tmavyRezim,
        }, SetOptions(merge: true));

        if (_isAdmin && globalServisId != null) {
          await FirebaseFirestore.instance
              .collection('nastaveni_servisu')
              .doc(globalServisId)
              .set({
            'nazev_servisu': _nazevCtrl.text.trim(),
            'ico_servisu': _icoCtrl.text.trim(),
            'dic_servisu': _dicCtrl.text.trim(),
            'adresa_servisu': _adresaCtrl.text.trim(),
            'mesto_servisu': _mestoCtrl.text.trim(),
            'psc_servisu': _pscCtrl.text.trim(),
            'telefon_servisu': _telefonCtrl.text.trim(),
            'email_servisu': _emailCtrl.text.trim(),
            'registrace_servisu': _registraceCtrl.text.trim(),
            'default_odesilat_emaily': _defaultEmail,
            'auto_cislo_zakazky': _autoCisloZakazky,
            'podpis_povolen': _podpisPovolen,
            'spz_povinne': _spzPovinne,
            'zmeneno': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        themeNotifier.value = _tmavyRezim ? ThemeMode.dark : ThemeMode.light;

        // Uložení do SharedPreferences — načte se při příštím startu
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('tmavy_rezim', _tmavyRezim);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(l10n.nastUlozeno),
              backgroundColor: Colors.green));
        }
      }
    } catch (e, stackTrace) {
      await AppLogger.logError('Ukládání hlavního nastavení servisu', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.nastChyba(e.toString())), backgroundColor: Colors.red));
      }
    }
    setState(() => _isSaving = false);
  }


  Future<void> _toggleBiometric(bool value) async {
    final l10n = AppLocalizations.of(context);
    if (value) {
      final auth = LocalAuthentication();
      final ok = await auth.authenticate(
        localizedReason: l10n.nastBiometricReason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
      if (!ok) return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);
    setState(() => _biometricEnabled = value);
  }

  Future<void> _setJazyk(String? kod) async {
    final prefs = await SharedPreferences.getInstance();
    if (kod == null) {
      await prefs.remove('jazyk');
    } else {
      await prefs.setString('jazyk', kod);
    }
    localeNotifier.value = kod != null ? Locale(kod) : null;
    if (mounted) setState(() => _jazyk = kod);
  }

  void _ukazatVyberJazyka(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final jazyky = [
      (kod: null as String?,  vlajka: '🌐', nazev: l10n.nastSystJazyk),
      (kod: 'cs',  vlajka: '🇨🇿', nazev: 'Čeština'),
      (kod: 'en',  vlajka: '🇬🇧', nazev: 'English'),
      (kod: 'de',  vlajka: '🇩🇪', nazev: 'Deutsch'),
      (kod: 'pl',  vlajka: '🇵🇱', nazev: 'Polski'),
      (kod: 'sk',  vlajka: '🇸🇰', nazev: 'Slovenčina'),
    ];

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.nastJazyk,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: jazyky.map((j) => RadioListTile<String?>(
              value: j.kod,
              groupValue: _jazyk,
              activeColor: Colors.blue,
              title: Text('${j.vlajka}  ${j.nazev}',
                  style: const TextStyle(fontSize: 14)),
              onChanged: (v) {
                setDialogState(() {});
                _setJazyk(v);
                Navigator.pop(ctx);
              },
            )).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.nastZrusit),
            ),
          ],
        ),
      ),
    );
  }

  /// Přepne osobní režim pro leváky — spoušť fotoaparátu na levé straně při
  /// orientaci na šířku. Ukládá lokálně (čte fotoaparát) i do účtu uživatele.
  Future<void> _toggleSpoustVlevo(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefKameraSpoustVlevo, value);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('uzivatele')
          .doc(user.uid)
          .set({'kamera_spoust_vlevo': value}, SetOptions(merge: true));
    }
    if (mounted) setState(() => _spoustVlevo = value);
  }

  /// Přepne osobní (per-zařízení) volbu ukládání fotek z příjmu i do galerie.
  Future<void> _toggleUkladatDoZarizeni(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefUkladatFotoDoZarizeni, value);
    if (mounted) setState(() => _ukladatDoZarizeni = value);
  }

  Future<void> _ulozitSablony() async {
    if (globalServisId == null) return;
    await FirebaseFirestore.instance
        .collection('nastaveni_servisu')
        .doc(globalServisId)
        .set({'sablony_zprav': _sablonyZprav}, SetOptions(merge: true));
  }

  Future<void> _ulozitTypyZaznamu() async {
    if (globalServisId == null) return;
    await FirebaseFirestore.instance
        .collection('nastaveni_servisu')
        .doc(globalServisId)
        .set({
      'typy_zaznamu': _typyZaznamu,
      'default_typ_zaznamu': _defaultTypZaznamu,
    }, SetOptions(merge: true));
  }

  void _otevritDialogTypuZaznamu({String? initialText, int? editIndex}) {
    final ctrl = TextEditingController(text: initialText ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? TokColors.darkSurface : Colors.white,
        title: Text(editIndex != null ? l10n.nastUpravitTyp : l10n.nastNovyTyp),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.nastTypHint,
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
            child: Text(l10n.nastZrusit),
          ),
          ElevatedButton(
            onPressed: () async {
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
              await _ulozitTypyZaznamu();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.nastUlozitBtn),
          ),
        ],
      ),
    );
  }

  void _otevritDialogSablony({String? initialText, int? editIndex}) {
    final ctrl = TextEditingController(text: initialText ?? '');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? TokColors.darkSurface : Colors.white,
        title: Text(editIndex != null ? l10n.nastUpravitSablonu : l10n.nastNovaSablona),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: l10n.nastSablonaHint,
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[100],
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.nastZrusit),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = ctrl.text.trim();
              if (text.isEmpty) return;
              setState(() {
                if (editIndex != null) {
                  _sablonyZprav[editIndex] = text;
                } else {
                  _sablonyZprav.add(text);
                }
              });
              await _ulozitSablony();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(l10n.nastUlozitBtn),
          ),
        ],
      ),
    );
  }

  /// Uloží pořadí záložek do Firestore (uzivatele/{uid}) i do SharedPreferences.
  /// Firestore = zdrojová pravda (sync mezi zařízeními),
  /// SharedPreferences = lokální cache pro okamžité načtení při příštím startu.
  Future<void> _saveNavOrder(List<String> order) async {
    navOrderNotifier.value = List.from(order);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('nav_order', order);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('uzivatele')
          .doc(user.uid)
          .set({'nav_order': order}, SetOptions(merge: true))
          .catchError((e) => debugPrint('Chyba uložení nav_order: $e'));
    }
  }

  // --- FUNKCE PRO VYKRESLENÍ DIALOGU KONFIGURACE ČÍSLOVÁNÍ ---
  void _otevritKonfiguratorCislovani(String typDokladu, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _FormatCislovaniSheet(typDokladu: typDokladu),
    );
  }

  // --- FUNKCE PRO VYKRESLENÍ DIALOGU NA PŘESKLÁDÁNÍ A PŘIDÁVÁNÍ MODULŮ ---
  void _ukazatReorderingDialog(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    List<String> lokalniPoradi = List.from(navOrderNotifier.value);

    final Map<String, Map<String, dynamic>> vizual = {
      'prijem': {'nazev': l10n.nastModPrijem, 'ikona': Icons.add_circle_outline_rounded},
      'historie_prijmu': {'nazev': l10n.nastModHistorie, 'ikona': Icons.history_rounded},
      'menu': {'nazev': l10n.nastModMenu, 'ikona': Icons.grid_view},
      'vozidla': {'nazev': l10n.nastModVozidla, 'ikona': Icons.directions_car_outlined},
      'ukony': {'nazev': l10n.nastModUkony, 'ikona': Icons.playlist_add_check_circle_outlined},
      'zakaznici': {'nazev': l10n.nastModZakaznici, 'ikona': Icons.people_alt_outlined},
      'zamestnanci': {'nazev': l10n.nastModTym, 'ikona': Icons.badge_outlined},
      'statistiky': {'nazev': l10n.nastModStatistiky, 'ikona': Icons.bar_chart_outlined},
      'nastaveni': {'nazev': l10n.nastModNastaveni, 'ikona': Icons.settings_outlined},
      'vin_dekoder': {'nazev': l10n.nastModVin, 'ikona': Icons.travel_explore_outlined},
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                color: isDark ? TokColors.darkSurface : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 5,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.nastPrizpusobitListu, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(l10n.nastListaPopis, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 15),
                  
                  Expanded(
                    child: ReorderableListView(
                      onReorder: (oldIndex, newIndex) async {
                        setModalState(() {
                          if (newIndex > oldIndex) {
                            newIndex -= 1;
                          }
                          final item = lokalniPoradi.removeAt(oldIndex);
                          lokalniPoradi.insert(newIndex, item);
                        });
                        await _saveNavOrder(lokalniPoradi);
                      },
                      children: [
                        for (int i = 0; i < lokalniPoradi.length; i++)
                          Card(
                            key: ValueKey(lokalniPoradi[i]),
                            color: isDark ? TokColors.darkSurface : Colors.grey[50],
                            elevation: 0,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: Icon(vizual[lokalniPoradi[i]]!['ikona'], color: Colors.blue),
                              title: Text(vizual[lokalniPoradi[i]]!['nazev'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (lokalniPoradi[i] == 'menu')
                                    Tooltip(
                                      message: l10n.nastMenuNelzeOdebrat,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 12),
                                        child: Icon(Icons.lock_outline, color: Colors.grey, size: 20),
                                      ),
                                    )
                                  else if (lokalniPoradi.length > 2)
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                      onPressed: () async {
                                        setModalState(() {
                                          lokalniPoradi.removeAt(i);
                                        });
                                        await _saveNavOrder(lokalniPoradi);
                                      },
                                    ),
                                  const Icon(Icons.drag_handle, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  if (lokalniPoradi.length < 5)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Center(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                final dostupne = vizual.keys.where((k) => !lokalniPoradi.contains(k)).toList();
                                return AlertDialog(
                                  title: Text(l10n.nastVybrModul),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: dostupne.length,
                                      itemBuilder: (c, i) {
                                        final key = dostupne[i];
                                        return ListTile(
                                          leading: Icon(vizual[key]!['ikona'], color: Colors.blueGrey),
                                          title: Text(vizual[key]!['nazev']),
                                          onTap: () async {
                                            setModalState(() {
                                              lokalniPoradi.add(key);
                                            });
                                            await _saveNavOrder(lokalniPoradi);
                                            if (context.mounted) Navigator.pop(ctx);
                                          },
                                        );
                                      }
                                    ),
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.nastZavrit)),
                                  ],
                                );
                              }
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: Text(l10n.nastPridatZalozku),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                          ),
                        ),
                      ),
                    ),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(l10n.nastHotovo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isAdmin ? l10n.nastTitulAdmin : l10n.nastTitulUzivatel,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                        _isAdmin
                            ? l10n.nastPodtitulAdmin
                            : l10n.nastPodtitulUzivatel,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveSettings,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check_circle),
                label: Text(l10n.nastUlozit,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: Size.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ---------------------------------------------
              // PŘEDPLATNÉ — info karta nahoře
              // ---------------------------------------------
              if (_isAdmin) ...[
                const _SubscriptionStatusCard(),
                const SizedBox(height: 16),
              ],
              // ---------------------------------------------
              // SEKCE PRO ADMINA (FIREMNÍ ÚDAJE)
              // ---------------------------------------------
              if (_isAdmin) ...[
                _buildCard(
                  title: l10n.nastFiremniUdaje,
                  icon: Icons.business,
                  color: Colors.blue,
                  isDark: isDark,
                  children: [
                    _buildInput(_nazevCtrl, l10n.nastObchodniJmeno,
                        Icons.store, isDark),
                    Row(
                      children: [
                        Expanded(
                            child: _buildInput(
                                _icoCtrl, l10n.nastIco, Icons.numbers, isDark)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _buildInput(
                                _dicCtrl, l10n.nastDic, Icons.badge, isDark)),
                      ],
                    ),
                    _buildInput(
                        _registraceCtrl,
                        l10n.nastRejstrik,
                        Icons.gavel,
                        isDark),
                  ],
                ),
                _buildCard(
                  title: l10n.nastSidloKontakt,
                  icon: Icons.location_on,
                  color: Colors.orange,
                  isDark: isDark,
                  children: [
                    _buildInput(_adresaCtrl, l10n.nastUlice, Icons.map, isDark),
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: _buildInput(_mestoCtrl, l10n.nastMesto,
                                Icons.location_city, isDark)),
                        const SizedBox(width: 10),
                        Expanded(
                            flex: 1,
                            child: _buildInput(_pscCtrl, l10n.nastPsc,
                                Icons.mark_email_unread, isDark)),
                      ],
                    ),
                    _buildInput(
                        _telefonCtrl, l10n.nastTelefon, Icons.phone, isDark),
                    _buildInput(_emailCtrl, l10n.nastEmail,
                        Icons.email, isDark),
                  ],
                ),
                _buildCard(
                  title: l10n.nastCislovani,
                  icon: Icons.settings_suggest,
                  color: Colors.purple,
                  isDark: isDark,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? TokColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.build_circle_outlined, color: Colors.blue),
                        title: Text(l10n.nastFormatZakazek, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.edit, size: 18),
                        onTap: () => _otevritKonfiguratorCislovani('zakazka', isDark),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                          color: isDark ? TokColors.darkSurface : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10)),
                      child: SwitchListTile(
                        title: Text(l10n.nastAutoEmail,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(l10n.nastAutoEmailSub,
                            style: const TextStyle(fontSize: 12)),
                        value: _defaultEmail,
                        activeColor: Colors.blue,
                        onChanged: (v) => setState(() => _defaultEmail = v),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                          color: isDark ? TokColors.darkSurface : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10)),
                      child: SwitchListTile(
                        title: Text(l10n.nastAutoCislo,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(l10n.nastAutoCisloSub,
                            style: const TextStyle(fontSize: 12)),
                        value: _autoCisloZakazky,
                        activeColor: Colors.blue,
                        onChanged: (v) => setState(() => _autoCisloZakazky = v),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                          color: isDark ? TokColors.darkSurface : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10)),
                      child: SwitchListTile(
                        title: Text(l10n.nastPodpisPovolen,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(l10n.nastPodpisPovolenSub,
                            style: const TextStyle(fontSize: 12)),
                        value: _podpisPovolen,
                        activeColor: Colors.blue,
                        onChanged: (v) => setState(() => _podpisPovolen = v),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                          color: isDark ? TokColors.darkSurface : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10)),
                      child: SwitchListTile(
                        title: Text(l10n.nastSpzPovinne,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(l10n.nastSpzPovinneSub,
                            style: const TextStyle(fontSize: 12)),
                        value: _spzPovinne,
                        activeColor: Colors.blue,
                        onChanged: (v) => setState(() => _spzPovinne = v),
                      ),
                    ),
                  ],
                ),
              ],

              // ---------------------------------------------
              // ŠABLONY ZPRÁV
              // ---------------------------------------------
              _buildCard(
                title: l10n.nastSablony,
                icon: Icons.chat_bubble_outline,
                color: Colors.teal,
                isDark: isDark,
                children: [
                  Text(
                    l10n.nastSablonyPopis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  if (_sablonyZprav.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        l10n.nastSablonyPrazdne,
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ),
                  for (int i = 0; i < _sablonyZprav.length; i++)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? TokColors.darkSurface
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.grey[200]!),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14),
                        title: Text(_sablonyZprav[i],
                            style: const TextStyle(fontSize: 13)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  size: 18, color: Colors.blue),
                              onPressed: () => _otevritDialogSablony(
                                  initialText: _sablonyZprav[i],
                                  editIndex: i),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: Colors.redAccent),
                              onPressed: () async {
                                setState(
                                    () => _sablonyZprav.removeAt(i));
                                await _ulozitSablony();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _otevritDialogSablony(),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.nastPridatSablonu),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.teal,
                        side: const BorderSide(color: Colors.teal),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),

              _buildCard(
                title: l10n.nastTypyZaznamu,
                icon: Icons.label_outline,
                color: Colors.indigo,
                isDark: isDark,
                children: [
                  Text(
                    l10n.nastTypyZaznamuPopis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  for (int i = 0; i < _typyZaznamu.length; i++)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? TokColors.darkSurface
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.grey[200]!),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14),
                        title: Text(_typyZaznamu[i],
                            style: const TextStyle(fontSize: 13)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_defaultTypZaznamu == _typyZaznamu[i])
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Chip(
                                  label: Text(l10n.nastVychozi,
                                      style: const TextStyle(fontSize: 11)),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  size: 18, color: Colors.blue),
                              onPressed: () => _otevritDialogTypuZaznamu(
                                  initialText: _typyZaznamu[i],
                                  editIndex: i),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: Colors.redAccent),
                              onPressed: _typyZaznamu.length <= 1
                                  ? null
                                  : () async {
                                      final deleted = _typyZaznamu[i];
                                      setState(() {
                                        _typyZaznamu.removeAt(i);
                                        if (_defaultTypZaznamu == deleted) {
                                          _defaultTypZaznamu =
                                              _typyZaznamu.first;
                                        }
                                      });
                                      await _ulozitTypyZaznamu();
                                    },
                            ),
                          ],
                        ),
                        onLongPress: () async {
                          setState(() => _defaultTypZaznamu = _typyZaznamu[i]);
                          await _ulozitTypyZaznamu();
                        },
                      ),
                    ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _otevritDialogTypuZaznamu(),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.nastPridatTyp),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.indigo,
                        side: const BorderSide(color: Colors.indigo),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.nastLongPress,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),

              // ---------------------------------------------
              // SEKCE PRO VŠECHNY UŽIVATELE (VZHLED A ODHLÁŠENÍ)
              // ---------------------------------------------
              _buildCard(
                title: l10n.nastOsobni,
                icon: Icons.person,
                color: Colors.pinkAccent,
                isDark: isDark,
                children: [
                  Card(
                    color: isDark ? TokColors.darkSurface : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.view_column, color: Colors.blue),
                      ),
                      title: Text(l10n.nastPrizpusobitListu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(l10n.nastPrizpusobitListuSub, style: const TextStyle(fontSize: 11)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      onTap: () => _ukazatReorderingDialog(context, isDark),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? TokColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: SwitchListTile(
                      title: Text(l10n.nastTmavyRezim,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(l10n.nastTmavyRezimSub,
                          style: const TextStyle(fontSize: 11)),
                      value: _tmavyRezim,
                      activeColor: Colors.blue,
                      onChanged: (v) => setState(() => _tmavyRezim = v),
                    ),
                  ),
                  if (_biometricAvailable) ...[
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? TokColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: SwitchListTile(
                        secondary: const Icon(Icons.fingerprint, color: Colors.blue),
                        title: Text(l10n.nastBiometrie,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(l10n.nastBiometrieSub,
                            style: const TextStyle(fontSize: 11)),
                        value: _biometricEnabled,
                        activeColor: Colors.blue,
                        onChanged: _toggleBiometric,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? TokColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: SwitchListTile(
                      secondary: const Icon(Icons.pan_tool_alt, color: Colors.blue),
                      title: Text(l10n.nastLeVaci,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(l10n.nastLeVaciSub,
                          style: const TextStyle(fontSize: 11)),
                      value: _spoustVlevo,
                      activeColor: Colors.blue,
                      onChanged: _toggleSpoustVlevo,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? TokColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: SwitchListTile(
                      secondary: const Icon(Icons.photo_library_outlined,
                          color: Colors.blue),
                      title: Text(l10n.nastUlozitDoZarizeniTitle,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(l10n.nastUlozitDoZarizeniSub,
                          style: const TextStyle(fontSize: 11)),
                      value: _ukladatDoZarizeni,
                      activeColor: Colors.blue,
                      onChanged: _toggleUkladatDoZarizeni,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? TokColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.language_rounded, color: Colors.blue),
                      title: Text(l10n.nastJazyk,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(
                        _jazyk == null
                            ? l10n.nastSystJazyk
                            : const {
                                'cs': '🇨🇿 Čeština',
                                'en': '🇬🇧 English',
                                'de': '🇩🇪 Deutsch',
                                'pl': '🇵🇱 Polski',
                                'sk': '🇸🇰 Slovenčina',
                              }[_jazyk] ?? _jazyk!,
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      onTap: () => _ukazatVyberJazyka(context, isDark),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
      {required String title,
      required IconData icon,
      required Color color,
      required List<Widget> children,
      required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TokColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color)),
              const SizedBox(width: 15),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInput(
      TextEditingController ctrl, String label, IconData icon, bool isDark,
      {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        keyboardType: isNum
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: Colors.grey),
          filled: true,
          fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: isDark ? const Color(0xFF424242) : Colors.grey[300]!,
                  width: 1)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: isDark ? const Color(0xFF424242) : Colors.grey[300]!,
                  width: 1)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }
}

// ============================================================================
// NOVÝ WIDGET: INTERAKTIVNÍ KONFIGURÁTOR ČÍSELNÝCH ŘAD
// ============================================================================

class _FormatCislovaniSheet extends StatefulWidget {
  final String typDokladu; // 'faktura' nebo 'zakazka'
  
  const _FormatCislovaniSheet({required this.typDokladu});

  @override
  State<_FormatCislovaniSheet> createState() => _FormatCislovaniSheetState();
}

class _FormatCislovaniSheetState extends State<_FormatCislovaniSheet> {
  String _prefix = '';
  String _rokFormat = '{YYYY}'; // '{YYYY}', '{YY}', ''
  String _mesicFormat = '{MM}'; // '{MM}', ''
  String _oddelovac = '-'; // '-', '/', '_', ''
  double _delkaPocitadla = 5.0; // 3 až 6
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nactiStavajiciNastaveni();
  }

  Future<void> _nactiStavajiciNastaveni() async {
    if (globalServisId == null) return;
    
    // Výchozí hodnoty podle typu
    _prefix = widget.typDokladu == 'faktura' ? 'FAK' : 'ZAK';
    
    try {
      final doc = await FirebaseFirestore.instance.collection('nastaveni_servisu').doc(globalServisId).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (data.containsKey('prefix_${widget.typDokladu}')) {
          _prefix = data['prefix_${widget.typDokladu}'];
        } else {
          final pluralKey = widget.typDokladu == 'faktura' ? 'prefix_faktury' : 'prefix_zakazky';
          if (data.containsKey(pluralKey)) _prefix = data[pluralKey];
        }
        
        // Zkusíme načíst rozložené konfigurační parametry (pokud už si je někdy uložil)
        if (data.containsKey('cfg_rok_${widget.typDokladu}')) _rokFormat = data['cfg_rok_${widget.typDokladu}'];
        if (data.containsKey('cfg_mesic_${widget.typDokladu}')) _mesicFormat = data['cfg_mesic_${widget.typDokladu}'];
        if (data.containsKey('cfg_oddelovac_${widget.typDokladu}')) _oddelovac = data['cfg_oddelovac_${widget.typDokladu}'];
        if (data.containsKey('cfg_delka_${widget.typDokladu}')) {
          _delkaPocitadla = (data['cfg_delka_${widget.typDokladu}'] as num).toDouble();
        }
      }
    } catch (e) {
      debugPrint('Chyba načítání masky: $e');
    }
    
    setState(() => _isLoading = false);
  }

  String _vygenerujMasku() {
    List<String> casti = [];
    if (_prefix.isNotEmpty) casti.add('{PREFIX}');
    if (_rokFormat.isNotEmpty) casti.add(_rokFormat);
    if (_mesicFormat.isNotEmpty) casti.add(_mesicFormat);
    casti.add('{NUM${_delkaPocitadla.toInt()}}');
    
    return casti.join(_oddelovac);
  }

  String _vygenerujNahled() {
    final ted = DateTime.now();
    String nahled = _vygenerujMasku();
    
    nahled = nahled.replaceAll('{PREFIX}', _prefix.toUpperCase());
    nahled = nahled.replaceAll('{YYYY}', DateFormat('yyyy').format(ted));
    nahled = nahled.replaceAll('{YY}', DateFormat('yy').format(ted));
    nahled = nahled.replaceAll('{MM}', DateFormat('MM').format(ted));
    
    String cislice = '1'.padLeft(_delkaPocitadla.toInt(), '0');
    nahled = nahled.replaceAll('{NUM${_delkaPocitadla.toInt()}}', cislice);
    
    return nahled;
  }

  Future<void> _ulozitNastaveni() async {
    if (globalServisId == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _isSaving = true);

    try {
      final maska = _vygenerujMasku();

      // Uložíme jak finální masku pro generování, tak jednotlivé dílky pro budoucí úpravy v tomto konfigurátoru
      await FirebaseFirestore.instance.collection('nastaveni_servisu').doc(globalServisId).set({
        'maska_${widget.typDokladu}': maska,
        'prefix_${widget.typDokladu}': _prefix.toUpperCase(),
        'cfg_rok_${widget.typDokladu}': _rokFormat,
        'cfg_mesic_${widget.typDokladu}': _mesicFormat,
        'cfg_oddelovac_${widget.typDokladu}': _oddelovac,
        'cfg_delka_${widget.typDokladu}': _delkaPocitadla.toInt(),
        'zmeneno': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context); // Zavřít BottomSheet
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.nastFormatUlozen), backgroundColor: Colors.green));
      }
    } catch (e, stackTrace) {
      await AppLogger.logError('Uložení masky číslování (${widget.typDokladu})', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.nastChyba(e.toString())), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Vyšší sheet kvůli klávesnici
      decoration: BoxDecoration(
        color: isDark ? TokColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.nastFormatTitle(widget.typDokladu.toUpperCase()), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Náhledový štítek
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(l10n.nastNahledLabel, style: const TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(_vygenerujNahled(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.blue)),
                const SizedBox(height: 10),
                Text(l10n.nastInternaMaska(_vygenerujMasku()), style: GoogleFonts.ibmPlexMono(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // Konfigurační formulář
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _prefix,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: l10n.nastPrefix,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[50],
                          ),
                          onChanged: (val) => setState(() => _prefix = val.trim()),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _oddelovac,
                          decoration: InputDecoration(
                            labelText: l10n.nastOddelovac,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[50],
                          ),
                          items: [
                            DropdownMenuItem(value: '-', child: Text(l10n.nastOddelovacPomlcka)),
                            DropdownMenuItem(value: '/', child: Text(l10n.nastOddelovacLomitko)),
                            DropdownMenuItem(value: '_', child: Text(l10n.nastOddelovacPodtrzitko)),
                            DropdownMenuItem(value: '', child: Text(l10n.nastOddelovacBez)),
                          ],
                          onChanged: (val) => setState(() => _oddelovac = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _rokFormat,
                          decoration: InputDecoration(
                            labelText: l10n.nastRokFormat,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[50],
                          ),
                          items: [
                            DropdownMenuItem(value: '{YYYY}', child: Text(l10n.nastRok4)),
                            DropdownMenuItem(value: '{YY}', child: Text(l10n.nastRok2)),
                            DropdownMenuItem(value: '', child: Text(l10n.nastBezRoku)),
                          ],
                          onChanged: (val) => setState(() => _rokFormat = val!),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _mesicFormat,
                          decoration: InputDecoration(
                            labelText: l10n.nastMesicFormat,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[50],
                          ),
                          items: [
                            DropdownMenuItem(value: '{MM}', child: Text(l10n.nastMesic2)),
                            DropdownMenuItem(value: '', child: Text(l10n.nastBezMesice)),
                          ],
                          onChanged: (val) => setState(() => _mesicFormat = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(l10n.nastDelkaCitadla(_delkaPocitadla.toInt()), style: const TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: _delkaPocitadla,
                    min: 3,
                    max: 6,
                    divisions: 3,
                    activeColor: Colors.blue,
                    label: _delkaPocitadla.toInt().toString(),
                    onChanged: (val) => setState(() => _delkaPocitadla = val),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: const Border(left: BorderSide(color: Colors.orange, width: 4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 10),
                        Expanded(child: Text(l10n.nastInfoZmenaFormatu, style: const TextStyle(fontSize: 12))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _ulozitNastaveni,
                  icon: _isSaving ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save),
                  label: Text(l10n.nastUlozitFormat, style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Karta zobrazená v Nastavení (jen pro admina) — stav předplatného.
/// Pro trial ukazuje zbývající dny + CTA upgrade. Pro placené plány ukazuje
/// plán a platnost. Po vypršení vede na paywall.
class _SubscriptionStatusCard extends StatelessWidget {
  const _SubscriptionStatusCard();

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    final l10n = AppLocalizations.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('predplatne')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 110,
            decoration: BoxDecoration(
              color: tok.surface,
              border: Border.all(color: tok.line),
              borderRadius: BorderRadius.circular(TokRadius.xl),
            ),
            child: const Center(
                child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2))),
          );
        }

        final data =
            snapshot.data!.data() as Map<String, dynamic>? ?? const {};
        final planTyp = (data['plan_typ'] ?? 'trial').toString();
        final trialStart = (data['trial_zacatek'] as Timestamp?)?.toDate();
        final platnostDo = (data['platnost_do'] as Timestamp?)?.toDate();

        final isTrial = planTyp == 'trial';
        final now = DateTime.now();

        int? zbyvajiciDni;
        bool vyprseno = false;
        double progress = 0;

        if (isTrial && trialStart != null) {
          final trialEnd = trialStart.add(const Duration(days: 30));
          if (now.isBefore(trialEnd)) {
            zbyvajiciDni = trialEnd.difference(now).inDays + 1;
            progress = 1 - (zbyvajiciDni / 30);
          } else {
            vyprseno = true;
            progress = 1;
          }
        } else if (platnostDo != null) {
          if (now.isAfter(platnostDo)) vyprseno = true;
        }

        final accent = vyprseno
            ? TokColors.danger
            : (isTrial ? TokColors.warning : TokColors.success);

        return Container(
          padding: const EdgeInsets.all(TokSpace.lg),
          decoration: BoxDecoration(
            color: tok.surface,
            border: Border.all(color: tok.line),
            borderRadius: BorderRadius.circular(TokRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(TokRadius.sm),
                    ),
                    child: Icon(
                      isTrial
                          ? Icons.access_time_rounded
                          : Icons.workspace_premium_outlined,
                      color: accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isTrial
                              ? (vyprseno
                                  ? l10n.nastTrialVyprselo
                                  : l10n.nastTrialAktivni)
                              : l10n.nastPlanNazev(planTyp.toUpperCase()),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: tok.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isTrial
                              ? (vyprseno
                                  ? l10n.nastTrialVyberPlan
                                  : l10n.nastTrialZbyva(zbyvajiciDni!, _dayWord(zbyvajiciDni, l10n)))
                              : (platnostDo != null
                                  ? l10n.nastPlatnostDo(DateFormat('d. M. yyyy').format(platnostDo))
                                  : l10n.nastAktivni),
                          style: TextStyle(
                              fontSize: 12, color: tok.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isTrial) ...[
                const SizedBox(height: TokSpace.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(TokRadius.round),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: tok.line,
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                ),
                const SizedBox(height: TokSpace.md),
                SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PredplatnePage()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          vyprseno ? TokColors.accent : TokColors.ink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(TokRadius.md),
                      ),
                    ),
                    child: Text(
                      vyprseno ? l10n.nastVybratPlan : l10n.nastZobrazitPlany,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _dayWord(int n, AppLocalizations l10n) {
    if (n == 1) return l10n.nastDayJeden;
    if (n >= 2 && n <= 4) return l10n.nastDayNeco;
    return l10n.nastDayMnogo;
  }
}