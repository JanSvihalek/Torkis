import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/biometric_gate.dart';
import '../core/constants.dart';
import '../core/subscription_service.dart';
import 'auth_screen.dart';
import 'main_screen.dart';
import 'onboarding.dart';
import 'paywall_screen.dart';

// --- GLOBÁLNÍ PROMĚNNÉ PRO CELOU APLIKACI ---
String? globalServisId;
String? globalUserRole;
String? globalUserJmeno;

// Sdružená data pro přihlášení (uživatel + předplatné)
class _AuthData {
  final DocumentSnapshot userDoc;
  final DocumentSnapshot? predDoc;
  final bool subscriptionActive;
  final int zbyvajiciDniTrialu;
  final String? rcPlanTyp; // aktivní plán z RevenueCat (null = trial nebo neaktivní)
  _AuthData({
    required this.userDoc,
    this.predDoc,
    this.subscriptionActive = false,
    this.zbyvajiciDniTrialu = 0,
    this.rcPlanTyp,
  });
}

Future<_AuthData> _loadAuthData(String uid) async {
  final userDoc = await FirebaseFirestore.instance
      .collection('uzivatele')
      .doc(uid)
      .get();

  if (!userDoc.exists) {
    final predDoc = await FirebaseFirestore.instance
        .collection('predplatne')
        .doc(uid)
        .get();
    applySubscription(predDoc);
    return _AuthData(userDoc: userDoc, predDoc: predDoc);
  }

  final servisId =
      (userDoc.data() as Map<String, dynamic>)['servis_id']?.toString();
  if (servisId == null) return _AuthData(userDoc: userDoc, subscriptionActive: true);

  final predDoc = await FirebaseFirestore.instance
      .collection('predplatne')
      .doc(servisId)
      .get();

  // Dokud není RevenueCat nakonfigurován, propustíme všechny uživatele
  if (kRevenueCatApiKey == 'PLACEHOLDER_REVENUECAT_API_KEY') {
    return _AuthData(userDoc: userDoc, predDoc: predDoc, subscriptionActive: true);
  }

  // Identifikace uživatele v RevenueCat
  await SubscriptionService.identifyUser(uid);

  // 1. Kontrola RevenueCat entitlementu — vrátí aktivní plán nebo null
  final rcPlanTyp = await SubscriptionService.getActivePlanTyp();
  bool subscriptionActive = rcPlanTyp != null;
  int zbyvajiciDni = 0;

  // 2. Pokud není aktivní předplatné, zkontrolujeme 30denní trial
  if (!subscriptionActive && predDoc.exists) {
    final data = predDoc.data() as Map<String, dynamic>;
    final trialStart = (data['trial_zacatek'] as Timestamp?)?.toDate();
    if (trialStart != null) {
      final trialEnd = trialStart.add(const Duration(days: 30));
      final now = DateTime.now();
      if (now.isBefore(trialEnd)) {
        subscriptionActive = true;
        zbyvajiciDni = trialEnd.difference(now).inDays + 1;
      }
    }
  }

  // 3. Ručně přidělený plán z Firestore (predplatne je zamčené pravidly —
  //    zapíše jen vlastník v konzoli nebo RevenueCat webhook, tedy důvěryhodné).
  //    Platí, když plán není trial a platnost_do je prázdná nebo v budoucnu.
  if (!subscriptionActive && predDoc.exists) {
    final data = predDoc.data() as Map<String, dynamic>;
    final planTyp = data['plan_typ']?.toString();
    final platnostDo = (data['platnost_do'] as Timestamp?)?.toDate();
    final platnyPlan =
        planTyp != null && planTyp.isNotEmpty && planTyp != 'trial';
    final neexpirovano =
        platnostDo == null || platnostDo.isAfter(DateTime.now());
    if (platnyPlan && neexpirovano) {
      subscriptionActive = true;
    }
  }

  return _AuthData(
    userDoc: userDoc,
    predDoc: predDoc,
    subscriptionActive: subscriptionActive,
    zbyvajiciDniTrialu: zbyvajiciDni,
    rcPlanTyp: rcPlanTyp,
  );
}

void applySubscription(DocumentSnapshot? predDoc) {
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

        // Anonymní session z zákaznického portálu — odhlásit a zobrazit login
        if (user.isAnonymous) {
          FirebaseAuth.instance.signOut();
          return const AuthScreen();
        }

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
                final navOrder = List<String>.from(rawNavOrder)
                    .where(navIdToModulKlic.containsKey)
                    .toList();
                if (navOrder.isNotEmpty) {
                  navOrderNotifier.value = navOrder;
                  SharedPreferences.getInstance().then(
                    (p) => p.setStringList('nav_order', navOrder),
                  );
                }
              } else {
                // Uživatel nemá uložený nav_order — nastavíme výchozí a uložíme
                const defaultNav = ['prijem', 'vozidla', 'zakaznici', 'menu'];
                navOrderNotifier.value = defaultNav;
                SharedPreferences.getInstance().then(
                  (p) => p.setStringList('nav_order', defaultNav),
                );
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  FirebaseFirestore.instance
                      .collection('uzivatele')
                      .doc(uid)
                      .set({'nav_order': defaultNav}, SetOptions(merge: true));
                }
              }
              SharedPreferences.getInstance().then(
                (p) => p.setBool('tmavy_rezim', tmavyRezim),
              );
              // Načtení a aplikace předplatného (plan z Firestore jako základ)
              applySubscription(snap.data!.predDoc);

              // RevenueCat plán má přednost před Firestore hodnotou
              final rcPlan = snap.data!.rcPlanTyp;
              if (rcPlan != null) {
                globalPlanTyp = rcPlan;
                final defaults =
                    kPlanModuly[rcPlan] ?? kPlanModuly['basic']!;
                globalModuly = {for (final m in defaults) m: true};
              }

              if (!snap.data!.subscriptionActive) {
                return PaywallScreen(
                    zbyvajiciDniTrialu: snap.data!.zbyvajiciDniTrialu);
              }
              return const BiometricGate();
            }
            return const SetupWizardScreen();
          },
        );
      },
    );
  }
}
