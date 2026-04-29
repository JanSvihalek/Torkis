import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_gate.dart';

class VyberZakaznikaSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onVybrano;
  const VyberZakaznikaSheet({super.key, required this.onVybrano});
  @override
  State<VyberZakaznikaSheet> createState() => _VyberZakaznikaSheetState();
}

class _VyberZakaznikaSheetState extends State<VyberZakaznikaSheet> {
  String? get _sId => globalServisId ?? FirebaseAuth.instance.currentUser?.uid;
  String _hledanyText = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_sId == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25))),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 20),
          const Text('Vybrat existujícího zákazníka',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          TextField(
              onChanged: (val) =>
                  setState(() => _hledanyText = val.toLowerCase()),
              decoration: InputDecoration(
                  hintText: 'Hledat podle jména, IČO, telefonu...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none))),
          const SizedBox(height: 15),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('zakaznici')
                  .where('servis_id', isEqualTo: _sId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final zakaznici = snapshot.data!.docs
                    .map((d) => d.data() as Map<String, dynamic>)
                    .where((z) {
                  final jmeno = (z['jmeno'] ?? '').toString().toLowerCase();
                  final ico = (z['ico'] ?? '').toString().toLowerCase();
                  final tel = (z['telefon'] ?? '').toString().toLowerCase();
                  return jmeno.contains(_hledanyText) ||
                      ico.contains(_hledanyText) ||
                      tel.contains(_hledanyText);
                }).toList();
                if (zakaznici.isEmpty) {
                  return const Center(child: Text('Žádný zákazník nenalezen.'));
                }
                return ListView.separated(
                  itemCount: zakaznici.length,
                  separatorBuilder: (c, i) => const Divider(),
                  itemBuilder: (context, index) {
                    final z = zakaznici[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(z['jmeno'] ?? 'Neznámé jméno',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${z['telefon'] ?? ''} ${z['ico'] != null && z['ico'].toString().isNotEmpty ? '• IČO: ${z['ico']}' : ''}'),
                      onTap: () {
                        widget.onVybrano(z);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
