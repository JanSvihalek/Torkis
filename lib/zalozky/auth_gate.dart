import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_screen.dart';
import 'onboarding.dart';
import 'main_screen.dart';

// --- NOVÉ: GLOBÁLNÍ PROMĚNNÉ PRO CELOU APLIKACI ---
String? globalServisId;
String? globalUserRole;
Map<String, bool> globalPrava = {};

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // 1. Čekáme na zjištění stavu
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        // 2. Uživatel není přihlášen -> Login
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const AuthScreen();
        }

        final user = authSnapshot.data!;

        // 3. ZMĚNA: Už nehledáme v 'nastaveni_servisu', ale v 'uzivatele'
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('uzivatele')
              .doc(user.uid)
              .get(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }

            if (userSnap.hasError) {
              return Scaffold(
                  body: Center(
                      child:
                          Text('Chyba načítání profilu: ${userSnap.error}')));
            }

            // 4. Kontrola, zda má uživatel vytvořený profil a roli
            if (userSnap.hasData && userSnap.data!.exists) {
              final userData = userSnap.data!.data() as Map<String, dynamic>;

              // ULOŽÍME ID SERVISU, ROLI A PRÁVA DO PAMĚTI PRO ZBYTEK APLIKACE
              globalServisId = userData['servis_id'];
              globalUserRole = userData['role'];
              globalPrava = Map<String, bool>.from(userData['prava'] ?? {});

              return const MainScreen();
            }

            // 5. Pokud profil v 'uzivatele' neexistuje, je to nově registrovaný majitel -> Průvodce
            return const SetupWizardScreen();
          },
        );
      },
    );
  }
}