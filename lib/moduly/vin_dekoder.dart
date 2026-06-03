import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/design_tokens.dart';
import '../core/constants.dart';
import '../core/vincario_service.dart';
import 'auth_gate.dart';
import 'prijem/ocr_camera_page.dart';

/// Překlad anglických Vincario labelů do češtiny pro sekci OSTATNÍ INFORMACE.
const Map<String, String> _kPreloz = {
  // Identifikace
  'WMI': 'WMI',
  'VDS': 'VDS',
  'VIS': 'VIS',
  'Check Digit': 'Kontrolní číslice',
  'Sequential Number': 'Sériové číslo',
  'Vehicle Type': 'Typ vozidla',
  'Vehicle Class': 'Třída vozidla',
  'Model Range': 'Modelová řada',
  'Version': 'Verze',
  'Country of Origin': 'Země původu',
  // Motor
  'Engine Code': 'Kód motoru',
  'Number of Cylinders': 'Počet válců',
  'Valves Per Cylinder': 'Ventily na válec',
  'Bore (mm)': 'Vrtání (mm)',
  'Stroke (mm)': 'Zdvih (mm)',
  'Compression Ratio': 'Kompresní poměr',
  'Valve Train': 'Rozvod ventilů',
  'Fuel System': 'Palivový systém',
  'Turbo': 'Turbodmychadlo',
  'Supercharger': 'Přeplňování',
  'Cooling': 'Chlazení',
  'Engine Position': 'Umístění motoru',
  'Max Torque (Nm)': 'Max. točivý moment (Nm)',
  'Max Torque RPM': 'Otáčky max. momentu',
  'Max Power RPM': 'Otáčky max. výkonu',
  // Výkon a jízdní vlastnosti
  'Max Speed (km/h)': 'Max. rychlost (km/h)',
  '0-100 (s)': '0–100 km/h (s)',
  // Podvozek
  'Front Brakes': 'Přední brzdy',
  'Rear Brakes': 'Zadní brzdy',
  'Steering': 'Řízení',
  'Front Suspension': 'Přední odpružení',
  'Rear Suspension': 'Zadní odpružení',
  'Front Track (mm)': 'Rozchod přední nápravy (mm)',
  'Rear Track (mm)': 'Rozchod zadní nápravy (mm)',
  'Number of Axles': 'Počet náprav',
  'Tires': 'Pneumatiky',
  'Rims': 'Ráfky',
  // Rozměry a hmotnosti
  'Wheelbase (mm)': 'Rozvor náprav (mm)',
  'Length (mm)': 'Délka (mm)',
  'Width (mm)': 'Šířka (mm)',
  'Height (mm)': 'Výška (mm)',
  'Fuel Tank Capacity (L)': 'Objem nádrže (L)',
  'Payload (kg)': 'Užitečná hmotnost (kg)',
  'Towing Capacity (kg)': 'Tažná hmotnost (kg)',
  // Emise a spotřeba
  'CO2 Emission City (g/km)': 'Emise CO₂ ve městě (g/km)',
  'CO2 Emission Highway (g/km)': 'Emise CO₂ mimo město (g/km)',
  'Fuel Consumption City (l/100km)': 'Spotřeba ve městě (l/100 km)',
  'Fuel Consumption Highway (l/100km)': 'Spotřeba mimo město (l/100 km)',
  'Electric Range (km)': 'Elektrický dojezd (km)',
  'Battery Capacity (kWh)': 'Kapacita baterie (kWh)',
  'Charge Time (h)': 'Doba nabíjení (h)',
  // Bezpečnost a výbava
  'ABS': 'ABS',
  'ASR': 'ASR (protiskluz)',
  'ESP': 'ESP',
  'Airbag System': 'Airbagový systém',
  'Power Steering': 'Posilovač řízení',
  'Air Conditioning': 'Klimatizace',
  'Electric Windows': 'Elektrická okna',
  'ISOFIX': 'ISOFIX',
};

class _Sekce {
  final String nazev;
  final IconData icon;
  final List<(String, String)> pole;
  const _Sekce(this.nazev, this.icon, this.pole);
}

class VinDekoderPage extends StatefulWidget {
  const VinDekoderPage({super.key});

  @override
  State<VinDekoderPage> createState() => _VinDekoderPageState();
}

class _VinDekoderPageState extends State<VinDekoderPage> {
  final _vinCtrl = TextEditingController();

  String? get _sId => globalServisId ?? FirebaseAuth.instance.currentUser?.uid;

