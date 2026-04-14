import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'auth_gate.dart';
import '../firebase_options.dart'; // <--- TVŮJ SOUBOR S KONFIGURACÍ FIREBASE (MUSÍ ZDE BÝT!)

class ZamestnanciPage extends StatefulWidget {
  const ZamestnanciPage({super.key});

  @override
  State<ZamestnanciPage> createState() => _ZamestnanciPageState();
}

class _ZamestnanciPageState extends State<ZamestnanciPage> {
  final _emailCtrl = TextEditingController();
  final _hesloCtrl = TextEditingController();
  final _jmenoCtrl = TextEditingController();
  String _vybranaRole = 'mechanik';
  bool _isSaving = false;

  Future<void> _vytvoritUzivatele() async {
    if (_emailCtrl.text.isEmpty || _hesloCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Vyplňte E-mail a heslo (min. 6 znaků)')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Vytvoříme vedlejší Firebase appku pro účely registrace
      FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp_${DateTime.now().millisecondsSinceEpoch}',
        options: DefaultFirebaseOptions
            .currentPlatform, // Z tvého firebase_options.dart
      );

      // 2. Vytvoříme účet pro mechanika
      UserCredential res = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _hesloCtrl.text.trim(),
      );

      // 3. Uložíme profil mechanika do Firestore pod NAŠÍM servis_id
      await FirebaseFirestore.instance
          .collection('uzivatele')
          .doc(res.user!.uid)
          .set({
        'uid': res.user!.uid,
        'email': _emailCtrl.text.trim(),
        'jmeno': _jmenoCtrl.text.trim(),
        'role': _vybranaRole,
        'servis_id': globalServisId, // Provážeme s hlavním servisem!
        'vytvoreno': FieldValue.serverTimestamp(),
      });

      // 4. Odhlásíme a smažeme vedlejší appku
      await FirebaseAuth.instanceFor(app: secondaryApp).signOut();
      await secondaryApp.delete();

      if (mounted) {
        Navigator.pop(context); // Zavřít okno
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Zaměstnanec úspěšně přidán.'),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('uzivatele')
            .where('servis_id',
                isEqualTo:
                    globalServisId) // Zobrazíme jen lidi ze stejného servisu
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final clenove = snapshot.data!.docs;

          return ListView.builder(
            itemCount: clenove.length,
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, index) {
              final data = clenove[index].data() as Map<String, dynamic>;
              final role = data['role'] ?? 'Neznámá';
              return Card(
                elevation: 0,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E1E1E)
                    : Colors.grey[100],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    backgroundColor:
                        role == 'admin' ? Colors.redAccent : Colors.blue,
                    foregroundColor: Colors.white,
                    child: Icon(role == 'admin'
                        ? Icons.star
                        : (role == 'technik' ? Icons.computer : Icons.build)),
                  ),
                  title: Text(data['jmeno'] ?? data['email'],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'E-mail: ${data['email']}\nRole: ${role.toUpperCase()}'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        label: const Text('Přidat zaměstnance',
            style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.person_add),
      ),
    );
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 30,
              right: 30,
              top: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nový zaměstnanec',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                  controller: _jmenoCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Jméno', border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Přihlašovací e-mail',
                      border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextField(
                  controller: _hesloCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Heslo (min. 6 znaků)',
                      border: OutlineInputBorder())),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _vybranaRole,
                decoration: const InputDecoration(
                    labelText: 'Role v systému', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(
                      value: 'mechanik',
                      child: Text('Mechanik (jen vidí zakázky)')),
                  DropdownMenuItem(
                      value: 'technik',
                      child: Text('Technik (zakázky, zákazníci, faktury)')),
                  DropdownMenuItem(
                      value: 'admin', child: Text('Admin (přístup ke všemu)')),
                ],
                onChanged: (v) => setModalState(() => _vybranaRole = v!),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white),
                  onPressed: _isSaving
                      ? null
                      : () async {
                          setModalState(() => _isSaving = true);
                          await _vytvoritUzivatele();
                          setModalState(() => _isSaving = false);
                        },
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ULOŽIT',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }
}
