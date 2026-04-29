const List<Map<String, String>> kPredvolby = [
  {'kod': '+420', 'vlajka': '🇨🇿', 'nazev': 'Česká republika'},
  {'kod': '+421', 'vlajka': '🇸🇰', 'nazev': 'Slovensko'},
  {'kod': '+49', 'vlajka': '🇩🇪', 'nazev': 'Německo'},
  {'kod': '+43', 'vlajka': '🇦🇹', 'nazev': 'Rakousko'},
  {'kod': '+48', 'vlajka': '🇵🇱', 'nazev': 'Polsko'},
  {'kod': '+36', 'vlajka': '🇭🇺', 'nazev': 'Maďarsko'},
  {'kod': '+380', 'vlajka': '🇺🇦', 'nazev': 'Ukrajina'},
  {'kod': '+44', 'vlajka': '🇬🇧', 'nazev': 'Velká Británie'},
  {'kod': '+1', 'vlajka': '🇺🇸', 'nazev': 'USA'},
  {'kod': '+7', 'vlajka': '🇷🇺', 'nazev': 'Rusko'},
];

String formatTelefon(String? tel) {
  if (tel == null || tel.isEmpty) return '';
  for (final p in kPredvolby) {
    final kod = p['kod']!;
    if (tel.startsWith(kod)) return '$kod ${tel.substring(kod.length).trim()}';
  }
  return tel;
}
