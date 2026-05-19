import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../core/constants.dart';
import '../core/design_tokens.dart';
import '../core/torkis_ui.dart';
import 'auth_gate.dart'; // Kvůli globalServisId
import 'predplatne_page.dart';

class ZamestnanciPage extends StatefulWidget {
  const ZamestnanciPage({super.key});

  @override
  State<ZamestnanciPage> createState() => _ZamestnanciPageState();
}

class _ZamestnanciPageState extends State<ZamestnanciPage> {
  String _prelozModul(String modul) {
    switch (modul) {
      case 'zamestnanci':
        return 'Zaměstnanci';
      case 'nastaveni':
        return 'Nastavení';
      default:
        return modul;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;

    return Scaffold(
      backgroundColor: tok.bg,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('uzivatele')
              .where('servis_id', isEqualTo: globalServisId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Chyba: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            final pocet = docs.length;
            final limit = kPlanUserLimit[globalPlanTyp];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TorkisPageTitle(
                  title: 'Tým a oprávnění',
                  subtitle:
                      'Spravujte členy svého servisu a jejich přístup do aplikace.',
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      TokSpace.xl, TokSpace.sm, TokSpace.xl, TokSpace.md),
                  child: _UserQuotaCard(
                    pocet: pocet,
                    limit: limit,
                    plan: globalPlanTyp,
                  ),
                ),
                Expanded(
                  child: docs.isEmpty
                      ? Center(
                          child: Text('Zatím nemáte žádné členy týmu.',
                              style: TextStyle(color: tok.textSecondary)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                              TokSpace.xl, 0, TokSpace.xl, 100),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final docId = docs[index].id;
                            return _UserCard(
                              data: data,
                              docId: docId,
                              prelozModul: _prelozModul,
                              onEdit: (id, jmeno, prava) =>
                                  _showEditPravaDialog(context, id, jmeno, prava),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('uzivatele')
            .where('servis_id', isEqualTo: globalServisId)
            .snapshots(),
        builder: (context, snapshot) {
          final pocet = snapshot.data?.docs.length ?? 0;
          final limit = kPlanUserLimit[globalPlanTyp];
          final dosazenLimit = limit != null && pocet >= limit;
          return FloatingActionButton.extended(
            onPressed: () {
              if (dosazenLimit) {
                _showLimitReachedDialog(context, pocet, limit);
              } else {
                _showAddZamestnanecDialog(context);
              }
            },
            label: const Text('Přidat člena týmu',
                style: TextStyle(fontWeight: FontWeight.w600)),
            icon: Icon(
                dosazenLimit ? Icons.lock_outline : Icons.person_add_rounded),
            backgroundColor:
                dosazenLimit ? TokColors.steel : TokColors.ink,
            foregroundColor: Colors.white,
          );
        },
      ),
    );
  }

  void _showLimitReachedDialog(BuildContext context, int pocet, int limit) {
    final tok = context.tok;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tok.surface,
        title: const Text('Dosažen limit účtů'),
        content: Text(
            'Plán ${globalPlanTyp.toUpperCase()} umožňuje maximálně $limit uživatelských účtů. Aktuálně využíváte $pocet/$limit. Pro přidání dalších členů týmu upgradujte plán.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Zrušit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PredplatnePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TokColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Upgradovat plán'),
          ),
        ],
      ),
    );
  }

  // --- DIALOG PRO PŘIDÁNÍ NOVÉHO ZAMĚSTNANCE (VČETNĚ FIREBASE AUTH) ---
  void _showAddZamestnanecDialog(BuildContext context) {
    final jmenoCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final hesloCtrl = TextEditingController();

    Map<String, bool> novaPrava = {
      'zamestnanci': false,
      'nastaveni': false,
    };

    bool isSaving = false;
    bool hesloSkryte = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final tok = context.tok;

          return Container(
            height: MediaQuery.of(context).size.height * 0.90,
            decoration: BoxDecoration(
              color: tok.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(
                TokSpace.xl, TokSpace.md, TokSpace.xl, TokSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tok.line,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: TokSpace.lg),
                Text('Nový člen týmu',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: tok.textPrimary,
                    )),
                const SizedBox(height: TokSpace.lg),
                TextField(
                  controller: jmenoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Jméno a příjmení *',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Přihlašovací e-mail *',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: hesloCtrl,
                  obscureText: hesloSkryte,
                  decoration: InputDecoration(
                    labelText: 'Přihlašovací heslo (min. 6 znaků) *',
                    suffixIcon: IconButton(
                      icon: Icon(hesloSkryte
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () =>
                          setModalState(() => hesloSkryte = !hesloSkryte),
                    ),
                  ),
                ),
                const SizedBox(height: TokSpace.lg),
                Text('Výchozí přístupová práva',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tok.textSecondary,
                        letterSpacing: 0.4)),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildPravoSwitch(setModalState, 'Správa zaměstnanců',
                            'zamestnanci', novaPrava, Icons.people_alt_outlined),
                        _buildPravoSwitch(setModalState,
                            'Nastavení servisu (IČO, atd.)', 'nastaveni',
                            novaPrava, Icons.settings_outlined),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: TokSpace.sm),
                TorkisPrimaryButton(
                  label: 'Vytvořit účet',
                  loading: isSaving,
                  trailingIcon: null,
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (jmenoCtrl.text.trim().isEmpty ||
                              emailCtrl.text.trim().isEmpty ||
                              hesloCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Vyplňte prosím jméno, e-mail i heslo.'),
                                backgroundColor: TokColors.danger,
                              ),
                            );
                            return;
                          }
                          if (hesloCtrl.text.trim().length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Heslo musí mít alespoň 6 znaků.'),
                                backgroundColor: TokColors.warning,
                              ),
                            );
                            return;
                          }

                          // Re-check limitu těsně před zápisem (sekundární obrana).
                          final aktualniSnap = await FirebaseFirestore.instance
                              .collection('uzivatele')
                              .where('servis_id', isEqualTo: globalServisId)
                              .get();
                          final aktualniPocet = aktualniSnap.docs.length;
                          final limit = kPlanUserLimit[globalPlanTyp];
                          if (limit != null && aktualniPocet >= limit) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              _showLimitReachedDialog(
                                  context, aktualniPocet, limit);
                            }
                            return;
                          }

                          setModalState(() => isSaving = true);

                          try {
                            FirebaseApp tempApp =
                                await Firebase.initializeApp(
                              name: 'tempAuth',
                              options: Firebase.app().options,
                            );
                            UserCredential userCredential =
                                await FirebaseAuth.instanceFor(app: tempApp)
                                    .createUserWithEmailAndPassword(
                              email: emailCtrl.text.trim(),
                              password: hesloCtrl.text.trim(),
                            );
                            String novyUid = userCredential.user!.uid;
                            await tempApp.delete();

                            await FirebaseFirestore.instance
                                .collection('uzivatele')
                                .doc(novyUid)
                                .set({
                              'uid': novyUid,
                              'jmeno': jmenoCtrl.text.trim(),
                              'email': emailCtrl.text.trim(),
                              'servis_id': globalServisId,
                              'role': 'zamestnanec',
                              'prava': novaPrava,
                              'vytvoreno': FieldValue.serverTimestamp(),
                            });

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Účet vytvořen.'),
                                  backgroundColor: TokColors.success,
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            setModalState(() => isSaving = false);
                            String errMsg = 'Chyba ověření.';
                            if (e.code == 'weak-password') {
                              errMsg = 'Zadané heslo je příliš slabé.';
                            } else if (e.code == 'email-already-in-use') {
                              errMsg =
                                  'Účet s tímto e-mailem již existuje.';
                            } else if (e.code == 'invalid-email') {
                              errMsg = 'Neplatný formát e-mailu.';
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(errMsg),
                                    backgroundColor: TokColors.danger),
                              );
                            }
                          } catch (e) {
                            setModalState(() => isSaving = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Neočekávaná chyba: $e'),
                                    backgroundColor: TokColors.danger),
                              );
                            }
                          }
                        },
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditPravaDialog(BuildContext context, String docId, String jmeno,
      Map<String, dynamic> aktualniPrava) {
    Map<String, bool> lokalniPrava = {
      'zamestnanci': aktualniPrava['zamestnanci'] ?? false,
      'nastaveni': aktualniPrava['nastaveni'] ?? false,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final tok = context.tok;
          return Container(
            decoration: BoxDecoration(
              color: tok.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(
                TokSpace.xl, TokSpace.md, TokSpace.xl, TokSpace.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tok.line,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: TokSpace.lg),
                Text('Přístupová práva',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: tok.textSecondary,
                        letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text(jmeno,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: tok.textPrimary,
                    )),
                const SizedBox(height: TokSpace.lg),
                _buildPravoSwitch(setModalState, 'Správa zaměstnanců',
                    'zamestnanci', lokalniPrava, Icons.people_alt_outlined),
                _buildPravoSwitch(
                    setModalState,
                    'Nastavení servisu (IČO, atd.)',
                    'nastaveni',
                    lokalniPrava,
                    Icons.settings_outlined),
                const SizedBox(height: TokSpace.lg),
                TorkisPrimaryButton(
                  label: 'Uložit oprávnění',
                  trailingIcon: null,
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('uzivatele')
                        .doc(docId)
                        .update({'prava': lokalniPrava});
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPravoSwitch(StateSetter setState, String label, String key,
      Map<String, bool> prava, IconData icon) {
    final tok = context.tok;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: tok.bg,
          borderRadius: BorderRadius.circular(TokRadius.md),
          border: Border.all(color: tok.line),
        ),
        child: SwitchListTile(
          title: Text(label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: tok.textPrimary,
              )),
          secondary: Icon(icon,
              color:
                  prava[key]! ? TokColors.accent : tok.textSecondary),
          value: prava[key]!,
          activeThumbColor: TokColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TokRadius.md),
          ),
          onChanged: (bool value) {
            setState(() => prava[key] = value);
          },
        ),
      ),
    );
  }
}

