import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../l10n/app_localizations.dart';

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
  final bool podpisPovolen;

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
    this.podpisPovolen = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final validniPozadavky =
        pozadavkyControllers.where((c) => c.text.trim().isNotEmpty).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.prijemPodpisTitle,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              // Souhrn
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E3A5F) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                    border:
                        Border.all(color: Colors.blue.withValues(alpha: 0.3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        l10n.prijemPodpisZakaznik(
                            jmeno.isEmpty ? l10n.prijemPodpisNeuvedeno : jmeno),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 5),
                    Text(
                        l10n.prijemPodpisAdresa(
                            '${ulice.isNotEmpty ? "$ulice, " : ""}$psc $mesto'),
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Text(l10n.prijemPodpisVozidlo('${spz.toUpperCase()} $znacka'),
                        style: const TextStyle(fontSize: 16)),
                    if (validniPozadavky.isNotEmpty) ...[
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Divider()),
                      Text(l10n.prijemPodpisSjednaneUkony,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 16)),
                      const SizedBox(height: 10),
                      ...validniPozadavky.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue)),
                                Expanded(
                                    child: Text(c.text,
                                        style: const TextStyle(fontSize: 15)))
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
                        ? const Color(0xFF1E3A5F)
                        : Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(15),
                    border:
                        Border.all(color: Colors.blue.withValues(alpha: 0.3))),
                child: CheckboxListTile(
                  title: Text(l10n.prijemPodpisEmailToggle,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      email.isEmpty
                          ? l10n.prijemPodpisEmailChybi
                          : l10n.prijemPodpisEmailKam(email),
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
              if (podpisPovolen) ...[
                Text(l10n.prijemPodpisSouhlas,
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
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
                        label: Text(l10n.prijemPodpisSmazat,
                            style: const TextStyle(color: Colors.red)))),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.2))),
                  child: Row(
                    children: [
                      const Icon(Icons.draw_outlined, color: Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.prijemPodpisVypnut,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
