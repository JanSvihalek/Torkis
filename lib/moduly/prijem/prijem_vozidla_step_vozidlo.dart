import 'package:flutter/material.dart';
import '../../core/design_tokens.dart';
import '../../core/torkis_ui.dart';
import 'prijem_vozidla_helpers.dart';

const _kVsechnyZeme = {
  'CZ': '🇨🇿 Česká republika',
  'SK': '🇸🇰 Slovensko',
  'DE': '🇩🇪 Německo',
  'AT': '🇦🇹 Rakousko',
  'PL': '🇵🇱 Polsko',
  'HU': '🇭🇺 Maďarsko',
  'FR': '🇫🇷 Francie',
  'IT': '🇮🇹 Itálie',
  'GB': '🇬🇧 Velká Británie',
  'NL': '🇳🇱 Nizozemsko',
  'BE': '🇧🇪 Belgie',
  'RO': '🇷🇴 Rumunsko',
  'UA': '🇺🇦 Ukrajina',
  'HR': '🇭🇷 Chorvatsko',
  'SI': '🇸🇮 Slovinsko',
  'BG': '🇧🇬 Bulharsko',
  'LT': '🇱🇹 Litva',
  'LV': '🇱🇻 Lotyšsko',
  'EE': '🇪🇪 Estonsko',
  'RU': '🇷🇺 Rusko',
};

/// Krok 1 – Identifikace vozidla.
/// Pole: číslo zakázky, SPZ, VIN, značka + model (autocomplete), rok výroby,
/// palivo, převodovka, motorizace.
class StepVozidlo extends StatelessWidget {
  final bool isDark;

  // Stav zakázky
  final TextEditingController zakazkaController;
  final bool autoGenerateCislo;
  final bool isGeneratingCislo;
  final VoidCallback onRegenerateCislo;

  // Stav SPZ / vozidlo
  final TextEditingController spzController;
  final TextEditingController vinController;
  final TextEditingController znackaController;
  final TextEditingController modelController;
  final TextEditingController rokVyrobyController;
  final TextEditingController motorizaceController;

  final bool isLoadingSpz;
  final VoidCallback onHledatSpz;
  final bool isLoadingVin;
  final VoidCallback onHledatVin;
  final void Function(TextEditingController, bool) onScan;
  final VoidCallback? onScanZnacka;
  final VoidCallback? onScanModel;
  final VoidCallback? onScanVinOrSpz;

  // Autocomplete
  final int autocompleteResetKey;
  final List<String> dostupneZnacky;
  final List<String> dostupneModely;
  final Map<String, String> logovaZnacek;
  final Map<String, List<String>> databazeZnacek;
  final void Function(String) onZnackaSelected;
  final void Function(String) onModelSelected;

  // Palivo / převodovka
  final String vybranePalivo;
  final List<String> moznostiPaliva;
  final ValueChanged<String?> onPalivoChanged;

  final String vybranaPrevodovka;
  final List<String> moznostiPrevodovky;
  final ValueChanged<String?> onPrevodovkaChanged;

  // Vozidla zákazníka (chip list)
  final List<Map<String, dynamic>> nalezenaVozidla;
  final void Function(Map<String, dynamic>) onVozidloSelected;

  // Typ karosérie
  final String typKaroserie;
  final List<String> moznostiKaroserie;
  final ValueChanged<String?> onKaroserieChanged;

  // Země registrace
  final String zemeRegistrace;
  final ValueChanged<String> onZemeChanged;

  // Typ záznamu
  final String typZaznamu;
  final List<String> typyZaznamu;
  final ValueChanged<String> onTypZaznamuChanged;