  bool _loadingKeys = true;
  String _apiKey = '';
  String _secretKey = '';

  bool _loading = false;
  String? _error;
  VincarioResult? _result;
  String? _dekovanyVin;
  String? _logoUrl;

  // Stream uložený jako pole — nevytváří se znovu při každém setState
  Stream<QuerySnapshot>? _historieStream;

  // Počet skutečných API volání (z_cache==false) v aktuálním měsíci
  int _pocetTentoMesic = 0;
  bool _loadingPocet = true;

  int? get _limit => kPlanVinLimit[globalPlanTyp];
  bool get _limitDosazen =>
      _limit != null && _pocetTentoMesic >= _limit!;

  bool get _maKlice => _apiKey.isNotEmpty && _secretKey.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nactiKlice();
  }

  Future<void> _nactiPocetTentoMesic() async {
    if (_sId == null) {
      if (mounted) setState(() => _loadingPocet = false);
      return;
    }
    try {
      final zacatekMesice = DateTime(
          DateTime.now().year, DateTime.now().month, 1);
      final snap = await FirebaseFirestore.instance
          .collection('vin_skeny')
          .where('servis_id', isEqualTo: _sId)
          .where('z_cache', isEqualTo: false)
          .where('cas',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(zacatekMesice))
          .count()
          .get();
      if (mounted) {
        setState(() {
          _pocetTentoMesic = snap.count ?? 0;
          _loadingPocet = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPocet = false);
    }
  }

  void _initHistorieStream() {
    if (_historieStream != null || _sId == null) return;
    // Bez orderBy — nepotřebujeme composite index.
    // Třídíme client-side v _buildHistorieSidebar.
    _historieStream = FirebaseFirestore.instance
        .collection('vin_skeny')
        .where('servis_id', isEqualTo: _sId)
        .limit(50)
        .snapshots();
  }

  @override
  void dispose() {
    _vinCtrl.dispose();
    super.dispose();
  }

  Future<void> _nactiKlice() async {
    try {
      if (_sId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('nastaveni_servisu')
            .doc(_sId)
            .get();
        if (doc.exists) {
          _apiKey = doc.data()?['vincario_api_key']?.toString() ?? '';
          _secretKey = doc.data()?['vincario_secret_key']?.toString() ?? '';
        }
      }
    } catch (_) {
    } finally {
      if (mounted) {
        _initHistorieStream();
        _nactiPocetTentoMesic();
        setState(() => _loadingKeys = false);
      }
    }
  }

  Future<void> _scanVin() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Skenování funguje pouze v nainstalované aplikaci (APK/iOS).'),
          backgroundColor: Colors.orange));
      return;
    }
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const OcrCameraPage(label: 'VIN')),
    );
    if (result != null && result.isNotEmpty && mounted) {
      setState(() => _vinCtrl.text = result.toUpperCase());
      _dekodovat();
    }
  }

  Future<void> _dekodovat() async {
    final vin =
        _vinCtrl.text.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
    if (vin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Zadejte VIN kód.'), backgroundColor: Colors.orange));
      return;
    }
    if (!_maKlice) return;
    if (_limitDosazen) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Dosáhli jste měsíčního limitu $_pocetTentoMesic / $_limit dekódování. '
            'Upgradujte plán pro pokračování.'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _dekovanyVin = vin;
      _logoUrl = null;
    });
    try {
      // 1. Zkusit globální cache
      final cacheDoc = await FirebaseFirestore.instance
          .collection('vin_cache')
          .doc(vin)
          .get();

      VincarioResult res;
      bool zCache;

      if (cacheDoc.exists) {
        final raw = Map<String, dynamic>.from(
            cacheDoc.data()!['raw'] as Map<dynamic, dynamic>);
        res = VincarioResult(raw);
        zCache = true;
      } else {
        // 2. Cache miss → volat API a uložit výsledek
        res = await VincarioService.decode(
            vin: vin, apiKey: _apiKey, secretKey: _secretKey);
        zCache = false;
        _ulozitDoCache(vin, res);
        if (mounted) setState(() => _pocetTentoMesic++);
      }

      if (mounted) {
        setState(() {
          _result = res;
        });
        _ulozitDoHistorie(vin, res, zCache: zCache);
        _nactiLogo(_f(res, ['Make']));
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _ulozitDoHistorie(String vin, VincarioResult r,
      {bool zCache = false}) async {
    if (_sId == null) return;
    try {
      await FirebaseFirestore.instance.collection('vin_skeny').add({
        'servis_id': _sId,
        'vin': vin,
        'znacka': _f(r, ['Make']),
        'model': _f(r, ['Model']),
        'rok': _f(r, ['Model Year']),
        'motorizace': _f(r, ['Engine']),
        'prevodovka': _f(r, ['Transmission']),
        'z_cache': zCache,
        'cas': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> _ulozitDoCache(String vin, VincarioResult r) async {
    try {
      await FirebaseFirestore.instance.collection('vin_cache').doc(vin).set({
        'vin': vin,
        'raw': r.raw,
        'dekodovano': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> _nactiLogo(String znacka) async {
    if (znacka.isEmpty) return;
    try {
      final q = await FirebaseFirestore.instance
          .collection('znacka')
          .where('nazev', isEqualTo: znacka)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty && mounted) {
        final url = q.docs.first.data()['logo']?.toString() ?? '';
        if (url.isNotEmpty) setState(() => _logoUrl = url);
      }
    } catch (_) {}
  }

  String _f(VincarioResult r, List<String> keys) {
    for (final k in keys) {
      final v = r.field(k);
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  String _formatCislo(String raw) {
    final n = int.tryParse(raw.replaceAll(RegExp(r'\D'), ''));
    if (n == null) return raw;
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _formatCas(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Právě teď';
    if (diff.inMinutes < 60) return 'před ${diff.inMinutes} min';
    if (dt.day == now.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}.${dt.month}.';
  }

  List<_Sekce> _buildSekce(VincarioResult r) {
    final kW = _f(r, ['Engine Power (kW)']);
    final hp = _f(r, ['Engine Power (HP)']);
    final vykon = [
      if (kW.isNotEmpty) '$kW kW',
      if (hp.isNotEmpty) '($hp k)',
    ].join(' ');

    final mesic1 = _f(r, ['Month of First Registration']);
    final rok1 = _f(r, ['Year of First Registration']);
    final reg1 = (mesic1.isNotEmpty && rok1.isNotEmpty)
        ? '${mesic1.padLeft(2, '0')} / $rok1'
        : rok1;

    final objem = _f(r, ['Engine Displacement (ccm)']);
    final objemStr = objem.isNotEmpty ? '${_formatCislo(objem)} cm³' : '';

    final curb = _f(r, ['Curb Weight (kg)']);
    final gvw = _f(r, ['Gross Vehicle Weight (kg)']);
    final co2 = _f(r, ['CO2 Emission (g/km)']);
    final spotr = _f(r,
        ['Fuel Consumption Combined (l/100km)', 'Fuel Consumption (l/100km)']);

    List<(String, String)> filtr(List<(String, String)> lst) =>
        lst.where((p) => p.$2.isNotEmpty).toList();

    final mfAddr = [
      _f(r, ['Manufacturer Address']),
      _f(r, ['Plant City']),
      _f(r, ['Plant Country']),
    ].where((s) => s.isNotEmpty).join(', ');

    final identifikace = filtr([
      ('Značka', _f(r, ['Make'])),
      ('Model', _f(r, ['Model'])),
      ('Obchodní označení', _f(r, ['Commercial Name'])),
      ('Rok výroby', _f(r, ['Model Year'])),
      ('Karosérie', _f(r, ['Body Type'])),
      ('Body', _f(r, ['Body'])),
      ('Typ / varianta', _f(r, ['Trim', 'Series'])),
      ('Místo výroby', mfAddr),
    ]);

    final torque = _f(r, ['Max Torque (Nm)']);
    final speed = _f(r, ['Max Speed (km/h)']);
    final cylinders = _f(r, ['Number of Cylinders']);
    final engineCode = _f(r, ['Engine Code']);
    final spotrMesto = _f(r, ['Fuel Consumption City (l/100km)']);
    final spotrDalnice = _f(r, ['Fuel Consumption Highway (l/100km)']);
    final elektDojezd = _f(r, ['Electric Range (km)']);
    final rozvor = _f(r, ['Wheelbase (mm)']);
    final delka = _f(r, ['Length (mm)']);
    final sirka = _f(r, ['Width (mm)']);
    final vyska = _f(r, ['Height (mm)']);
    final nadrz = _f(r, ['Fuel Tank Capacity (L)']);
    final tazna = _f(r, ['Towing Capacity (kg)']);

    final motor = filtr([
      ('Motorizace', _f(r, ['Engine'])),
      ('Typ motoru', _f(r, ['Engine Type'])),
      ('Kód motoru', engineCode),
      ('Zdvihový objem', objemStr),
      ('Počet válců', cylinders),
      ('Výkon', vykon),
      ('Max. točivý moment', torque.isNotEmpty ? '$torque Nm' : ''),
      ('Palivo', _f(r, ['Fuel Type'])),
      ('Převodovka', _f(r, ['Transmission'])),
      ('Počet převodů', _f(r, ['Number of Gears', 'Gears'])),
      ('Pohon', _f(r, ['Drive'])),
      ('Max. rychlost', speed.isNotEmpty ? '$speed km/h' : ''),
    ]);

    final karoserie = filtr([
      ('Typ karosérie', _f(r, ['Body Type'])),
      ('Počet dveří', _f(r, ['Number of Doors'])),
      ('Počet míst', _f(r, ['Number of Seats'])),
      ('Provozní hmotnost', curb.isNotEmpty ? '$curb kg' : ''),
      ('Max. hmotnost', gvw.isNotEmpty ? '${_formatCislo(gvw)} kg' : ''),
      ('Tažná hmotnost', tazna.isNotEmpty ? '$tazna kg' : ''),
      ('Rozvor náprav', rozvor.isNotEmpty ? '$rozvor mm' : ''),
      ('Délka', delka.isNotEmpty ? '$delka mm' : ''),
      ('Šířka', sirka.isNotEmpty ? '$sirka mm' : ''),
      ('Výška', vyska.isNotEmpty ? '$vyska mm' : ''),
      ('Objem nádrže', nadrz.isNotEmpty ? '$nadrz L' : ''),
    ]);

    final registrace = filtr([
      ('1. registrace', reg1),
      ('Emisní norma', _f(r, ['Emission Standard'])),
      ('Emise CO₂', co2.isNotEmpty ? '$co2 g/km' : ''),
      ('Spotřeba (komb.)', spotr.isNotEmpty ? '$spotr l/100 km' : ''),
      ('Spotřeba ve městě',
          spotrMesto.isNotEmpty ? '$spotrMesto l/100 km' : ''),
      ('Spotřeba mimo město',
          spotrDalnice.isNotEmpty ? '$spotrDalnice l/100 km' : ''),
      ('Elektrický dojezd',
          elektDojezd.isNotEmpty ? '$elektDojezd km' : ''),
    ]);

    // Pole pokrytá výše — filtrují se ze sekce OSTATNÍ.
    const mapovane = {
      'Make', 'Model', 'Commercial Name', 'Model Year',
      'Body Type', 'Body', 'Trim', 'Series',
      'Manufacturer Address', 'Plant City', 'Plant Country',
      'Engine', 'Engine Type', 'Engine Code',
      'Engine Displacement (ccm)',
      'Engine Power (kW)', 'Engine Power (HP)',
      'Number of Cylinders', 'Max Torque (Nm)',
      'Fuel Type', 'Transmission', 'Number of Gears', 'Gears', 'Drive',
      'Max Speed (km/h)',
      'Number of Doors', 'Number of Seats',
      'Curb Weight (kg)', 'Gross Vehicle Weight (kg)', 'Towing Capacity (kg)',
      'Wheelbase (mm)', 'Length (mm)', 'Width (mm)', 'Height (mm)',
      'Fuel Tank Capacity (L)',
      'Month of First Registration', 'Year of First Registration',
      'Emission Standard', 'CO2 Emission (g/km)',
      'Fuel Consumption Combined (l/100km)', 'Fuel Consumption (l/100km)',
      'Fuel Consumption City (l/100km)', 'Fuel Consumption Highway (l/100km)',
      'Electric Range (km)',
    };

    // Zbývající pole — labely přeloženy do češtiny přes _kPreloz.
    final ostatni = r.vsechnyUdaje
        .where((p) => !mapovane.contains(p.label))
        .map((p) => (_kPreloz[p.label] ?? p.label, p.value))
        .toList();

    return [
      if (identifikace.isNotEmpty)
        _Sekce('IDENTIFIKACE', Icons.label_outline_rounded, identifikace),
      if (motor.isNotEmpty)
        _Sekce('MOTOR A POHON', Icons.settings_outlined, motor),
      if (karoserie.isNotEmpty)
        _Sekce('KAROSERIE A ROZMĚRY', Icons.directions_car_outlined, karoserie),
      if (registrace.isNotEmpty)
        _Sekce('PALIVO A EMISE', Icons.cloud_outlined, registrace),
      if (ostatni.isNotEmpty)
        _Sekce('OSTATNÍ INFORMACE', Icons.data_object_rounded, ostatni),
    ];
  }

  void _reset() => setState(() {
        _result = null;
        _error = null;
        _dekovanyVin = null;
        _logoUrl = null;
        _vinCtrl.clear();
      });

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loadingKeys) {
      return const Center(child: CircularProgressIndicator());
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(TokSpace.xl),
                  child: _buildMainColumn(context, wide: true),
                ),
              ),
              VerticalDivider(width: 1, thickness: 1, color: context.tok.line),
              SizedBox(
                width: 280,
                child: _buildHistorieSidebar(context),
              ),
            ],
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(TokSpace.lg),
          child: _buildMainColumn(context, wide: false),
        );
      },
    );
  }

  Widget _buildMainColumn(BuildContext context, {required bool wide}) {
    final tok = context.tok;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_result == null && !_loading) ...[
          Text('Skener VIN',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: tok.textPrimary,
                height: 1.1,
              )),
          const SizedBox(height: 4),
          Text('Rychlé vyhledání specifikace vozu z VIN kódu',
              style: TextStyle(fontSize: 13, color: tok.textSecondary)),
          const SizedBox(height: TokSpace.lg),
          _buildScanTile(tok),
          const SizedBox(height: TokSpace.md),
          _buildManualInput(tok),
          if (!_loadingPocet && _limit != null) ...[
            const SizedBox(height: TokSpace.md),
            _buildUsageIndicator(tok),
          ],
          if (!_maKlice) ...[
            const SizedBox(height: TokSpace.md),
            _buildKeysBanner(tok),
          ],
        ],
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (_error != null && !_loading) ...[
          _buildErrorCard(tok, _error!),
          const SizedBox(height: TokSpace.lg),
          _buildScanTile(tok),
        ],
        if (_result != null && !_loading)
          _buildVehicleResult(context, tok, _result!, wide: wide),
      ],
    );
  }

  // ── Scan tile ────────────────────────────────────────────────────────────────

  Widget _buildScanTile(TorkisTokens tok) {
    return Container(
      decoration: BoxDecoration(
        color: TokColors.ink,
        borderRadius: BorderRadius.circular(TokRadius.xl),
      ),
      padding: const EdgeInsets.all(TokSpace.lg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(TokRadius.md),
            ),
            child: const Icon(Icons.qr_code_scanner_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: TokSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Skenovat VIN kód',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  'Automaticky načte specifikace vozu z VIN — ze štítku, rámu dveří nebo čelního skla',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.50),
                      fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: TokSpace.md),
          FilledButton(
            onPressed: _scanVin,
            style: FilledButton.styleFrom(
              backgroundColor: TokColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TokRadius.md)),
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            child: const Text('Spustit sken →'),
          ),
        ],
      ),
    );
  }

  Widget _buildManualInput(TorkisTokens tok) {
    return TextField(
      controller: _vinCtrl,
      textCapitalization: TextCapitalization.characters,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: tok.textPrimary,
        letterSpacing: 0.5,
      ),
      cursorColor: TokColors.accent,
      onSubmitted: (_) => _maKlice ? _dekodovat() : null,
      decoration: InputDecoration(
        hintText: 'Zadat VIN ručně (např. TMBJJ7NE5K…)',
        hintStyle: TextStyle(
            fontSize: 13,
            color: tok.textSecondary,
            fontWeight: FontWeight.w400),
        prefixIcon: const Icon(Icons.tag_outlined,
            color: TokColors.accent, size: 18),
        suffixIcon: _maKlice
            ? IconButton(
                icon: const Icon(Icons.search_rounded,
                    color: TokColors.accent, size: 20),
                onPressed: _dekodovat,
                tooltip: 'Dekódovat',
              )
            : null,
        filled: true,
        fillColor: tok.isDark
            ? Colors.white.withValues(alpha: 0.06)
            : TokColors.paper,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TokRadius.lg),
          borderSide: BorderSide(color: tok.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TokRadius.lg),
          borderSide:
              const BorderSide(color: TokColors.accent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildUsageIndicator(TorkisTokens tok) {
    final limit = _limit!;
    final pct = (_pocetTentoMesic / limit).clamp(0.0, 1.0);
    final Color barColor;
    if (pct >= 1.0) {
      barColor = Colors.red;
    } else if (pct >= 0.85) {
      barColor = Colors.orange;
    } else {
      barColor = TokColors.accent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: TokSpace.md, vertical: TokSpace.sm),
      decoration: BoxDecoration(
        color: tok.surface,
        borderRadius: BorderRadius.circular(TokRadius.lg),
        border: Border.all(color: tok.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, size: 14, color: tok.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Dekódování VIN tento měsíc',
                    style: TextStyle(
                        fontSize: 12, color: tok.textSecondary)),
              ),
              Text(
                '$_pocetTentoMesic / $limit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: tok.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          if (_limitDosazen) ...[
            const SizedBox(height: 6),
            Text(
              'Měsíční limit vyčerpán. Upgradujte plán pro další dekódování.',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.red,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKeysBanner(TorkisTokens tok) {
    return Container(
      padding: const EdgeInsets.all(TokSpace.lg),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(TokRadius.lg),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.key_off_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: TokSpace.md),
          Expanded(
            child: Text(
              'Vincario API klíče nejsou nastaveny. Doplňte je v Nastavení servisu, '
              'aby dekódování fungovalo.',
              style: TextStyle(fontSize: 13, color: tok.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(TorkisTokens tok, String msg) {
    return Container(
      padding: const EdgeInsets.all(TokSpace.lg),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(TokRadius.lg),
        border: Border.all(color: Colors.red.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
          const SizedBox(width: TokSpace.md),
          Expanded(
            child: Text('Nepodařilo se dekódovat VIN: $msg',
                style: TextStyle(fontSize: 13, color: tok.textPrimary)),
          ),
        ],
      ),
    );
  }

  // ── Vehicle result ───────────────────────────────────────────────────────────

  Widget _buildVehicleResult(
      BuildContext context, TorkisTokens tok, VincarioResult r,
      {required bool wide}) {
    final znacka = _f(r, ['Make']);
    final model = _f(r, ['Model']);
    final rok = _f(r, ['Model Year']);
    final motor = _f(r, ['Engine']);
    final karoserie = _f(r, ['Body Type']);
    final prevodovka = _f(r, ['Transmission']);
    final mesic1 = _f(r, ['Month of First Registration']);
    final rok1 = _f(r, ['Year of First Registration']);
    final reg1 = (mesic1.isNotEmpty && rok1.isNotEmpty)
        ? '${mesic1.padLeft(2, '0')} / $rok1'
        : rok1;

    final nadpis = [znacka, model].where((s) => s.isNotEmpty).join(' ');
    final podnadpis =
        [karoserie, motor, rok].where((s) => s.isNotEmpty).join(' · ');

    final sekce = _buildSekce(r);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vehicle header card
        Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: tok.surface,
                borderRadius: BorderRadius.circular(TokRadius.xl),
                border: Border.all(color: tok.line),
              ),
              padding: const EdgeInsets.fromLTRB(
                  TokSpace.lg, TokSpace.lg, 52, TokSpace.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo značky, nebo fallback ikona
                      Container(
                        width: 48,
                        height: 48,
                        padding: _logoUrl != null
                            ? const EdgeInsets.all(8)
                            : EdgeInsets.zero,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(TokRadius.md),
                          border: Border.all(color: tok.line),
                        ),
                        child: _logoUrl != null
                            ? Image.network(
                                _logoUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.directions_car_rounded,
                                        color: TokColors.ink, size: 26),
                              )
                            : const Icon(Icons.directions_car_rounded,
                                color: TokColors.ink, size: 26),
                      ),
                      const SizedBox(width: TokSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              nadpis.isNotEmpty
                                  ? nadpis
                                  : (_dekovanyVin ?? ''),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: tok.textPrimary,
                                height: 1.1,
                              ),
                            ),
                            if (podnadpis.isNotEmpty)
                              Text(podnadpis,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: tok.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TokSpace.md),
                  if (_dekovanyVin != null)
                    Text(
                      _dekovanyVin!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: tok.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              top: TokSpace.sm,
              right: TokSpace.sm,
              child: FilledButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 15),
                label: const Text('Nový sken'),
                style: FilledButton.styleFrom(
                  backgroundColor: TokColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TokRadius.md)),
                ),
              ),
            ),
          ],
        ),

        // Stat pills (1. registrace, Motorizace, Převodovka)
        if (reg1.isNotEmpty || motor.isNotEmpty || prevodovka.isNotEmpty) ...[
          const SizedBox(height: TokSpace.md),
          Row(
            children: [
              if (reg1.isNotEmpty)
                Expanded(child: _buildStatPill(tok, '1. registrace', reg1)),
              if (motor.isNotEmpty) ...[
                if (reg1.isNotEmpty) const SizedBox(width: TokSpace.sm),
                Expanded(child: _buildStatPill(tok, 'Motorizace', motor)),
              ],
              if (prevodovka.isNotEmpty) ...[
                if (reg1.isNotEmpty || motor.isNotEmpty)
                  const SizedBox(width: TokSpace.sm),
                Expanded(child: _buildStatPill(tok, 'Převodovka', prevodovka)),
              ],
            ],
          ),
        ],

        // Sections
        const SizedBox(height: TokSpace.md),
        if (wide)
          _buildSekceGridWide(tok, sekce)
        else
          _buildSekceGridNarrow(tok, sekce),

        const SizedBox(height: TokSpace.xl),
      ],
    );
  }

  Widget _buildStatPill(TorkisTokens tok, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: TokSpace.md, vertical: TokSpace.sm),
      decoration: BoxDecoration(
        color: tok.surface,
        borderRadius: BorderRadius.circular(TokRadius.lg),
        border: Border.all(color: tok.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: tok.textSecondary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: tok.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildSekceGridWide(TorkisTokens tok, List<_Sekce> sekce) {
    if (sekce.isEmpty) return const SizedBox.shrink();
    final rows = <Widget>[];
    for (int i = 0; i < sekce.length; i += 2) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: TokSpace.md));
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildSekceKarta(tok, sekce[i])),
          if (i + 1 < sekce.length) ...[
            const SizedBox(width: TokSpace.md),
            Expanded(child: _buildSekceKarta(tok, sekce[i + 1])),
          ] else
            const Expanded(child: SizedBox.shrink()),
        ],
      ));
    }
    return Column(children: rows);
  }

  Widget _buildSekceGridNarrow(TorkisTokens tok, List<_Sekce> sekce) {
    return Column(
      children: sekce
          .map((s) => Padding(
                padding: const EdgeInsets.only(bottom: TokSpace.md),
                child: _buildSekceKarta(tok, s),
              ))
          .toList(),
    );
  }

  Widget _buildSekceKarta(TorkisTokens tok, _Sekce sekce) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tok.surface,
        borderRadius: BorderRadius.circular(TokRadius.xl),
        border: Border.all(color: tok.line),
      ),
      padding: const EdgeInsets.all(TokSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(sekce.icon, size: 13, color: tok.textSecondary),
              const SizedBox(width: 6),
              Text(sekce.nazev,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: tok.textSecondary,
                    letterSpacing: 0.8,
                  )),
            ],
          ),
          const SizedBox(height: TokSpace.sm),
          ...sekce.pole.map((p) => _buildRadek(tok, p.$1, p.$2)),
        ],
      ),
    );
  }

  Widget _buildRadek(TorkisTokens tok, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: tok.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: tok.textPrimary)),
          ),
        ],
      ),
    );
  }

  // ── History sidebar ──────────────────────────────────────────────────────────

  Widget _buildHistorieSidebar(BuildContext context) {
    final tok = context.tok;
    if (_historieStream == null) return const SizedBox.shrink();

    final isFiltered = _dekovanyVin != null;

    return StreamBuilder<QuerySnapshot>(
      stream: _historieStream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(TokSpace.xl),
              child: Text('Nepodařilo se načíst historii.',
                  style:
                      TextStyle(fontSize: 12, color: tok.textSecondary),
                  textAlign: TextAlign.center),
            ),
          );
        }

        // Client-side třídění podle cas desc (bez composite indexu)
        final vsechny = (snap.data?.docs ?? []).toList()
          ..sort((a, b) {
            final ta =
                ((a.data() as Map)['cas'] as Timestamp?)
                    ?.millisecondsSinceEpoch ??
                    0;
            final tb =
                ((b.data() as Map)['cas'] as Timestamp?)
                    ?.millisecondsSinceEpoch ??
                    0;
            return tb.compareTo(ta);
          });

        // Po dekódování zobrazíme jen záznamy pro aktuální VIN
        final zobrazit = isFiltered
            ? vsechny
                .where((d) =>
                    (d.data() as Map)['vin']?.toString() ==
                    _dekovanyVin)
                .toList()
            : vsechny;

        final now = DateTime.now();
        final dnes = vsechny.where((d) {
          final ts = (d.data() as Map)['cas'];
          if (ts is Timestamp) {
            final dt = ts.toDate();
            return dt.year == now.year &&
                dt.month == now.month &&
                dt.day == now.day;
          }
          return false;
        }).length;

        // Titulek a podtitulek sidebaru
        final String headerTitle;
        final String headerSub;
        if (isFiltered) {
          final vin = _dekovanyVin!;
          headerTitle = vin.length > 13
              ? '${vin.substring(0, 7)}…${vin.substring(vin.length - 4)}'
              : vin;
          headerSub = zobrazit.isEmpty
              ? 'Nové vozidlo'
              : zobrazit.length == 1
                  ? 'Poprvé dekódováno'
                  : 'Dekódováno ${zobrazit.length}×';
        } else {
          headerTitle = 'Historie skenů';
          headerSub = dnes > 0
              ? 'Dnes · $dnes dekódovaných VIN'
              : 'Poslední skeny';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  TokSpace.lg, TokSpace.lg, TokSpace.lg, TokSpace.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isFiltered
                            ? Icons.manage_search_rounded
                            : Icons.history_rounded,
                        size: 16,
                        color: TokColors.accent,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(headerTitle,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: tok.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (isFiltered)
                        GestureDetector(
                          onTap: () =>
                              setState(() => _dekovanyVin = null),
                          child: const Text('Vše',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: TokColors.accent,
                                  fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(headerSub,
                      style: TextStyle(
                          fontSize: 11, color: tok.textSecondary)),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: tok.line),
            Expanded(
              child: zobrazit.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(TokSpace.xl),
                        child: Text(
                          snap.connectionState ==
                                  ConnectionState.waiting
                              ? 'Načítání…'
                              : isFiltered
                                  ? 'Toto vozidlo nebylo dříve dekódováno.'
                                  : 'Zatím žádné skeny.',
                          style: TextStyle(
                              fontSize: 13, color: tok.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          vertical: TokSpace.xs),
                      itemCount: zobrazit.length,
                      itemBuilder: (context, i) {
                        final data = zobrazit[i].data()
                            as Map<String, dynamic>;
                        final vin = data['vin']?.toString() ?? '';
                        final znacka =
                            data['znacka']?.toString() ?? '';
                        final model =
                            data['model']?.toString() ?? '';
                        final rok = data['rok']?.toString() ?? '';
                        final motorizace =
                            data['motorizace']?.toString() ?? '';
                        final nazev = [znacka, model]
                            .where((s) => s.isNotEmpty)
                            .join(' ');
                        final detail = [motorizace, rok]
                            .where((s) => s.isNotEmpty)
                            .join(' · ');
                        final ts = data['cas'] as Timestamp?;
                        final cas = ts?.toDate();
                        final vinTrunc = vin.length > 11
                            ? '${vin.substring(0, 7)}…${vin.substring(vin.length - 4)}'
                            : vin;
                        // V histori zobrazujeme poslední záznam jako aktivní
                        final isActive = isFiltered && i == 0;

                        return _buildHistoriePolozka(
                          tok,
                          nazev: nazev,
                          detail: detail,
                          vinTrunc: vinTrunc,
                          cas: cas,
                          isActive: isActive,
                          onTap: isFiltered
                              ? null
                              : () {
                                  setState(
                                      () => _vinCtrl.text = vin);
                                  _dekodovat();
                                },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoriePolozka(
    TorkisTokens tok, {
    required String nazev,
    required String detail,
    required String vinTrunc,
    required DateTime? cas,
    required bool isActive,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: isActive ? TokColors.accentSoft : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: TokSpace.lg, vertical: TokSpace.sm),
          decoration: isActive
              ? const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: TokColors.accent, width: 3),
                  ),
                )
              : null,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive
                      ? TokColors.accent.withValues(alpha: 0.15)
                      : (tok.isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFEFF1F4)),
                  borderRadius: BorderRadius.circular(TokRadius.sm),
                ),
                child: Icon(Icons.directions_car_rounded,
                    size: 16,
                    color: isActive ? TokColors.accent : tok.textSecondary),
              ),
              const SizedBox(width: TokSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nazev.isNotEmpty ? nazev : 'Neznámé vozidlo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? TokColors.accent : tok.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (detail.isNotEmpty)
                      Text(detail,
                          style:
                              TextStyle(fontSize: 11, color: tok.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    Text(vinTrunc,
                        style: TextStyle(
                            fontSize: 10,
                            color: tok.textSecondary.withValues(alpha: 0.6),
                            letterSpacing: 0.3)),
                  ],
                ),
              ),
              if (cas != null)
                Text(_formatCas(cas),
                    style: TextStyle(fontSize: 10, color: tok.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
