import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/design_tokens.dart';
import '../core/torkis_ui.dart';
import '../core/vincario_service.dart';
import 'auth_gate.dart';
import 'prijem/ocr_camera_page.dart';

/// Rychlý náhled údajů o vozidle podle VINu přes Vincario API.
/// Pouze zobrazuje, co API vrátí — nic neukládá.
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

  bool get _maKlice => _apiKey.isNotEmpty && _secretKey.isNotEmpty;

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
    });
    try {
      final res = await VincarioService.decode(
          vin: vin, apiKey: _apiKey, secretKey: _secretKey);
      if (mounted) setState(() => _result = res);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    if (_loadingKeys) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(TokSpace.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _inputCard(tok),
              if (!_maKlice) ...[
                const SizedBox(height: TokSpace.lg),
                _keysBanner(tok),
              ],
              if (_loading) ...[
                const SizedBox(height: TokSpace.xxl),
                const Center(child: CircularProgressIndicator()),
              ],
              if (_error != null) ...[
                const SizedBox(height: TokSpace.lg),
                _errorCard(tok, _error!),
              ],
              if (_result != null) ...[
                const SizedBox(height: TokSpace.lg),
                _resultView(tok, _result!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputCard(TorkisTokens tok) {
    return Container(
      decoration: BoxDecoration(
        color: tok.surface,
        borderRadius: BorderRadius.circular(TokRadius.xl),
        border: Border.all(color: tok.line),
      ),
      padding: const EdgeInsets.all(TokSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('VIN kód vozidla',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: tok.textSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: _vinCtrl,
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: tok.textPrimary),
            cursorColor: TokColors.accent,
            onSubmitted: (_) => _maKlice ? _dekodovat() : null,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.tag_outlined,
                  color: TokColors.accent, size: 18),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner_rounded,
                    color: TokColors.steel, size: 20),
                onPressed: _scanVin,
                tooltip: 'Naskenovat VIN',
              ),
              filled: true,
              fillColor: tok.isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : TokColors.paper,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TokRadius.md),
                borderSide: BorderSide(color: tok.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TokRadius.md),
                borderSide:
                    const BorderSide(color: TokColors.accent, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: TokSpace.md),
          TorkisPrimaryButton(
            label: 'Dekódovat VIN',
            loading: _loading,
            onPressed: _maKlice && !_loading ? _dekodovat : null,
            trailingIcon: Icons.travel_explore_rounded,
          ),
        ],
      ),
    );
  }

  Widget _keysBanner(TorkisTokens tok) {
    return Container(
      width: double.infinity,
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

  Widget _errorCard(TorkisTokens tok, String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TokSpace.lg),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(TokRadius.lg),
        border: Border.all(color: Colors.red.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.red, size: 20),
          const SizedBox(width: TokSpace.md),
          Expanded(
            child: Text('Nepodařilo se dekódovat VIN: $msg',
                style: TextStyle(fontSize: 13, color: tok.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _resultView(TorkisTokens tok, VincarioResult res) {
    final znacka = res.field('Make');
    final model = res.field('Model');
    final rok = res.field('Model Year');
    final nadpis = [znacka, model].where((s) => s.isNotEmpty).join(' ');
    final udaje = res.vsechnyUdaje;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (nadpis.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(TokSpace.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [TokColors.ink, TokColors.inkSoft],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(TokRadius.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nadpis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
                if (rok.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('Rok výroby $rok',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13)),
                ],
              ],
            ),
          ),
        const SizedBox(height: TokSpace.lg),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: tok.surface,
            borderRadius: BorderRadius.circular(TokRadius.xl),
            border: Border.all(color: tok.line),
          ),
          padding: const EdgeInsets.symmetric(
              horizontal: TokSpace.lg, vertical: TokSpace.xs),
          child: Column(
            children: [
              for (int i = 0; i < udaje.length; i++) ...[
                if (i > 0) Divider(height: 1, color: tok.line),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: TokSpace.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(udaje[i].label,
                            style: TextStyle(
                                fontSize: 13, color: tok.textSecondary)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: Text(udaje[i].value,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: tok.textPrimary)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
