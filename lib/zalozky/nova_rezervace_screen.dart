import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'auth_gate.dart';

class NovaRezervaceScreen extends StatefulWidget {
  final DateTime vybranyDen;

  const NovaRezervaceScreen({super.key, required this.vybranyDen});

  @override
  State<NovaRezervaceScreen> createState() => _NovaRezervaceScreenState();
}

class _NovaRezervaceScreenState extends State<NovaRezervaceScreen> {
  TextEditingController? _autoSpzController;
  TextEditingController? _autoZakaznikController;

  final _znackaController = TextEditingController();
  final _modelController = TextEditingController();
  final _vinController = TextEditingController();
  final _icoController = TextEditingController();
  final _telefonController = TextEditingController();
  final _emailController = TextEditingController();

  String? _vybranyUkon;
  List<String> _dostupneUkony = [];
  
  late DateTime _datumRezervace;
  TimeOfDay _casOd = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _casDo = const TimeOfDay(hour: 9, minute: 0);
  
  bool _isLoading = false;
  String? _vybranyZakaznikId;

  @override
  void initState() {
    super.initState();
    _datumRezervace = widget.vybranyDen;
    _nactiNastaveni();
  }

  @override
  void dispose() {
    _znackaController.dispose();
    _modelController.dispose();
    _vinController.dispose();
    _icoController.dispose();
    _telefonController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _nactiNastaveni() async {
    final doc = await FirebaseFirestore.instance.collection('nastaveni_servisu').doc(globalServisId).get();
    if (doc.exists && doc.data()!.containsKey('rychle_ukony')) {
      if (mounted) {
        setState(() {
          _dostupneUkony = List<String>.from(doc.data()!['rychle_ukony']);
        });
      }
    }
  }

  Future<void> _ulozitRezervaci() async {
    final spz = _autoSpzController?.text.trim().toUpperCase() ?? '';
    final zakaznik = _autoZakaznikController?.text.trim() ?? '';

    if (spz.isEmpty || _vybranyUkon == null || zakaznik.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zadejte minimálně SPZ, jméno zákazníka a vyberte úkon.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // UKLÁDÁME UŽ POUZE DO PLÁNOVAČE A ULOŽÍME TAM VŠECHNY ÚDAJE
      await FirebaseFirestore.instance.collection('planovac').add({
        'servis_id': globalServisId,
        'spz': spz,
        'znacka': _znackaController.text.trim(),
        'model': _modelController.text.trim(),
        'vin': _vinController.text.trim().toUpperCase(),
        'zakaznik_jmeno': zakaznik,
        'zakaznik_ico': _icoController.text.trim(),
        'zakaznik_telefon': _telefonController.text.trim(),
        'zakaznik_email': _emailController.text.trim(),
        'zakaznik_id': _vybranyZakaznikId,
        'nazev_ukonu': _vybranyUkon,
        'datum': DateFormat('yyyy-MM-dd').format(_datumRezervace),
        'cas_od': '${_casOd.hour.toString().padLeft(2, '0')}:${_casOd.minute.toString().padLeft(2, '0')}',
        'cas_do': '${_casDo.hour.toString().padLeft(2, '0')}:${_casDo.minute.toString().padLeft(2, '0')}',
        'zakazka_doc_id': null, // Zatím není propojeno na reálnou zakázku
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rezervace uložena do kalendáře.'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chyba při ukládání: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Nová rezervace', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('1. Termín a úkon', Icons.calendar_month),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _vybranyUkon,
                        decoration: _buildInputDecoration('Plánovaný úkon', Icons.build_circle, isDark),
                        items: _dostupneUkony.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                        onChanged: (val) => setState(() => _vybranyUkon = val),
                      ),
                      const SizedBox(height: 15),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Datum rezervace', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        subtitle: Text(DateFormat('EEEE, d. MMMM yyyy', 'cs_CZ').format(_datumRezervace), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        trailing: const Icon(Icons.edit_calendar, color: Colors.blue),
                        onTap: () async {
                          final d = await showDatePicker(context: context, initialDate: _datumRezervace, firstDate: DateTime.now().subtract(const Duration(days: 30)), lastDate: DateTime.now().add(const Duration(days: 365)));
                          if (d != null) setState(() => _datumRezervace = d);
                        },
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Od', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              subtitle: Text(_casOd.format(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              trailing: const Icon(Icons.access_time, color: Colors.blue),
                              onTap: () async {
                                final t = await showTimePicker(context: context, initialTime: _casOd);
                                if (t != null) setState(() => _casOd = t);
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Do', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              subtitle: Text(_casDo.format(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              trailing: const Icon(Icons.access_time, color: Colors.blue),
                              onTap: () async {
                                final t = await showTimePicker(context: context, initialTime: _casDo);
                                if (t != null) setState(() => _casDo = t);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              _buildSectionTitle('2. Identifikace vozidla', Icons.directions_car),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('vozidla').where('servis_id', isEqualTo: globalServisId).snapshots(),
                        builder: (context, vozidlaSnapshot) {
                          List<Map<String, dynamic>> existujiciVozidla = [];
                          if (vozidlaSnapshot.hasData) {
                            existujiciVozidla = vozidlaSnapshot.data!.docs.map((d) => d.data() as Map<String, dynamic>).toList();
                          }
                          
                          return Autocomplete<Map<String, dynamic>>(
                            displayStringForOption: (option) => option['spz'] ?? '',
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) return const Iterable.empty();
                              return existujiciVozidla.where((vozidlo) => 
                                  (vozidlo['spz'] ?? '').toString().toUpperCase().contains(textEditingValue.text.toUpperCase()));
                            },
                            onSelected: (selection) {
                              setState(() {
                                _autoSpzController?.text = selection['spz'] ?? '';
                                _znackaController.text = selection['znacka'] ?? '';
                                _modelController.text = selection['model'] ?? '';
                                _vinController.text = selection['vin'] ?? '';
                                
                                if (selection['majitel_jmeno'] != null) {
                                  _autoZakaznikController?.text = selection['majitel_jmeno'];
                                  _icoController.text = selection['majitel_ico'] ?? '';
                                  _telefonController.text = selection['majitel_telefon'] ?? '';
                                  _emailController.text = selection['majitel_email'] ?? '';
                                  _vybranyZakaznikId = selection['zakaznik_id'];
                                }
                              });
                            },
                            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                              _autoSpzController = controller;
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                textCapitalization: TextCapitalization.characters,
                                decoration: _buildInputDecoration('SPZ vozidla (Vyhledejte nebo napište)', Icons.search, isDark),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _vinController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: _buildInputDecoration('VIN kód (nepovinné)', Icons.pin, isDark),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _znackaController, decoration: _buildInputDecoration('Značka', Icons.directions_car_filled_outlined, isDark))),
                          const SizedBox(width: 10),
                          Expanded(child: TextField(controller: _modelController, decoration: _buildInputDecoration('Model', Icons.info_outline, isDark))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              _buildSectionTitle('3. Údaje o zákazníkovi', Icons.person),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('zakaznici').where('servis_id', isEqualTo: globalServisId).snapshots(),
                        builder: (context, zakSnapshot) {
                          List<Map<String, dynamic>> existujiciZakaznici = [];
                          if (zakSnapshot.hasData) {
                            existujiciZakaznici = zakSnapshot.data!.docs.map((d) => d.data() as Map<String, dynamic>).toList();
                          }
                          return Autocomplete<Map<String, dynamic>>(
                            displayStringForOption: (option) => option['jmeno'] ?? '',
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) return const Iterable.empty();
                              return existujiciZakaznici.where((zak) => zak['jmeno'].toString().toLowerCase().contains(textEditingValue.text.toLowerCase()));
                            },
                            onSelected: (selection) {
                              setState(() {
                                _autoZakaznikController?.text = selection['jmeno'] ?? '';
                                _icoController.text = selection['ico'] ?? '';
                                _telefonController.text = selection['telefon'] ?? '';
                                _emailController.text = selection['email'] ?? '';
                                _vybranyZakaznikId = selection['id_zakaznika'];
                              });
                            },
                            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                              _autoZakaznikController = controller;
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: _buildInputDecoration('Jméno / Firma', Icons.person_search, isDark),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _icoController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration('IČO (pro firmy)', Icons.business, isDark),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _telefonController, keyboardType: TextInputType.phone, decoration: _buildInputDecoration('Telefon', Icons.phone, isDark))),
                          const SizedBox(width: 10),
                          Expanded(child: TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: _buildInputDecoration('E-mail', Icons.email, isDark))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 35),

              SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _ulozitRezervaci,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('ULOŽIT DO KALENDÁŘE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.blueGrey, size: 20),
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }
}