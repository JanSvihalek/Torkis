import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_sk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('pl'),
    Locale('sk')
  ];

  /// No description provided for @appName.
  ///
  /// In cs, this message translates to:
  /// **'TORKIS'**
  String get appName;

  /// No description provided for @btnUlozit.
  ///
  /// In cs, this message translates to:
  /// **'Uložit'**
  String get btnUlozit;

  /// No description provided for @btnZrusit.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit'**
  String get btnZrusit;

  /// No description provided for @btnPotvrdit.
  ///
  /// In cs, this message translates to:
  /// **'Potvrdit'**
  String get btnPotvrdit;

  /// No description provided for @btnZavrit.
  ///
  /// In cs, this message translates to:
  /// **'Zavřít'**
  String get btnZavrit;

  /// No description provided for @btnNovySken.
  ///
  /// In cs, this message translates to:
  /// **'Nový sken'**
  String get btnNovySken;

  /// No description provided for @btnSpustitSken.
  ///
  /// In cs, this message translates to:
  /// **'Spustit sken →'**
  String get btnSpustitSken;

  /// No description provided for @btnZacitPouzivat.
  ///
  /// In cs, this message translates to:
  /// **'Začít používat aplikaci'**
  String get btnZacitPouzivat;

  /// No description provided for @btnPlany.
  ///
  /// In cs, this message translates to:
  /// **'Plány'**
  String get btnPlany;

  /// No description provided for @nacitani.
  ///
  /// In cs, this message translates to:
  /// **'Načítání…'**
  String get nacitani;

  /// No description provided for @chybaObecna.
  ///
  /// In cs, this message translates to:
  /// **'Nastala chyba.'**
  String get chybaObecna;

  /// No description provided for @zadejteVin.
  ///
  /// In cs, this message translates to:
  /// **'Zadejte VIN kód.'**
  String get zadejteVin;

  /// No description provided for @zadejteVinRucne.
  ///
  /// In cs, this message translates to:
  /// **'Zadat VIN ručně (např. TMBJJ7NE5K…)'**
  String get zadejteVinRucne;

  /// No description provided for @vinDekoderNav.
  ///
  /// In cs, this message translates to:
  /// **'VIN'**
  String get vinDekoderNav;

  /// No description provided for @vinDekoderTabDekodovani.
  ///
  /// In cs, this message translates to:
  /// **'Dekódování VIN'**
  String get vinDekoderTabDekodovani;

  /// No description provided for @vinDekoderTabTrzniHodnota.
  ///
  /// In cs, this message translates to:
  /// **'Tržní hodnota'**
  String get vinDekoderTabTrzniHodnota;

  /// No description provided for @vinDekoderTabStk.
  ///
  /// In cs, this message translates to:
  /// **'Zjištění STK'**
  String get vinDekoderTabStk;

  /// No description provided for @vinDekoderTitle.
  ///
  /// In cs, this message translates to:
  /// **'Dekodér VIN'**
  String get vinDekoderTitle;

  /// No description provided for @vinDekoderSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Rychlé vyhledání specifikace vozu z VIN kódu'**
  String get vinDekoderSubtitle;

  /// No description provided for @trzniHodnotaTitle.
  ///
  /// In cs, this message translates to:
  /// **'Tržní hodnota'**
  String get trzniHodnotaTitle;

  /// No description provided for @trzniHodnotaSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Odhad tržní ceny vozidla z dat evropského trhu'**
  String get trzniHodnotaSubtitle;

  /// No description provided for @stkTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zjištění STK'**
  String get stkTitle;

  /// No description provided for @stkSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Přehled technických prohlídek vozidla z registru'**
  String get stkSubtitle;

  /// No description provided for @skenVinKod.
  ///
  /// In cs, this message translates to:
  /// **'Skenovat VIN kód'**
  String get skenVinKod;

  /// No description provided for @skenVinProTrzni.
  ///
  /// In cs, this message translates to:
  /// **'Skenovat VIN pro tržní hodnotu'**
  String get skenVinProTrzni;

  /// No description provided for @skenVinProStk.
  ///
  /// In cs, this message translates to:
  /// **'Skenovat VIN pro STK'**
  String get skenVinProStk;

  /// No description provided for @skenVinPopis.
  ///
  /// In cs, this message translates to:
  /// **'Automaticky načte specifikace vozu podle naskenovaného nebo zadaného VIN'**
  String get skenVinPopis;

  /// No description provided for @skenVinTrzniPopis.
  ///
  /// In cs, this message translates to:
  /// **'Zjistí odhad tržní ceny vozu podle naskenovaného nebo zadaného VIN z dat evropského trhu'**
  String get skenVinTrzniPopis;

  /// No description provided for @skenVinStkPopis.
  ///
  /// In cs, this message translates to:
  /// **'Načte data o technických prohlídkách vozidla z registru'**
  String get skenVinStkPopis;

  /// No description provided for @dekodovat.
  ///
  /// In cs, this message translates to:
  /// **'Dekódovat'**
  String get dekodovat;

  /// No description provided for @zjstitHodnotu.
  ///
  /// In cs, this message translates to:
  /// **'Zjistit hodnotu'**
  String get zjstitHodnotu;

  /// No description provided for @zjstitStk.
  ///
  /// In cs, this message translates to:
  /// **'Zjistit STK'**
  String get zjstitStk;

  /// No description provided for @stkPlatna.
  ///
  /// In cs, this message translates to:
  /// **'STK platná'**
  String get stkPlatna;

  /// No description provided for @stkNeplatna.
  ///
  /// In cs, this message translates to:
  /// **'STK neplatná'**
  String get stkNeplatna;

  /// No description provided for @stkPlatnaJeste.
  ///
  /// In cs, this message translates to:
  /// **'STK platná ještě {dni} dní'**
  String stkPlatnaJeste(int dni);

  /// No description provided for @stkProsla.
  ///
  /// In cs, this message translates to:
  /// **'STK neplatná (prošlá o {dni} dní)'**
  String stkProsla(int dni);

  /// No description provided for @stkDatumNeznamo.
  ///
  /// In cs, this message translates to:
  /// **'STK — datum neznámé'**
  String get stkDatumNeznamo;

  /// No description provided for @stkPlatnostDo.
  ///
  /// In cs, this message translates to:
  /// **'Platnost STK do'**
  String get stkPlatnostDo;

  /// No description provided for @stkInfoBanner.
  ///
  /// In cs, this message translates to:
  /// **'Data pocházejí z veřejného registru vozidel. Dostupnost a aktuálnost se liší — u některých vozidel nemusí být STK evidována.'**
  String get stkInfoBanner;

  /// No description provided for @trzniHodnotaTitle2.
  ///
  /// In cs, this message translates to:
  /// **'TRŽNÍ HODNOTA'**
  String get trzniHodnotaTitle2;

  /// No description provided for @trzniMedian.
  ///
  /// In cs, this message translates to:
  /// **'medián'**
  String get trzniMedian;

  /// No description provided for @trzniPrumernaCena.
  ///
  /// In cs, this message translates to:
  /// **'Průměrná cena'**
  String get trzniPrumernaCena;

  /// No description provided for @trzniPrumernyNajezd.
  ///
  /// In cs, this message translates to:
  /// **'Průměrný nájezd'**
  String get trzniPrumernyNajezd;

  /// No description provided for @trzniPocetVzorku.
  ///
  /// In cs, this message translates to:
  /// **'Počet vzorků'**
  String get trzniPocetVzorku;

  /// No description provided for @trzniObdobiDat.
  ///
  /// In cs, this message translates to:
  /// **'Období dat'**
  String get trzniObdobiDat;

  /// No description provided for @trzniZdroj.
  ///
  /// In cs, this message translates to:
  /// **'Evropský trh · Vincario Market Value'**
  String get trzniZdroj;

  /// No description provided for @trzniNeniData.
  ///
  /// In cs, this message translates to:
  /// **'Evropská data nejsou k dispozici.'**
  String get trzniNeniData;

  /// No description provided for @historieNacitani.
  ///
  /// In cs, this message translates to:
  /// **'Načítání…'**
  String get historieNacitani;

  /// No description provided for @historieSken.
  ///
  /// In cs, this message translates to:
  /// **'Historie skenů'**
  String get historieSken;

  /// No description provided for @historiePrvniDekodovani.
  ///
  /// In cs, this message translates to:
  /// **'Poprvé dekódováno'**
  String get historiePrvniDekodovani;

  /// No description provided for @historieNeznameVozidlo.
  ///
  /// In cs, this message translates to:
  /// **'Neznámé vozidlo'**
  String get historieNeznameVozidlo;

  /// No description provided for @historieZadneSken.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné skeny.'**
  String get historieZadneSken;

  /// No description provided for @historieVse.
  ///
  /// In cs, this message translates to:
  /// **'Vše'**
  String get historieVse;

  /// No description provided for @historieDnes.
  ///
  /// In cs, this message translates to:
  /// **'Dnes · {pocet} dekódovaných VIN'**
  String historieDnes(int pocet);

  /// No description provided for @historiePosledniSkeny.
  ///
  /// In cs, this message translates to:
  /// **'Poslední skeny'**
  String get historiePosledniSkeny;

  /// No description provided for @historieNoveVozidlo.
  ///
  /// In cs, this message translates to:
  /// **'Nové vozidlo'**
  String get historieNoveVozidlo;

  /// No description provided for @historieDekodovanoXKrat.
  ///
  /// In cs, this message translates to:
  /// **'Dekódováno {pocet}×'**
  String historieDekodovanoXKrat(int pocet);

  /// No description provided for @limitVyprsel.
  ///
  /// In cs, this message translates to:
  /// **'Měsíční limit vyčerpán. Upgradujte plán pro pokračování.'**
  String get limitVyprsel;

  /// No description provided for @limitDekodovaniTitle.
  ///
  /// In cs, this message translates to:
  /// **'Dekódování VIN tento měsíc'**
  String get limitDekodovaniTitle;

  /// No description provided for @limitTrzniTitle.
  ///
  /// In cs, this message translates to:
  /// **'Tržní hodnota tento měsíc'**
  String get limitTrzniTitle;

  /// No description provided for @upsellTrzniTitle.
  ///
  /// In cs, this message translates to:
  /// **'Tržní hodnota je v placených plánech'**
  String get upsellTrzniTitle;

  /// No description provided for @upsellTrzniText.
  ///
  /// In cs, this message translates to:
  /// **'Ve zkušební verzi není dostupná. Odemknete ji už v plánu Basic.'**
  String get upsellTrzniText;

  /// No description provided for @chybaDekodovani.
  ///
  /// In cs, this message translates to:
  /// **'Nepodařilo se dekódovat VIN: {zprava}'**
  String chybaDekodovani(String zprava);

  /// No description provided for @trialWelcomeTitle.
  ///
  /// In cs, this message translates to:
  /// **'Vítejte v TORKISu'**
  String get trialWelcomeTitle;

  /// No description provided for @trialWelcomeSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Spustili jsme vám zkušební dobu na 30 dní zdarma — bez platební karty a bez závazků.'**
  String get trialWelcomeSubtitle;

  /// No description provided for @trialWelcomePill.
  ///
  /// In cs, this message translates to:
  /// **'30 DNÍ ZDARMA'**
  String get trialWelcomePill;

  /// No description provided for @trialWelcomeFooter.
  ///
  /// In cs, this message translates to:
  /// **'Po skončení trialu si vyberete plán, který vám sedne.'**
  String get trialWelcomeFooter;

  /// No description provided for @trialBenefitVozidla.
  ///
  /// In cs, this message translates to:
  /// **'Neomezený počet záznamů vozidel a zákazníků'**
  String get trialBenefitVozidla;

  /// No description provided for @trialBenefitVin.
  ///
  /// In cs, this message translates to:
  /// **'10 dekódovaných VINů'**
  String get trialBenefitVin;

  /// No description provided for @trialBenefitStk.
  ///
  /// In cs, this message translates to:
  /// **'Neomezený počet zjištění platnosti STK'**
  String get trialBenefitStk;

  /// No description provided for @trialBenefitFunkce.
  ///
  /// In cs, this message translates to:
  /// **'Plný přístup ke všem funkcím aplikace.'**
  String get trialBenefitFunkce;

  /// No description provided for @trialBenefitKarta.
  ///
  /// In cs, this message translates to:
  /// **'Žádné platební údaje. Bez automatického strhávání.'**
  String get trialBenefitKarta;

  /// No description provided for @trialBenefitData.
  ///
  /// In cs, this message translates to:
  /// **'Vaše data jsou vždy vaše — export kdykoli zdarma.'**
  String get trialBenefitData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['cs', 'de', 'en', 'pl', 'sk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
    case 'sk':
      return AppLocalizationsSk();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
