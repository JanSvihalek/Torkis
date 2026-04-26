import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_gate.dart'; // Kvůli globalServisId
import 'app_logger.dart'; // Pro odchytávání chyb

class DoplnkyNastaveniPage extends StatefulWidget {
  const DoplnkyNastaveniPage({super.key});

  @override
  State<DoplnkyNastaveniPage> createState() => _DoplnkyNastaveniPageState();
}

class _DoplnkyNastaveniPageState extends State<DoplnkyNastaveniPage> {
  bool _isLoading = true;
  Map<String, dynamic> _aktivniDoplnky = {};

  @override
  void initState() {
    super.initState();
    _nactiDoplnky();
  }

  Future<void> _nactiDoplnky() async {
    if (globalServisId == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('nastaveni_servisu')
          .doc(globalServisId)
          .get();
      
      if (doc.exists && doc.data()!.containsKey('doplnky')) {
        setState(() {
          _aktivniDoplnky = Map<String, dynamic>.from(doc.data()!['doplnky']);
        });
      }
    } catch (e, stackTrace) {
      AppLogger.logError('Chyba při načítání doplňků', e, stackTrace);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _odeslatPoptavku(String nazevDoplnku) async {
    if (globalServisId == null) return;

    // Potvrzovací dialog pro uživatele
    bool? potvrdit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zájem o doplněk'),
        content: Text('Chcete odeslat nezávaznou poptávku na aktivaci doplňku "$nazevDoplnku"? Ozveme se Vám pro domluvení detailů nastavení.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ZRUŠIT', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: const Text('ODESLAT POPTÁVKU'),
          ),
        ],
      ),
    );

    if (potvrdit != true) return;

    try {
      // Uložení poptávky do nové kolekce pro administrátora (tebe)
      await FirebaseFirestore.instance.collection('poptavky_doplnky').add({
        'servis_id': globalServisId,
        'doplnek': nazevDoplnku,
        'stav': 'nova',
        'cas_poptavky': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Poptávka byla odeslána. Brzy se Vám ozveme!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.logError('Chyba při odesílání poptávky na doplněk: $nazevDoplnku', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chyba při odesílání poptávky.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Prémiové doplňky', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.extension, color: Colors.white, size: 40),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rozšiřte možnosti TORKISu', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 5),
                        Text('Některé funkce vyžadují individuální nastavení. Rádi s Vámi vše probereme.', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Doplňky seznam
            _buildDoplnekCard(
              klic: 'etl_sync',
              nazev: 'Automatická synchronizace s ERP',
              popis: 'Propojte Torkis s Vaším stávajícím účetním programem (Pohoda, Money, Kros). Vozidla a zákazníci se budou automaticky stahovat přímo do Vašeho tabletu na příjmu.',
              cena: 'Individuální nacenění',
              ikona: Icons.sync,
              barva: Colors.purple,
              isDark: isDark,
            ),
            
            const SizedBox(height: 15),
            
            _buildDoplnekCard(
              klic: 'sms_modul',
              nazev: 'SMS notifikace zákazníkům',
              popis: 'Aplikace bude automaticky posílat SMS zprávy zákazníkům (např. "Vaše vozidlo bylo přijato", "Vozidlo je opravené a připravené k vyzvednutí").',
              cena: '+ 190 Kč / měsíc',
              ikona: Icons.sms,
              barva: Colors.orange,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoplnekCard({
    required String klic,
    required String nazev,
    required String popis,
    required String cena,
    required IconData ikona,
    required Color barva,
    required bool isDark,
  }) {
    final isAktivni = _aktivniDoplnky[klic] == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAktivni ? Colors.green : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          width: isAktivni ? 2 : 1,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isAktivni ? Colors.green.withOpacity(0.1) : barva.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(isAktivni ? Icons.check_circle : ikona, color: isAktivni ? Colors.green : barva, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nazev, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(
                      isAktivni ? 'Aktivní' : cena, 
                      style: TextStyle(color: isAktivni ? Colors.green : barva, fontWeight: FontWeight.bold, fontSize: 14)
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            popis,
            style: const TextStyle(color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 20),
          
          // Tlačítko se zobrazí pouze pokud doplněk ještě není aktivní
          if (!isAktivni)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _odeslatPoptavku(nazev),
                icon: const Icon(Icons.mail_outline),
                label: const Text('MÁM ZÁJEM O NASTAVENÍ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: barva,
                  side: BorderSide(color: barva.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Text('Tento modul již využíváte', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}