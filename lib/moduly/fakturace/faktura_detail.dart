import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import '../../core/pdf_generator.dart';
import '../auth_gate.dart';
import '../zakaznici/zakaznik_detail.dart';
import '../vozidla/vozidlo_detail.dart';
import '../zakazka/prubeh.dart';
import 'faktura_edit_polozky.dart';

Future<void> syncAndRegenerateFaktura(
  String fakturaDocId,
  String zakazkaId,
  List<dynamic> updatedPrace,
) async {
  if (globalServisId == null) return;

  double celkovaSuma = 0.0;
  for (var prace in updatedPrace) {
    final polozky = prace['polozky'] as List<dynamic>?;
    if (polozky != null) {
      for (var p in polozky) {
        double mnoz = double.tryParse(p['mnozstvi'].toString()) ?? 1.0;
        double cena = double.tryParse(p['cena_s_dph'].toString()) ?? 0.0;
        double sleva = double.tryParse(p['sleva']?.toString() ?? '0') ?? 0.0;
        celkovaSuma += (mnoz * cena) * (1 - (sleva / 100));
      }
    } else {
      celkovaSuma += (prace['cena_s_dph'] ?? 0.0).toDouble();
      final dily = prace['pouzite_dily'] as List<dynamic>? ?? [];
      for (var dil in dily) {
        double p = double.tryParse(dil['pocet'].toString()) ?? 1.0;
        double c = double.tryParse(dil['cena_s_dph'].toString()) ?? 0.0;
        celkovaSuma += (p * c);
      }
    }
  }

  final docNastaveni = await FirebaseFirestore.instance
      .collection('nastaveni_servisu')
      .doc(globalServisId)
      .get();
  String odesilatelJmeno = docNastaveni.data()?['nazev_servisu'] ?? 'Servis';
  String odesilatelIco = docNastaveni.data()?['ico_servisu'] ?? '';

  if (zakazkaId != 'PRODEJ' && zakazkaId != 'PULTOVÝ PRODEJ') {
    final zakazkaRef = FirebaseFirestore.instance
        .collection('zakazky')
        .doc('${globalServisId}_$zakazkaId');
    final zakDoc = await zakazkaRef.get();

    if (zakDoc.exists) {
      final zakData = zakDoc.data()!;
      zakData['provedene_prace'] = updatedPrace;

      final pdfBytes = await GlobalPdfGenerator.generateDocument(
        data: zakData,
        servisNazev: odesilatelJmeno,
        servisIco: odesilatelIco,
        typ: PdfTyp.faktura,
      );

      Reference pdfRef = FirebaseStorage.instance.ref().child(
          'servisy/$globalServisId/zakazky/$zakazkaId/finalni_vyuctovani_$zakazkaId.pdf');
      await pdfRef.putData(
          pdfBytes, SettableMetadata(contentType: 'application/pdf'));
      String pdfUrl = await pdfRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('faktury')
          .doc(fakturaDocId)
          .update({
        'provedene_prace': updatedPrace,
        'celkova_castka': celkovaSuma,
        'pdf_url': pdfUrl,
      });

      await zakazkaRef.update({
        'provedene_prace': updatedPrace,
        'vystupni_protokol_url': pdfUrl,
      });
    }
  } else {
    final fakturaRef =
        FirebaseFirestore.instance.collection('faktury').doc(fakturaDocId);
    final fakDoc = await fakturaRef.get();

    if (fakDoc.exists) {
      final fakData = fakDoc.data()!;
      fakData['provedene_prace'] = updatedPrace;
      fakData['celkova_castka'] = celkovaSuma;

      final pdfBytes = await GlobalPdfGenerator.generateDocument(
        data: fakData,
        servisNazev: odesilatelJmeno,
        servisIco: odesilatelIco,
        typ: PdfTyp.faktura,
      );

      String cisloFak = fakData['cislo_faktury'] ?? 'PRODEJ';
      Reference pdfRef = FirebaseStorage.instance
          .ref()
          .child('servisy/$globalServisId/faktury/$cisloFak.pdf');
      await pdfRef.putData(
          pdfBytes, SettableMetadata(contentType: 'application/pdf'));
      String pdfUrl = await pdfRef.getDownloadURL();

      await fakturaRef.update({
        'provedene_prace': updatedPrace,
        'celkova_castka': celkovaSuma,
        'pdf_url': pdfUrl,
      });
    }
  }
}

class FakturaDetailScreen extends StatefulWidget {
  final String fakturaDocId;
  final String zakazkaId;

  const FakturaDetailScreen({
    super.key,
    required this.fakturaDocId,
    required this.zakazkaId,
  });

