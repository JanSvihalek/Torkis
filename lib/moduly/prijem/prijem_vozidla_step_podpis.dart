import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

/// Krok 6 – Shrnutí a podpis zákazníka.
/// Zobrazuje souhrn zákazníka, vozidla a sjednaných úkonů.
/// Zákazník podepíše prstem na SignatureController plátno.
class StepPodpis extends StatelessWidget {
  final bool isDark;

  final String jmeno;
  final String ulice;
  final String psc;
  final String mesto;
  final String spz;
  final String znacka;
  final String email;

  final List<TextEditingController> pozadavkyControllers;

  final bool odeslatEmail;
  final ValueChanged<bool?> onOdeslatEmailChanged;

  final SignatureController signatureController;

  const StepPodpis({
    super.key,
    required this.isDark,
    required this.jmeno,
    required this.ulice,
    required this.psc,
    required this.mesto,
    required this.spz,
    required this.znacka,
    required this.email,
    required this.pozadavkyControllers,
    required this.odeslatEmail,
    required this.onOdeslatEmailChanged,
    required this.signatureController,
  });

  @override
  Widget build(BuildContext context) {
    final validniPozadavky = pozadavkyControllers
        .where((c) => c.text.trim().isNotEmpty)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Shrnutí a podpis',
              style:
                  TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          // Souhrn
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E1E)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Zákazník: ${jmeno.isEmpty ? 'Neuvedeno' : jmeno}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text(
                    'Adresa: ${ulice.isNotEmpty ? "$ulice, " : ""}$psc $mesto',
                    style: const TextStyle(
                        fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 10),
                Text(
                    'Vozidlo: ${spz.toUpperCase()} $znacka',
                    style: const TextStyle(fontSize: 16)),
                if (validniPozadavky.isNotEmpty) ...[
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Divider()),
                  const Text('Sjednané úkony:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 16)),
                  const SizedBox(height: 10),
                  ...validniPozadavky.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue)),
                            Expanded(
                                child: Text(c.text,
                                    style: const TextStyle(
                                        fontSize: 15)))
                          ]))),
                ],
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Checkbox – odeslat e-mail
          Container(
            decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1E1E)
                    : Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3))),
            child: CheckboxListTile(
              title: const Text('Odeslat kopii protokolu na e-mail',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  email.isEmpty
                      ? 'U zákazníka (krok 2) není vyplněn žádný e-mail.'
                      : 'Bude odesláno na: $email',
                  style: TextStyle(
                      color: email.isEmpty ? Colors.red : Colors.grey,
                      fontSize: 13)),
              value: odeslatEmail,
              activeColor: Colors.blue,
              checkColor: Colors.white,
              onChanged: onOdeslatEmailChanged,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
              'Zákazník svým podpisem stvrzuje správnost výše uvedených údajů a souhlasí se stavem vozidla při převzetí do servisu.',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 20),
          // Podpisové plátno
          Container(
            decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(15),
                color: Colors.white),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Signature(
                    controller: signatureController,
                    height: 250,
                    backgroundColor: Colors.white)),
          ),
          const SizedBox(height: 10),
          Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                  onPressed: () => signatureController.clear(),
                  icon: const Icon(Icons.clear, color: Colors.red),
                  label: const Text('Smazat podpis',
                      style: TextStyle(color: Colors.red)))),
        ],
      ),
    );
  }
}
