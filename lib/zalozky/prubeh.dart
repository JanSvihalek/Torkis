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
import 'auth_gate.dart';
import 'zakazka_komunikace.dart';
import 'prubeh_add_work.dart';
import 'prubeh_fotodokumentace.dart';

// Modul prĹŻbÄ›hu zakĂˇzek â€” sklĂˇdĂˇ se ze ÄŤtyĹ™ obrazovek:
//
// [ServiceProgressPage]  â€” seznam aktivnĂ­ch zakĂˇzek (search + StreamBuilder karet)
// [ActiveJobScreen]      â€” detail zakĂˇzky: zĂˇloĹľky PĹ™ehled / CenovĂˇ nabĂ­dka /
//                          Foto / ZĂˇkaznĂ­k / Vozidlo + akce DokonÄŤit / Storno
// [AddWorkScreen]        â€” dialog pro zĂˇznam provedenĂ© prĂˇce (Ăşkon + dĂ­ly + foto)
// [FotodokumentaceScreen]â€” fullscreen galerie fotek pĹ™iloĹľenĂ˝ch k zakĂˇzce

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

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "ZpracovĂˇvĂˇ se...";
    DateTime dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  String _formatDateShort(dynamic timestamp) {
    if (timestamp == null) return "Neuvedeno";
    DateTime dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy').format(dt);
  }

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (globalServisId == null)
      return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ZakĂˇzky',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TabBar(
                controller: _tabController,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                unselectedLabelStyle: const TextStyle(fontSize: 15),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'OtevĹ™enĂ©'),
                  Tab(text: 'UkonÄŤenĂ©'),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOtevrenTab(isDark),
              _buildUkonceneTab(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar({
    required bool isDark,
    required String hint,
    required IconData icon,
    required void Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          if (!isDark)
            const BoxShadow(
                color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.blue),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildOtevrenTab(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 15, 30, 10),
          child: _buildSearchBar(
            isDark: isDark,
            hint: 'Hledat SPZ, VIN nebo ÄŤĂ­slo...',
            icon: Icons.search,
            onChanged: (v) => setState(() => _searchOpen = v.toLowerCase()),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('zakazky')
                .where('servis_id', isEqualTo: globalServisId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Center(child: Text("Chyba databĂˇze: ${snapshot.error}"));
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['stav_zakazky'] == 'DokonÄŤeno') return false;
                final cislo =
                    data['cislo_zakazky']?.toString().toLowerCase() ?? '';
                final spz = data['spz']?.toString().toLowerCase() ?? '';
                final vin = data['vin']?.toString().toLowerCase() ?? '';
                return cislo.contains(_searchOpen) ||
                    spz.contains(_searchOpen) ||
                    vin.contains(_searchOpen);
              }).toList();

              docs.sort((a, b) {
                final timeA =
                    (a.data() as Map)['cas_prijeti'] as Timestamp?;
                final timeB =
                    (b.data() as Map)['cas_prijeti'] as Timestamp?;
                if (timeA == null && timeB == null) return 0;
                if (timeA == null) return 1;
                if (timeB == null) return -1;
                return timeB.compareTo(timeA);
              });

              if (docs.isEmpty) {
                return const Center(
                    child: Text('Ĺ˝ĂˇdnĂ© aktivnĂ­ zakĂˇzky k zobrazenĂ­.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;
                  final stav = data['stav_zakazky'] ?? 'PĹ™ijato';

                  final znacka = data['znacka']?.toString() ?? '';
                  final model = data['model']?.toString() ?? '';
                  final vin = data['vin']?.toString() ?? '';
                  final zakaznikJmeno =
                      data['zakaznik']?['jmeno']?.toString() ?? '';

                  return Card(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${data['spz']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: getStatusColor(stav).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(stav,
                                style: TextStyle(
                                    color: getStatusColor(stav),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ZakĂˇzka: ${data['cislo_zakazky']}',
                                style: const TextStyle(fontSize: 13)),
                            if (zakaznikJmeno.isNotEmpty)
                              Text(zakaznikJmeno,
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[500])),
                            if (znacka.isNotEmpty)
                              Text('$znacka $model'.trim(),
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[500])),
                            if (vin.isNotEmpty)
                              Text('VIN: $vin',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500])),
                            const SizedBox(height: 2),
                            Text(
                                'PĹ™Ă­jem: ${_formatDate(data['cas_prijeti'])}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      trailing:
                          const Icon(Icons.arrow_forward_ios, size: 16),
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

  Widget _buildUkonceneTab(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 15, 30, 10),
          child: _buildSearchBar(
            isDark: isDark,
            hint: 'Hledat v historii (SPZ, VIN, ÄŤĂ­slo)...',
            icon: Icons.history,
            onChanged: (v) => setState(() => _searchClosed = v.toLowerCase()),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('zakazky')
                .where('servis_id', isEqualTo: globalServisId)
                .where('stav_zakazky', isEqualTo: 'DokonÄŤeno')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError)
                return Center(child: Text("Chyba: ${snapshot.error}"));
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());

              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final cislo =
                    data['cislo_zakazky']?.toString().toLowerCase() ?? '';
                final spz = data['spz']?.toString().toLowerCase() ?? '';
                final vin = data['vin']?.toString().toLowerCase() ?? '';
                final zakaznik =
                    data['zakaznik']?['jmeno']?.toString().toLowerCase() ?? '';
                return cislo.contains(_searchClosed) ||
                    spz.contains(_searchClosed) ||
                    vin.contains(_searchClosed) ||
                    zakaznik.contains(_searchClosed);
              }).toList();

              docs.sort((a, b) {
                final timeA =
                    (a.data() as Map)['cas_ukonceni'] as Timestamp?;
                final timeB =
                    (b.data() as Map)['cas_ukonceni'] as Timestamp?;
                if (timeA == null || timeB == null) return 0;
                return timeB.compareTo(timeA);
              });

              if (docs.isEmpty) {
                return const Center(
                    child: Text('Historie je zatĂ­m prĂˇzdnĂˇ.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;
                  final bool isMechanik = globalUserRole == 'mechanik';
                  final double celkovaCena =
                      (data['celkova_castka'] as num?)?.toDouble() ?? 0.0;
                  final znacka = data['znacka']?.toString() ?? '';
                  final model = data['model']?.toString() ?? '';
                  final vin = data['vin']?.toString() ?? '';
                  final zakaznikJmeno =
                      data['zakaznik']?['jmeno']?.toString() ?? 'Neuvedeno';

                  return Card(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        child: const Icon(Icons.check_circle,
                            color: Colors.green),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${data['spz']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          if (!isMechanik && celkovaCena > 0)
                            Text(
                              '${celkovaCena.toStringAsFixed(0)} KÄŤ',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ZakĂˇzka: ${data['cislo_zakazky']}',
                                style: const TextStyle(fontSize: 13)),
                            Text(zakaznikJmeno,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[500])),
                            if (znacka.isNotEmpty)
                              Text('$znacka $model'.trim(),
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[500])),
                            if (vin.isNotEmpty)
                              Text('VIN: $vin',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500])),
                            const SizedBox(height: 2),
                            Text(
                                'UkonÄŤeno: ${_formatDateShort(data['cas_ukonceni'])}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
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
  String _zpusobUhrady = 'PĹ™evodem';
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
          _zpusobUhrady = doc.data()?['zpusob_uhrady'] ?? 'PĹ™evodem';
        });
      }
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "ZpracovĂˇvĂˇ se...";
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

  /// SmaĹľe jeden Ĺ™Ăˇdek z pole 'pozadavky_zakaznika' v dokumentu zakĂˇzky.
  Future<void> _deletePozadavek(BuildContext context, String pozadavek) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Smazat poĹľadavek?'),
        content: const Text(
          'Opravdu chcete tento poĹľadavek zĂˇkaznĂ­ka trvale odstranit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ZRUĹ IT'),
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

  /// VrĂˇtĂ­ vĹˇechny dĂ­ly ze seznamu provedenĂ˝ch pracĂ­ zpÄ›t na sklad.
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
          'typ_pohybu': 'pĹ™Ă­jem',
          'mnozstvi': mnozstvi,
          'poznamka': popis,
          'zakazka_id': widget.zakazkaId,
          'datum': FieldValue.serverTimestamp(),
          'uzivatel_id': FirebaseAuth.instance.currentUser?.uid,
        });
      }
    }
  }

  /// OdstranĂ­ zĂˇznam provedenĂ© prĂˇce ze zakĂˇzky a pĹ™egeneruje PDF cenovĂ© nabĂ­dky.
  Future<void> _deleteWork(
    BuildContext context,
    Map<String, dynamic> workItem,
  ) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Smazat Ăşkon?'),
        content: const Text(
          'Opravdu chcete tento zĂˇznam o prĂˇci odstranit? Tato akce je nevratnĂˇ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ZRUĹ IT'),
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
        'OdebrĂˇnĂ­ poloĹľky ze zakĂˇzky ${widget.zakazkaId}',
      );
      await FirebaseFirestore.instance
          .collection('zakazky')
          .doc(widget.documentId)
          .update({
        'provedene_prace': FieldValue.arrayRemove([workItem]),
      });
    }
  }

  /// Vygeneruje PDF cenovĂ© nabĂ­dky a odeĹˇle ji zĂˇkaznĂ­kovi na e-mail.
  /// ZobrazĂ­ dialog pro potvrzenĂ­ / Ăşpravu e-mailovĂ© adresy pĹ™ed odeslĂˇnĂ­m.
  Future<void> _odeslatKNaceneni(
      BuildContext context, Map<String, dynamic> data) async {
    final zakaznik = data['zakaznik'] as Map<String, dynamic>? ?? {};
    final emailCtrl = TextEditingController(text: zakaznik['email']?.toString() ?? '');

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generovat nacenÄ›nĂ­',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
                'Aplikace vygeneruje PDF s cenovou nabĂ­dkou a odeĹˇle ji zĂˇkaznĂ­kovi.'),
            const SizedBox(height: 15),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'E-mail zĂˇkaznĂ­ka',
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
            child: const Text('ZruĹˇit'),
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
        builder: (context) => const Center(child: CircularProgressIndicator()),
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
          'stav_zakazky': 'K nacenÄ›nĂ­',
          'nabidka_url': downloadUrl,
        });

        if (context.mounted) {
          Navigator.pop(context);

          if (zakaznikEmail.isNotEmpty && zakaznikEmail.contains('@')) {
            Map<String, dynamic> mailDoc = {
              'to': zakaznikEmail,
              'from': '$sNazev (pĹ™es TORKIS) <jan.svihalek00@gmail.com>',
              'message': {
                'subject':
                    'CenovĂˇ nabĂ­dka - ZakĂˇzka ${widget.zakazkaId} ($sNazev)',
                'html': '''
                  <div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; margin: 0 auto; border: 1px solid #eee; padding: 20px; border-radius: 10px;">
                    <h2 style="color: #2196F3; border-bottom: 2px solid #2196F3; padding-bottom: 10px;">DobrĂ˝ den,</h2>
                    <p>zasĂ­lĂˇme VĂˇm cenovou nabĂ­dku k nahlĂ©dnutĂ­ pro VaĹˇi zakĂˇzku <b>${widget.zakazkaId}</b> v servisu $sNazev.</p>
                    <p>CelĂ˝ dokument si mĹŻĹľete prohlĂ©dnout zde:</p>
                    <div style="text-align: center; margin: 30px 0;">
                      <a href="$downloadUrl" style="background-color: #2196F3; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 16px; display: inline-block;">Zobrazit nacenÄ›nĂ­ (PDF)</a>
                    </div>
                    <p>ProsĂ­me o informaci, zda s rozpoÄŤtem souhlasĂ­te, abychom mohli zaÄŤĂ­t pracovat.</p>
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
                content: Text('NacenÄ›nĂ­ odeslĂˇno na: $zakaznikEmail'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'ZĂˇkaznĂ­k nemĂˇ e-mail. NacenÄ›nĂ­ uloĹľeno, nynĂ­ ho mĹŻĹľete sdĂ­let.'),
                backgroundColor: Colors.orange,
              ),
            );
            await Printing.sharePdf(
                bytes: pdfBytes, filename: 'Naceneni_${widget.zakazkaId}.pdf');
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

  /// NastavĂ­ stav zakĂˇzky na 'StornovĂˇno' â€” zakĂˇzka zmizĂ­ z aktivnĂ­ho seznamu,
  /// ale zĹŻstane v historii (nenĂ­ fyzicky smazĂˇna).
  Future<void> _stornovatZakazku(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stornovat a znovu otevĹ™Ă­t?'),
        content: const Text(
          'Tato akce oznaÄŤĂ­ pĹŻvodnĂ­ fakturu jako "StornovĂˇno" (dobropis) a vrĂˇtĂ­ zakĂˇzku do stavu "PĹ™ijato". ZakĂˇzku tak budete moci znovu upravovat a poslĂ©ze vygenerovat novou fakturu.\n\nOpravdu chcete zakĂˇzku odemknout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ZRUĹ IT'),
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
            'Storno zakĂˇzky ${widget.zakazkaId}',
          );

          if (fakturaCislo.isNotEmpty) {
            final fakturaRef = FirebaseFirestore.instance
                .collection('faktury')
                .doc('${globalServisId}_$fakturaCislo');
            final fakturaDoc = await fakturaRef.get();

            if (fakturaDoc.exists) {
              await fakturaRef.update({'stav_platby': 'StornovĂˇno'});
            }
          }

          await FirebaseFirestore.instance
              .collection('zakazky')
              .doc(widget.documentId)
              .update({
            'stav_zakazky': 'PĹ™ijato',
            'zpusob_ukonceni': FieldValue.delete(),
            'forma_uhrady': FieldValue.delete(),
            'splatnost_dny': FieldValue.delete(),
            'cas_ukonceni': FieldValue.delete(),
            'faktura_cislo': FieldValue.delete(),
          });
          
          if (rezervaceId.isNotEmpty) {
            await FirebaseFirestore.instance.collection('planovac').doc(rezervaceId).update({
              'stav': 'PĹ™ijato na servis'
            });
          }

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Faktura stornovĂˇna a zakĂˇzka znovu otevĹ™ena.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Chyba pĹ™i stornovĂˇnĂ­: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  /// PĹ™epne stav zakĂˇzky (napĹ™. â€žPĹ™ijato" â†’ â€žV opravÄ›" â†’ â€žÄŚekĂˇ na dĂ­ly").
  /// Stav se zobrazuje jako barevnĂ˝ ĹˇtĂ­tek v kartÄ› zakĂˇzky.
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
    final List<String> moznostiPlatby = ['PĹ™evodem', 'HotovÄ›', 'Kartou'];
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
            'UkonÄŤenĂ­ a vyĂşÄŤtovĂˇnĂ­',
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
                            'ZpracovĂˇvĂˇm...',
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
                    'ZpĹŻsob Ăşhrady:',
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
                              if (val == 'HotovÄ›' || val == 'Kartou') {
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
                    title: const Text('Odeslat fakturu zĂˇkaznĂ­kovi na e-mail',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: emailZakaznika.isEmpty
                        ? const Text('ZĂˇkaznĂ­k nemĂˇ vyplnÄ›nĂ˝ e-mail',
                            style: TextStyle(color: Colors.red, fontSize: 12))
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
                    'ZakĂˇzka se pĹ™esune do Historie. Vygeneruje se PDF vyĂşÄŤtovĂˇnĂ­.',
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
                    label: const Text('DokonÄŤit a pĹ™edat k platbÄ›'),
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
                      'Nerealizuje se (ZruĹˇit)',
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
                child: const Text('ZPÄšT'),
              ),
          ],
        ),
      ),
    );
  }

  /// UkonÄŤĂ­ zakĂˇzku: vygeneruje finĂˇlnĂ­ fakturu (PDF), uloĹľĂ­ ji do Storage,
  /// vytvoĹ™Ă­ dokument v kolekci 'faktury', aktualizuje zĂˇznam vozidla (tachometr, STK)
  /// a pĹ™esune zakĂˇzku do stavu 'DokonÄŤeno'.
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
            double c = (double.tryParse(dil['cena_s_dph'].toString()) ?? 0.0);
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
          odesilatelJmeno = docNastaveni.data()?['nazev_servisu'] ?? 'Servis';
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

        // ÄŚĂ­taÄŤ v databĂˇzi zĹŻstĂˇvĂˇ roÄŤnĂ­
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
              
          // FormĂˇtovĂˇnĂ­ bez pomlÄŤek: PREFIX + ROK + MÄšSĂŤC + INKREMENT (napĹ™. FAK20260400001)
          String sequencePart = currentCount.toString().padLeft(5, '0');
          return '$prefix$yearPart$monthPart$sequencePart';
        });

        // ... Zbytek kĂłdu (DateTime splatnost = ted.add(...) atd.)

        // ... (Zbytek kĂłdu pro uloĹľenĂ­ faktury zĹŻstĂˇvĂˇ stejnĂ˝)

        DateTime splatnost = ted.add(Duration(days: splatnostDny));

        String stavPlatby = (celkovaSuma <= 0 || platba == 'HotovÄ›' || platba == 'Kartou')
            ? 'Uhrazeno'
            : 'ÄŚekĂˇ na platbu';

        await FirebaseFirestore.instance
            .collection('faktury')
            .doc('${globalServisId}_$cisloFaktury')
            .set({
          'servis_id': globalServisId,
          'cislo_faktury': cisloFaktury,
          'cislo_zakazky': widget.zakazkaId,
          'spz': widget.spz,
          'zakaznik_id': zakaznik['id_zakaznika'] ?? '',
          'zakaznik_jmeno': zakaznik['jmeno'] ?? 'NeznĂˇmĂ˝ zĂˇkaznĂ­k',
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
                  '$odesilatelJmeno (pĹ™es TORKIS) <jan.svihalek00@gmail.com>',
              'message': {
                'subject':
                    'Faktura - ZakĂˇzka ${widget.zakazkaId} ($odesilatelJmeno)',
                'html': '''
                  <div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; margin: 0 auto; border: 1px solid #eee; padding: 20px; border-radius: 10px;">
                    <h2 style="color: #2196F3; border-bottom: 2px solid #2196F3; padding-bottom: 10px;">DobrĂ˝ den,</h2>
                    <p>v pĹ™Ă­loze VĂˇm zasĂ­lĂˇme fakturu za provedenĂ© servisnĂ­ prĂˇce na VaĹˇem vozidle <b>${data['spz']}</b> v naĹˇem servisu.</p>
                    <div style="text-align: center; margin: 30px 0;">
                      <a href="$pdfUrl" style="background-color: #2196F3; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 16px; display: inline-block;">Zobrazit a stĂˇhnout fakturu</a>
                    </div>
                    <p>DÄ›kujeme za vyuĹľitĂ­ naĹˇich sluĹľeb. V pĹ™Ă­padÄ› jakĂ˝chkoliv dotazĹŻ na tento e-mail jednoduĹˇe odpovÄ›zte, zprĂˇva nĂˇm bude doruÄŤena.</p>
                    <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
                    <p style="font-size: 12px; color: #777;">Tento e-mail byl vygenerovĂˇn automaticky systĂ©mem <b>TORKIS.cz</b> pro servis <b>$odesilatelJmeno</b>.</p>
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

      await FirebaseFirestore.instance
          .collection('zakazky')
          .doc(widget.documentId)
          .update({
        'stav_zakazky': 'DokonÄŤeno',
        'zpusob_ukonceni': zpusob,
        'forma_uhrady': platba,
        'splatnost_dny': splatnostDny,
        'celkova_castka': celkovaSuma,
        'cas_ukonceni': FieldValue.serverTimestamp(),
        if (cisloFaktury.isNotEmpty) 'faktura_cislo': cisloFaktury,
        if (pdfUrl.isNotEmpty) 'vystupni_protokol_url': pdfUrl,
      });
      
      // --- TADY BYLA TA CHYBA (ZAPOMENUTĂť KĂ“D PRO PLĂNOVAÄŚ) ---
      String rezervaceId = data['rezervace_id']?.toString() ?? '';
      if (rezervaceId.isNotEmpty) {
        try {
          await FirebaseFirestore.instance.collection('planovac').doc(rezervaceId).update({
            'stav': 'DokonÄŤeno'
          });
        } catch (e) {
          debugPrint("Chyba pĹ™i updatovĂˇnĂ­ plĂˇnovaÄŤe na DokonÄŤeno: $e");
        }
      }
      // --------------------------------------------------------

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(odeslatEmail && !zruseno
                ? 'ZakĂˇzka ukonÄŤena a faktura odeslĂˇna.'
                : 'ZakĂˇzka ĂşspÄ›ĹˇnÄ› ukonÄŤena.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Chyba ukonÄŤenĂ­: $e");
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chyba pĹ™i ukonÄŤovĂˇnĂ­: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
          ),
        );
      }
    }
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10, color: color, fontWeight: FontWeight.bold),
            ),
          ],
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
          final aktualniStav = data['stav_zakazky'] ?? 'PĹ™ijato';
          final stav = data['stav_vozidla'] as Map<String, dynamic>? ?? {};
          final zakaznik = data['zakaznik'] as Map<String, dynamic>? ?? {};
          _zakaznikJmeno = zakaznik['jmeno']?.toString() ?? '';
          _zakaznikEmail = zakaznik['email']?.toString() ?? '';
          
          final rawUrls = data['fotografie_urls'];
          final Map<String, dynamic> imageUrlsByCategoryRaw = {};
          if (rawUrls is Map) {
            imageUrlsByCategoryRaw.addAll(Map<String, dynamic>.from(rawUrls));
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

          final bool isCompleted = aktualniStav == 'DokonÄŤeno';

          List<String> dostupneStavy =
              stavyZakazky.where((s) => s != 'DokonÄŤeno').toList();
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
                                'DokonÄŤeno (UzamÄŤeno)',
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
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Informace o zakĂˇzce',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'PĹ™ijato: ${_formatDate(data['cas_prijeti'])}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (data['prijal_jmeno'] != null)
                                    Text(
                                      'PĹ™ijal: ${data['prijal_jmeno']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                                      ),
                                    ),
                                ],
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
                                                  'ZĂˇkaznĂ­k',
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
                                        if (globalServisId != null &&
                                            data['spz'] != null) {
                                          final vozidloDocId =
                                              '${globalServisId}_${data['spz']}';
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
                                                  ? 'NeznĂˇmĂ© vozidlo'
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
                            if (prijemFotky.isNotEmpty) ...[
                              const Divider(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FotodokumentaceScreen(
                                          fotografieUrls: prijemFotky,
                                          titulek: 'PĹ™Ă­jem vozidla',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.camera_alt_outlined),
                                  label: Text('Fotodokumentace z pĹ™Ă­jmu (${prijemFotky.length})'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                    side: const BorderSide(color: Colors.blue),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (pozadavky.isNotEmpty) ...[
                      const Text(
                        'PoĹľadavky od zĂˇkaznĂ­ka (k Ĺ™eĹˇenĂ­)',
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
                                      if (!isMechanik)
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              color: Colors.red),
                                          tooltip: 'Smazat poĹľadavek',
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
                      'ZaznamenanĂ© Ăşkony',
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
                              'ZatĂ­m nebyly pĹ™idĂˇny ĹľĂˇdnĂ© prĂˇce.',
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
                              'typ': 'PrĂˇce',
                              'nazev': 'PrĂˇce',
                              'cislo': '',
                              'mnozstvi': prace['delka_prace'] ?? 1,
                              'jednotka': 'h',
                              'cena_s_dph': prace['cena_s_dph'],
                              'sleva': 0.0,
                            });
                          }
                          for (var d
                              in (prace['pouzite_dily'] as List<dynamic>? ??
                                  [])) {
                            polozky.add({
                              'typ': 'MateriĂˇl',
                              'nazev': d['nazev'],
                              'cislo': d['cislo'] ?? '',
                              'mnozstvi': d['pocet'] ?? 1,
                              'jednotka': 'ks',
                              'cena_s_dph': d['cena_s_dph'],
                              'sleva': 0.0,
                            });
                          }
                        }

                        double celkemUkon = 0.0;
                        for (var p in polozky) {
                          double pMnoz =
                              double.tryParse(p['mnozstvi'].toString()) ?? 1.0;
                          double pCena =
                              double.tryParse(p['cena_s_dph'].toString()) ??
                                  0.0;
                          double pSleva =
                              double.tryParse(p['sleva']?.toString() ?? '0') ??
                                  0.0;
                          celkemUkon += (pMnoz * pCena) * (1 - (pSleva / 100));
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
                                        '${prace['nazev']} ${!isMechanik ? "(Celkem: ${celkemUkon.toStringAsFixed(2)} KÄŤ)" : ""}',
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
                                    if (!isCompleted && !isMechanik)
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
                                    'PoloĹľky:',
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
                                    double pSleva = double.tryParse(
                                            p['sleva']?.toString() ?? '0') ??
                                        0.0;

                                    String pJedn = p['jednotka'] ?? 'ks';
                                    String cistyMnoz = pMnoz
                                        .toString()
                                        .replaceAll(
                                            RegExp(r"([.]*0)(?!.*\d)"), "");
                                    String slevaStr = pSleva > 0
                                        ? ' (-${pSleva.toStringAsFixed(0)}%)'
                                        : '';

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
                                        'â€˘ [${p['typ']}] $nDisp - $cistyMnoz $pJedn$slevaStr ${!isMechanik ? "- ${(pMnoz * pCena * (1 - pSleva / 100)).toStringAsFixed(2)} KÄŤ" : ""}',
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
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FotodokumentaceScreen(
                                              fotografieUrls: fotky.map((e) => e.toString()).toList(),
                                              titulek: prace['nazev'] ?? 'Ăškon',
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.photo_library),
                                      label: Text('Zobrazit fotodokumentaci (${fotky.length})'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.blue,
                                        side: const BorderSide(color: Colors.blue),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              // ĹĂDEK AKCĂŤ (dole)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (!isCompleted)
                          _buildActionBtn(
                            icon: Icons.add_circle_outline,
                            label: 'PĹ™idat\nĂşkon',
                            color: Colors.blue,
                            onTap: () => _openAddWorkDialog(context),
                          ),
                        if (!isCompleted && !isMechanik)
                          _buildActionBtn(
                            icon: Icons.flag_outlined,
                            label: 'Fakturovat/\nUkonÄŤit',
                            color: Colors.orange,
                            onTap: () => _ukoncitZakazkuDialog(context, data,
                                stav, zakaznik, imageUrlsByCategoryRaw),
                          ),
                        _buildActionBtn(
                          icon: Icons.chat_outlined,
                          label: 'Komunikace',
                          color: Colors.teal,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ZakazkaKomunikacePage(
                                documentId: widget.documentId,
                                zakazkaId: widget.zakazkaId,
                                spz: widget.spz,
                                zakaznikJmeno: _zakaznikJmeno,
                                zakaznikEmail: _zakaznikEmail,
                              ),
                            ),
                          ),
                        ),
                        if (!isCompleted && !isMechanik)
                          _buildActionBtn(
                            icon: Icons.request_quote_outlined,
                            label: 'NacenÄ›nĂ­',
                            color: Colors.purple,
                            onTap: () => _odeslatKNaceneni(context, data),
                          ),
                        _buildActionBtn(
                          icon: Icons.picture_as_pdf_outlined,
                          label: 'Protokol',
                          color: Colors.redAccent,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                    title: const Text('NĂˇhled protokolu')),
                                body: PdfPreview(
                                  build: (format) async {
                                    String sNazev = 'Servis';
                                    String sIco = '';
                                    if (globalServisId != null) {
                                      final docNast = await FirebaseFirestore
                                          .instance
                                          .collection('nastaveni_servisu')
                                          .doc(globalServisId)
                                          .get();
                                      sNazev =
                                          docNast.data()?['nazev_servisu'] ??
                                              'Servis';
                                      sIco =
                                          docNast.data()?['ico_servisu'] ?? '';
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
                                      child: CircularProgressIndicator()),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (isCompleted && !isMechanik)
                          _buildActionBtn(
                            icon: Icons.settings_backup_restore,
                            label: 'Stornovat\nfakturu',
                            color: Colors.red,
                            onTap: () => _stornovatZakazku(context),
                          ),
                      ],
                    ),
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
