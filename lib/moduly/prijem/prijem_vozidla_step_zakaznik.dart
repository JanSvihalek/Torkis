import 'package:flutter/material.dart';
import 'prijem_vozidla_helpers.dart';

/// Krok 2 – Údaje o zákazníkovi.
/// Pole: jméno/firma, IČO (s ARES vyhledáváním), ulice, město, PSČ, telefon, e-mail.
class StepZakaznik extends StatelessWidget {
  final bool isDark;

  final TextEditingController jmenoController;
  final TextEditingController icoController;
  final TextEditingController uliceController;
  final TextEditingController mestoController;
  final TextEditingController pscController;
  final TextEditingController telefonController;
  final TextEditingController emailController;

  final bool isLoadingAres;
  final VoidCallback onFetchAres;
  final VoidCallback onVyberZakaznika;

  final String telPredvolba;
  final List<Map<String, String>> predvolby;
  final ValueChanged<String> onPredvolbaChanged;

  const StepZakaznik({
    super.key,
    required this.isDark,
    required this.jmenoController,
    required this.icoController,
    required this.uliceController,
    required this.mestoController,
    required this.pscController,
    required this.telefonController,
    required this.emailController,
    required this.isLoadingAres,
    required this.onFetchAres,
    required this.onVyberZakaznika,
    required this.telPredvolba,
    required this.predvolby,
    required this.onPredvolbaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Údaje o zákazníkovi',
              style:
                  TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          buildInput(
            'Jméno a příjmení / Název firmy',
            Icons.person,
            jmenoController,
            isDark,
            customSuffix: IconButton(
                icon: const Icon(Icons.person_search,
                    color: Colors.blue),
                onPressed: onVyberZakaznika,
                tooltip: 'Hledat uloženého zákazníka'),
          ),
          const SizedBox(height: 20),
          // IČO s ARES vyhledáváním — vlastní layout (loading indikátor v suffixu)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('IČO (ARES vyhledávání)',
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
                  controller: icoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.business,
                          color: Colors.blue),
                      suffixIcon: isLoadingAres
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
                              onPressed: onFetchAres,
                              tooltip: 'Hledat v ARES'),
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
          const SizedBox(height: 20),
          buildInput('Ulice a číslo', Icons.location_on,
              uliceController, isDark),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                flex: 2,
                child: buildInput('Město', Icons.location_city,
                    mestoController, isDark)),
            const SizedBox(width: 15),
            Expanded(
                flex: 1,
                child: buildInput('PSČ', Icons.markunread_mailbox,
                    pscController, isDark,
                    numbersOnly: true)),
          ]),
          const SizedBox(height: 20),
          PhoneFieldWidget(
            isDark: isDark,
            telPredvolba: telPredvolba,
            telefonController: telefonController,
            predvolby: predvolby,
            onPredvolbaChanged: onPredvolbaChanged,
          ),
          const SizedBox(height: 20),
          buildInput(
              'E-mail', Icons.email, emailController, isDark),
        ],
      ),
    );
  }
}
