import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import 'auth_gate.dart';

class PredplatnePage extends StatefulWidget {
  const PredplatnePage({super.key});

  @override
  State<PredplatnePage> createState() => _PredplatnePageState();
}

class _PredplatnePageState extends State<PredplatnePage> {
  int _pocetUzivatelu = 1;

  Future<void> _odeslatiPoptavku(String plan) async {
    final subject = Uri.encodeComponent('Poptávka předplatného Torkis – plán ${plan.toUpperCase()}');
    final body = Uri.encodeComponent(
      'Dobrý den,\n\n'
      'Mám zájem o plán ${plan.toUpperCase()} pro svůj autoservis.\n\n'
      'Informace o servisu:\n'
      '  Servis ID: ${globalServisId ?? "neznámé"}\n'
      '  Aktuální plán: ${globalPlanTyp.toUpperCase()}\n'
      '  Počet uživatelů: $_pocetUzivatelu\n\n'
      'Prosím o zaslání cenové nabídky.\n\n'
      's pozdravem',
    );
    final uri = Uri.parse('mailto:jan.svihalek00@gmail.com?subject=$subject&body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nepodařilo se otevřít emailového klienta.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final jePlatne = globalPredplatneAktivni;
    final platnostDo = globalPredplatnePlatnost;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Předplatné', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aktuální stav
            _buildAktualniStav(isDark, jePlatne, platnostDo),
            const SizedBox(height: 28),

            const Text('Dostupné plány',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              'Cena se odvíjí od počtu uživatelů. Kontaktujte nás pro individuální nabídku.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Počet uživatelů
            _buildPocetUzivatelu(isDark),
            const SizedBox(height: 20),

            // Plán Basic
            _buildPlanKarta(
              isDark: isDark,
              plan: 'basic',
              nazev: 'Basic',
              barva: Colors.blueGrey,
              popis: 'Základní správa autoservisu',
              moduly: const [
                'Příjem vozidla',
                'Historie příjmů',
                'Zákazníci',
                'Vozidla',
                'Historie příjmů',
                'Zaměstnanci',
              ],
              jeSoucasny: globalPlanTyp == 'basic',
              jeLepe: false,
            ),
            const SizedBox(height: 16),

            // Plán Pro
            _buildPlanKarta(
              isDark: isDark,
              plan: 'pro',
              nazev: 'Pro',
              barva: Colors.blue,
              popis: 'Kompletní řízení autoservisu',
              moduly: const [
                'Vše z Basic plánu',
                'Zakázky & plánování',
                'Sklad dílů',
                'Fakturace',
                'Účetnictví',
                'Statistiky & přehledy',
              ],
              jeSoucasny: globalPlanTyp == 'pro',
              jeLepe: true,
            ),
            const SizedBox(height: 30),

            // Kontakt info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Po odeslání poptávky vás budeme kontaktovat s individuální nabídkou. '
                      'Aktivace probíhá do 24 hodin od úhrady.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAktualniStav(bool isDark, bool jePlatne, DateTime? platnostDo) {
    final barva = jePlatne ? Colors.green : Colors.red;
    final planLabel = globalPlanTyp.toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: barva.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: barva.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: barva.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.workspace_premium, color: barva, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Váš aktuální plán: $planLabel',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: barva)),
                const SizedBox(height: 3),
                Text(
                  platnostDo == null
                      ? 'Platnost: bez omezení'
                      : jePlatne
                          ? 'Aktivní do: ${DateFormat('dd.MM.yyyy').format(platnostDo)}'
                          : 'Předplatné expirováno: ${DateFormat('dd.MM.yyyy').format(platnostDo)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: barva.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              jePlatne ? 'Aktivní' : 'Expirováno',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: barva),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPocetUzivatelu(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Počet uživatelů',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text('Kolik zaměstnanců bude aplikaci používat?',
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: _pocetUzivatelu > 1
                    ? () => setState(() => _pocetUzivatelu--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.blue,
              ),
              Expanded(
                child: Text(
                  '$_pocetUzivatelu ${_pocetUzivatelu == 1 ? 'uživatel' : _pocetUzivatelu < 5 ? 'uživatelé' : 'uživatelů'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _pocetUzivatelu++),
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanKarta({
    required bool isDark,
    required String plan,
    required String nazev,
    required Color barva,
    required String popis,
    required List<String> moduly,
    required bool jeSoucasny,
    required bool jeLepe,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: jeSoucasny
              ? Colors.green.withValues(alpha: 0.5)
              : jeLepe
                  ? barva.withValues(alpha: 0.4)
                  : Colors.grey.withValues(alpha: 0.2),
          width: jeSoucasny || jeLepe ? 2 : 1,
        ),
        boxShadow: [
          if (!isDark && jeLepe)
            BoxShadow(
                color: barva.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hlavička
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: jeSoucasny
                  ? Colors.green.withValues(alpha: 0.08)
                  : barva.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Icon(Icons.workspace_premium,
                    color: jeSoucasny ? Colors.green : barva, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nazev,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: jeSoucasny ? Colors.green : barva)),
                      Text(popis,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                if (jeSoucasny)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Váš plán',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green)),
                  ),
                if (jeLepe && !jeSoucasny)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: barva.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Doporučeno',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: barva)),
                  ),
              ],
            ),
          ),

          // Moduly
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...moduly.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              size: 16,
                              color: jeSoucasny ? Colors.green : barva),
                          const SizedBox(width: 8),
                          Text(m, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    )),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                // Cena
                Row(
                  children: [
                    const Icon(Icons.payments_outlined,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Cena dle počtu uživatelů – individuální nabídka',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Tlačítko
                SizedBox(
                  width: double.infinity,
                  child: jeSoucasny
                      ? OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.check),
                          label: const Text('Aktuálně aktivní'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () => _odeslatiPoptavku(plan),
                          icon: const Icon(Icons.mail_outline),
                          label: const Text('Mám zájem',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: barva,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
