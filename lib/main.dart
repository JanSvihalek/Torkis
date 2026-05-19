import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // Potřebné pro PlatformDispatcher
import 'firebase_options.dart';
import 'core/constants.dart';
import 'core/design_tokens.dart';
import 'core/subscription_service.dart';
import 'moduly/auth_gate.dart';
import 'moduly/main_screen.dart'; // kvůli navOrderNotifier

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializace Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SubscriptionService.init();
  await initializeDateFormatting('cs_CZ', null);

  // Načteme uložené preference PŘED prvním snímkem, aby nedošlo k záblesku
  // světlého motivu nebo nesprávného pořadí záložek.
  final prefs = await SharedPreferences.getInstance();

  final tmavyRezim = prefs.getBool('tmavy_rezim') ?? false;
  themeNotifier.value = tmavyRezim ? ThemeMode.dark : ThemeMode.light;

  final savedNavOrder = prefs.getStringList('nav_order');
  if (savedNavOrder != null && savedNavOrder.isNotEmpty) {
    navOrderNotifier.value = savedNavOrder;
  }

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

/// Headings (display, headline) = IBM Plex Sans, vše ostatní = IBM Plex Mono.
TextTheme _buildTextTheme(TextTheme base) {
  final sans = GoogleFonts.ibmPlexSansTextTheme(base);
  return sans.copyWith(
    bodyLarge: GoogleFonts.ibmPlexMono(textStyle: sans.bodyLarge),
    bodyMedium: GoogleFonts.ibmPlexMono(textStyle: sans.bodyMedium),
    bodySmall: GoogleFonts.ibmPlexMono(textStyle: sans.bodySmall),
    labelLarge: GoogleFonts.ibmPlexMono(textStyle: sans.labelLarge),
    labelMedium: GoogleFonts.ibmPlexMono(textStyle: sans.labelMedium),
    labelSmall: GoogleFonts.ibmPlexMono(textStyle: sans.labelSmall),
    titleLarge: GoogleFonts.ibmPlexMono(textStyle: sans.titleLarge),
    titleMedium: GoogleFonts.ibmPlexMono(textStyle: sans.titleMedium),
    titleSmall: GoogleFonts.ibmPlexMono(textStyle: sans.titleSmall),
  );
}

ThemeData _buildTorkisTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final tok = TorkisTokens(brightness);

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: TokColors.accent,
    onPrimary: Colors.white,
    secondary: TokColors.ink,
    onSecondary: Colors.white,
    error: TokColors.danger,
    onError: Colors.white,
    surface: tok.surface,
    onSurface: tok.textPrimary,
    surfaceContainerHighest: tok.surfaceElevated,
    surfaceContainer: tok.surface,
    surfaceContainerLow: tok.bg,
    surfaceContainerLowest: tok.bg,
    outline: tok.line,
    outlineVariant: tok.line,
    tertiary: TokColors.accent2,
    onTertiary: Colors.white,
  );

  final baseText = _buildTextTheme(ThemeData(brightness: brightness).textTheme);

  return ThemeData(
    brightness: brightness,
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: tok.bg,
    canvasColor: tok.bg,
    dividerColor: tok.line,
    textTheme: baseText.apply(
      bodyColor: tok.textPrimary,
      displayColor: tok.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: tok.bg,
      foregroundColor: tok.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: GoogleFonts.ibmPlexSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: tok.textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: tok.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TokRadius.xl),
        side: BorderSide(color: tok.line),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: TokColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TokRadius.lg),
        ),
        textStyle: GoogleFonts.ibmPlexSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: tok.textPrimary,
        side: BorderSide(color: tok.lineStrong),
        minimumSize: const Size.fromHeight(50),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TokRadius.lg),
        ),
        textStyle: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: TokColors.accent,
        textStyle: GoogleFonts.ibmPlexSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : TokColors.paper,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: TextStyle(color: tok.textMuted, fontSize: 15),
      labelStyle: TextStyle(color: tok.textSecondary, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TokRadius.md),
        borderSide: BorderSide(color: tok.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TokRadius.md),
        borderSide: BorderSide(color: tok.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TokRadius.md),
        borderSide: const BorderSide(color: TokColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TokRadius.md),
        borderSide: const BorderSide(color: TokColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(TokRadius.md),
        borderSide: const BorderSide(color: TokColors.danger, width: 1.5),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isDark
          ? TokColors.darkSurface.withValues(alpha: 0.95)
          : Colors.white.withValues(alpha: 0.96),
      surfaceTintColor: Colors.transparent,
      indicatorColor: TokColors.accentSoft,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.ibmPlexSans(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          letterSpacing: 0.2,
          color: selected ? TokColors.accent : tok.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? TokColors.accent : tok.textSecondary,
          size: 22,
        );
      }),
      height: 64,
      elevation: 0,
    ),
    dividerTheme: DividerThemeData(
      color: tok.line,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: tok.bg,
      side: BorderSide(color: tok.line),
      labelStyle: GoogleFonts.ibmPlexSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: tok.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TokRadius.round),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: tok.inkSurface,
      contentTextStyle: GoogleFonts.ibmPlexSans(
        color: tok.onInk,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TokRadius.md),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: tok.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TokRadius.xl),
      ),
    ),
  );
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
          title: 'TORKIS',
          
          // --- PŘIDÁNO: Podpora češtiny pro úplně všechny systémové dialogy ---
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('cs', 'CZ'),
          ],

          theme: _buildTorkisTheme(Brightness.light),
          darkTheme: _buildTorkisTheme(Brightness.dark),
          themeMode: currentMode,

          home: const AuthGate(),
        );
      },
    );
  }
}