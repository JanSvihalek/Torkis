import 'package:flutter/material.dart';
import '../../core/biometric_signature_pad.dart';
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

  // Rozšířená rekapitulace příjmu
  final String model;
  final String vin;
  final String rokVyroby;
  final String palivo;
  final String prevodovka;
  final String motorizace;
  final String telefon;
  final String ico;
  final String cisloZakazky;
  final String typZaznamu;
  final String tachometr;
  final double stavNadrze;
  final String stkMesic;
  final String stkRok;
  final List<String> poskozeni;
  final String pneuLP;
  final String pneuPP;
  final String pneuLZ;
  final String pneuPZ;
  final String poznamky;

  final List<TextEditingController> pozadavkyControllers;

  final bool odeslatEmail;
  final ValueChanged<bool?> onOdeslatEmailChanged;

  final BiometricSignatureController signatureController;
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
    this.model = '',
    this.vin = '',
    this.rokVyroby = '',
    this.palivo = '',
    this.prevodovka = '',
    this.motorizace = '',
    this.telefon = '',
    this.ico = '',
    this.cisloZakazky = '',
    this.typZaznamu = '',
    this.tachometr = '',
    this.stavNadrze = 0,
    this.stkMesic = '',
    this.stkRok = '',
    this.poskozeni = const [],
    this.pneuLP = '',
    this.pneuPP = '',
    this.pneuLZ = '',
    this.pneuPZ = '',
    this.poznamky = '',
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
              // ── Rekapitulace příjmu ─────────────────────────────────
              _sekce(
                icon: Icons.assignment_outlined,
                color: Colors.indigo,
                title: l10n.prijemRekapZaznam,
                children: [
                  _infoRow(l10n.prijemVozidloCisloZaznamu, cisloZakazky),
                  _infoRow(l10n.prijemVozidloTypZaznamu, typZaznamu),
                ],
              ),
              _sekce(
                icon: Icons.directions_car,
                color: Colors.blue,
                title: l10n.histSekceVozidlo,
                children: [
                  _infoRow(l10n.histPoleSPZ, spz.toUpperCase()),
                  _infoRow(l10n.histPoleZnackaModel, '$znacka $model'.trim()),
                  _infoRow(l10n.histPoleVin, vin),
                  _infoRow(l10n.histPoleRokVyroby, rokVyroby),
                  _infoRow(l10n.histPolePalivo, palivo),
                  _infoRow(l10n.histPolePrevodovka, prevodovka),
                  _infoRow(l10n.histPoleMotorizace, motorizace),
                ],
              ),
              _sekce(
                icon: Icons.fact_check_outlined,
                color: Colors.orange,
                title: l10n.histSekceStav,
                children: [
                  _infoRow(l10n.histPoleTachometr,
                      tachometr.trim().isEmpty ? null : '$tachometr km'),
                  _infoRow(
                      l10n.histPoleNadrz, '${stavNadrze.toStringAsFixed(0)} %'),
                  _infoRow(l10n.histPoleStk, _stkText()),
                  _infoRow(l10n.histPolePoskozeni, _poskozeniText()),
                  _infoRow(l10n.histPolePneuLP, _pneuText(pneuLP, pneuPP)),
                  _infoRow(l10n.histPolePneuLZ, _pneuText(pneuLZ, pneuPZ)),
                ],
              ),
              _sekce(
                icon: Icons.person,
                color: Colors.teal,
                title: l10n.histSekceZakaznik,
                children: [
                  _infoRow(l10n.histPoleJmeno, jmeno),
                  _infoRow(l10n.histPoleTelefon, telefon),
                  _infoRow(l10n.histPoleEmail, email),
                  _infoRow(l10n.histPoleAdresa, _adresaText()),
                  _infoRow(l10n.histPoleIco, ico),
                ],
              ),
              if (validniPozadavky.isNotEmpty)
                _sekce(
                  icon: Icons.build_circle_outlined,
                  color: Colors.deepOrange,
                  title: l10n.prijemPodpisSjednaneUkony,
                  children: validniPozadavky
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.chevron_right,
                                    size: 18, color: Colors.deepOrange),
                                const SizedBox(width: 6),
                                Expanded(
                                    child: Text(c.text,
                                        style: const TextStyle(fontSize: 15))),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              if (poznamky.trim().isNotEmpty)
                _sekce(
                  icon: Icons.notes,
                  color: Colors.blueGrey,
                  title: l10n.histSekcePoznamky,
                  children: [
                    Text(poznamky.trim(),
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
              const SizedBox(height: 15),
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
                      child: BiometricSignaturePad(
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

  // ── Pomocné prvky rekapitulace ────────────────────────────────────────

  String? _stkText() {
    if (stkMesic.trim().isEmpty && stkRok.trim().isEmpty) return null;
    final m = stkMesic.trim().isEmpty ? '-' : stkMesic.trim();
    final r = stkRok.trim().isEmpty ? '-' : stkRok.trim();
    return '$m / $r';
  }

  String? _poskozeniText() {
    final list = poskozeni
        .where((p) => p.trim().isNotEmpty && p.trim() != 'Neuvedeno')
        .toList();
    return list.isEmpty ? null : list.join(', ');
  }

  String? _pneuText(String a, String b) {
    if (a.trim().isEmpty && b.trim().isEmpty) return null;
    final x = a.trim().isEmpty ? '-' : a.trim();
    final y = b.trim().isEmpty ? '-' : b.trim();
    return '$x / $y';
  }

  String? _adresaText() {
    final radek = '${ulice.isNotEmpty ? "$ulice, " : ""}$psc $mesto'.trim();
    return radek.isEmpty ? null : radek;
  }

  Widget _infoRow(String label, String? value) {
    final val = value?.trim() ?? '';
    if (val.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(val,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _sekce({
    required IconData icon,
    required Color color,
    required String title,
    required List<Widget> children,
  }) {
    final hasContent = children.any((w) => w is! SizedBox);
    if (!hasContent) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A5F) : Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: color)),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }
}
