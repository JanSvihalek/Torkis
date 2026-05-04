import 'package:flutter/material.dart';
import 'prubeh_fotodokumentace.dart';

/// Sekce detailu zakázky: požadavky zákazníka + seznam zaznamenaných úkonů
/// (práce, díly, fotodokumentace ke každému úkonu).
class PrehledPraci extends StatelessWidget {
  final bool isDark;
  final bool isCompleted;
  final bool isMechanik;
  final List<dynamic> provedenePrace;
  final List<dynamic> pozadavky;

  /// Otevře dialog pro přidání / editaci úkonu.
  final void Function({String? initialTitle, Map<String, dynamic>? existingWork, int? editIndex}) onAddWork;

  /// Smaže požadavek zákazníka.
  final void Function(String pozadavek) onDeletePozadavek;

  /// Smaže záznam o provedené práci.
  final void Function(Map<String, dynamic> workItem) onDeleteWork;

  /// Formátuje timestamp na čitelný řetězec.
  final String Function(dynamic timestamp) formatDate;

  const PrehledPraci({
    super.key,
    required this.isDark,
    required this.isCompleted,
    required this.isMechanik,
    required this.provedenePrace,
    required this.pozadavky,
    required this.onAddWork,
    required this.onDeletePozadavek,
    required this.onDeleteWork,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -- Požadavky zákazníka --
        if (pozadavky.isNotEmpty) ...[
          const Text(
            'Požadavky od zákazníka (k řešení)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...pozadavky.map(
            (p) => Card(
              color: Colors.orange.withValues(alpha: 0.05),
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                title: Text(
                  p.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: isCompleted
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isMechanik)
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              tooltip: 'Smazat požadavek',
                              onPressed: () =>
                                  onDeletePozadavek(p.toString()),
                            ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.build, size: 18),
                            label: const Text('ZPRACOVAT'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () =>
                                onAddWork(initialTitle: p.toString()),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const Divider(height: 40),
        ],

        // -- Zaznamenané úkony --
        const Text(
          'Zaznamenané úkony',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        if (provedenePrace.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Icon(
                  Icons.build_circle_outlined,
                  size: 80,
                  color: Colors.grey.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Zatím nebyly přidány žádné práce.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        else
          ...List.generate(provedenePrace.length, (index) {
            final trueIndex = provedenePrace.length - 1 - index;
            final prace = provedenePrace[trueIndex] as Map<String, dynamic>;
            final fotky =
                prace['fotografie_urls'] as List<dynamic>? ?? [];

            List<dynamic> polozky =
                prace['polozky'] as List<dynamic>? ?? [];
            if (polozky.isEmpty) {
              if ((prace['cena_s_dph'] ?? 0) > 0) {
                polozky = [
                  {
                    'typ': 'Práce',
                    'nazev': 'Práce',
                    'cislo': '',
                    'mnozstvi': prace['delka_prace'] ?? 1,
                    'jednotka': 'h',
                    'cena_s_dph': prace['cena_s_dph'],
                    'sleva': 0.0,
                  }
                ];
              }
              for (var d
                  in (prace['pouzite_dily'] as List<dynamic>? ?? [])) {
                polozky.add({
                  'typ': 'Materiál',
                  'nazev': d['nazev'],
                  'cislo': d['cislo'] ?? '',
                  'mnozstvi': d['pocet'] ?? 1,
                  'jednotka': 'ks',
                  'cena_s_dph': d['cena_s_dph'],
                  'sleva': 0.0,
                });
              }
            }

            double celkemUkon = 0.0;
            for (var p in polozky) {
              double pMnoz =
                  double.tryParse(p['mnozstvi'].toString()) ?? 1.0;
              double pCena =
                  double.tryParse(p['cena_s_dph'].toString()) ?? 0.0;
              double pSleva =
                  double.tryParse(p['sleva']?.toString() ?? '0') ?? 0.0;
              celkemUkon += (pMnoz * pCena) * (1 - (pSleva / 100));
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              color: isDark ? const Color(0xFF1E3A5F) : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${prace['nazev']} ${!isMechanik ? "(Celkem: ${celkemUkon.toStringAsFixed(2)} Kč)" : ""}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!isCompleted)
                          IconButton(
                            onPressed: () => onAddWork(
                              existingWork: prace,
                              editIndex: trueIndex,
                            ),
                            icon: const Icon(Icons.edit,
                                color: Colors.blue, size: 20),
                          ),
                        if (!isCompleted && !isMechanik)
                          IconButton(
                            onPressed: () => onDeleteWork(prace),
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 20),
                          ),
                      ],
                    ),
                    Text(
                      formatDate(prace['cas']),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (prace['popis'] != null &&
                        prace['popis'].toString().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(prace['popis'],
                          style: const TextStyle(fontSize: 14)),
                    ],
                    if (polozky.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Položky:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      ...polozky.map((p) {
                        double pMnoz = double.tryParse(
                                p['mnozstvi'].toString()) ??
                            1.0;
                        double pCena = double.tryParse(
                                p['cena_s_dph'].toString()) ??
                            0.0;
                        double pSleva = double.tryParse(
                                p['sleva']?.toString() ?? '0') ??
                            0.0;
                        String pJedn = p['jednotka'] ?? 'ks';
                        String cistyMnoz = pMnoz
                            .toString()
                            .replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
                        String slevaStr = pSleva > 0
                            ? ' (-${pSleva.toStringAsFixed(0)}%)'
                            : '';
                        String cNum = p['cislo']?.toString() ?? '';
                        String nDisp = cNum.trim().isNotEmpty
                            ? '${p['nazev']} ($cNum)'
                            : p['nazev'];

                        return Padding(
                          padding:
                              const EdgeInsets.only(top: 4, left: 10),
                          child: Text(
                            '• [${p['typ']}] $nDisp - $cistyMnoz $pJedn$slevaStr'
                            '${!isMechanik ? " - ${(pMnoz * pCena * (1 - pSleva / 100)).toStringAsFixed(2)} Kč" : ""}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                    ],
                    if (fotky.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FotodokumentaceScreen(
                                  fotografieUrls: fotky
                                      .map((e) => e.toString())
                                      .toList(),
                                  titulek: prace['nazev'] ?? 'Úkon',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.photo_library),
                          label: Text(
                              'Zobrazit fotodokumentaci (${fotky.length})'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
