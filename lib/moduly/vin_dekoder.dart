import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/design_tokens.dart';
import '../core/constants.dart';
import '../core/vincario_service.dart';
import '../l10n/app_localizations.dart';
import 'auth_gate.dart';
import 'predplatne_page.dart';
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

  bool _loading = false;
  String? _error;
  VincarioResult? _result;
  String? _dekovanyVin;
  String? _logoUrl;

  VincarioMarketValue? _trzniHodnota;
  bool _loadingTrzni = false;
  String? _trzniError;

  StkResult? _stkResult;
  bool _loadingStk = false;
  String? _stkError;

  String _mena = 'EUR';
  double? _kurz;
  bool _nacitaKurz = false;

  // Mód: 0 = VIN dekódování, 1 = tržní hodnota, 2 = zjištění STK
  int _rezimValue = 0;

  // Streamy uložené jako pole — nevytváří se znovu při každém setState
  Stream<QuerySnapshot>? _historieStream;
  Stream<QuerySnapshot>? _valueStream;

  // Počítadlo VIN dekódování (z_cache==false) v aktuálním měsíci
  int _pocetTentoMesic = 0;
  bool _loadingPocet = true;

  int? get _limit => kPlanVinLimit[globalPlanTyp];
  bool get _limitDosazen =>
      _limit != null && _pocetTentoMesic >= _limit!;

  // Počítadlo market value lookupů (z_cache==false) v aktuálním měsíci
  int _pocetValueTentoMesic = 0;
  bool _loadingPocetValue = true;

  int? get _valueLimit => kPlanValueLimit[globalPlanTyp];
  bool get _valueLimitDosazen =>
      _valueLimit != null && _pocetValueTentoMesic >= _valueLimit!;

  // Tržní hodnota není součástí plánu (typicky Trial má limit 0).
  bool get _valueNeniVPlanu => _valueLimit == 0;

  // Sdílený klíč žije na serveru (Cloud Functions), modul je vždy dostupný.
  bool get _maKlice => true;

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
      final now = DateTime.now();
      final zacatekMesice = DateTime(now.year, now.month, 1);
      // Jen jeden where filtr → nevyžaduje composite index.
      // Měsíc a z_cache filtrujeme client-side.
      final snap = await FirebaseFirestore.instance
          .collection('vin_skeny')
          .where('servis_id', isEqualTo: _sId)
          .get();
      final pocet = snap.docs.where((d) {
        final data = d.data();
        if (data['z_cache'] == true) return false;
        final ts = data['cas'] as Timestamp?;
        if (ts == null) return false;
        return ts.toDate().isAfter(
            zacatekMesice.subtract(const Duration(seconds: 1)));
      }).length;
      if (mounted) {
        setState(() {
          _pocetTentoMesic = pocet;
          _loadingPocet = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPocet = false);
    }
  }

  void _initHistorieStream() {
    if (_sId == null) return;
    _historieStream ??= FirebaseFirestore.instance
        .collection('vin_skeny')
        .where('servis_id', isEqualTo: _sId)
        .limit(50)
        .snapshots();
    _valueStream ??= FirebaseFirestore.instance
        .collection('value_skeny')
        .where('servis_id', isEqualTo: _sId)
        .limit(50)
        .snapshots();
  }

  @override
  void dispose() {
    _vinCtrl.dispose();
    super.dispose();
  }

  /// Inicializace modulu — historie a měsíční počítadla. Vincario klíče už se
  /// nenačítají (žijí na serveru), volání jde přes Cloud Functions.
  Future<void> _nactiKlice() async {
    if (mounted) {
      _initHistorieStream();
      _nactiPocetTentoMesic();
      _nactiPocetValueTentoMesic();
      setState(() => _loadingKeys = false);
    }
  }


  Future<void> _dekodovat() async {
    final l10n = AppLocalizations.of(context);
    final vin =
        _vinCtrl.text.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
    if (vin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.vinZadejteVin), backgroundColor: Colors.orange));
      return;
    }
    if (!_maKlice) return;
    if (_limitDosazen) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.vinLimitDekodovani(_pocetTentoMesic, _limit!)),
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
      // Cache i počítadlo řeší Cloud Function; vrací zda šlo o cache zásah.
      final res = await VincarioService.decode(vin: vin);
      if (mounted) {
        setState(() {
          _result = res.result;
          if (!res.fromCache) _pocetTentoMesic++;
        });
        _ulozitDoHistorie(vin, res.result, zCache: res.fromCache);
        _nactiLogo(_f(res.result, ['Make']));
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

  String _formatCas(DateTime dt, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return l10n.vinPraveTed;
    if (diff.inMinutes < 60) return l10n.vinPredMinutami(diff.inMinutes);
    if (dt.day == now.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}.${dt.month}.';
  }

  List<_Sekce> _buildSekce(VincarioResult r, AppLocalizations l10n) {
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
      (l10n.vinFieldZnacka, _f(r, ['Make'])),
      (l10n.vinFieldModel, _f(r, ['Model'])),
      (l10n.vinFieldObchodniOznaceni, _f(r, ['Commercial Name'])),
      (l10n.vinFieldRokVyroby, _f(r, ['Model Year'])),
      (l10n.vinFieldKaroserie, _f(r, ['Body Type'])),
      (l10n.vinFieldKaroserie, _f(r, ['Body'])),
      (l10n.vinFieldTypVarianta, _f(r, ['Trim', 'Series'])),
      (l10n.vinFieldMistoVyroby, mfAddr),
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
      (l10n.vinFieldMotorizace, _f(r, ['Engine'])),
      (l10n.vinFieldTypMotoru, _f(r, ['Engine Type'])),
      (l10n.vinFieldKodMotoru, engineCode),
      (l10n.vinFieldZdvihObjem, objemStr),
      (l10n.vinFieldPocetValcu, cylinders),
      (l10n.vinFieldVykon, vykon),
      (l10n.vinFieldTocivyMoment, torque.isNotEmpty ? '$torque Nm' : ''),
      (l10n.vinFieldPalivo, _f(r, ['Fuel Type'])),
      (l10n.vinFieldPrevodovka, _f(r, ['Transmission'])),
      (l10n.vinFieldPocetPrevodu, _f(r, ['Number of Gears', 'Gears'])),
      (l10n.vinFieldPohon, _f(r, ['Drive'])),
      (l10n.vinFieldMaxRychlost, speed.isNotEmpty ? '$speed km/h' : ''),
    ]);

    final karoserie = filtr([
      (l10n.vinFieldTypKaroserie, _f(r, ['Body Type'])),
      (l10n.vinFieldPocetDveri, _f(r, ['Number of Doors'])),
      (l10n.vinFieldPocetMist, _f(r, ['Number of Seats'])),
      (l10n.vinFieldProvozniHmotnost, curb.isNotEmpty ? '$curb kg' : ''),
      (l10n.vinFieldMaxHmotnost, gvw.isNotEmpty ? '${_formatCislo(gvw)} kg' : ''),
      (l10n.vinFieldTaznaHmotnost, tazna.isNotEmpty ? '$tazna kg' : ''),
      (l10n.vinFieldRozvorNaprav, rozvor.isNotEmpty ? '$rozvor mm' : ''),
      (l10n.vinFieldDelka, delka.isNotEmpty ? '$delka mm' : ''),
      (l10n.vinFieldSirka, sirka.isNotEmpty ? '$sirka mm' : ''),
      (l10n.vinFieldVyska, vyska.isNotEmpty ? '$vyska mm' : ''),
      (l10n.vinFieldObjemNadrze, nadrz.isNotEmpty ? '$nadrz L' : ''),
    ]);

    final registrace = filtr([
      (l10n.vinField1Registrace, reg1),
      (l10n.vinFieldEmisniNorma, _f(r, ['Emission Standard'])),
      (l10n.vinFieldEmiseCo2, co2.isNotEmpty ? '$co2 g/km' : ''),
      (l10n.vinFieldSpotrebaKomb, spotr.isNotEmpty ? '$spotr l/100 km' : ''),
      (l10n.vinFieldSpotrebaMesto,
          spotrMesto.isNotEmpty ? '$spotrMesto l/100 km' : ''),
      (l10n.vinFieldSpotrebaDalnice,
          spotrDalnice.isNotEmpty ? '$spotrDalnice l/100 km' : ''),
      (l10n.vinFieldElektDojezd,
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

    // Zbývající pole — labely přeloženy přes _kPreloz.
    final ostatni = r.vsechnyUdaje
        .where((p) => !mapovane.contains(p.label))
        .map((p) => (_kPreloz[p.label] ?? p.label, p.value))
        .toList();

    return [
      if (identifikace.isNotEmpty)
        _Sekce(l10n.vinSekceIdentifikace, Icons.label_outline_rounded, identifikace),
      if (motor.isNotEmpty)
        _Sekce(l10n.vinSekceMotor, Icons.settings_outlined, motor),
      if (karoserie.isNotEmpty)
        _Sekce(l10n.vinSekceKaroserie, Icons.directions_car_outlined, karoserie),
      if (registrace.isNotEmpty)
        _Sekce(l10n.vinSekcePalivo, Icons.cloud_outlined, registrace),
      if (ostatni.isNotEmpty)
        _Sekce(l10n.vinSekceOstatni, Icons.data_object_rounded, ostatni),
    ];
  }

  Future<void> _nactiPocetValueTentoMesic() async {
    if (_sId == null) {
      if (mounted) setState(() => _loadingPocetValue = false);
      return;
    }
    try {
      final now = DateTime.now();
      final zacatek = DateTime(now.year, now.month, 1);
      final snap = await FirebaseFirestore.instance
          .collection('value_skeny')
          .where('servis_id', isEqualTo: _sId)
          .get();
      final pocet = snap.docs.where((d) {
        final data = d.data();
        if (data['z_cache'] == true) return false;
        final ts = data['cas'] as Timestamp?;
        if (ts == null) return false;
        return ts.toDate().isAfter(
            zacatek.subtract(const Duration(seconds: 1)));
      }).length;
      if (mounted) {
        setState(() {
          _pocetValueTentoMesic = pocet;
          _loadingPocetValue = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingPocetValue = false);
    }
  }

  Future<void> _ulozitValueDoHistorie(String vin, VincarioMarketValue r,
      {bool zCache = false}) async {
    if (_sId == null) return;
    try {
      final eu = r.europePrice;
      await FirebaseFirestore.instance.collection('value_skeny').add({
        'servis_id': _sId,
        'vin': vin,
        'znacka': r.make,
        'model': r.model,
        'rok': r.modelYear?.toString() ?? '',
        'median_eur': eu?['price_median'],
        'z_cache': zCache,
        'cas': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }


  Future<void> _nacistTrzniHodnotu() async {
    final l10n = AppLocalizations.of(context);
    final vin = _vinCtrl.text.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
    if (vin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.vinZadejteVin), backgroundColor: Colors.orange));
      return;
    }
    if (!_maKlice) return;
    if (_valueNeniVPlanu) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.vinTrzniChybaVerze),
        backgroundColor: TokColors.accent,
        duration: const Duration(seconds: 4),
      ));
      return;
    }
    if (_valueLimitDosazen) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.vinLimitValue(_pocetValueTentoMesic, _valueLimit!)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ));
      return;
    }
    setState(() {
      _loadingTrzni = true;
      _trzniError = null;
      _trzniHodnota = null;
      _dekovanyVin = vin;
      _logoUrl = null;
    });
    try {
      // Cache i počítadlo řeší Cloud Function; vrací zda šlo o cache zásah.
      final res = await VincarioService.marketValue(vin: vin);
      if (mounted) {
        setState(() {
          _trzniHodnota = res.result;
          if (!res.fromCache) _pocetValueTentoMesic++;
        });
        _ulozitValueDoHistorie(vin, res.result, zCache: res.fromCache);
        _nactiLogo(res.result.make);
      }
    } catch (e) {
      if (mounted) setState(() => _trzniError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingTrzni = false);
    }
  }

  Future<void> _nacistKurz() async {
    if (_kurz != null || _nacitaKurz) return;
    setState(() => _nacitaKurz = true);
    try {
      final rate = await VincarioService.kurzEurCzk();
      if (mounted) setState(() => _kurz = rate);
    } catch (_) {
      if (mounted) setState(() => _mena = 'EUR');
    } finally {
      if (mounted) setState(() => _nacitaKurz = false);
    }
  }

  void _reset() => setState(() {
        _result = null;
        _error = null;
        _dekovanyVin = null;
        _logoUrl = null;
        _trzniHodnota = null;
        _trzniError = null;
        _loadingTrzni = false;
        _stkResult = null;
        _stkError = null;
        _loadingStk = false;
        _vinCtrl.clear();
      });

  Future<void> _nacistStk() async {
    final l10n = AppLocalizations.of(context);
    final vin =
        _vinCtrl.text.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
    if (vin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.vinZadejteVin), backgroundColor: Colors.orange));
      return;
    }
    setState(() {
      _loadingStk = true;
      _stkError = null;
      _stkResult = null;
      _dekovanyVin = vin;
    });
    try {
      final res = await VincarioService.stk(vin: vin);
      if (mounted) {
        setState(() => _stkResult = res.result);
      }
    } catch (e) {
      if (mounted) setState(() => _stkError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingStk = false);
    }
  }

  Future<void> _scanVinAkce() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).vinSkenJenApk),
          backgroundColor: Colors.orange));
      return;
    }
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const OcrCameraPage(label: 'VIN')),
    );
    if (result != null && result.isNotEmpty && mounted) {
      setState(() => _vinCtrl.text = result.toUpperCase());
      if (_rezimValue == 1) {
        _nacistTrzniHodnotu();
      } else if (_rezimValue == 2) {
        _nacistStk();
      } else {
        _dekodovat();
      }
    }
  }

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
    final l10n = AppLocalizations.of(context);
    final jeVysledek = _rezimValue == 1
        ? (_trzniHodnota != null && !_loadingTrzni)
        : _rezimValue == 2
            ? (_stkResult != null && !_loadingStk)
            : (_result != null && !_loading);
    final jeNacitani = _rezimValue == 1
        ? _loadingTrzni
        : _rezimValue == 2
            ? _loadingStk
            : _loading;
    final jeChyba = _rezimValue == 1
        ? (_trzniError != null && !_loadingTrzni)
        : _rezimValue == 2
            ? (_stkError != null && !_loadingStk)
            : (_error != null && !_loading);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!jeVysledek && !jeNacitani) ...[
          // Přepínač módu
          SegmentedButton<int>(
            segments: [
              ButtonSegment(
                value: 0,
                icon: const Icon(Icons.manage_search_rounded, size: 16),
                label: Text(l10n.vinDekoderTabDekodovani),
              ),
              ButtonSegment(
                value: 1,
                icon: const Icon(Icons.bar_chart_rounded, size: 16),
                label: Text(l10n.vinDekoderTabTrzniHodnota),
              ),
              ButtonSegment(
                value: 2,
                icon: const Icon(Icons.fact_check_outlined, size: 16),
                label: Text(l10n.vinDekoderTabStk),
              ),
            ],
            selected: {_rezimValue},
            onSelectionChanged: (v) => setState(() {
              _rezimValue = v.first;
              _result = null;
              _error = null;
              _trzniHodnota = null;
              _trzniError = null;
              _stkResult = null;
              _stkError = null;
              _dekovanyVin = null;
              _logoUrl = null;
            }),
          ),
          const SizedBox(height: TokSpace.lg),
          Text(
            _rezimValue == 1
                ? l10n.vinTrzniHodnotaTitle
                : _rezimValue == 2
                    ? l10n.vinStkTitle
                    : l10n.vinDekoderTitle,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: tok.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _rezimValue == 1
                ? l10n.vinTrzniSubtitle
                : _rezimValue == 2
                    ? l10n.vinStkSubtitle
                    : l10n.vinDekoderSubtitle,
            style: TextStyle(fontSize: 13, color: tok.textSecondary),
          ),
          const SizedBox(height: TokSpace.lg),
          _buildScanTile(tok, l10n),
          const SizedBox(height: TokSpace.md),
          _buildManualInput(tok, l10n),
          if (_rezimValue == 1 && _valueNeniVPlanu) ...[
            const SizedBox(height: TokSpace.md),
            _buildValueUpsell(tok, l10n),
          ] else if (_rezimValue == 1
              ? (!_loadingPocetValue && _valueLimit != null)
              : (_rezimValue == 0 && !_loadingPocet && _limit != null)) ...[
            const SizedBox(height: TokSpace.md),
            _buildUsageIndicator(tok, l10n),
          ],
          if (_rezimValue == 2) ...[
            const SizedBox(height: TokSpace.md),
            _buildStkInfoBanner(tok, l10n),
          ],
          if (!_maKlice) ...[
            const SizedBox(height: TokSpace.md),
            _buildKeysBanner(tok, l10n),
          ],
          if (jeChyba) ...[
            const SizedBox(height: TokSpace.md),
            _buildErrorCard(tok, l10n, _rezimValue == 1
                ? _trzniError!
                : _rezimValue == 2
                    ? _stkError!
                    : _error!),
          ],
        ],
        if (jeNacitani)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (jeVysledek)
          _rezimValue == 1
              ? _buildValueResult(context, tok, _trzniHodnota!)
              : _rezimValue == 2
                  ? _buildStkResult(context, tok, _stkResult!)
                  : _buildVehicleResult(context, tok, _result!, wide: wide),
      ],
    );
  }

  // ── Scan tile ────────────────────────────────────────────────────────────────

  Widget _buildScanTile(TorkisTokens tok, AppLocalizations l10n) {
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
                Text(
                  _rezimValue == 1
                      ? l10n.vinSkenTitleTrzni
                      : _rezimValue == 2
                          ? l10n.vinSkenTitleStk
                          : l10n.vinSkenTitleVin,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  _rezimValue == 1
                      ? l10n.vinSkenPopisTrzni
                      : _rezimValue == 2
                          ? l10n.vinSkenPopisStk
                          : l10n.vinSkenPopisVin,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.50),
                      fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: TokSpace.md),
          FilledButton(
            onPressed: _scanVinAkce,
            style: FilledButton.styleFrom(
              backgroundColor: TokColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TokRadius.md)),
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            child: Text(l10n.vinSkenTlacitko),
          ),
        ],
      ),
    );
  }

  Widget _buildManualInput(TorkisTokens tok, AppLocalizations l10n) {
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
      onSubmitted: (_) {
        if (!_maKlice) return;
        if (_rezimValue == 1) {
          _nacistTrzniHodnotu();
        } else if (_rezimValue == 2) {
          _nacistStk();
        } else {
          _dekodovat();
        }
      },
      decoration: InputDecoration(
        hintText: l10n.vinInputHint,
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
                onPressed: _rezimValue == 1
                    ? _nacistTrzniHodnotu
                    : _rezimValue == 2
                        ? _nacistStk
                        : _dekodovat,
                tooltip: _rezimValue == 1
                    ? l10n.vinTooltipHodnota
                    : _rezimValue == 2
                        ? l10n.vinTooltipStk
                        : l10n.vinTooltipDekodovat,
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

  // Upsell pro Trial — tržní hodnota není ve zkušební verzi, vede na plány.
  Widget _buildValueUpsell(TorkisTokens tok, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(TokSpace.md),
      decoration: BoxDecoration(
        color: TokColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(TokRadius.lg),
        border: Border.all(color: TokColors.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_outlined,
              color: TokColors.accent, size: 22),
          const SizedBox(width: TokSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.vinUpsellTitle,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: tok.textPrimary)),
                const SizedBox(height: 2),
                Text(l10n.vinUpsellSubtitle,
                    style:
                        TextStyle(fontSize: 11, color: tok.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: TokSpace.sm),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PredplatnePage()),
            ),
            style: TextButton.styleFrom(foregroundColor: TokColors.accent),
            child: Text(l10n.vinUpsellPlany),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageIndicator(TorkisTokens tok, AppLocalizations l10n) {
    final limit = _rezimValue == 1 ? _valueLimit! : _limit!;
    final pocet = _rezimValue == 1 ? _pocetValueTentoMesic : _pocetTentoMesic;
    final pct = (pocet / limit).clamp(0.0, 1.0);
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
                child: Text(
                    _rezimValue == 1
                        ? l10n.vinLimitTrzniMesic
                        : l10n.vinLimitDekodovaniMesic,
                    style: TextStyle(
                        fontSize: 12, color: tok.textSecondary)),
              ),
              Text(
                '$pocet / $limit',
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
          if (_rezimValue == 1 ? _valueLimitDosazen : _limitDosazen) ...[
            const SizedBox(height: 6),
            Text(
              l10n.vinLimitVycerpan,
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.red,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKeysBanner(TorkisTokens tok, AppLocalizations l10n) {
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
              l10n.vinVincarioKlice,
              style: TextStyle(fontSize: 13, color: tok.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStkInfoBanner(TorkisTokens tok, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(TokSpace.md),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(TokRadius.lg),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 16, color: Colors.orange),
          const SizedBox(width: TokSpace.sm),
          Expanded(
            child: Text(
              l10n.vinStkInfoBanner,
              style: TextStyle(fontSize: 12, color: tok.textPrimary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(TorkisTokens tok, AppLocalizations l10n, String msg) {
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
            child: Text(l10n.vinChybaDekodovani(msg),
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
    final l10n = AppLocalizations.of(context);
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

    final sekce = _buildSekce(r, l10n);

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
                label: Text(l10n.vinNovySken),
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
                Expanded(child: _buildStatPill(tok, l10n.vinField1Registrace, reg1)),
              if (motor.isNotEmpty) ...[
                if (reg1.isNotEmpty) const SizedBox(width: TokSpace.sm),
                Expanded(child: _buildStatPill(tok, l10n.vinFieldMotorizace, motor)),
              ],
              if (prevodovka.isNotEmpty) ...[
                if (reg1.isNotEmpty || motor.isNotEmpty)
                  const SizedBox(width: TokSpace.sm),
                Expanded(child: _buildStatPill(tok, l10n.vinFieldPrevodovka, prevodovka)),
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

  Widget _buildValueResult(
      BuildContext context, TorkisTokens tok, VincarioMarketValue data) {
    final l10n = AppLocalizations.of(context);
    final nadpis = [data.make, data.model]
        .where((s) => s.isNotEmpty)
        .join(' ');
    final podnadpis = data.modelYear != null ? '${data.modelYear}' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header karta
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                        ? Image.network(_logoUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.directions_car_rounded,
                                color: TokColors.ink,
                                size: 26))
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
                          nadpis.isNotEmpty ? nadpis : (_dekovanyVin ?? ''),
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
                              style: TextStyle(
                                  fontSize: 13, color: tok.textSecondary)),
                      ],
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
                label: Text(l10n.vinNovySken),
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
        const SizedBox(height: TokSpace.md),
        // Tržní data
        Container(
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
                  const Icon(Icons.bar_chart_rounded,
                      size: 13, color: TokColors.accent),
                  const SizedBox(width: 6),
                  Text(l10n.vinTrzniHodnotaHeader,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: tok.textSecondary,
                        letterSpacing: 0.8,
                      )),
                  const Spacer(),
                  _buildMenaToggle(tok),
                ],
              ),
              const SizedBox(height: TokSpace.md),
              _buildTrzniData(tok, data, l10n),
            ],
          ),
        ),
        const SizedBox(height: TokSpace.xl),
      ],
    );
  }

  // ── STK result ───────────────────────────────────────────────────────────────

  Widget _buildStkResult(
      BuildContext context, TorkisTokens tok, StkResult data) {
    final l10n = AppLocalizations.of(context);
    DateTime? parseDatum(String s) {
      if (s.isEmpty) return null;
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    String fmtDatum(String s) {
      final dt = parseDatum(s);
      if (dt == null) return s;
      return '${dt.day}.${dt.month}.${dt.year}';
    }

    final stkPlatnost = parseDatum(data.stkPlatnostDo);
    final now = DateTime.now();
    final stkPlatna = stkPlatnost != null && stkPlatnost.isAfter(now);
    final stkDni = stkPlatnost?.difference(now).inDays;
    final statusColor = stkPlatna ? Colors.green : Colors.red;

    final nadpis = [data.znacka, data.obchodniOznaceni]
        .where((s) => s.isNotEmpty)
        .join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header karta
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
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(TokRadius.md),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Icon(
                          stkPlatna
                              ? Icons.verified_rounded
                              : Icons.warning_rounded,
                          color: statusColor,
                          size: 26,
                        ),
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
                            Text(
                              data.stkPlatnostDo.isEmpty
                                  ? l10n.vinStkPlatnostNeznama
                                  : stkPlatna
                                      ? l10n.vinStkPlatnaJesteXDni(stkDni!)
                                      : l10n.vinStkNeplatna(-(stkDni!)),
                              style: TextStyle(
                                  fontSize: 13,
                                  color: data.stkPlatnostDo.isEmpty
                                      ? tok.textSecondary
                                      : statusColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_dekovanyVin != null) ...[
                    const SizedBox(height: TokSpace.md),
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
                ],
              ),
            ),
            Positioned(
              top: TokSpace.sm,
              right: TokSpace.sm,
              child: FilledButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 15),
                label: Text(l10n.vinNovySken),
                style: FilledButton.styleFrom(
                  backgroundColor: TokColors.accent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TokRadius.md)),
                ),
              ),
            ),
          ],
        ),

        if (data.stkPlatnostDo.isNotEmpty) ...[
          const SizedBox(height: TokSpace.md),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: tok.surface,
              borderRadius: BorderRadius.circular(TokRadius.xl),
              border: Border.all(color: tok.line),
            ),
            padding: const EdgeInsets.all(TokSpace.lg),
            child: _buildStkRadekSBarvou(
              tok,
              l10n.vinStkPlatnostDo,
              fmtDatum(data.stkPlatnostDo),
              stkPlatna ? Colors.green : Colors.red,
            ),
          ),
        ],

        const SizedBox(height: TokSpace.xl),
      ],
    );
  }

  Widget _buildStkRadekSBarvou(
      TorkisTokens tok, String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: tok.textSecondary)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildMenaToggle(TorkisTokens tok) {
    if (_nacitaKurz) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      );
    }
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'EUR', label: Text('EUR')),
        ButtonSegment(value: 'CZK', label: Text('Kč')),
      ],
      selected: {_mena},
      onSelectionChanged: (v) {
        final nova = v.first;
        if (nova == 'CZK') _nacistKurz();
        setState(() => _mena = nova);
      },
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        textStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),
      ),
    );
  }

  Widget _buildTrzniData(TorkisTokens tok, VincarioMarketValue data, AppLocalizations l10n) {
    if (_mena == 'CZK' && _kurz == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: TokSpace.md),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final eu = data.europePrice;
    final odo = data.europeOdometer;
    if (eu == null) {
      return Text(l10n.vinTrzniDataNedostupna,
          style: TextStyle(fontSize: 13, color: tok.textSecondary));
    }

    final faktor = _mena == 'CZK' ? _kurz! : 1.0;
    num? conv(num? v) => v == null ? null : v * faktor;

    final median = conv(eu['price_median'] as num?);
    final below = conv(eu['price_below'] as num?);
    final above = conv(eu['price_above'] as num?);
    final avg = conv(eu['price_avg'] as num?);
    final currency = _mena == 'CZK' ? 'Kč' : (eu['price_currency']?.toString() ?? 'EUR');
    final count = eu['price_count'] as num?;

    final odomAvg = odo?['odometer_avg'] as num?;
    final odomUnit = odo?['odometer_unit']?.toString() ?? 'km';

    String fmt(num? v) {
      if (v == null) return '—';
      final s = v.round().toString();
      final buf = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
        buf.write(s[i]);
      }
      return buf.toString();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hlavní cena — medián
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${fmt(median)} $currency',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: tok.textPrimary,
                height: 1.0,
              ),
            ),
            const SizedBox(width: TokSpace.sm),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(l10n.vinTrzniMedian,
                  style: TextStyle(
                      fontSize: 12, color: tok.textSecondary)),
            ),
          ],
        ),
        const SizedBox(height: TokSpace.md),

        // Cenový rozsah — vizuální bar
        if (below != null && median != null && above != null) ...[
          _buildCenovyBar(tok, below, median, above, currency, l10n),
          const SizedBox(height: TokSpace.md),
        ],

        // Detailní hodnoty
        Divider(height: 1, color: tok.line),
        const SizedBox(height: TokSpace.sm),
        _buildTrzniRadek(tok, l10n.vinTrzniPrumernaCena,
            avg != null ? '${fmt(avg)} $currency' : '—'),
        if (odomAvg != null)
          _buildTrzniRadek(tok, l10n.vinTrzniPrumernyNajezd,
              '${fmt(odomAvg)} $odomUnit'),
        if (count != null)
          _buildTrzniRadek(tok, l10n.vinTrzniPocetVzorku, '$count'),
        if (data.periodFrom.isNotEmpty && data.periodTo.isNotEmpty)
          _buildTrzniRadek(
              tok, l10n.vinTrzniObdobiDat, '${data.periodFrom} – ${data.periodTo}'),

        // Zdroj dat
        const SizedBox(height: TokSpace.sm),
        Text(l10n.vinTrzniZdroj,
            style: TextStyle(fontSize: 10, color: tok.textSecondary)),
      ],
    );
  }

  Widget _buildCenovyBar(TorkisTokens tok, num below, num median, num above,
      String currency, AppLocalizations l10n) {
    final total = above - below;
    if (total <= 0) return const SizedBox.shrink();
    final leftRatio = ((median - below) / total).clamp(0.0, 1.0);
    final rightRatio = 1.0 - leftRatio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: [
              Flexible(
                flex: (leftRatio * 100).round(),
                child: Container(height: 8,
                    color: TokColors.accent.withValues(alpha: 0.35)),
              ),
              Container(width: 3, height: 12,
                  color: TokColors.accent),
              Flexible(
                flex: (rightRatio * 100).round().clamp(1, 100),
                child: Container(height: 8,
                    color: TokColors.accent.withValues(alpha: 0.15)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.vinTrzniOd(_fmtCena(below), currency),
                style: TextStyle(fontSize: 10, color: tok.textSecondary)),
            Text(l10n.vinTrzniDo(_fmtCena(above), currency),
                style: TextStyle(fontSize: 10, color: tok.textSecondary)),
          ],
        ),
      ],
    );
  }

  String _fmtCena(num v) {
    final s = v.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  Widget _buildTrzniRadek(TorkisTokens tok, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: tok.textSecondary)),
          const SizedBox(width: 8),
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
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildSekceKarta(tok, sekce[i])),
            if (i + 1 < sekce.length) ...[
              const SizedBox(width: TokSpace.md),
              Expanded(child: _buildSekceKarta(tok, sekce[i + 1])),
            ] else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
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
    final l10n = AppLocalizations.of(context);
    final stream = _rezimValue == 1
        ? _valueStream
        : _rezimValue == 2
            ? null
            : _historieStream;
    if (stream == null) return const SizedBox.shrink();

    final isFiltered = _dekovanyVin != null;

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(TokSpace.xl),
              child: Text(l10n.vinChybaHistorie,
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
              ? l10n.vinHistorieNoveVozidlo
              : zobrazit.length == 1
                  ? l10n.vinHistoriePoprve
                  : l10n.vinHistorieDekodovanoX(zobrazit.length);
        } else {
          headerTitle = l10n.vinHistorieNadpis;
          headerSub = dnes > 0
              ? l10n.vinHistorieDnes(dnes)
              : l10n.vinHistoriePosledni;
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
                          child: Text(l10n.vinHistorieVse,
                              style: const TextStyle(
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
                              ? l10n.vinHistorieNacitani
                              : isFiltered
                                  ? l10n.vinTotoVozidloNebyloDekodovano
                                  : l10n.vinHistorieZadneSkeny,
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
                          l10n: l10n,
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
    required AppLocalizations l10n,
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
                      nazev.isNotEmpty ? nazev : l10n.vinHistorieNezname,
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
                Text(_formatCas(cas, l10n),
                    style: TextStyle(fontSize: 10, color: tok.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
