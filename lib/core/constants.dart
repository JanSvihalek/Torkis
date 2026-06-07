import 'package:flutter/material.dart';

const String kAppVerze = '5.3.8';
const String kKontaktEmail = 'podpora@torkis.cz';
const String kKontaktTelefon = '+420 731 901 003';
const String kKontaktWeb = 'torkis.cz';

// Globální ThemeNotifier pro přepínání světlého a tmavého režimu
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// Globální LocaleNotifier — null = sledovat systémový jazyk
final ValueNotifier<Locale?> localeNotifier = ValueNotifier(null);

// Osobní nastavení uživatele — klíč v SharedPreferences pro režim pro leváky
// (spoušť fotoaparátu na levé straně, když je zařízení na šířku).
const String kPrefKameraSpoustVlevo = 'kamera_spoust_vlevo';

// Osobní (per-zařízení) volba: ukládat fotky z příjmu i do galerie zařízení.
const String kPrefUkladatFotoDoZarizeni = 'ukladat_foto_do_zarizeni';

// Seznam dostupných stavů zakázky
const List<String> stavyZakazky = [
  'Přijato',
  'V řešení',
  'Čeká na díly',
  'Dokončeno',
];

// Přiřazení barev k jednotlivým stavům
Color getStatusColor(String stav) {
  switch (stav) {
    case 'Přijato':
      return Colors.blue;
    case 'V řešení':
      return Colors.orange;
    case 'Čeká na díly':
      return Colors.red;
    case 'Dokončeno':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

// Kategorie fotografií pro Příjem a Průběh
// LOGICKÉ POŘADÍ (Obchůzka zvenku -> Sednutí dovnitř)
final Map<String, Map<String, dynamic>> photoCategories = {
  'zvenku': {
    'label': 'Pohled zvenku (kolem vozu)',
    'icon': Icons.directions_car,
  },
  'poskozeni': {'label': 'Zjištěná poškození', 'icon': Icons.car_crash},
  'disky': {'label': 'Disky a kola', 'icon': Icons.tire_repair},
  'stk': {'label': 'Nálepka STK', 'icon': Icons.calendar_month},
  'interier': {
    'label': 'Interiér vozu',
    'icon': Icons.airline_seat_recline_normal,
  },
  'tachometr': {'label': 'Tachometr a palubní deska', 'icon': Icons.speed},
  'vin': {'label': 'VIN kód', 'icon': Icons.confirmation_number},
  'ostatni': {'label': 'Ostatní dokumentace', 'icon': Icons.camera_alt},
};

// ============================================================
// PŘEDPLATNÉ — výchozí moduly podle plánu
// ============================================================

/// Výchozí moduly povolené pro každý typ plánu.
const Map<String, List<String>> kPlanModuly = {
  'basic': [
    'prijem',
    'zakaznici',
    'vozidla',
    'historie_prijmu',
    'zamestnanci',
  ],
  'standard': [
    'prijem',
    'zakaznici',
    'vozidla',
    'historie_prijmu',
    'statistiky',
    'zamestnanci',
  ],
  'pro': [
    'prijem',
    'zakaznici',
    'vozidla',
    'historie_prijmu',
    'statistiky',
    'zamestnanci',
  ],
  // Trial = plný přístup (jako Pro), aby uživatel viděl všechny funkce.
  // Limity (kPlanPrijemLimit, kPlanUserLimit) jsou pro 'trial' také null.
  'trial': [
    'prijem',
    'zakaznici',
    'vozidla',
    'historie_prijmu',
    'statistiky',
    'zamestnanci',
  ],
};

/// Maximální počet příjmů za měsíc dle plánu (null = neomezeno).
const Map<String, int?> kPlanPrijemLimit = {
  'basic': 50,
  'standard': 150,
  'pro': null,
  // Trial: štědrý strop jako pojistka proti scriptování / e-mailovému spamu.
  // Genuinní zákazník to za 30 dní nevyčerpá.
  'trial': 150,
  'custom': null,
};

/// Maximální počet dekódování VIN za měsíc dle plánu (null = neomezeno).
/// Počítají se pouze skutečná API volání (z_cache == false).
/// POZN.: musí zůstat v souladu s functions/index.js → VIN_LIMITS.
const Map<String, int?> kPlanVinLimit = {
  'basic': 30,
  'standard': 60,
  'pro': 150,
  'trial': 10,
  'custom': null,
};

/// Maximální počet zjištění tržní hodnoty za měsíc dle plánu (null = neomezeno).
/// Počítají se pouze skutečná API volání (z_cache == false).
/// Tržní hodnota je drahá (Vincario value balíček, min. 4 990 Kč/měsíc) — dostupná jen v Pro.
/// POZN.: musí zůstat v souladu s functions/index.js → VALUE_LIMITS.
const Map<String, int?> kPlanValueLimit = {
  'basic': 0,
  'standard': 0,
  'pro': 5,
  'trial': 0,
  'custom': null,
};

/// Maximální počet uživatelských účtů (členů týmu) dle plánu (null = neomezeno).
/// Limit zahrnuje admina i všechny zaměstnance.
const Map<String, int?> kPlanUserLimit = {
  'basic': 3,
  'standard': 10,
  'pro': null,
  'trial': null,
  'custom': null,
};

/// Mapování nav ID → klíč v globalModuly (null = vždy přístupné bez ohledu na plán).
const Map<String, String?> navIdToModulKlic = {
  'prijem': 'prijem',
  'statistiky': 'statistiky',
  'zamestnanci': 'zamestnanci',
  'historie_prijmu': 'prijem',
  'nastaveni': null,
  'ukony': null,
  'vozidla': null,
  'zakaznici': null,
  'menu': null,
  'vin_dekoder': null,
};

/// Moduly, na které lze členům týmu udělovat individuální oprávnění.
/// Admin má vždy přístup ke všem; 'menu' je vždy dostupné, proto v seznamu není.
const List<String> kGrantableModuly = [
  'prijem',
  'vozidla',
  'zakaznici',
  'historie_prijmu',
  'ukony',
  'vin_dekoder',
  'statistiky',
  'zamestnanci',
  'nastaveni',
];

/// Citlivé moduly, které jsou novému členovi týmu ve výchozím stavu zakázané.
const Set<String> kCitliveModuly = {'statistiky', 'zamestnanci', 'nastaveni'};

/// Výchozí oprávnění pro nového člena týmu: provozní moduly zapnuté,
/// citlivé oblasti (statistiky, správa týmu, nastavení) vypnuté.
Map<String, bool> defaultZamestnanecPrava() => {
      for (final m in kGrantableModuly) m: !kCitliveModuly.contains(m),
    };

// Globální stav předplatného (nastaven v auth_gate.dart při přihlášení)
String globalPlanTyp = 'basic';
Map<String, bool> globalModuly = {};
DateTime? globalPredplatnePlatnost;

bool get globalPredplatneAktivni {
  if (globalPredplatnePlatnost == null) return true;
  return globalPredplatnePlatnost!.isAfter(DateTime.now());
}

bool maPristupModul(String modulKlic) {
  if (!globalPredplatneAktivni) return false;
  return globalModuly[modulKlic] ?? false;
}

// ============================================================
// Třída pro dynamické zadávání použitých dílů (používá se v prubeh.dart)
class DilInput {
  final TextEditingController cislo = TextEditingController();
  final TextEditingController nazev = TextEditingController();
  final TextEditingController pocet = TextEditingController(text: '1');
  final TextEditingController cenaBezDph = TextEditingController();
  final TextEditingController cenaSDph = TextEditingController();

  void dispose() {
    cislo.dispose();
    nazev.dispose();
    pocet.dispose();
    cenaBezDph.dispose();
    cenaSDph.dispose();
  }
}
