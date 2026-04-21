import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_gate.dart';

class NovaRezervaceScreen extends StatefulWidget {
  final DateTime vybranyDen;

  const NovaRezervaceScreen({super.key, required this.vybranyDen});

  @override
  State<NovaRezervaceScreen> createState() => _NovaRezervaceScreenState();
}

class _NovaRezervaceScreenState extends State<NovaRezervaceScreen> {
  // PŘIDÁNO: Bezpečná pojistka pro ID servisu (odolná proti Hot Restartu)
  String? get _sId => globalServisId ?? FirebaseAuth.instance.currentUser?.uid;

  final _spzController = TextEditingController();
  final _znackaController = TextEditingController();
  final _modelController = TextEditingController();
  final _vinController = TextEditingController();

  final _zakaznikController = TextEditingController();
  final _icoController = TextEditingController();
  final _telefonController = TextEditingController();
  final _emailController = TextEditingController();

  String? _vybranyUkon;
  List<String> _dostupneUkony = [];
  Map<String, double> _delkyUkonu = {};
  bool _isLoadingUkony = true;

  late DateTime _datumRezervace;
  TimeOfDay _casOd = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _casDo = const TimeOfDay(hour: 9, minute: 0);

  bool _isLoading = false;
  bool _isLoadingSpz = false;

