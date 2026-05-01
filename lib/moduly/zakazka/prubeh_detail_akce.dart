import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/pdf_generator.dart';
import '../auth_gate.dart';
import '../zakazka_komunikace/zakazka_komunikace_page.dart';
import '../fakturace/faktura_detail.dart';

/// Spodní lišta akcí na detailu zakázky.
class AkceLista extends StatelessWidget {
  final bool isDark;
  final bool isCompleted;
  final bool isMechanik;
  final Map<String, dynamic> data;
  final Map<String, dynamic> stav;
  final Map<String, dynamic> zakaznik;
  final Map<String, dynamic> imageUrls;
  final String documentId;
  final String zakazkaId;
  final String spz;
  final String zakaznikJmeno;
  final String zakaznikEmail;

  final VoidCallback onPridatUkon;
  final VoidCallback onUkoncit;
  final VoidCallback onNaceneni;
  final VoidCallback onStornovat;

  const AkceLista({
    super.key,
    required this.isDark,
    required this.isCompleted,
    required this.isMechanik,
    required this.data,
    required this.stav,
    required this.zakaznik,
    required this.imageUrls,
    required this.documentId,
    required this.zakazkaId,
    required this.spz,
    required this.zakaznikJmeno,
    required this.zakaznikEmail,
    required this.onPridatUkon,
    required this.onUkoncit,
    required this.onNaceneni,
    required this.onStornovat,
  });

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
    return Container(
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
                  label: 'Přidat\núkon',
                  color: Colors.blue,
                  onTap: onPridatUkon,
                ),
              if (!isCompleted && !isMechanik)
                _buildActionBtn(
                  icon: Icons.receipt_long_outlined,
                  label: 'Fakturovat/\nUkončit',
                  color: Colors.orange,
                  onTap: onUkoncit,
                ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('zakazky')
                    .doc(documentId)
                    .collection('zakaznik_zpravy')
                    .where('from_zakaznik', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  final neprectenych = snapshot.data?.docs
                          .where((d) =>
                              (d.data() as Map<String, dynamic>)['precteno'] !=
                              true)
                          .length ??
                      0;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildActionBtn(
                        icon: Icons.chat_outlined,
                        label: 'Komunikace',
                        color:
                            neprectenych > 0 ? Colors.orange : Colors.teal,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ZakazkaKomunikacePage(
                              documentId: documentId,
                              zakazkaId: zakazkaId,
                              spz: spz,
                              zakaznikJmeno: zakaznikJmeno,
                              zakaznikEmail: zakaznikEmail,
                            ),
                          ),
                        ),
                      ),
                      if (neprectenych > 0)
                        Positioned(
                          top: 0,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                                minWidth: 18, minHeight: 18),
                            child: Text(
                              neprectenych > 9 ? '9+' : '$neprectenych',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (!isCompleted && !isMechanik)
                _buildActionBtn(
                  icon: Icons.request_quote_outlined,
                  label: 'Nacenění',
                  color: Colors.purple,
                  onTap: onNaceneni,
                ),
              _buildActionBtn(
                icon: Icons.picture_as_pdf_outlined,
                label: 'Protokol\npříjmu',
                color: Colors.redAccent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar:
                          AppBar(title: const Text('Náhled protokolu')),
                      body: PdfPreview(
                        build: (format) async {
                          String sNazev = 'Servis';
                          String sIco = '';
                          if (globalServisId != null) {
                            final docNast = await FirebaseFirestore.instance
                                .collection('nastaveni_servisu')
                                .doc(globalServisId)
                                .get();
                            sNazev =
                                docNast.data()?['nazev_servisu'] ?? 'Servis';
                            sIco = docNast.data()?['ico_servisu'] ?? '';
                          }
                          return await GlobalPdfGenerator.generateDocument(
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
                        loadingWidget:
                            const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                ),
              ),
              if (isCompleted &&
                  !isMechanik &&
                  (data['faktura_cislo']?.toString().isNotEmpty == true))
                _buildActionBtn(
                  icon: Icons.receipt_long,
                  label: 'Zobrazit\nfakturu',
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FakturaDetailScreen(
                        fakturaDocId:
                            '${globalServisId}_${data['faktura_cislo']}',
                        zakazkaId: zakazkaId,
                      ),
                    ),
                  ),
                ),
              if (isCompleted && !isMechanik)
                _buildActionBtn(
                  icon: Icons.settings_backup_restore,
                  label: 'Stornovat fakturu/\notevřít zakázku',
                  color: Colors.red,
                  onTap: onStornovat,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
