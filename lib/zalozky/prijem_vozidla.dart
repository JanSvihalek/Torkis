import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:signature/signature.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import '../core/pdf_generator.dart';
import 'auth_gate.dart';
import 'prijem_vozidla_vyber_zakaznika.dart';
import 'prijem_vozidla_kamera.dart';
import 'prijem_vozidla_step_vozidlo.dart';
import 'prijem_vozidla_step_zakaznik.dart';
import 'prijem_vozidla_step_stav.dart';
import 'prijem_vozidla_step_photo.dart';
import 'prijem_vozidla_step_prace.dart';
import 'prijem_vozidla_step_podpis.dart';

// Formulář příjmu vozidla — 6stránkový průvodce (PageView).
// Stránky: 1) Vozidlo, 2) Zákazník, 3) Stav při příjmu, 4) Fotodokumentace,
//          5) Požadované práce, 6) Podpis a odeslání protokolu.
// Po dokončení se zakázka zapíše do Firestore (kolekce 'zakazky') a
// volitelně se zákazníkovi pošle protokol o příjmu na e-mail jako PDF.

// Notifier používaný Plánovačem: když dispatcher klikne „Přijmout na servis",
// sem pošle ID rezervace a formulář se přednaplní jejími daty.
final ValueNotifier<String?> rezervaceKeZpracovani = ValueNotifier(null);

class MainWizardPage extends StatefulWidget {
  const MainWizardPage({super.key});
  @override
  State<MainWizardPage> createState() => _MainWizardPageState();
}

class _MainWizardPageState extends State<MainWizardPage> {
  String? get _sId => globalServisId ?? FirebaseAuth.instance.currentUser?.uid;

  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 6;
  bool _isUploading = false;
  bool _isLoadingAres = false;
  bool _isCheckingZakazka = false;
  bool _isGeneratingCislo = false;
  bool _isLoadingSpz = false;

  final _jmenoController = TextEditingController();
  final _icoController = TextEditingController();
  final _uliceController = TextEditingController();
  final _mestoController = TextEditingController();
  final _pscController = TextEditingController();

  final _telefonController = TextEditingController();
  final _emailZController = TextEditingController();
  String _telPredvolba = '+420';

  bool _odeslatEmail = true;
  bool _defaultOdeslatEmail = true;

  String? _vybranyZakaznikId;
  String? _zpracovavanaRezervaceId;
  List<Map<String, dynamic>> _nalezenaVozidla = [];

  final _zakazkaController = TextEditingController();
  final _spzController = TextEditingController();
  final _vinController = TextEditingController();
  final _motorizaceController = TextEditingController();
  final _poznamkyController = TextEditingController();

  final _znackaController = TextEditingController();
  final _modelController = TextEditingController();
  final _rokVyrobyController = TextEditingController();

  String _vybranePalivo = 'Benzín';
  final List<String> _moznostiPaliva = [
    'Benzín',
    'Nafta',
    'Elektro',
    'Hybrid',
    'LPG/CNG',
    'Jiné'
  ];

  String _vybranaPrevodovka = 'Manuální­';
  final List<String> _moznostiPrevodovky = ['Manuální­', 'Automatická', 'Jiné'];

  final Map<String, List<XFile>> _categoryImages = {};
  final ImagePicker _picker = ImagePicker();

  final List<String> _vybranePoskozeni = [];
  final List<String> _poskozeniMoznosti = [
    'Žádné',
    'Čelní sklo',
    'Stěrače',
    'Disky',
    'Karosérie'
  ];

  final _tachometrController = TextEditingController();
  final _poskozeniController = TextEditingController();
  double _stavNadrze = 50.0;

  final _stkMesicController = TextEditingController();
  final _stkRokController = TextEditingController();

  final _pneuLPController = TextEditingController();
  final _pneuPPController = TextEditingController();
  final _pneuLZController = TextEditingController();
  final _pneuPZController = TextEditingController();

  final List<TextEditingController> _pozadavkyControllers = [
    TextEditingController()
  ];

  List<String> _rychleUkony = [];
  bool _isLoadingUkony = true;

  Map<String, List<String>> _databazeZnacek = {};
  Map<String, String> _logovaZnacek = {};
  List<String> _dostupneZnacky = [];
  List<String> _dostupneModely = [];
  String _vybranaZnackaString = '';
  int _autocompleteResetKey = 0;

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    _generujCisloZakazky();
    _nactiNastaveni();
    _nactiUkonyZDatabaze();
    _nactiDatabaziZnacek();

