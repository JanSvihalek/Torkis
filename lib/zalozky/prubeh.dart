import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import '../core/constants.dart';
import '../core/pdf_generator.dart';

import 'zakaznici.dart';
import 'vozidla.dart';

class ServiceProgressPage extends StatefulWidget {
  const ServiceProgressPage({super.key});
  @override
  State<ServiceProgressPage> createState() => _ServiceProgressPageState();
}

class _ServiceProgressPageState extends State<ServiceProgressPage> {
  String _searchQuery = '';

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "Zpracovává se...";
    DateTime dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Center(child: Text("Nejste přihlášeni."));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Zakázky',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Aktivní zakázky v řešení.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    if (!isDark)
                      const BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 10,
                          offset: Offset(0, 4)),
                  ],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Hledat SPZ, VIN nebo číslo...',
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('zakazky')
                .where('servis_id', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Center(child: Text("Chyba databáze: ${snapshot.error}"));
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['stav_zakazky'] == 'Dokončeno') return false;
                final cislo =
                    data['cislo_zakazky']?.toString().toLowerCase() ?? '';
                final spz = data['spz']?.toString().toLowerCase() ?? '';
                final vin = data['vin']?.toString().toLowerCase() ?? '';
                return cislo.contains(_searchQuery) ||
                    spz.contains(_searchQuery) ||
                    vin.contains(_searchQuery);
              }).toList();

              docs.sort((a, b) {
                final dataA = a.data() as Map<String, dynamic>;
                final dataB = b.data() as Map<String, dynamic>;
                final timeA = dataA['cas_prijeti'] as Timestamp?;
                final timeB = dataB['cas_prijeti'] as Timestamp?;
                if (timeA == null && timeB == null) return 0;
                if (timeA == null) return 1;
                if (timeB == null) return -1;
                return timeB.compareTo(timeA);
              });

              if (docs.isEmpty)
                return const Center(
                  child: Text('Žádné aktivní zakázky k zobrazení.'),
                );

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;
                  final stav = data['stav_zakazky'] ?? 'Přijato';

                  return Card(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${data['spz']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(stav).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              stav,
                              style: TextStyle(
                                color: getStatusColor(stav),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Zakázka: ${data['cislo_zakazky']}' +
                              (data['znacka'] != null &&
                                      data['znacka'].toString().isNotEmpty
                                  ? '\n${data['znacka']} ${data['model'] ?? ''}'
                                  : '') +
                              '\nČas příjmu: ${_formatDate(data['cas_prijeti'])}',
                        ),
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActiveJobScreen(
                            documentId: docId,
                            zakazkaId: data['cislo_zakazky'].toString(),
                            spz: data['spz'].toString(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
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

  @override
  void initState() {
    super.initState();
    _nactiSplatnost();
  }

  Future<void> _nactiSplatnost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('nastaveni_servisu')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _vychoziSplatnost = doc.data()?['splatnost_dny'] ?? 14;
        });
      }
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "Zpracovává se...";
    DateTime dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  void _openImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      await FirebaseFirestore.instance
          .collection('zakazky')
          .doc(widget.documentId)
          .update({
        'provedene_prace': FieldValue.arrayRemove([workItem]),
      });
    }
  }

  // OPRAVA EMAILOVÉ STRUKTURY: POUŽITA LOGIKA Z PRIJEM_VOZIDLA
  Future<void> _odeslatKNaceneni(BuildContext context, Map<String, dynamic> data) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odeslat nacenění zákazníkovi?'),
        content: const Text(
          'Aplikace vygeneruje PDF s rozpočtem a odešle jej na e-mail zákazníka.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ZRUŠIT'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'ODESLAT',
              style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        String sNazev = 'Servis';
        String sIco = '';
        String sEmail = '';
        final docNast = await FirebaseFirestore.instance.collection('nastaveni_servisu').doc(user.uid).get();
        if (docNast.exists) {
          sNazev = docNast.data()?['nazev_servisu'] ?? 'Servis';
          sIco = docNast.data()?['ico_servisu'] ?? '';
          sEmail = docNast.data()?['email_servisu'] ?? ''; 
        }

        final zakaznik = data['zakaznik'] as Map<String, dynamic>? ?? {};
        final zakaznikEmail = zakaznik['email']?.toString() ?? '';

        final pdfBytes = await GlobalPdfGenerator.generateDocument(
          data: data,
          servisNazev: sNazev,
          servisIco: sIco,
          typ: PdfTyp.naceneni,
        );

        String fileName = 'naceneni_${widget.zakazkaId}.pdf';
        Reference ref = FirebaseStorage.instance.ref().child('servisy/${user.uid}/zakazky/${widget.zakazkaId}/$fileName');
        await ref.putData(pdfBytes, SettableMetadata(contentType: 'application/pdf'));
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
            // ZDE JE KLÍČOVÁ OPRAVA STRUCTURY EMAILU
            Map<String, dynamic> mailDoc = {
              'to': zakaznikEmail,
              'from': '$sNazev (přes Torkis) <jan.svihalek00@gmail.com>', // Pevný funkční formát
              'message': {
                'subject': 'Cenová nabídka - Zakázka ${widget.zakazkaId} ($sNazev)',
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
                content: Text('Zákazník nemá e-mail. Nacenění uloženo, nyní ho můžete sdílet.'),
                backgroundColor: Colors.orange,
              ),
            );
            await Printing.sharePdf(bytes: pdfBytes, filename: 'Naceneni_${widget.zakazkaId}.pdf');
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chyba: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

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
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          String cisloIba = widget.zakazkaId.replaceAll(RegExp(r'[^0-9]'), '');
          String cisloFaktury = 'FAK$cisloIba';
          final fakturaRef = FirebaseFirestore.instance
              .collection('faktury')
              .doc('${user.uid}_$cisloFaktury');
          final fakturaSnap = await fakturaRef.get();

          if (fakturaSnap.exists) {
            await fakturaRef.update({'stav_platby': 'Stornováno'});
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
          });

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
    String vybranaPlatba = moznostiPlatby[0];
    final splatnostController =
        TextEditingController(text: _vychoziSplatnost.toString());
    bool isFinishing = false;

    String emailZakaznika = zakaznik['email']?.toString() ?? '';
    bool odeslatEmail = emailZakaznika.isNotEmpty && emailZakaznika.contains('@');

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
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: vybranaPlatba,
                        isExpanded: true,
                        items: moznostiPlatby
                            .map(
                              (p) => DropdownMenuItem<String>(
                                  value: p, child: Text(p)),
                            )
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
                    title: const Text('Odeslat fakturu zákazníkovi na e-mail', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: emailZakaznika.isEmpty 
                        ? const Text('Zákazník nemá vyplněný e-mail', style: TextStyle(color: Colors.red, fontSize: 12)) 
                        : Text(emailZakaznika, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    value: odeslatEmail,
                    activeColor: Colors.blue,
                    onChanged: emailZakaznika.isEmpty ? null : (bool? value) {
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
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
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

  // OPRAVA EMAILOVÉ STRUKTURY PRO FAKTURU
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

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
            celkovaSuma += (mnoz * cena);
          }
        } else {
          celkovaSuma += (prace['cena_s_dph'] ?? 0.0).toDouble();
          final dily = prace['pouzite_dily'] as List<dynamic>? ?? [];
          for (var dil in dily) {
            double p = (double.tryParse(dil['pocet'].toString()) ?? 1.0);
            double c = (double.tryParse(dil['cena_s_dph'].toString()) ?? 0.0);
            celkovaSuma += (p * c);
          }
        }
      }

      String cisloIba = widget.zakazkaId.replaceAll(RegExp(r'[^0-9]'), '');
      String cisloFaktury = 'FAK$cisloIba';
      
      String odesilatelJmeno = 'Servis';
      String odesilatelIco = '';
      String odesilatelEmail = '';

      if (!zruseno) {
        final docNastaveni = await FirebaseFirestore.instance
            .collection('nastaveni_servisu')
            .doc(user.uid)
            .get();
        if (docNastaveni.exists) {
          odesilatelJmeno = docNastaveni.data()?['nazev_servisu'] ?? 'Servis';
          odesilatelIco = docNastaveni.data()?['ico_servisu'] ?? '';
          odesilatelEmail = docNastaveni.data()?['email_servisu'] ?? ''; 
        }

        data['splatnost_dny'] = splatnostDny;

        final pdfBytes = await GlobalPdfGenerator.generateDocument(
          data: data,
          servisNazev: odesilatelJmeno,
          servisIco: odesilatelIco,
          typ: PdfTyp.faktura, 
        );

        Reference pdfRef = FirebaseStorage.instance.ref().child(
              'servisy/${user.uid}/zakazky/${widget.zakazkaId}/finalni_vyuctovani_${widget.zakazkaId}.pdf',
            );
        await pdfRef.putData(
          pdfBytes,
          SettableMetadata(contentType: 'application/pdf'),
        );
        pdfUrl = await pdfRef.getDownloadURL();

        if (zpusob == 'faktura') {
          DateTime now = DateTime.now();
          DateTime splatnost = now.add(Duration(days: splatnostDny));

          String stavPlatby = (platba == 'Hotově' || platba == 'Kartou')
              ? 'Uhrazeno'
              : 'Čeká na platbu';

          await FirebaseFirestore.instance
              .collection('faktury')
              .doc('${user.uid}_$cisloFaktury')
              .set({
            'servis_id': user.uid,
            'cislo_faktury': cisloFaktury,
            'cislo_zakazky': widget.zakazkaId,
            'spz': widget.spz,
            'zakaznik_id': zakaznik['id_zakaznika'] ?? '',
            'zakaznik_jmeno': zakaznik['jmeno'] ?? 'Neznámý zákazník',
            'datum_vystaveni': Timestamp.fromDate(now),
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

              // KLÍČOVÁ OPRAVA: SPRÁVNÁ STRUKTURA DLE PRIJEM_VOZIDLA
              Map<String, dynamic> mailDoc = {
                'to': zakaznikEmail,
                'from': '$odesilatelJmeno (přes Torkis) <jan.svihalek00@gmail.com>', // Pevný funkční formát
                'message': {
                  'subject': 'Faktura - Zakázka ${widget.zakazkaId} ($odesilatelJmeno)',
                  'html': '''
                    <div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; margin: 0 auto; border: 1px solid #eee; padding: 20px; border-radius: 10px;">
                      <h2 style="color: #2196F3; border-bottom: 2px solid #2196F3; padding-bottom: 10px;">Dobrý den,</h2>
                      <p>v příloze Vám zasíláme fakturu za provedené servisní práce na Vašem vozidle <b>${data['spz']}</b> v našem servisu.</p>
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
            }
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
        'cas_ukonceni': FieldValue.serverTimestamp(),
        if (pdfUrl.isNotEmpty) 'vystupni_protokol_url': pdfUrl,
      });

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(odeslatEmail && !zruseno ? 'Zakázka ukončena a faktura odeslána.' : 'Zakázka úspěšně ukončena.'),
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
          if (snapshot.hasError)
            return Center(child: Text("Chyba: ${snapshot.error}"));
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null)
            return const Center(child: Text("Dokument nenalezen."));

          final provedenePrace =
              data['provedene_prace'] as List<dynamic>? ?? [];
          final pozadavky = data['pozadavky_zakaznika'] as List<dynamic>? ?? [];
          final aktualniStav = data['stav_zakazky'] ?? 'Přijato';
          final stav = data['stav_vozidla'] as Map<String, dynamic>? ?? {};
          final zakaznik = data['zakaznik'] as Map<String, dynamic>? ?? {};
          final rawUrls = data['fotografie_urls'];
          final Map<String, dynamic> imageUrlsByCategoryRaw = {};
          if (rawUrls is Map) {
            imageUrlsByCategoryRaw.addAll(Map<String, dynamic>.from(rawUrls));
          } else if (rawUrls is List) {
            imageUrlsByCategoryRaw['ostatni'] = rawUrls;
          }

          final bool isCompleted = aktualniStav == 'Dokončeno';

          List<String> dostupneStavy = stavyZakazky.where((s) => s != 'Dokončeno').toList();
          if (!dostupneStavy.contains(aktualniStav) && !isCompleted) {
            dostupneStavy.add(aktualniStav);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    const Text(
                      'Stav: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: getStatusColor(aktualniStav).withOpacity(0.1),
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
                                    if (novyStav != null)
                                      _zmenitStav(context, novyStav);
                                  },
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    if (!isCompleted)
                      IconButton(
                        icon: const Icon(
                          Icons.request_quote,
                          color: Colors.purple,
                        ),
                        tooltip: 'Generovat nabídku a odeslat e-mailem',
                        onPressed: () => _odeslatKNaceneni(context, data),
                      ),
                    IconButton(
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'Zobrazit zakázkový protokol',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: const Text('Náhled protokolu'),
                              ),
                              body: PdfPreview(
                                build: (format) async {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  String sNazev = 'Servis';
                                  String sIco = '';
                                  if (user != null) {
                                    final docNast = await FirebaseFirestore
                                        .instance
                                        .collection('nastaveni_servisu')
                                        .doc(user.uid)
                                        .get();
                                    sNazev = docNast.data()?['nazev_servisu'] ??
                                        'Servis';
                                    sIco = docNast.data()?['ico_servisu'] ?? '';
                                  }
                                  return await GlobalPdfGenerator
                                      .generateDocument(
                                    data: data,
                                    servisNazev: sNazev,
                                    servisIco: sIco,
                                    typ: PdfTyp.protokol, 
                                  );
                                },
                                allowSharing: true,
                                allowPrinting: true,
                                canChangeOrientation: false,
                                canChangePageFormat: false,
                                loadingWidget: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Card(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      margin: const EdgeInsets.only(bottom: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: Text(
                                'Informace o zakázce',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const Divider(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ZakaznikDetailScreen(
                                              zakaznikData: zakaznik,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.person,
                                                  size: 16,
                                                  color: isDark
                                                      ? Colors.grey[400]
                                                      : Colors.grey[700],
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  'Zákazník',
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.grey[400]
                                                        : Colors.grey[700],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              zakaznik['jmeno']
                                                          ?.toString()
                                                          .isNotEmpty ==
                                                      true
                                                  ? zakaznik['jmeno']
                                                  : 'Neuvedeno',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            if (zakaznik['telefon']
                                                    ?.toString()
                                                    .isNotEmpty ==
                                                true)
                                              Text(zakaznik['telefon']),
                                            if (zakaznik['email']
                                                    ?.toString()
                                                    .isNotEmpty ==
                                                true)
                                              Text(zakaznik['email']),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 80,
                                  color: Colors.grey.withOpacity(0.3),
                                  margin: const EdgeInsets.only(top: 10),
                                ),
                                Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {
                                        final user =
                                            FirebaseAuth.instance.currentUser;
                                        if (user != null &&
                                            data['spz'] != null) {
                                          final vozidloDocId =
                                              '${user.uid}_${data['spz']}';
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  VozidloDetailScreen(
                                                vozidloDocId: vozidloDocId,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.directions_car,
                                                  size: 16,
                                                  color: isDark
                                                      ? Colors.grey[400]
                                                      : Colors.grey[700],
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  'Vozidlo',
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.grey[400]
                                                        : Colors.grey[700],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: isDark
                                                      ? Colors.grey[600]!
                                                      : Colors.black87,
                                                  width: 1.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                data['spz']
                                                        ?.toString()
                                                        .toUpperCase() ??
                                                    '---',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${data['znacka'] ?? ''} ${data['model'] ?? ''}'
                                                      .trim()
                                                      .isEmpty
                                                  ? 'Neznámé vozidlo'
                                                  : '${data['znacka']} ${data['model']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (data['rok_vyroby']
                                                        ?.toString()
                                                        .isNotEmpty ==
                                                    true ||
                                                data['motorizace']
                                                        ?.toString()
                                                        .isNotEmpty ==
                                                    true)
                                              Text(
                                                '${data['rok_vyroby'] ?? ''} ${data['motorizace'] ?? ''}'
                                                    .trim(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            Text(
                                              'VIN: ${data['vin']?.toString().isNotEmpty == true ? data['vin'] : '-'}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (pozadavky.isNotEmpty) ...[
                      const Text(
                        'Požadavky od zákazníka (k řešení)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...pozadavky.map(
                        (p) => Card(
                          color: Colors.orange.withOpacity(0.05),
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            title: Text(
                              p.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: isCompleted
                                ? null
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        tooltip: 'Smazat požadavek',
                                        onPressed: () => _deletePozadavek(
                                            context, p.toString()),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.build, size: 18),
                                        label: const Text('ZPRACOVAT'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () => _openAddWorkDialog(
                                          context,
                                          initialTitle: p.toString(),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const Divider(height: 40),
                    ],
                    const Text(
                      'Zaznamenané úkony',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (provedenePrace.isEmpty)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 30),
                            Icon(
                              Icons.build_circle_outlined,
                              size: 80,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Zatím nebyly přidány žádné práce.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    else
                      ...List.generate(provedenePrace.length, (index) {
                        final trueIndex = provedenePrace.length - 1 - index;
                        final prace = provedenePrace[trueIndex];
                        final fotky =
                            prace['fotografie_urls'] as List<dynamic>? ?? [];

                        List<dynamic> polozky =
                            prace['polozky'] as List<dynamic>? ?? [];
                        if (polozky.isEmpty) {
                          if ((prace['cena_s_dph'] ?? 0) > 0) {
                            polozky.add({
                              'typ': 'Práce',
                              'nazev': 'Práce',
                              'cislo': '',
                              'mnozstvi': prace['delka_prace'] ?? 1,
                              'jednotka': 'h',
                              'cena_s_dph': prace['cena_s_dph']
                            });
                          }
                          for (var d
                              in (prace['pouzite_dily'] as List<dynamic>? ??
                                  [])) {
                            polozky.add({
                              'typ': 'Materiál',
                              'nazev': d['nazev'],
                              'cislo': d['cislo'] ?? '',
                              'mnozstvi': d['pocet'] ?? 1,
                              'jednotka': 'ks',
                              'cena_s_dph': d['cena_s_dph']
                            });
                          }
                        }

                        double celkemUkon = 0.0;
                        for (var p in polozky) {
                          celkemUkon += (double.tryParse(
                                      p['mnozstvi'].toString()) ??
                                  1.0) *
                              (double.tryParse(p['cena_s_dph'].toString()) ??
                                  0.0);
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          color:
                              isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
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
                                        '${prace['nazev']} (Celkem: ${celkemUkon.toStringAsFixed(2)} Kč)',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (!isCompleted)
                                      IconButton(
                                        onPressed: () => _openAddWorkDialog(
                                          context,
                                          existingWork: prace,
                                          editIndex: trueIndex,
                                        ),
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                      ),
                                    if (!isCompleted)
                                      IconButton(
                                        onPressed: () =>
                                            _deleteWork(context, prace),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                                Text(
                                  _formatDate(prace['cas']),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                if (prace['popis'] != null &&
                                    prace['popis'].toString().isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    prace['popis'],
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                                if (polozky.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Položky:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  ...polozky.map((p) {
                                    double pMnoz = double.tryParse(
                                            p['mnozstvi'].toString()) ??
                                        1.0;
                                    double pCena = double.tryParse(
                                            p['cena_s_dph'].toString()) ??
                                        0.0;
                                    String pJedn = p['jednotka'] ?? 'ks';
                                    String cistyMnoz = pMnoz
                                        .toString()
                                        .replaceAll(
                                            RegExp(r"([.]*0)(?!.*\d)"), "");

                                    String cNum = p['cislo']?.toString() ?? '';
                                    String nDisp = cNum.trim().isNotEmpty
                                        ? '${p['nazev']} ($cNum)'
                                        : p['nazev'];

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        top: 4,
                                        left: 10,
                                      ),
                                      child: Text(
                                        '• [${p['typ']}] $nDisp - $cistyMnoz $pJedn - ${(pMnoz * pCena).toStringAsFixed(2)} Kč',
                                        style: const TextStyle(
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                                if (fotky.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: SizedBox(
                                      height: 100,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: fotky.length,
                                        separatorBuilder: (c, i) =>
                                            const SizedBox(width: 10),
                                        itemBuilder: (c, i) => GestureDetector(
                                          onTap: () =>
                                              _openImageDialog(fotky[i]),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              fotky[i],
                                              width: 140,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),

              // SPODNÍ LIŠTA PRO ZAMČENOU ZAKÁZKU (STORNO)
              if (isCompleted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _stornovatZakazku(context),
                        icon: const Icon(Icons.settings_backup_restore),
                        label: const Text(
                          'STORNOVAT FAKTURU A ZNOVU OTEVŘÍT ZAKÁZKU',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // SPODNÍ LIŠTA PRO AKTIVNÍ ZAKÁZKU
              if (!isCompleted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _ukoncitZakazkuDialog(context,
                                data, stav, zakaznik, imageUrlsByCategoryRaw),
                            icon: const Icon(Icons.flag),
                            label: const Text(
                              'UKONČIT A VYDAT',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _openAddWorkDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text(
                              'PŘIDAT ÚKON',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class PolozkaInput {
  String typ = 'Materiál';
  final cislo = TextEditingController();
  final nazev = TextEditingController();
  final mnozstvi = TextEditingController(text: '1');
  String jednotka = 'ks';
  final cenaBezDph = TextEditingController(text: '0');
  final cenaSDph = TextEditingController(text: '0');

  void dispose() {
    cislo.dispose();
    nazev.dispose();
    mnozstvi.dispose();
    cenaBezDph.dispose();
    cenaSDph.dispose();
  }
}

class AddWorkScreen extends StatefulWidget {
  final String documentId;
  final String zakazkaId;
  final String? initialTitle;
  final Map<String, dynamic>? existingWork;
  final int? editIndex;

  const AddWorkScreen({
    super.key,
    required this.documentId,
    required this.zakazkaId,
    this.initialTitle,
    this.existingWork,
    this.editIndex,
  });

  @override
  State<AddWorkScreen> createState() => _AddWorkScreenState();
}

class _AddWorkScreenState extends State<AddWorkScreen> {
  final _nazevController = TextEditingController();
  final _popisController = TextEditingController();

  final List<PolozkaInput> _polozkyInputs = [];
  final List<XFile> _workImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isSaving = false;
  double _hodinovaSazba = 0.0;
  bool _jePlatceDph = false;
  double _celkovaCenaSDph = 0.0;

  @override
  void initState() {
    super.initState();
    _nactiHodinovouSazbu();

    if (widget.initialTitle != null) {
      _nazevController.text = widget.initialTitle!;
    }

    if (widget.existingWork != null) {
      _nazevController.text = widget.existingWork!['nazev'] ?? '';
      _popisController.text = widget.existingWork!['popis'] ?? '';

      final polozky = widget.existingWork!['polozky'] as List<dynamic>?;
      if (polozky != null) {
        for (var p in polozky) {
          final input = PolozkaInput();
          input.typ = p['typ'] ?? 'Materiál';
          input.cislo.text = p['cislo'] ?? '';
          input.nazev.text = p['nazev'] ?? '';
          input.mnozstvi.text = (p['mnozstvi'] ?? 1.0).toString();
          input.jednotka = p['jednotka'] ?? 'ks';
          input.cenaBezDph.text = (p['cena_bez_dph'] ?? 0.0).toStringAsFixed(2);
          input.cenaSDph.text = (p['cena_s_dph'] ?? 0.0).toStringAsFixed(2);
          _polozkyInputs.add(input);
        }
      } else {
        if ((widget.existingWork!['cena_s_dph'] ?? 0) > 0 ||
            (widget.existingWork!['delka_prace']?.toString().isNotEmpty ==
                true)) {
          final input = PolozkaInput();
          input.typ = 'Práce';
          input.cislo.text = '';
          input.nazev.text = 'Práce mechanika';
          input.mnozstvi.text =
              (widget.existingWork!['delka_prace'] ?? 1).toString();
          input.jednotka = 'h';
          input.cenaBezDph.text =
              (widget.existingWork!['cena_bez_dph'] ?? 0.0).toStringAsFixed(2);
          input.cenaSDph.text =
              (widget.existingWork!['cena_s_dph'] ?? 0.0).toStringAsFixed(2);
          _polozkyInputs.add(input);
        }
        final dily =
            widget.existingWork!['pouzite_dily'] as List<dynamic>? ?? [];
        for (var d in dily) {
          final input = PolozkaInput();
          input.typ = 'Materiál';
          input.cislo.text = d['cislo'] ?? '';
          input.nazev.text = d['nazev'] ?? '';
          input.mnozstvi.text = (d['pocet'] ?? 1.0).toString();
          input.jednotka = 'ks';
          input.cenaBezDph.text = (d['cena_bez_dph'] ?? 0.0).toStringAsFixed(2);
          input.cenaSDph.text = (d['cena_s_dph'] ?? 0.0).toStringAsFixed(2);
          _polozkyInputs.add(input);
        }
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prepocitatCelkem();
      });
    }

    if (_polozkyInputs.isEmpty) {
      _polozkyInputs.add(PolozkaInput());
    }
  }

  Future<void> _nactiHodinovouSazbu() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('nastaveni_servisu')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _hodinovaSazba = (doc.data()?['hodinova_sazba'] ?? 0.0).toDouble();
          _jePlatceDph = doc.data()?['platce_dph'] ?? false;
        });
      }
    }
  }

  void _prepocitatCelkem() {
    double celkem = 0.0;
    for (var p in _polozkyInputs) {
      double pocet =
          double.tryParse(p.mnozstvi.text.replaceAll(',', '.')) ?? 0.0;
      double cenaKs =
          double.tryParse(p.cenaSDph.text.replaceAll(',', '.')) ?? 0.0;
      celkem += (pocet * cenaKs);
    }
    setState(() {
      _celkovaCenaSDph = celkem;
    });
  }

  void _prepocitatDphPolozky(PolozkaInput p, String bezDphText) {
    double bezDph = double.tryParse(bezDphText.replaceAll(',', '.')) ?? 0.0;
    double sDph = _jePlatceDph ? (bezDph * 1.21) : bezDph;
    p.cenaSDph.text = sDph.toStringAsFixed(2);
    _prepocitatCelkem();
  }

  @override
  void dispose() {
    _nazevController.dispose();
    _popisController.dispose();
    for (var p in _polozkyInputs) {
      p.dispose();
    }
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    if (photo != null) setState(() => _workImages.add(photo));
  }

  Future<void> _pickFromGallery() async {
    final photos = await _picker.pickMultiImage(
      imageQuality: 60,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    if (photos.isNotEmpty) setState(() => _workImages.addAll(photos));
  }

  Future<void> _saveWork() async {
    if (_nazevController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Zadejte alespoň hlavičku (Název skupiny).'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      List<String> uploadedUrls = [];

      for (int i = 0; i < _workImages.length; i++) {
        String fileName =
            'prace_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        Reference ref = FirebaseStorage.instance.ref().child(
            'servisy/${user!.uid}/zakazky/${widget.zakazkaId}/$fileName');
        await ref.putData(await _workImages[i].readAsBytes());
        uploadedUrls.add(await ref.getDownloadURL());
      }

      List<Map<String, dynamic>> zpracovanePolozky = _polozkyInputs
          .map((p) => {
                'typ': p.typ,
                'cislo': p.cislo.text.trim(),
                'nazev': p.nazev.text.trim(),
                'mnozstvi':
                    double.tryParse(p.mnozstvi.text.replaceAll(',', '.')) ??
                        1.0,
                'jednotka': p.jednotka,
                'cena_bez_dph':
                    double.tryParse(p.cenaBezDph.text.replaceAll(',', '.')) ??
                        0.0,
                'cena_s_dph':
                    double.tryParse(p.cenaSDph.text.replaceAll(',', '.')) ??
                        0.0,
              })
          .where((d) => d['nazev'].toString().isNotEmpty)
          .toList();

      List<String> finalFotky = [];
      if (widget.existingWork != null) {
        finalFotky.addAll(
            List<String>.from(widget.existingWork!['fotografie_urls'] ?? []));
      }
      finalFotky.addAll(uploadedUrls);

      Map<String, dynamic> novyUkon = {
        'nazev': _nazevController.text.trim(),
        'popis': _popisController.text.trim(),
        'polozky': zpracovanePolozky,
        'cas': widget.existingWork?['cas'] ?? Timestamp.now(),
        'fotografie_urls': finalFotky,
      };

      if (widget.editIndex != null) {
        final doc = await FirebaseFirestore.instance
            .collection('zakazky')
            .doc(widget.documentId)
            .get();
        List<dynamic> prace = List.from(doc.data()?['provedene_prace'] ?? []);
        if (widget.editIndex! >= 0 && widget.editIndex! < prace.length) {
          prace[widget.editIndex!] = novyUkon;
          await FirebaseFirestore.instance
              .collection('zakazky')
              .doc(widget.documentId)
              .update({'provedene_prace': prace});
        }
      } else {
        Map<String, dynamic> updates = {
          'provedene_prace': FieldValue.arrayUnion([novyUkon]),
        };

        if (widget.initialTitle != null) {
          updates['pozadavky_zakaznika'] =
              FieldValue.arrayRemove([widget.initialTitle]);
        }

        await FirebaseFirestore.instance
            .collection('zakazky')
            .doc(widget.documentId)
            .update(updates);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Chyba: $e')));
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.existingWork != null ? 'Úprava úkonu' : 'Nový úkon'),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.folder, color: Colors.blue),
                              SizedBox(width: 10),
                              Text('Hlavička (Skupina)',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(_nazevController,
                              'Název úkonu (např. Servis brzd) *', isDark,
                              isBold: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Card(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.format_list_bulleted,
                                  color: Colors.orange),
                              SizedBox(width: 10),
                              Text('Položky dokladu',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          ...List.generate(_polozkyInputs.length, (index) {
                            final polozka = _polozkyInputs[index];
                            double dPocet = double.tryParse(polozka
                                    .mnozstvi.text
                                    .replaceAll(',', '.')) ??
                                0.0;
                            double dCena = double.tryParse(polozka.cenaSDph.text
                                    .replaceAll(',', '.')) ??
                                0.0;
                            double rCelkem = dPocet * dCena;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2C2C2C)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: DropdownButtonFormField<String>(
                                          value: polozka.typ,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black),
                                          items: ['Práce', 'Materiál']
                                              .map((t) => DropdownMenuItem(
                                                  value: t,
                                                  child: Text(t,
                                                      style: const TextStyle(
                                                          fontSize: 12))))
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(() {
                                                polozka.typ = val;
                                                if (val == 'Práce') {
                                                  polozka.jednotka = 'h';
                                                  if (_hodinovaSazba > 0) {
                                                    polozka.cenaBezDph.text =
                                                        _hodinovaSazba
                                                            .toStringAsFixed(2);
                                                    _prepocitatDphPolozky(
                                                        polozka,
                                                        polozka
                                                            .cenaBezDph.text);
                                                  }
                                                }
                                                if (val == 'Materiál')
                                                  polozka.jednotka = 'ks';
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Typ',
                                            labelStyle:
                                                const TextStyle(fontSize: 12),
                                            filled: true,
                                            fillColor: isDark
                                                ? const Color(0xFF1E1E1E)
                                                : Colors.white,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 10),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 4,
                                        child: _buildTextField(
                                            polozka.cislo, 'Číslo dílu', isDark,
                                            compact: true),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red, size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          setState(() {
                                            polozka.dispose();
                                            _polozkyInputs.removeAt(index);
                                            _prepocitatCelkem();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                      polozka.nazev, 'Název položky', isDark,
                                      compact: true),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: _buildTextField(
                                          polozka.mnozstvi,
                                          'Mn.',
                                          isDark,
                                          isNumber: true,
                                          compact: true,
                                          onChanged: (v) => _prepocitatCelkem(),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        flex: 3,
                                        child: DropdownButtonFormField<String>(
                                          value: polozka.jednotka,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black),
                                          items: [
                                            'ks',
                                            'h',
                                            'min',
                                            'l',
                                            'm',
                                            'bal',
                                            'sada',
                                            'úkon'
                                          ]
                                              .map((j) => DropdownMenuItem(
                                                  value: j,
                                                  child: Text(j,
                                                      style: const TextStyle(
                                                          fontSize: 12))))
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null)
                                              setState(
                                                  () => polozka.jednotka = val);
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Jedn.',
                                            labelStyle:
                                                const TextStyle(fontSize: 12),
                                            filled: true,
                                            fillColor: isDark
                                                ? const Color(0xFF1E1E1E)
                                                : Colors.white,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 10),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        flex: 3,
                                        child: _buildTextField(
                                          polozka.cenaBezDph,
                                          _jePlatceDph ? 'Bez DPH' : 'Cena',
                                          isDark,
                                          isNumber: true,
                                          compact: true,
                                          onChanged: (v) =>
                                              _prepocitatDphPolozky(polozka, v),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        flex: 3,
                                        child: _buildTextField(
                                          polozka.cenaSDph,
                                          _jePlatceDph ? 'S DPH' : 'Konečná',
                                          isDark,
                                          isNumber: true,
                                          compact: true,
                                          onChanged: (v) => _prepocitatCelkem(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Text('Celkem za položku: ',
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 12)),
                                        Text('${rCelkem.toStringAsFixed(2)} Kč',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                                fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          TextButton.icon(
                            onPressed: () => setState(
                                () => _polozkyInputs.add(PolozkaInput())),
                            icon: const Icon(Icons.add),
                            label: const Text('Přidat další položku'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Card(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.more_horiz, color: Colors.purple),
                              SizedBox(width: 10),
                              Text('Doplňující informace',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(_popisController,
                              'Interní poznámka k úkonu', isDark,
                              maxLines: 2),
                          const SizedBox(height: 20),
                          const Text('Fotodokumentace úkonu:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 80,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: _takePhoto,
                                  child: Container(
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.blue),
                                    ),
                                    child: const Icon(Icons.add_a_photo,
                                        color: Colors.blue),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: _pickFromGallery,
                                  child: Container(
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border:
                                          Border.all(color: Colors.blueGrey),
                                    ),
                                    child: const Icon(Icons.photo_library,
                                        color: Colors.blueGrey),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _workImages.length,
                                    itemBuilder: (c, i) => Stack(
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: kIsWeb
                                                ? Image.network(
                                                    _workImages[i].path,
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover)
                                                : Image.file(
                                                    File(_workImages[i].path),
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover),
                                          ),
                                        ),
                                        Positioned(
                                          top: 2,
                                          right: 12,
                                          child: GestureDetector(
                                            onTap: () => setState(
                                                () => _workImages.removeAt(i)),
                                            child: const CircleAvatar(
                                                radius: 10,
                                                backgroundColor: Colors.white,
                                                child: Icon(Icons.close,
                                                    size: 12,
                                                    color: Colors.red)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Celkem za položku',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('${_celkovaCenaSDph.toStringAsFixed(2)} Kč',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveWork,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check),
                    label: Text(_isSaving ? 'UKLÁDÁM...' : 'ULOŽIT ÚKON',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, bool isDark,
      {bool isNumber = false,
      bool isBold = false,
      bool compact = false,
      int maxLines = 1,
      Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: compact ? 12 : (isBold ? 16 : 14)),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(fontSize: compact ? 12 : 14),
        filled: true,
        fillColor: isDark
            ? (compact ? const Color(0xFF1E1E1E) : const Color(0xFF2C2C2C))
            : Colors.white,
        contentPadding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 15, vertical: compact ? 10 : 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}