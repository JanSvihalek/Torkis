import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_gate.dart'; // Kvůli globalServisId

class ZamestnanciPage extends StatefulWidget {
  const ZamestnanciPage({super.key});

  @override
  State<ZamestnanciPage> createState() => _ZamestnanciPageState();
}

class _ZamestnanciPageState extends State<ZamestnanciPage> {
  
  // Pomocná funkce pro překlad klíčů z databáze do hezké češtiny
  String _prelozModul(String modul) {
    switch (modul) {
      case 'zakazky': return 'Zakázky';
      case 'sklad': return 'Sklad';
      case 'fakturace': return 'Fakturace';
      case 'zamestnanci': return 'Zaměstnanci';
      case 'nastaveni': return 'Nastavení';
      default: return modul;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Správa týmu', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddZamestnanecDialog(context),
        label: const Text('PŘIDAT ZAMĚSTNANCE', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.person_add),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
            child: Text(
              'Zaměstnanci a práva',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'Zde můžete spravovat svůj tým, vytvářet účty a nastavovat oprávnění.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('uzivatele')
                  .where('servis_id', isEqualTo: globalServisId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Chyba: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text('Zatím nemáte žádné zaměstnance.', style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 80), // Větší padding dole kvůli tlačítku
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    final String jmeno = data['jmeno'] ?? 'Bez jména';
                    final String email = data['email'] ?? '-';
                    final String role = data['role'] ?? 'zamestnanec';
                    final bool jeAdmin = role == 'admin';

                    // Bezpečné načtení práv
                    final Map<String, dynamic> prava = data['prava'] ?? {
                      'zakazky': true,
                      'sklad': false,
                      'fakturace': false,
                      'zamestnanci': false,
                      'nastaveni': false,
                    };

                    List<String> aktivniModuly = [];
                    prava.forEach((key, value) {
                      if (value == true) aktivniModuly.add(_prelozModul(key));
                    });

                    String podnadpis = aktivniModuly.isEmpty
                        ? 'Bez přístupu'
                        : 'Přístup: ${aktivniModuly.join(', ')}';

                    return Card(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        leading: CircleAvatar(
                          backgroundColor: jeAdmin ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                          child: Icon(
                            jeAdmin ? Icons.admin_panel_settings : Icons.person, 
                            color: jeAdmin ? Colors.red : Colors.blue
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(jmeno, style: const TextStyle(fontWeight: FontWeight.bold))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: jeAdmin ? Colors.red.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                jeAdmin ? 'Admin' : 'Zaměstnanec',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: jeAdmin ? Colors.red : Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text('$email\n$podnadpis', style: const TextStyle(fontSize: 12)),
                        isThreeLine: true,
                        trailing: jeAdmin
                            ? const Icon(Icons.lock_outline, color: Colors.grey)
                            : IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _showEditPravaDialog(context, docId, jmeno, prava),
                              ),
                      ),
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

  // --- DIALOG PRO PŘIDÁNÍ NOVÉHO ZAMĚSTNANCE (VČETNĚ FIREBASE AUTH) ---
  void _showAddZamestnanecDialog(BuildContext context) {
    final jmenoCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final hesloCtrl = TextEditingController();

    Map<String, bool> novaPrava = {
      'zakazky': true, // Výchozí přístup
      'sklad': false,
      'fakturace': false,
      'zamestnanci': false,
      'nastaveni': false,
    };

    bool isSaving = false;
    bool hesloSkryte = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          
          return Container(
            height: MediaQuery.of(context).size.height * 0.90, // Mírně zvětšeno kvůli heslu
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 5,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Nový zaměstnanec', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                TextField(
                  controller: jmenoCtrl,
                  decoration: InputDecoration(
                    labelText: 'Jméno a příjmení *',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Přihlašovací e-mail *',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: hesloCtrl,
                  obscureText: hesloSkryte,
                  decoration: InputDecoration(
                    labelText: 'Přihlašovací heslo (min. 6 znaků) *',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    suffixIcon: IconButton(
                      icon: Icon(hesloSkryte ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setModalState(() {
                          hesloSkryte = !hesloSkryte;
                        });
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 25),
                Text('Výchozí přístupová práva', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildPravoSwitch(setModalState, 'Zakázky a průběh oprav', 'zakazky', novaPrava, Icons.build),
                        _buildPravoSwitch(setModalState, 'Skladové hospodářství', 'sklad', novaPrava, Icons.inventory_2),
                        _buildPravoSwitch(setModalState, 'Fakturace a pokladna', 'fakturace', novaPrava, Icons.receipt_long),
                        _buildPravoSwitch(setModalState, 'Správa zaměstnanců', 'zamestnanci', novaPrava, Icons.people),
                        _buildPravoSwitch(setModalState, 'Nastavení servisu (IČO, atd.)', 'nastaveni', novaPrava, Icons.settings),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : () async {
                      if (jmenoCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty || hesloCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vyplňte prosím jméno, e-mail i heslo.'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      if (hesloCtrl.text.trim().length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Heslo musí mít alespoň 6 znaků.'), backgroundColor: Colors.orange),
                        );
                        return;
                      }

                      setModalState(() => isSaving = true);

                      try {
                        // 1. Vytvoření dočasné instance Firebase, abychom neodhlásili aktuálního admina
                        FirebaseApp tempApp = await Firebase.initializeApp(
                          name: 'tempAuth',
                          options: Firebase.app().options,
                        );
                        
                        // 2. Vytvoření uživatele ve Firebase Auth
                        UserCredential userCredential = await FirebaseAuth.instanceFor(app: tempApp)
                            .createUserWithEmailAndPassword(
                          email: emailCtrl.text.trim(),
                          password: hesloCtrl.text.trim(),
                        );
                        
                        String novyUid = userCredential.user!.uid;
                        
                        // Zahození dočasné instance
                        await tempApp.delete();

                        // 3. Uložení práv do Firestore přímo pod jeho vygenerovaným UID
                        await FirebaseFirestore.instance.collection('uzivatele').doc(novyUid).set({
                          'uid': novyUid,
                          'jmeno': jmenoCtrl.text.trim(),
                          'email': emailCtrl.text.trim(),
                          'servis_id': globalServisId,
                          'role': 'zamestnanec',
                          'prava': novaPrava,
                          'vytvoreno': FieldValue.serverTimestamp(),
                        });
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Zaměstnanec vytvořen a práva přidělena.'), backgroundColor: Colors.green),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        setModalState(() => isSaving = false);
                        String errMsg = 'Chyba ověření.';
                        if (e.code == 'weak-password') errMsg = 'Zadané heslo je příliš slabé.';
                        else if (e.code == 'email-already-in-use') errMsg = 'Účet s tímto e-mailem již existuje.';
                        else if (e.code == 'invalid-email') errMsg = 'Neplatný formát e-mailu.';
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errMsg), backgroundColor: Colors.red),
                          );
                        }
                      } catch (e) {
                        setModalState(() => isSaving = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Neočekávaná chyba: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: isSaving 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('VYTVOŘIT ZAMĚSTNANCE', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- DIALOG PRO ÚPRAVU PRÁV ---
  void _showEditPravaDialog(BuildContext context, String docId, String jmeno, Map<String, dynamic> aktualniPrava) {
    Map<String, bool> lokalniPrava = {
      'zakazky': aktualniPrava['zakazky'] ?? true,
      'sklad': aktualniPrava['sklad'] ?? false,
      'fakturace': aktualniPrava['fakturace'] ?? false,
      'zamestnanci': aktualniPrava['zamestnanci'] ?? false,
      'nastaveni': aktualniPrava['nastaveni'] ?? false,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 5,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Přístupová práva', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text(jmeno, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                _buildPravoSwitch(setModalState, 'Zakázky a průběh oprav', 'zakazky', lokalniPrava, Icons.build),
                _buildPravoSwitch(setModalState, 'Skladové hospodářství', 'sklad', lokalniPrava, Icons.inventory_2),
                _buildPravoSwitch(setModalState, 'Fakturace a pokladna', 'fakturace', lokalniPrava, Icons.receipt_long),
                _buildPravoSwitch(setModalState, 'Správa zaměstnanců', 'zamestnanci', lokalniPrava, Icons.people),
                _buildPravoSwitch(setModalState, 'Nastavení servisu (IČO, atd.)', 'nastaveni', lokalniPrava, Icons.settings),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('uzivatele')
                          .doc(docId)
                          .update({'prava': lokalniPrava});
                      
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('ULOŽIT OPRÁVNĚNÍ', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPravoSwitch(StateSetter setState, String label, String key, Map<String, bool> prava, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SwitchListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        secondary: Icon(icon, color: prava[key]! ? Colors.blue : Colors.grey),
        value: prava[key]!,
        activeColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        onChanged: (bool value) {
          setState(() {
            prava[key] = value;
          });
        },
      ),
    );
  }
}