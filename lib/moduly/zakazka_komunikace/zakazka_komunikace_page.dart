import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'zprava_karta.dart';
import 'pridat_zpravu_sheet.dart';

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
    _oznacitJakoPrectene();
  }

  Future<void> _oznacitJakoPrectene() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('zakazky')
          .doc(widget.documentId)
          .collection('zakaznik_zpravy')
          .where('from_zakaznik', isEqualTo: true)
          .get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snap.docs) {
        if (doc.data()['precteno'] != true) {
          batch.update(doc.reference, {'precteno': true});
        }
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Chyba při označování zpráv jako přečtených: $e');
    }
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
    if (mounted) {
      setState(() {
        _portalToken = token;
        _isLoadingToken = false;
      });
    }
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
      builder: (_) => PridatZpravuSheet(
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
        backgroundColor: isDark ? const Color(0xFF1E3A5F) : Colors.white,
        elevation: 0,
        title: const Text('Komunikace',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildZakaznikInfoCard(isDark),
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
                        Text('Napište zákazníkovi první zprávu',
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  reverse: true,
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    return ZpravaKarta(data: data, isDark: isDark);
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

  Widget _buildZakaznikInfoCard(bool isDark) {
    final hasEmail = widget.zakaznikEmail.isNotEmpty;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A5F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.teal.withValues(alpha: 0.3), width: 1.5),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.teal.withValues(alpha: 0.12),
            child: const Icon(Icons.person_outline, color: Colors.teal, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.zakaznikJmeno.isNotEmpty
                      ? widget.zakaznikJmeno
                      : 'Zákazník',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  'Zakázka ${widget.zakazkaId} · ${widget.spz}',
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.email_outlined,
                        size: 12,
                        color: hasEmail ? Colors.teal : Colors.orange[400]),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        hasEmail ? widget.zakaznikEmail : 'bez emailu',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            color: hasEmail
                                ? (isDark ? Colors.grey[400] : Colors.grey[600])
                                : Colors.orange[400]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortalLinkCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A5F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1.5),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
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
            'Zákazník může sledovat průběh zakázky níže:',
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
                          isDark ? const Color(0xFF1E3A5F) : Colors.grey[100],
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
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
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
