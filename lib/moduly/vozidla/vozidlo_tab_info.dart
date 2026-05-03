import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../zakaznici/zakaznik_detail.dart';

class VozidloInfoTab extends StatelessWidget {
  final bool isDark;
  final User user;
  final Map<String, dynamic> autoData;
  final String spz;
  final String zakaznikId;
  final String znackaNazev;
  final String palivo;
  final String prevodovka;
  final String tacho;
  final String stkM;
  final String stkR;

  const VozidloInfoTab({
    super.key,
    required this.isDark,
    required this.user,
    required this.autoData,
    required this.spz,
    required this.zakaznikId,
    required this.znackaNazev,
    required this.palivo,
    required this.prevodovka,
    required this.tacho,
    required this.stkM,
    required this.stkR,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              if (znackaNazev.isNotEmpty)
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('znacka').get(),
                  builder: (context, snap) {
                    if (snap.hasData) {
                      String nalezeneLogo = '';
                      for (var doc in snap.data!.docs) {
                        final d = doc.data() as Map<String, dynamic>;
                        final dbNazev = (d['nazev']?.toString() ?? doc.id)
                            .trim()
                            .toLowerCase();
                        if (dbNazev == znackaNazev.toLowerCase()) {
                          nalezeneLogo = d['logo']?.toString() ??
                              d['logo_url']?.toString() ??
                              '';
                          break;
                        }
                      }
                      if (nalezeneLogo.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Container(
                            height: 80,
                            constraints: const BoxConstraints(maxWidth: 150),
                            padding: isDark
                                ? const EdgeInsets.all(10)
                                : EdgeInsets.zero,
                            decoration: isDark
                                ? BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  )
                                : null,
                            child: Image.network(
                              nalezeneLogo,
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => const SizedBox(),
                            ),
                          ),
                        );
                      }
                    }
                    return const SizedBox(height: 20);
                  },
                ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.grey[600]! : Colors.black87,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 24,
                      color: Colors.blue[700],
                      margin: const EdgeInsets.only(right: 12),
                    ),
                    Text(
                      spz.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Card(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                  color: Colors.teal.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn(
                          'Značka a Model',
                          '${autoData['znacka'] ?? ''} ${autoData['model'] ?? ''}'
                              .trim(),
                        ),
                      ),
                      Expanded(
                        child: _buildInfoColumn(
                            'Motorizace', autoData['motorizace']),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: _buildInfoColumn('VIN', autoData['vin'])),
                      Expanded(
                          child: _buildInfoColumn(
                              'Rok výroby', autoData['rok_vyroby'])),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: _buildInfoColumn(
                              'Převodovka', autoData['prevodovka'])),
                      Expanded(
                          child: _buildInfoColumn('Palivo', autoData['palivo'])),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoColumn(
                          'Tachometr (poslední)',
                          tacho.isNotEmpty ? '$tacho km' : '-',
                        ),
                      ),
                      Expanded(
                        child: _buildInfoColumn(
                          'Platnost STK',
                          stkM.isNotEmpty && stkR.isNotEmpty
                              ? '$stkM / $stkR'
                              : '-',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          if (zakaznikId.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Majitel vozidla',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('zakaznici')
                  .where('servis_id', isEqualTo: user.uid)
                  .where('id_zakaznika', isEqualTo: zakaznikId)
                  .limit(1)
                  .get(),
              builder: (context, zakaznikSnap) {
                if (zakaznikSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!zakaznikSnap.hasData ||
                    zakaznikSnap.data!.docs.isEmpty) {
                  return const Text('Zákazník nenalezen.',
                      style: TextStyle(color: Colors.grey));
                }
                final zakaznikData = zakaznikSnap.data!.docs.first.data()
                    as Map<String, dynamic>;
                return Card(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : Colors.blueGrey[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                        color: Colors.blueGrey.withValues(alpha: 0.3)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ZakaznikDetailScreen(
                            zakaznikData: zakaznikData),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      leading: CircleAvatar(
                        backgroundColor:
                            Colors.blueGrey.withValues(alpha: 0.2),
                        foregroundColor: Colors.blueGrey,
                        child: const Icon(Icons.person),
                      ),
                      title: Text(
                        zakaznikData['jmeno'] ?? 'Neznámý zákazník',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                          '${zakaznikData['telefon'] ?? ''}\n${zakaznikData['email'] ?? ''}'
                              .trim()),
                      trailing:
                          const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, dynamic value) {
    final valStr = value?.toString() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          valStr.isNotEmpty ? valStr : '-',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
