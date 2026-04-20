import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'auth_gate.dart';
import 'prubeh.dart';
import 'nova_rezervace_screen.dart'; // <--- ODKAZ NA NOVOU STRÁNKU

class PlanovacPage extends StatefulWidget {
  const PlanovacPage({super.key});

  @override
  State<PlanovacPage> createState() => _PlanovacPageState();
}

class _PlanovacPageState extends State<PlanovacPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // 1. ZOBRAZENÍ KALENDÁŘE
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
              onFormatChanged: (format) => setState(() => _calendarFormat = format),
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonDecoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1), 
                  borderRadius: BorderRadius.circular(15)
                ),
                formatButtonTextStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
              ),
            ),
          ),
          const Divider(height: 1),
          
          // 2. SEZNAM REZERVACÍ PRO VYBRANÝ DEN
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('planovac')
                  .where('servis_id', isEqualTo: globalServisId)
                  .where('datum', isEqualTo: DateFormat('yyyy-MM-dd').format(_selectedDay))
                  .orderBy('cas_od')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Chyba: ${snapshot.error}"));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final docs = snapshot.data!.docs;
                
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 50, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 10),
                        const Text("Žádné rezervace", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final rez = docs[index].data() as Map<String, dynamic>;
                    return _buildRezervaceCard(rez, isDark);
                  },
                );
              },
            ),
          ),
        ],
      ),
      
      // 3. TLAČÍTKO PRO OTEVŘENÍ STRÁNKY (Místo bottom sheetu)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // Předáme stránce vybraný den, ať se tam rovnou hezky předvyplní
              builder: (context) => NovaRezervaceScreen(vybranyDen: _selectedDay),
            ),
          );
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nová rezervace', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRezervaceCard(Map<String, dynamic> rez, bool isDark) {
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
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(rez['cas_od'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13)),
              Text(rez['cas_do'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
        title: Text(rez['spz'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(rez['nazev_ukonu'] ?? '', style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {
          if (rez['zakazka_doc_id'] != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ActiveJobScreen(
              documentId: rez['zakazka_doc_id'],
              zakazkaId: '---', 
              spz: rez['spz'],
            )));
          }
        },
      ),
    );
  }
}