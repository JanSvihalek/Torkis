import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:printing/printing.dart';
import '../../core/constants.dart';
import '../../core/pdf_generator.dart';
import '../auth_gate.dart';
import 'prubeh_add_work.dart';
import 'prubeh_tab_otevreno.dart';
import 'prubeh_tab_ukoncene.dart';
import 'prubeh_detail_zakaznik_vozidlo.dart';
import 'prubeh_detail_prehled.dart';
import 'prubeh_detail_akce.dart';

// Modul průběhu zakázek — skládá se ze čtyř obrazovek:
//
// [ServiceProgressPage]  – seznam aktivních zakázek (search + StreamBuilder karet)
// [ActiveJobScreen]      – detail zakázky: záložky Přehled / Cenová nabídka /
//                          Foto / Zákazník / Vozidlo + akce Dokončit / Storno
// [AddWorkScreen]        – dialog pro záznam provedené práce (úkon + díly + foto)
// [FotodokumentaceScreen]– fullscreen galerie fotek přiložených k zakázce

class ServiceProgressPage extends StatefulWidget {
  const ServiceProgressPage({super.key});
  @override
  State<ServiceProgressPage> createState() => _ServiceProgressPageState();
}

class _ServiceProgressPageState extends State<ServiceProgressPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchOpen = '';
  String _searchClosed = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToJob(
      BuildContext context, String docId, String cisloZakazky, String spz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveJobScreen(
          documentId: docId,
          zakazkaId: cisloZakazky,
          spz: spz,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (globalServisId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Zakázky',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TabBar(
                controller: _tabController,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                unselectedLabelStyle: const TextStyle(fontSize: 15),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Otevřené'),
                  Tab(text: 'Ukončené'),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              OtevrenTab(
                isDark: isDark,
                searchOpen: _searchOpen,
                onSearchChanged: (v) =>
                    setState(() => _searchOpen = v.toLowerCase()),
                onTapZakazka: (docId, cislo, spz) =>
                    _navigateToJob(context, docId, cislo, spz),
              ),
              UkonceneTab(
                isDark: isDark,
                searchClosed: _searchClosed,
                onSearchChanged: (v) =>
                    setState(() => _searchClosed = v.toLowerCase()),
                onTapZakazka: (docId, cislo, spz) =>
                    _navigateToJob(context, docId, cislo, spz),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ActiveJobScreen extends StatefulWidget {
  final String documentId;
  final String zakazkaId;
  final String spz;

  const ActiveJobScreen({
    super.key,
    required this.documentId,
    required this.zakazkaId,
    required this.spz,
  });

  @override
  State<ActiveJobScreen> createState() => _ActiveJobScreenState();
}

class _ActiveJobScreenState extends State<ActiveJobScreen> {
  int _vychoziSplatnost = 14;
  String _zpusobUhrady = 'Převodem';
  String _zakaznikJmeno = '';
  String _zakaznikEmail = '';

  @override
  void initState() {
    super.initState();
    _nactiNastaveni();
  }

  Future<void> _nactiNastaveni() async {
    if (globalServisId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('nastaveni_servisu')
          .doc(globalServisId)
          .get();
      if (doc.exists) {
        setState(() {
          _vychoziSplatnost = doc.data()?['splatnost_dny'] ?? 14;
          _zpusobUhrady = doc.data()?['zpusob_uhrady'] ?? 'Převodem';
        });
      }
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "Zpracovává se...";
    DateTime dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  void _openAddWorkDialog(
    BuildContext context, {
    String? initialTitle,
    Map<String, dynamic>? existingWork,
    int? editIndex,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddWorkScreen(
          documentId: widget.documentId,
          zakazkaId: widget.zakazkaId,
          initialTitle: initialTitle,
          existingWork: existingWork,
          editIndex: editIndex,
        ),
      ),
    );
  }

  /// Smaže jeden řádek z pole 'pozadavky_zakaznika' v dokumentu zakázky.
  Future<void> _deletePozadavek(BuildContext context, String pozadavek) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Smazat požadavek?'),
        content: const Text(
          'Opravdu chcete tento požadavek zákazníka trvale odstranit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ZRUŠIT'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SMAZAT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('zakazky')
          .doc(widget.documentId)
          .update({
        'pozadavky_zakaznika': FieldValue.arrayRemove([pozadavek]),
      });
    }
  }

  /// Vrátí všechny díly ze seznamu provedených prací zpět na sklad.
  Future<void> _vratDilyNaSklad(
    List<dynamic> provedenePrace,
    String popis,
  ) async {
    for (var prace in provedenePrace) {
      final polozky = prace['polozky'] as List<dynamic>? ?? [];
      for (var item in polozky) {
        final skladId = item['sklad_id']?.toString() ?? '';
        if (skladId.isEmpty) continue;
        final double mnozstvi =
            double.tryParse(item['mnozstvi'].toString()) ?? 0.0;
        if (mnozstvi <= 0) continue;
        await FirebaseFirestore.instance
            .collection('sklad')
            .doc(skladId)
            .update({'skladem': FieldValue.increment(mnozstvi)});
        await FirebaseFirestore.instance
            .collection('skladove_pohyby')
            .add({
          'servis_id': globalServisId,
          'sklad_id': skladId,
          'nazev_dilu': item['nazev'],
          'typ_pohybu': 'příjem',
          'mnozstvi': mnozstvi,
          'poznamka': popis,
          'zakazka_id': widget.zakazkaId,
          'datum': FieldValue.serverTimestamp(),
          'uzivatel_id': FirebaseAuth.instance.currentUser?.uid,
        });
      }
    }
  }

  /// Odstraní záznam provedené práce ze zakázky a přegeneruje PDF cenové nabídky.
  Future<void> _deleteWork(
    BuildContext context,
    Map<String, dynamic> workItem,
  ) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Smazat úkon?'),
        content: const Text(
          'Opravdu chcete tento záznam o práci odstranit? Tato akce je nevratná.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ZRUŠIT'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SMAZAT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _vratDilyNaSklad(
        [workItem],
        'Odebrání položky ze zakázky ${widget.zakazkaId}',
      );
      await FirebaseFirestore.instance
          .collection('zakazky')
          .doc(widget.documentId)
          .update({
        'provedene_prace': FieldValue.arrayRemove([workItem]),
      });
    }
  }

  /// Vygeneruje PDF cenové nabídky a odešle ji zákazníkovi na e-mail.
  /// Zobrazí dialog pro potvrzení / úpravu e-mailové adresy před odesláním.
  Future<void> _odeslatKNaceneni(
      BuildContext context, Map<String, dynamic> data) async {
    final zakaznik = data['zakaznik'] as Map<String, dynamic>? ?? {};
    final emailCtrl =
        TextEditingController(text: zakaznik['email']?.toString() ?? '');

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generovat nacenění',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
                'Aplikace vygeneruje PDF s cenovou nabídkou a odešle ji zákazníkovi.'),
            const SizedBox(height: 15),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'E-mail zákazníka',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zrušit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Odeslat',
                style: TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    final finalEmail = emailCtrl.text.trim();
    emailCtrl.dispose();

    if (confirm == true && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator()),
      );

      try {
        if (globalServisId == null) return;

        String sNazev = 'Servis';
        String sIco = '';
        String sEmail = '';

        final docNast = await FirebaseFirestore.instance
            .collection('nastaveni_servisu')
            .doc(globalServisId)
            .get();
        if (docNast.exists) {
          sNazev = docNast.data()?['nazev_servisu'] ?? 'Servis';
          sIco = docNast.data()?['ico_servisu'] ?? '';
          sEmail = docNast.data()?['email_servisu'] ?? '';
        }

        final zakaznikEmail = finalEmail;

        final pdfBytes = await GlobalPdfGenerator.generateDocument(
          data: data,
          servisNazev: sNazev,
          servisIco: sIco,
          typ: PdfTyp.naceneni,
        );

        String fileName = 'naceneni_${widget.zakazkaId}.pdf';
        Reference ref = FirebaseStorage.instance.ref().child(
            'servisy/$globalServisId/zakazky/${widget.zakazkaId}/$fileName');
        await ref.putData(
            pdfBytes, SettableMetadata(contentType: 'application/pdf'));
        String downloadUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('zakazky')
            .doc(widget.documentId)
            .update({
          'stav_zakazky': 'K nacenění',
          'nabidka_url': downloadUrl,
        });

        if (context.mounted) {
          Navigator.pop(context);

          if (zakaznikEmail.isNotEmpty && zakaznikEmail.contains('@')) {
            Map<String, dynamic> mailDoc = {
              'to': zakaznikEmail,
              'from': '$sNazev (přes TORKIS) <jan.svihalek00@gmail.com>',
              'message': {
                'subject':
                    'Cenová nabídka - Zakázka ${widget.zakazkaId} ($sNazev)',
                'html': '''
                  <div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; margin: 0 auto; border: 1px solid #eee; padding: 20px; border-radius: 10px;">
                    <h2 style="color: #2196F3; border-bottom: 2px solid #2196F3; padding-bottom: 10px;">Dobrý den,</h2>
                    <p>zasíláme Vám cenovou nabídku k nahlédnutí pro Vaši zakázku <b>${widget.zakazkaId}</b> v servisu $sNazev.</p>
                    <p>Celý dokument si můžete prohlédnout zde:</p>
                    <div style="text-align: center; margin: 30px 0;">
                      <a href="$downloadUrl" style="background-color: #2196F3; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 16px; display: inline-block;">Zobrazit nacenění (PDF)</a>
                    </div>
                    <p>Prosíme o informaci, zda s rozpočtem souhlasíte, abychom mohli začít pracovat.</p>
                    <br>
                    <p>S pozdravem,<br><b>$sNazev</b></p>
                  </div>
                '''
              }
            };

            if (sEmail.isNotEmpty && sEmail.contains('@')) {
              mailDoc['replyTo'] = sEmail;
            }

            await FirebaseFirestore.instance.collection('maily').add(mailDoc);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Nacenění odesláno na: $zakaznikEmail'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Zákazník nemá e-mail. Nacenění uloženo, nyní ho můžete sdílet.'),
                backgroundColor: Colors.orange,
              ),
            );
            await Printing.sharePdf(
                bytes: pdfBytes,
                filename: 'Naceneni_${widget.zakazkaId}.pdf');
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Chyba: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  /// Nastaví stav zakázky na 'Stornováno' – zakázka zmizí z aktivního seznamu,
  /// ale zůstane v historii (není fyzicky smazána).
  Future<void> _stornovatZakazku(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stornovat a znovu otevřít?'),
        content: const Text(
          'Tato akce označí původní fakturu jako "Stornováno" (dobropis) a vrátí zakázku do stavu "Přijato". Zakázku tak budete moci znovu upravovat a posléze vygenerovat novou fakturu.\n\nOpravdu chcete zakázku odemknout?',
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
      if (globalServisId != null) {
        try {
          final zakazkaSnap = await FirebaseFirestore.instance
              .collection('zakazky')
              .doc(widget.documentId)
              .get();

          final snapData = zakazkaSnap.data() ?? {};
          String fakturaCislo = snapData['faktura_cislo'] ?? '';
          String rezervaceId = snapData['rezervace_id'] ?? '';

          final provedenePrace =
              snapData['provedene_prace'] as List<dynamic>? ?? [];
          await _vratDilyNaSklad(
            provedenePrace,
            'Storno zakázky ${widget.zakazkaId}',
          );

          if (fakturaCislo.isNotEmpty) {
            final fakturaRef = FirebaseFirestore.instance
                .collection('faktury')
                .doc('${globalServisId}_$fakturaCislo');
            final fakturaDoc = await fakturaRef.get();

            if (fakturaDoc.exists) {
              await fakturaRef.update({'stav_platby': 'Stornováno'});
            }
          }

          await FirebaseFirestore.instance
              .collection('zakazky')
              .doc(widget.documentId)
              .update({
            'stav_zakazky': 'Přijato',
            'zpusob_ukonceni': FieldValue.delete(),
            'forma_uhrady': FieldValue.delete(),
            'splatnost_dny': FieldValue.delete(),
            'cas_ukonceni': FieldValue.delete(),
            'faktura_cislo': FieldValue.delete(),
          });

          if (rezervaceId.isNotEmpty) {
            await FirebaseFirestore.instance
                .collection('planovac')
                .doc(rezervaceId)
                .update({'stav': 'Přijato na servis'});
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Faktura stornována a zakázka znovu otevřena.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Chyba při stornování: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  /// Přepne stav zakázky (např. „Přijato" → „V opravě" → „Čeká na díly").
  Future<void> _zmenitStav(BuildContext context, String novyStav) async {
    await FirebaseFirestore.instance
        .collection('zakazky')
        .doc(widget.documentId)
        .update({'stav_zakazky': novyStav});
  }

  void _ukoncitZakazkuDialog(
    BuildContext context,
    Map<String, dynamic> data,
    Map<String, dynamic> stav,
    Map<String, dynamic> zakaznik,
    Map<String, dynamic> imageUrls,
  ) {
    final List<String> moznostiPlatby = ['Převodem', 'Hotově', 'Kartou'];
    String vybranaPlatba = moznostiPlatby.contains(_zpusobUhrady)
        ? _zpusobUhrady
        : moznostiPlatby[0];
    final splatnostController =
        TextEditingController(text: _vychoziSplatnost.toString());
    bool isFinishing = false;

    String emailZakaznika = zakaznik['email']?.toString() ?? '';
    bool odeslatEmail =
        emailZakaznika.isNotEmpty && emailZakaznika.contains('@');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Ukončení a vyúčtování',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isFinishing)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 15),
                          Text(
                            'Zpracovávám...',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  const Text(
                    'Způsob úhrady:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.5)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: vybranaPlatba,
                        isExpanded: true,
                        items: moznostiPlatby
                            .map((p) => DropdownMenuItem<String>(
                                value: p, child: Text(p)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              vybranaPlatba = val;
                              if (val == 'Hotově' || val == 'Kartou') {
                                splatnostController.text = '0';
                              } else {
                                splatnostController.text =
                                    _vychoziSplatnost.toString();
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Splatnost faktury (ve dnech):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: splatnostController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 15),
                  CheckboxListTile(
                    title: const Text('Odeslat fakturu zákazníkovi na e-mail',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: emailZakaznika.isEmpty
                        ? const Text('Zákazník nemá vyplněný e-mail',
                            style: TextStyle(
                                color: Colors.red, fontSize: 12))
                        : Text(emailZakaznika,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                    value: odeslatEmail,
                    activeColor: Colors.blue,
                    onChanged: emailZakaznika.isEmpty
                        ? null
                        : (bool? value) {
                            setDialogState(() {
                              odeslatEmail = value ?? false;
                            });
                          },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Zakázka se přesune do Historie. Vygeneruje se PDF vyúčtování.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () async {
                      setDialogState(() => isFinishing = true);
                      int customSplatnost =
                          int.tryParse(splatnostController.text) ?? 14;
                      await _zpracovatUkonceni(
                        context,
                        'faktura',
                        vybranaPlatba,
                        customSplatnost,
                        data,
                        stav,
                        zakaznik,
                        imageUrls,
                        odeslatEmail: odeslatEmail,
                      );
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Dokončit a předat k platbě'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () async {
                      setDialogState(() => isFinishing = true);
                      await _zpracovatUkonceni(
                        context,
                        'zruseno',
                        '',
                        0,
                        data,
                        stav,
                        zakaznik,
                        imageUrls,
                        zruseno: true,
                        odeslatEmail: false,
                      );
                    },
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text(
                      'Nerealizuje se (Zrušit)',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (!isFinishing)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ZPĚT'),
              ),
          ],
        ),
      ),
    );
  }

  /// Ukončí zakázku: vygeneruje finální fakturu (PDF), uloží ji do Storage,
  /// vytvoří dokument v kolekci 'faktury', aktualizuje záznam vozidla (tachometr, STK)
  /// a přesune zakázku do stavu 'Dokončeno'.
  Future<void> _zpracovatUkonceni(
    BuildContext context,
    String zpusob,
    String platba,
    int splatnostDny,
    Map<String, dynamic> data,
    Map<String, dynamic> stav,
    Map<String, dynamic> zakaznik,
    Map<String, dynamic> imageUrls, {
    bool zruseno = false,
    bool odeslatEmail = false,
  }) async {
    if (globalServisId == null) return;

    try {
      String pdfUrl = '';
      double celkovaSuma = 0.0;

      final provedenePrace = data['provedene_prace'] as List<dynamic>? ?? [];
      for (var prace in provedenePrace) {
        final polozky = prace['polozky'] as List<dynamic>?;
        if (polozky != null) {
          for (var p in polozky) {
            double mnoz = double.tryParse(p['mnozstvi'].toString()) ?? 1.0;
            double cena = double.tryParse(p['cena_s_dph'].toString()) ?? 0.0;
            double sleva = double.tryParse(p['sleva'].toString()) ?? 0.0;
            celkovaSuma += (mnoz * cena) * (1 - (sleva / 100));
          }
        } else {
          celkovaSuma += (prace['cena_s_dph'] ?? 0.0).toDouble();
          final dily = prace['pouzite_dily'] as List<dynamic>? ?? [];
          for (var dil in dily) {
            double p = (double.tryParse(dil['pocet'].toString()) ?? 1.0);
            double c =
                (double.tryParse(dil['cena_s_dph'].toString()) ?? 0.0);
            celkovaSuma += (p * c);
          }
        }
      }

      String odesilatelJmeno = 'Servis';
      String odesilatelIco = '';
      String odesilatelEmail = '';
      String prefix = 'FAK';

      if (!zruseno) {
        final docNastaveni = await FirebaseFirestore.instance
            .collection('nastaveni_servisu')
            .doc(globalServisId)
            .get();
        if (docNastaveni.exists) {
          odesilatelJmeno =
              docNastaveni.data()?['nazev_servisu'] ?? 'Servis';
          odesilatelIco = docNastaveni.data()?['ico_servisu'] ?? '';
          odesilatelEmail = docNastaveni.data()?['email_servisu'] ?? '';
          prefix = docNastaveni.data()?['prefix_faktury'] ?? 'FAK';
        }

        data['splatnost_dny'] = splatnostDny;

        final pdfBytes = await GlobalPdfGenerator.generateDocument(
          data: data,
          servisNazev: odesilatelJmeno,
          servisIco: odesilatelIco,
          typ: PdfTyp.faktura,
        );

        Reference pdfRef = FirebaseStorage.instance.ref().child(
              'servisy/$globalServisId/zakazky/${widget.zakazkaId}/finalni_vyuctovani_${widget.zakazkaId}.pdf',
            );
        await pdfRef.putData(
          pdfBytes,
          SettableMetadata(contentType: 'application/pdf'),
        );
        pdfUrl = await pdfRef.getDownloadURL();
      }

      String cisloFaktury = '';

      if (zpusob == 'faktura') {
        final ted = DateTime.now();

        String yearPart = DateFormat('yyyy').format(ted);
        String monthPart = DateFormat('MM').format(ted);

        // Čítač v databázi zůstává roční
        final counterRef = FirebaseFirestore.instance
            .collection('citace_faktur')
            .doc('${globalServisId}_rok_$yearPart');

        cisloFaktury = await FirebaseFirestore.instance
            .runTransaction((transaction) async {
          final snapshot = await transaction.get(counterRef);
          int currentCount = 1;
          if (snapshot.exists) {
            currentCount = (snapshot.data()?['pocet'] ?? 0) + 1;
          }
          transaction.set(
              counterRef, {'pocet': currentCount}, SetOptions(merge: true));

          // Formátování bez pomlček: PREFIX + ROK + MĚSÍC + INKREMENT (např. FAK20260400001)
          String sequencePart = currentCount.toString().padLeft(5, '0');
          return '$prefix$yearPart$monthPart$sequencePart';
        });

        DateTime splatnost = ted.add(Duration(days: splatnostDny));

        String stavPlatby =
            (celkovaSuma <= 0 || platba == 'Hotově' || platba == 'Kartou')
                ? 'Uhrazeno'
                : 'Čeká na platbu';

        await FirebaseFirestore.instance
            .collection('faktury')
            .doc('${globalServisId}_$cisloFaktury')
            .set({
          'servis_id': globalServisId,
          'cislo_faktury': cisloFaktury,
          'cislo_zakazky': widget.zakazkaId,
          'spz': widget.spz,
          'zakaznik_id': zakaznik['id_zakaznika'] ?? '',
          'zakaznik_jmeno': zakaznik['jmeno'] ?? 'Neznámý zákazník',
          'datum_vystaveni': Timestamp.fromDate(ted),
          'datum_splatnosti': Timestamp.fromDate(splatnost),
          'forma_uhrady': platba,
          'celkova_castka': celkovaSuma,
          'stav_platby': stavPlatby,
          'pdf_url': pdfUrl,
          'provedene_prace': data['provedene_prace'] ?? [],
          'vytvoreno': FieldValue.serverTimestamp(),
        });

        if (odeslatEmail) {
          String zakaznikEmail = zakaznik['email']?.toString() ?? '';
          if (zakaznikEmail.isNotEmpty && zakaznikEmail.contains('@')) {
            Map<String, dynamic> mailDoc = {
              'to': zakaznikEmail,
              'from':
                  '$odesilatelJmeno (přes TORKIS) <jan.svihalek00@gmail.com>',
              'message': {
                'subject':
                    'Faktura - Zakázka ${widget.zakazkaId} ($odesilatelJmeno)',
                'html': '''
                  <div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; margin: 0 auto; border: 1px solid #eee; padding: 20px; border-radius: 10px;">
                    <h2 style="color: #2196F3; border-bottom: 2px solid #2196F3; padding-bottom: 10px;">Dobrý den,</h2>
                    <p>v příloze Vám zasíláme fakturu za provedené servisní práce na Vašem vozidle <b>${data['spz']}</b> v našem servisu.</p>
                    <div style="text-align: center; margin: 30px 0;">
                      <a href="$pdfUrl" style="background-color: #2196F3; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 16px; display: inline-block;">Zobrazit a stáhnout fakturu</a>
                    </div>
                    <p>Děkujeme za využití našich služeb. V případě jakýchkoliv dotazů na tento e-mail jednoduše odpovězte, zpráva nám bude doručena.</p>
                    <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
                    <p style="font-size: 12px; color: #777;">Tento e-mail byl vygenerován automaticky systémem <b>TORKIS.cz</b> pro servis <b>$odesilatelJmeno</b>.</p>
                  </div>
                '''
              }
            };

            if (odesilatelEmail.isNotEmpty && odesilatelEmail.contains('@')) {
              mailDoc['replyTo'] = odesilatelEmail;
            }

            await FirebaseFirestore.instance
                .collection('maily')
                .add(mailDoc);
          }
        }
      }

      await FirebaseFirestore.instance
          .collection('zakazky')
          .doc(widget.documentId)
          .update({
        'stav_zakazky': 'Dokončeno',
        'zpusob_ukonceni': zpusob,
        'forma_uhrady': platba,
        'splatnost_dny': splatnostDny,
        'celkova_castka': celkovaSuma,
        'cas_ukonceni': FieldValue.serverTimestamp(),
        if (cisloFaktury.isNotEmpty) 'faktura_cislo': cisloFaktury,
        if (pdfUrl.isNotEmpty) 'vystupni_protokol_url': pdfUrl,
      });

      // Aktualizace stavu v plánovači
      String rezervaceId = data['rezervace_id']?.toString() ?? '';
      if (rezervaceId.isNotEmpty) {
        try {
          await FirebaseFirestore.instance
              .collection('planovac')
              .doc(rezervaceId)
              .update({'stav': 'Dokončeno'});
        } catch (e) {
          debugPrint("Chyba při updatování plánovače na Dokončeno: $e");
        }
      }

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(odeslatEmail && !zruseno
                ? 'Zakázka ukončena a faktura odeslána.'
                : 'Zakázka úspěšně ukončena.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Chyba ukončení: $e");
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba při ukončování: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isMechanik = globalUserRole == 'mechanik';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 1,
        title: Text(
          'Oprava: ${widget.zakazkaId} (${widget.spz})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('zakazky')
            .doc(widget.documentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Chyba: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return const Center(child: Text("Dokument nenalezen."));
          }

          final provedenePrace =
              data['provedene_prace'] as List<dynamic>? ?? [];
          final pozadavky =
              data['pozadavky_zakaznika'] as List<dynamic>? ?? [];
          final aktualniStav = data['stav_zakazky'] ?? 'Přijato';
          final stav = data['stav_vozidla'] as Map<String, dynamic>? ?? {};
          final zakaznik =
              data['zakaznik'] as Map<String, dynamic>? ?? {};
          _zakaznikJmeno = zakaznik['jmeno']?.toString() ?? '';
          _zakaznikEmail = zakaznik['email']?.toString() ?? '';

          final rawUrls = data['fotografie_urls'];
          final Map<String, dynamic> imageUrlsByCategoryRaw = {};
          if (rawUrls is Map) {
            imageUrlsByCategoryRaw
                .addAll(Map<String, dynamic>.from(rawUrls));
          } else if (rawUrls is List) {
            imageUrlsByCategoryRaw['ostatni'] = rawUrls;
          }

          List<String> prijemFotky = [];
          for (var val in imageUrlsByCategoryRaw.values) {
            if (val is List) {
              prijemFotky.addAll(val.map((e) => e.toString()));
            } else if (val is String) {
              prijemFotky.add(val);
            }
          }

          final bool isCompleted = aktualniStav == 'Dokončeno';

          List<String> dostupneStavy =
              stavyZakazky.where((s) => s != 'Dokončeno').toList();
          if (!dostupneStavy.contains(aktualniStav) && !isCompleted) {
            dostupneStavy.add(aktualniStav);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Stav zakázky (dropdown / badge) --
              Container(
                width: double.infinity,
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 15),
                child: Row(
                  children: [
                    const Text(
                      'Stav: ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: getStatusColor(aktualniStav)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: isCompleted
                            ? Text(
                                'Dokončeno (Uzamčeno)',
                                style: TextStyle(
                                  color: getStatusColor(aktualniStav),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              )
                            : DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: aktualniStav,
                                  isExpanded: true,
                                  dropdownColor: isDark
                                      ? const Color(0xFF2C2C2C)
                                      : Colors.white,
                                  items: dostupneStavy
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(
                                            s,
                                            style: TextStyle(
                                              color: getStatusColor(s),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (novyStav) {
                                    if (novyStav != null) {
                                      _zmenitStav(context, novyStav);
                                    }
                                  },
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // -- Scrollovatelný obsah --
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    ZakaznikVozidloCard(
                      isDark: isDark,
                      data: data,
                      zakaznik: zakaznik,
                      formattedPrijeti: _formatDate(data['cas_prijeti']),
                      prijemFotky: prijemFotky,
                    ),
                    PrehledPraci(
                      isDark: isDark,
                      isCompleted: isCompleted,
                      isMechanik: isMechanik,
                      provedenePrace: provedenePrace,
                      pozadavky: pozadavky,
                      onAddWork: ({initialTitle, existingWork, editIndex}) =>
                          _openAddWorkDialog(
                        context,
                        initialTitle: initialTitle,
                        existingWork: existingWork,
                        editIndex: editIndex,
                      ),
                      onDeletePozadavek: (p) =>
                          _deletePozadavek(context, p),
                      onDeleteWork: (w) => _deleteWork(context, w),
                      formatDate: _formatDate,
                    ),
                  ],
                ),
              ),
              // -- Spodní lišta akcí --
              AkceLista(
                isDark: isDark,
                isCompleted: isCompleted,
                isMechanik: isMechanik,
                data: data,
                stav: stav,
                zakaznik: zakaznik,
                imageUrls: imageUrlsByCategoryRaw,
                documentId: widget.documentId,
                zakazkaId: widget.zakazkaId,
                spz: widget.spz,
                zakaznikJmeno: _zakaznikJmeno,
                zakaznikEmail: _zakaznikEmail,
                onPridatUkon: () => _openAddWorkDialog(context),
                onUkoncit: () => _ukoncitZakazkuDialog(
                    context, data, stav, zakaznik, imageUrlsByCategoryRaw),
                onNaceneni: () => _odeslatKNaceneni(context, data),
                onStornovat: () => _stornovatZakazku(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
