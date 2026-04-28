import 'package:flutter/material.dart';
import 'auth_gate.dart';
import 'zakaznici.dart';
import 'vozidla.dart';
import 'prubeh_fotodokumentace.dart';

/// Karta se základními informacemi o zakázce: datum příjmu, zákazník, vozidlo
/// a tlačítko pro zobrazení fotodokumentace z příjmu.
class ZakaznikVozidloCard extends StatelessWidget {
  final bool isDark;
  final Map<String, dynamic> data;
  final Map<String, dynamic> zakaznik;
  final String formattedPrijeti;
  final List<String> prijemFotky;

  const ZakaznikVozidloCard({
    super.key,
    required this.isDark,
    required this.data,
    required this.zakaznik,
    required this.formattedPrijeti,
    required this.prijemFotky,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Záhlaví: název sekce + datum/přijal --
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informace o zakázce',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Přijato: $formattedPrijeti',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (data['prijal_jmeno'] != null)
                    Text(
                      'Přijal: ${data['prijal_jmeno']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 10),
            // -- Zákazník | Vozidlo --
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Zákazník
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ZakaznikDetailScreen(
                              zakaznikData: zakaznik,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 16,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Zákazník',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              zakaznik['jmeno']?.toString().isNotEmpty == true
                                  ? zakaznik['jmeno']
                                  : 'Neuvedeno',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            if (zakaznik['telefon']?.toString().isNotEmpty ==
                                true)
                              Text(zakaznik['telefon']),
                            if (zakaznik['email']?.toString().isNotEmpty == true)
                              Text(zakaznik['email']),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Oddělovač
                Container(
                  width: 1,
                  height: 80,
                  color: Colors.grey.withValues(alpha: 0.3),
                  margin: const EdgeInsets.only(top: 10),
                ),
                // Vozidlo
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        if (globalServisId != null && data['spz'] != null) {
                          final vozidloDocId =
                              '${globalServisId}_${data['spz']}';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VozidloDetailScreen(
                                vozidloDocId: vozidloDocId,
                              ),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 16,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Vozidlo',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // SPZ rámeček
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isDark
                                      ? Colors.grey[600]!
                                      : Colors.black87,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                data['spz']?.toString().toUpperCase() ?? '---',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${data['znacka'] ?? ''} ${data['model'] ?? ''}'
                                          .trim()
                                          .isEmpty
                                  ? 'Neznámé vozidlo'
                                  : '${data['znacka']} ${data['model']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (data['rok_vyroby']?.toString().isNotEmpty ==
                                    true ||
                                data['motorizace']?.toString().isNotEmpty == true)
                              Text(
                                '${data['rok_vyroby'] ?? ''} ${data['motorizace'] ?? ''}'
                                    .trim(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            Text(
                              'VIN: ${data['vin']?.toString().isNotEmpty == true ? data['vin'] : '-'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // -- Fotodokumentace z příjmu --
            if (prijemFotky.isNotEmpty) ...[
              const Divider(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FotodokumentaceScreen(
                          fotografieUrls: prijemFotky,
                          titulek: 'Příjem vozidla',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(
                      'Fotodokumentace z příjmu (${prijemFotky.length})'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
