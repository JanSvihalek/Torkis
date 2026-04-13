import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('nastaveni_servisu')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
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
            .collection('nastaveni_servisu')
            .doc(user.uid)
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
              'zmeneno': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nastavení bylo úspěšně uloženo.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nastavení',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Firemní údaje, ceník a fakturace.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveSettings,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: const Text('ULOŽIT NASTAVENÍ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEVÝ SLOUPEC
                Expanded(
                  child: Column(
                    children: [
                      _buildSectionCard(
                        isDark: isDark,
                        title: 'Firemní údaje',
                        icon: Icons.business,
                        color: Colors.blue,
                        children: [
                          _buildTextField(
                            _nazevCtrl,
                            'Název servisu / Jméno',
                            Icons.badge,
                            isDark,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  _icoCtrl,
                                  'IČO',
                                  Icons.numbers,
                                  isDark,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildTextField(
                                  _dicCtrl,
                                  'DIČ',
                                  Icons.account_balance,
                                  isDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            _registraceCtrl,
                            'Spisová značka',
                            Icons.gavel,
                            isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSectionCard(
                        isDark: isDark,
                        title: 'Sídlo a kontakt',
                        icon: Icons.location_on,
                        color: Colors.orange,
                        children: [
                          _buildTextField(
                            _adresaCtrl,
                            'Ulice a č.p.',
                            Icons.streetview,
                            isDark,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  _mestoCtrl,
                                  'Město',
                                  Icons.location_city,
                                  isDark,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                flex: 1,
                                child: _buildTextField(
                                  _pscCtrl,
                                  'PSČ',
                                  Icons.markunread_mailbox,
                                  isDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  _telefonCtrl,
                                  'Telefon',
                                  Icons.phone,
                                  isDark,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildTextField(
                                  _emailCtrl,
                                  'E-mail',
                                  Icons.email,
                                  isDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 30),
                // PRAVÝ SLOUPEC
                Expanded(
                  child: Column(
                    children: [
                      _buildSectionCard(
                        isDark: isDark,
                        title: 'Fakturace a Platby',
                        icon: Icons.receipt_long,
                        color: Colors.green,
                        children: [
                          _buildTextField(
                            _bankaCtrl,
                            'Bankovní účet (pro QR platbu)',
                            Icons.account_balance_wallet,
                            isDark,
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            'Výchozí splatnost faktury:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  _splatnostCtrl,
                                  'Počet dní',
                                  Icons.date_range,
                                  isDark,
                                  isNumber: true,
                                ),
                              ),
                              const SizedBox(width: 15),
                              const Expanded(
                                child: Text(
                                  'Dní od data vystavení',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSectionCard(
                        isDark: isDark,
                        title: 'Ceník a DPH',
                        icon: Icons.monetization_on,
                        color: Colors.purple,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  _sazbaCtrl,
                                  'Výchozí hodinová sazba',
                                  Icons.timer,
                                  isDark,
                                  isNumber: true,
                                ),
                              ),
                              const SizedBox(width: 15),
                              const Expanded(
                                child: Text(
                                  'Kč / hodina (bez DPH)',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2C2C2C)
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF424242)
                                    : const Color(0xFFE0E0E0),
                              ),
                            ),
                            child: SwitchListTile(
                              title: const Text(
                                'Plátce DPH',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: const Text(
                                'Automaticky připočítávat 21% k částkám.',
                              ),
                              value: _platceDph,
                              activeColor: Colors.blue,
                              onChanged: (val) =>
                                  setState(() => _platceDph = val),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
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
                  color: isDark
                      ? const Color(0xFF2C2C2C)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
    bool isDark, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: isDark ? const Color(0xFF121212) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
