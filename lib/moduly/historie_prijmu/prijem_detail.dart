import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../../core/pdf_generator.dart';
import '../zakazka/prubeh.dart';
import '../zakazka_komunikace/zakazka_komunikace_page.dart';

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

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-';
    final dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
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
            content: Text('Chyba při tisku: $e'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isTisku = false);
    }
  }

  Future<void> _zobrazitProtokol() async {
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
                  'Protokol ${widget.data['cislo_zakazky'] ?? ''}'),
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
            content: Text('Chyba při zobrazení: $e'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isTisku = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final d = widget.data;
    final stavVozidla = d['stav_vozidla'] as Map<String, dynamic>? ?? {};
    final zakaznik = d['zakaznik'] as Map<String, dynamic>? ?? {};
    final fotoUrls = d['fotografie_urls'] as Map<String, dynamic>? ?? {};
    final podpisUrl = d['podpis_url']?.toString() ?? '';
    final pozadavky =
        (d['pozadavky_zakaznika'] as List<dynamic>? ?? []).cast<String>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          d['spz']?.toString() ?? 'Detail příjmu',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            tooltip: 'Komunikace se zákazníkem',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ZakazkaKomunikacePage(
                  documentId: widget.docId,
                  zakazkaId: d['cislo_zakazky']?.toString() ?? '',
                  spz: d['spz']?.toString() ?? '',
                  zakaznikJmeno: zakaznik['jmeno']?.toString() ?? '',
                  zakaznikEmail: zakaznik['email']?.toString() ?? '',
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            tooltip: 'Zobrazit protokol',
            onPressed: _isTisku ? null : _zobrazitProtokol,
          ),
          IconButton(
            icon: _isTisku
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.print_outlined),
            tooltip: 'Tisknout protokol',
            onPressed: _isTisku ? null : _tiskniProtokol,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Přijato: ${_formatDate(d['cas_prijeti'])}',
                          style: const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        'Zakázka: ${d['cislo_zakazky'] ?? ''}',
                        style: const TextStyle(
                            color: Colors.blue, fontSize: 12),
                      ),
                    ],
                  ),
                  if (d['prijal_jmeno'] != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, color: Colors.blue, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Přijal: ${d['prijal_jmeno']}',
                          style: TextStyle(
                              color: Colors.blue.withValues(alpha: 0.8), fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 15),

            _sectionCard(
              isDark,
              icon: Icons.directions_car,
              color: Colors.blue,
              title: 'Vozidlo',
              children: [
                _infoRow('SPZ', d['spz']),
                _infoRow('Značka & Model',
                    '${d['znacka'] ?? ''} ${d['model'] ?? ''}'.trim()),
                _infoRow('VIN', d['vin']),
                _infoRow('Rok výroby', d['rok_vyroby']),
                _infoRow('Palivo', d['palivo_typ']),
                _infoRow('Převodovka', d['prevodovka']),
                _infoRow('Motorizace', d['motorizace']),
              ],
            ),
            const SizedBox(height: 15),

            _sectionCard(
              isDark,
              icon: Icons.person,
              color: Colors.teal,
              title: 'Zákazník',
              children: [
                _infoRow('Jméno', zakaznik['jmeno']),
                _infoRow('Telefon', zakaznik['telefon']),
                _infoRow('E-mail', zakaznik['email']),
                _infoRow('Adresa', zakaznik['adresa']),
                _infoRow('IČO', zakaznik['ico']),
              ],
            ),
            const SizedBox(height: 15),

            _sectionCard(
              isDark,
              icon: Icons.fact_check_outlined,
              color: Colors.orange,
              title: 'Stav při příjmu',
              children: [
                _infoRow(
                  'Tachometr',
                  stavVozidla['tachometr'] != null &&
                          stavVozidla['tachometr'].toString().isNotEmpty
                      ? '${stavVozidla['tachometr']} km'
                      : null,
                ),
                _infoRow(
                  'Stav nádrže',
                  stavVozidla['nadrz'] != null
                      ? '${(stavVozidla['nadrz'] as num).toStringAsFixed(0)} %'
                      : null,
                ),
                _infoRow(
                  'STK',
                  (stavVozidla['stk_mesic']?.toString() ?? '').isNotEmpty ||
                          (stavVozidla['stk_rok']?.toString() ?? '').isNotEmpty
                      ? '${stavVozidla['stk_mesic'] ?? '-'} / ${stavVozidla['stk_rok'] ?? '-'}'
                      : null,
                ),
                _infoRow(
                  'Poškození',
                  (stavVozidla['poskozeni'] as List<dynamic>? ?? [])
                      .join(', '),
                ),
                _infoRow(
                  'Pneumatiky LP / PP',
                  (stavVozidla['pneu_lp']?.toString() ?? '').isNotEmpty ||
                          (stavVozidla['pneu_pp']?.toString() ?? '').isNotEmpty
                      ? '${stavVozidla['pneu_lp'] ?? '-'} / ${stavVozidla['pneu_pp'] ?? '-'}'
                      : null,
                ),
                _infoRow(
                  'Pneumatiky LZ / PZ',
                  (stavVozidla['pneu_lz']?.toString() ?? '').isNotEmpty ||
                          (stavVozidla['pneu_pz']?.toString() ?? '').isNotEmpty
                      ? '${stavVozidla['pneu_lz'] ?? '-'} / ${stavVozidla['pneu_pz'] ?? '-'}'
                      : null,
                ),
              ],
            ),

            if (pozadavky.isNotEmpty) ...[
              const SizedBox(height: 15),
              _sectionCard(
                isDark,
                icon: Icons.build_circle_outlined,
                color: Colors.deepOrange,
                title: 'Požadavky zákazníka',
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
                    .toList(),
              ),
            ],

            if ((d['poznamky']?.toString() ?? '').isNotEmpty) ...[
              const SizedBox(height: 15),
              _sectionCard(
                isDark,
                icon: Icons.notes,
                color: Colors.blueGrey,
                title: 'Poznámky',
                children: [Text(d['poznamky'].toString())],
              ),
            ],

            const SizedBox(height: 15),
            _buildFotoSection(isDark, fotoUrls),

            if (podpisUrl.isNotEmpty) ...[
              const SizedBox(height: 15),
              _buildPodpisSection(isDark, podpisUrl),
            ],

            const SizedBox(height: 20),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                        label: const Text('Zobrazit'),
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
                        label: const Text('Tisk'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActiveJobScreen(
                        documentId: widget.docId,
                        zakazkaId: d['cislo_zakazky']?.toString() ?? '',
                        spz: d['spz']?.toString() ?? '',
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.build_circle_outlined),
                  label: const Text('Otevřít zakázku'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(
    bool isDark, {
    required IconData icon,
    required Color color,
    required String title,
    required List<Widget> children,
  }) {
    final hasContent = children.any((w) => w is! SizedBox);
    if (!hasContent) return const SizedBox();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: color)),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
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
      bool isDark, Map<String, dynamic> fotoUrls) {
    final entries = fotoUrls.entries
        .where((e) => (e.value as List<dynamic>? ?? []).isNotEmpty)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.photo_library_outlined,
                  color: Colors.purple, size: 20),
              SizedBox(width: 8),
              Text('Fotodokumentace',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.purple)),
            ],
          ),
          const Divider(height: 20),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.no_photography_outlined,
                      color: Colors.grey, size: 18),
                  SizedBox(width: 8),
                  Text('Nebyly pořízeny žádné fotografie.',
                      style: TextStyle(color: Colors.grey)),
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

  Widget _buildPodpisSection(bool isDark, String podpisUrl) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.draw_outlined, color: Colors.indigo, size: 20),
              SizedBox(width: 8),
              Text('Podpis zákazníka',
                  style: TextStyle(
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
                errorBuilder: (_, __, ___) => const Center(
                    child: Text('Podpis není k dispozici',
                        style: TextStyle(color: Colors.grey))),
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
