import 'package:flutter/material.dart';
import 'auth_screen.dart'; // Odkaz na tvůj přihlašovací/registrační formulář

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. NAVIGAČNÍ LIŠTA ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.build_circle, color: Colors.blue, size: 32),
                      const SizedBox(width: 10),
                      Text(
                        'TORKIS',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: isDark ? Colors.white : Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  if (!isMobile)
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {}, // Zde může být scrollování na ceník
                          child: const Text('Funkce', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 20),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Ceník', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 20),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Přihlásit se'),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // --- 2. HERO SEKCE (Hlavní tahák) ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40, vertical: isMobile ? 60 : 100),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade300.withOpacity(0.5)),
                    ),
                    child: const Text(
                      'Vytvořeno mechaniky pro autoservisy',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Zkraťte příjem auta do servisu\nz 10 minut na 2.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 36 : 56,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'Skenování VIN kódu, fotodokumentace a podpis přímo na displeji.\nZbavte se šanonů a chraňte se před nespravedlivými reklamacemi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 20,
                      color: Colors.blue.shade100,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade900,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 22),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 10,
                    ),
                    child: const Text(
                      'VYZKOUŠET NA 14 DNÍ ZDARMA',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Bez závazků. Bez nutnosti zadávat platební kartu.',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ),

            // --- 3. HLAVNÍ FUNKCE (Benefity) ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40, vertical: 80),
              child: Column(
                children: [
                  const Text(
                    'Konec luštění škrábanic na papíře',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Vše vyřídíte jedním prstem přímo u auta na dílně.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 60),
                  Wrap(
                    spacing: 30,
                    runSpacing: 30,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.qr_code_scanner,
                        title: 'Chytré čtení VIN',
                        desc: 'Stačí naskenovat VIN a systém automaticky doplní značku, model, rok výroby i motorizaci z napojené databáze.',
                        isDark: isDark,
                        isMobile: isMobile,
                      ),
                      _buildFeatureCard(
                        icon: Icons.add_a_photo,
                        title: 'Neprůstřelná fotodokumentace',
                        desc: 'Vyfoťte stav vozu a tachometru při příjmu. Fotky se bezpečně uloží k zakázce a chrání vás před dohadováním.',
                        isDark: isDark,
                        isMobile: isMobile,
                      ),
                      _buildFeatureCard(
                        icon: Icons.draw,
                        title: 'Podpis a profi PDF',
                        desc: 'Zákazník se podepíše na displej a obratem mu na e-mail přistane profesionální předávací protokol s vaším logem.',
                        isDark: isDark,
                        isMobile: isMobile,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- 4. CENÍK A VERZE (BASIC vs PRO) ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40, vertical: 80),
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              child: Column(
                children: [
                  const Text(
                    'Vyberte si verzi, která vám sedne',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Od jednoduchého příjmu aut až po kompletní řízení servisu.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 60),
                  Wrap(
                    spacing: 40,
                    runSpacing: 40,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildPricingCard(
                        title: 'TORKIS Basic',
                        subtitle: 'Ideální pro rychlý a bezpečný příjem aut.',
                        price: 'Zkušební verze',
                        features: [
                          'Aplikace pro mobil i tablet',
                          'Průvodce příjmem vozidla',
                          'Automatické dekódování VIN',
                          'Fotodokumentace k zakázce',
                          'Generování podepsaných PDF',
                          'Historie a adresář zákazníků'
                        ],
                        buttonText: 'ZAČÍT ZDARMA',
                        isDark: isDark,
                        isPro: false,
                        context: context,
                      ),
                      _buildPricingCard(
                        title: 'TORKIS PRO',
                        subtitle: 'Malé ERP pro kompletní řízení dílny.',
                        price: 'Připravujeme',
                        features: [
                          'Vše z verze Basic',
                          'Fakturace a účetnictví',
                          'Sklad náhradních dílů',
                          'Sledování marží a normohodin',
                          'Plánovací kalendář zvedáků',
                          'Statistiky a výkazy'
                        ],
                        buttonText: 'ZJISTIT VÍCE',
                        isDark: isDark,
                        isPro: true,
                        context: context,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- 5. PATIČKA ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              color: isDark ? const Color(0xFF0F0F0F) : Colors.blue.shade900,
              child: Column(
                children: [
                  const Icon(Icons.build_circle, size: 50, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    'TORKIS',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Moderní software pro autoservisy.\nChráníme váš čas i vaše nervy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 20),
                  Text(
                    '© ${DateTime.now().year} Torkis. Vytvořeno s péčí na Vysočině.',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
    required bool isMobile,
  }) {
    return Container(
      width: isMobile ? double.infinity : 350,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.blue.shade900.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
        ],
        border: isDark ? Border.all(color: Colors.grey.shade800) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, size: 36, color: Colors.blue),
          ),
          const SizedBox(height: 25),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Text(
            desc,
            style: const TextStyle(color: Colors.grey, height: 1.6, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String subtitle,
    required String price,
    required List<String> features,
    required String buttonText,
    required bool isDark,
    required bool isPro,
    required BuildContext context,
  }) {
    return Container(
      width: 380,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isPro ? Colors.blue : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          width: isPro ? 3 : 1,
        ),
        boxShadow: [
          if (isPro && !isDark)
            BoxShadow(
              color: Colors.blue.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            )
          else if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPro)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('PRO NÁROČNÉ', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(subtitle, style: const TextStyle(color: Colors.grey, height: 1.4)),
          const SizedBox(height: 30),
          Text(price, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: isPro ? Colors.blue : null)),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 30),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: isPro ? Colors.blue : Colors.green, size: 22),
                    const SizedBox(width: 15),
                    Expanded(child: Text(f, style: const TextStyle(fontSize: 15))),
                  ],
                ),
              )),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (!isPro) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPro ? Colors.blue.shade50 : Colors.blue,
                foregroundColor: isPro ? Colors.blue.shade900 : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                elevation: isPro ? 0 : 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}