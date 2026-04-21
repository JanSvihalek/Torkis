import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:io';
import 'auth_gate.dart'; // Pro získání globalServisId

class AppLogger {
  /// Odchytí chybu a pošle ji jak do Firebase Crashlytics, tak do tvé databáze
  static Future<void> logError(String kontext, dynamic chyba, [StackTrace? stackTrace]) async {
    // 1. Zapsání do konzole (pro tebe při vývoji)
    debugPrint('🔴 CHYBA [$kontext]: $chyba');
    if (stackTrace != null) debugPrint(stackTrace.toString());

    // 2. Odeslání do Firebase Crashlytics (jen v produkci, ne na webu)
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordError(chyba, stackTrace, reason: kontext);
    }

    // 3. Uložení čitelného logu do Firestore (abys to viděl rovnou v databázi)
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      await FirebaseFirestore.instance.collection('chybove_logy').add({
        'cas': FieldValue.serverTimestamp(),
        'servis_id': globalServisId ?? 'neznámý',
        'uzivatel_id': user?.uid ?? 'nepřihlášen',
        'uzivatel_email': user?.email ?? 'nepřihlášen',
        'kontext_akce': kontext,
        'chybova_hlaska': chyba.toString(),
        'stack_trace': stackTrace?.toString() ?? '',
        'platforma': kIsWeb ? 'Web' : (Platform.isIOS ? 'iOS' : 'Android'),
        'vyreseno': false, // Můžeš si v databázi pak chyby odškrtávat
      });
    } catch (e) {
      debugPrint('Selhalo uložení logu do databáze: $e');
    }
  }

  /// Pro zaznamenání důležitých uživatelských akcí (tzv. "Breadcrumbs")
  /// Pomůže ti to zjistit, co uživatel dělal těsně před tím, než to spadlo
  static void logAkci(String akce) {
    debugPrint('🔵 AKCE: $akce');
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.log(akce);
    }
  }
}