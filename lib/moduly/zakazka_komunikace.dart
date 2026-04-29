import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'auth_gate.dart';

const String _portalBaseUrl = 'https://app.torkis.cz/zakazka';

class ZakazkaKomunikacePage extends StatefulWidget {
  final String documentId;
  final String zakazkaId;
  final String spz;
  final String zakaznikJmeno;
  final String zakaznikEmail;

  const ZakazkaKomunikacePage({
    super.key,
    required this.documentId,
    required this.zakazkaId,
    required this.spz,
    required this.zakaznikJmeno,
    required this.zakaznikEmail,
  });

  @override
  State<ZakazkaKomunikacePage> createState() => _ZakazkaKomunikacePageState();
}

class _ZakazkaKomunikacePageState extends State<ZakazkaKomunikacePage> {
  String? _portalToken;
  bool _isLoadingToken = true;

  @override
  void initState() {
    super.initState();
    _nactiNeboVytvorToken();
  }

  Future<void> _nactiNeboVytvorToken() async {
    final doc = await FirebaseFirestore.instance
        .collection('zakazky')
        .doc(widget.documentId)
        .get();
    String? token = doc.data()?['portal_token']?.toString();
    if (token == null || token.isEmpty) {
      token = _generateToken();
      await FirebaseFirestore.instance
          .collection('zakazky')
          .doc(widget.documentId)
          .update({'portal_token': token});
    }
    if (mounted)
      setState(() {
        _portalToken = token;
        _isLoadingToken = false;
      });
  }

  String _generateToken() {
    final rand = DateTime.now().millisecondsSinceEpoch;
    final extra = widget.documentId.hashCode.abs();
    final combined = (rand ^ extra).toRadixString(36);
    return (combined + combined).substring(0, 12);
  }

  String get _portalUrl => '$_portalBaseUrl/$_portalToken';

  void _kopirovatOdkaz() {
    Clipboard.setData(ClipboardData(text: _portalUrl));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Odkaz zkopírován do schránky'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ));
  }

