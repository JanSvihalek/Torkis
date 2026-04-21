import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'auth_gate.dart';
import 'prubeh.dart';
import 'nova_rezervace_screen.dart';

// --- IMPORTY PRO DÁLKOVÉ OVLÁDÁNÍ PŘÍJMU A ZÁLOŽEK ---
import 'prijem_vozidla.dart' show rezervaceKeZpracovani;
import 'main_screen.dart' show globalSwitchTabNotifier;

class PlanovacPage extends StatefulWidget {
  const PlanovacPage({super.key});

  @override
  State<PlanovacPage> createState() => _PlanovacPageState();
}

class _PlanovacPageState extends State<PlanovacPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  void _ukazDetailRezervace(BuildContext context, String docId,
      Map<String, dynamic> rez, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 20),
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10))),
            ),
            const Text('Detail rezervace',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.directions_car, color: Colors.white)),
              title: Text(rez['spz'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text('${rez['znacka'] ?? ''} ${rez['model'] ?? ''}'),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person, color: Colors.grey),
              title: Text(rez['zakaznik_jmeno'] ?? 'Neznámý zákazník',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(rez['zakaznik_telefon'] ?? ''),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.build_circle, color: Colors.orange),
              title: const Text('Plánovaný úkon',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              subtitle: Text(rez['nazev_ukonu'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Zavře tenhle detail

                  // --- ZDE JE TO KOUZLO S PŘESMĚROVÁNÍM ---
                  // 1. Předá ID dokumentu do Příjmu vozidla
                  rezervaceKeZpracovani.value = docId;

                  // 2. Přepne spodní menu na záložku 'prijem'
                  globalSwitchTabNotifier.value = 'prijem';
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('PŘIJMOUT VOZIDLO DO SERVISU',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            child: TableCalendar(
              locale: 'cs_CZ',
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) => setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              }),
              onFormatChanged: (format) =>
                  setState(() => _calendarFormat = format),
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonDecoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15)),
                formatButtonTextStyle: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              calendarStyle: const CalendarStyle(
                selectedDecoration:
                    BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(
                    color: Colors.blueAccent, shape: BoxShape.circle),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('planovac')
                  .where('servis_id', isEqualTo: globalServisId)
                  .where('datum',
                      isEqualTo: DateFormat('yyyy-MM-dd').format(_selectedDay))
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Chyba: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Data se řadí přímo v aplikaci = odpadá problém s Firebase Indexy
                final docs = snapshot.data!.docs.toList();

                docs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;

                  final timeA = aData['cas_od']?.toString() ?? '00:00';
                  final timeB = bData['cas_od']?.toString() ?? '00:00';

                  return timeA.compareTo(timeB);
                });

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 50, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 10),
                        const Text("Žádné rezervace",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return _buildRezervaceCard(doc, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      NovaRezervaceScreen(vybranyDen: _selectedDay)));
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nová rezervace',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRezervaceCard(DocumentSnapshot doc, bool isDark) {
    final rez = doc.data() as Map<String, dynamic>;
    final docId = doc.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 55,
          decoration: BoxDecoration(
              color: rez['zakazka_doc_id'] != null
                  ? Colors.green.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(rez['cas_od'] ?? '',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: rez['zakazka_doc_id'] != null
                          ? Colors.green
                          : Colors.blue,
                      fontSize: 13)),
              Text(rez['cas_do'] ?? '',
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
        title: Text(rez['spz'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(rez['nazev_ukonu'] ?? '',
            style: const TextStyle(fontSize: 13)),
        trailing: Icon(
            rez['zakazka_doc_id'] != null
                ? Icons.build_circle
                : Icons.arrow_forward_ios,
            size: rez['zakazka_doc_id'] != null ? 24 : 14,
            color: rez['zakazka_doc_id'] != null ? Colors.green : Colors.grey),
        onTap: () {
          if (rez['zakazka_doc_id'] != null) {
            // Zakázka už je fyzicky na dílně -> Otevřeme detail
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ActiveJobScreen(
                          documentId: rez['zakazka_doc_id'],
                          zakazkaId: '---',
                          spz: rez['spz'],
                        )));
          } else {
            // Zatím jen plán v kalendáři -> Tlačítko k přijetí
            _ukazDetailRezervace(context, docId, rez, isDark);
          }
        },
      ),
    );
  }
}
