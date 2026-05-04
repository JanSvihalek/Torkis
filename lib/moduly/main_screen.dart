import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import 'auth_gate.dart';
import 'auth_screen.dart';

// Sjednocené relativní importy!
import 'planovac.dart';
import 'zakazka/prubeh.dart';
import 'prijem/prijem_vozidla.dart';
import 'historie_prijmu/historie_prijmu_page.dart';
import 'zakaznici/zakaznici_page.dart';
import 'vozidla/vozidla_page.dart';
import 'ukony.dart';
import 'fakturace/fakturace_page.dart';
import 'statistiky.dart';
import 'nastaveni.dart';
import 'ucetnictvi.dart';
import 'zamestnanci.dart';
import 'sklad.dart';
import 'welcome_screen.dart';
import 'Add_ons.dart';
import 'predplatne_page.dart';

// GLOBÁLNÍ NOTIFIER PRO POŘADÍ SPODNÍ LIŠTY
final ValueNotifier<List<String>> navOrderNotifier =
    ValueNotifier(['prijem', 'zakazky', 'menu']);

bool maPristup(String navId) {
  // 1. Platnost předplatného — blokuje všechny role
  if (!globalPredplatneAktivni && navId != 'menu') return false;

  // 2. Moduly předplatného — určuje přístup pro všechny role
  final modulKlic = navIdToModulKlic[navId];
  if (modulKlic != null && !(globalModuly[modulKlic] ?? false)) return false;

  return true;
}

