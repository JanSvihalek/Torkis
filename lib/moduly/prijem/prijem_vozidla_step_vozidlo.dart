import 'package:flutter/material.dart';
import 'prijem_vozidla_helpers.dart';

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
  final void Function(TextEditingController, bool) onScan;

  // Autocomplete
  final int autocompleteResetKey;
  final List<String> dostupneZnacky;
  final List<String> dostupneModely;
  final Map<String, String> logovaZnacek;
  final Map<String, List<String>> databazeZnacek;
  final void Function(String) onZnackaSelected;

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
    required this.onScan,
    required this.autocompleteResetKey,
    required this.dostupneZnacky,
    required this.dostupneModely,
    required this.logovaZnacek,
    required this.databazeZnacek,
    required this.onZnackaSelected,
    required this.vybranePalivo,
    required this.moznostiPaliva,
    required this.onPalivoChanged,
    required this.vybranaPrevodovka,
    required this.moznostiPrevodovky,
    required this.onPrevodovkaChanged,
    required this.nalezenaVozidla,
    required this.onVozidloSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final Widget cisloInput = buildInput(
                'Číslo zakázky *',
                Icons.onetwothree,
                zakazkaController,
                isDark,
                caps: true,
                customSuffix: !autoGenerateCislo
                    ? null
                    : isGeneratingCislo
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2)))
                        : IconButton(
                            icon: const Icon(Icons.refresh,
                                color: Colors.blue),
                            onPressed: onRegenerateCislo,
                            tooltip: 'Vygenerovat nové číslo'),
              );

              if (constraints.maxWidth < 400) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Příjem vozidla',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    cisloInput,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                      flex: 3,
                      child: Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text('Příjem vozidla',
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold)))),
                  const SizedBox(width: 15),
                  Expanded(flex: 2, child: cisloInput),
                ],
              );
            },
          ),
          const SizedBox(height: 30),
          if (nalezenaVozidla.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.directions_car, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Zákazník má uložená tato vozidla:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue))
                  ]),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: nalezenaVozidla
                        .map((v) => ActionChip(
                            backgroundColor: isDark
                                ? const Color(0xFF2C2C2C)
                                : Colors.white,
                            side: const BorderSide(color: Colors.blue),
                            label: Text(
                                '${v['spz']} ${v['znacka'] != null && v['znacka'].toString().isNotEmpty ? '(${v['znacka']} ${v['model'] ?? ''})' : ''}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            onPressed: () => onVozidloSelected(v)))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
          buildInput(
            'SPZ vozidla (Klikněte na lupu pro dotažení) *',
            Icons.abc,
            spzController,
            isDark,
            caps: true,
            customSuffix: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.document_scanner),
                      onPressed: () => onScan(spzController, false),
                      tooltip: 'Naskenovat SPZ fotoaparátem'),
                  isLoadingSpz
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2)))
                      : IconButton(
                          icon: const Icon(Icons.search,
                              color: Colors.blue),
                          onPressed: onHledatSpz,
                          tooltip:
                              'Vyhledat auto a majitele z historie')
                ]),
          ),
          const SizedBox(height: 20),
          buildInput('VIN kód', Icons.abc, vinController, isDark,
              caps: true, onScan: onScan),
          const SizedBox(height: 20),
          // Značka autocomplete
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Značka (např. Škoda)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 8),
              Autocomplete<String>(
                key: ValueKey('znacka_$autocompleteResetKey'),
                initialValue:
                    TextEditingValue(text: znackaController.text),
                displayStringForOption: (z) => z,
                optionsBuilder: (TextEditingValue value) {
                  if (value.text.isEmpty) return dostupneZnacky;
                  return dostupneZnacky.where((z) => z
                      .toLowerCase()
                      .contains(value.text.toLowerCase()));
                },
                onSelected: (String val) {
                  znackaController.text = val;
                  onZnackaSelected(val);
                },
                fieldViewBuilder: (ctx, ctrl, focusNode, onSubmit) {
                  return Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                      ],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: ctrl,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.directions_car,
                            color: Colors.blue),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                color: isDark
                                    ? Colors.grey[800]!
                                    : Colors.grey[300]!)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                                color: Colors.blue, width: 2)),
                      ),
                      onChanged: (val) {
                        znackaController.text = val;
                        if (databazeZnacek.containsKey(val)) {
                          onZnackaSelected(val);
                        }
                      },
                    ),
                  );
                },
                optionsViewBuilder: (ctx, onSel, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxHeight: 250),
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
                                            const Icon(
                                                Icons.directions_car,
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
              const Text('Model (např. Octavia)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 8),
              Autocomplete<String>(
                key: ValueKey('model_$autocompleteResetKey'),
                initialValue:
                    TextEditingValue(text: modelController.text),
                displayStringForOption: (m) => m,
                optionsBuilder: (TextEditingValue value) {
                  if (dostupneModely.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  if (value.text.isEmpty) return dostupneModely;
                  return dostupneModely.where((m) => m
                      .toLowerCase()
                      .contains(value.text.toLowerCase()));
                },
                onSelected: (String val) {
                  modelController.text = val;
                },
                fieldViewBuilder: (ctx, ctrl, focusNode, onSubmit) {
                  return Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                      ],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: ctrl,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                            Icons.directions_car_filled,
                            color: Colors.blue),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                                color: isDark
                                    ? Colors.grey[800]!
                                    : Colors.grey[300]!)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                                color: Colors.blue, width: 2)),
                      ),
                      onChanged: (val) => modelController.text = val,
                    ),
                  );
                },
                optionsViewBuilder: (ctx, onSel, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxHeight: 200),
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
          buildInput('Rok výroby', Icons.calendar_today,
              rokVyrobyController, isDark,
              numbersOnly: true, onScan: onScan),
          const SizedBox(height: 20),
          buildInput('Motorizace (např. 2.0 TDI)', Icons.settings,
              motorizaceController, isDark,
              onScan: onScan),
          const SizedBox(height: 20),
          buildDropdown('Typ paliva', Icons.local_gas_station,
              vybranePalivo, moznostiPaliva, onPalivoChanged, isDark),
          const SizedBox(height: 20),
          buildDropdown(
              'Převodovka',
              Icons.settings_input_component,
              vybranaPrevodovka,
              moznostiPrevodovky,
              onPrevodovkaChanged,
              isDark),
        ],
      ),
    );
  }
}