  String? _vybranyZakaznikId;
  List<Map<String, dynamic>> _nalezenaVozidla = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _datumRezervace = widget.vybranyDen;
    _nactiUkonyZDatabaze();
  }

  @override
  void dispose() {
    _spzController.dispose();
    _znackaController.dispose();
    _modelController.dispose();
    _vinController.dispose();
    _zakaznikController.dispose();
    _icoController.dispose();
    _telefonController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _nactiUkonyZDatabaze() async {
    if (_sId == null) {
      // Pokud ID opravdu není, musíme vypnout načítání, ať to nevisí!
      if (mounted) setState(() => _isLoadingUkony = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('ukony')
          .where('servis_id', isEqualTo: _sId)
          .where('aktivni', isEqualTo: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        List<String> nacteneUkony = [];
        Map<String, double> nacteneDelky = {};

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final nazev = (data['nazev'] ?? '').toString();
          final cas = (data['odhadovany_cas'] ?? 1.0).toDouble();

          if (nazev.isNotEmpty) {
            nacteneUkony.add(nazev);
            nacteneDelky[nazev] = cas;
          }
        }

        nacteneUkony.sort();

        if (mounted) {
          setState(() {
            _dostupneUkony = nacteneUkony;
            _delkyUkonu = nacteneDelky;
            _isLoadingUkony = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingUkony = false);
      }
    } catch (e) {
      debugPrint("Chyba při načítání úkonů: $e");
      if (mounted) setState(() => _isLoadingUkony = false);
    }
  }

  void _prepocitatCasDo(String? vybranyUkon) {
    if (vybranyUkon != null && _delkyUkonu.containsKey(vybranyUkon)) {
      final double hoursToAdd = _delkyUkonu[vybranyUkon]!;
      final int addHours = hoursToAdd.toInt();
      final int addMinutes = ((hoursToAdd - addHours) * 60).round();

      int newHour = _casOd.hour + addHours;
      int newMinute = _casOd.minute + addMinutes;

      if (newMinute >= 60) {
        newHour += newMinute ~/ 60;
        newMinute = newMinute % 60;
      }

      setState(() {
        _casDo = TimeOfDay(hour: newHour % 24, minute: newMinute);
      });
    }
  }

  Future<void> _scanText(TextEditingController controller) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Skenování pomocí AI funguje pouze v aplikaci.'),
          backgroundColor: Colors.orange));
      return;
    }
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return;
      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      String result = recognizedText.text
          .replaceAll(RegExp(r'[^A-Z0-9]'), '')
          .toUpperCase();
      setState(() => controller.text = result);
      textRecognizer.close();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Chyba skenování: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _hledatPodleSpz() async {
    final spz = _spzController.text.trim().toUpperCase().replaceAll(' ', '');
    if (spz.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Zadejte alespoň část SPZ pro vyhledání.'),
          backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoadingSpz = true);

    try {
      if (_sId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Chyba: ID Servisu se nepodařilo načíst.'),
            backgroundColor: Colors.red));
        return;
      }

      final vozidlaQuery = await FirebaseFirestore.instance
          .collection('vozidla')
          .where('servis_id', isEqualTo: _sId)
          .get();
      final nalezenaVozidla = vozidlaQuery.docs.map((d) => d.data()).where((v) {
        final ulozenoSpz = (v['spz'] ?? '').toString().toUpperCase();
        return ulozenoSpz.startsWith(spz);
      }).toList();

      if (nalezenaVozidla.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Žádné vozidlo s touto SPZ nebylo nalezeno.'),
            backgroundColor: Colors.blueGrey));
        return;
      }

      if (nalezenaVozidla.length == 1) {
        await _aplikovatVybraneVozidlo(nalezenaVozidla.first);
      } else {
        _otevritVyberNalezenychVozidel(nalezenaVozidla);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Chyba při vyhledávání: $e'),
          backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoadingSpz = false);
    }
  }

  Future<void> _aplikovatVybraneVozidlo(
      Map<String, dynamic> vozidloData) async {
    if (_sId == null) return;

    setState(() {
      _spzController.text = vozidloData['spz']?.toString() ?? '';
      _znackaController.text = vozidloData['znacka']?.toString() ?? '';
      _modelController.text = vozidloData['model']?.toString() ?? '';
      _vinController.text = vozidloData['vin']?.toString() ?? '';
    });

    final zakaznikId = vozidloData['zakaznik_id'];
    if (zakaznikId != null && zakaznikId.toString().isNotEmpty) {
      final zakQuery = await FirebaseFirestore.instance
          .collection('zakaznici')
          .where('servis_id', isEqualTo: _sId)
          .where('id_zakaznika', isEqualTo: zakaznikId)
          .get();

      if (zakQuery.docs.isNotEmpty) {
        final z = zakQuery.docs.first.data();
        setState(() {
          _vybranyZakaznikId = z['id_zakaznika']?.toString();
          _zakaznikController.text = z['jmeno']?.toString() ?? '';
          _icoController.text = z['ico']?.toString() ?? '';
          _telefonController.text = z['telefon']?.toString() ?? '';
          _emailController.text = z['email']?.toString() ?? '';
        });
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Údaje o vozidle a zákazníkovi byly načteny.'),
          backgroundColor: Colors.green));
    }
  }

  void _otevritVyberNalezenychVozidel(List<Map<String, dynamic>> vozidla) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text('Nalezeno více vozidel',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Vyberte konkrétní vozidlo ze seznamu:',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.separated(
                itemCount: vozidla.length,
                separatorBuilder: (c, i) => const Divider(),
                itemBuilder: (context, index) {
                  final v = vozidla[index];
                  return ListTile(
                    leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        child: Icon(Icons.directions_car)),
                    title: Text(v['spz'] ?? 'Neznámá SPZ',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${v['znacka'] ?? ''} ${v['model'] ?? ''}'),
                    onTap: () {
                      Navigator.pop(context);
                      _aplikovatVybraneVozidlo(v);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _otevritVyberZakaznika() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VyberZakaznikaSheet(
        onVybrano: (zakaznik) async {
          setState(() {
            _vybranyZakaznikId = zakaznik['id_zakaznika'];
            _zakaznikController.text = zakaznik['jmeno'] ?? '';
            _icoController.text = zakaznik['ico'] ?? '';
            _telefonController.text = zakaznik['telefon'] ?? '';
            _emailController.text = zakaznik['email'] ?? '';
          });

          if (_sId != null && _vybranyZakaznikId != null) {
            final vozidlaSnap = await FirebaseFirestore.instance
                .collection('vozidla')
                .where('servis_id', isEqualTo: _sId)
                .where('zakaznik_id', isEqualTo: _vybranyZakaznikId)
                .get();
            setState(() {
              _nalezenaVozidla = vozidlaSnap.docs.map((d) => d.data()).toList();
            });
          }
        },
      ),
    );
  }

  Future<void> _ulozitRezervaci() async {
    if (_spzController.text.trim().isEmpty ||
        _vybranyUkon == null ||
        _zakaznikController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Zadejte minimálně SPZ, jméno a vyberte úkon.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('planovac').add({
        'servis_id': _sId,
        'spz': _spzController.text.trim().toUpperCase(),
        'znacka': _znackaController.text.trim(),
        'model': _modelController.text.trim(),
        'vin': _vinController.text.trim().toUpperCase(),
        'zakaznik_jmeno': _zakaznikController.text.trim(),
        'zakaznik_ico': _icoController.text.trim(),
        'zakaznik_telefon': _telefonController.text.trim(),
        'zakaznik_email': _emailController.text.trim(),
        'zakaznik_id': _vybranyZakaznikId,
        'nazev_ukonu': _vybranyUkon,
        'datum': DateFormat('yyyy-MM-dd').format(_datumRezervace),
        'cas_od':
            '${_casOd.hour.toString().padLeft(2, '0')}:${_casOd.minute.toString().padLeft(2, '0')}',
        'cas_do':
            '${_casDo.hour.toString().padLeft(2, '0')}:${_casDo.minute.toString().padLeft(2, '0')}',
        'zakazka_doc_id': null,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Rezervace byla přidána do plánovače.'),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Chyba při ukládání: $e'),
            backgroundColor: Colors.red));
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
        title: const Text('Nová rezervace',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _vybranyUkon,
                        decoration: _buildInputDecoration(
                            'Plánovaný úkon', Icons.build_circle, isDark),
                        hint: Text(_isLoadingUkony
                            ? 'Načítám úkony...'
                            : (_dostupneUkony.isEmpty
                                ? 'Žádné úkony nenalezeny'
                                : 'Vyberte úkon')),
                        items: _dostupneUkony
                            .map((u) =>
                                DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: _dostupneUkony.isEmpty
                            ? null
                            : (val) {
                                setState(() {
                                  _vybranyUkon = val;
                                });
                                _prepocitatCasDo(val);
                              },
                      ),
                      const SizedBox(height: 15),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Datum rezervace',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        subtitle: Text(
                            DateFormat('EEEE, d. MMMM yyyy', 'cs_CZ')
                                .format(_datumRezervace),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        trailing:
                            const Icon(Icons.edit_calendar, color: Colors.blue),
                        onTap: () async {
                          final d = await showDatePicker(
                              context: context,
                              initialDate: _datumRezervace,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 30)),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)));
                          if (d != null) setState(() => _datumRezervace = d);
                        },
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Od',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              subtitle: Text(_casOd.format(context),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              trailing: const Icon(Icons.access_time,
                                  color: Colors.blue),
                              onTap: () async {
                                final t = await showTimePicker(
                                    context: context, initialTime: _casOd);
                                if (t != null) {
                                  setState(() {
                                    _casOd = t;
                                  });
                                  _prepocitatCasDo(_vybranyUkon);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Do',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              subtitle: Text(_casDo.format(context),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              trailing: const Icon(Icons.access_time,
                                  color: Colors.blue),
                              onTap: () async {
                                final t = await showTimePicker(
                                    context: context, initialTime: _casDo);
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
              _buildSectionTitle(
                  '2. Identifikace vozidla', Icons.directions_car),
              if (_nalezenaVozidla.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.directions_car,
                              color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text('Uložená vozidla zákazníka:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _nalezenaVozidla
                            .map((v) => ActionChip(
                                  backgroundColor: isDark
                                      ? const Color(0xFF2C2C2C)
                                      : Colors.white,
                                  side: const BorderSide(color: Colors.blue),
                                  label: Text(
                                      '${v['spz']} ${v['znacka'] != null ? '(${v['znacka']})' : ''}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  onPressed: () => _aplikovatVybraneVozidlo(v),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      TextField(
                        controller: _spzController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'SPZ vozidla',
                          labelStyle: const TextStyle(fontSize: 14),
                          prefixIcon: const Icon(Icons.directions_car,
                              color: Colors.blueGrey, size: 20),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.document_scanner),
                                  onPressed: () => _scanText(_spzController),
                                  tooltip: 'Skenovat SPZ'),
                              _isLoadingSpz
                                  ? const Padding(
                                      padding: EdgeInsets.all(14.0),
                                      child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2)))
                                  : IconButton(
                                      icon: const Icon(Icons.search,
                                          color: Colors.blue),
                                      onPressed: _hledatPodleSpz,
                                      tooltip: 'Hledat auto v databázi'),
                            ],
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF2C2C2C)
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _vinController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: _buildInputDecoration(
                            'VIN kód (nepovinné)', Icons.pin, isDark),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                                  controller: _znackaController,
                                  decoration: _buildInputDecoration(
                                      'Značka',
                                      Icons.directions_car_filled_outlined,
                                      isDark))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: TextField(
                                  controller: _modelController,
                                  decoration: _buildInputDecoration(
                                      'Model', Icons.info_outline, isDark))),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      TextField(
                        controller: _zakaznikController,
                        decoration: InputDecoration(
                          labelText: 'Jméno a příjmení / Název firmy',
                          labelStyle: const TextStyle(fontSize: 14),
                          prefixIcon: const Icon(Icons.person,
                              color: Colors.blueGrey, size: 20),
                          suffixIcon: IconButton(
                              icon: const Icon(Icons.person_search,
                                  color: Colors.blue),
                              onPressed: _otevritVyberZakaznika,
                              tooltip: 'Hledat uloženého zákazníka'),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF2C2C2C)
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _icoController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(
                            'IČO (pro firmy)', Icons.business, isDark),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                                  controller: _telefonController,
                                  keyboardType: TextInputType.phone,
                                  decoration: _buildInputDecoration(
                                      'Telefon', Icons.phone, isDark))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: _buildInputDecoration(
                                      'E-mail', Icons.email, isDark))),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ULOŽIT DO KALENDÁŘE',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5)),
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
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.blueGrey, size: 20),
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    );
  }
}

