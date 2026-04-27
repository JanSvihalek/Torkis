import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import 'auth_gate.dart';

// Lidsky čitelné názvy modulů
const Map<String, String> _modulNazvy = {
  'prijem':          'Příjem vozidla & Historie příjmů',
  'zakazky':         'Zakázky',
  'planovac':        'Plánovač',
  'sklad':           'Sklad dílů',
  'fakturace':       'Fakturace',
  'ucetnictvi':      'Účetnictví',
  'statistiky':      'Statistiky',
  'zamestnanci':     'Zaměstnanci / Tým',
};

const Map<String, Color> _modulBarvy = {
  'prijem':      Colors.blue,
  'zakazky':     Color.fromARGB(255, 68, 134, 70),
  'planovac':    Colors.green,
  'sklad':       Colors.orange,
  'fakturace':   Colors.teal,
  'ucetnictvi':  Colors.indigo,
  'statistiky':  Colors.purple,
  'zamestnanci': Colors.redAccent,
};

class PredplatneAdminPage extends StatefulWidget {
  /// Pokud je null, spravuje se servis aktuálně přihlášeného uživatele.
  final String? servisId;

  const PredplatneAdminPage({super.key, this.servisId});

  @override
  State<PredplatneAdminPage> createState() => _PredplatneAdminPageState();
}

class _PredplatneAdminPageState extends State<PredplatneAdminPage> {
  String get _servisId => widget.servisId ?? globalServisId ?? '';

  bool _loading = true;
  bool _saving = false;

  String _planTyp = 'basic';
  DateTime? _platnostDo;
  Map<String, bool> _moduly = {};

  @override
  void initState() {
    super.initState();
    _nacist();
  }

