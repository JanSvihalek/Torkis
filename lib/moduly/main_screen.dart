import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import '../core/design_tokens.dart';
import '../core/torkis_ui.dart';
import 'auth_gate.dart';
import 'auth_screen.dart';

// Sjednocené relativní importy!
import 'prijem/prijem_vozidla.dart';
import 'historie_prijmu/historie_prijmu_page.dart';
import 'zakaznici/zakaznici_page.dart';
import 'vozidla/vozidla_page.dart';
import 'ukony.dart';
import 'statistiky.dart';
import 'nastaveni.dart';
import 'zamestnanci.dart';
import 'welcome_screen.dart';
import 'predplatne_page.dart';
import 'prijem/prijem_vozidla_tablet_layout.dart' show kTabletBreakpoint;

// GLOBÁLNÍ NOTIFIER PRO POŘADÍ SPODNÍ LIŠTY
final ValueNotifier<List<String>> navOrderNotifier =
    ValueNotifier(['prijem', 'menu']);

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
    'menu': _NavData(
        page: const MenuPage(),
        icon: Icons.grid_view,
        activeIcon: Icons.grid_view_rounded,
        label: 'Menu'),
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
      final validOrder = savedOrder.where(_allNavItems.containsKey).toList();
      if (validOrder.isNotEmpty) navOrderNotifier.value = validOrder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<List<String>>(
        valueListenable: navOrderNotifier,
        builder: (context, navOrder, child) {
          final filteredNavOrder = navOrder
              .where((id) => _allNavItems.containsKey(id) && maPristup(id))
              .toList();

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

          return LayoutBuilder(builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= kTabletBreakpoint;

            if (isTablet) {
              return Scaffold(
                backgroundColor: context.tok.bg,
                body: Row(
                  children: [
                    _MainTabletSidebar(
                      navItems: filteredNavOrder
                          .map((id) => (id: id, data: _allNavItems[id]!))
                          .toList(),
                      currentTabId: _currentTabId,
                      isDark: isDark,
                      onTabSelected: (id) =>
                          setState(() => _currentTabId = id),
                      onToggleTheme: () async {
                        final newIsDark = !isDark;
                        themeNotifier.value = newIsDark
                            ? ThemeMode.dark
                            : ThemeMode.light;
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('tmavy_rezim', newIsDark);
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('uzivatele')
                              .doc(user.uid)
                              .set({'tmavy_rezim': newIsDark},
                                  SetOptions(merge: true));
                        }
                      },
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: currentIndex,
                        children: currentPages,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Scaffold(
              backgroundColor: context.tok.bg,
              appBar: AppBar(
                titleSpacing: 0,
                backgroundColor: context.tok.bg,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                title: Padding(
                  padding: const EdgeInsets.only(left: TokSpace.xl),
                  child: Row(
                    children: [
                      TorkisMark(size: 26, color: context.tok.ink),
                      const SizedBox(width: 9),
                      Text(
                        'TORKIS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: context.tok.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                centerTitle: false,
                actions: [
                  _AppBarIconButton(
                    icon: isDark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    onPressed: () async {
                      final newIsDark = !isDark;
                      themeNotifier.value =
                          newIsDark ? ThemeMode.dark : ThemeMode.light;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('tmavy_rezim', newIsDark);
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('uzivatele')
                              .doc(user.uid)
                              .set({'tmavy_rezim': newIsDark},
                                  SetOptions(merge: true));
                        } catch (e) {
                          debugPrint('Chyba při ukládání motivu: $e');
                        }
                      }
                    },
                  ),
                  const SizedBox(width: TokSpace.lg),
                ],
              ),
              body: IndexedStack(
                index: currentIndex,
                children: currentPages,
              ),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: context.tok.surface,
                  border: Border(
                    top: BorderSide(color: context.tok.line, width: 1),
                  ),
                ),
                child: NavigationBar(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentTabId = filteredNavOrder[index];
                    });
                  },
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  indicatorColor: TokColors.accentSoft,
                  labelBehavior:
                      NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: currentDestinations,
                ),
              ),
            );
          });
        });
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _AppBarIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    return InkResponse(
      onTap: onPressed,
      radius: 24,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: tok.surface,
          border: Border.all(color: tok.line),
          borderRadius: BorderRadius.circular(TokRadius.round),
        ),
        child: Icon(icon, size: 18, color: tok.textSecondary),
      ),
    );
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
    final tok = context.tok;
    final role = globalUserRole ?? 'zamestnanec';

    final items = <_ModuleEntry>[
      if (maPristup('vozidla'))
        _ModuleEntry('Vozidla', Icons.directions_car_outlined,
            const VozidlaPage()),
      if (maPristup('zakaznici'))
        _ModuleEntry('Zákazníci', Icons.people_alt_outlined,
            const ZakazniciPage()),
      if (maPristup('historie_prijmu'))
        _ModuleEntry('Historie příjmů', Icons.history_rounded,
            const HistoriePrijmuPage()),
      if (maPristup('ukony'))
        _ModuleEntry('Úkony', Icons.playlist_add_check_rounded,
            const UkonyPage()),
      if (maPristup('zamestnanci'))
        _ModuleEntry('Tým', Icons.badge_outlined, const ZamestnanciPage()),
      if (maPristup('statistiky'))
        _ModuleEntry(
            'Statistiky', Icons.bar_chart_rounded, const StatisticsPage()),
      if (maPristup('nastaveni'))
        _ModuleEntry(
            'Nastavení', Icons.settings_outlined, const SettingsPage()),
      if (globalUserRole == 'admin')
        _ModuleEntry('Předplatné', Icons.workspace_premium_outlined,
            const PredplatnePage()),
      if (globalUserRole == 'admin')
        _ModuleEntry('Web', Icons.public_rounded, const LandingPage()),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          TokSpace.lg, TokSpace.sm, TokSpace.lg, TokSpace.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: TokSpace.xs, vertical: 4),
            child: Text(
              'Moduly',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: tok.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                left: TokSpace.xs, top: 4, bottom: TokSpace.lg),
            child: Row(
              children: [
                TorkisRolePill(role: role),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Přihlášen v servisu',
                    style: TextStyle(
                      fontSize: 13,
                      color: tok.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1 / 0.95,
            children: items
                .map((e) => TorkisModuleCard(
                      icon: e.icon,
                      label: e.label,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            backgroundColor: context.tok.bg,
                            appBar: AppBar(
                              title: Text(e.label),
                              backgroundColor: context.tok.bg,
                              surfaceTintColor: Colors.transparent,
                              elevation: 0,
                            ),
                            body: e.page,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: TokSpace.xxl),
          _ContactCard(tok: tok),
          const SizedBox(height: TokSpace.md),
          TorkisSecondaryButton(
            label: 'Odhlásit se',
            leadingIcon: Icons.logout_rounded,
            onPressed: () async {
              final potvrdit = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Odhlášení'),
                  content: const Text('Opravdu se chcete odhlásit?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Zrušit')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Odhlásit',
                          style: TextStyle(color: TokColors.danger),
                        )),
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
          ),
        ],
      ),
    );
  }
}

