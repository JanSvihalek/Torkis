import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UcetnictviPage extends StatefulWidget {
  const UcetnictviPage({super.key});

  @override
  State<UcetnictviPage> createState() => _UcetnictviPageState();
}

class _UcetnictviPageState extends State<UcetnictviPage> {
  final formatMena = NumberFormat.currency(
    locale: 'cs_CZ',
    symbol: 'Kč',
    decimalDigits: 0,
  );
  final formatMenaSDesetinami = NumberFormat.currency(
    locale: 'cs_CZ',
    symbol: 'Kč',
    decimalDigits: 2,
  );

  final List<String> zkratkyMesicu = [
    'Led',
    'Úno',
    'Bře',
    'Dub',
    'Kvě',
    'Čvn',
    'Čvc',
    'Srp',
    'Zář',
    'Říj',
    'Lis',
    'Pro',
  ];

  Widget _buildShrnujiciKarta(
    String nadpis,
    double castka,
    IconData ikona,
    Color barva,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: barva.withOpacity(0.3), width: 1.5),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: barva.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: barva.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(ikona, color: barva, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    nadpis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              formatMena.format(castka),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const Center(child: Text("Nejste přihlášeni."));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Účetnictví a Přehled',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Finanční zdraví servisu a statistiky tržeb.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('faktury')
                .where('servis_id', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Chyba: ${snapshot.error}"));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              double celkovyObratVRoce = 0;
              double obratTentoMesic = 0;
              double cekajiciPlatby = 0;

              final now = DateTime.now();
              Map<int, double> obratPoMesicich = {
                for (var i = 1; i <= 12; i++) i: 0.0,
              };
              List<Map<String, dynamic>> nezaplaceneFaktury = [];

              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final castka = (data['celkova_castka'] ?? 0.0).toDouble();
                final stav = data['stav_platby'] ?? '';
                final datum =
                    (data['datum_vystaveni'] as Timestamp?)?.toDate() ?? now;

                // Nezaplacené faktury
                if (stav == 'Čeká na platbu') {
                  cekajiciPlatby += castka;
                  nezaplaceneFaktury.add(data);
                }

                // Statistiky pro aktuální rok
                if (datum.year == now.year) {
                  celkovyObratVRoce += castka;
                  obratPoMesicich[datum.month] =
                      obratPoMesicich[datum.month]! + castka;

                  if (datum.month == now.month) {
                    obratTentoMesic += castka;
                  }
                }
              }

              // Seřazení nezaplacených faktur (od nejstarších, protože ty spěchají nejvíc)
              nezaplaceneFaktury.sort((a, b) {
                final dateA =
                    (a['datum_splatnosti'] as Timestamp?)?.toDate() ?? now;
                final dateB =
                    (b['datum_splatnosti'] as Timestamp?)?.toDate() ?? now;
                return dateA.compareTo(dateB);
              });

              // Výpočet maxima pro graf
              double maxMesicniObrat = 0;
              obratPoMesicich.forEach((key, value) {
                if (value > maxMesicniObrat) maxMesicniObrat = value;
              });

              return ListView(
                padding: const EdgeInsets.all(30),
                children: [
                  // --- TOP KARTY (KPI) ---
                  Row(
                    children: [
                      _buildShrnujiciKarta(
                        'TENTO MĚSÍC',
                        obratTentoMesic,
                        Icons.account_balance_wallet,
                        Colors.green,
                        isDark,
                      ),
                      const SizedBox(width: 15),
                      _buildShrnujiciKarta(
                        'ČEKÁ NA PLATBU',
                        cekajiciPlatby,
                        Icons.warning_amber_rounded,
                        Colors.orange,
                        isDark,
                      ),
                      const SizedBox(width: 15),
                      _buildShrnujiciKarta(
                        'OBRAT ROK ${now.year}',
                        celkovyObratVRoce,
                        Icons.insights,
                        Colors.blue,
                        isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // --- GRAF VÝVOJE ---
                  Text(
                    'Vývoj tržeb v roce ${now.year}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 250,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(12, (index) {
                        int mesic = index + 1;
                        double hodnota = obratPoMesicich[mesic] ?? 0.0;
                        double vyskaSloupce = maxMesicniObrat == 0
                            ? 0
                            : (hodnota / maxMesicniObrat) * 160;
                        bool jeAktualni = mesic == now.month;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Tooltip částky
                            if (hodnota > 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '${(hodnota / 1000).toStringAsFixed(0)}k',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            // Sloupec
                            Container(
                              width: 35,
                              height: vyskaSloupce > 0
                                  ? vyskaSloupce
                                  : 4, // Minimální výška, aby byl vidět
                              decoration: BoxDecoration(
                                color: jeAktualni
                                    ? Colors.blue
                                    : (isDark
                                          ? Colors.blue[900]
                                          : Colors.blue[200]),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Popisek měsíce
                            Text(
                              zkratkyMesicu[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: jeAktualni
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: jeAktualni ? Colors.blue : Colors.grey,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- SEZNAM NEZAPLACENÝCH FAKTUR ---
                  Row(
                    children: [
                      const Icon(Icons.money_off, color: Colors.redAccent),
                      const SizedBox(width: 10),
                      const Text(
                        'Kniha pohledávek (Nezaplaceno)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${nezaplaceneFaktury.length} faktur',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (nezaplaceneFaktury.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 60,
                              color: Colors.green.withOpacity(0.5),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Skvělá práce! Všichni zákazníci mají zaplaceno.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...nezaplaceneFaktury.map((faktura) {
                      final splatnost =
                          (faktura['datum_splatnosti'] as Timestamp?)
                              ?.toDate() ??
                          now;
                      final dnuPoSplatnosti = now.difference(splatnost).inDays;
                      final jePoSplatnosti = dnuPoSplatnosti > 0;

                      return Card(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: jePoSplatnosti
                                ? Colors.red.withOpacity(0.5)
                                : Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(15),
                          leading: CircleAvatar(
                            backgroundColor: jePoSplatnosti
                                ? Colors.red.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            child: Icon(
                              Icons.warning_rounded,
                              color: jePoSplatnosti
                                  ? Colors.red
                                  : Colors.orange,
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${faktura['zakaznik_jmeno']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${(faktura['celkova_castka'] ?? 0.0).toStringAsFixed(2)} Kč',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Text('Faktura: ${faktura['cislo_faktury']}'),
                                const Spacer(),
                                Text(
                                  jePoSplatnosti
                                      ? '$dnuPoSplatnosti dní po splatnosti!'
                                      : 'Splatnost: ${DateFormat('dd.MM.yyyy').format(splatnost)}',
                                  style: TextStyle(
                                    color: jePoSplatnosti
                                        ? Colors.red
                                        : Colors.orange[800],
                                    fontWeight: jePoSplatnosti
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 50), // Spodní buffer
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
