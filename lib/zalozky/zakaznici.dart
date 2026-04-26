// Modul zákazníků — 2 obrazovky:
//   ZakazniciPage       – seznam zákazníků s vyhledáváním (jméno, telefon, IČO)
//   ZakaznikDetailScreen – detail zákazníka se 3 záložkami: Info & Auta, Zakázky, Faktury
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'vozidla.dart';
import 'prubeh.dart'; // Pro proklik na zakázku
import 'fakturace.dart'; // Pro proklik na fakturu
import 'auth_gate.dart'; // <--- PŘIDÁN IMPORT PRO globalServisId

const List<Map<String, String>> _kPredvolby = [
  {'kod': '+420', 'vlajka': '🇨🇿', 'nazev': 'Česká republika'},
  {'kod': '+421', 'vlajka': '🇸🇰', 'nazev': 'Slovensko'},
  {'kod': '+49', 'vlajka': '🇩🇪', 'nazev': 'Německo'},
  {'kod': '+43', 'vlajka': '🇦🇹', 'nazev': 'Rakousko'},
  {'kod': '+48', 'vlajka': '🇵🇱', 'nazev': 'Polsko'},
  {'kod': '+36', 'vlajka': '🇭🇺', 'nazev': 'Maďarsko'},
  {'kod': '+380', 'vlajka': '🇺🇦', 'nazev': 'Ukrajina'},
  {'kod': '+44', 'vlajka': '🇬🇧', 'nazev': 'Velká Británie'},
  {'kod': '+1', 'vlajka': '🇺🇸', 'nazev': 'USA'},
  {'kod': '+7', 'vlajka': '🇷🇺', 'nazev': 'Rusko'},
];

String _formatTelefon(String? tel) {
  if (tel == null || tel.isEmpty) return '';
  for (final p in _kPredvolby) {
    final kod = p['kod']!;
    if (tel.startsWith(kod)) return '$kod ${tel.substring(kod.length).trim()}';
  }
  return tel;
}

/// Seznam všech zákazníků servisu s live vyhledáváním.
class ZakazniciPage extends StatefulWidget {
  const ZakazniciPage({super.key});

  @override
  State<ZakazniciPage> createState() => _ZakazniciPageState();
}

