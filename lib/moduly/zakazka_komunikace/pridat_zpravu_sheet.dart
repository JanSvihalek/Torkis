import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../auth_gate.dart';

class PridatZpravuSheet extends StatefulWidget {
  final String documentId;
  final String zakazkaId;
  final String spz;
  final String zakaznikEmail;
  final String zakaznikJmeno;
  final String portalUrl;

  const PridatZpravuSheet({
    super.key,
    required this.documentId,
    required this.zakazkaId,
    required this.spz,
    required this.zakaznikEmail,
    required this.zakaznikJmeno,
    required this.portalUrl,
  });

  @override
  State<PridatZpravuSheet> createState() => _PridatZpravuSheetState();
}

class _PridatZpravuSheetState extends State<PridatZpravuSheet> {
  final _textCtrl = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _foto = [];
  bool _odeslatEmail = true;
  bool _isSaving = false;
  List<String> _sablony = [];
  bool _priloztNaceneni = false;
  final _castkaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nactiSablony();
  }

  Future<void> _nactiSablony() async {
    if (globalServisId == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('nastaveni_servisu')
          .doc(globalServisId)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _sablony = List<String>.from(doc.data()?['sablony_zprav'] ?? []);
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _castkaCtrl.dispose();
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
    if (_textCtrl.text.trim().isEmpty && !_priloztNaceneni) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Zadejte text zprávy.'),
          backgroundColor: Colors.orange));
      return;
    }
    if (_priloztNaceneni) {
      final castka =
          double.tryParse(_castkaCtrl.text.replaceAll(',', '.')) ?? 0.0;
      if (castka <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Zadejte platnou cenu nacenění.'),
            backgroundColor: Colors.orange));
        return;
      }
    }
    setState(() => _isSaving = true);
    try {
      final servisId = globalServisId;
      final autor = globalUserJmeno ??
          FirebaseAuth.instance.currentUser?.email ??
          'Servis';

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

      final List<String> fotoUrls = [];
      for (int i = 0; i < _foto.length; i++) {
        final bytes = await _foto[i].readAsBytes();
        final ref = FirebaseStorage.instance.ref().child(
            'servisy/$servisId/zakazky/${widget.documentId}/zpravy/${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
        await ref.putData(bytes);
        fotoUrls.add(await ref.getDownloadURL());
      }

      final Map<String, dynamic> msgData = {
        'text': _textCtrl.text.trim(),
        'foto_urls': fotoUrls,
        'cas': FieldValue.serverTimestamp(),
        'autor': autor,
        'odeslan_email': _odeslatEmail && widget.zakaznikEmail.isNotEmpty,
      };
      if (_priloztNaceneni) {
        msgData['typ'] = 'naceneni';
        msgData['castka'] =
            double.tryParse(_castkaCtrl.text.replaceAll(',', '.')) ?? 0.0;
        msgData['stav_schvaleni'] = 'cekajici';
      }
      await FirebaseFirestore.instance
          .collection('zakazky')
          .doc(widget.documentId)
          .collection('zakaznik_zpravy')
          .add(msgData);

      if (_odeslatEmail && widget.zakaznikEmail.isNotEmpty) {
        final Map<String, dynamic> mailDoc = {
          'to': widget.zakaznikEmail,
          'from': '$sNazev (přes TORKIS) <jan.svihalek00@gmail.com>',
          'message': {
            'subject': _priloztNaceneni
                ? 'Nacenění zakázky ${widget.zakazkaId} – ${widget.spz}'
                : 'Aktualizace zakázky ${widget.zakazkaId} – ${widget.spz}',
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
    final naceneniBlock = _priloztNaceneni
        ? '''
  <div style="background:#f1fbf5;border:2px solid #a5d6a7;border-radius:10px;padding:18px;margin:20px 0;">
    <p style="font-weight:700;color:#2e7d32;margin:0 0 8px;">💰 Nacenění opravy</p>
    <p style="font-size:26px;font-weight:800;color:#1a1a1a;margin:0 0 10px;">${_castkaCtrl.text.replaceAll('.', ',')} Kč</p>
    <p style="color:#555;font-size:13px;margin:0;">Pro schválení nebo zamítnutí nacenění klikněte na tlačítko níže.</p>
  </div>'''
        : '';
    return '''
<div style="font-family: Arial, sans-serif; color: #333; max-width: 600px; margin: 0 auto; border: 1px solid #eee; padding: 20px; border-radius: 10px;">
  <h2 style="color: #2196F3; border-bottom: 2px solid #2196F3; padding-bottom: 10px;">Dobrý den,</h2>
  <p>máme pro Vás ${_priloztNaceneni ? 'nacenění' : 'aktualizaci'} k zakázce <b>${widget.zakazkaId}</b> na vozidle <b>${widget.spz}</b> v servisu $sNazev.</p>
  $naceneniBlock
  ${text.isNotEmpty ? '''<div style="background: #f5f9ff; border-left: 4px solid #2196F3; padding: 15px; margin: 20px 0; border-radius: 0 6px 6px 0;"><p style="margin: 0; line-height: 1.6;">$text</p></div>''' : ''}
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
            if (_sablony.isNotEmpty) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _sablony
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text(s,
                                  style: const TextStyle(fontSize: 12)),
                              backgroundColor: isDark
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.teal.withValues(alpha: 0.08),
                              side: BorderSide(
                                  color: Colors.teal.withValues(alpha: 0.4)),
                              onPressed: () {
                                final current = _textCtrl.text;
                                _textCtrl.text = current.isEmpty
                                    ? s
                                    : '$current\n$s';
                                _textCtrl.selection =
                                    TextSelection.collapsed(
                                        offset: _textCtrl.text.length);
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),
            ],
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
            const SizedBox(height: 10),
            Row(
              children: [
                Switch(
                  value: _priloztNaceneni,
                  activeThumbColor: Colors.green,
                  onChanged: (v) => setState(() => _priloztNaceneni = v),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.request_quote_outlined,
                    color: Colors.green, size: 20),
                const SizedBox(width: 6),
                const Text('Přiložit nacenění',
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            if (_priloztNaceneni) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _castkaCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Cena celkem',
                  suffixText: 'Kč',
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1A2A1A)
                      : const Color(0xFFF1FBF5),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Colors.green.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.green, width: 2),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
            const SizedBox(height: 12),
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
                          child: kIsWeb
                              ? Image.network(_foto[i].path,
                                  width: 60, height: 60, fit: BoxFit.cover)
                              : Image.file(File(_foto[i].path),
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
                      activeThumbColor: Colors.blue,
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