// DÁLKOVÝ OVLADAČ PRO PŘEPÍNÁNÍ ZÁLOŽEK ZVENČÍ
final ValueNotifier<String?> globalSwitchTabNotifier = ValueNotifier(null);

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _currentTabId = 'prijem';

  final Map<String, _NavData> _allNavItems = {
    'prijem': _NavData(
        page: const MainWizardPage(),
        icon: Icons.add_circle_outline_rounded,
        activeIcon: Icons.add_circle_rounded,
        label: 'Příjem'),
    'zakazky': _NavData(
        page: const ServiceProgressPage(),
        icon: Icons.build_circle_outlined,
        activeIcon: Icons.build_circle,
        label: 'Zakázky'),
    'menu': _NavData(
        page: const MenuPage(),
        icon: Icons.grid_view,
        activeIcon: Icons.grid_view_rounded,
        label: 'Menu'),
    'sklad': _NavData(
        page: const SkladPage(),
        icon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2,
        label: 'Sklad'),
    'planovac': _NavData(
        page: const PlanovacPage(),
        icon: Icons.calendar_today,
        activeIcon: Icons.calendar_today,
        label: 'Plánování'),
    'fakturace': _NavData(
        page: const FakturacePage(),
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: 'Faktury'),
    'vozidla': _NavData(
        page: const VozidlaPage(),
        icon: Icons.directions_car_outlined,
        activeIcon: Icons.directions_car,
        label: 'Vozidla'),
    'ukony': _NavData(
        page: const UkonyPage(),
        icon: Icons.playlist_add_check_circle_outlined,
        activeIcon: Icons.playlist_add_check_circle,
        label: 'Úkony'),
    'zakaznici': _NavData(
        page: const ZakazniciPage(),
        icon: Icons.people_alt_outlined,
        activeIcon: Icons.people_alt,
        label: 'Zákazníci'),
    'zamestnanci': _NavData(
        page: const ZamestnanciPage(),
        icon: Icons.badge_outlined,
        activeIcon: Icons.badge,
        label: 'Tým'),
    'ucetnictvi': _NavData(
        page: const UcetnictviPage(),
        icon: Icons.pie_chart_outline,
        activeIcon: Icons.pie_chart,
        label: 'Účetnictví'),
    'statistiky': _NavData(
        page: const StatisticsPage(),
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: 'Statistiky'),
    'nastaveni': _NavData(
        page: const SettingsPage(),
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Nastavení'),
    'historie_prijmu': _NavData(
        page: const HistoriePrijmuPage(),
        icon: Icons.assignment_add,
        activeIcon: Icons.assignment_add,
        label: 'Příjmy'),
  };

  @override
  void initState() {
    super.initState();
    _loadNavOrder();
    globalSwitchTabNotifier.addListener(_onGlobalTabSwitch);
  }

  void _onGlobalTabSwitch() {
    final targetTabId = globalSwitchTabNotifier.value;

    if (targetTabId != null && mounted) {
      // Future.microtask zajistí, že se přepnutí provede bezpečně až po dokončení aktuálního renderu (např. zavření modalu v plánovači)
      Future.microtask(() {
        if (navOrderNotifier.value.contains(targetTabId)) {
          setState(() {
            _currentTabId = targetTabId;
          });
        }
        globalSwitchTabNotifier.value = null; // Vyčistíme pro další použití
      });
    }
  }

  @override
  void dispose() {
    globalSwitchTabNotifier.removeListener(_onGlobalTabSwitch);
    super.dispose();
  }

  Future<void> _loadNavOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final savedOrder = prefs.getStringList('nav_order');
    if (savedOrder != null && savedOrder.isNotEmpty) {
      navOrderNotifier.value = savedOrder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<List<String>>(
        valueListenable: navOrderNotifier,
        builder: (context, navOrder, child) {
          final filteredNavOrder =
              navOrder.where((id) => maPristup(id)).toList();

          int currentIndex = filteredNavOrder.indexOf(_currentTabId);
          if (currentIndex == -1) {
            currentIndex = 0;
            if (filteredNavOrder.isNotEmpty) {
              Future.microtask(
                  () => setState(() => _currentTabId = filteredNavOrder.first));
            }
          }

          final List<Widget> currentPages =
              filteredNavOrder.map((id) => _allNavItems[id]!.page).toList();
          final List<NavigationDestination> currentDestinations =
              filteredNavOrder.map((id) {
            final item = _allNavItems[id]!;
            return NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.activeIcon),
              label: item.label,
            );
          }).toList();

          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              title: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/torkis-app-icon-192.png',
                      height: 28,
                    ),
                    const SizedBox(width: 8),
                    Text('TORKIS',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black87,
                            letterSpacing: -0.5)),
                  ],
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode,
                      color: isDark ? Colors.amber : Colors.black54),
                  onPressed: () async {
                    final newIsDark = !isDark;
                    themeNotifier.value =
                        newIsDark ? ThemeMode.dark : ThemeMode.light;

                    // Uložení do SharedPreferences — načte se při příštím startu
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('tmavy_rezim', newIsDark);

                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      try {
                        await FirebaseFirestore.instance
                            .collection('uzivatele')
                            .doc(user.uid)
                            .set({
                          'tmavy_rezim': newIsDark,
                        }, SetOptions(merge: true));
                      } catch (e) {
                        debugPrint('Chyba při ukládání motivu: $e');
                      }
                    }
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: IndexedStack(
              index: currentIndex,
              children: currentPages,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentTabId = filteredNavOrder[index];
                });
              },
              backgroundColor: isDark ? const Color(0xFF0D2040) : Colors.white,
              indicatorColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: currentDestinations,
            ),
          );
        });
  }
}

