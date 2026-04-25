import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Přidáno pro živý náhled data v konfigurátoru

import '../core/constants.dart';
import 'auth_gate.dart'; // Kvůli globalUserRole a globalServisId
import 'main_screen.dart'; // Kvůli navOrderNotifier
import 'app_logger.dart'; // Přidán náš logger pro odchytávání chyb

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
  final _bankaCtrl = TextEditingController();
  final _registraceCtrl = TextEditingController();
  final _sazbaCtrl = TextEditingController(text: '0');
  final _splatnostCtrl = TextEditingController(text: '14');

  bool _platceDph = false;
  bool _defaultEmail = true;

  // Uživatelské nastavení (pro všechny)
  bool _tmavyRezim = false;

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
    _bankaCtrl.dispose();
    _registraceCtrl.dispose();
    _sazbaCtrl.dispose();
    _splatnostCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('uzivatele')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _tmavyRezim = userDoc.data()!['tmavy_rezim'] ?? false;
        });
      }

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
            _bankaCtrl.text = data['banka_servisu'] ?? '';
            _registraceCtrl.text = data['registrace_servisu'] ?? '';
            _sazbaCtrl.text = (data['hodinova_sazba'] ?? 0).toString();
            _splatnostCtrl.text = (data['splatnost_dny'] ?? 14).toString();
            _platceDph = data['platce_dph'] ?? false;
            _defaultEmail = data['default_odesilat_emaily'] ?? true;
          });
        }
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
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
            'banka_servisu': _bankaCtrl.text.trim(),
            'registrace_servisu': _registraceCtrl.text.trim(),
            'hodinova_sazba':
                double.tryParse(_sazbaCtrl.text.replaceAll(',', '.')) ?? 0.0,
            'splatnost_dny': int.tryParse(_splatnostCtrl.text) ?? 14,
            'platce_dph': _platceDph,
            'default_odesilat_emaily': _defaultEmail,
            'zmeneno': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        themeNotifier.value = _tmavyRezim ? ThemeMode.dark : ThemeMode.light;

        // Uložení do SharedPreferences — načte se při příštím startu
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('tmavy_rezim', _tmavyRezim);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Nastavení uloženo.'),
              backgroundColor: Colors.green));
        }
      }
    } catch (e, stackTrace) {
      await AppLogger.logError('Ukládání hlavního nastavení servisu', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Chyba: $e'), backgroundColor: Colors.red));
      }
    }
    setState(() => _isSaving = false);
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
    List<String> lokalniPoradi = List.from(navOrderNotifier.value);

    final Map<String, Map<String, dynamic>> vizual = {
      'prijem': {'nazev': 'Příjem vozidla', 'ikona': Icons.add_circle_outline_rounded},
      'zakazky': {'nazev': 'Aktivní zakázky', 'ikona': Icons.build_circle_outlined},
      'historie': {'nazev': 'Historie', 'ikona': Icons.history_rounded},
      'menu': {'nazev': 'Menu (Ostatní moduly)', 'ikona': Icons.grid_view},
      'sklad': {'nazev': 'Sklad dílů', 'ikona': Icons.inventory_2_outlined},
      'fakturace': {'nazev': 'Faktury', 'ikona': Icons.receipt_long_outlined},
      'vozidla': {'nazev': 'Vozidla', 'ikona': Icons.directions_car_outlined},
      'ukony': {'nazev': 'Úkony', 'ikona': Icons.playlist_add_check_circle_outlined},
      'zakaznici': {'nazev': 'Zákazníci', 'ikona': Icons.people_alt_outlined},
      'planovac': {'nazev': 'Plánovač', 'ikona': Icons.calendar_today_outlined},
      'zamestnanci': {'nazev': 'Tým a práva', 'ikona': Icons.badge_outlined},
      'ucetnictvi': {'nazev': 'Účetnictví', 'ikona': Icons.pie_chart_outline},
      'statistiky': {'nazev': 'Statistiky', 'ikona': Icons.bar_chart_outlined},
      'nastaveni': {'nazev': 'Nastavení', 'ikona': Icons.settings_outlined},
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
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
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
                  const Text('Přizpůsobit spodní lištu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Text('Můžete mít aktivních 2 až 5 záložek. Přetažením změníte pořadí.', style: TextStyle(color: Colors.grey, fontSize: 13)),
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
                            color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                            elevation: 0,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: Icon(vizual[lokalniPoradi[i]]!['ikona'], color: Colors.blue),
                              title: Text(vizual[lokalniPoradi[i]]!['nazev'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (lokalniPoradi[i] == 'menu')
                                    const Tooltip(
                                      message: 'Menu nelze odebrat',
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
                                  title: const Text('Vyberte modul pro lištu'),
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
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ZAVŘÍT')),
                                  ],
                                );
                              }
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Přidat další záložku (max 5)'),
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
                      child: const Text('HOTOVO', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    Text(_isAdmin ? 'Firemní nastavení' : 'Můj profil',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                        _isAdmin
                            ? 'Správa údajů servisu a ceníku.'
                            : 'Základní nastavení vašeho účtu.',
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
                label: const Text('ULOŽIT',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
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
              // SEKCE PRO ADMINA (FIREMNÍ ÚDAJE)
              // ---------------------------------------------
              if (_isAdmin) ...[
                _buildCard(
                  title: 'Firemní údaje',
                  icon: Icons.business,
                  color: Colors.blue,
                  isDark: isDark,
                  children: [
                    _buildInput(_nazevCtrl, 'Obchodní jméno / Název servisu',
                        Icons.store, isDark),
                    Row(
                      children: [
                        Expanded(
                            child: _buildInput(
                                _icoCtrl, 'IČO', Icons.numbers, isDark)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _buildInput(
                                _dicCtrl, 'DIČ', Icons.badge, isDark)),
                      ],
                    ),
                    _buildInput(
                        _registraceCtrl,
                        'Zápis v rejstříku (spisová značka)',
                        Icons.gavel,
                        isDark),
                  ],
                ),
                _buildCard(
                  title: 'Sídlo a kontakt',
                  icon: Icons.location_on,
                  color: Colors.orange,
                  isDark: isDark,
                  children: [
                    _buildInput(_adresaCtrl, 'Ulice a č.p.', Icons.map, isDark),
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: _buildInput(_mestoCtrl, 'Město',
                                Icons.location_city, isDark)),
                        const SizedBox(width: 10),
                        Expanded(
                            flex: 1,
                            child: _buildInput(_pscCtrl, 'PSČ',
                                Icons.mark_email_unread, isDark)),
                      ],
                    ),
                    _buildInput(
                        _telefonCtrl, 'Telefon servisu', Icons.phone, isDark),
                    _buildInput(_emailCtrl, 'E-mail pro komunikaci',
                        Icons.email, isDark),
                  ],
                ),
                _buildCard(
                  title: 'Fakturace a ceny',
                  icon: Icons.receipt_long,
                  color: Colors.green,
                  isDark: isDark,
                  children: [
                    _buildInput(_bankaCtrl, 'Bankovní účet',
                        Icons.account_balance, isDark),
                    Row(
                      children: [
                        Expanded(
                            child: _buildInput(_sazbaCtrl, 'Hodinová sazba',
                                Icons.timer, isDark,
                                isNum: true)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _buildInput(_splatnostCtrl,
                                'Splatnost (dny)', Icons.calendar_today, isDark,
                                isNum: true)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10)),
                      child: SwitchListTile(
                        title: const Text('Plátce DPH',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        value: _platceDph,
                        activeThumbColor: Colors.blue,
                        onChanged: (v) => setState(() => _platceDph = v),
                      ),
                    ),
                  ],
                ),
                _buildCard(
                  title: 'Číslování a automatizace',
                  icon: Icons.settings_suggest,
                  color: Colors.purple,
                  isDark: isDark,
                  children: [
                    // NOVÁ TLAČÍTKA PRO KONFIGURÁTOR MÍSTO TEXTOVÝCH POLÍ
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.build_circle_outlined, color: Colors.blue),
                            title: const Text('Formát čísla zakázek', style: TextStyle(fontWeight: FontWeight.bold)),
                            trailing: const Icon(Icons.edit, size: 18),
                            onTap: () => _otevritKonfiguratorCislovani('zakazka', isDark),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.receipt_outlined, color: Colors.orange),
                            title: const Text('Formát čísla faktur', style: TextStyle(fontWeight: FontWeight.bold)),
                            trailing: const Icon(Icons.edit, size: 18),
                            onTap: () => _otevritKonfiguratorCislovani('faktura', isDark),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10)),
                      child: SwitchListTile(
                        title: const Text('Automaticky zasílat e-maily',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text(
                            'Přednastaví odesílání PDF nabídek a faktur.',
                            style: TextStyle(fontSize: 12)),
                        value: _defaultEmail,
                        activeThumbColor: Colors.blue,
                        onChanged: (v) => setState(() => _defaultEmail = v),
                      ),
                    ),
                  ],
                ),
              ],

              // ---------------------------------------------
              // SEKCE PRO VŠECHNY UŽIVATELE (VZHLED A ODHLÁŠENÍ)
              // ---------------------------------------------
              _buildCard(
                title: 'Osobní nastavení',
                icon: Icons.person,
                color: Colors.pinkAccent,
                isDark: isDark,
                children: [
                  Card(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.view_column, color: Colors.blue),
                      ),
                      title: const Text('Přizpůsobit spodní lištu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Přidejte si zástupce nebo změňte pořadí.', style: TextStyle(fontSize: 11)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      onTap: () => _ukazatReorderingDialog(context, isDark),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      color:
                          isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: SwitchListTile(
                      title: const Text('Vynutit tmavý režim',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text(
                          'Aplikace bude tmavá bez ohledu na systém.',
                          style: TextStyle(fontSize: 11)),
                      value: _tmavyRezim,
                      activeThumbColor: Colors.blue,
                      onChanged: (v) => setState(() => _tmavyRezim = v),
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
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                      color: color.withValues(alpha: 0.1),
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
          fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Formát číslování byl úspěšně uložen.'), backgroundColor: Colors.green));
      }
    } catch (e, stackTrace) {
      await AppLogger.logError('Uložení masky číslování (${widget.typDokladu})', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chyba: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Vyšší sheet kvůli klávesnici
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
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
          Text('Formát čísla pro: ${widget.typDokladu.toUpperCase()}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          // Náhledový štítek
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Text('Náhled budoucího dokladu:', style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(_vygenerujNahled(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.blue)),
                const SizedBox(height: 10),
                Text('Interní maska: ${_vygenerujMasku()}', style: const TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace')),
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
                            labelText: 'Prefix (Značka)', 
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                          ),
                          onChanged: (val) => setState(() => _prefix = val.trim()),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _oddelovac,
                          decoration: InputDecoration(
                            labelText: 'Oddělovač', 
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                          ),
                          items: const [
                            DropdownMenuItem(value: '-', child: Text('Pomlčka (-)')),
                            DropdownMenuItem(value: '/', child: Text('Lomítko (/)')),
                            DropdownMenuItem(value: '_', child: Text('Podtržítko (_)')),
                            DropdownMenuItem(value: '', child: Text('Bez oddělovače')),
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
                            labelText: 'Formát roku', 
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                          ),
                          items: const [
                            DropdownMenuItem(value: '{YYYY}', child: Text('4 cifry (2026)')),
                            DropdownMenuItem(value: '{YY}', child: Text('2 cifry (26)')),
                            DropdownMenuItem(value: '', child: Text('Bez roku')),
                          ],
                          onChanged: (val) => setState(() => _rokFormat = val!),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _mesicFormat,
                          decoration: InputDecoration(
                            labelText: 'Formát měsíce', 
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                          ),
                          items: const [
                            DropdownMenuItem(value: '{MM}', child: Text('2 cifry (04)')),
                            DropdownMenuItem(value: '', child: Text('Bez měsíce')),
                          ],
                          onChanged: (val) => setState(() => _mesicFormat = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text('Délka pořadového čísla na konci: ${_delkaPocitadla.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      color: Colors.orange.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: const Border(left: BorderSide(color: Colors.orange, width: 4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 10),
                        Expanded(child: Text('Pokud změníte formát v průběhu roku, stávající doklady zůstanou nedotčeny a nová řada začne navazovat od aktuálního čísla v databázi.', style: TextStyle(fontSize: 12))),
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
                  label: const Text('ULOŽIT FORMÁT', style: TextStyle(fontWeight: FontWeight.bold)),
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