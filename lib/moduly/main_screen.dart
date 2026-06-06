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
import '../l10n/app_localizations.dart';

// Sjednocené relativní importy!
import 'prijem/prijem_vozidla.dart';
import 'historie_prijmu/historie_prijmu_page.dart';
import 'zakaznici/zakaznici_page.dart';
import 'vozidla/vozidla_page.dart';
import 'ukony.dart';
import 'vin_dekoder.dart';
import 'statistiky.dart';
import 'nastaveni.dart';
import 'zamestnanci.dart';
import 'welcome_screen.dart';
import 'predplatne_page.dart';
import 'prijem/prijem_vozidla_tablet_layout.dart' show kTabletBreakpoint;

// GLOBÁLNÍ NOTIFIER PRO POŘADÍ SPODNÍ LIŠTY
final ValueNotifier<List<String>> navOrderNotifier =
    ValueNotifier(['prijem', 'vozidla', 'zakaznici', 'menu']);

bool maPristup(String navId) {
  // 1. Platnost předplatného — blokuje všechny role
  if (!globalPredplatneAktivni && navId != 'menu') return false;

  // 2. Moduly předplatného — určuje přístup pro všechny role
  final modulKlic = navIdToModulKlic[navId];
  if (modulKlic != null && !(globalModuly[modulKlic] ?? false)) return false;

  // 3. Individuální oprávnění člena týmu (admin má vždy přístup).
  //    Chybějící klíč = povoleno (zpětná kompatibilita se staršími účty).
  if (globalUserRole != 'admin' && kGrantableModuly.contains(navId)) {
    if (!(globalUserPrava[navId] ?? true)) return false;
  }

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

  // Stabilní klíč pro IndexedStack se stránkami. Mobilní a tabletový layout
  // mají odlišnou strukturu stromu — díky společnému GlobalKey Flutter element
  // při změně orientace přesune místo zničení, takže stav rozpracovaných stránek
  // (např. formuláře příjmu) zůstane zachován.
  final GlobalKey _pagesKey = GlobalKey();

  static const Set<String> _validNavIds = {
    'prijem', 'menu', 'vozidla', 'ukony', 'zakaznici',
    'zamestnanci', 'statistiky', 'nastaveni', 'historie_prijmu', 'vin_dekoder',
  };

  Map<String, _NavData> _buildNavItems(AppLocalizations l10n) => {
    'prijem': _NavData(page: const MainWizardPage(), icon: Icons.add_circle_outline_rounded, activeIcon: Icons.add_circle_rounded, label: l10n.mainNavNovy),
    'menu': _NavData(page: const MenuPage(), icon: Icons.grid_view, activeIcon: Icons.grid_view_rounded, label: l10n.mainNavMenu),
    'vozidla': _NavData(page: const VozidlaPage(), icon: Icons.directions_car_outlined, activeIcon: Icons.directions_car, label: l10n.mainNavVozidla),
    'ukony': _NavData(page: const UkonyPage(), icon: Icons.playlist_add_check_circle_outlined, activeIcon: Icons.playlist_add_check_circle, label: l10n.mainNavUkony),
    'zakaznici': _NavData(page: const ZakazniciPage(), icon: Icons.people_alt_outlined, activeIcon: Icons.people_alt, label: l10n.mainNavZakaznici),
    'zamestnanci': _NavData(page: const ZamestnanciPage(), icon: Icons.badge_outlined, activeIcon: Icons.badge, label: l10n.mainNavTym),
    'statistiky': _NavData(page: const StatisticsPage(), icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: l10n.mainNavStatistiky),
    'nastaveni': _NavData(page: const SettingsPage(), icon: Icons.settings_outlined, activeIcon: Icons.settings, label: l10n.mainNavNastaveni),
    'historie_prijmu': _NavData(page: const HistoriePrijmuPage(), icon: Icons.assignment_add, activeIcon: Icons.assignment_add, label: l10n.mainNavPrijmy),
    'vin_dekoder': _NavData(page: const VinDekoderPage(), icon: Icons.travel_explore_outlined, activeIcon: Icons.travel_explore_rounded, label: l10n.mainNavVin),
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
      final validOrder = savedOrder.where(_validNavIds.contains).toList();
      if (validOrder.isNotEmpty) navOrderNotifier.value = validOrder;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final navItems = _buildNavItems(l10n);

    return ValueListenableBuilder<List<String>>(
        valueListenable: navOrderNotifier,
        builder: (context, navOrder, child) {
          final filteredNavOrder = navOrder
              .where((id) => navItems.containsKey(id) && maPristup(id))
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
              filteredNavOrder.map((id) => navItems[id]!.page).toList();
          final List<NavigationDestination> currentDestinations =
              filteredNavOrder.map((id) {
            final item = navItems[id]!;
            return NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.activeIcon),
              label: item.label,
            );
          }).toList();

          return LayoutBuilder(builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= kTabletBreakpoint &&
                MediaQuery.orientationOf(context) == Orientation.landscape;

            if (isTablet) {
              return Scaffold(
                backgroundColor: context.tok.bg,
                body: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      _MainTabletSidebar(
                        navItems: filteredNavOrder
                            .map((id) => (id: id, data: navItems[id]!))
                            .toList(),
                        currentTabId: _currentTabId,
                        isDark: isDark,
                        onTabSelected: (id) =>
                            setState(() => _currentTabId = id),
                        onToggleTheme: () async {
                          final newIsDark = !isDark;
                          themeNotifier.value =
                              newIsDark ? ThemeMode.dark : ThemeMode.light;
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
                          key: _pagesKey,
                          index: currentIndex,
                          children: currentPages,
                        ),
                      ),
                    ],
                  ),
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
                key: _pagesKey,
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
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
    final l10n = AppLocalizations.of(context);
    final role = globalUserRole ?? 'zamestnanec';

    final items = <_ModuleEntry>[
      if (maPristup('vozidla'))
        _ModuleEntry(l10n.mainNavVozidla, Icons.directions_car_outlined, const VozidlaPage(),
            subtitle: l10n.mainModVozidlaSubtitle, countKey: 'vozidla'),
      if (maPristup('zakaznici'))
        _ModuleEntry(l10n.mainNavZakaznici, Icons.people_alt_outlined, const ZakazniciPage(),
            subtitle: l10n.mainModZakazniciSubtitle, countKey: 'zakaznici'),
      if (maPristup('historie_prijmu'))
        _ModuleEntry(l10n.mainModHistorieLabel, Icons.history_rounded,
            const HistoriePrijmuPage(),
            subtitle: l10n.mainModHistorieSubtitle, countKey: 'zakazky'),
      if (maPristup('ukony'))
        _ModuleEntry(l10n.mainNavUkony, Icons.playlist_add_check_rounded, const UkonyPage(),
            subtitle: l10n.mainModUkonySubtitle, countKey: 'ukony'),
      if (maPristup('vin_dekoder'))
        _ModuleEntry(l10n.mainModVinLabel, Icons.travel_explore_rounded, const VinDekoderPage(),
            subtitle: l10n.mainModVinSubtitle),
      if (maPristup('zamestnanci'))
        _ModuleEntry(l10n.mainNavTym, Icons.badge_outlined, const ZamestnanciPage(),
            subtitle: l10n.mainModTymSubtitle, countKey: 'uzivatele'),
      if (maPristup('statistiky'))
        _ModuleEntry(l10n.mainNavStatistiky, Icons.bar_chart_rounded, const StatisticsPage(),
            subtitle: l10n.mainModStatistikySubtitle),
      if (maPristup('nastaveni'))
        _ModuleEntry(l10n.mainNavNastaveni, Icons.settings_outlined, const SettingsPage(),
            subtitle: l10n.mainModNastaveniSubtitle),
      if (globalUserRole == 'admin')
        _ModuleEntry(l10n.mainModPredplatneLabel, Icons.workspace_premium_outlined,
            const PredplatnePage(),
            subtitle: l10n.mainModPredplatneSubtitle),
      if (globalUserRole == 'admin')
        _ModuleEntry(l10n.mainModWebLabel, Icons.public_rounded, const LandingPage(),
            subtitle: l10n.mainModWebSubtitle),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTabletLandscape = constraints.maxWidth >= kTabletBreakpoint &&
            MediaQuery.orientationOf(context) == Orientation.landscape;
        if (isTabletLandscape) {
          final cols = (constraints.maxWidth / 300).floor().clamp(2, 4);
          return _buildTabletLayout(context, tok, role, items, cols, l10n);
        }
        return _buildMobileLayout(context, tok, role, items, l10n);
      },
    );
  }

  void _openModule(BuildContext context, _ModuleEntry e) {
    Navigator.push(
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
    );
  }

  Widget _buildHeader(TorkisTokens tok, String role, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: TokSpace.xs, vertical: 4),
          child: Text(
            l10n.mainModulyNadpis,
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
                  l10n.mainPrihlasenv,
                  style: TextStyle(fontSize: 13, color: tok.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Mobil (na výšku) — ponecháno beze změny ───────────────────────────────
  Widget _buildMobileLayout(BuildContext context, TorkisTokens tok, String role,
      List<_ModuleEntry> items, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          TokSpace.lg, TokSpace.sm, TokSpace.lg, TokSpace.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(tok, role, l10n),
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
                      onTap: () => _openModule(context, e),
                    ))
                .toList(),
          ),
          const SizedBox(height: TokSpace.xxl),
          _ContactCard(tok: tok),
          const SizedBox(height: TokSpace.md),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  // ── iPad (na šířku) — mřížka karet se živými počty ────────────────────────
  Widget _buildTabletLayout(BuildContext context, TorkisTokens tok, String role,
      List<_ModuleEntry> items, int cols, AppLocalizations l10n) {
    final sId = globalServisId ?? FirebaseAuth.instance.currentUser?.uid;
    final collections =
        items.map((e) => e.countKey).whereType<String>().toSet();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          TokSpace.xl, TokSpace.lg, TokSpace.xl, TokSpace.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(tok, role, l10n),
          FutureBuilder<Map<String, int>>(
            future: _fetchCounts(sId, collections),
            builder: (context, snap) {
              final counts = snap.data ?? const <String, int>{};
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: TokSpace.lg,
                crossAxisSpacing: TokSpace.lg,
                childAspectRatio: 1.7,
                children: items
                    .map((e) => _ModuleGridCard(
                          entry: e,
                          count: e.countKey != null ? counts[e.countKey] : null,
                          onTap: () => _openModule(context, e),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: TokSpace.xxl),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                _ContactCard(tok: tok),
                const SizedBox(height: TokSpace.md),
                _buildLogoutButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, int>> _fetchCounts(
      String? sId, Set<String> collections) async {
    final result = <String, int>{};
    if (sId == null) return result;
    await Future.wait(collections.map((c) async {
      try {
        final snap = await FirebaseFirestore.instance
            .collection(c)
            .where('servis_id', isEqualTo: sId)
            .count()
            .get();
        result[c] = snap.count ?? 0;
      } catch (_) {}
    }));
    return result;
  }

  Widget _buildLogoutButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TorkisSecondaryButton(
      label: l10n.mainOdhlasitSe,
      leadingIcon: Icons.logout_rounded,
      onPressed: () async {
        final potvrdit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.mainOdhlaseniTitle),
            content: Text(l10n.mainOdhlaseniContent),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.mainZrusit)),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    l10n.mainOdhlasit,
                    style: const TextStyle(color: TokColors.danger),
                  )),
            ],
          ),
        );
        if (potvrdit == true) {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AuthScreen()),
              (route) => false,
            );
          }
        }
      },
    );
  }
}

