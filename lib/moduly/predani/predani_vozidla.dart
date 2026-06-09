import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/biometric_signature.dart';
import '../../core/biometric_signature_pad.dart';
import '../../core/design_tokens.dart';
import '../../core/signature_capture_screen.dart';
import '../../l10n/app_localizations.dart';
import '../auth_gate.dart';
import '../prijem/photo_annotation_editor.dart';

/// Jeden řádek provedené práce (název + cena).
class _PraceRadek {
  final TextEditingController nazev;
  final TextEditingController cena;
  _PraceRadek({String nazevText = '', String cenaText = ''})
      : nazev = TextEditingController(text: nazevText),
        cena = TextEditingController(text: cenaText);
  void dispose() {
    nazev.dispose();
    cena.dispose();
  }
}

/// Předání vozidla zákazníkovi — závěrečná fáze zakázky.
/// Zapisuje do téhož dokumentu zakázky: provedené práce, finální cenu, foto
/// při předání, podpis převzetí (biometrie + pečeť) a nastaví stav „Dokončeno".
class PredaniVozidlaScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const PredaniVozidlaScreen(
      {super.key, required this.docId, required this.data});

  @override
  State<PredaniVozidlaScreen> createState() => _PredaniVozidlaScreenState();
}

class _PredaniVozidlaScreenState extends State<PredaniVozidlaScreen> {
  final List<_PraceRadek> _prace = [];
  final _tachometrPredani = TextEditingController();
  final List<XFile> _fotky = [];
  final BiometricSignatureController _sig = BiometricSignatureController();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _cenik = [];
  bool _isSaving = false;

