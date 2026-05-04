import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import 'auth_screen.dart';
import 'onboarding.dart';
import 'main_screen.dart';

// --- GLOBÁLNÍ PROMĚNNÉ PRO CELOU APLIKACI ---
String? globalServisId;
String? globalUserRole;
String? globalUserJmeno;

// Sdružená data pro přihlášení (uživatel + předplatné)
class _AuthData {
  final DocumentSnapshot userDoc;
  final DocumentSnapshot? predDoc;
  _AuthData({required this.userDoc, this.predDoc});
}

Future<_AuthData> _loadAuthData(String uid) async {
  final userDoc = await FirebaseFirestore.instance
      .collection('uzivatele')
      .doc(uid)
      .get();

  if (!userDoc.exists) return _AuthData(userDoc: userDoc);

  final servisId =
      (userDoc.data() as Map<String, dynamic>)['servis_id']?.toString();
  if (servisId == null) return _AuthData(userDoc: userDoc);

  final predDoc = await FirebaseFirestore.instance
      .collection('predplatne')
      .doc(servisId)
      .get();

  return _AuthData(userDoc: userDoc, predDoc: predDoc);
}

void _applySubscription(DocumentSnapshot? predDoc) {
  if (predDoc == null || !predDoc.exists) {
    // Žádný dokument → Basic plan bez vypršení
    globalPlanTyp = 'basic';
    globalPredplatnePlatnost = null;
    globalModuly = {for (final m in kPlanModuly['basic']!) m: true};
    return;
  }

  final data = predDoc.data() as Map<String, dynamic>;
  globalPlanTyp = data['plan_typ']?.toString() ?? 'basic';

  final platnostTs = data['platnost_do'] as Timestamp?;
  globalPredplatnePlatnost = platnostTs?.toDate();

  final modulyPovolene =
      Map<String, dynamic>.from(data['moduly_povolene'] ?? {});

  if (globalPlanTyp == 'custom') {
    globalModuly = modulyPovolene
        .map((k, v) => MapEntry(k, v == true));
  } else {
    // Výchozí moduly podle plánu + případné přepisy
    final defaults =
        kPlanModuly[globalPlanTyp] ?? kPlanModuly['basic']!;
    globalModuly = {for (final m in defaults) m: true};
    for (final entry in modulyPovolene.entries) {
      globalModuly[entry.key] = entry.value == true;
    }
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const AuthScreen();
        }

        final user = authSnapshot.data!;

        return FutureBuilder<_AuthData>(
          future: _loadAuthData(user.uid),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }

            if (snap.hasError) {
              return Scaffold(
                  body: Center(
                      child: Text(
                          'Chyba načítání profilu: ${snap.error}')));
            }

            final userDoc = snap.data!.userDoc;

            if (userDoc.exists) {
              final userData =
                  userDoc.data() as Map<String, dynamic>;

              globalServisId = userData['servis_id'];
              globalUserRole = userData['role'];
              globalUserJmeno = userData['jmeno']?.toString();

              final tmavyRezim =
                  userData['tmavy_rezim'] as bool? ?? false;
              themeNotifier.value =
                  tmavyRezim ? ThemeMode.dark : ThemeMode.light;

              final rawNavOrder = userData['nav_order'];
              if (rawNavOrder is List && rawNavOrder.isNotEmpty) {
                final navOrder = List<String>.from(rawNavOrder);
                navOrderNotifier.value = navOrder;
                SharedPreferences.getInstance().then(
                  (p) => p.setStringList('nav_order', navOrder),
                );
              }
              SharedPreferences.getInstance().then(
                (p) => p.setBool('tmavy_rezim', tmavyRezim),
              );
              // Načtení a aplikace předplatného
              _applySubscription(snap.data!.predDoc);

              return const MainScreen();
            }
            return const SetupWizardScreen();
          },
        );
      },
    );
  }
}