  const StepVozidlo({
    super.key,
    required this.isDark,
    required this.zakazkaController,
    required this.autoGenerateCislo,
    required this.isGeneratingCislo,
    required this.onRegenerateCislo,
    required this.spzController,
    required this.vinController,
    required this.znackaController,
    required this.modelController,
    required this.rokVyrobyController,
    required this.motorizaceController,
    required this.isLoadingSpz,
    required this.onHledatSpz,
    required this.isLoadingVin,
    required this.onHledatVin,
    required this.onScan,
    this.onScanZnacka,
    this.onScanModel,
    this.onScanVinOrSpz,
    required this.autocompleteResetKey,
    required this.dostupneZnacky,
    required this.dostupneModely,
    required this.logovaZnacek,
    required this.databazeZnacek,
    required this.onZnackaSelected,
    required this.onModelSelected,
    required this.vybranePalivo,
    required this.moznostiPaliva,
    required this.onPalivoChanged,
    required this.vybranaPrevodovka,
    required this.moznostiPrevodovky,
    required this.onPrevodovkaChanged,
    required this.nalezenaVozidla,
    required this.onVozidloSelected,
    required this.typKaroserie,
    required this.moznostiKaroserie,
    required this.onKaroserieChanged,
    required this.zemeRegistrace,
    required this.onZemeChanged,
    required this.typZaznamu,
    required this.typyZaznamu,
    required this.onTypZaznamuChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          TokSpace.xl, TokSpace.lg, TokSpace.xl, TokSpace.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Příjem vozidla',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: tok.textPrimary,
                height: 1.1,
              )),
          const SizedBox(height: 6),
          Text('Naskenujte VIN nebo SPZ, nebo údaje doplňte ručně.',
              style: TextStyle(fontSize: 13, color: tok.textSecondary)),
          const SizedBox(height: TokSpace.lg),
          buildDropdown(
            'Typ záznamu',
            Icons.label_outline,
            typyZaznamu.contains(typZaznamu) ? typZaznamu : typyZaznamu.first,
            typyZaznamu,
            (v) { if (v != null) onTypZaznamuChanged(v); },
            isDark,
          ),
          const SizedBox(height: TokSpace.lg),
          TorkisActionTile(
            icon: Icons.qr_code_scanner_rounded,
            title: 'Skenovat VIN/SPZ',
            subtitle: 'Automaticky rozpozná typ kódu',
            onTap: onScanVinOrSpz,
          ),
          const SizedBox(height: TokSpace.lg),
          buildInput(
            'Číslo zakázky',
            Icons.tag_rounded,
            zakazkaController,
            isDark,
            caps: true,
            customSuffix: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner_rounded,
                      size: 18, color: TokColors.steel),
                  onPressed: () => onScan(zakazkaController, false),
                  tooltip: 'Naskenovat číslo zakázky',
                ),
                if (autoGenerateCislo)
                  isGeneratingCislo
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: TokColors.accent)))
                      : IconButton(
                          icon: const Icon(Icons.refresh_rounded,
                              size: 18, color: TokColors.accent),
                          onPressed: onRegenerateCislo,
                          tooltip: 'Vygenerovat nové číslo',
                        ),
              ],
            ),
          ),
          const SizedBox(height: TokSpace.xl),
          if (nalezenaVozidla.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(TokSpace.lg),
              decoration: BoxDecoration(
                color: tok.surface,
                border: Border(
                  left: const BorderSide(color: TokColors.accent, width: 3),
                  top: BorderSide(color: tok.line),
                  right: BorderSide(color: tok.line),
                  bottom: BorderSide(color: tok.line),
                ),
                borderRadius: BorderRadius.circular(TokRadius.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.directions_car_outlined,
                          color: TokColors.accent, size: 18),
                      const SizedBox(width: 10),
                      Text('Zákazník má uložená tato vozidla',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: tok.textPrimary,
                          )),
                    ],
                  ),
                  const SizedBox(height: TokSpace.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: nalezenaVozidla.map((v) {
                      final spz = v['spz'] ?? '';
                      final znacka = v['znacka']?.toString() ?? '';
                      final model = v['model']?.toString() ?? '';
                      final podtitul =
                          znacka.isNotEmpty ? ' ($znacka $model)' : '';
                      return ActionChip(
                        backgroundColor: TokColors.accentSoft,
                        side: BorderSide.none,
                        label: Text(
                          '$spz$podtitul',
                          style: const TextStyle(
                            color: TokColors.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        onPressed: () => onVozidloSelected(v),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TokSpace.xl),
          ],
          // ── Země + SPZ ───────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 88,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6, left: 2),
                      child: Text('Země',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: tok.textSecondary,
                              letterSpacing: 0.2)),
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : TokColors.paper,
                        borderRadius: BorderRadius.circular(TokRadius.md),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : tok.line,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: zemeRegistrace,
                          isExpanded: true,
                          icon: const SizedBox.shrink(),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          selectedItemBuilder: (_) =>
                              _kVsechnyZeme.keys.map((k) => Center(
                                    child: Text(
                                      '${_kVsechnyZeme[k]!.split(' ').first} $k',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : TokColors.ink,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )).toList(),
                          items: _kVsechnyZeme.entries
                              .map((e) => DropdownMenuItem(
                                    value: e.key,
                                    child: Text(e.value,
                                        style: const TextStyle(fontSize: 14)),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) onZemeChanged(v);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: buildInput(
                  'SPZ vozidla',
                  Icons.confirmation_number_outlined,
                  spzController,
                  isDark,
                  caps: true,
                  customSuffix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner_rounded,
                            size: 18, color: TokColors.steel),
                        onPressed: () => onScan(spzController, false),
                        tooltip: 'Naskenovat SPZ fotoaparátem',
                      ),
                      isLoadingSpz
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: TokColors.accent)))
                          : IconButton(
                              icon: const Icon(Icons.search_rounded,
                                  size: 18, color: TokColors.accent),
                              onPressed: onHledatSpz,
                              tooltip:
                                  'Vyhledat vozidlo a majitele z historie',
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          buildInput(
            'VIN kód',
            Icons.tag_outlined,
            vinController,
            isDark,
            caps: true,
            customSuffix: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner_rounded,
                      size: 18, color: TokColors.steel),
                  onPressed: () => onScan(vinController, false),
                  tooltip: 'Naskenovat VIN fotoaparátem',
                ),
                isLoadingVin
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: TokColors.accent)))
                    : IconButton(
                        icon: const Icon(Icons.search_rounded,
                            size: 18, color: TokColors.accent),
                        onPressed: onHledatVin,
                        tooltip: 'Vyhledat vozidlo a majitele z historie',
                      ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Značka autocomplete
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 2),
                child: Text(
                  'Značka (např. Škoda)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: tok.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Autocomplete<String>(
                key: ValueKey('znacka_$autocompleteResetKey'),
                initialValue: TextEditingValue(text: znackaController.text),
                displayStringForOption: (z) => z,
                optionsBuilder: (TextEditingValue value) {
                  if (value.text.isEmpty) return dostupneZnacky;
                  return dostupneZnacky.where((z) =>
                      z.toLowerCase().contains(value.text.toLowerCase()));
                },
                onSelected: (String val) {
                  znackaController.text = val;
                  onZnackaSelected(val);
                },
                fieldViewBuilder: (ctx, ctrl, focusNode, onSubmit) {
                  return TextField(
                    controller: ctrl,
                    focusNode: focusNode,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : TokColors.ink,
                    ),
                    cursorColor: TokColors.accent,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.directions_car_outlined,
                          color: TokColors.accent, size: 18),
                      suffixIcon: onScanZnacka != null
                          ? IconButton(
                              icon: const Icon(Icons.qr_code_scanner_rounded,
                                  size: 18, color: TokColors.steel),
                              onPressed: onScanZnacka,
                              tooltip: 'Naskenovat značku fotoaparátem')
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : TokColors.paper,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TokRadius.md),
                          borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : context.tok.line)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TokRadius.md),
                          borderSide: const BorderSide(
                              color: TokColors.accent, width: 1.5)),
                    ),
                    onChanged: (val) {
                      znackaController.text = val;
                      if (databazeZnacek.containsKey(val)) {
                        onZnackaSelected(val);
                      }
                    },
                  );
                },
                optionsViewBuilder: (ctx, onSel, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 250),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (ctx, i) {
                              final z = options.elementAt(i);
                              final logo = logovaZnacek[z];
                              return ListTile(
                                leading: logo != null
                                    ? Image.network(logo,
                                        width: 28,
                                        height: 28,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.directions_car,
                                                color: Colors.blue))
                                    : const Icon(Icons.directions_car,
                                        color: Colors.blue),
                                title: Text(z,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                                onTap: () => onSel(z),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Model autocomplete
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 2),
                child: Text(
                  'Model (např. Octavia)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: tok.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Autocomplete<String>(
                key: ValueKey('model_$autocompleteResetKey'),
                initialValue: TextEditingValue(text: modelController.text),
                displayStringForOption: (m) => m,
                optionsBuilder: (TextEditingValue value) {
                  if (dostupneModely.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  if (value.text.isEmpty) return dostupneModely;
                  return dostupneModely.where((m) =>
                      m.toLowerCase().contains(value.text.toLowerCase()));
                },
                onSelected: (String val) {
                  modelController.text = val;
                  onModelSelected(val);
                },
                fieldViewBuilder: (ctx, ctrl, focusNode, onSubmit) {
                  return TextField(
                    controller: ctrl,
                    focusNode: focusNode,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : TokColors.ink,
                    ),
                    cursorColor: TokColors.accent,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                          Icons.directions_car_filled_outlined,
                          color: TokColors.accent,
                          size: 18),
                      suffixIcon: onScanModel != null
                          ? IconButton(
                              icon: const Icon(Icons.qr_code_scanner_rounded,
                                  size: 18, color: TokColors.steel),
                              onPressed: onScanModel,
                              tooltip: 'Naskenovat model fotoaparátem')
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : TokColors.paper,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TokRadius.md),
                          borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : context.tok.line)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(TokRadius.md),
                          borderSide: const BorderSide(
                              color: TokColors.accent, width: 1.5)),
                    ),
                    onChanged: (val) => modelController.text = val,
                  );
                },
                optionsViewBuilder: (ctx, onSel, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (ctx, i) {
                              final m = options.elementAt(i);
                              return ListTile(
                                title: Text(m,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                                onTap: () => onSel(m),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          buildInput(
              'Rok výroby', Icons.calendar_today, rokVyrobyController, isDark,
              numbersOnly: true, onScan: onScan),
          const SizedBox(height: 20),
          buildInput('Motorizace (např. 2.0 TDI)', Icons.settings,
              motorizaceController, isDark,
              onScan: onScan),
          const SizedBox(height: 20),
          buildDropdown('Typ paliva', Icons.local_gas_station, vybranePalivo,
              moznostiPaliva, onPalivoChanged, isDark),
          const SizedBox(height: 20),
          buildDropdown(
              'Převodovka',
              Icons.settings_input_component,
              vybranaPrevodovka,
              moznostiPrevodovky,
              onPrevodovkaChanged,
              isDark),
          const SizedBox(height: 20),
          buildDropdown('Typ karosérie', Icons.directions_car_outlined,
              typKaroserie, moznostiKaroserie, onKaroserieChanged, isDark),
        ],
      ),
    );
  }
}