  String get _servisId => widget.data['servis_id']?.toString() ?? '';
  String get _zakazkaId => widget.data['cislo_zakazky']?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    // Předvyplníme provedené práce z původních požadavků zákazníka.
    final pozadavky =
        (widget.data['pozadavky_zakaznika'] as List<dynamic>? ?? [])
            .cast<String>();
    for (final p in pozadavky) {
      if (p.trim().isNotEmpty) _prace.add(_PraceRadek(nazevText: p.trim()));
    }
    _nactiCenik();
  }

  @override
  void dispose() {
    for (final r in _prace) {
      r.dispose();
    }
    _tachometrPredani.dispose();
    _sig.dispose();
    super.dispose();
  }

  Future<void> _nactiCenik() async {
    if (_servisId.isEmpty) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('ukony')
          .where('servis_id', isEqualTo: _servisId)
          .get();
      if (!mounted) return;
      setState(() {
        _cenik = snap.docs.map((d) => d.data()).toList();
      });
    } catch (_) {/* ceník je volitelný */}
  }

  double get _celkem {
    double sum = 0;
    for (final r in _prace) {
      sum += double.tryParse(r.cena.text.replaceAll(',', '.')) ?? 0;
    }
    return sum;
  }

  // ── Práce ────────────────────────────────────────────────────────────────

  void _pridatPraci() => setState(() => _prace.add(_PraceRadek()));

  void _vybratZCeniku() {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? TokColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: _cenik.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.predaniBezPrace,
                    style: TextStyle(color: context.tok.textSecondary)),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: _cenik.length,
                itemBuilder: (_, i) {
                  final u = _cenik[i];
                  final nazev = u['nazev']?.toString() ?? '';
                  final cena = (u['cena_bez_dph'] as num?)?.toDouble() ?? 0;
                  return ListTile(
                    title: Text(nazev),
                    trailing: Text('${cena.toStringAsFixed(0)} Kč',
                        style: TextStyle(color: context.tok.textSecondary)),
                    onTap: () {
                      setState(() => _prace.add(_PraceRadek(
                          nazevText: nazev,
                          cenaText: cena > 0 ? cena.toStringAsFixed(0) : '')));
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
      ),
    );
  }

  // ── Foto ───────────────────────────────────────────────────────────────────

  Future<void> _pridatFoto() async {
    final List<XFile> picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) setState(() => _fotky.addAll(picked));
  }

  Future<void> _vyfotit() async {
    final XFile? shot =
        await _picker.pickImage(source: ImageSource.camera);
    if (shot != null) setState(() => _fotky.add(shot));
  }

  Future<void> _anotovat(int index) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bytes =
        await PhotoAnnotationEditor.open(context, _fotky[index], isDark);
    if (bytes == null || !mounted) return;
    final dir = File(_fotky[index].path).parent.path;
    final newPath =
        '$dir/predani_annot_${DateTime.now().microsecondsSinceEpoch}.png';
    await File(newPath).writeAsBytes(bytes);
    setState(() => _fotky[index] = XFile(newPath));
  }

  // ── Podpis ──────────────────────────────────────────────────────────────────

  Future<void> _podepsat() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await SignatureCaptureScreen.open(context, _sig, isDark);
    if (mounted) setState(() {});
  }

  Future<BiometricSignature> _zachytBiometrii() async {
    String deviceModel = 'neznámé';
    String platform = kIsWeb ? 'web' : defaultTargetPlatform.name;
    if (!kIsWeb) {
      try {
        final info = DeviceInfoPlugin();
        if (defaultTargetPlatform == TargetPlatform.android) {
          final a = await info.androidInfo;
          deviceModel = '${a.manufacturer} ${a.model}';
          platform = 'Android ${a.version.release} (SDK ${a.version.sdkInt})';
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          final i = await info.iosInfo;
          deviceModel = i.utsname.machine;
          platform = '${i.systemName} ${i.systemVersion}';
        }
      } catch (_) {/* best effort */}
    }
    String appVersion = '';
    try {
      final pkg = await PackageInfo.fromPlatform();
      appVersion = '${pkg.version}+${pkg.buildNumber}';
    } catch (_) {/* ignore */}
    final locale =
        WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag();
    return _sig.buildBiometricSignature(
      deviceModel: deviceModel,
      platform: platform,
      appVersion: appVersion,
      locale: locale,
    );
  }

  // ── Dokončení ────────────────────────────────────────────────────────────────

  Future<void> _dokoncit() async {
    final l10n = AppLocalizations.of(context);
    if (_sig.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.predaniChybaPodpis),
          backgroundColor: Colors.orange));
      return;
    }
    final souhlasText = l10n.predaniSouhlas;
    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final ts = DateTime.now().millisecondsSinceEpoch;
      final basePath = 'servisy/$_servisId/zakazky/$_zakazkaId/predani';

      // 1) Foto při předání
      final List<String> fotoUrls = [];
      for (int i = 0; i < _fotky.length; i++) {
        final bytes = await _fotky[i].readAsBytes();
        final ref =
            FirebaseStorage.instance.ref().child('$basePath/foto_${ts}_$i.jpg');
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        fotoUrls.add(await ref.getDownloadURL());
      }

      // 2) Podpis převzetí (PNG + biometrie JSON + pečeť)
      final biometrie = await _zachytBiometrii();
      String? podpisUrl;
      String? podpisDataUrl;
      final png = await _sig.toPngBytes();
      if (png != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('$basePath/podpis_$ts.png');
        await ref.putData(png, SettableMetadata(contentType: 'image/png'));
        podpisUrl = await ref.getDownloadURL();
      }
      final dataRef = FirebaseStorage.instance
          .ref()
          .child('$basePath/podpis_biometrie_$ts.json');
      await dataRef.putData(
          Uint8List.fromList(utf8.encode(biometrie.encode())),
          SettableMetadata(contentType: 'application/json'));
      podpisDataUrl = await dataRef.getDownloadURL();

      // 3) Provedené práce + pečeť
      final provedene = _prace
          .where((r) => r.nazev.text.trim().isNotEmpty)
          .map((r) => {
                'nazev': r.nazev.text.trim(),
                'cena': double.tryParse(r.cena.text.replaceAll(',', '.')) ?? 0,
              })
          .toList();

      final dokumentObsah = <String, dynamic>{
        'cislo_zakazky': _zakazkaId,
        'provedene_prace': provedene,
        'cena_celkem': _celkem,
        'tachometr_predani': _tachometrPredani.text.trim(),
      };
      final seal = SignatureSeal.create(
        biometrics: biometrie,
        documentContent: dokumentObsah,
        consentText: souhlasText,
      ).toJson();

      // 4) Zápis do téže zakázky
      await FirebaseFirestore.instance
          .collection('zakazky')
          .doc(widget.docId)
          .set({
        'provedene_prace': provedene,
        'cena_celkem': _celkem,
        'tachometr_predani': _tachometrPredani.text.trim(),
        'fotografie_predani_urls': fotoUrls,
        'podpis_predani_url': podpisUrl,
        'podpis_predani_data_url': podpisDataUrl,
        'podpis_predani_seal': seal,
        'stav_zakazky': 'Dokončeno',
        'cas_predani': FieldValue.serverTimestamp(),
        'predal_uid': user?.uid,
        'predal_jmeno': globalUserJmeno ?? user?.email ?? 'Neznámý',
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.predaniHotovo),
          backgroundColor: Colors.green));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tok = context.tok;
    final isDark = tok.isDark;

    return Scaffold(
      backgroundColor: tok.bg,
      appBar: AppBar(
        title: Text(l10n.predaniTitul,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? TokColors.darkSurface : Colors.white,
        elevation: 0,
      ),
      body: AbsorbPointer(
        absorbing: _isSaving,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sekcePrace(l10n, tok),
                  const SizedBox(height: 15),
                  _sekcePorovnani(l10n, tok),
                  const SizedBox(height: 15),
                  _sekceFoto(l10n, tok, isDark),
                  const SizedBox(height: 15),
                  _sekcePodpis(l10n, tok),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _dokoncit,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                          _isSaving ? l10n.predaniProbiha : l10n.predaniDokoncit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TokColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Sekce ──────────────────────────────────────────────────────────────────

  Widget _card(TorkisTokens tok,
      {required IconData icon,
      required String title,
      required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TokSpace.lg),
      decoration: BoxDecoration(
        color: tok.surface,
        borderRadius: BorderRadius.circular(TokRadius.xl),
        border: Border.all(color: tok.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: tok.accentSoft,
                  borderRadius: BorderRadius.circular(TokRadius.sm),
                ),
                child: Icon(icon, color: tok.accent, size: 18),
              ),
              const SizedBox(width: TokSpace.sm),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: tok.textPrimary)),
              ),
            ],
          ),
          Divider(height: 24, color: tok.line),
          ...children,
        ],
      ),
    );
  }

  Widget _sekcePrace(AppLocalizations l10n, TorkisTokens tok) {
    return _card(tok,
        icon: Icons.build_circle_outlined,
        title: l10n.predaniProvedenePrace,
        children: [
          if (_prace.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(l10n.predaniBezPrace,
                  style: TextStyle(color: tok.textSecondary, fontSize: 13)),
            ),
          for (int i = 0; i < _prace.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _prace[i].nazev,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: l10n.predaniNazevPrace,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: _prace[i].cena,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.right,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: l10n.predaniCena,
                        suffixText: 'Kč',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 18, color: Colors.redAccent),
                    onPressed: () => setState(() {
                      _prace[i].dispose();
                      _prace.removeAt(i);
                    }),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pridatPraci,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.predaniPridatPraci),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _vybratZCeniku,
                  icon: const Icon(Icons.list_alt, size: 18),
                  label: Text(l10n.predaniVybratZCeniku),
                ),
              ),
            ],
          ),
          Divider(height: 24, color: tok.line),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.predaniCelkem,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: tok.textPrimary)),
              Text('${_celkem.toStringAsFixed(0)} Kč',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: tok.accent)),
            ],
          ),
        ]);
  }

  Widget _sekcePorovnani(AppLocalizations l10n, TorkisTokens tok) {
    final stav = widget.data['stav_vozidla'] as Map<String, dynamic>? ?? {};
    final tachPrijem = stav['tachometr']?.toString() ?? '';
    final nadrz = stav['nadrz'] != null
        ? '${(stav['nadrz'] as num).toStringAsFixed(0)} %'
        : '';
    final poskozeni =
        (stav['poskozeni'] as List<dynamic>? ?? []).join(', ');

    return _card(tok,
        icon: Icons.compare_arrows_rounded,
        title: l10n.predaniPorovnani,
        children: [
          Row(
            children: [
              const SizedBox(width: 130),
              Expanded(
                child: Text(l10n.predaniPriPrijmu,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: tok.textSecondary)),
              ),
              Expanded(
                child: Text(l10n.predaniPriPredani,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: tok.accent)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _porovnaniRow(
            tok,
            l10n.histPoleTachometr,
            tachPrijem.isEmpty ? '-' : '$tachPrijem km',
            child: TextField(
              controller: _tachometrPredani,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                hintText: l10n.predaniTachometrPredani,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          if (nadrz.isNotEmpty)
            _porovnaniRow(tok, l10n.histPoleNadrz, nadrz),
          if (poskozeni.isNotEmpty)
            _porovnaniRow(tok, l10n.histPolePoskozeni, poskozeni),
        ]);
  }

  Widget _porovnaniRow(TorkisTokens tok, String label, String prijem,
      {Widget? child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(color: tok.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(prijem,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: tok.textPrimary)),
          ),
          Expanded(
            child: child ??
                Text('—',
                    style: TextStyle(color: tok.textSecondary, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _sekceFoto(AppLocalizations l10n, TorkisTokens tok, bool isDark) {
    return _card(tok,
        icon: Icons.photo_camera_outlined,
        title: l10n.predaniFoto,
        children: [
          if (_fotky.isNotEmpty)
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _fotky.length,
                itemBuilder: (_, i) => Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _anotovat(i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: kIsWeb
                              ? Image.network(_fotky[i].path,
                                  width: 80, height: 80, fit: BoxFit.cover)
                              : Image.file(File(_fotky[i].path),
                                  width: 80, height: 80, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => setState(() => _fotky.removeAt(i)),
                        child: const CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.close,
                                size: 14, color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_fotky.isNotEmpty) const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _vyfotit,
                  icon: const Icon(Icons.add_a_photo_rounded, size: 18),
                  label: Text(l10n.predaniPridatFoto),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _pridatFoto,
                icon: const Icon(Icons.photo_library_rounded),
                tooltip: l10n.predaniPridatFoto,
              ),
            ],
          ),
        ]);
  }

  Widget _sekcePodpis(AppLocalizations l10n, TorkisTokens tok) {
    return _card(tok,
        icon: Icons.draw_outlined,
        title: l10n.predaniPodpisPrevzeti,
        children: [
          Text(l10n.predaniSouhlas,
              style: TextStyle(color: tok.textSecondary, fontSize: 13)),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: _sig,
            builder: (context, _) {
              if (_sig.isEmpty) {
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _podepsat,
                    icon: const Icon(Icons.draw_outlined),
                    label: Text(l10n.prijemPodpisOtevrit),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: tok.accent,
                      side: BorderSide(color: tok.accent, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _podepsat,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                          border: Border.all(color: tok.accent, width: 2),
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: SignaturePreview(controller: _sig),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton.icon(
                          onPressed: () => _sig.clear(),
                          icon: const Icon(Icons.clear, color: Colors.red),
                          label: Text(l10n.prijemPodpisSmazat,
                              style: const TextStyle(color: Colors.red))),
                      const Spacer(),
                      TextButton.icon(
                          onPressed: _podepsat,
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(l10n.prijemPodpisZnovu)),
                    ],
                  ),
                ],
              );
            },
          ),
        ]);
  }
}