class _UserQuotaCard extends StatelessWidget {
  final int pocet;
  final int? limit;
  final String plan;

  const _UserQuotaCard({
    required this.pocet,
    required this.limit,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    final unlimited = limit == null;
    final dosazen = !unlimited && pocet >= limit!;
    final progress = unlimited ? 0.0 : (pocet / limit!).clamp(0.0, 1.0);

    final accent = dosazen ? TokColors.warning : TokColors.accent;

    return Container(
      padding: const EdgeInsets.all(TokSpace.lg),
      decoration: BoxDecoration(
        color: tok.surface,
        border: Border.all(color: tok.line),
        borderRadius: BorderRadius.circular(TokRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(TokRadius.sm),
                ),
                child: Icon(Icons.group_outlined,
                    color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      unlimited
                          ? '$pocet uživatelů'
                          : '$pocet / $limit uživatelů',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: tok.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      unlimited
                          ? 'Plán ${plan.toUpperCase()} · bez limitu'
                          : dosazen
                              ? 'Plán ${plan.toUpperCase()} · limit dosažen'
                              : 'Plán ${plan.toUpperCase()} · zbývá ${limit! - pocet}',
                      style: TextStyle(
                          fontSize: 12, color: tok.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!unlimited) ...[
            const SizedBox(height: TokSpace.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(TokRadius.round),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: tok.line,
                valueColor: AlwaysStoppedAnimation(accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final String Function(String) prelozModul;
  final void Function(String, String, Map<String, dynamic>) onEdit;

  const _UserCard({
    required this.data,
    required this.docId,
    required this.prelozModul,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final tok = context.tok;
    final String jmeno = data['jmeno'] ?? 'Bez jména';
    final String email = data['email'] ?? '-';
    final String role = data['role'] ?? 'zamestnanec';
    final bool jeAdmin = role == 'admin';

    final Map<String, dynamic> prava = data['prava'] ?? {
      'zamestnanci': false,
      'nastaveni': false,
    };

    List<String> aktivniModuly = [];
    prava.forEach((key, value) {
      if (value == true) aktivniModuly.add(prelozModul(key));
    });

    final podnadpis = aktivniModuly.isEmpty
        ? 'Bez rozšířených práv'
        : aktivniModuly.join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(TokSpace.md),
      decoration: BoxDecoration(
        color: tok.surface,
        borderRadius: BorderRadius.circular(TokRadius.xl),
        border: Border.all(color: tok.line),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (jeAdmin ? TokColors.accent : TokColors.steel)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(TokRadius.round),
            ),
            child: Icon(
              jeAdmin
                  ? Icons.admin_panel_settings_outlined
                  : Icons.person_outline_rounded,
              color: jeAdmin ? TokColors.accent : TokColors.steel,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        jmeno,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: tok.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: jeAdmin
                            ? TokColors.accentSoft
                            : tok.bg,
                        borderRadius:
                            BorderRadius.circular(TokRadius.round),
                      ),
                      child: Text(
                        jeAdmin ? 'ADMIN' : 'ČLEN',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: jeAdmin
                              ? TokColors.accent
                              : tok.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(email,
                    style: TextStyle(
                        fontSize: 12, color: tok.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(podnadpis,
                    style: TextStyle(
                      fontSize: 11,
                      color: tok.textMuted,
                      fontStyle: aktivniModuly.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    )),
              ],
            ),
          ),
          if (jeAdmin)
            Icon(Icons.lock_outline_rounded,
                color: tok.textMuted, size: 18)
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: TokColors.accent),
              onPressed: () => onEdit(docId, jmeno, prava),
            ),
        ],
      ),
    );
  }
}
