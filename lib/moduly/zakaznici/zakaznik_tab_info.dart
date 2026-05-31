import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../vozidla/vozidlo_detail.dart';
import '../prijem/prijem_vozidla.dart';
import '../../core/design_tokens.dart';

class ZakaznikInfoTab extends StatelessWidget {
  final bool isDark;
  final Map<String, dynamic> dataZakaznika;
  final dynamic zakaznikId;
  final dynamic servisId;

  const ZakaznikInfoTab({
    super.key,
    required this.isDark,
    required this.dataZakaznika,
    required this.zakaznikId,
    required this.servisId,
  });

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;

    final jmeno = dataZakaznika['jmeno']?.toString().trim() ?? '';
    final ico = dataZakaznika['ico']?.toString() ?? '';
    final dic = dataZakaznika['dic']?.toString() ?? '';
    final telefon = dataZakaznika['telefon']?.toString() ?? '';
    final email = dataZakaznika['email']?.toString() ?? '';
    final adresa = dataZakaznika['adresa']?.toString() ?? '';
    final jeFirma = ico.isNotEmpty;

    final contactRows = <Widget>[
      if (ico.isNotEmpty)
        _contactRow(tok, Icons.account_balance_wallet_outlined, 'IČO', ico),
      if (dic.isNotEmpty)
        _contactRow(tok, Icons.account_balance_wallet_outlined, 'DIČ', dic),
      if (telefon.isNotEmpty)
        _contactRow(
          tok,
          Icons.phone_outlined,
          'TELEFON',
          telefon,
          action: _CallButton(telefon: telefon),
        ),
      if (email.isNotEmpty)
        _contactRow(tok, Icons.email_outlined, 'E-MAIL', email),
      if (adresa.isNotEmpty)
        _contactRow(tok, Icons.location_on_outlined, 'ADRESA', adresa),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(TokSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Identita zákazníka ──────────────────────────────────
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tok.accent,
                  borderRadius: BorderRadius.circular(TokRadius.lg),
                ),
                child: Text(
                  _initials(jmeno),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: TokSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jmeno.isEmpty ? 'Neznámý zákazník' : jmeno,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: tok.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      jeFirma ? 'Firma' : 'Soukromá osoba',
                      style: TextStyle(
                        fontSize: 13,
                        color: tok.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: TokSpace.xl),

          // ── Kontaktní karta ─────────────────────────────────────
          if (contactRows.isNotEmpty)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: tok.surface,
                borderRadius: BorderRadius.circular(TokRadius.xl),
                border: Border.all(color: tok.line),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: TokSpace.lg, vertical: TokSpace.xs),
              child: Column(
                children: [
                  for (int i = 0; i < contactRows.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: tok.line),
                    contactRows[i],
                  ],
                ],
              ),
            ),

          const SizedBox(height: TokSpace.xxl),

          // ── Vozidla zákazníka ───────────────────────────────────
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('vozidla')
                .where('servis_id', isEqualTo: servisId)
                .where('zakaznik_id', isEqualTo: zakaznikId)
                .snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'VOZIDLA ZÁKAZNÍKA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: tok.textSecondary,
                        ),
                      ),
                      if (docs.isNotEmpty) ...[
                        const SizedBox(width: TokSpace.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: tok.accentSoft,
                            borderRadius:
                                BorderRadius.circular(TokRadius.round),
                          ),
                          child: Text(
                            '${docs.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tok.accent,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainWizardPage(),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: tok.accent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: TokSpace.sm),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Přidat'),
                      ),
                    ],
                  ),
                  const SizedBox(height: TokSpace.md),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(TokSpace.lg),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (docs.isEmpty)
                    Text(
                      'Zákazník nemá v systému uložena žádná vozidla.',
                      style: TextStyle(color: tok.textSecondary),
                    )
                  else
                    ...docs.map((doc) => _vozidloCard(context, tok, doc)),
                ],
              );
            },
          ),
          const SizedBox(height: TokSpace.xl),
        ],
      ),
    );
  }

  // Iniciály z jména / názvu firmy (max 2 znaky).
  String _initials(String jmeno) {
    final slova = jmeno
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (slova.isEmpty) return '?';
    if (slova.length == 1) return slova.first.characters.first.toUpperCase();
    return (slova.first.characters.first + slova[1].characters.first)
        .toUpperCase();
  }

  // ── Řádek kontaktu s ikonovou dlaždicí ────────────────────────
  Widget _contactRow(
    TorkisTokens tok,
    IconData icon,
    String label,
    String value, {
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TokSpace.md),
      child: Row(
        children: [
          _iconTile(tok, icon),
          const SizedBox(width: TokSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: tok.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: tok.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: TokSpace.sm),
            action,
          ],
        ],
      ),
    );
  }

  Widget _iconTile(TorkisTokens tok, IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: tok.accentSoft,
        borderRadius: BorderRadius.circular(TokRadius.md),
      ),
      child: Icon(icon, size: 20, color: tok.accent),
    );
  }

  // ── Karta vozidla ─────────────────────────────────────────────
  Widget _vozidloCard(
      BuildContext context, TorkisTokens tok, QueryDocumentSnapshot doc) {
    final vozidlo = doc.data() as Map<String, dynamic>;
    final znacka = vozidlo['znacka']?.toString() ?? '';
    final model = vozidlo['model']?.toString() ?? '';
    final motorizace = vozidlo['motorizace']?.toString() ?? '';
    final rok = vozidlo['rok_vyroby']?.toString() ?? '';

    final popis = [
      '$znacka $model'.trim(),
      if (motorizace.isNotEmpty) motorizace,
    ].where((s) => s.isNotEmpty).join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: TokSpace.md),
      child: Container(
        decoration: BoxDecoration(
          color: tok.surface,
          borderRadius: BorderRadius.circular(TokRadius.xl),
          border: Border.all(color: tok.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(TokRadius.xl),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VozidloDetailScreen(vozidloDocId: doc.id),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(TokSpace.md),
            child: Row(
              children: [
                _iconTile(tok, Icons.directions_car_outlined),
                const SizedBox(width: TokSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vozidlo['spz'] ?? ''}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: tok.textPrimary,
                        ),
                      ),
                      if (popis.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          popis,
                          style: TextStyle(
                            fontSize: 13,
                            color: tok.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (rok.isNotEmpty)
                  Text(
                    rok,
                    style: TextStyle(color: tok.textSecondary, fontSize: 13),
                  ),
                const SizedBox(width: TokSpace.sm),
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: tok.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tmavé kruhové tlačítko pro vytočení telefonního čísla.
class _CallButton extends StatelessWidget {
  final String telefon;
  const _CallButton({required this.telefon});

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    return Material(
      color: tok.inkSurface,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            launchUrl(Uri.parse('tel:${telefon.replaceAll(' ', '')}')),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.phone, size: 18, color: tok.onInk),
        ),
      ),
    );
  }
}