  @override
  State<FakturaDetailScreen> createState() => _FakturaDetailScreenState();
}

class _FakturaDetailScreenState extends State<FakturaDetailScreen> {
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "-";
    DateTime dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  void _zobrazitPdf(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Náhled dokladu')),
          body: PdfPreview(
            build: (format) async {
              final response = await http.get(Uri.parse(url));
              return response.bodyBytes;
            },
            allowSharing: true,
            allowPrinting: true,
            canChangeOrientation: false,
            canChangePageFormat: false,
            loadingWidget: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }

  Future<void> _odeslatFakturuEmailem(
      Map<String, dynamic> fData, String vychoziEmail) async {
    final String pdfUrl = fData['pdf_url']?.toString() ?? '';
    final String cisloFaktury = fData['cislo_faktury']?.toString() ?? '';

    if (pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Faktura ještě nemá vygenerované PDF.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    TextEditingController emailCtrl =
        TextEditingController(text: vychoziEmail);

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odeslat fakturu e-mailem?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Faktura bude odeslána na níže uvedený e-mail:'),
            const SizedBox(height: 15),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: 'E-mail příjemce',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.send),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ZRUŠIT'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ODESLAT',
                style: TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final finalEmail = emailCtrl.text.trim();
      if (finalEmail.isEmpty || !finalEmail.contains('@')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Zadán neplatný e-mail.'),
              backgroundColor: Colors.red));
        }
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator()),
      );

      try {
        final docNastaveni = await FirebaseFirestore.instance
            .collection('nastaveni_servisu')
            .doc(globalServisId)
            .get();
        String odesilatelJmeno =
            docNastaveni.data()?['nazev_servisu'] ?? 'Servis';
        String odesilatelEmail =
            docNastaveni.data()?['email_servisu'] ?? '';

        Map<String, dynamic> mailDoc = {
          'to': finalEmail,
          'from':
              '$odesilatelJmeno (přes Torkis) <jan.svihalek00@gmail.com>',
          'message': {
            'subject': 'Faktura $cisloFaktury ($odesilatelJmeno)',
            'html': '''
              <div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; margin: 0 auto; border: 1px solid #eee; padding: 20px; border-radius: 10px;">
                <h2 style="color: #2196F3; border-bottom: 2px solid #2196F3; padding-bottom: 10px;">Dobrý den,</h2>
                <p>v příloze Vám zasíláme fakturu <b>$cisloFaktury</b> za provedené služby a dodané zboží.</p>
                <div style="text-align: center; margin: 30px 0;">
                  <a href="$pdfUrl" style="background-color: #2196F3; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 16px; display: inline-block;">Zobrazit a stáhnout fakturu</a>
                </div>
                <p>Děkujeme za využití našich služeb. V případě jakýchkoliv dotazů na tento e-mail jednoduše odpovězte, zpráva nám bude doručena.</p>
                <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
                <p style="font-size: 12px; color: #777;">Tento e-mail byl vygenerován automaticky systémem <b>Torkis.cz</b> pro servis <b>$odesilatelJmeno</b>.</p>
              </div>
            '''
          }
        };

        if (odesilatelEmail.isNotEmpty && odesilatelEmail.contains('@')) {
          mailDoc['replyTo'] = odesilatelEmail;
        }

        await FirebaseFirestore.instance.collection('maily').add(mailDoc);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Faktura odeslána na: $finalEmail'),
                backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Chyba odeslání: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _stornovatZakazkovouFakturu(
      Map<String, dynamic> fData) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stornovat fakturu?'),
        content: const Text(
          'Faktura bude označena jako stornovaná a zakázka se znovu otevře se stavem "V řešení".\n\nProvedené práce a vydané díly zůstanou v zakázce zachovány — budete je moci upravit a zakázku znovu uzavřít.\n\nOpravdu chcete fakturu stornovat?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ZRUŠIT'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('STORNOVAT',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('faktury')
          .doc(widget.fakturaDocId)
          .update({'stav_platby': 'Stornováno'});

      if (globalServisId != null) {
        await FirebaseFirestore.instance
            .collection('zakazky')
            .doc('${globalServisId}_${widget.zakazkaId}')
            .update({
          'stav_zakazky': 'V řešení',
          'cas_ukonceni': FieldValue.delete(),
          'celkova_castka': FieldValue.delete(),
          'faktura_cislo': FieldValue.delete(),
          'vystupni_protokol_url': FieldValue.delete(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faktura stornována, zakázka znovu otevřena.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Chyba storna: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _stornovatPultovyProdej(Map<String, dynamic> fData) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stornovat prodej?'),
        content: const Text(
          'Tato akce označí fakturu jako stornovanou a automaticky vrátí všechny prodané díly zpět na sklad.\n\nOpravdu chcete prodej stornovat?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ZRUŠIT'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('STORNOVAT',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('faktury')
            .doc(widget.fakturaDocId)
            .update({
          'stav_platby': 'Stornováno',
        });

        final prace = fData['provedene_prace'] as List<dynamic>? ?? [];
        for (var p in prace) {
          final polozky = p['polozky'] as List<dynamic>? ?? [];
          for (var item in polozky) {
            final skladId = item['sklad_id'];
            if (skladId != null && skladId.toString().isNotEmpty) {
              double mnozstvi =
                  double.tryParse(item['mnozstvi'].toString()) ?? 0.0;
              if (mnozstvi > 0) {
                await FirebaseFirestore.instance
                    .collection('sklad')
                    .doc(skladId)
                    .update({
                  'skladem': FieldValue.increment(mnozstvi),
                });

                await FirebaseFirestore.instance
                    .collection('skladove_pohyby')
                    .add({
                  'servis_id': globalServisId,
                  'sklad_id': skladId,
                  'nazev_dilu': item['nazev'],
                  'typ_pohybu': 'příjem',
                  'mnozstvi': mnozstvi,
                  'poznamka':
                      'Storno faktury ${fData['cislo_faktury']}',
                  'zakazka_id': fData['cislo_faktury'],
                  'datum': FieldValue.serverTimestamp(),
                  'uzivatel_id':
                      FirebaseAuth.instance.currentUser?.uid,
                });
              }
            }
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Prodej stornován a díly vráceny na sklad.'),
                backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Chyba storna: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _deleteWork(
    BuildContext context,
    Map<String, dynamic> workItem,
    List<dynamic> vsechnyPrace,
  ) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Smazat úkon?'),
        content: const Text(
          'Opravdu chcete tuto skupinu prací z faktury odstranit? Systém následně fakturu automaticky přegeneruje.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ZRUŠIT'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SMAZAT',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator()),
      );

      try {
        vsechnyPrace.remove(workItem);
        await syncAndRegenerateFaktura(
          widget.fakturaDocId,
          widget.zakazkaId,
          vsechnyPrace,
        );
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Smazáno a přegenerováno.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Chyba: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _openEditDialog(
    BuildContext context,
    Map<String, dynamic>? existingWork,
    int? editIndex,
    List<dynamic> vsechnyPrace,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFakturaWorkScreen(
          fakturaDocId: widget.fakturaDocId,
          zakazkaId: widget.zakazkaId,
          existingWork: existingWork,
          editIndex: editIndex,
          vsechnyPrace: List.from(vsechnyPrace),
        ),
      ),
    );
  }

  Widget _buildClickableRow({
    required bool isDark,
    required String title,
    required String value,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                    Text(value,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    if (subtitle != null && subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isMechanik = globalUserRole == 'mechanik';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF1E3A5F) : Colors.white,
        title: const Text('Detail faktury',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('faktury')
            .doc(widget.fakturaDocId)
            .snapshots(),
        builder: (context, fakturaSnap) {
          if (fakturaSnap.hasError)
            return Center(
                child: Text("Chyba: ${fakturaSnap.error}"));
          if (!fakturaSnap.hasData)
            return const Center(child: CircularProgressIndicator());

          final fData =
              fakturaSnap.data!.data() as Map<String, dynamic>?;
          if (fData == null)
            return const Center(
                child: Text("Faktura nenalezena."));

          final provedenePrace =
              fData['provedene_prace'] as List<dynamic>? ?? [];
          final stavPlatby = fData['stav_platby'] ?? 'Neznámý';
          final jeUhrazeno = stavPlatby == 'Uhrazeno';
          final jeStornovano = stavPlatby == 'Stornováno';

          final bool isManual =
              fData['cislo_zakazky'] == 'PRODEJ' ||
                  fData['cislo_zakazky'] == 'PULTOVÝ PRODEJ';

          return FutureBuilder<DocumentSnapshot?>(
            future: isManual || globalServisId == null
                ? Future<DocumentSnapshot?>.value(null)
                : FirebaseFirestore.instance
                    .collection('zakazky')
                    .doc('${globalServisId}_${widget.zakazkaId}')
                    .get(),
            builder: (context, zakazkaSnap) {
              Map<String, dynamic> zakData = {};
              if (zakazkaSnap.hasData &&
                  zakazkaSnap.data != null &&
                  zakazkaSnap.data!.exists) {
                zakData = zakazkaSnap.data!.data()
                    as Map<String, dynamic>;
              }

              final pZakaznik = isManual
                  ? (fData['zakaznik'] as Map<String, dynamic>? ?? {})
                  : (zakData['zakaznik']
                          as Map<String, dynamic>? ??
                      {});
              final telefon = pZakaznik['telefon'] ?? '';
              final email = pZakaznik['email'] ?? '';
              final znacka = zakData['znacka'] ?? '';
              final model = zakData['model'] ?? '';
              final stavVozidla = zakData['stav_vozidla']
                      as Map<String, dynamic>? ??
                  {};
              final tachometr = stavVozidla['tachometr'] ?? '';

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: isDark
                        ? const Color(0xFF1E3A5F)
                        : Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${fData['cislo_faktury']}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  decoration: jeStornovano
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: jeStornovano
                                      ? Colors.grey
                                      : null,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                      Icons.email_outlined,
                                      color: Colors.blue),
                                  tooltip:
                                      'Odeslat na e-mail zákazníka',
                                  onPressed: () =>
                                      _odeslatFakturuEmailem(
                                          fData, email),
                                ),
                                const SizedBox(width: 5),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (fData['pdf_url'] != null &&
                                        fData['pdf_url']
                                            .toString()
                                            .isNotEmpty) {
                                      _zobrazitPdf(
                                          context, fData['pdf_url']);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'PDF zatím není k dispozici.'),
                                        ),
                                      );
                                    }
                                  },
                                  icon:
                                      const Icon(Icons.picture_as_pdf),
                                  label: const Text('PDF'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _buildClickableRow(
                                    isDark: isDark,
                                    title: 'Zákazník',
                                    value:
                                        '${fData['zakaznik_jmeno']}',
                                    subtitle: (telefon.isNotEmpty ||
                                            email.isNotEmpty)
                                        ? '$telefon \n$email'
                                        : null,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ZakaznikDetailScreen(
                                            zakaznikData: pZakaznik,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  if (!isManual)
                                    const SizedBox(height: 5),
                                  if (!isManual)
                                    _buildClickableRow(
                                      isDark: isDark,
                                      title: 'Vozidlo',
                                      value: '${fData['spz']}',
                                      subtitle: (znacka.isNotEmpty
                                              ? '$znacka $model\n'
                                              : '') +
                                          (tachometr
                                                  .toString()
                                                  .isNotEmpty
                                              ? 'Najeto: $tachometr km'
                                              : ''),
                                      onTap: () {
                                        final vozidloDocId =
                                            '${globalServisId}_${fData['spz']}';
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                VozidloDetailScreen(
                                              vozidloDocId: vozidloDocId,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  if (!isManual)
                                    const SizedBox(height: 5),
                                  if (!isManual)
                                    _buildClickableRow(
                                      isDark: isDark,
                                      title: 'Zakázce',
                                      value:
                                          '${fData['cislo_zakazky']}',
                                      onTap: () {
                                        final docId =
                                            '${globalServisId}_${widget.zakazkaId}';
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ActiveJobScreen(
                                              documentId: docId,
                                              zakazkaId: widget.zakazkaId,
                                              spz: fData['spz'] ?? '',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E3A5F)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text('Celková částka',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12)),
                                    Text(
                                      '${(fData['celkova_castka'] ?? 0.0).toStringAsFixed(2)} Kč',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: jeStornovano
                                            ? Colors.grey
                                            : Colors.blue[800],
                                        decoration: jeStornovano
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    const Text('Stav úhrady',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12)),
                                    Text(
                                      stavPlatby,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: jeStornovano
                                            ? Colors.redAccent
                                            : (jeUhrazeno
                                                ? Colors.green
                                                : Colors.orange),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    const Text(
                                        'Vystaveno / Splatnost',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_formatDate(fData['datum_vystaveni'])} \n${_formatDate(fData['datum_splatnosti'])}',
                                      style: const TextStyle(
                                          fontSize: 13, height: 1.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const Text('Rozpis položek dokladu:',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        if (provedenePrace.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(30),
                              child: Text(
                                  'Faktura neobsahuje žádné položky.',
                                  style:
                                      TextStyle(color: Colors.grey)),
                            ),
                          )
                        else
                          ...List.generate(provedenePrace.length,
                              (index) {
                            final prace = provedenePrace[index];

                            List<dynamic> polozky = List.from(
                                prace['polozky']
                                        as List<dynamic>? ??
                                    []);

                            if (polozky.isEmpty) {
                              if ((prace['cena_s_dph'] ?? 0) > 0) {
                                polozky.add({
                                  'typ': 'Práce',
                                  'nazev': 'Práce',
                                  'cislo': '',
                                  'mnozstvi':
                                      prace['delka_prace'] ?? 1,
                                  'jednotka': 'h',
                                  'cena_s_dph': prace['cena_s_dph'],
                                });
                              }
                              for (var d in (prace['pouzite_dily']
                                      as List<dynamic>? ??
                                  [])) {
                                polozky.add({
                                  'typ': 'Materiál',
                                  'nazev': d['nazev'],
                                  'cislo': d['cislo'] ?? '',
                                  'mnozstvi': d['pocet'] ?? 1,
                                  'jednotka': 'ks',
                                  'cena_s_dph': d['cena_s_dph'],
                                });
                              }
                            }

                            double celkemUkon = 0.0;
                            for (var p in polozky) {
                              double pMnoz = double.tryParse(
                                      p['mnozstvi'].toString()) ??
                                  1.0;
                              double pCena = double.tryParse(
                                      p['cena_s_dph'].toString()) ??
                                  0.0;
                              double pSleva = double.tryParse(
                                      p['sleva']?.toString() ??
                                          '0') ??
                                  0.0;
                              celkemUkon += (pMnoz * pCena) *
                                  (1 - (pSleva / 100));
                            }

                            return Card(
                              margin:
                                  const EdgeInsets.only(bottom: 15),
                              color: isDark
                                  ? const Color(0xFF1E3A5F)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${prace['nazev']} (${celkemUkon.toStringAsFixed(2)} Kč)',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (!isManual && !jeStornovano)
                                          IconButton(
                                            onPressed: () =>
                                                _openEditDialog(
                                              context,
                                              prace,
                                              index,
                                              provedenePrace,
                                            ),
                                            icon: const Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                                size: 20),
                                            constraints:
                                                const BoxConstraints(),
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10),
                                          ),
                                        if (!isManual && !jeStornovano)
                                          IconButton(
                                            onPressed: () =>
                                                _deleteWork(
                                              context,
                                              prace,
                                              List.from(provedenePrace),
                                            ),
                                            icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 20),
                                            constraints:
                                                const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ...polozky.map((p) {
                                      double pMnoz = double.tryParse(
                                              p['mnozstvi']
                                                  .toString()) ??
                                          1.0;
                                      double pCena = double.tryParse(
                                              p['cena_s_dph']
                                                  .toString()) ??
                                          0.0;
                                      double pSleva = double.tryParse(
                                              p['sleva']?.toString() ??
                                                  '0') ??
                                          0.0;
                                      String pJedn =
                                          p['jednotka'] ?? 'ks';
                                      String cistyMnoz = pMnoz
                                          .toString()
                                          .replaceAll(
                                              RegExp(
                                                  r"([.]*0)(?!.*\d)"),
                                              "");
                                      String slevaStr = pSleva > 0
                                          ? ' (-${pSleva.toStringAsFixed(0)}%)'
                                          : '';
                                      String cNum =
                                          p['cislo']?.toString() ?? '';
                                      String nDisp =
                                          cNum.trim().isNotEmpty
                                              ? '${p['nazev']} ($cNum)'
                                              : p['nazev'];

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4, left: 10),
                                        child: Text(
                                          '• [${p['typ']}] $nDisp - $cistyMnoz $pJedn$slevaStr - ${(pMnoz * pCena * (1 - pSleva / 100)).toStringAsFixed(2)} Kč',
                                          style: const TextStyle(
                                              fontSize: 13),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  if (!isManual && !jeStornovano)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E3A5F)
                            : Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 10,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _openEditDialog(
                                    context, null, null, provedenePrace),
                                icon: const Icon(Icons.add),
                                label: const Text(
                                    'PŘIDAT ÚKON DO FAKTURY',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15)),
                                ),
                              ),
                            ),
                            if (!isMechanik) ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _stornovatZakazkovouFakturu(fData),
                                  icon: const Icon(
                                      Icons.settings_backup_restore,
                                      color: Colors.red),
                                  label: const Text('STORNOVAT FAKTURU',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Colors.red, width: 1.5),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  if (isManual && !jeStornovano && !isMechanik)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E3A5F)
                            : Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 10,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _stornovatPultovyProdej(fData),
                            icon: const Icon(
                                Icons.settings_backup_restore),
                            label: const Text(
                                'STORNOVAT FAKTURU A VRÁTIT DÍLY',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[50],
                              foregroundColor: Colors.red,
                              side: const BorderSide(
                                  color: Colors.red, width: 2),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(15)),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
