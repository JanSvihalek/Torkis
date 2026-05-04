import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'foto_nahled.dart';

class ZpravaKarta extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;

  const ZpravaKarta({super.key, required this.data, required this.isDark});

  String _formatCas(dynamic ts) {
    if (ts == null) return '';
    final dt = (ts as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  bool get _isFromZakaznik =>
      data['from_zakaznik'] == true || data['autor'] == 'Zákazník';

  @override
  Widget build(BuildContext context) {
    if (data['typ'] == 'naceneni') return _buildNaceneniCard(context);
    final text = data['text']?.toString() ?? '';
    final fotoUrls = (data['foto_urls'] as List<dynamic>? ?? []).cast<String>();
    final odeslanEmail = data['odeslan_email'] as bool? ?? false;
    final autor = data['autor']?.toString() ?? '';
    final isZakaznik = _isFromZakaznik;

    final bubbleColor = isZakaznik
        ? Colors.blue
        : (isDark ? const Color(0xFF1E3A5F) : const Color(0xFFF0F4FF));
    final textColor = isZakaznik
        ? Colors.white
        : (isDark ? Colors.white : Colors.black87);
    final metaColor = isZakaznik
        ? Colors.blue.withValues(alpha: 0.6)
        : Colors.grey;

    return Align(
      alignment: isZakaznik ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment: isZakaznik
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 3, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isZakaznik && odeslanEmail) ...[
                    const Icon(Icons.email, size: 11, color: Colors.green),
                    const SizedBox(width: 3),
                  ],
                  Text(autor,
                      style: TextStyle(
                          fontSize: 11,
                          color: metaColor,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  Text(_formatCas(data['cas']),
                      style: TextStyle(fontSize: 11, color: metaColor)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isZakaznik ? 14 : 4),
                  bottomRight: Radius.circular(isZakaznik ? 4 : 14),
                ),
                border: isZakaznik
                    ? null
                    : Border.all(
                        color:
                            isDark ? Colors.grey[700]! : const Color(0xFFDCE4F8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (text.isNotEmpty)
                    Text(text,
                        style: TextStyle(fontSize: 14, color: textColor)),
                  if (fotoUrls.isNotEmpty) ...[
                    if (text.isNotEmpty) const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNaceneniCard(BuildContext context) {
    final stav = data['stav_schvaleni']?.toString() ?? 'cekajici';
    final castka = (data['castka'] as num?)?.toDouble() ?? 0.0;
    final text = data['text']?.toString() ?? '';
    final autor = data['autor']?.toString() ?? '';

    Color stavColor;
    String stavLabel;
    switch (stav) {
      case 'schvaleno':
        stavColor = Colors.green;
        stavLabel = '✓ Schváleno zákazníkem';
        break;
      case 'zamitnuto':
        stavColor = Colors.red;
        stavLabel = '✗ Zamítnuto zákazníkem';
        break;
      default:
        stavColor = Colors.orange;
        stavLabel = '⏳ Čeká na schválení zákazníka';
    }

    final bg = isDark ? const Color(0xFF1A2A1A) : const Color(0xFFF1FBF5);
    final borderCol = isDark ? Colors.green.shade800 : Colors.green.shade200;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 3, left: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(autor,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  Text(_formatCas(data['cas']),
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(14),
                ),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.request_quote_outlined,
                          color: Colors.green.shade700, size: 18),
                      const SizedBox(width: 6),
                      Text('Nacenění opravy',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.green.shade700)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    NumberFormat.currency(
                            locale: 'cs_CZ', symbol: 'Kč', decimalDigits: 2)
                        .format(castka),
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87),
                  ),
                  if (text.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(text,
                        style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[300] : Colors.grey[700])),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: stavColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(stavLabel,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: stavColor)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _zobrazitFoto(BuildContext context, List<String> urls, int startIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FotoNahled(urls: urls, startIndex: startIndex),
      ),
    );
  }
}
