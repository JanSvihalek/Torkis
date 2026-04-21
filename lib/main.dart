import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:ui'; // Potřebné pro PlatformDispatcher

import 'firebase_options.dart';
import 'core/constants.dart';
import 'zalozky/auth_screen.dart';
import 'zalozky/main_screen.dart';

// Zde uprav cestu podle toho, do jaké složky sis uložil svůj logger
import 'zalozky/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializace Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Tvoje původní inicializace českého formátování času
  await initializeDateFormatting('cs_CZ', null);

  // --- NASTAVENÍ CRASHLYTICS A ZACHYTÁVÁNÍ CHYB ---
  if (!kIsWeb) {
    // Odchytí chyby vykreslování Flutteru (v UI)
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Odchytí asynchronní chyby (např. selhání na pozadí, pád API)
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    
    debugPrint("✅ Firebase Crashlytics je aktivní.");
  } else {
    debugPrint("ℹ️ Spuštěno na webu, Crashlytics je neaktivní.");
  }

  runApp(const VistoApp());
}

class VistoApp extends StatelessWidget {
  const VistoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Visto',
          
          // --- PŘIDÁNO: Podpora češtiny pro úplně všechny systémové dialogy ---
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('cs', 'CZ'),
          ],

          // Tvoje původní, nedotčené nastavení světlého motivu
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0061FF),
              primary: const Color(0xFF0061FF),
              surface: const Color(0xFFFBFDFF),
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          
          // Tvoje původní, nedotčené nastavení tmavého motivu
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF4D94FF),
              primary: const Color(0xFF4D94FF),
              surface: const Color(0xFF121212),
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          themeMode: currentMode,
          
          // Tvoje původní logika pro přihlašování a směrování
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasData) {
                return const MainScreen();
              }
              return const AuthScreen();
            },
          ),
        );
      },
    );
  }
}