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
class StepVozidlo extends StatefulWidget {
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

  // Vincario VIN dekodér
  final bool isLoadingVincario;
  final VoidCallback? onDekovatVin;

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
    this.isLoadingVincario = false,
    this.onDekovatVin,
  });

  @override
  State<StepVozidlo> createState() => _StepVozidloState();
}

class _StepVozidloState extends State<StepVozidlo> {
  // null = automatické dle šířky obrazovky (tablet → mřížka, mobil → pod sebou)
  bool? _useGrid;

  /// Akční dlaždice ve stylu „Skenovat VIN/SPZ" — pro hledání v databázi a
  /// dekódování VIN. Podporuje stav načítání (spinner místo ikony) a deaktivaci.
  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool loading,
    required VoidCallback? onTap,
  }) {
    final tok = context.tok;
    final disabled = loading || onTap == null;
    return Material(
      color: tok.surface,
      borderRadius: BorderRadius.circular(TokRadius.lg),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(TokRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TokRadius.lg),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : tok.line,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TokColors.accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(TokRadius.sm),
                ),
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: TokColors.accent))
                    : Icon(icon, color: TokColors.accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: tok.textPrimary,
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: tok.textSecondary,
                        )),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: tok.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpzSection(BuildContext context) {
    final tok = context.tok;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      color: widget.isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : TokColors.paper,
                      borderRadius: BorderRadius.circular(TokRadius.md),
                      border: Border.all(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : tok.line,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: widget.zemeRegistrace,
                        isExpanded: true,
                        icon: const SizedBox.shrink(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        selectedItemBuilder: (_) => _kVsechnyZeme.keys
                            .map((k) => Center(
                                  child: Text(
                                    '${_kVsechnyZeme[k]!.split(' ').first} $k',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: widget.isDark
                                          ? Colors.white
                                          : TokColors.ink,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ))
                            .toList(),
                        items: _kVsechnyZeme.entries
                            .map((e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text(e.value,
                                      style: const TextStyle(fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) widget.onZemeChanged(v);
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
                widget.spzController,
                widget.isDark,
                caps: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          context,
          icon: Icons.search_rounded,
          title: 'Hledat v databázi',
          subtitle: 'Najít dříve uložené vozidlo podle SPZ',
          loading: widget.isLoadingSpz,
          onTap: widget.onHledatSpz,
        ),
      ],
    );
  }

  Widget _buildVinSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildInput(
          'VIN kód',
          Icons.tag_outlined,
          widget.vinController,
          widget.isDark,
          caps: true,
        ),
        const SizedBox(height: 10),
        _buildActionTile(
          context,
          icon: Icons.search_rounded,
          title: 'Hledat v databázi',
          subtitle: 'Najít dříve uložené vozidlo podle VIN',
          loading: widget.isLoadingVin,
          onTap: widget.onHledatVin,
        ),
        if (widget.onDekovatVin != null) ...[
          const SizedBox(height: 8),
          _buildActionTile(
            context,
            icon: Icons.cloud_download_rounded,
            title: 'Dekódovat VIN online',
            subtitle: 'Doplnit značku, model a motorizaci',
            loading: widget.isLoadingVincario,
            onTap: widget.onDekovatVin,
          ),
        ],
      ],
    );
  }

  Widget _buildZnackaSection(BuildContext context) {
    final tok = context.tok;
    return Column(
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
          key: ValueKey('znacka_${widget.autocompleteResetKey}'),
          initialValue: TextEditingValue(text: widget.znackaController.text),
          displayStringForOption: (z) => z,
          optionsBuilder: (TextEditingValue value) {
            if (value.text.isEmpty) return widget.dostupneZnacky;
            return widget.dostupneZnacky.where((z) =>
                z.toLowerCase().contains(value.text.toLowerCase()));
          },
          onSelected: (String val) {
            widget.znackaController.text = val;
            widget.onZnackaSelected(val);
          },
          fieldViewBuilder: (ctx, ctrl, focusNode, onSubmit) {
            return TextField(
              controller: ctrl,
              focusNode: focusNode,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: widget.isDark ? Colors.white : TokColors.ink,
              ),
              cursorColor: TokColors.accent,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.directions_car_outlined,
                    color: TokColors.accent, size: 18),
                suffixIcon: null,
                filled: true,
                fillColor: widget.isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : TokColors.paper,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TokRadius.md),
                    borderSide: BorderSide(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : context.tok.line)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TokRadius.md),
                    borderSide: const BorderSide(
                        color: TokColors.accent, width: 1.5)),
              ),
              onChanged: (val) {
                widget.znackaController.text = val;
                if (widget.databazeZnacek.containsKey(val)) {
                  widget.onZnackaSelected(val);
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
                        final logo = widget.logovaZnacek[z];
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
    );
  }

  Widget _buildModelSection(BuildContext context) {
    final tok = context.tok;
    return Column(
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
          key: ValueKey('model_${widget.autocompleteResetKey}'),
          initialValue: TextEditingValue(text: widget.modelController.text),
          displayStringForOption: (m) => m,
          optionsBuilder: (TextEditingValue value) {
            if (widget.dostupneModely.isEmpty) {
              return const Iterable<String>.empty();
            }
            if (value.text.isEmpty) return widget.dostupneModely;
            return widget.dostupneModely.where((m) =>
                m.toLowerCase().contains(value.text.toLowerCase()));
          },
          onSelected: (String val) {
            widget.modelController.text = val;
            widget.onModelSelected(val);
          },
          fieldViewBuilder: (ctx, ctrl, focusNode, onSubmit) {
            return TextField(
              controller: ctrl,
              focusNode: focusNode,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: widget.isDark ? Colors.white : TokColors.ink,
              ),
              cursorColor: TokColors.accent,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                    Icons.directions_car_filled_outlined,
                    color: TokColors.accent,
                    size: 18),
                suffixIcon: null,
                filled: true,
                fillColor: widget.isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : TokColors.paper,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TokRadius.md),
                    borderSide: BorderSide(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : context.tok.line)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TokRadius.md),
                    borderSide: const BorderSide(
                        color: TokColors.accent, width: 1.5)),
              ),
              onChanged: (val) => widget.modelController.text = val,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 720;
        final useGrid = isTablet && (_useGrid ?? true);
        final maxWidth = isTablet ? 960.0 : 600.0;

        Widget rowPair(Widget left, Widget right) {
          if (useGrid) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: left),
                const SizedBox(width: TokSpace.lg),
                Expanded(child: right),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              left,
              const SizedBox(height: 20),
              right,
            ],
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              TokSpace.xl, TokSpace.lg, TokSpace.xl, TokSpace.xxxl),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Záznam vozidla',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                  color: tok.textPrimary,
                                  height: 1.1,
                                )),
                            const SizedBox(height: 6),
                            Text(
                                'Naskenujte VIN nebo SPZ, nebo údaje doplňte ručně.',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: tok.textSecondary)),
                          ],
                        ),
                      ),
                      if (isTablet) ...[
                        const SizedBox(width: TokSpace.lg),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(
                              value: false,
                              icon: Icon(Icons.view_agenda_outlined, size: 16),
                              label: Text('Pod sebou'),
                            ),
                            ButtonSegment(
                              value: true,
                              icon: Icon(Icons.grid_view_outlined, size: 16),
                              label: Text('V mřížce'),
                            ),
                          ],
                          selected: {_useGrid ?? true},
                          onSelectionChanged: (Set<bool> v) =>
                              setState(() => _useGrid = v.first),
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: TokSpace.lg),
                  TorkisActionTile(
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'Skenovat VIN/SPZ',
                    subtitle: 'Automaticky rozpozná typ kódu',
                    onTap: widget.onScanVinOrSpz,
                  ),
                  const SizedBox(height: TokSpace.lg),
                  rowPair(
                    buildDropdown(
                      'Typ záznamu',
                      Icons.label_outline,
                      widget.typyZaznamu.contains(widget.typZaznamu)
                          ? widget.typZaznamu
                          : widget.typyZaznamu.first,
                      widget.typyZaznamu,
                      (v) {
                        if (v != null) widget.onTypZaznamuChanged(v);
                      },
                      widget.isDark,
                    ),
                    buildInput(
                      'Číslo záznamu',
                      Icons.tag_rounded,
                      widget.zakazkaController,
                      widget.isDark,
                      caps: true,
                      customSuffix: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.autoGenerateCislo)
                            widget.isGeneratingCislo
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: TokColors.accent)))
                                : IconButton(
                                    icon: const Icon(Icons.refresh_rounded,
                                        size: 18, color: TokColors.accent),
                                    onPressed: widget.onRegenerateCislo,
                                    tooltip: 'Vygenerovat nové číslo',
                                  ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: TokSpace.xl),
                  if (widget.nalezenaVozidla.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(TokSpace.lg),
                      decoration: BoxDecoration(
                        color: tok.surface,
                        border: Border(
                          left: const BorderSide(
                              color: TokColors.accent, width: 3),
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
                            children: widget.nalezenaVozidla.map((v) {
                              final spz = v['spz'] ?? '';
                              final znacka = v['znacka']?.toString() ?? '';
                              final model = v['model']?.toString() ?? '';
                              final podtitul = znacka.isNotEmpty
                                  ? ' ($znacka $model)'
                                  : '';
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
                                onPressed: () =>
                                    widget.onVozidloSelected(v),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: TokSpace.xl),
                  ],
                  rowPair(
                    _buildSpzSection(context),
                    _buildVinSection(context),
                  ),
                  const SizedBox(height: 20),
                  rowPair(
                    _buildZnackaSection(context),
                    _buildModelSection(context),
                  ),
                  const SizedBox(height: 20),
                  rowPair(
                    buildInput('Rok výroby', Icons.calendar_today,
                        widget.rokVyrobyController, widget.isDark,
                        numbersOnly: true, onScan: widget.onScan),
                    buildInput(
                        'Motorizace (např. 2.0 TDI)',
                        Icons.settings,
                        widget.motorizaceController,
                        widget.isDark,
                        onScan: widget.onScan),
                  ),
                  const SizedBox(height: 20),
                  rowPair(
                    buildDropdown(
                        'Typ paliva',
                        Icons.local_gas_station,
                        widget.vybranePalivo,
                        widget.moznostiPaliva,
                        widget.onPalivoChanged,
                        widget.isDark),
                    buildDropdown(
                        'Převodovka',
                        Icons.settings_input_component,
                        widget.vybranaPrevodovka,
                        widget.moznostiPrevodovky,
                        widget.onPrevodovkaChanged,
                        widget.isDark),
                  ),
                  const SizedBox(height: 20),
                  buildDropdown(
                      'Typ karosérie',
                      Icons.directions_car_outlined,
                      widget.typKaroserie,
                      widget.moznostiKaroserie,
                      widget.onKaroserieChanged,
                      widget.isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
