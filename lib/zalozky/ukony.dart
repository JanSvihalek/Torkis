import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_gate.dart'; // Kvůli globalServisId

class UkonyPage extends StatefulWidget {
  const UkonyPage({super.key});

  @override
  State<UkonyPage> createState() => _UkonyPageState();
}

class _UkonyPageState extends State<UkonyPage> {
  final _novyUkonController = TextEditingController();
  bool _isSaving = false;

  // Toto je seznam výchozích úkonů, který se nahraje, pokud je databáze prázdná
  final List<String> _vychoziUkony = [
    'Výměna oleje a filtrů',
    'Kontrola brzd',
    'Servis klimatizace',
    'Příprava a provedení STK',
    'Geometrie kol',
    'Pneuservis (přezutí)',
    'Diagnostika závad'
  ];

  Future<void> _pridatUkon() async {
    final nazev = _novyUkonController.text.trim();
    if (nazev.isEmpty) return;

    if (globalServisId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chyba: Neznámé ID servisu.'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final docRef = FirebaseFirestore.instance.collection('nastaveni_servisu').doc(globalServisId);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        final data = docSnap.data()!;
        
        // Pokud pole rychle_ukony ještě vůbec neexistuje, musíme vytvořit pole rovnou 
        // s výchozími úkony PLUS tím novým, jinak by se výchozí úkony nenávratně smazaly.
        if (!data.containsKey('rychle_ukony') || (data['rychle_ukony'] as List).isEmpty) {
          List<String> combinedList = List.from(_vychoziUkony);
          if (!combinedList.contains(nazev)) {
            combinedList.add(nazev);
          }
          await docRef.set({
            'rychle_ukony': combinedList
          }, SetOptions(merge: true));
        } else {
          // Pokud už pole existuje, jen do něj přidáme ten nový (ArrayUnion zajistí, že se nebudou duplikovat)
          await docRef.update({
            'rychle_ukony': FieldValue.arrayUnion([nazev])
          });
        }
      } else {
        // Pokud neexistuje ani dokument nastavení (což by se teoreticky stát nemělo)
        List<String> combinedList = List.from(_vychoziUkony);
        combinedList.add(nazev);
        await docRef.set({'rychle_ukony': combinedList}, SetOptions(merge: true));
      }

      _novyUkonController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Úkon byl úspěšně přidán.'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chyba při ukládání: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _smazatUkon(String nazev) async {
    if (globalServisId == null) return;

    try {
      final docRef = FirebaseFirestore.instance.collection('nastaveni_servisu').doc(globalServisId);
      
      // Pro bezpečné smazání
      await docRef.update({
        'rychle_ukony': FieldValue.arrayRemove([nazev])
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Úkon smazán.'), backgroundColor: Colors.orange));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chyba při mazání: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  void dispose() {
    _novyUkonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Používáme stream z nastaveni_servisu přes globalServisId, ne uživatelovo UID
    if (globalServisId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rychlé úkony', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text(
                'Spravujte si seznam úkonů, které se vám budou nabízet pro rychlé kliknutí při příjmu vozidla.', 
                style: TextStyle(fontSize: 13, color: Colors.grey)
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: TextField(
                        controller: _novyUkonController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Napište nový úkon (např. Výměna rozvodů)...',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!, width: 1)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.deepOrange, width: 2)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18)
                        ),
                        onSubmitted: (_) => _pridatUkon(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    height: 55, // Aby se to výškově srovnalo s TextFieldem
                    width: 55,
                    decoration: BoxDecoration(
                      color: Colors.deepOrange, 
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        if (!isDark) BoxShadow(color: Colors.deepOrange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: IconButton(
                      icon: _isSaving 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Icon(Icons.add, color: Colors.white, size: 28),
                      onPressed: _isSaving ? null : _pridatUkon,
                      tooltip: 'Přidat úkon',
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 30),
        Expanded(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('nastaveni_servisu').doc(globalServisId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text("Chyba: ${snapshot.error}"));
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

              List<String> ulozeneUkony = [];
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                if (data.containsKey('rychle_ukony') && (data['rychle_ukony'] as List).isNotEmpty) {
                  ulozeneUkony = List<String>.from(data['rychle_ukony']);
                } else {
                  ulozeneUkony = List.from(_vychoziUkony); 
                }
              } else {
                ulozeneUkony = List.from(_vychoziUkony);
              }

              if (ulozeneUkony.isEmpty) return const Center(child: Text('Zatím nemáte definované žádné úkony.'));

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                itemCount: ulozeneUkony.length,
                itemBuilder: (context, index) {
                  final ukon = ulozeneUkony[index];
                  return Card(
                    elevation: 0,
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), 
                      side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!)
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      title: Text(ukon, style: const TextStyle(fontWeight: FontWeight.w500)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _smazatUkon(ukon),
                        tooltip: 'Smazat úkon ze seznamu',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}