class _ModuleEntry {
  final String label;
  final IconData icon;
  final Widget page;
  const _ModuleEntry(this.label, this.icon, this.page);
}

class _ContactCard extends StatelessWidget {
  final TorkisTokens tok;
  const _ContactCard({required this.tok});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TokSpace.xl),
      decoration: BoxDecoration(
        color: tok.surface,
        borderRadius: BorderRadius.circular(TokRadius.xl),
        border: Border.all(color: tok.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TorkisMark(size: 22, color: tok.ink),
              const SizedBox(width: 8),
              Text('TORKIS',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 1.1,
                    color: tok.textPrimary,
                  )),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: TokColors.accentSoft,
                  borderRadius: BorderRadius.circular(TokRadius.round),
                ),
                child: Text(
                  'v$kAppVerze',
                  style: const TextStyle(
                    color: TokColors.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 24, color: tok.line),
          _kontaktRadek(Icons.email_outlined, kKontaktEmail,
              () => launchUrl(Uri.parse('mailto:$kKontaktEmail'))),
          const SizedBox(height: 10),
          _kontaktRadek(
              Icons.phone_outlined,
              kKontaktTelefon,
              () => launchUrl(
                  Uri.parse('tel:${kKontaktTelefon.replaceAll(' ', '')}'))),
          const SizedBox(height: 10),
          _kontaktRadek(Icons.language_outlined, kKontaktWeb,
              () => launchUrl(Uri.parse('https://$kKontaktWeb'))),
        ],
      ),
    );
  }

  Widget _kontaktRadek(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TokRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(icon, size: 16, color: TokColors.accent),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: TokColors.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tablet sidebar navigace ───────────────────────────────────────────────────

class _MainTabletSidebar extends StatelessWidget {
  final List<({String id, _NavData data})> navItems;
  final String currentTabId;
  final bool isDark;
  final ValueChanged<String> onTabSelected;
  final VoidCallback onToggleTheme;

  const _MainTabletSidebar({
    required this.navItems,
    required this.currentTabId,
    required this.isDark,
    required this.onTabSelected,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      color: TokColors.ink,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: TokSpace.lg),
              child: TorkisMark(size: 26, color: TokColors.accent),
            ),
          ),
          const Divider(color: TokColors.darkLine, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: TokSpace.md),
              children: navItems
                  .map((e) => _SidebarNavItem(
                        icon: e.data.icon,
                        activeIcon: e.data.activeIcon,
                        label: e.data.label,
                        isActive: currentTabId == e.id,
                        onTap: () => onTabSelected(e.id),
                      ))
                  .toList(),
            ),
          ),
          const Divider(color: TokColors.darkLine, height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: TokSpace.md),
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: TokColors.steelSoft,
                      size: 20,
                    ),
                    onPressed: onToggleTheme,
                    tooltip: isDark ? 'Světlý režim' : 'Tmavý režim',
                  ),
                  const SizedBox(height: TokSpace.sm),
                  _SidebarUserChip(),
                  const SizedBox(height: TokSpace.sm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Material(
        color: isActive
            ? TokColors.accent.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(TokRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(TokRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? TokColors.accent : TokColors.steelSoft,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color:
                        isActive ? TokColors.accent : TokColors.steelSoft,
                    fontSize: 10,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarUserChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String initials = '?';
    final name = user?.displayName;
    if (name != null && name.isNotEmpty) {
      final parts = name.trim().split(' ');
      initials = parts.length >= 2
          ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
          : name[0].toUpperCase();
    } else if (user?.email != null) {
      initials = user!.email![0].toUpperCase();
    }
    return CircleAvatar(
      radius: 14,
      backgroundColor: TokColors.accent.withValues(alpha: 0.2),
      child: Text(
        initials,
        style: const TextStyle(
          color: TokColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
