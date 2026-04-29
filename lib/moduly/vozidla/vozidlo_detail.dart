import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vozidlo_tab_info.dart';
import 'vozidlo_tab_zakazky.dart';
import 'vozidlo_tab_faktury.dart';
import 'vozidlo_tab_prijem.dart';

class VozidloDetailScreen extends StatelessWidget {
  final String vozidloDocId;

  const VozidloDetailScreen({super.key, required this.vozidloDocId});

  void _otevritEditaci(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final spzCtrl = TextEditingController(text: data['spz']?.toString() ?? '');
    final znackaCtrl =
        TextEditingController(text: data['znacka']?.toString() ?? '');
    final modelCtrl =
        TextEditingController(text: data['model']?.toString() ?? '');
    final vinCtrl = TextEditingController(text: data['vin']?.toString() ?? '');
    final rokCtrl =
        TextEditingController(text: data['rok_vyroby']?.toString() ?? '');
    final motorCtrl =
        TextEditingController(text: data['motorizace']?.toString() ?? '');
    final tachoCtrl =
        TextEditingController(text: data['tachometr']?.toString() ?? '');
    final stkMCtrl =
        TextEditingController(text: data['stk_mesic']?.toString() ?? '');
    final stkRCtrl =
        TextEditingController(text: data['stk_rok']?.toString() ?? '');

    String vybranaZnacka = znackaCtrl.text;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('znacka').get(),
              builder: (context, snapshot) {
                Map<String, List<String>> databazeZnacek = {};
                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final docData = doc.data() as Map<String, dynamic>;
                    final nazev = docData['nazev']?.toString() ?? doc.id;
                    final modely = List<String>.from(docData['model'] ?? []);
                    databazeZnacek[nazev] = modely;
                  }
                }

