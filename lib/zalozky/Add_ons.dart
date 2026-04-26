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

  Future<void> _prepnoutDoplnek(String klic, bool novaHodnota) async {
    if (globalServisId == null) return;
    
    // Zde by v reálné produkci byla integrace na platební bránu (Stripe/GoPay),
    // která po úspěšné platbě změní hodnotu v databázi. 
    // Pro ukázku to přepínáme rovnou.
    
    setState(() {
      _aktivniDoplnky[klic] = novaHodnota;
    });

    try {
      await FirebaseFirestore.instance
          .collection('nastaveni_servisu')
          .doc(globalServisId)
          .set({
        'doplnky': _aktivniDoplnky
      }, SetOptions(merge: true));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(novaHodnota ? 'Doplněk byl úspěšně aktivován.' : 'Doplněk byl deaktivován.'),
          backgroundColor: novaHodnota ? Colors.green : Colors.blueGrey,
        ));
      }
    } catch (e, stackTrace) {
      AppLogger.logError('Chyba při ukládání doplňku $klic', e, stackTrace);
      setState(() => _aktivniDoplnky[klic] = !novaHodnota); // Revert při chybě
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
                        Text('Přidejte si moduly podle toho, co Váš servis aktuálně potřebuje.', style: TextStyle(color: Colors.white70, fontSize: 13)),
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
              popis: 'Propojte Torkis s Vaším stávajícím účetním programem (Pohoda, Money, Kros). Vozidla a zákazníci se budou 2x denně automaticky stahovat do Vašeho tabletu.',
              cena: '+ 390 Kč / měsíc',
              ikona: Icons.sync,
              barva: Colors.purple,
              isDark: isDark,
            ),
            
            const SizedBox(height: 15),
            
            _buildDoplnekCard(
              klic: 'sms_modul',
              nazev: 'SMS notifikace zákazníkům',
              popis: 'Aplikace bude automaticky posílat SMS zprávy zákazníkům ("Vaše vozidlo bylo přijato", "Vozidlo je opravené a připravené k vyzvednutí").',
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
          color: isAktivni ? barva : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
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
                  color: barva.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(ikona, color: barva, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nazev, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(cena, style: TextStyle(color: barva, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              Switch(
                value: isAktivni,
                activeColor: barva,
                onChanged: (val) => _prepnoutDoplnek(klic, val),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 15),
          Text(
            popis,
            style: const TextStyle(color: Colors.grey, height: 1.4),
          ),
        ],
      ),
    );
  }
}