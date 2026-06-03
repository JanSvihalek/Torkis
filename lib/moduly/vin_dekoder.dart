import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/design_tokens.dart';
import '../core/vincario_service.dart';
import 'auth_gate.dart';
import 'prijem/ocr_camera_page.dart';

class _Sekce {
  final String nazev;
  final IconData icon;
  final List<(String, String)> pole;
  // true → pole se renderují jako Wrap chipů místo label/value řádků
  final bool wrapLayout;
  const _Sekce(this.nazev, this.icon, this.pole, {this.wrapLayout = false});
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
  double? _apiCas;
  String? _logoUrl;

  bool get _maKlice => _apiKey.isNotEmpty && _secretKey.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nactiKlice();
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
      if (mounted) setState(() => _loadingKeys = false);
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
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
      _dekovanyVin = vin;
      _apiCas = null;
    });
    final start = DateTime.now();
    try {
      final res = await VincarioService.decode(
          vin: vin, apiKey: _apiKey, secretKey: _secretKey);
      final elapsed = DateTime.now().difference(start).inMilliseconds / 1000.0;
      if (mounted) {
        setState(() {
          _result = res;
          _apiCas = elapsed;
          _logoUrl = null;
        });
        _ulozitDoHistorie(vin, res);
        _nactiLogo(_f(res, ['Make']));
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _ulozitDoHistorie(String vin, VincarioResult r) async {
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

    final motor = filtr([
      ('Motorizace', _f(r, ['Engine'])),
      ('Typ motoru', _f(r, ['Engine Type'])),
      ('Zdvihový objem', objemStr),
      ('Výkon', vykon),
      ('Palivo', _f(r, ['Fuel Type'])),
      ('Převodovka', _f(r, ['Transmission'])),
      ('Počet převodů', _f(r, ['Number of Gears', 'Gears'])),
      ('Pohon', _f(r, ['Drive'])),
    ]);

    final karoserie = filtr([
      ('Typ karosérie', _f(r, ['Body Type'])),
      ('Počet dveří', _f(r, ['Number of Doors'])),
      ('Počet míst', _f(r, ['Number of Seats'])),
      ('Provozní hmotnost', curb.isNotEmpty ? '$curb kg' : ''),
      ('Max. hmotnost', gvw.isNotEmpty ? '${_formatCislo(gvw)} kg' : ''),
    ]);

    final registrace = filtr([
      ('1. registrace', reg1),
      ('Emisní norma', _f(r, ['Emission Standard'])),
      ('Emise CO₂', co2.isNotEmpty ? '$co2 g/km' : ''),
      ('Spotřeba (komb.)', spotr.isNotEmpty ? '$spotr l/100 km' : ''),
    ]);

    // Pole, která jsou již pokryta výše (původní anglické labely z API).
    const mapovane = {
      'Make', 'Model', 'Commercial Name', 'Model Year',
      'Body Type', 'Body', 'Trim', 'Series',
      'Manufacturer Address', 'Plant City', 'Plant Country',
      'Engine', 'Engine Type', 'Engine Displacement (ccm)',
      'Engine Power (kW)', 'Engine Power (HP)',
      'Fuel Type', 'Transmission', 'Number of Gears', 'Gears', 'Drive',
      'Number of Doors', 'Number of Seats',
      'Curb Weight (kg)', 'Gross Vehicle Weight (kg)',
      'Month of First Registration', 'Year of First Registration',
      'Emission Standard', 'CO2 Emission (g/km)',
      'Fuel Consumption Combined (l/100km)', 'Fuel Consumption (l/100km)',
    };

    // Všechna zbývající pole vrácená API, která nejsou v předchozích sekcích.
    final ostatni = r.vsechnyUdaje
        .where((p) => !mapovane.contains(p.label))
        .map((p) => (p.label, p.value))
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
        _Sekce('OSTATNÍ INFORMACE', Icons.data_object_rounded, ostatni,
            wrapLayout: true),
    ];
  }

  void _reset() => setState(() {
        _result = null;
        _error = null;
        _dekovanyVin = null;
        _apiCas = null;
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
        Container(
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
                            errorBuilder: (_, __, ___) => Icon(
                                Icons.directions_car_rounded,
                                color: TokColors.ink,
                                size: 26),
                          )
                        : Icon(Icons.directions_car_rounded,
                            color: TokColors.ink, size: 26),
                  ),
                  const SizedBox(width: TokSpace.md),
                  // Název — Flexible aby se nerozbil layout s tlačítkem
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (nadpis.isNotEmpty)
                          Text(nadpis,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: tok.textPrimary,
                                height: 1.1,
                              )),
                        if (podnadpis.isNotEmpty)
                          Text(podnadpis,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13, color: tok.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: TokSpace.sm),
                  OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh_rounded, size: 14),
                    label: const Text('Nový sken'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: tok.textPrimary,
                      side: BorderSide(color: tok.line),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(TokRadius.md)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TokSpace.md),
              Row(
                children: [
                  Text(
                    _dekovanyVin ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: tok.textPrimary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  if (_apiCas != null) ...[
                    const SizedBox(width: TokSpace.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(TokRadius.round),
                        border: Border.all(
                            color: const Color(0xFF22C55E)
                                .withValues(alpha: 0.30)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_rounded,
                              size: 11, color: Color(0xFF22C55E)),
                          const SizedBox(width: 4),
                          Text(
                            'Dekódováno přes API · ${_apiCas!.toStringAsFixed(1)} s',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF22C55E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          if (sekce.wrapLayout)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sekce.pole
                  .map((p) => _buildOstatniChip(tok, p.$1, p.$2))
                  .toList(),
            )
          else
            ...sekce.pole.map((p) => _buildRadek(tok, p.$1, p.$2)),
        ],
      ),
    );
  }

  Widget _buildOstatniChip(TorkisTokens tok, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tok.isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(TokRadius.md),
        border: Border.all(color: tok.line),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label  ',
              style: TextStyle(
                  fontSize: 11,
                  color: tok.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: tok.textPrimary),
            ),
          ],
        ),
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
    if (_sId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vin_skeny')
          .where('servis_id', isEqualTo: _sId)
          .orderBy('cas', descending: true)
          .limit(30)
          .snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        final now = DateTime.now();
        final dnes = docs.where((d) {
          final ts = (d.data() as Map)['cas'];
          if (ts is Timestamp) {
            final dt = ts.toDate();
            return dt.year == now.year &&
                dt.month == now.month &&
                dt.day == now.day;
          }
          return false;
        }).length;

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
                      const Icon(Icons.history_rounded,
                          size: 16, color: TokColors.accent),
                      const SizedBox(width: 6),
                      Text('Historie skenů',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: tok.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dnes > 0
                        ? 'Dnes · $dnes dekódovaných VIN'
                        : 'Poslední skeny',
                    style: TextStyle(fontSize: 11, color: tok.textSecondary),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: tok.line),
            Expanded(
              child: docs.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(TokSpace.xl),
                        child: Text('Zatím žádné skeny',
                            style: TextStyle(
                                fontSize: 13, color: tok.textSecondary),
                            textAlign: TextAlign.center),
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.symmetric(vertical: TokSpace.xs),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final vin = data['vin']?.toString() ?? '';
                        final znacka = data['znacka']?.toString() ?? '';
                        final model = data['model']?.toString() ?? '';
                        final rok = data['rok']?.toString() ?? '';
                        final motorizace = data['motorizace']?.toString() ?? '';
                        final nazev = [znacka, model]
                            .where((s) => s.isNotEmpty)
                            .join(' ');
                        final detail = [motorizace, rok]
                            .where((s) => s.isNotEmpty)
                            .join(' · ');
                        final ts = data['cas'] as Timestamp?;
                        final cas = ts?.toDate();
                        final isActive = vin == _dekovanyVin;
                        final vinTrunc = vin.length > 11
                            ? '${vin.substring(0, 7)}…${vin.substring(vin.length - 4)}'
                            : vin;

                        return _buildHistoriePolozka(
                          tok,
                          nazev: nazev,
                          detail: detail,
                          vinTrunc: vinTrunc,
                          cas: cas,
                          isActive: isActive,
                          onTap: isActive
                              ? null
                              : () {
                                  setState(() => _vinCtrl.text = vin);
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
