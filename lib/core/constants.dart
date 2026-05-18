import 'package:flutter/material.dart';

const String kAppVerze = '4.1.9';
const String kKontaktEmail = 'podpora@torkis.cz';
const String kKontaktTelefon = '+420 731 901 003';
const String kKontaktWeb = 'torkis.cz';

// Globální ThemeNotifier pro přepínání světlého a tmavého režimu
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

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
  'pro': [
    'prijem',
    'zakazky',
    'zakaznici',
    'vozidla',
    'historie_prijmu',
    'planovac',
    'sklad',
    'fakturace',
    'ucetnictvi',
    'statistiky',
    'zamestnanci',
  ],
};

/// Mapování nav ID → klíč v globalModuly (null = vždy přístupné bez ohledu na plán).
const Map<String, String?> navIdToModulKlic = {
  'prijem': 'prijem',
  'zakazky': 'zakazky',
  'planovac': 'planovac',
  'sklad': 'sklad',
  'fakturace': 'fakturace',
  'ucetnictvi': 'ucetnictvi',
  'statistiky': 'statistiky',
  'zamestnanci': 'zamestnanci',
  'historie_prijmu': 'prijem',
  'nastaveni': null,
  'ukony': null,
  'vozidla': null,
  'zakaznici': null,
  'menu': null,
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
