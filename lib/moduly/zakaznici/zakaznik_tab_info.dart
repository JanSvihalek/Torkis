import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../vozidla/vozidlo_detail.dart';

class ZakaznikInfoTab extends StatelessWidget {
  final bool isDark;
  final Map<String, dynamic> dataZakaznika;
  final dynamic zakaznikId;
  final dynamic servisId;

  const ZakaznikInfoTab({
    super.key,
    required this.isDark,
    required this.dataZakaznika,
    required this.zakaznikId,
    required this.servisId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Colors.blue.withValues(alpha: 0.1),
                        foregroundColor: Colors.blue,
                        radius: 30,
                        child: const Icon(Icons.person, size: 30),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dataZakaznika['jmeno'] ?? 'Neznámý',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (dataZakaznika['ico'] != null &&
                                dataZakaznika['ico']
                                    .toString()
                                    .isNotEmpty)
                              Text(
                                'IČO: ${dataZakaznika['ico']}',
                                style:
                                    const TextStyle(color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  _buildInfoRow(Icons.phone, 'Telefon',
                      dataZakaznika['telefon']),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                      Icons.email, 'E-mail', dataZakaznika['email']),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.location_on, 'Adresa',
                      dataZakaznika['adresa']),
                  if (dataZakaznika['dic'] != null &&
                      dataZakaznika['dic'].toString().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.account_balance_wallet, 'DIČ',
                        dataZakaznika['dic']),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Vozidla zákazníka',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('vozidla')
                .where('servis_id', isEqualTo: servisId)
                .where('zakaznik_id', isEqualTo: zakaznikId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text(
                  'Zákazník nemá v systému uložena žádná vozidla.',
                  style: TextStyle(color: Colors.grey),
                );
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final vozidlo =
                      doc.data() as Map<String, dynamic>;
                  return Card(
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : Colors.grey[50],
                    margin: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VozidloDetailScreen(
                              vozidloDocId: doc.id),
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.directions_car,
                            color: Colors.blue),
                        title: Text(
                          '${vozidlo['spz']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${vozidlo['znacka'] ?? ''} ${vozidlo['model'] ?? ''} ${vozidlo['motorizace'] != null && vozidlo['motorizace'].toString().isNotEmpty ? '(${vozidlo['motorizace']})' : ''}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              vozidlo['rok_vyroby']?.toString() ?? '',
                              style: const TextStyle(
                                  color: Colors.grey),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios,
                                size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    final valStr = value?.toString() ?? '';
    if (valStr.isEmpty) return const SizedBox();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey)),
              Text(
                valStr,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
