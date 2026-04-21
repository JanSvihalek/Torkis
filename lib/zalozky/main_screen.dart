import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:torkis/zalozky/planovac.dart';

import '../core/constants.dart';
import 'auth_gate.dart'; // Kvůli globalServisId a globalUserRole

import 'prubeh.dart';
import 'prijem_vozidla.dart';
import 'historie.dart';
import 'zakaznici.dart';
import 'vozidla.dart';
import 'ukony.dart';
import 'fakturace.dart';
import 'statistiky.dart';
import 'nastaveni.dart';
import 'ucetnictvi.dart';
import 'zamestnanci.dart';
import 'sklad.dart';

// GLOBÁLNÍ NOTIFIER PRO POŘADÍ SPODNÍ LIŠTY
final ValueNotifier<List<String>> navOrderNotifier =
    ValueNotifier(['prijem', 'zakazky', 'historie', 'menu']);

// --- PŘIDÁNO: DÁLKOVÝ OVLADAČ PRO PŘEPÍNÁNÍ ZÁLOŽEK ZVENČÍ ---
// Poslouží nám na předávání povelů z detailu plánovače apod.
final ValueNotifier<String?> globalSwitchTabNotifier = ValueNotifier(null);

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Pamatujeme si ID aktuálního tabu
  String _currentTabId = 'prijem';

  // DATABÁZE VŠECH DOSTUPNÝCH MODULŮ PRO SPODNÍ LIŠTU
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
    'historie': _NavData(
        page: const HistoryPage(),
        icon: Icons.history_rounded,
        activeIcon: Icons.history_rounded,
        label: 'Historie'),
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
  };

  @override
  void initState() {
    super.initState();
    _loadNavOrder();

    // --- PŘIDÁNO: Naslouchání na signál zvenčí ---
    globalSwitchTabNotifier.addListener(_onGlobalTabSwitch);
  }

  // --- PŘIDÁNO: Funkce pro přepnutí tabu zvenčí ---
  void _onGlobalTabSwitch() {
    final targetTabId = globalSwitchTabNotifier.value;

    if (targetTabId != null && mounted) {
      // Zjistíme, jestli cílový tab (např. 'prijem') je vůbec ve spodním menu
      if (navOrderNotifier.value.contains(targetTabId)) {
        setState(() {
          _currentTabId = targetTabId;
        });
      } else {
        // Pokud tab ve spodní liště NENÍ, hodíme pro jistotu chybovou hlášku
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Tato záložka není ve spodním menu! Přidejte si ji tam v nastavení.'),
          backgroundColor: Colors.orange,
        ));
      }

      // Vynulujeme vysílač, aby reagoval i na další kliknutí
      globalSwitchTabNotifier.value = null;
    }
  }

  @override
  void dispose() {
    globalSwitchTabNotifier.removeListener(_onGlobalTabSwitch);
    super.dispose();
  }

  // Načtení uloženého pořadí z paměti zařízení
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
          // Zjistíme, na jakém indexu se aktuálně nachází náš aktivní tab
          int currentIndex = navOrder.indexOf(_currentTabId);
          if (currentIndex == -1) currentIndex = 0;

          // Sestavíme aktuální seznam stránek a tlačítek podle uživatelského výběru
          final List<Widget> currentPages =
              navOrder.map((id) => _allNavItems[id]!.page).toList();
          final List<NavigationDestination> currentDestinations =
              navOrder.map((id) {
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
                    Icon(Icons.car_repair,
                        color: Theme.of(context).colorScheme.primary, size: 28),
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
                  _currentTabId = navOrder[index];
                });
              },
              backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              indicatorColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: currentDestinations,
            ),
          );
        });
  }
}

// Pomocná třída pro uložení dat o jednom tabu
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

// ============================================================================
// STRÁNKA MENU (MŘÍŽKA S MODULY)
// ============================================================================
class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final role = globalUserRole ?? 'mechanik';
    final isAdmin = role == 'admin';
    final isTechnik = role == 'technik' || isAdmin;

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
              // Moduly dostupné pro všechny (i pro mechaniky)

              _buildMenuCard(context, 'Vozidla', Icons.directions_car,
                  Colors.teal, const VozidlaPage(), isDark),
              _buildMenuCard(context, 'Zákazníci', Icons.people_alt,
                  Colors.blue, const ZakazniciPage(), isDark),
              _buildMenuCard(
                  context,
                  'Zakázky',
                  Icons.build_circle,
                  const Color.fromARGB(255, 68, 134, 70),
                  const ServiceProgressPage(),
                  isDark),
              _buildMenuCard(context, 'Sklad dílů', Icons.inventory_2,
                  Colors.orange, const SkladPage(), isDark,
                  hasOwnScaffold: true),
              _buildMenuCard(context, 'Faktury', Icons.receipt_long,
                  Colors.green, const FakturacePage(), isDark),
              _buildMenuCard(context, 'Plánování', Icons.calendar_today,
                  Colors.green, const PlanovacPage(), isDark),
              _buildMenuCard(context, 'Úkony', Icons.playlist_add_check_circle,
                  Colors.deepOrange, const UkonyPage(), isDark),
              _buildMenuCard(context, 'Zaměstnanci', Icons.badge,
                  Colors.redAccent, const ZamestnanciPage(), isDark),
              _buildMenuCard(context, 'Účetnictví', Icons.pie_chart,
                  Colors.indigo, const UcetnictviPage(), isDark),
              _buildMenuCard(context, 'Statistiky', Icons.bar_chart,
                  Colors.purple, const StatisticsPage(), isDark),
              _buildMenuCard(context, 'Nastavení', Icons.settings,
                  Colors.blueGrey, const SettingsPage(), isDark),
            ],
          ),
          const SizedBox(height: 40),
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
                                    ? const Color(0xFF1A1A1A)
                                    : Colors.white,
                                elevation: 1,
                                title: Text(title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))),
                            body: page,
                          )),
              ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isLocked
                  ? Colors.grey.withOpacity(0.2)
                  : color.withOpacity(0.3),
              width: 2),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                  color: color.withOpacity(0.1),
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
            if (isLocked) ...[
              const SizedBox(height: 5),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5)),
                  child: const Text('Připravujeme',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold))),
            ],
          ],
        ),
      ),
    );
  }
}
