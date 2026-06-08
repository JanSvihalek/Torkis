import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants.dart';
import '../../core/design_tokens.dart';
import '../../core/pdf_generator.dart';
import '../../l10n/app_localizations.dart';
import '../vozidla/vozidlo_detail.dart';
import '../zakaznici/zakaznik_detail.dart';

class PrijemDetailScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const PrijemDetailScreen(
      {super.key, required this.docId, required this.data});

  @override
  State<PrijemDetailScreen> createState() => _PrijemDetailScreenState();
}

class _PrijemDetailScreenState extends State<PrijemDetailScreen> {
  bool _isTisku = false;
  bool _isExportingFotek = false;

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-';
    final dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  String _formatDateHeader(dynamic timestamp) {
    if (timestamp == null) return '-';
    final dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd. MM. yyyy  HH:mm').format(dt);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Future<Uint8List> _generatePdfBytes() async {
    String servisNazev = 'Torkis Servis';
    String servisIco = '';
    final servisId = widget.data['servis_id']?.toString() ?? '';
    if (servisId.isNotEmpty) {
      final doc = await FirebaseFirestore.instance
          .collection('nastaveni_servisu')
          .doc(servisId)
          .get();
      if (doc.exists) {
        servisNazev = doc.data()?['nazev_servisu'] ?? 'Torkis Servis';
        servisIco = doc.data()?['ico_servisu'] ?? '';
      }
    }
    return GlobalPdfGenerator.generateDocument(
      data: widget.data,
      servisNazev: servisNazev,
      servisIco: servisIco,
      typ: PdfTyp.protokol,
    );
  }

