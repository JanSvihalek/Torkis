import 'package:flutter/material.dart';
import 'prijem_vozidla_helpers.dart';

/// Krok 3 – Stav vozidla při příjmu.
/// Pole: tachometr, stav nádrže (slider), zjištěná poškození (FilterChip),
/// platnost STK, hloubka dezénu pneu (LP/PP/LZ/PZ), dodatečné poznámky.
class StepCheck extends StatelessWidget {
  final bool isDark;

  final TextEditingController tachometrController;
  final double stavNadrze;
  final ValueChanged<double> onStavNadrzeChanged;

  final List<String> vybranePoskozeni;
  final List<String> poskozeniMoznosti;
  final void Function(String value, bool selected) onPoskozeniChanged;
  final TextEditingController vlastniPoskozeniController;
  final VoidCallback onPridatVlastniPoskozeni;

  final TextEditingController stkMesicController;
  final TextEditingController stkRokController;

  final TextEditingController pneuLPController;
  final TextEditingController pneuPPController;
  final TextEditingController pneuLZController;
  final TextEditingController pneuPZController;

  final TextEditingController poskozeniController;

  const StepCheck({
    super.key,
    required this.isDark,
    required this.tachometrController,
    required this.stavNadrze,
    required this.onStavNadrzeChanged,
    required this.vybranePoskozeni,
    required this.poskozeniMoznosti,
    required this.onPoskozeniChanged,
    required this.vlastniPoskozeniController,
    required this.onPridatVlastniPoskozeni,
    required this.stkMesicController,
    required this.stkRokController,
    required this.pneuLPController,
    required this.pneuPPController,
    required this.pneuLZController,
    required this.pneuPZController,
    required this.poskozeniController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Stav vozidla',
              style:
                  TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          buildInput('Stav tachometru (km)', Icons.speed,
              tachometrController, isDark,
              numbersOnly: true),
          const SizedBox(height: 25),
          // Stav nádrže
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Stav paliva v nádrži (${stavNadrze.toInt()} %)',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E3A5F)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                            color:
                                Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                    ],
                    border: Border.all(
                        color: isDark
                            ? Colors.grey[800]!
                            : Colors.grey[300]!,
                        width: 1)),
                child: Row(
                  children: [
                    Icon(Icons.local_gas_station,
                        color: stavNadrze < 20
                            ? Colors.red
                            : Colors.blue),
                    Expanded(
                        child: Slider(
                            value: stavNadrze,
                            min: 0,
                            max: 100,
                            divisions: 4,
                            label: '${stavNadrze.toInt()} %',
                            activeColor: Colors.blue,
                            onChanged: onStavNadrzeChanged)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Divider(),
          const SizedBox(height: 20),
          // Zjištěná poškození
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Zjištěná poškození (lze vybrat více)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E3A5F)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                            color:
                                Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                    ],
                    border: Border.all(
                        color: isDark
                            ? Colors.grey[800]!
                            : Colors.grey[300]!,
                        width: 1)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                            padding: EdgeInsets.only(top: 4, right: 15),
                            child: Icon(Icons.car_crash, color: Colors.blue)),
                        Expanded(
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: poskozeniMoznosti.map((value) {
                              final isSelected =
                                  vybranePoskozeni.contains(value);
                              return FilterChip(
                                label: Text(value),
                                selected: isSelected,
                                onSelected: (bool selected) =>
                                    onPoskozeniChanged(value, selected),
                                selectedColor:
                                    Colors.blue.withValues(alpha: 0.2),
                                checkmarkColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                        color: isSelected
                                            ? Colors.blue
                                            : (isDark
                                                ? Colors.grey[800]!
                                                : Colors.grey[300]!))),
                                backgroundColor: isDark
                                    ? const Color(0xFF1E3A5F)
                                    : Colors.grey[50],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: vlastniPoskozeniController,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Vlastní popis poškození...',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.grey[100],
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: isDark
                                          ? Colors.grey[700]!
                                          : Colors.grey[300]!)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 2)),
                            ),
                            onSubmitted: (_) => onPridatVlastniPoskozeni(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: onPridatVlastniPoskozeni,
                          icon: const Icon(Icons.add_circle, color: Colors.blue),
                          tooltip: 'Přidat vlastní poškození',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          // Platnost STK
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Platnost STK',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: buildHalfInput('Měsíc',
                        Icons.calendar_month, stkMesicController,
                        isDark, TextInputType.number)),
                const SizedBox(width: 15),
                Expanded(
                    child: buildHalfInput('Rok',
                        Icons.edit_calendar, stkRokController,
                        isDark, TextInputType.number)),
              ]),
            ],
          ),
          const SizedBox(height: 25),
          // Hloubka dezénu pneu
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hloubka dezénu pneu (v mm)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: buildHalfInput(
                        'Levá př.',
                        Icons.tire_repair,
                        pneuLPController,
                        isDark,
                        const TextInputType.numberWithOptions(
                            decimal: true))),
                const SizedBox(width: 15),
                Expanded(
                    child: buildHalfInput(
                        'Pravá př.',
                        Icons.tire_repair,
                        pneuPPController,
                        isDark,
                        const TextInputType.numberWithOptions(
                            decimal: true))),
              ]),
              const SizedBox(height: 15),
              Row(children: [
                Expanded(
                    child: buildHalfInput(
                        'Levá zad.',
                        Icons.tire_repair,
                        pneuLZController,
                        isDark,
                        const TextInputType.numberWithOptions(
                            decimal: true))),
                const SizedBox(width: 15),
                Expanded(
                    child: buildHalfInput(
                        'Pravá zad.',
                        Icons.tire_repair,
                        pneuPZController,
                        isDark,
                        const TextInputType.numberWithOptions(
                            decimal: true))),
              ]),
            ],
          ),
          const SizedBox(height: 30),
          // Dodatečné poznámky
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dodatečné poznámky k vozu',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                            color:
                                Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                    ],
                    borderRadius: BorderRadius.circular(15)),
                child: TextField(
                  controller: poskozeniController,
                  maxLines: 4,
                  decoration: InputDecoration(
                      hintText: 'Jakékoliv další detaily k příjmu...',
                      prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(Icons.notes,
                              color: Colors.blue)),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[300]!,
                              width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: Colors.blue, width: 2)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[300]!,
                              width: 1))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
