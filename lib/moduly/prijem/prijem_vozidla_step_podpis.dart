import 'package:flutter/material.dart';
import '../../core/biometric_signature_pad.dart';
import '../../core/design_tokens.dart';
import '../../core/signature_capture_screen.dart';
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
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _tok.textPrimary)),
              const SizedBox(height: 30),
              // ── Rekapitulace příjmu ─────────────────────────────────
              _sekce(
                icon: Icons.assignment_outlined,
                title: l10n.prijemRekapZaznam,
                children: [
                  _infoRow(l10n.prijemVozidloCisloZaznamu, cisloZakazky),
                  _infoRow(l10n.prijemVozidloTypZaznamu, typZaznamu),
                ],
              ),
              _sekce(
                icon: Icons.directions_car,
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
                  title: l10n.prijemPodpisSjednaneUkony,
                  children: validniPozadavky
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.chevron_right,
                                    size: 18, color: _tok.accent),
                                const SizedBox(width: 6),
                                Expanded(
                                    child: Text(c.text,
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: _tok.textPrimary))),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              if (poznamky.trim().isNotEmpty)
                _sekce(
                  icon: Icons.notes,
                  title: l10n.histSekcePoznamky,
                  children: [
                    Text(poznamky.trim(),
                        style: TextStyle(
                            fontSize: 14, color: _tok.textPrimary)),
                  ],
                ),
              const SizedBox(height: 15),
              // Checkbox – odeslat e-mail
              Container(
                decoration: BoxDecoration(
                    color: _tok.accentSoft,
                    borderRadius: BorderRadius.circular(TokRadius.xl),
                    border: Border.all(color: _tok.line)),
                child: CheckboxListTile(
                  title: Text(l10n.prijemPodpisEmailToggle,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _tok.textPrimary)),
                  subtitle: Text(
                      email.isEmpty
                          ? l10n.prijemPodpisEmailChybi
                          : l10n.prijemPodpisEmailKam(email),
                      style: TextStyle(
                          color: email.isEmpty
                              ? TokColors.danger
                              : _tok.textSecondary,
                          fontSize: 13)),
                  value: odeslatEmail,
                  activeColor: _tok.accent,
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
                AnimatedBuilder(
                  animation: signatureController,
                  builder: (context, _) => signatureController.isEmpty
                      ? _buildPodepsatButton(context, l10n)
                      : _buildPodpisNahled(context, l10n),
                ),
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

  // ── Podpis ────────────────────────────────────────────────────────────

  Future<void> _otevritPodpis(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await SignatureCaptureScreen.open(context, signatureController, isDark);
  }

  /// Prázdný stav – velké tlačítko otevírající celoobrazovkové podepisování.
  Widget _buildPodepsatButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _otevritPodpis(context),
        icon: const Icon(Icons.draw_outlined),
        label: Text(l10n.prijemPodpisOtevrit),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue,
          side: const BorderSide(color: Colors.blue, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 22),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Stav s podpisem – náhled (klepnutím lze upravit) + akce smazat / znovu.
  Widget _buildPodpisNahled(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.prijemPodpisNahled,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _otevritPodpis(context),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(15),
                color: Colors.white),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: SignaturePreview(controller: signatureController),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            TextButton.icon(
                onPressed: () => signatureController.clear(),
                icon: const Icon(Icons.clear, color: Colors.red),
                label: Text(l10n.prijemPodpisSmazat,
                    style: const TextStyle(color: Colors.red))),
            const Spacer(),
            TextButton.icon(
                onPressed: () => _otevritPodpis(context),
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.prijemPodpisZnovu)),
          ],
        ),
      ],
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

  TorkisTokens get _tok =>
      TorkisTokens(isDark ? Brightness.dark : Brightness.light);

  Widget _infoRow(String label, String? value) {
    final val = value?.trim() ?? '';
    if (val.isEmpty) return const SizedBox.shrink();
    final tok = _tok;
    return Padding(
      padding: const EdgeInsets.only(bottom: TokSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(color: tok.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(val,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: tok.textPrimary)),
          ),
        ],
      ),
    );
  }

  /// Sekce souhrnu — jednotný design (accent ikona, neutrální plocha a linka).
  Widget _sekce({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final hasContent = children.any((w) => w is! SizedBox);
    if (!hasContent) return const SizedBox.shrink();
    final tok = _tok;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: TokSpace.md),
      padding: const EdgeInsets.all(TokSpace.lg),
      decoration: BoxDecoration(
        color: tok.surface,
        borderRadius: BorderRadius.circular(TokRadius.xl),
        border: Border.all(color: tok.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: tok.accentSoft,
                  borderRadius: BorderRadius.circular(TokRadius.sm),
                ),
                child: Icon(icon, color: tok.accent, size: 18),
              ),
              const SizedBox(width: TokSpace.sm),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: tok.textPrimary)),
              ),
            ],
          ),
          Divider(height: 24, color: tok.line),
          ...children,
        ],
      ),
    );
  }
}