  Future<void> _tiskniProtokol() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isTisku = true);
    try {
      final pdfBytes = await _generatePdfBytes();
      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: 'Protokol_${widget.data['cislo_zakazky'] ?? widget.docId}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.histChybaTisku(e.toString())),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isTisku = false);
    }
  }

  Future<void> _zobrazitProtokol() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isTisku = true);
    try {
      final pdfBytes = await _generatePdfBytes();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: Text(
                  l10n.histProtokol(widget.data['cislo_zakazky']?.toString() ?? '')),
            ),
            body: PdfPreview(
              build: (_) async => pdfBytes,
              allowPrinting: true,
              allowSharing: true,
              canChangePageFormat: false,
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.histChybaZobrazeni(e.toString())),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isTisku = false);
    }
  }

  Future<void> _exportFotodokumentace() async {
    final fotoUrls =
        widget.data['fotografie_urls'] as Map<String, dynamic>? ?? {};
    if (fotoUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Tato zakázka nemá žádnou fotodokumentaci.'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    setState(() => _isExportingFotek = true);
    try {
      final archive = Archive();
      int celkem = 0;

      for (final entry in fotoUrls.entries) {
        final kategorie = entry.key;
        final urls = (entry.value as List<dynamic>).cast<String>();
        // Použij český label pro název složky, pokud existuje
        final slozka = photoCategories[kategorie]?['label'] as String? ??
            kategorie;

        for (int i = 0; i < urls.length; i++) {
          final response = await http.get(Uri.parse(urls[i]));
          if (response.statusCode != 200) continue;
          final bytes = response.bodyBytes;
          // Struktura v ZIPu: <label kategorie>/<index+1>.jpg
          archive.addFile(ArchiveFile(
            '$slozka/${i + 1}.jpg',
            bytes.length,
            bytes,
          ));
          celkem++;
        }
      }

      if (celkem == 0) throw Exception('Žádné fotky se nepodařilo stáhnout.');

      final zipData = ZipEncoder().encode(archive);
      if (zipData == null) throw Exception('ZIP se nepodařilo sestavit.');

      final dir = await getTemporaryDirectory();
      final cislo =
          widget.data['cislo_zakazky']?.toString() ?? widget.docId;
      final path = '${dir.path}/fotodokumentace_$cislo.zip';
      await File(path).writeAsBytes(zipData);

      if (!mounted) return;
      setState(() => _isExportingFotek = false);

      await Share.shareXFiles(
        [XFile(path)],
        subject: 'Fotodokumentace $cislo',
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isExportingFotek = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Export fotek selhal: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final d = widget.data;
    final zakaznik = d['zakaznik'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: context.tok.bg,
      appBar: AppBar(
        title: Text(
          d['spz']?.toString() ?? l10n.histDetailNadpis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? TokColors.darkSurface : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isExportingFotek
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.photo_library_outlined),
            tooltip: 'Exportovat fotodokumentaci (ZIP)',
            onPressed: _isExportingFotek ? null : _exportFotodokumentace,
          ),
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            tooltip: l10n.histZobrazitProtokol,
            onPressed: _isTisku ? null : _zobrazitProtokol,
          ),
          IconButton(
            icon: _isTisku
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.print_outlined),
            tooltip: l10n.histTisknoutProtokol,
            onPressed: _isTisku ? null : _tiskniProtokol,
          ),
        ],
      ),
      body: _buildProtokolTab(isDark, d, zakaznik, l10n),
    );
  }

  Widget _buildProtokolTab(
    bool isDark,
    Map<String, dynamic> d,
    Map<String, dynamic> zakaznik,
    AppLocalizations l10n,
  ) {
    final stavVozidla = d['stav_vozidla'] as Map<String, dynamic>? ?? {};
    final fotoUrls = d['fotografie_urls'] as Map<String, dynamic>? ?? {};
    final podpisUrl = d['podpis_url']?.toString() ?? '';
    final pozadavky =
        (d['pozadavky_zakaznika'] as List<dynamic>? ?? []).cast<String>();

    final spz = d['spz']?.toString() ?? '';
    final vin = d['vin']?.toString() ?? '';
    final stav = d['stav']?.toString() ?? 'Přijato';
    final stavColor = getStatusColor(stav);
    final prijal = d['prijal_jmeno']?.toString() ?? '';
    final cisloZakazky = d['cislo_zakazky']?.toString() ?? '';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tmavý gradient header ────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B1A2E), Color(0xFF0D1F35)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: stavColor),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      stav.toUpperCase(),
                      style: TextStyle(
                        color: stavColor.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (spz.isNotEmpty)
                  Text(spz,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                if (vin.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(vin,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0)),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDateHeader(d['cas_prijeti']),
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12),
                    ),
                    Text(
                      cisloZakazky,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12),
                    ),
                  ],
                ),
                if (prijal.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.histPrijal,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12)),
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.blue),
                            child: Center(
                              child: Text(_initials(prijal),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(prijal,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // ── Sekce karet ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          _sectionCard(isDark,
              icon: Icons.directions_car,
              color: Colors.blue,
              title: l10n.histSekceVozidlo,
              onTap: () {
                final servisId = d['servis_id']?.toString() ?? '';
                final spz = d['spz']?.toString() ?? '';
                if (servisId.isEmpty || spz.isEmpty) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VozidloDetailScreen(
                        vozidloDocId: '${servisId}_$spz'),
                  ),
                );
              },
              children: [
                _infoRow(l10n.histPoleSPZ, d['spz']),
                _infoRow(l10n.histPoleZnackaModel,
                    '${d['znacka'] ?? ''} ${d['model'] ?? ''}'.trim()),
                _infoRow(l10n.histPoleVin, d['vin']),
                _infoRow(l10n.histPoleRokVyroby, d['rok_vyroby']),
                _infoRow(l10n.histPolePalivo, d['palivo_typ']),
                _infoRow(l10n.histPolePrevodovka, d['prevodovka']),
                _infoRow(l10n.histPoleMotorizace, d['motorizace']),
              ]),
          const SizedBox(height: 15),
          _sectionCard(isDark,
              icon: Icons.person,
              color: Colors.teal,
              title: l10n.histSekceZakaznik,
              onTap: zakaznik.isNotEmpty
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ZakaznikDetailScreen(zakaznikData: zakaznik),
                        ),
                      )
                  : null,
              children: [
                _infoRow(l10n.histPoleJmeno, zakaznik['jmeno']),
                _infoRow(l10n.histPoleTelefon, zakaznik['telefon']),
                _infoRow(l10n.histPoleEmail, zakaznik['email']),
                _infoRow(l10n.histPoleAdresa, zakaznik['adresa']),
                _infoRow(l10n.histPoleIco, zakaznik['ico']),
                _infoRow(l10n.histPoleDic, zakaznik['dic']),
              ]),
          const SizedBox(height: 15),
          _sectionCard(isDark,
              icon: Icons.fact_check_outlined,
              color: Colors.orange,
              title: l10n.histSekceStav,
              children: [
                _infoRow(
                  l10n.histPoleTachometr,
                  stavVozidla['tachometr'] != null &&
                          stavVozidla['tachometr'].toString().isNotEmpty
                      ? '${stavVozidla['tachometr']} km'
                      : null,
                ),
                _infoRow(
                  l10n.histPoleNadrz,
                  stavVozidla['nadrz'] != null
                      ? '${(stavVozidla['nadrz'] as num).toStringAsFixed(0)} %'
                      : null,
                ),
                _infoRow(
                  l10n.histPoleStk,
                  (stavVozidla['stk_mesic']?.toString() ?? '').isNotEmpty ||
                          (stavVozidla['stk_rok']?.toString() ?? '').isNotEmpty
                      ? '${stavVozidla['stk_mesic'] ?? '-'} / ${stavVozidla['stk_rok'] ?? '-'}'
                      : null,
                ),
                _infoRow(
                  l10n.histPolePoskozeni,
                  (stavVozidla['poskozeni'] as List<dynamic>? ?? []).join(', '),
                ),
                _infoRow(
                  l10n.histPolePneuLP,
                  (stavVozidla['pneu_lp']?.toString() ?? '').isNotEmpty ||
                          (stavVozidla['pneu_pp']?.toString() ?? '').isNotEmpty
                      ? '${stavVozidla['pneu_lp'] ?? '-'} / ${stavVozidla['pneu_pp'] ?? '-'}'
                      : null,
                ),
                _infoRow(
                  l10n.histPolePneuLZ,
                  (stavVozidla['pneu_lz']?.toString() ?? '').isNotEmpty ||
                          (stavVozidla['pneu_pz']?.toString() ?? '').isNotEmpty
                      ? '${stavVozidla['pneu_lz'] ?? '-'} / ${stavVozidla['pneu_pz'] ?? '-'}'
                      : null,
                ),
              ]),
          if (pozadavky.isNotEmpty) ...[
            const SizedBox(height: 15),
            _sectionCard(isDark,
                icon: Icons.build_circle_outlined,
                color: Colors.deepOrange,
                title: l10n.histSekcePozadavky,
                children: pozadavky
                    .map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.chevron_right,
                                  size: 18, color: Colors.deepOrange),
                              const SizedBox(width: 6),
                              Expanded(child: Text(p)),
                            ],
                          ),
                        ))
                    .toList()),
          ],
          if ((d['poznamky']?.toString() ?? '').isNotEmpty) ...[
            const SizedBox(height: 15),
            _sectionCard(isDark,
                icon: Icons.notes,
                color: Colors.blueGrey,
                title: l10n.histSekcePoznamky,
                children: [Text(d['poznamky'].toString())]),
          ],
          const SizedBox(height: 15),
          _buildFotoSection(isDark, fotoUrls, l10n),
          if (podpisUrl.isNotEmpty) ...[
            const SizedBox(height: 15),
            _buildPodpisSection(isDark, podpisUrl, l10n),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isTisku ? null : _zobrazitProtokol,
                  icon: _isTisku
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.visibility_outlined),
                  label: Text(l10n.histZobrazitProtokol),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isTisku ? null : _tiskniProtokol,
                  icon: const Icon(Icons.print_outlined),
                  label: Text(l10n.histTisknoutBtn),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    bool isDark, {
    required IconData icon,
    required Color color,
    required String title,
    required List<Widget> children,
    VoidCallback? onTap,
  }) {
    final hasContent = children.any((w) => w is! SizedBox);
    if (!hasContent) return const SizedBox();
    final container = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? TokColors.darkSurface : Colors.white,
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
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: color)),
              ),
              if (onTap != null)
                Icon(Icons.arrow_forward_ios, size: 14, color: color),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
    if (onTap == null) return container;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: container,
    );
  }

  Widget _infoRow(String label, dynamic value) {
    final val = value?.toString() ?? '';
    if (val.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(val,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildFotoSection(
      bool isDark, Map<String, dynamic> fotoUrls, AppLocalizations l10n) {
    final entries = fotoUrls.entries
        .where((e) => (e.value as List<dynamic>? ?? []).isNotEmpty)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? TokColors.darkSurface : Colors.white,
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
              const Icon(Icons.photo_library_outlined,
                  color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(l10n.histSekceFoto,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.purple)),
            ],
          ),
          const Divider(height: 20),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.no_photography_outlined,
                      color: Colors.grey, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.histZadneFoto,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ...entries.map((entry) {
            final kategorie = entry.key;
            final urls =
                (entry.value as List<dynamic>).cast<String>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kategorie,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: urls.length,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => _FotoGalerie(
                                urls: urls, startIndex: i),
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 110,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: isDark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Image.network(
                              urls[i],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image,
                                      color: Colors.grey)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPodpisSection(bool isDark, String podpisUrl, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? TokColors.darkSurface : Colors.white,
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
              const Icon(Icons.draw_outlined, color: Colors.indigo, size: 20),
              const SizedBox(width: 8),
              Text(l10n.histSekcePodpis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.indigo)),
            ],
          ),
          const Divider(height: 20),
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                podpisUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Center(
                    child: Text(l10n.histPodpisNedostupny,
                        style: const TextStyle(color: Colors.grey))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FotoGalerie extends StatefulWidget {
  final List<String> urls;
  final int startIndex;

  const _FotoGalerie({required this.urls, required this.startIndex});

  @override
  State<_FotoGalerie> createState() => _FotoGalerieState();
}

class _FotoGalerieState extends State<_FotoGalerie> {
  late final PageController _ctrl;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
    _ctrl = PageController(initialPage: widget.startIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_currentIndex + 1} / ${widget.urls.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _ctrl,
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, i) => InteractiveViewer(
          child: Center(
            child: Image.network(
              widget.urls[i],
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 64),
            ),
          ),
        ),
      ),
    );
  }
}