                List<String> dostupneZnacky = databazeZnacek.keys.toList()
                  ..sort();
                List<String> dostupneModely = [];
                if (vybranaZnacka.isNotEmpty &&
                    databazeZnacek.containsKey(vybranaZnacka)) {
                  dostupneModely = databazeZnacek[vybranaZnacka]!..sort();
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Úprava vozidla',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      TextField(
                        controller: spzCtrl,
                        decoration: const InputDecoration(
                            labelText: 'SPZ',
                            border: OutlineInputBorder()),
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 15),
                      LayoutBuilder(
                        builder: (context, constraints) => DropdownMenu<String>(
                          width: constraints.maxWidth,
                          controller: znackaCtrl,
                          enableFilter: true,
                          enableSearch: true,
                          label: const Text('Značka'),
                          inputDecorationTheme: const InputDecorationTheme(
                              border: OutlineInputBorder()),
                          dropdownMenuEntries: dostupneZnacky
                              .map((z) =>
                                  DropdownMenuEntry(value: z, label: z))
                              .toList(),
                          onSelected: (val) => setState(() {
                            vybranaZnacka = val ?? znackaCtrl.text;
                            modelCtrl.clear();
                          }),
                        ),
                      ),
                      const SizedBox(height: 15),
                      LayoutBuilder(
                        builder: (context, constraints) => DropdownMenu<String>(
                          width: constraints.maxWidth,
                          controller: modelCtrl,
                          enableFilter: true,
                          enableSearch: true,
                          label: const Text('Model'),
                          inputDecorationTheme: const InputDecorationTheme(
                              border: OutlineInputBorder()),
                          dropdownMenuEntries: dostupneModely
                              .map((m) =>
                                  DropdownMenuEntry(value: m, label: m))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: vinCtrl,
                        decoration: const InputDecoration(
                            labelText: 'VIN', border: OutlineInputBorder()),
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 15),
                      Row(children: [
                        Expanded(
                          child: TextField(
                            controller: rokCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Rok výroby',
                                border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: motorCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Motorizace',
                                border: OutlineInputBorder()),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 15),
                      TextField(
                        controller: tachoCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Tachometr (km)',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 15),
                      const Text('Platnost STK',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 5),
                      Row(children: [
                        Expanded(
                          child: TextField(
                            controller: stkMCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Měsíc (MM)',
                                border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: stkRCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Rok (YYYY)',
                                border: OutlineInputBorder()),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () async {
                            final user =
                                FirebaseAuth.instance.currentUser;
                            if (user == null) return;

                            final oldSpz =
                                data['spz'].toString().toUpperCase();
                            final newSpz =
                                spzCtrl.text.trim().toUpperCase();

                            final updatedData = {
                              'spz': newSpz,
                              'znacka': znackaCtrl.text.trim(),
                              'model': modelCtrl.text.trim(),
                              'vin': vinCtrl.text.trim().toUpperCase(),
                              'rok_vyroby': rokCtrl.text.trim(),
                              'motorizace': motorCtrl.text.trim(),
                              'tachometr': tachoCtrl.text.trim(),
                              'stk_mesic': stkMCtrl.text.trim(),
                              'stk_rok': stkRCtrl.text.trim(),
                            };

                            if (oldSpz != newSpz) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (c) => const Center(
                                    child: CircularProgressIndicator()),
                              );
                              try {
                                final newDocId = '${user.uid}_$newSpz';
                                final check =
                                    await FirebaseFirestore.instance
                                        .collection('vozidla')
                                        .doc(newDocId)
                                        .get();
                                if (check.exists) {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                          'Vozidlo s touto SPZ již existuje!'),
                                      backgroundColor: Colors.red,
                                    ));
                                  }
                                  return;
                                }
                                await FirebaseFirestore.instance
                                    .collection('vozidla')
                                    .doc(newDocId)
                                    .set({...data, ...updatedData});

                                final batch =
                                    FirebaseFirestore.instance.batch();
                                for (var d in (await FirebaseFirestore
                                        .instance
                                        .collection('zakazky')
                                        .where('servis_id',
                                            isEqualTo: user.uid)
                                        .where('spz', isEqualTo: oldSpz)
                                        .get())
                                    .docs) {
                                  batch.update(
                                      d.reference, {'spz': newSpz});
                                }
                                for (var d in (await FirebaseFirestore
                                        .instance
                                        .collection('faktury')
                                        .where('servis_id',
                                            isEqualTo: user.uid)
                                        .where('spz', isEqualTo: oldSpz)
                                        .get())
                                    .docs) {
                                  batch.update(
                                      d.reference, {'spz': newSpz});
                                }
                                batch.delete(FirebaseFirestore.instance
                                    .collection('vozidla')
                                    .doc(docId));
                                await batch.commit();

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        'Vozidlo přejmenováno na $newSpz. Historie byla zachována.'),
                                    backgroundColor: Colors.green,
                                  ));
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          content: Text(
                                              'Chyba při migraci: $e')));
                                }
                              }
                            } else {
                              await FirebaseFirestore.instance
                                  .collection('vozidla')
                                  .doc(docId)
                                  .update(updatedData);
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          child: const Text('ULOŽIT ZMĚNY',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
          body: Center(child: Text('Nejste přihlášeni')));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vozidla')
          .doc(vozidloDocId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text("Chyba: ${snapshot.error}")),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final autoData =
            snapshot.data!.data() as Map<String, dynamic>?;
        if (autoData == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text("Vozidlo nenalezeno.")),
          );
        }

        final spz = autoData['spz']?.toString() ?? 'Neznámá SPZ';
        final zakaznikId = autoData['zakaznik_id']?.toString() ?? '';
        final znackaNazev =
            (autoData['znacka']?.toString() ?? '').trim();
        final tacho = autoData['tachometr']?.toString() ?? '';
        final stkM = autoData['stk_mesic']?.toString() ?? '';
        final stkR = autoData['stk_rok']?.toString() ?? '';

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              title: const Text('Karta vozidla',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor:
                  isDark ? const Color(0xFF1A1A1A) : Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.teal),
                  tooltip: 'Upravit údaje',
                  onPressed: () =>
                      _otevritEditaci(context, vozidloDocId, autoData),
                ),
              ],
              bottom: const TabBar(
                labelColor: Colors.teal,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.teal,
                indicatorWeight: 3,
                tabs: [
                  Tab(icon: Icon(Icons.info_outline), text: 'Info'),
                  Tab(icon: Icon(Icons.build), text: 'Zakázky'),
                  Tab(
                      icon: Icon(Icons.receipt_long),
                      text: 'Faktury'),
                  Tab(
                      icon: Icon(
                          Icons.assignment_turned_in_outlined),
                      text: 'Příjem'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                VozidloInfoTab(
                  isDark: isDark,
                  user: user,
                  autoData: autoData,
                  spz: spz,
                  zakaznikId: zakaznikId,
                  znackaNazev: znackaNazev,
                  tacho: tacho,
                  stkM: stkM,
                  stkR: stkR,
                ),
                VozidloZakazkyTab(
                    isDark: isDark, user: user, spz: spz),
                VozidloFakturyTab(
                    isDark: isDark, user: user, spz: spz),
                VozidloPrijemTab(
                    isDark: isDark, user: user, spz: spz),
              ],
            ),
          ),
        );
      },
    );
  }
}