class _NavData {
  final Widget page;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavData(
      {required this.page,
      required this.icon,
      required this.activeIcon,
      required this.label});
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final role = globalUserRole ?? 'zamestnanec';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
              padding: EdgeInsets.only(left: 10, top: 10, bottom: 5),
              child: Text('Moduly',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))),
          Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 20),
              child: Text('Přihlášen jako: ${role.toUpperCase()}',
                  style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14))),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 1.1,
            children: [
              if (maPristup('vozidla'))
                _buildMenuCard(context, 'Vozidla', Icons.directions_car,
                    Colors.teal, const VozidlaPage(), isDark),
              if (maPristup('zakaznici'))
                _buildMenuCard(context, 'Zákazníci', Icons.people_alt,
                    Colors.blue, const ZakazniciPage(), isDark),
              if (maPristup('zakazky'))
                _buildMenuCard(
                    context,
                    'Zakázky',
                    Icons.build_circle,
                    const Color.fromARGB(255, 68, 134, 70),
                    const ServiceProgressPage(),
                    isDark),
              if (maPristup('historie_prijmu'))
                _buildMenuCard(context, 'Historie příjmů', Icons.assignment_add,
                    Colors.blue, const HistoriePrijmuPage(), isDark),
              if (maPristup('sklad'))
                _buildMenuCard(context, 'Sklad dílů', Icons.inventory_2,
                    Colors.orange, const SkladPage(), isDark,
                    hasOwnScaffold: true),
              if (maPristup('fakturace'))
                _buildMenuCard(context, 'Faktury', Icons.receipt_long,
                    Colors.green, const FakturacePage(), isDark),
              if (maPristup('planovac'))
                _buildMenuCard(context, 'Plánování', Icons.calendar_today,
                    Colors.green, const PlanovacPage(), isDark),
              if (maPristup('ukony'))
                _buildMenuCard(
                    context,
                    'Úkony',
                    Icons.playlist_add_check_circle,
                    Colors.deepOrange,
                    const UkonyPage(),
                    isDark),
              if (maPristup('zamestnanci'))
                _buildMenuCard(context, 'Zaměstnanci', Icons.badge,
                    Colors.redAccent, const ZamestnanciPage(), isDark),
              if (maPristup('ucetnictvi'))
                _buildMenuCard(context, 'Účetnictví', Icons.pie_chart,
                    Colors.indigo, const UcetnictviPage(), isDark),
              if (maPristup('statistiky'))
                _buildMenuCard(context, 'Statistiky', Icons.bar_chart,
                    Colors.purple, const StatisticsPage(), isDark),
              if (maPristup('nastaveni'))
                _buildMenuCard(context, 'Nastavení', Icons.settings,
                    Colors.blueGrey, const SettingsPage(), isDark),
              if (globalUserRole == 'admin')
                _buildMenuCard(context, 'Předplatné', Icons.workspace_premium,
                    Colors.amber, const PredplatnePage(), isDark),
              if (globalUserRole == 'admin')
                _buildMenuCard(context, 'Vítací stránka', Icons.public,
                    Colors.cyan, const LandingPage(), isDark),
              if (globalUserRole == 'admin')
                _buildMenuCard(context, 'Doplňky', Icons.extension,
                    Colors.deepPurple, const DoplnkyNastaveniPage(), isDark),
            ],
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Card(
              color: isDark ? const Color(0xFF112240) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/torkis-app-icon-192.png',
                          height: 28,
                        ),
                        const SizedBox(width: 10),
                        const Text('TORKIS',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 18)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('v$kAppVerze',
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildKontaktRadek(
                      Icons.email_outlined,
                      kKontaktEmail,
                      () => launchUrl(Uri.parse('mailto:$kKontaktEmail')),
                      isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildKontaktRadek(
                      Icons.phone_outlined,
                      kKontaktTelefon,
                      () => launchUrl(Uri.parse(
                          'tel:${kKontaktTelefon.replaceAll(' ', '')}')),
                      isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildKontaktRadek(
                      Icons.language_outlined,
                      kKontaktWeb,
                      () => launchUrl(Uri.parse('https://$kKontaktWeb')),
                      isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: OutlinedButton.icon(
              onPressed: () async {
                final potvrdit = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Odhlášení'),
                    content: const Text('Opravdu se chcete odhlásit?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('ZRUŠIT')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('ODHLÁSIT',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (potvrdit == true) {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AuthScreen()),
                      (route) => false,
                    );
                  }
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Odhlásit se',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildKontaktRadek(
      IconData icon, String label, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(color: Colors.blue, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon,
      Color color, Widget? page, bool isDark,
      {bool isLocked = false, bool hasOwnScaffold = false}) {
    return InkWell(
      onTap: isLocked || page == null
          ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Tento modul připravujeme v další verzi!')))
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => hasOwnScaffold
                      ? page
                      : Scaffold(
                          appBar: AppBar(
                              backgroundColor: isDark
                                  ? const Color(0xFF1E3A5F)
                                  : Colors.white,
                              elevation: 1,
                              title: Text(title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))),
                          body: page))),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF112240) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isLocked
                  ? Colors.grey.withValues(alpha: 0.2)
                  : color.withValues(alpha: 0.3),
              width: 2),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: isLocked ? Colors.grey : color),
            const SizedBox(height: 15),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isLocked
                        ? Colors.grey
                        : (isDark ? Colors.white : Colors.black87))),
          ],
        ),
      ),
    );
  }
}