  Future<void> _nacist() async {
    setState(() => _loading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('predplatne')
          .doc(_servisId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _planTyp = data['plan_typ']?.toString() ?? 'basic';
        final ts = data['platnost_do'] as Timestamp?;
        _platnostDo = ts?.toDate();
        final raw = Map<String, dynamic>.from(data['moduly_povolene'] ?? {});
        _moduly = raw.map((k, v) => MapEntry(k, v == true));
      } else {
        _planTyp = 'basic';
        _platnostDo = null;
        _moduly = {};
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba načítání: $e'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _ulozit() async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('predplatne')
          .doc(_servisId)
          .set({
        'plan_typ': _planTyp,
        'platnost_do': _platnostDo != null ? Timestamp.fromDate(_platnostDo!) : null,
        'moduly_povolene': _moduly,
        'servis_id': _servisId,
        'aktualizovano': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Předplatné uloženo.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba ukládání: $e'), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _vybratiDatum() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _platnostDo ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2099),
    );
    if (picked != null) setState(() => _platnostDo = picked);
  }

  List<String> get _efektivniModuly {
    if (_planTyp == 'custom') return _modulNazvy.keys.toList();
    return kPlanModuly[_planTyp] ?? kPlanModuly['basic']!;
  }

  bool _jeModulPovolenEfektivne(String modul) {
    if (_planTyp == 'custom') return _moduly[modul] ?? false;
    final vPlanu = (_efektivniModuly).contains(modul);
    return _moduly.containsKey(modul) ? (_moduly[modul] ?? false) : vPlanu;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Správa předplatného',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        actions: [
          if (!_loading)
            _saving
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton(
                    icon: const Icon(Icons.save_outlined, color: Colors.blue),
                    tooltip: 'Uložit',
                    onPressed: _ulozit,
                  ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Servis ID info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.store_outlined,
                            color: Colors.blue, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Servis ID: $_servisId',
                            style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // TYP PLÁNU
                  _sekce(isDark,
                      icon: Icons.workspace_premium_outlined,
                      color: Colors.amber,
                      title: 'Typ plánu',
                      child: Column(
                        children: [
                          _planCard('basic', 'Basic',
                              'Příjem vozidla, zakázky, zákazníci, vozidla',
                              Colors.grey, isDark),
                          const SizedBox(height: 10),
                          _planCard('pro', 'Pro',
                              'Vše z Basic + fakturace, sklad, plánování, statistiky, tým',
                              Colors.blue, isDark),
                          const SizedBox(height: 10),
                          _planCard('custom', 'Custom (smlouva)',
                              'Moduly nastaveny ručně dle smlouvy',
                              Colors.deepPurple, isDark),
                        ],
                      )),
                  const SizedBox(height: 16),

                  // PLATNOST
                  _sekce(isDark,
                      icon: Icons.calendar_month_outlined,
                      color: Colors.orange,
                      title: 'Platnost předplatného',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.edit_calendar),
                                  label: Text(
                                    _platnostDo != null
                                        ? DateFormat('dd.MM.yyyy')
                                            .format(_platnostDo!)
                                        : 'Vybrat datum',
                                  ),
                                  onPressed: _vybratiDatum,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              if (_platnostDo != null) ...[
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.red),
                                  tooltip: 'Bez vypršení',
                                  onPressed: () =>
                                      setState(() => _platnostDo = null),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _platnostDo == null
                                ? 'Předplatné bez data vypršení (doživotní / lifetime).'
                                : _platnostDo!.isBefore(DateTime.now())
                                    ? '⚠️ Předplatné je již EXPIROVÁNO.'
                                    : 'Aktivní ještě ${_platnostDo!.difference(DateTime.now()).inDays} dní.',
                            style: TextStyle(
                              fontSize: 12,
                              color: _platnostDo != null &&
                                      _platnostDo!.isBefore(DateTime.now())
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(height: 16),

                  // MODULY
                  _sekce(isDark,
                      icon: Icons.extension_outlined,
                      color: Colors.deepPurple,
                      title: _planTyp == 'custom'
                          ? 'Povolené moduly (Custom)'
                          : 'Přehled modulů plánu ${_planTyp.toUpperCase()}',
                      child: Column(
                        children: _modulNazvy.entries.map((entry) {
                          final modul = entry.key;
                          final nazev = entry.value;
                          final barva =
                              _modulBarvy[modul] ?? Colors.grey;
                          final povoleno =
                              _jeModulPovolenEfektivne(modul);
                          final jeVPlanu =
                              (_efektivniModuly).contains(modul);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2A2A2A)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: povoleno
                                      ? barva.withValues(alpha: 0.3)
                                      : Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              child: SwitchListTile(
                                title: Text(
                                  nazev,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: povoleno ? null : Colors.grey,
                                  ),
                                ),
                                subtitle: _planTyp != 'custom'
                                    ? Text(
                                        jeVPlanu
                                            ? 'Zahrnuto v plánu ${_planTyp.toUpperCase()}'
                                            : 'Není v plánu ${_planTyp.toUpperCase()}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: jeVPlanu
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      )
                                    : null,
                                secondary: Icon(Icons.circle,
                                    color: povoleno
                                        ? barva
                                        : Colors.grey.withValues(alpha: 0.3),
                                    size: 12),
                                value: povoleno,
                                activeThumbColor: barva,
                                onChanged: (val) {
                                  setState(() {
                                    if (_planTyp == 'custom') {
                                      _moduly[modul] = val;
                                    } else {
                                      // Pro non-custom ukládáme jen přepisy výchozích hodnot
                                      if (val == jeVPlanu) {
                                        _moduly.remove(modul);
                                      } else {
                                        _moduly[modul] = val;
                                      }
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      )),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _ulozit,
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save_outlined),
                      label: const Text('ULOŽIT PŘEDPLATNÉ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _planCard(String hodnota, String nazev, String popis,
      Color barva, bool isDark) {
    final vybran = _planTyp == hodnota;
    return GestureDetector(
      onTap: () => setState(() {
        _planTyp = hodnota;
        if (hodnota == 'custom' && _moduly.isEmpty) {
          // Předvyplníme z aktuálního efektivního stavu
          for (final m in _modulNazvy.keys) {
            _moduly[m] = (kPlanModuly[_planTyp] ?? []).contains(m);
          }
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: vybran
              ? barva.withValues(alpha: isDark ? 0.2 : 0.08)
              : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[50]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: vybran ? barva : Colors.grey.withValues(alpha: 0.2),
            width: vybran ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              vybran ? Icons.radio_button_checked : Icons.radio_button_off,
              color: vybran ? barva : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nazev,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: vybran ? barva : null)),
                  const SizedBox(height: 2),
                  Text(popis,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sekce(bool isDark,
      {required IconData icon,
      required Color color,
      required String title,
      required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: color)),
            ],
          ),
          const Divider(height: 20),
          child,
        ],
      ),
    );
  }
}