  void _otevritPridatZpravu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PridatZpravuSheet(
        documentId: widget.documentId,
        zakazkaId: widget.zakazkaId,
        spz: widget.spz,
        zakaznikEmail: widget.zakaznikEmail,
        zakaznikJmeno: widget.zakaznikJmeno,
        portalUrl: _portalUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        title: const Text('Komunikace se zákazníkem',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildPortalLinkCard(isDark),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('zakazky')
                  .doc(widget.documentId)
                  .collection('zakaznik_zpravy')
                  .orderBy('cas', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Chyba: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 64,
                            color:
                                isDark ? Colors.grey[700] : Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Zatím žádné zprávy',
                            style: TextStyle(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                                fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Přidejte první zprávu pro zákazníka',
                            style: TextStyle(
                                color: isDark
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                                fontSize: 13)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    return _ZpravaKarta(data: data, isDark: isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _otevritPridatZpravu,
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Přidat zprávu'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildPortalLinkCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text('Zákaznický portál',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.blue)),
              const Spacer(),
              if (_isLoadingToken)
                const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Zákazník může sledovat průběh zakázky na tomto odkazu:',
            style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          if (_portalToken != null)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _portalUrl,
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontFamily: 'monospace'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _kopirovatOdkaz,
                  icon: const Icon(Icons.copy, color: Colors.blue),
                  tooltip: 'Kopírovat odkaz',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Karta jedné zprávy ────────────────────────────────────────────────────────

class _ZpravaKarta extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;

  const _ZpravaKarta({required this.data, required this.isDark});

  String _formatCas(dynamic ts) {
    if (ts == null) return '';
    final dt = (ts as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final text = data['text']?.toString() ?? '';
    final fotoUrls = (data['foto_urls'] as List<dynamic>? ?? []).cast<String>();
    final odeslanEmail = data['odeslan_email'] as bool? ?? false;
    final autor = data['autor']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(autor,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              if (odeslanEmail)
                const Icon(Icons.email, size: 14, color: Colors.green),
              const SizedBox(width: 4),
              Text(_formatCas(data['cas']),
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
          if (fotoUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: fotoUrls.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _zobrazitFoto(context, fotoUrls, i),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(fotoUrls[i],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              color: Colors.grey)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _zobrazitFoto(BuildContext context, List<String> urls, int startIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FotoNahled(urls: urls, startIndex: startIndex),
      ),
    );
  }
}

// ── Fullscreen náhled fotek ───────────────────────────────────────────────────

class _FotoNahled extends StatefulWidget {
  final List<String> urls;
  final int startIndex;
  const _FotoNahled({required this.urls, required this.startIndex});

  @override
  State<_FotoNahled> createState() => _FotoNahledState();
}

class _FotoNahledState extends State<_FotoNahled> {
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
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
      appBar:
          AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: PageView.builder(
        controller: _ctrl,
        itemCount: widget.urls.length,
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: Image.network(widget.urls[i],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                    color: Colors.white, size: 64)),
          ),
        ),
      ),
    );
  }
}

// ── Bottom sheet: přidat zprávu ───────────────────────────────────────────────

class _PridatZpravuSheet extends StatefulWidget {
  final String documentId;
  final String zakazkaId;
  final String spz;
  final String zakaznikEmail;
  final String zakaznikJmeno;
  final String portalUrl;

  const _PridatZpravuSheet({
    required this.documentId,
    required this.zakazkaId,
    required this.spz,
    required this.zakaznikEmail,
    required this.zakaznikJmeno,
    required this.portalUrl,
  });

  @override
  State<_PridatZpravuSheet> createState() => _PridatZpravuSheetState();
}

class _PridatZpravuSheetState extends State<_PridatZpravuSheet> {
  final _textCtrl = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _foto = [];
  bool _odeslatEmail = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _fotitFoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (photo != null) setState(() => _foto.add(photo));
  }

  Future<void> _pridatFoto() async {
    final photos =
        await _picker.pickMultiImage(imageQuality: 70, maxWidth: 1280);
    if (photos.isNotEmpty) setState(() => _foto.addAll(photos));
  }

  void _vyberZdrojFota() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.camera_alt_outlined, color: Colors.blue),
              ),
              title: const Text('Vyfotit'),
              onTap: () {
                Navigator.pop(context);
                _fotitFoto();
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.photo_library_outlined, color: Colors.blue),
              ),
              title: const Text('Vybrat z galerie'),
              onTap: () {
                Navigator.pop(context);
                _pridatFoto();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _odeslat() async {
    if (_textCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Zadejte text zprávy.'),
          backgroundColor: Colors.orange));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final servisId = globalServisId;
      final autor = globalUserJmeno ??
          FirebaseAuth.instance.currentUser?.email ??
          'Servis';

      // Načtení názvu a emailu servisu pro replyTo
      String sNazev = autor;
      String sEmail = '';
      if (servisId != null) {
        final docNast = await FirebaseFirestore.instance
            .collection('nastaveni_servisu')
            .doc(servisId)
            .get();
        if (docNast.exists) {
          sNazev = docNast.data()?['nazev_servisu'] ?? autor;
          sEmail = docNast.data()?['email_servisu'] ?? '';
        }
      }

      // Nahrání fotek
      final List<String> fotoUrls = [];
      for (int i = 0; i < _foto.length; i++) {
        final bytes = await _foto[i].readAsBytes();
        final ref = FirebaseStorage.instance.ref().child(
            'servisy/$servisId/zakazky/${widget.documentId}/zpravy/${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
        await ref.putData(bytes);
        fotoUrls.add(await ref.getDownloadURL());
      }

      // Uložení zprávy
      await FirebaseFirestore.instance
          .collection('zakazky')
          .doc(widget.documentId)
          .collection('zakaznik_zpravy')
          .add({
        'text': _textCtrl.text.trim(),
        'foto_urls': fotoUrls,
        'cas': FieldValue.serverTimestamp(),
        'autor': autor,
        'odeslan_email': _odeslatEmail && widget.zakaznikEmail.isNotEmpty,
      });

      // Email zákazníkovi
      if (_odeslatEmail && widget.zakaznikEmail.isNotEmpty) {
        final Map<String, dynamic> mailDoc = {
          'to': widget.zakaznikEmail,
          'from': '$sNazev (přes TORKIS) <jan.svihalek00@gmail.com>',
          'message': {
            'subject':
                'Aktualizace zakázky ${widget.zakazkaId} – ${widget.spz}',
            'html': _buildEmailHtml(autor, sNazev),
          },
        };
        if (sEmail.isNotEmpty && sEmail.contains('@')) {
          mailDoc['replyTo'] = sEmail;
        }
        await FirebaseFirestore.instance.collection('maily').add(mailDoc);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chyba: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _buildEmailHtml(String autor, String sNazev) {
    final text = _textCtrl.text.trim().replaceAll('\n', '<br>');
    return '''
<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; margin: 0 auto; border: 1px solid #eee; padding: 20px; border-radius: 10px;">
  <h2 style="color: #2196F3; border-bottom: 2px solid #2196F3; padding-bottom: 10px;">Dobrý den,</h2>
  <p>máme pro Vás aktualizaci k zakázce <b>${widget.zakazkaId}</b> na vozidle <b>${widget.spz}</b> v servisu $sNazev.</p>
  <div style="background: #f5f9ff; border-left: 4px solid #2196F3; padding: 15px; margin: 20px 0; border-radius: 0 6px 6px 0;">
    <p style="margin: 0; line-height: 1.6;">$text</p>
  </div>
  <p>Průběh vaší zakázky můžete sledovat online:</p>
  <div style="text-align: center; margin: 30px 0;">
    <a href="${widget.portalUrl}"
       style="background-color: #2196F3; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; font-weight: bold; font-size: 16px; display: inline-block;">
      Sledovat zakázku online
    </a>
  </div>
  <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
  <p style="font-size: 12px; color: #777;">Tento e-mail byl vygenerován automaticky systémem <b>TORKIS.cz</b> pro servis <b>$sNazev</b>. Odesílatel zprávy: $autor.</p>
</div>''';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 16),
            const Text('Nová zpráva pro zákazníka',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
                '${widget.zakaznikJmeno.isNotEmpty ? widget.zakaznikJmeno : 'Zákazník'} – ${widget.spz}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: _textCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Např. Nalezena závada na brzdách, čekáme na díly...',
                filled: true,
                fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            // Thumbnaily přidaných fotek
            if (_foto.isNotEmpty) ...[
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _foto.length,
                  itemBuilder: (_, i) => Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(_foto[i].path),
                              width: 60, height: 60, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => setState(() => _foto.removeAt(i)),
                          child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.close,
                                  size: 12, color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _vyberZdrojFota,
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label: const Text('Foto'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 12),
                if (widget.zakaznikEmail.isNotEmpty)
                  Expanded(
                    child: SwitchListTile(
                      value: _odeslatEmail,
                      onChanged: (v) => setState(() => _odeslatEmail = v),
                      title: const Text('Odeslat emailem',
                          style: TextStyle(fontSize: 13)),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: Colors.blue,
                    ),
                  ),
                if (widget.zakaznikEmail.isEmpty)
                  const Expanded(
                    child: Text('Zákazník nemá email',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _odeslat,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label: Text(_isSaving ? 'Odesílám...' : 'Odeslat zprávu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