class _VyberZakaznikaSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onVybrano;
  const _VyberZakaznikaSheet({required this.onVybrano});
  @override
  State<_VyberZakaznikaSheet> createState() => _VyberZakaznikaSheetState();
}

class _VyberZakaznikaSheetState extends State<_VyberZakaznikaSheet> {
  String? get _sId => globalServisId ?? FirebaseAuth.instance.currentUser?.uid;
  String _hledanyText = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_sId == null) return const Center(child: CircularProgressIndicator());

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 20),
          const Text('Vybrat existujícího zákazníka',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          TextField(
            onChanged: (val) =>
                setState(() => _hledanyText = val.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Hledat podle jména, IČO, telefonu...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('zakaznici')
                  .where('servis_id', isEqualTo: _sId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final zakaznici = snapshot.data!.docs
                    .map((d) => d.data() as Map<String, dynamic>)
                    .where((z) {
                  final jmeno = (z['jmeno'] ?? '').toString().toLowerCase();
                  final ico = (z['ico'] ?? '').toString().toLowerCase();
                  final tel = (z['telefon'] ?? '').toString().toLowerCase();
                  return jmeno.contains(_hledanyText) ||
                      ico.contains(_hledanyText) ||
                      tel.contains(_hledanyText);
                }).toList();

                if (zakaznici.isEmpty)
                  return const Center(child: Text('Žádný zákazník nenalezen.'));

                return ListView.separated(
                  itemCount: zakaznici.length,
                  separatorBuilder: (c, i) => const Divider(),
                  itemBuilder: (context, index) {
                    final z = zakaznici[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(z['jmeno'] ?? 'Neznámé jméno',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${z['telefon'] ?? ''} ${z['ico'] != null && z['ico'].toString().isNotEmpty ? '• IČO: ${z['ico']}' : ''}'),
                      onTap: () {
                        widget.onVybrano(z);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