    rezervaceKeZpracovani.addListener(_zpracujRezervaciZPlanovace);
  }

  /// Načte katalog úkonů servisu — zobrazí se jako rychlé tipy na stránce 5 (Požadované práce).
  Future<void> _nactiUkonyZDatabaze() async {
    if (_sId == null) {
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
        final ukonyZDb = snapshot.docs
            .map((doc) {
              final data = doc.data();
              return (data['nazev'] ?? data['nazev_ukonu'] ?? '').toString();
            })
            .where((nazev) => nazev.isNotEmpty)
            .toList();

        ukonyZDb.sort();

        if (mounted) {
          setState(() {
            _rychleUkony = ukonyZDb;
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

  /// Přednaplní formulář daty z rezervace v plánovači.
  /// Volá se automaticky přes listener na [rezervaceKeZpracovani].
  /// Přednaplní formulář daty z rezervace v plánovači.
  /// Volá se automaticky přes listener na [rezervaceKeZpracovani].
  Future<void> _zpracujRezervaciZPlanovace() async {
    final id = rezervaceKeZpracovani.value;
    if (id == null) return;

    try {
      _zpracovavanaRezervaceId = id;
      final doc =
          await FirebaseFirestore.instance.collection('planovac').doc(id).get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _autocompleteResetKey++;
          _spzController.text = data['spz'] ?? '';
          _znackaController.text = data['znacka'] ?? '';
          _modelController.text = data['model'] ?? '';
          _vinController.text = data['vin'] ?? '';

          _jmenoController.text = data['zakaznik_jmeno'] ?? '';
          _icoController.text = data['zakaznik_ico'] ?? '';
          _nastavitTelefon(data['zakaznik_telefon'] ?? '');
          _emailZController.text = data['zakaznik_email'] ?? '';
          _vybranyZakaznikId = data['zakaznik_id'];

          final ukon = data['nazev_ukonu'];
          if (ukon != null && ukon.toString().isNotEmpty) {
            _pozadavkyControllers.clear();
            _pozadavkyControllers
                .add(TextEditingController(text: ukon.toString()));
          }
        });

        if (_spzController.text.isNotEmpty && _sId != null) {
          final vozidlaQuery = await FirebaseFirestore.instance
              .collection('vozidla')
              .where('servis_id', isEqualTo: _sId)
              .where('spz', isEqualTo: _spzController.text)
              .limit(1)
              .get();
          if (vozidlaQuery.docs.isNotEmpty) {
            await _aplikovatVybraneVozidlo(vozidlaQuery.docs.first.data());
          }
        }

        setState(() => _currentPage = 0);
        _pageController.jumpToPage(0);
      }
    } catch (e) {
      debugPrint("Chyba při načítání rezervace: $e");
    } finally {
      rezervaceKeZpracovani.value = null;
    }
  }

  /// Načte databázi značek a modelů z Firestore (kolekce 'znacka').
  /// Výsledek se použije pro autocomplete na stránce 1 a pro loga v dropdownu.
  Future<void> _nactiDatabaziZnacek() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('znacka').get();
      Map<String, List<String>> nacteno = {};
      Map<String, String> loga = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final nazev = data['nazev']?.toString() ?? doc.id;
        final modely = List<String>.from(data['model'] ?? []);
        nacteno[nazev] = modely;
        if (data['logo'] != null && data['logo'].toString().isNotEmpty) {
          loga[nazev] = data['logo'].toString();
        }
      }

      if (mounted) {
        setState(() {
          _databazeZnacek = nacteno;
          _logovaZnacek = loga;
          _dostupneZnacky = _databazeZnacek.keys.toList()..sort();
        });
      }
    } catch (e) {
      debugPrint("Chyba při načítání značek: $e");
    }
  }

  void _aktualizujModely(String znacka) {
    setState(() {
      _vybranaZnackaString = znacka;
      _autocompleteResetKey++;
      if (_databazeZnacek.containsKey(znacka)) {
        _dostupneModely = _databazeZnacek[znacka]!..sort();
      } else {
        _dostupneModely = [];
      }
      _modelController.clear();
    });
  }

  /// Načte výchozí nastavení servisu — konkrétně příznak „automaticky odesílat e-maily",
  /// který přednaplní checkbox na poslední stránce průvodce.
  Future<void> _nactiNastaveni() async {
    if (_sId != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('nastaveni_servisu')
            .doc(_sId)
            .get();
        if (doc.exists) {
          final data = doc.data()!;
          if (mounted) {
            setState(() {
              if (data.containsKey('default_odesilat_emaily')) {
                _defaultOdeslatEmail = data['default_odesilat_emaily'] as bool;
                _odeslatEmail = _defaultOdeslatEmail;
              }
            });
          }
        }
      } catch (e) {
        debugPrint("Chyba při načítání nastavení servisu: $e");
      }
    }
  }

  /// Vygeneruje unikátní číslo zakázky podle formátu nastaveného v nastavení servisu.
  /// Čte prefix, rok/měsíc formát a délku počítadla, pak prohledá existující zakázky
  /// a přidá o 1 vyšší číslo než dosavadní maximum ve stejné sérii.
  Future<void> _generujCisloZakazky() async {
    setState(() => _isGeneratingCislo = true);
    try {
      if (_sId == null) return;

      final nastaveniDoc = await FirebaseFirestore.instance
          .collection('nastaveni_servisu')
          .doc(_sId)
          .get();
      final data =
          nastaveniDoc.exists ? nastaveniDoc.data()! : <String, dynamic>{};

      // Prefix: priorita prefix_zakazka (nastaveni.dart), fallback prefix_zakazky (starý onboarding)
      String prefix = data['prefix_zakazka']?.toString().trim() ?? '';
      if (prefix.isEmpty)
        prefix = data['prefix_zakazky']?.toString().trim() ?? '';
      if (prefix.isEmpty) prefix = 'ZAK';

      final rokFormat = data['cfg_rok_zakazka']?.toString() ?? '{YYYY}';
      final mesicFormat = data['cfg_mesic_zakazka']?.toString() ?? '{MM}';
      final oddelovac = data['cfg_oddelovac_zakazka']?.toString() ?? '';
      final delka = (data['cfg_delka_zakazka'] as num?)?.toInt() ?? 5;

      final ted = DateTime.now();
      String rokPart = '';
      if (rokFormat == '{YYYY}') {
        rokPart = DateFormat('yyyy').format(ted);
      } else if (rokFormat == '{YY}') {
        rokPart = DateFormat('yy').format(ted);
      }

      String mesicPart = '';
      if (mesicFormat == '{MM}') {
        mesicPart = DateFormat('MM').format(ted);
      }

      // Prefix bez poÄŤĂ­tadla (pouĹľije se pro hledĂˇnĂ­ existujĂ­cĂ­ch ÄŤĂ­sel v rĂˇmci Ĺ™ady)
      List<String> casti = [prefix];
      if (rokPart.isNotEmpty) casti.add(rokPart);
      if (mesicPart.isNotEmpty) casti.add(mesicPart);
      final hledanyPrefix = casti.join(oddelovac);

      final querySnapshot = await FirebaseFirestore.instance
          .collection('zakazky')
          .where('servis_id', isEqualTo: _sId)
          .get();

      int nextNumber = 1;
      for (var doc in querySnapshot.docs) {
        final cislo = doc.data()['cislo_zakazky']?.toString() ?? '';
        if (cislo.startsWith(hledanyPrefix)) {
          String koncovka = cislo.substring(hledanyPrefix.length);
          if (oddelovac.isNotEmpty && koncovka.startsWith(oddelovac)) {
            koncovka = koncovka.substring(oddelovac.length);
          }
          final currentNum = int.tryParse(koncovka) ?? 0;
          if (currentNum >= nextNumber) nextNumber = currentNum + 1;
        }
      }

      casti.add(nextNumber.toString().padLeft(delka, '0'));
      final finalCislo = casti.join(oddelovac);

      if (mounted) {
        setState(() => _zakazkaController.text = finalCislo);
      }
    } catch (e) {
      debugPrint('Chyba při generování čísla: $e');
      if (mounted) {
        final ted = DateTime.now();
        setState(() {
          _zakazkaController.text =
              'ZAK${DateFormat('yyyyMM').format(ted)}00001';
        });
      }
    } finally {
      if (mounted) setState(() => _isGeneratingCislo = false);
    }
  }

  /// Vyhledá vozidlo v databázi servisu podle SPZ (prefixová shoda).
  /// Při jediném výsledku přednaplní formulář okamžitě, při více zobrazí výběrový dialog.
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

  /// Přenese data nalezeného vozidla (SPZ, VIN, značka…) i navázaného zákazníka do formuláře.
  Future<void> _aplikovatVybraneVozidlo(
      Map<String, dynamic> vozidloData) async {
    if (_sId == null) return;
    setState(() {
      _spzController.text = vozidloData['spz']?.toString() ?? '';
      String nactenaZnacka = vozidloData['znacka']?.toString() ?? '';
      _znackaController.text = nactenaZnacka;
      _aktualizujModely(nactenaZnacka);
      _modelController.text = vozidloData['model']?.toString() ?? '';
      _vinController.text = vozidloData['vin']?.toString() ?? '';
      _rokVyrobyController.text = vozidloData['rok_vyroby']?.toString() ?? '';
      _motorizaceController.text = vozidloData['motorizace']?.toString() ?? '';
      _tachometrController.text = vozidloData['tachometr']?.toString() ?? '';
      _stkMesicController.text = vozidloData['stk_mesic']?.toString() ?? '';
      _stkRokController.text = vozidloData['stk_rok']?.toString() ?? '';
      if (vozidloData['palivo'] != null &&
          _moznostiPaliva.contains(vozidloData['palivo'])) {
        _vybranePalivo = vozidloData['palivo'];
      }
      if (vozidloData['prevodovka'] != null &&
          _moznostiPrevodovky.contains(vozidloData['prevodovka'])) {
        _vybranaPrevodovka = vozidloData['prevodovka'];
      }
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
          _jmenoController.text = z['jmeno']?.toString() ?? '';
          _icoController.text = z['ico']?.toString() ?? '';
          _uliceController.text =
              z['ulice']?.toString() ?? (z['adresa']?.toString() ?? '');
          _mestoController.text = z['mesto']?.toString() ?? '';
          _pscController.text = z['psc']?.toString() ?? '';
          _nastavitTelefon(z['telefon']?.toString() ?? '');
          _emailZController.text = z['email']?.toString() ?? '';
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
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(25))),
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

  @override
  void dispose() {
    _spzController.dispose();
    _znackaController.dispose();
    _modelController.dispose();
    _vinController.dispose();
    _jmenoController.dispose();
    _telefonController.dispose();
    _emailZController.dispose();
    _tachometrController.dispose();
    _poskozeniController.dispose();
    _signatureController.dispose();
    _uliceController.dispose();
    _mestoController.dispose();
    _pscController.dispose();
    for (var c in _pozadavkyControllers) {
      c.dispose();
    }
    rezervaceKeZpracovani.removeListener(_zpracujRezervaciZPlanovace);
    super.dispose();
  }

  static const List<Map<String, String>> _predvolby = [
    {'kod': '+420', 'vlajka': '🇨🇿', 'nazev': 'Česká republika'},
    {'kod': '+421', 'vlajka': '🇸🇰', 'nazev': 'Slovensko'},
    {'kod': '+49', 'vlajka': '🇩🇪', 'nazev': 'Německo'},
    {'kod': '+43', 'vlajka': '🇦🇹', 'nazev': 'Rakousko'},
    {'kod': '+48', 'vlajka': '🇵🇱', 'nazev': 'Polsko'},
    {'kod': '+36', 'vlajka': '🇭🇺', 'nazev': 'Maďarsko'},
    {'kod': '+380', 'vlajka': '🇺🇦', 'nazev': 'Ukrajina'},
    {'kod': '+44', 'vlajka': '🇬🇧', 'nazev': 'Velká Británie'},
    {'kod': '+1', 'vlajka': '🇺🇸', 'nazev': 'USA'},
  ];

  // Rozloží uložené číslo ("+420731901003") na předvolbu a samotné číslo.
  // Stará čísla bez předvolby zůstanou v _telefonController beze změny.
  void _nastavitTelefon(String telefon) {
    for (final p in _predvolby) {
      final kod = p['kod']!;
      if (telefon.startsWith(kod)) {
        setState(() => _telPredvolba = kod);
        _telefonController.text = telefon.substring(kod.length).trim();
        return;
      }
    }
    _telefonController.text = telefon;
  }

  String get _plneTelCislo => '$_telPredvolba${_telefonController.text.trim()}';

  /// Dotáže ARES API na IČO a přednaplní jméno a adresu zákazníka (strana 2).
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
          _jmenoController.text = data['obchodniJmeno'] ?? '';
          final sidlo = data['sidlo'] ?? {};
          final ulice = sidlo['nazevUlice'] ?? sidlo['nazevObce'] ?? '';
          final cp =
              sidlo['cisloDomovni'] != null ? ' ${sidlo['cisloDomovni']}' : '';
          final co = sidlo['cisloOrientacni'] != null
              ? '/${sidlo['cisloOrientacni']}'
              : '';
          final obec = sidlo['nazevObce'] ?? '';
          final psc = (sidlo['psc'] != null) ? sidlo['psc'].toString() : '';
          if (ulice.isEmpty && sidlo['textovaAdresa'] != null) {
            _uliceController.text = sidlo['textovaAdresa'];
            _mestoController.clear();
            _pscController.clear();
          } else {
            _uliceController.text = '$ulice$cp$co'.trim();
            _mestoController.text = obec;
            _pscController.text = psc;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Údaje z ARES byly úspěšně načteny.'),
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

  void _otevritVyberZakaznika() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VyberZakaznikaSheet(
        onVybrano: (zakaznik) async {
          setState(() {
            _vybranyZakaznikId = zakaznik['id_zakaznika'];
            _jmenoController.text = zakaznik['jmeno'] ?? '';
            _icoController.text = zakaznik['ico'] ?? '';
            _uliceController.text = zakaznik['ulice']?.toString() ??
                (zakaznik['adresa']?.toString() ?? '');
            _mestoController.text = zakaznik['mesto']?.toString() ?? '';
            _pscController.text = zakaznik['psc']?.toString() ?? '';
            _nastavitTelefon(zakaznik['telefon'] ?? '');
            _emailZController.text = zakaznik['email'] ?? '';
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

  Future<void> _moveNext() async {
    FocusScope.of(context).unfocus();
    if (_currentPage == 0) {
      final zadaneCislo = _zakazkaController.text.trim();
      if (zadaneCislo.isEmpty || _spzController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Číslo zakázky a SPZ jsou povinné údaje!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3)));
        return;
      }
      setState(() => _isCheckingZakazka = true);
      try {
        if (_sId != null) {
          final docSnap = await FirebaseFirestore.instance
              .collection('zakazky')
              .where('servis_id', isEqualTo: _sId)
              .where('cislo_zakazky', isEqualTo: zadaneCislo)
              .get();
          if (docSnap.docs.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'Toto číslo zakázky již v databázi existuje! Zadejte prosím jiné.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4)));
            setState(() => _isCheckingZakazka = false);
            return;
          }
        }
      } catch (e) {
        debugPrint('Chyba pĹ™i kontrole ÄŤĂ­sla: $e');
      } finally {
        if (mounted) setState(() => _isCheckingZakazka = false);
      }
    }
    if (_currentPage == _totalPages - 1) {
      if (_signatureController.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Zákazník musí připojit podpis před odesláním.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3)));
        return;
      }
      _startDirectUpload();
    } else {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic);
    }
  }

  void _moveBack() {
    FocusScope.of(context).unfocus();
    _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic);
  }

  Future<void> _startDirectUpload() async {
    setState(() => _isUploading = true);
    try {
      await _uploadToFirebase();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Zakázka úspěšně odeslána'),
            backgroundColor: Colors.green));
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Chyba při odesílání: $e'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  String _generatePortalToken(String docId) {
    final rand = DateTime.now().millisecondsSinceEpoch;
    final extra = docId.hashCode.abs();
    final combined = (rand ^ extra).toRadixString(36);
    return (combined + combined).substring(0, 12);
  }

  Future<void> _uploadToFirebase() async {
    if (_sId == null) throw Exception('Nejste přiřazeni k žádnému servisu!');
    final user = FirebaseAuth.instance.currentUser;
    final Map<String, List<String>> imageUrlsByCategory = {};
    String zakazkaId = _zakazkaController.text.trim();

    for (var entry in _categoryImages.entries) {
      final categoryKey = entry.key;
      final images = entry.value;
      imageUrlsByCategory[categoryKey] = [];
      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        String fileName =
            '${categoryKey}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('servisy/$_sId/zakazky/$zakazkaId/$fileName');
        await ref.putData(await image.readAsBytes());
        String downloadUrl = await ref.getDownloadURL();
        imageUrlsByCategory[categoryKey]!.add(downloadUrl);
      }
    }

    String? podpisUrl;
    if (_signatureController.isNotEmpty) {
      final Uint8List? signatureBytes = await _signatureController.toPngBytes();
      if (signatureBytes != null) {
        Reference ref = FirebaseStorage.instance.ref().child(
            'servisy/$_sId/zakazky/$zakazkaId/podpis_${DateTime.now().millisecondsSinceEpoch}.png');
        await ref.putData(signatureBytes);
        podpisUrl = await ref.getDownloadURL();
      }
    }

    String zakaznikId = '';
    if (_vybranyZakaznikId != null && _vybranyZakaznikId!.isNotEmpty) {
      zakaznikId = _vybranyZakaznikId!;
    } else {
      final telefon = _plneTelCislo;
      final ico = _icoController.text.trim();
      QuerySnapshot? existujici;

      if (telefon.isNotEmpty) {
        final snap = await FirebaseFirestore.instance
            .collection('zakaznici')
            .where('servis_id', isEqualTo: _sId)
            .where('telefon', isEqualTo: telefon)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) existujici = snap;
      }
      if (existujici == null && ico.isNotEmpty) {
        final snap = await FirebaseFirestore.instance
            .collection('zakaznici')
            .where('servis_id', isEqualTo: _sId)
            .where('ico', isEqualTo: ico)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) existujici = snap;
      }

      if (existujici != null && existujici.docs.isNotEmpty) {
        zakaznikId = existujici.docs.first['id_zakaznika'];
      } else {
        zakaznikId = 'ZAK_${DateTime.now().millisecondsSinceEpoch}';
      }
    }

    String ulice = _uliceController.text.trim();
    String mesto = _mestoController.text.trim();
    String psc = _pscController.text.trim();
    String kombinovanaAdresa =
        '$ulice, $psc $mesto'.trim().replaceAll(RegExp(r'^, |,$'), '');

    if (_jmenoController.text.trim().isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('zakaznici')
          .doc('${_sId}_$zakaznikId')
          .set({
        'servis_id': _sId,
        'id_zakaznika': zakaznikId,
        'jmeno': _jmenoController.text.trim(),
        'ico': _icoController.text.trim(),
        'ulice': ulice,
        'mesto': mesto,
        'psc': psc,
        'adresa': kombinovanaAdresa,
        'telefon': _plneTelCislo,
        'email': _emailZController.text.trim(),
        'posledni_navsteva': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    String spz = _spzController.text.trim().toUpperCase();
    if (spz.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('vozidla')
          .doc('${_sId}_$spz')
          .set({
        'servis_id': _sId,
        'zakaznik_id': zakaznikId,
        'spz': spz,
        'vin': _vinController.text.trim().toUpperCase(),
        'znacka': _znackaController.text.trim(),
        'model': _modelController.text.trim(),
        'rok_vyroby': _rokVyrobyController.text.trim(),
        'motorizace': _motorizaceController.text.trim(),
        'palivo': _vybranePalivo,
        'prevodovka': _vybranaPrevodovka,
        'tachometr': _tachometrController.text.trim(),
        'stk_mesic': _stkMesicController.text.trim(),
        'stk_rok': _stkRokController.text.trim(),
        'posledni_navsteva': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    List<String> pozadovaneUkony = _pozadavkyControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    Map<String, dynamic> zakazkaData = {
      'servis_id': _sId,
      'zakaznik_id': zakaznikId,
      'cislo_zakazky': zakazkaId,
      'spz': spz,
      'vin': _vinController.text.trim().toUpperCase(),
      'znacka': _znackaController.text.trim(),
      'model': _modelController.text.trim(),
      'rok_vyroby': _rokVyrobyController.text.trim(),
      'motorizace': _motorizaceController.text.trim(),
      'palivo_typ': _vybranePalivo,
      'prevodovka': _vybranaPrevodovka,
      'stav_zakazky': 'Přijato',
      'rezervace_id': _zpracovavanaRezervaceId, // Uložíme ID pro Dokončeno
      'zakaznik': {
        'id_zakaznika': zakaznikId,
        'jmeno': _jmenoController.text.trim(),
        'ico': _icoController.text.trim(),
        'ulice': ulice,
        'mesto': mesto,
        'psc': psc,
        'adresa': kombinovanaAdresa,
        'telefon': _plneTelCislo,
        'email': _emailZController.text.trim(),
      },
      'stav_vozidla': {
        'tachometr': _tachometrController.text.trim(),
        'nadrz': _stavNadrze,
        'poskozeni':
            _vybranePoskozeni.isEmpty ? ['Neuvedeno'] : _vybranePoskozeni,
        'stk_mesic': _stkMesicController.text.trim(),
        'stk_rok': _stkRokController.text.trim(),
        'pneu_lp': _pneuLPController.text.trim(),
        'pneu_pp': _pneuPPController.text.trim(),
        'pneu_lz': _pneuLZController.text.trim(),
        'pneu_pz': _pneuPZController.text.trim(),
      },
      'pozadavky_zakaznika': pozadovaneUkony,
      'poznamky': _poskozeniController.text.trim(),
      'fotografie_urls': imageUrlsByCategory,
      'podpis_url': podpisUrl,
      'provedene_prace': [],
      'cas_prijeti': FieldValue.serverTimestamp(),
      'prijal_uid': user?.uid,
      'prijal_jmeno': globalUserJmeno ?? user?.email ?? 'Neznámý',
      'portal_token': _generatePortalToken('${_sId}_$zakazkaId'),
    };

    await FirebaseFirestore.instance
        .collection('zakazky')
        .doc('${_sId}_$zakazkaId')
        .set(zakazkaData);

    if (_zpracovavanaRezervaceId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('planovac')
            .doc(_zpracovavanaRezervaceId)
            .update({
          'zakazka_doc_id': '${_sId}_$zakazkaId',
          'stav': 'Přijato na servis'
        });
      } catch (e) {
        debugPrint("Chyba při updatování plánovače: $e");
      }
    }

    final emailZakanika = _emailZController.text.trim();
    if (_odeslatEmail &&
        emailZakanika.isNotEmpty &&
        emailZakanika.contains('@')) {
      String odesilatelJmeno = 'Torkis Servis';
      String odesilatelIco = '';
      final docNastaveni = await FirebaseFirestore.instance
          .collection('nastaveni_servisu')
          .doc(_sId)
          .get();
      if (docNastaveni.exists) {
        odesilatelJmeno =
            docNastaveni.data()?['nazev_servisu'] ?? 'Torkis Servis';
        odesilatelIco = docNastaveni.data()?['ico_servisu'] ?? '';
      }

      final pdfBytes = await GlobalPdfGenerator.generateDocument(
        data: zakazkaData,
        servisNazev: odesilatelJmeno,
        servisIco: odesilatelIco,
        typ: PdfTyp.protokol,
      );

      Reference pdfRef = FirebaseStorage.instance
          .ref()
          .child('servisy/$_sId/zakazky/$zakazkaId/protokol_$zakazkaId.pdf');
      await pdfRef.putData(
          pdfBytes, SettableMetadata(contentType: 'application/pdf'));
      String pdfDownloadUrl = await pdfRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('maily').add({
        'to': emailZakanika,
        'from': '$odesilatelJmeno (přes TORKIS) <jan.svihalek00@gmail.com>',
        'replyTo': user?.email ?? '',
        'message': {
          'subject': 'Protokol o přijetí vozidla $spz - $odesilatelJmeno',
          'html': '''
            <div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; margin: 0 auto; border: 1px solid #eee; padding: 20px; border-radius: 10px;">
              <h2 style="color: #2196F3; border-bottom: 2px solid #2196F3; padding-bottom: 10px;">Dobrý den,</h2>
              <p>v příloze Vám zasíláme odkaz na podepsaný protokol o přijetí Vašeho vozidla <b>$spz</b> do našeho servisu.</p>
              <div style="text-align: center; margin: 30px 0;">
                <a href="$pdfDownloadUrl" style="background-color: #2196F3; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 16px; display: inline-block;">Zobrazit a stáhnout protokol</a>
              </div>
              <p>V případě jakýchkoliv dotazů na tento e-mail jednoduše odpovězte, zpráva nám bude doručena.</p>
              <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
              <p style="font-size: 12px; color: #777;">Tento e-mail byl vygenerován automaticky systémem <b>Torkis.cz</b> pro servis <b>$odesilatelJmeno</b>.</p>
            </div>
          ''',
        },
      });
    }
  }

  void _resetForm() {
    _jmenoController.clear();
    _icoController.clear();
    _uliceController.clear();
    _mestoController.clear();
    _pscController.clear();
    _telefonController.clear();
    _emailZController.clear();
    _vybranyZakaznikId = null;
    _zpracovavanaRezervaceId = null;
    _nalezenaVozidla.clear();

    _spzController.clear();
    _vinController.clear();
    _znackaController.clear();
    _vybranaZnackaString = '';
    _dostupneModely.clear();
    _modelController.clear();
    _rokVyrobyController.clear();
    _motorizaceController.clear();
    _vybranePalivo = 'Benzín';
    _vybranaPrevodovka = 'Manuální';
    _poznamkyController.clear();
    _categoryImages.clear();
    _vybranePoskozeni.clear();
    _stkMesicController.clear();
    _stkRokController.clear();
    _pneuLPController.clear();
    _pneuPPController.clear();
    _pneuLZController.clear();
    _pneuPZController.clear();
    _tachometrController.clear();
    _stavNadrze = 50.0;
    _poskozeniController.clear();
    _signatureController.clear();
    setState(() => _autocompleteResetKey++);

    for (var c in _pozadavkyControllers) {
      c.dispose();
    }
    _pozadavkyControllers.clear();
    _pozadavkyControllers.add(TextEditingController());

    _generujCisloZakazky();

    _odeslatEmail = _defaultOdeslatEmail;

    setState(() => _currentPage = 0);
    _pageController.jumpToPage(0);
  }

  Future<void> _takePhotoSeries(String categoryKey) async {
    if (kIsWeb) {
      // Web nemĂˇ pĹ™Ă­mĂ˝ pĹ™Ă­stup ke kameĹ™e pĹ™es camera package â€” pouĹľijeme image_picker
      final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 60,
          maxWidth: 1280,
          maxHeight: 1280);
      if (photo != null) {
        setState(() {
          _categoryImages[categoryKey] ??= [];
          _categoryImages[categoryKey]!.add(photo);
        });
      }
      return;
    }
    final result = await Navigator.push<List<XFile>>(
      context,
      MaterialPageRoute(builder: (_) => const MultiShotCameraPage()),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _categoryImages[categoryKey] ??= [];
        _categoryImages[categoryKey]!.addAll(result);
      });
    }
  }

  Future<void> _pickFromGallery(String categoryKey) async {
    final List<XFile> photos = await _picker.pickMultiImage(
        imageQuality: 60, maxWidth: 1280, maxHeight: 1280);
    if (photos.isNotEmpty) {
      setState(() {
        if (_categoryImages[categoryKey] == null)
          _categoryImages[categoryKey] = [];
        _categoryImages[categoryKey]!.addAll(photos);
      });
    }
  }

  Future<void> _scanText(
      TextEditingController controller, bool numbersOnly) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Skenování pomocí AI funguje pouze v nainstalované aplikaci (APK/iOS).'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4)));
      return;
    }
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return;
      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      String result = recognizedText.text;
      if (numbersOnly) {
        result = result.replaceAll(RegExp(r'[^0-9]'), '');
      } else {
        result = result.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();
      }
      setState(() => controller.text = result);
      textRecognizer.close();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Chyba skenování: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildVozidloStep(isDark),
                  _buildZakaznikStep(isDark),
                  _buildCheckStep(isDark),
                  _buildPhotoStep(isDark),
                  _buildPraceStep(isDark),
                  _buildPodpisStep(isDark),
                ],
              ),
            ),
            _buildBottomPanel(isDark),
          ],
        ),
        if (_isUploading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Card(
                elevation: 10,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('Odesílám zakázku a protokol...',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── STRANA 1: Identifikace vozidla ────────────────────────────────
  Widget _buildVozidloStep(bool isDark) => StepVozidlo(
        isDark: isDark,
        zakazkaController: _zakazkaController,
        isGeneratingCislo: _isGeneratingCislo,
        onRegenerateCislo: _generujCisloZakazky,
        spzController: _spzController,
        vinController: _vinController,
        znackaController: _znackaController,
        modelController: _modelController,
        rokVyrobyController: _rokVyrobyController,
        motorizaceController: _motorizaceController,
        isLoadingSpz: _isLoadingSpz,
        onHledatSpz: _hledatPodleSpz,
        onScan: _scanText,
        autocompleteResetKey: _autocompleteResetKey,
        dostupneZnacky: _dostupneZnacky,
        dostupneModely: _dostupneModely,
        logovaZnacek: _logovaZnacek,
        databazeZnacek: _databazeZnacek,
        onZnackaSelected: _aktualizujModely,
        vybranePalivo: _vybranePalivo,
        moznostiPaliva: _moznostiPaliva,
        onPalivoChanged: (v) => setState(() => _vybranePalivo = v!),
        vybranaPrevodovka: _vybranaPrevodovka,
        moznostiPrevodovky: _moznostiPrevodovky,
        onPrevodovkaChanged: (v) => setState(() => _vybranaPrevodovka = v!),
        nalezenaVozidla: _nalezenaVozidla,
        onVozidloSelected: _aplikovatVybraneVozidlo,
      );

  // ── STRANA 2: Zákazník ────────────────────────────────
  Widget _buildZakaznikStep(bool isDark) => StepZakaznik(
        isDark: isDark,
        jmenoController: _jmenoController,
        icoController: _icoController,
        uliceController: _uliceController,
        mestoController: _mestoController,
        pscController: _pscController,
        telefonController: _telefonController,
        emailController: _emailZController,
        isLoadingAres: _isLoadingAres,
        onFetchAres: _fetchAresData,
        onVyberZakaznika: _otevritVyberZakaznika,
        telPredvolba: _telPredvolba,
        predvolby: _predvolby,
        onPredvolbaChanged: (kod) => setState(() => _telPredvolba = kod),
      );

  // ── STRANA 3: Stav vozidla při přímu ────────────────
  Widget _buildCheckStep(bool isDark) => StepCheck(
        isDark: isDark,
        tachometrController: _tachometrController,
        stavNadrze: _stavNadrze,
        onStavNadrzeChanged: (val) => setState(() => _stavNadrze = val),
        vybranePoskozeni: _vybranePoskozeni,
        poskozeniMoznosti: _poskozeniMoznosti,
        onPoskozeniChanged: (value, selected) {
          setState(() {
            if (value == 'Žadné') {
              if (selected) {
                _vybranePoskozeni.clear();
                _vybranePoskozeni.add('Žadné');
              } else {
                _vybranePoskozeni.remove('Žadné');
              }
            } else {
              if (selected) {
                _vybranePoskozeni.remove('Žadné');
                _vybranePoskozeni.add(value);
              } else {
                _vybranePoskozeni.remove(value);
              }
            }
          });
        },
        stkMesicController: _stkMesicController,
        stkRokController: _stkRokController,
        pneuLPController: _pneuLPController,
        pneuPPController: _pneuPPController,
        pneuLZController: _pneuLZController,
        pneuPZController: _pneuPZController,
        poskozeniController: _poskozeniController,
      );

  // ── STRANA 4: Fotodokumentace ─────────────────────
  Widget _buildPhotoStep(bool isDark) => StepPhoto(
        isDark: isDark,
        categoryImages: _categoryImages,
        onPickFromGallery: _pickFromGallery,
        onTakePhotoSeries: _takePhotoSeries,
        onRemovePhoto: (key, idx) =>
            setState(() => _categoryImages[key]!.removeAt(idx)),
      );

  // ── STRANA 5: Poždované práce ────────────────────
  Widget _buildPraceStep(bool isDark) => StepPrace(
        isDark: isDark,
        isLoadingUkony: _isLoadingUkony,
        rychleUkony: _rychleUkony,
        pozadavkyControllers: _pozadavkyControllers,
        onPridatUkon: () =>
            setState(() => _pozadavkyControllers.add(TextEditingController())),
        onOdebratUkon: (index) =>
            setState(() => _pozadavkyControllers.removeAt(index)),
        onRychlyUkonTap: (ukon) {
          setState(() {
            if (_pozadavkyControllers.last.text.isEmpty) {
              _pozadavkyControllers.last.text = ukon;
            } else {
              _pozadavkyControllers.add(TextEditingController(text: ukon));
            }
          });
        },
      );

  // ── STRANA 6: Podpis a odeslání ───────────────────
  Widget _buildPodpisStep(bool isDark) => StepPodpis(
        isDark: isDark,
        jmeno: _jmenoController.text,
        ulice: _uliceController.text,
        psc: _pscController.text,
        mesto: _mestoController.text,
        spz: _spzController.text,
        znacka: _znackaController.text,
        email: _emailZController.text,
        pozadavkyControllers: _pozadavkyControllers,
        odeslatEmail: _odeslatEmail,
        onOdeslatEmailChanged: (val) =>
            setState(() => _odeslatEmail = val ?? true),
        signatureController: _signatureController,
      );

  // â”€â”€ SpodnĂ­ navigaÄŤnĂ­ panel (ZpÄ›t / DalĹˇĂ­ / DokonÄŤit) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildBottomPanel(bool isDark) => Container(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121212) : Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5))
            ]),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                  children: List.generate(
                      _totalPages,
                      (index) => Expanded(
                          child: Container(
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                  color: index <= _currentPage
                                      ? Colors.blue
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2)))))),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (_currentPage > 0)
                    IconButton.filledTonal(
                        onPressed: _moveBack,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        padding: const EdgeInsets.all(15)),
                  if (_currentPage > 0) const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isCheckingZakazka ||
                              _isUploading ||
                              _isGeneratingCislo)
                          ? null
                          : _moveNext,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18))),
                      child: (_isCheckingZakazka ||
                              _isUploading ||
                              _isGeneratingCislo)
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(
                              _currentPage == _totalPages - 1
                                  ? 'DOKONČIT A ODESLAT'
                                  : 'DALŠÍ KROK',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
