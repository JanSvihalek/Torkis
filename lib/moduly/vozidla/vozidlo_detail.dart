import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vozidlo_tab_info.dart';
import 'vozidlo_tab_prijem.dart';
import '../../core/design_tokens.dart';
import '../../l10n/app_localizations.dart';

class VozidloDetailScreen extends StatelessWidget {
  final String vozidloDocId;

  const VozidloDetailScreen({super.key, required this.vozidloDocId});

  void _otevritEditaci(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    final spzCtrl = TextEditingController(text: data['spz']?.toString() ?? '');
    final znackaCtrl =
        TextEditingController(text: data['znacka']?.toString() ?? '');
    final modelCtrl =
        TextEditingController(text: data['model']?.toString() ?? '');
    final vinCtrl = TextEditingController(text: data['vin']?.toString() ?? '');
    final rokCtrl =
        TextEditingController(text: data['rok_vyroby']?.toString() ?? '');
    final motorCtrl =
        TextEditingController(text: data['motorizace']?.toString() ?? '');
    final tachoCtrl =
        TextEditingController(text: data['tachometr']?.toString() ?? '');
    final stkMCtrl =
        TextEditingController(text: data['stk_mesic']?.toString() ?? '');
    final stkRCtrl =
        TextEditingController(text: data['stk_rok']?.toString() ?? '');

    String vybranaZnacka = znackaCtrl.text;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    // Future se vytváří jednou před otevřením sheetu — není uvnitř builderu,
    // takže setModalState ho neobnoví a nezpůsobí blikání.
    final brandsFuture =
        FirebaseFirestore.instance.collection('znacka').get();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return FutureBuilder<QuerySnapshot>(
          future: brandsFuture,
          builder: (sheetCtx, snapshot) {
            Map<String, List<String>> databazeZnacek = {};
            if (snapshot.hasData) {
              for (var doc in snapshot.data!.docs) {
                final docData = doc.data() as Map<String, dynamic>;
                final nazev = docData['nazev']?.toString() ?? doc.id;
                final modely = List<String>.from(docData['model'] ?? []);
                databazeZnacek[nazev] = modely;
              }
            }
            final dostupneZnacky = databazeZnacek.keys.toList()..sort();

            return StatefulBuilder(
              builder: (sheetCtx, setModalState) {
                final dostupneModely =
                    (vybranaZnacka.isNotEmpty &&
                            databazeZnacek.containsKey(vybranaZnacka))
                        ? (List<String>.from(
                            databazeZnacek[vybranaZnacka]!)
                          ..sort())
                        : <String>[];

                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? TokColors.darkSurface : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(25)),
                  ),
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom:
                        MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(l10n.vozidloDetailUprava,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        TextField(
                          controller: spzCtrl,
                          decoration: InputDecoration(
                              labelText: l10n.vozidloDetailSpz,
                              border: const OutlineInputBorder()),
                          textCapitalization:
                              TextCapitalization.characters,
                        ),
                        const SizedBox(height: 15),
                        LayoutBuilder(
                          builder: (ctx, constraints) =>
                              DropdownMenu<String>(
                            width: constraints.maxWidth,
                            controller: znackaCtrl,
                            enableFilter: true,
                            enableSearch: true,
                            label: Text(l10n.vozidloDetailZnacka),
                            inputDecorationTheme:
                                const InputDecorationTheme(
                                    border: OutlineInputBorder()),
                            dropdownMenuEntries: dostupneZnacky
                                .map((z) =>
                                    DropdownMenuEntry(value: z, label: z))
                                .toList(),
                            onSelected: (val) => setModalState(() {
                              vybranaZnacka = val ?? znackaCtrl.text;
                              modelCtrl.clear();
                            }),
                          ),
                        ),
                        const SizedBox(height: 15),
                        LayoutBuilder(
                          builder: (ctx, constraints) =>
                              DropdownMenu<String>(
                            width: constraints.maxWidth,
                            controller: modelCtrl,
                            enableFilter: true,
                            enableSearch: true,
                            label: Text(l10n.vozidloDetailModel),
                            inputDecorationTheme:
                                const InputDecorationTheme(
                                    border: OutlineInputBorder()),
                            dropdownMenuEntries: dostupneModely
                                .map((m) =>
                                    DropdownMenuEntry(value: m, label: m))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: vinCtrl,
                          decoration: InputDecoration(
                              labelText: l10n.vozidloVin,
                              border: const OutlineInputBorder()),
                          textCapitalization:
                              TextCapitalization.characters,
                        ),
                        const SizedBox(height: 15),
                        Row(children: [
                          Expanded(
                            child: TextField(
                              controller: rokCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText: l10n.vozidloRokVyroby,
                                  border: const OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: TextField(
                              controller: motorCtrl,
                              decoration: InputDecoration(
                                  labelText: l10n.vozidloMotorizace,
                                  border: const OutlineInputBorder()),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 15),
                        TextField(
                          controller: tachoCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: l10n.vozidloDetailTachoKm,
                              border: const OutlineInputBorder()),
                        ),
                        const SizedBox(height: 15),
                        Text(l10n.vozidloDetailPlatnostStk,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 5),
                        Row(children: [
                          Expanded(
                            child: TextField(
                              controller: stkMCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText: l10n.vozidloDetailStkMesic,
                                  border: const OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: TextField(
                              controller: stkRCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText: l10n.vozidloDetailStkRok,
                                  border: const OutlineInputBorder()),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TokColors.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              final user =
                                  FirebaseAuth.instance.currentUser;
                              if (user == null) return;

                              final oldSpz =
                                  data['spz'].toString().toUpperCase();
                              final newSpz =
                                  spzCtrl.text.trim().toUpperCase();

                              final updatedData = {
                                'spz': newSpz,
                                'znacka': znackaCtrl.text.trim(),
                                'model': modelCtrl.text.trim(),
                                'vin': vinCtrl.text.trim().toUpperCase(),
                                'rok_vyroby': rokCtrl.text.trim(),
                                'motorizace': motorCtrl.text.trim(),
                                'tachometr': tachoCtrl.text.trim(),
                                'stk_mesic': stkMCtrl.text.trim(),
                                'stk_rok': stkRCtrl.text.trim(),
                              };

                              if (oldSpz != newSpz) {
                                showDialog(
                                  context: sheetCtx,
                                  barrierDismissible: false,
                                  builder: (c) => const Center(
                                      child: CircularProgressIndicator()),
                                );
                                try {
                                  final newDocId =
                                      '${user.uid}_$newSpz';
                                  final check = await FirebaseFirestore
                                      .instance
                                      .collection('vozidla')
                                      .doc(newDocId)
                                      .get();
                                  if (check.exists) {
                                    if (sheetCtx.mounted) {
                                      Navigator.pop(sheetCtx);
                                      ScaffoldMessenger.of(sheetCtx)
                                          .showSnackBar(SnackBar(
                                        content: Text(l10n.vozidloDetailSpzExistuje),
                                        backgroundColor: Colors.red,
                                      ));
                                    }
                                    return;
                                  }
                                  await FirebaseFirestore.instance
                                      .collection('vozidla')
                                      .doc(newDocId)
                                      .set({...data, ...updatedData});
                                  await FirebaseFirestore.instance
                                      .collection('vozidla')
                                      .doc(docId)
                                      .delete();
                                  if (sheetCtx.mounted) {
                                    Navigator.pop(sheetCtx);
                                    Navigator.pop(sheetCtx);
                                    Navigator.pop(sheetCtx);
                                    ScaffoldMessenger.of(sheetCtx)
                                        .showSnackBar(SnackBar(
                                      content: Text(l10n.vozidloDetailPrejmenovano(newSpz)),
                                      backgroundColor: Colors.green,
                                    ));
                                  }
                                } catch (e) {
                                  if (sheetCtx.mounted) {
                                    Navigator.pop(sheetCtx);
                                    ScaffoldMessenger.of(sheetCtx)
                                        .showSnackBar(SnackBar(
                                            content: Text(
                                                'Chyba při migraci: $e')));
                                  }
                                }
                              } else {
                                await FirebaseFirestore.instance
                                    .collection('vozidla')
                                    .doc(docId)
                                    .update(updatedData);
                                if (sheetCtx.mounted) {
                                  Navigator.pop(sheetCtx);
                                }
                              }
                            },
                            child: Text(l10n.vozidloDetailUlozitZmeny,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
          body: Center(child: Text(AppLocalizations.of(context).vozidlaNejstePrihlaseni)));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('vozidla')
          .doc(vozidloDocId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text("Chyba: ${snapshot.error}")),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final autoData =
            snapshot.data!.data() as Map<String, dynamic>?;
        if (autoData == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(AppLocalizations.of(context).vozidloDetailNenalezeno)),
          );
        }

        final tok = context.tok;
        final l10n = AppLocalizations.of(context);
        final spz = autoData['spz']?.toString() ?? '';
        final zakaznikId = autoData['zakaznik_id']?.toString() ?? '';
        final znackaNazev = (autoData['znacka']?.toString() ?? '').trim();
        final palivo = autoData['palivo']?.toString() ?? '';
        final prevodovka = autoData['prevodovka']?.toString() ?? '';
        final tacho = autoData['tachometr']?.toString() ?? '';
        final stkM = autoData['stk_mesic']?.toString() ?? '';
        final stkR = autoData['stk_rok']?.toString() ?? '';

        final vehicleTitle =
            '${autoData['znacka'] ?? ''} ${autoData['model'] ?? ''}'.trim();
        final titleText = spz.isNotEmpty
            ? spz
            : (vehicleTitle.isNotEmpty ? vehicleTitle : l10n.vozidloDetailBezSpz);

        final views = <Widget>[
          VozidloInfoTab(
            isDark: isDark,
            user: user,
            autoData: autoData,
            spz: spz,
            zakaznikId: zakaznikId,
            znackaNazev: znackaNazev,
            tacho: tacho,
            palivo: palivo,
            prevodovka: prevodovka,
            stkM: stkM,
            stkR: stkR,
          ),
          VozidloPrijemTab(isDark: isDark, user: user, spz: spz),
        ];

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: tok.bg,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, tok, l10n, titleText, autoData),
                  Expanded(child: TabBarView(children: views)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Hlavička karty vozidla ─────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, TorkisTokens tok,
      AppLocalizations l10n, String title, Map<String, dynamic> autoData) {
    return Container(
      decoration: BoxDecoration(
        color: tok.surface,
        border: Border(bottom: BorderSide(color: tok.line)),
      ),
      padding:
          const EdgeInsets.fromLTRB(TokSpace.lg, TokSpace.md, TokSpace.lg, 0),
      child: Column(
        children: [
          Row(
            children: [
              _roundIconButton(tok, Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context)),
              const SizedBox(width: TokSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.vozidloDetailLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: TokColors.accent,
                        )),
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: tok.textPrimary,
                          height: 1.1,
                        )),
                  ],
                ),
              ),
              _roundIconButton(tok, Icons.edit_outlined,
                  onTap: () =>
                      _otevritEditaci(context, vozidloDocId, autoData)),
              const SizedBox(width: TokSpace.sm),
              _buildMenuButton(context, tok),
            ],
          ),
          const SizedBox(height: TokSpace.sm),
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: TokColors.accent,
            unselectedLabelColor: tok.textSecondary,
            indicatorColor: TokColors.accent,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            unselectedLabelStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: l10n.vozidloTabInfo),
              Tab(text: l10n.vozidloTabZaznamy),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roundIconButton(TorkisTokens tok, IconData icon,
      {required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TokRadius.md),
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TokRadius.md),
            border: Border.all(color: tok.line),
          ),
          child: Icon(icon, size: 18, color: tok.textPrimary),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, TorkisTokens tok) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TokRadius.md),
        border: Border.all(color: tok.line),
      ),
      child: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, size: 18, color: tok.textPrimary),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TokRadius.md)),
        onSelected: (v) {
          if (v == 'smazat') _smazatVozidlo(context);
        },
        itemBuilder: (ctx) => [
          PopupMenuItem(
            value: 'smazat',
            child: Row(children: [
              const Icon(Icons.delete_outline_rounded,
                  size: 18, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text(AppLocalizations.of(ctx).vozidloSmazatAkce,
                  style: const TextStyle(color: Colors.redAccent)),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _smazatVozidlo(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.vozidloSmazatDialogTitle),
        content: Text(l10n.vozidloSmazatDialogText),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text(l10n.btnZrusit)),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.vozidloSmazatBtn,
                style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await FirebaseFirestore.instance
          .collection('vozidla')
          .doc(vozidloDocId)
          .delete();
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.vozidloSmazano),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Chyba při mazání: $e'),
            backgroundColor: Colors.red));
      }
    }
  }
}