class _ModuleEntry {
  final String label;
  final IconData icon;
  final Widget page;
  final String? subtitle;
  // Kolekce ve Firestore pro živý počet (filtr servis_id). null = bez počtu.
  final String? countKey;
  const _ModuleEntry(this.label, this.icon, this.page,
      {this.subtitle, this.countKey});
}

/// Bohatá karta modulu pro iPad na šířku — ikona, živý počet, název, popis.
class _ModuleGridCard extends StatelessWidget {
  final _ModuleEntry entry;
  final int? count;
  final VoidCallback onTap;
  const _ModuleGridCard(
      {required this.entry, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    final iconBg = tok.isDark
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFEFF1F4);
    return Material(
      color: tok.surface,
      borderRadius: BorderRadius.circular(TokRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TokRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(TokSpace.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TokRadius.xl),
            border: Border.all(color: tok.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(TokRadius.md),
                    ),
                    child: Icon(entry.icon, size: 22, color: tok.textPrimary),
                  ),
                  const Spacer(),
                  if (count != null)
                    Text(
                      _formatPocet(count!),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: tok.textPrimary,
                      ),
                    )
                  else
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: tok.textSecondary),
                ],
              ),
              const Spacer(),
              Text(
                entry.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: tok.textPrimary,
                ),
              ),
              if (entry.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  entry.subtitle!,
                  style: TextStyle(fontSize: 12, color: tok.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _formatPocet(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return buf.toString();
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: TokColors.accentSoft,
                  borderRadius: BorderRadius.circular(TokRadius.round),
                ),
                child: const Text(
                  'v$kAppVerze',
                  style: TextStyle(
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
              child: Image.asset(
                'assets/images/torkis-app-icon-256.png',
                width: 36,
                height: 36,
              ),
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
                    tooltip: isDark ? AppLocalizations.of(context).mainSvetlyRezim : AppLocalizations.of(context).mainTmavyRezim,
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
                    color: isActive ? TokColors.accent : TokColors.steelSoft,
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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
