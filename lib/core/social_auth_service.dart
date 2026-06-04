import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Výsledek pokusu o sociální přihlášení. Když [user] není null, přihlášení
/// proběhlo úspěšně; jinak nese [errorMessage] připravený k zobrazení uživateli,
/// nebo je obojí null (uživatel přihlášení sám zrušil — nic nehlásíme).
class SocialAuthResult {
  final User? user;
  final String? errorMessage;
  const SocialAuthResult._({this.user, this.errorMessage});

  bool get cancelled => user == null && errorMessage == null;

  factory SocialAuthResult.success(User user) =>
      SocialAuthResult._(user: user);
  factory SocialAuthResult.error(String message) =>
      SocialAuthResult._(errorMessage: message);
  const factory SocialAuthResult.cancelledByUser() = SocialAuthResult._;
}

/// Přihlášení přes Google a Apple účet napojené na Firebase Auth.
///
/// Nový uživatel (bez dokumentu v kolekci `uzivatele`) je po přihlášení
/// automaticky nasměrován do onboardingu — viz [AuthGate]. Tady se tedy
/// řeší pouze samotné ověření identity, ne založení profilu.
class SocialAuthService {
  SocialAuthService._();

  /// Přihlášení přes Google účet (iOS + Android).
  static Future<SocialAuthResult> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      // Uživatel zavřel výběr účtu.
      if (googleUser == null) return const SocialAuthResult.cancelledByUser();

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCred.user;
      if (user == null) {
        return SocialAuthResult.error('Přihlášení přes Google se nezdařilo.');
      }
      return SocialAuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return SocialAuthResult.error(_firebaseMessage(e));
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return SocialAuthResult.error('Přihlášení přes Google se nezdařilo.');
    }
  }

  /// Přihlášení přes Apple ID. Funguje nativně na iOS/iPadOS.
  static Future<SocialAuthResult> signInWithApple() async {
    try {
      final provider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');

      final userCred =
          await FirebaseAuth.instance.signInWithProvider(provider);
      final user = userCred.user;
      if (user == null) {
        return SocialAuthResult.error('Přihlášení přes Apple se nezdařilo.');
      }
      return SocialAuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      // Uživatel zrušil systémový dialog Apple.
      if (e.code == 'canceled' || e.code == 'web-context-canceled') {
        return const SocialAuthResult.cancelledByUser();
      }
      return SocialAuthResult.error(_firebaseMessage(e));
    } catch (e) {
      debugPrint('Apple sign-in error: $e');
      return SocialAuthResult.error('Přihlášení přes Apple se nezdařilo.');
    }
  }

  static String _firebaseMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'Účet s tímto e-mailem už existuje, přihlaste se původní metodou.';
      case 'invalid-credential':
        return 'Přihlašovací údaje vypršely nebo jsou neplatné.';
      case 'network-request-failed':
        return 'Chyba připojení k internetu.';
      case 'operation-not-allowed':
        return 'Tato metoda přihlášení není povolena.';
      default:
        return 'Došlo k chybě při přihlašování: ${e.code}';
    }
  }
}