class _ZakazniciPageState extends State<ZakazniciPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              const Text(
                'Zákazníci',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Adresář vašich klientů a jejich vozidel.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Hledat jméno, telefon nebo IČO...',
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('zakaznici')
                .where('servis_id', isEqualTo: globalServisId) // <--- ZMĚNA ZDE
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Chyba databáze: ${snapshot.error}"));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final jmeno = data['jmeno']?.toString().toLowerCase() ?? '';
                final telefon = data['telefon']?.toString().toLowerCase() ?? '';
                final ico = data['ico']?.toString().toLowerCase() ?? '';
                return jmeno.contains(_searchQuery) ||
                    telefon.contains(_searchQuery) ||
                    ico.contains(_searchQuery);
              }).toList();

              docs.sort((a, b) {
                final dataA = a.data() as Map<String, dynamic>;
                final dataB = b.data() as Map<String, dynamic>;
                final jmenoA = dataA['jmeno']?.toString().toLowerCase() ?? '';
                final jmenoB = dataB['jmeno']?.toString().toLowerCase() ?? '';
                return jmenoA.compareTo(jmenoB);
              });

              if (docs.isEmpty) {
                return const Center(
                  child: Text('Zatím nemáte žádné zákazníky.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;

                  return Card(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                    margin: const EdgeInsets.only(bottom: 15),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        foregroundColor: Colors.blue,
                        radius: 25,
                        child: const Icon(Icons.person),
                      ),
                      title: Text(
                        '${data['jmeno']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data['telefon'] != null &&
                                data['telefon'].toString().isNotEmpty)
                              Text('📞 ${_formatTelefon(data['telefon']?.toString())}'),
                            if (data['email'] != null &&
                                data['email'].toString().isNotEmpty)
                              Text('✉️ ${data['email']}'),
                            if (data['ico'] != null &&
                                data['ico'].toString().isNotEmpty)
                              Text('🏢 IČO: ${data['ico']}'),
                          ],
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ZakaznikDetailScreen(zakaznikData: data),
                        ),
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

/// Detail zákazníka — subscribuje se na živá data zákazníka ze Firestore
/// a zobrazuje 3 záložky: základní info + vozidla, servisní zakázky, faktury.
class ZakaznikDetailScreen extends StatelessWidget {
  final Map<String, dynamic> zakaznikData;

  const ZakaznikDetailScreen({super.key, required this.zakaznikData});

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "Zpracovává se...";
    DateTime dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  String _formatDateOnly(dynamic timestamp) {
    if (timestamp == null) return "-";
    DateTime dt = (timestamp as Timestamp).toDate();
    return DateFormat('dd.MM.yyyy').format(dt);
  }

  /// Otevře bottom sheet pro úpravu kontaktních údajů zákazníka (jméno, telefon,
  /// e-mail, adresa, IČO, DIČ) a uloží změny do Firestore.
  void _otevritEditaci(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final jmenoCtrl =
        TextEditingController(text: data['jmeno']?.toString() ?? '');
    String telPredvolba = '+420';
    String telefonRaw = data['telefon']?.toString() ?? '';
    for (final p in _kPredvolby) {
      if (telefonRaw.startsWith(p['kod']!)) {
        telPredvolba = p['kod']!;
        telefonRaw = telefonRaw.substring(p['kod']!.length).trim();
        break;
      }
    }
    final telCtrl = TextEditingController(text: telefonRaw);
    final emailCtrl =
        TextEditingController(text: data['email']?.toString() ?? '');
    final adresaCtrl =
        TextEditingController(text: data['adresa']?.toString() ?? '');
    final icoCtrl = TextEditingController(text: data['ico']?.toString() ?? '');
    final dicCtrl = TextEditingController(text: data['dic']?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
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
                const Text(
                  'Úprava zákazníka',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: jmenoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Jméno a Příjmení / Název firmy',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                const Text('Telefon',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (_) => Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25)),
                            ),
                            padding:
                                const EdgeInsets.fromLTRB(20, 16, 20, 30),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 40, height: 4,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                                const Text('Vyberte předvolbu',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                ..._kPredvolby.map((p) => ListTile(
                                      leading: Text(p['vlajka']!,
                                          style: const TextStyle(
                                              fontSize: 24)),
                                      title: Text(p['nazev']!),
                                      trailing: Text(p['kod']!,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue)),
                                      selected:
                                          p['kod'] == telPredvolba,
                                      selectedColor: Colors.blue,
                                      onTap: () {
                                        setSheetState(() =>
                                            telPredvolba = p['kod']!);
                                        Navigator.pop(context);
                                      },
                                    )),
                              ],
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _kPredvolby.firstWhere(
                                    (p) => p['kod'] == telPredvolba,
                                    orElse: () =>
                                        _kPredvolby.first)['vlajka']!,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 6),
                              Text(telPredvolba,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const Icon(Icons.arrow_drop_down, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: telCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Číslo',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: adresaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Adresa',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: icoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'IČO',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        controller: dicCtrl,
                        decoration: const InputDecoration(
                          labelText: 'DIČ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('zakaznici')
                          .doc(docId)
                          .update({
                        'jmeno': jmenoCtrl.text.trim(),
                        'telefon': '$telPredvolba${telCtrl.text.trim()}',
                        'email': emailCtrl.text.trim(),
                        'adresa': adresaCtrl.text.trim(),
                        'ico': icoCtrl.text.trim(),
                        'dic': dicCtrl.text.trim(),
                      });
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text(
                      'ULOŽIT ZMĚNY',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (globalServisId == null) {
      return const Scaffold(body: Center(child: Text('Zpracovávám data...')));
    }

    final zakaznikId = zakaznikData['id_zakaznika'] ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('zakaznici')
          .where('servis_id', isEqualTo: globalServisId) // <--- ZMĚNA ZDE
          .where('id_zakaznika', isEqualTo: zakaznikId)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text("Chyba: ${snapshot.error}")));
        }
        if (!snapshot.hasData) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()));
        }

        if (snapshot.data!.docs.isEmpty) {
          return _buildScreen(
              context, isDark, zakaznikData, "UNKNOWN", globalServisId!);
        }

        final doc = snapshot.data!.docs.first;
        final aktualniData = doc.data() as Map<String, dynamic>;
        final docId = doc.id;

        return _buildScreen(
            context, isDark, aktualniData, docId, globalServisId!);
      },
    );
  }

  Widget _buildScreen(BuildContext context, bool isDark,
      Map<String, dynamic> aktualniData, String docId, String servisId) {
    final zakaznikId = aktualniData['id_zakaznika'] ?? '';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            aktualniData['jmeno'] ?? 'Karta zákazníka',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          elevation: 0,
          actions: [
            if (docId != "UNKNOWN")
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                tooltip: 'Upravit údaje',
                onPressed: () => _otevritEditaci(context, docId, aktualniData),
              ),
          ],
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Info & Auta'),
              Tab(icon: Icon(Icons.build), text: 'Zakázky'),
              Tab(icon: Icon(Icons.receipt_long), text: 'Faktury'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildInfoTab(context, isDark, aktualniData, zakaznikId, servisId),
            _buildZakazkyTab(context, isDark, zakaznikId, servisId),
            _buildFakturyTab(context, isDark, zakaznikId, servisId),
          ],
        ),
      ),
    );
  }

  // =======================================================
  // ZÁLOŽKA 1: ZÁKLADNÍ INFO A VOZIDLA
  // =======================================================
  Widget _buildInfoTab(
      BuildContext context,
      bool isDark,
      Map<String, dynamic> dataZakaznika,
      dynamic zakaznikId,
      dynamic servisId) {
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
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
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
                                dataZakaznika['ico'].toString().isNotEmpty)
                              Text(
                                'IČO: ${dataZakaznika['ico']}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  _buildInfoRow(
                    Icons.phone,
                    'Telefon',
                    _formatTelefon(dataZakaznika['telefon']?.toString()),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(Icons.email, 'E-mail', dataZakaznika['email']),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.location_on,
                    'Adresa',
                    dataZakaznika['adresa'],
                  ),
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
                  final vozidlo = doc.data() as Map<String, dynamic>;
                  return Card(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                    margin: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                VozidloDetailScreen(vozidloDocId: doc.id),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: const Icon(
                          Icons.directions_car,
                          color: Colors.blue,
                        ),
                        title: Text(
                          '${vozidlo['spz']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${vozidlo['znacka'] ?? ''} ${vozidlo['model'] ?? ''} ${vozidlo['motorizace'] != null && vozidlo['motorizace'].toString().isNotEmpty ? '(${vozidlo['motorizace']})' : ''}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              vozidlo['rok_vyroby']?.toString() ?? '',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
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

  // =======================================================
  // ZÁLOŽKA 2: ZAKÁZKY
  // =======================================================
  Widget _buildZakazkyTab(
      BuildContext context, bool isDark, dynamic zakaznikId, dynamic servisId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('zakazky')
            .where('servis_id', isEqualTo: servisId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Zákazník zatím nemá žádné servisní záznamy.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          // Filtrování podle zakaznikId
          final docs = snapshot.data!.docs.where((doc) {
            final zData = doc.data() as Map<String, dynamic>;
            final zId1 = zData['zakaznik_id']?.toString() ?? '';
            final zId2 =
                (zData['zakaznik'] as Map<String, dynamic>?)?['id_zakaznika']
                        ?.toString() ??
                    '';
            return zId1 == zakaznikId || zId2 == zakaznikId;
          }).toList();

          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Zákazník zatím nemá žádné servisní záznamy.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          docs.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            final timeA = dataA['cas_prijeti'] as Timestamp?;
            final timeB = dataB['cas_prijeti'] as Timestamp?;
            if (timeA == null && timeB == null) return 0;
            if (timeA == null) return 1;
            if (timeB == null) return -1;
            return timeB.compareTo(timeA);
          });

          return Column(
            children: docs.map((doc) {
              final zakazka = doc.data() as Map<String, dynamic>;
              final stav = zakazka['stav_zakazky'] ?? 'Přijato';

              double celkovaCenaSDph = 0.0;
              final prace = zakazka['provedene_prace'] as List<dynamic>? ?? [];
              for (var p in prace) {
                celkovaCenaSDph += (p['cena_s_dph'] ?? 0.0).toDouble();
                final dily = p['pouzite_dily'] as List<dynamic>? ?? [];
                for (var dil in dily) {
                  double pocet = (dil['pocet'] ?? 1.0).toDouble();
                  double cenaSDph = (dil['cena_s_dph'] ?? 0.0).toDouble();
                  celkovaCenaSDph += (pocet * cenaSDph);
                }
              }

              Color barvaStavu;
              switch (stav) {
                case 'Přijato':
                  barvaStavu = Colors.blue;
                  break;
                case 'V řešení':
                  barvaStavu = Colors.orange;
                  break;
                case 'Čeká na díly':
                  barvaStavu = Colors.purple;
                  break;
                case 'Dokončeno':
                  barvaStavu = Colors.green;
                  break;
                default:
                  barvaStavu = Colors.grey;
              }

              return Card(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActiveJobScreen(
                          documentId: doc.id,
                          zakazkaId: zakazka['cislo_zakazky'].toString(),
                          spz: zakazka['spz']?.toString() ?? '',
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${zakazka['cislo_zakazky']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: barvaStavu.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: barvaStavu,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    stav,
                                    style: TextStyle(
                                      color: barvaStavu,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_ios,
                                    size: 14, color: Colors.grey),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${zakazka['spz']} • ${_formatDate(zakazka['cas_prijeti'])}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${prace.length} úkonů',
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              '${celkovaCenaSDph.toStringAsFixed(2)} Kč',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // =======================================================
  // ZÁLOŽKA 3: FAKTURY
  // =======================================================
  Widget _buildFakturyTab(
      BuildContext context, bool isDark, dynamic zakaznikId, dynamic servisId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('faktury')
            .where('servis_id', isEqualTo: servisId)
            .snapshots(),
        builder: (context, invoiceSnap) {
          if (invoiceSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!invoiceSnap.hasData || invoiceSnap.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'K tomuto zákazníkovi neevidujeme žádné faktury.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          final fakturyDocs = invoiceSnap.data!.docs.where((doc) {
            final fData = doc.data() as Map<String, dynamic>;
            final fId1 = fData['zakaznik_id']?.toString() ?? '';
            final fId2 =
                (fData['zakaznik'] as Map<String, dynamic>?)?['id_zakaznika']
                        ?.toString() ??
                    '';
            return fId1 == zakaznikId || fId2 == zakaznikId;
          }).toList();

          if (fakturyDocs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'K tomuto zákazníkovi neevidujeme žádné faktury.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          fakturyDocs.sort((a, b) {
            final dA = a.data() as Map<String, dynamic>;
            final dB = b.data() as Map<String, dynamic>;
            final tA = dA['datum_vystaveni'] as Timestamp?;
            final tB = dB['datum_vystaveni'] as Timestamp?;
            if (tA == null && tB == null) return 0;
            if (tA == null) return 1;
            if (tB == null) return -1;
            return tB.compareTo(tA);
          });

          return Column(
            children: fakturyDocs.map((fDoc) {
              final faktura = fDoc.data() as Map<String, dynamic>;
              final stavPlatby = faktura['stav_platby'] ?? 'Čeká na platbu';
              final isStorno = stavPlatby == 'Stornováno';

              Color platbaColor;
              if (stavPlatby == 'Uhrazeno') {
                platbaColor = Colors.green;
              } else if (stavPlatby == 'Stornováno') {
                platbaColor = Colors.red;
              } else {
                platbaColor = Colors.orange;
              }

              return Card(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FakturaDetailScreen(
                          fakturaDocId: fDoc.id,
                          zakazkaId: faktura['cislo_zakazky']?.toString() ?? '',
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${faktura['cislo_faktury']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: isStorno
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: platbaColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: platbaColor, width: 0.5),
                                  ),
                                  child: Text(
                                    stavPlatby,
                                    style: TextStyle(
                                        color: platbaColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_ios,
                                    size: 14, color: Colors.grey),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${faktura['spz'] ?? ''} • ${_formatDateOnly(faktura['datum_vystaveni'])}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${(faktura['celkova_castka'] ?? 0.0).toStringAsFixed(2)} Kč',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isStorno
                                    ? Colors.grey
                                    : (isDark
                                        ? Colors.greenAccent
                                        : Colors.green),
                                decoration: isStorno
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // =======================================================
  // POMOCNÝ WIDGET PRO TEXTY
  // =======================================================
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
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                valStr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
