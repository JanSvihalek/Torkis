import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_screen.dart';
import 'onboarding.dart';
import 'main_screen.dart';

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

        // 3. Uživatel JE přihlášen -> Jdeme do databáze
        final user = authSnapshot.data!;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('nastaveni_servisu')
              .doc(user.uid)
              .get(),
          builder: (context, firestoreSnapshot) {
            if (firestoreSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }

            if (firestoreSnapshot.hasError) {
              return Scaffold(
                  body:
                      Center(child: Text('Chyba: ${firestoreSnapshot.error}')));
            }

            // 4. Kontrola
            final doc = firestoreSnapshot.data;
            if (doc != null && doc.exists) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['prvni_spusteni_dokonceno'] == true) {
                // Hotovo, pouštíme ho dál!
                return const MainScreen();
              }
            }

            // 5. Není to hotové -> Zpět do průvodce
            return const SetupWizardScreen();
          },
        );
      },
    );
  }
}
