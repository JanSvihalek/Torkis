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

  /// No description provided for @vozidloStatTacho.
  ///
  /// In cs, this message translates to:
  /// **'TACHOMETR'**
  String get vozidloStatTacho;

  /// No description provided for @vozidloStatStkDo.
  ///
  /// In cs, this message translates to:
  /// **'STK DO'**
  String get vozidloStatStkDo;

  /// No description provided for @vozidloStatPrijmu.
  ///
  /// In cs, this message translates to:
  /// **'PŘÍJMŮ'**
  String get vozidloStatPrijmu;

  /// No description provided for @vozidloStkPlatna.
  ///
  /// In cs, this message translates to:
  /// **'STK platná'**
  String get vozidloStkPlatna;

  /// No description provided for @vozidloStkProsla.
  ///
  /// In cs, this message translates to:
  /// **'STK prošlá'**
  String get vozidloStkProsla;

  /// No description provided for @vozidloStkVyprsiBehemMesicu.
  ///
  /// In cs, this message translates to:
  /// **'Vyprší {mesic}/{rok} · zbývá {pocet} měsíců'**
  String vozidloStkVyprsiBehemMesicu(String mesic, String rok, int pocet);

  /// No description provided for @vozidloStkVyprsela.
  ///
  /// In cs, this message translates to:
  /// **'Vypršela {mesic}/{rok}'**
  String vozidloStkVyprsela(String mesic, String rok);

  /// No description provided for @vozidloTechnickeUdaje.
  ///
  /// In cs, this message translates to:
  /// **'Technické údaje'**
  String get vozidloTechnickeUdaje;

  /// No description provided for @vozidloZnackaModel.
  ///
  /// In cs, this message translates to:
  /// **'Značka & Model'**
  String get vozidloZnackaModel;

  /// No description provided for @vozidloMotorizace.
  ///
  /// In cs, this message translates to:
  /// **'Motorizace'**
  String get vozidloMotorizace;

  /// No description provided for @vozidloVin.
  ///
  /// In cs, this message translates to:
  /// **'VIN'**
  String get vozidloVin;

  /// No description provided for @vozidloRokVyroby.
  ///
  /// In cs, this message translates to:
  /// **'Rok výroby'**
  String get vozidloRokVyroby;

  /// No description provided for @vozidloPalivo.
  ///
  /// In cs, this message translates to:
  /// **'Palivo'**
  String get vozidloPalivo;

  /// No description provided for @vozidloPrevodovka.
  ///
  /// In cs, this message translates to:
  /// **'Převodovka'**
  String get vozidloPrevodovka;

  /// No description provided for @vozidloBarva.
  ///
  /// In cs, this message translates to:
  /// **'Barva'**
  String get vozidloBarva;

  /// No description provided for @vozidloVykon.
  ///
  /// In cs, this message translates to:
  /// **'Výkon'**
  String get vozidloVykon;

  /// No description provided for @vozidloPocetMistDveri.
  ///
  /// In cs, this message translates to:
  /// **'Místa / dveře'**
  String get vozidloPocetMistDveri;

  /// No description provided for @vozidloRozmery.
  ///
  /// In cs, this message translates to:
  /// **'Rozměry'**
  String get vozidloRozmery;

  /// No description provided for @vozidloUdajeZVin.
  ///
  /// In cs, this message translates to:
  /// **'Údaje z VIN'**
  String get vozidloUdajeZVin;

  /// No description provided for @vozidloTachometrLabel.
  ///
  /// In cs, this message translates to:
  /// **'Tachometr'**
  String get vozidloTachometrLabel;

  /// No description provided for @vozidloMajitel.
  ///
  /// In cs, this message translates to:
  /// **'Majitel vozidla'**
  String get vozidloMajitel;

  /// No description provided for @vozidloJmeno.
  ///
  /// In cs, this message translates to:
  /// **'Jméno'**
  String get vozidloJmeno;

  /// No description provided for @vozidloTelefon.
  ///
  /// In cs, this message translates to:
  /// **'Telefon'**
  String get vozidloTelefon;

  /// No description provided for @vozidloEmail.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get vozidloEmail;

  /// No description provided for @vozidloVolat.
  ///
  /// In cs, this message translates to:
  /// **'Volat'**
  String get vozidloVolat;

  /// No description provided for @vozidlaTitle.
  ///
  /// In cs, this message translates to:
  /// **'Databáze vozidel'**
  String get vozidlaTitle;

  /// No description provided for @vozidlaSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Přehled všech servisovaných aut.'**
  String get vozidlaSubtitle;

  /// No description provided for @vozidlaHledatHint.
  ///
  /// In cs, this message translates to:
  /// **'Hledat SPZ, Značku nebo VIN...'**
  String get vozidlaHledatHint;

  /// No description provided for @vozidlaSkenSpzTooltip.
  ///
  /// In cs, this message translates to:
  /// **'Naskenovat SPZ fotoaparátem'**
  String get vozidlaSkenSpzTooltip;

  /// No description provided for @vozidlaZadnaVozidla.
  ///
  /// In cs, this message translates to:
  /// **'Zatím nemáte v databázi žádná vozidla.'**
  String get vozidlaZadnaVozidla;

  /// No description provided for @vozidlaNejstePrihlaseni.
  ///
  /// In cs, this message translates to:
  /// **'Nejste přihlášeni.'**
  String get vozidlaNejstePrihlaseni;

  /// No description provided for @vozidlaSkenJenApp.
  ///
  /// In cs, this message translates to:
  /// **'Skenování funguje pouze v nainstalované aplikaci (APK/iOS).'**
  String get vozidlaSkenJenApp;

  /// No description provided for @vozidloDetailUprava.
  ///
  /// In cs, this message translates to:
  /// **'Úprava vozidla'**
  String get vozidloDetailUprava;

  /// No description provided for @vozidloDetailSpz.
  ///
  /// In cs, this message translates to:
  /// **'SPZ'**
  String get vozidloDetailSpz;

  /// No description provided for @vozidloDetailZnacka.
  ///
  /// In cs, this message translates to:
  /// **'Značka'**
  String get vozidloDetailZnacka;

  /// No description provided for @vozidloDetailModel.
  ///
  /// In cs, this message translates to:
  /// **'Model'**
  String get vozidloDetailModel;

  /// No description provided for @vozidloDetailTachoKm.
  ///
  /// In cs, this message translates to:
  /// **'Tachometr (km)'**
  String get vozidloDetailTachoKm;

  /// No description provided for @vozidloDetailPlatnostStk.
  ///
  /// In cs, this message translates to:
  /// **'Platnost STK'**
  String get vozidloDetailPlatnostStk;

  /// No description provided for @vozidloDetailStkMesic.
  ///
  /// In cs, this message translates to:
  /// **'Měsíc (MM)'**
  String get vozidloDetailStkMesic;

  /// No description provided for @vozidloDetailStkRok.
  ///
  /// In cs, this message translates to:
  /// **'Rok (YYYY)'**
  String get vozidloDetailStkRok;

  /// No description provided for @vozidloDetailUlozitZmeny.
  ///
  /// In cs, this message translates to:
  /// **'ULOŽIT ZMĚNY'**
  String get vozidloDetailUlozitZmeny;

  /// No description provided for @vozidloDetailSpzExistuje.
  ///
  /// In cs, this message translates to:
  /// **'Vozidlo s touto SPZ již existuje!'**
  String get vozidloDetailSpzExistuje;

  /// No description provided for @vozidloDetailPrejmenovano.
  ///
  /// In cs, this message translates to:
  /// **'Vozidlo přejmenováno na {spz}. Historie byla zachována.'**
  String vozidloDetailPrejmenovano(String spz);

  /// No description provided for @vozidloDetailNenalezeno.
  ///
  /// In cs, this message translates to:
  /// **'Vozidlo nenalezeno.'**
  String get vozidloDetailNenalezeno;

  /// No description provided for @vozidloDetailBezSpz.
  ///
  /// In cs, this message translates to:
  /// **'Vozidlo bez SPZ'**
  String get vozidloDetailBezSpz;

  /// No description provided for @vozidloDetailLabel.
  ///
  /// In cs, this message translates to:
  /// **'VOZIDLO'**
  String get vozidloDetailLabel;

  /// No description provided for @vozidloTabInfo.
  ///
  /// In cs, this message translates to:
  /// **'Info'**
  String get vozidloTabInfo;

  /// No description provided for @vozidloTabZaznamy.
  ///
  /// In cs, this message translates to:
  /// **'Záznamy'**
  String get vozidloTabZaznamy;

  /// No description provided for @vozidloSmazatAkce.
  ///
  /// In cs, this message translates to:
  /// **'Smazat vozidlo'**
  String get vozidloSmazatAkce;

  /// No description provided for @vozidloSmazatDialogTitle.
  ///
  /// In cs, this message translates to:
  /// **'Smazat vozidlo?'**
  String get vozidloSmazatDialogTitle;

  /// No description provided for @vozidloSmazatDialogText.
  ///
  /// In cs, this message translates to:
  /// **'Vozidlo bude odebráno z adresáře. Historie zakázek zůstane zachována.'**
  String get vozidloSmazatDialogText;

  /// No description provided for @vozidloSmazano.
  ///
  /// In cs, this message translates to:
  /// **'Vozidlo bylo smazáno.'**
  String get vozidloSmazano;

  /// No description provided for @vozidloSmazatBtn.
  ///
  /// In cs, this message translates to:
  /// **'Smazat'**
  String get vozidloSmazatBtn;

  /// No description provided for @prijemHelperTelefon.
  ///
  /// In cs, this message translates to:
  /// **'Telefonní číslo'**
  String get prijemHelperTelefon;

  /// No description provided for @prijemHelperPredvolba.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte předvolbu'**
  String get prijemHelperPredvolba;

  /// No description provided for @prijemStavTitle.
  ///
  /// In cs, this message translates to:
  /// **'Stav vozidla'**
  String get prijemStavTitle;

  /// No description provided for @prijemStavTacho.
  ///
  /// In cs, this message translates to:
  /// **'Stav tachometru (km)'**
  String get prijemStavTacho;

  /// No description provided for @prijemStavNadrz.
  ///
  /// In cs, this message translates to:
  /// **'Stav paliva v nádrži ({value} %)'**
  String prijemStavNadrz(int value);

  /// No description provided for @prijemStavPoskozeni.
  ///
  /// In cs, this message translates to:
  /// **'Zjištěná poškození (lze vybrat více)'**
  String get prijemStavPoskozeni;

  /// No description provided for @prijemStavVlastniPopis.
  ///
  /// In cs, this message translates to:
  /// **'Vlastní popis poškození...'**
  String get prijemStavVlastniPopis;

  /// No description provided for @prijemStavPridat.
  ///
  /// In cs, this message translates to:
  /// **'Přidat vlastní poškození'**
  String get prijemStavPridat;

  /// No description provided for @prijemStavPlatnostStk.
  ///
  /// In cs, this message translates to:
  /// **'Platnost STK'**
  String get prijemStavPlatnostStk;

  /// No description provided for @prijemStavMesic.
  ///
  /// In cs, this message translates to:
  /// **'Měsíc'**
  String get prijemStavMesic;

  /// No description provided for @prijemStavRok.
  ///
  /// In cs, this message translates to:
  /// **'Rok'**
  String get prijemStavRok;

  /// No description provided for @prijemStavPneu.
  ///
  /// In cs, this message translates to:
  /// **'Hloubka dezénu pneu (v mm)'**
  String get prijemStavPneu;

  /// No description provided for @prijemStavLevaPreh.
  ///
  /// In cs, this message translates to:
  /// **'Levá př.'**
  String get prijemStavLevaPreh;

  /// No description provided for @prijemStavPravaPreh.
  ///
  /// In cs, this message translates to:
  /// **'Pravá př.'**
  String get prijemStavPravaPreh;

  /// No description provided for @prijemStavLevaZad.
  ///
  /// In cs, this message translates to:
  /// **'Levá zad.'**
  String get prijemStavLevaZad;

  /// No description provided for @prijemStavPravaZad.
  ///
  /// In cs, this message translates to:
  /// **'Pravá zad.'**
  String get prijemStavPravaZad;

  /// No description provided for @prijemStavPoznamky.
  ///
  /// In cs, this message translates to:
  /// **'Dodatečné poznámky k vozu'**
  String get prijemStavPoznamky;

  /// No description provided for @prijemStavPoznamkyHint.
  ///
  /// In cs, this message translates to:
  /// **'Jakékoliv další detaily k příjmu...'**
  String get prijemStavPoznamkyHint;

  /// No description provided for @prijemZakaznikTitle.
  ///
  /// In cs, this message translates to:
  /// **'Údaje o zákazníkovi'**
  String get prijemZakaznikTitle;

  /// No description provided for @prijemZakaznikJmeno.
  ///
  /// In cs, this message translates to:
  /// **'Jméno a příjmení / Název firmy'**
  String get prijemZakaznikJmeno;

  /// No description provided for @prijemZakaznikHledat.
  ///
  /// In cs, this message translates to:
  /// **'Hledat uloženého zákazníka'**
  String get prijemZakaznikHledat;

  /// No description provided for @prijemZakaznikIco.
  ///
  /// In cs, this message translates to:
  /// **'IČO (ARES vyhledávání)'**
  String get prijemZakaznikIco;

  /// No description provided for @prijemZakaznikHledatAres.
  ///
  /// In cs, this message translates to:
  /// **'Hledat v ARES'**
  String get prijemZakaznikHledatAres;

  /// No description provided for @prijemZakaznikPravniForma.
  ///
  /// In cs, this message translates to:
  /// **'Právní forma'**
  String get prijemZakaznikPravniForma;

  /// No description provided for @prijemZakaznikUlice.
  ///
  /// In cs, this message translates to:
  /// **'Ulice a číslo'**
  String get prijemZakaznikUlice;

  /// No description provided for @prijemZakaznikMesto.
  ///
  /// In cs, this message translates to:
  /// **'Město'**
  String get prijemZakaznikMesto;

  /// No description provided for @prijemZakaznikPsc.
  ///
  /// In cs, this message translates to:
  /// **'PSČ'**
  String get prijemZakaznikPsc;

  /// No description provided for @prijemZakaznikEmail.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get prijemZakaznikEmail;

  /// No description provided for @prijemZakaznikFyzicka.
  ///
  /// In cs, this message translates to:
  /// **'Fyzická osoba'**
  String get prijemZakaznikFyzicka;

  /// No description provided for @prijemZakaznikOsvc.
  ///
  /// In cs, this message translates to:
  /// **'OSVČ'**
  String get prijemZakaznikOsvc;

  /// No description provided for @prijemVozidloTitle.
  ///
  /// In cs, this message translates to:
  /// **'Záznam vozidla'**
  String get prijemVozidloTitle;

  /// No description provided for @prijemVozidloNapoveda.
  ///
  /// In cs, this message translates to:
  /// **'Naskenujte VIN nebo SPZ, nebo údaje doplňte ručně.'**
  String get prijemVozidloNapoveda;

  /// No description provided for @prijemVozidloZeme.
  ///
  /// In cs, this message translates to:
  /// **'Země'**
  String get prijemVozidloZeme;

  /// No description provided for @prijemVozidloSpz.
  ///
  /// In cs, this message translates to:
  /// **'SPZ vozidla'**
  String get prijemVozidloSpz;

  /// No description provided for @prijemVozidloHledatSpz.
  ///
  /// In cs, this message translates to:
  /// **'Hledat SPZ v databázi'**
  String get prijemVozidloHledatSpz;

  /// No description provided for @prijemVozidloHledatSpzSub.
  ///
  /// In cs, this message translates to:
  /// **'Najít dříve uložené vozidlo podle SPZ'**
  String get prijemVozidloHledatSpzSub;

  /// No description provided for @prijemVozidloVin.
  ///
  /// In cs, this message translates to:
  /// **'VIN kód'**
  String get prijemVozidloVin;

  /// No description provided for @prijemVozidloHledatVin.
  ///
  /// In cs, this message translates to:
  /// **'Hledat VIN v databázi'**
  String get prijemVozidloHledatVin;

  /// No description provided for @prijemVozidloHledatVinSub.
  ///
  /// In cs, this message translates to:
  /// **'Najít dříve uložené vozidlo podle VIN'**
  String get prijemVozidloHledatVinSub;

  /// No description provided for @prijemVozidloDekodovat.
  ///
  /// In cs, this message translates to:
  /// **'Dekódovat VIN online'**
  String get prijemVozidloDekodovat;

  /// No description provided for @prijemVozidloDekodovatSub.
  ///
  /// In cs, this message translates to:
  /// **'Doplnit značku, model, motorizaci a STK'**
  String get prijemVozidloDekodovatSub;

  /// No description provided for @prijemVozidloZnackaHint.
  ///
  /// In cs, this message translates to:
  /// **'Značka (např. Škoda)'**
  String get prijemVozidloZnackaHint;

  /// No description provided for @prijemVozidloModelHint.
  ///
  /// In cs, this message translates to:
  /// **'Model (např. Octavia)'**
  String get prijemVozidloModelHint;

  /// No description provided for @prijemVozidloSkenovat.
  ///
  /// In cs, this message translates to:
  /// **'Skenovat VIN/SPZ'**
  String get prijemVozidloSkenovat;

  /// No description provided for @prijemVozidloSkenSub.
  ///
  /// In cs, this message translates to:
  /// **'Automaticky rozpozná typ kódu'**
  String get prijemVozidloSkenSub;

  /// No description provided for @prijemVozidloRozlozeniPodSebou.
  ///
  /// In cs, this message translates to:
  /// **'Pod sebou'**
  String get prijemVozidloRozlozeniPodSebou;

  /// No description provided for @prijemVozidloRozlozeniVMrizce.
  ///
  /// In cs, this message translates to:
  /// **'V mřížce'**
  String get prijemVozidloRozlozeniVMrizce;

  /// No description provided for @prijemVozidloTypZaznamu.
  ///
  /// In cs, this message translates to:
  /// **'Typ záznamu'**
  String get prijemVozidloTypZaznamu;

  /// No description provided for @prijemVozidloCisloZaznamu.
  ///
  /// In cs, this message translates to:
  /// **'Číslo záznamu'**
  String get prijemVozidloCisloZaznamu;

  /// No description provided for @prijemVozidloGenerovat.
  ///
  /// In cs, this message translates to:
  /// **'Vygenerovat nové číslo'**
  String get prijemVozidloGenerovat;

  /// No description provided for @prijemVozidloUlozenaVozidla.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník má uložená tato vozidla'**
  String get prijemVozidloUlozenaVozidla;

  /// No description provided for @prijemVozidloRokVyroby.
  ///
  /// In cs, this message translates to:
  /// **'Rok výroby'**
  String get prijemVozidloRokVyroby;

  /// No description provided for @prijemVozidloMotorizaceHint.
  ///
  /// In cs, this message translates to:
  /// **'Motorizace (např. 2.0 TDI)'**
  String get prijemVozidloMotorizaceHint;

  /// No description provided for @prijemVozidloTypPaliva.
  ///
  /// In cs, this message translates to:
  /// **'Typ paliva'**
  String get prijemVozidloTypPaliva;

  /// No description provided for @prijemVozidloPrevodovka.
  ///
  /// In cs, this message translates to:
  /// **'Převodovka'**
  String get prijemVozidloPrevodovka;

  /// No description provided for @prijemVozidloTypKaroserie.
  ///
  /// In cs, this message translates to:
  /// **'Typ karosérie'**
  String get prijemVozidloTypKaroserie;

  /// No description provided for @prijemVozidloBenzin.
  ///
  /// In cs, this message translates to:
  /// **'Benzín'**
  String get prijemVozidloBenzin;

  /// No description provided for @prijemVozidloNafta.
  ///
  /// In cs, this message translates to:
  /// **'Nafta'**
  String get prijemVozidloNafta;

  /// No description provided for @prijemVozidloElektro.
  ///
  /// In cs, this message translates to:
  /// **'Elektro'**
  String get prijemVozidloElektro;

  /// No description provided for @prijemVozidloHybrid.
  ///
  /// In cs, this message translates to:
  /// **'Hybrid'**
  String get prijemVozidloHybrid;

  /// No description provided for @prijemVozidloLpgCng.
  ///
  /// In cs, this message translates to:
  /// **'LPG/CNG'**
  String get prijemVozidloLpgCng;

  /// No description provided for @prijemVozidloJine.
  ///
  /// In cs, this message translates to:
  /// **'Jiné'**
  String get prijemVozidloJine;

  /// No description provided for @prijemVozidloManualni.
  ///
  /// In cs, this message translates to:
  /// **'Manuální'**
  String get prijemVozidloManualni;

  /// No description provided for @prijemVozidloAutomaticka.
  ///
  /// In cs, this message translates to:
  /// **'Automatická'**
  String get prijemVozidloAutomaticka;

  /// No description provided for @prijemVozidloDalsiUdaje.
  ///
  /// In cs, this message translates to:
  /// **'Další údaje o vozidle'**
  String get prijemVozidloDalsiUdaje;

  /// No description provided for @prijemVozidloDalsiUdajeSub.
  ///
  /// In cs, this message translates to:
  /// **'Nepovinné – doplní se z VIN dekodéru'**
  String get prijemVozidloDalsiUdajeSub;

  /// No description provided for @prijemVozidloBarva.
  ///
  /// In cs, this message translates to:
  /// **'Barva'**
  String get prijemVozidloBarva;

  /// No description provided for @prijemVozidloVykon.
  ///
  /// In cs, this message translates to:
  /// **'Výkon (kW)'**
  String get prijemVozidloVykon;

  /// No description provided for @prijemVozidloPocetMist.
  ///
  /// In cs, this message translates to:
  /// **'Počet míst'**
  String get prijemVozidloPocetMist;

  /// No description provided for @prijemVozidloPocetDveri.
  ///
  /// In cs, this message translates to:
  /// **'Počet dveří'**
  String get prijemVozidloPocetDveri;

  /// No description provided for @prijemVozidloRozmery.
  ///
  /// In cs, this message translates to:
  /// **'Rozměry (D × Š × V mm)'**
  String get prijemVozidloRozmery;

  /// No description provided for @prijemVozidloDelka.
  ///
  /// In cs, this message translates to:
  /// **'Délka'**
  String get prijemVozidloDelka;

  /// No description provided for @prijemVozidloSirka.
  ///
  /// In cs, this message translates to:
  /// **'Šířka'**
  String get prijemVozidloSirka;

  /// No description provided for @prijemVozidloVyska.
  ///
  /// In cs, this message translates to:
  /// **'Výška'**
  String get prijemVozidloVyska;

  /// No description provided for @prijemPraceTitle.
  ///
  /// In cs, this message translates to:
  /// **'Požadované práce'**
  String get prijemPraceTitle;

  /// No description provided for @prijemPracePozadavkyHint.
  ///
  /// In cs, this message translates to:
  /// **'Na čem jsme se se zákazníkem domluvili?'**
  String get prijemPracePozadavkyHint;

  /// No description provided for @prijemPraceRychlyVyber.
  ///
  /// In cs, this message translates to:
  /// **'Rychlý výběr nejčastějších úkonů:'**
  String get prijemPraceRychlyVyber;

  /// No description provided for @prijemPraceSeznam.
  ///
  /// In cs, this message translates to:
  /// **'Seznam požadavků k zakázce:'**
  String get prijemPraceSeznam;

  /// No description provided for @prijemPracePridat.
  ///
  /// In cs, this message translates to:
  /// **'Přidat jiný úkon'**
  String get prijemPracePridat;

  /// No description provided for @prijemPraceUkonN.
  ///
  /// In cs, this message translates to:
  /// **'Úkon {n}'**
  String prijemPraceUkonN(int n);

  /// No description provided for @prijemPodpisTitle.
  ///
  /// In cs, this message translates to:
  /// **'Shrnutí'**
  String get prijemPodpisTitle;

  /// No description provided for @prijemPodpisNeuvedeno.
  ///
  /// In cs, this message translates to:
  /// **'Neuvedeno'**
  String get prijemPodpisNeuvedeno;

  /// No description provided for @prijemPodpisZakaznik.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník: {jmeno}'**
  String prijemPodpisZakaznik(String jmeno);

  /// No description provided for @prijemPodpisAdresa.
  ///
  /// In cs, this message translates to:
  /// **'Adresa: {adresa}'**
  String prijemPodpisAdresa(String adresa);

  /// No description provided for @prijemPodpisVozidlo.
  ///
  /// In cs, this message translates to:
  /// **'Vozidlo: {spzZnacka}'**
  String prijemPodpisVozidlo(String spzZnacka);

  /// No description provided for @prijemPodpisSjednaneUkony.
  ///
  /// In cs, this message translates to:
  /// **'Sjednané úkony:'**
  String get prijemPodpisSjednaneUkony;

  /// No description provided for @prijemRekapZaznam.
  ///
  /// In cs, this message translates to:
  /// **'Záznam'**
  String get prijemRekapZaznam;

  /// No description provided for @prijemKonceptTitle.
  ///
  /// In cs, this message translates to:
  /// **'Neodeslaná zakázka'**
  String get prijemKonceptTitle;

  /// No description provided for @prijemKonceptText.
  ///
  /// In cs, this message translates to:
  /// **'Máte rozpracovanou neodeslanou zakázku. Chcete pokračovat tam, kde jste skončili?'**
  String get prijemKonceptText;

  /// No description provided for @prijemKonceptObnovit.
  ///
  /// In cs, this message translates to:
  /// **'Obnovit'**
  String get prijemKonceptObnovit;

  /// No description provided for @prijemKonceptZahodit.
  ///
  /// In cs, this message translates to:
  /// **'Zahodit'**
  String get prijemKonceptZahodit;

  /// No description provided for @prijemPodpisEmailToggle.
  ///
  /// In cs, this message translates to:
  /// **'Odeslat kopii protokolu na e-mail'**
  String get prijemPodpisEmailToggle;

  /// No description provided for @prijemPodpisEmailChybi.
  ///
  /// In cs, this message translates to:
  /// **'U zákazníka (krok 2) není vyplněn žádný e-mail.'**
  String get prijemPodpisEmailChybi;

  /// No description provided for @prijemPodpisEmailKam.
  ///
  /// In cs, this message translates to:
  /// **'Bude odesláno na: {email}'**
  String prijemPodpisEmailKam(String email);

  /// No description provided for @prijemPodpisSouhlas.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník svým podpisem stvrzuje správnost výše uvedených údajů a souhlasí se stavem vozidla při převzetí do servisu.'**
  String get prijemPodpisSouhlas;

  /// No description provided for @prijemPodpisSmazat.
  ///
  /// In cs, this message translates to:
  /// **'Smazat podpis'**
  String get prijemPodpisSmazat;

  /// No description provided for @prijemPodpisVypnut.
  ///
  /// In cs, this message translates to:
  /// **'Podpis zákazníka je v nastavení servisu vypnut.'**
  String get prijemPodpisVypnut;

  /// No description provided for @prijemPodpisOtevrit.
  ///
  /// In cs, this message translates to:
  /// **'Podepsat'**
  String get prijemPodpisOtevrit;

  /// No description provided for @prijemPodpisZnovu.
  ///
  /// In cs, this message translates to:
  /// **'Podepsat znovu'**
  String get prijemPodpisZnovu;

  /// No description provided for @prijemPodpisHotovo.
  ///
  /// In cs, this message translates to:
  /// **'Hotovo'**
  String get prijemPodpisHotovo;

  /// No description provided for @prijemPodpisZavrit.
  ///
  /// In cs, this message translates to:
  /// **'Zavřít'**
  String get prijemPodpisZavrit;

  /// No description provided for @prijemPodpisHint.
  ///
  /// In cs, this message translates to:
  /// **'Podepište se prstem nebo perem'**
  String get prijemPodpisHint;

  /// No description provided for @prijemPodpisNahled.
  ///
  /// In cs, this message translates to:
  /// **'Podpis zákazníka'**
  String get prijemPodpisNahled;

  /// No description provided for @prijemPodpisZahoditTitul.
  ///
  /// In cs, this message translates to:
  /// **'Zahodit podpis?'**
  String get prijemPodpisZahoditTitul;

  /// No description provided for @prijemPodpisZahoditPomoc.
  ///
  /// In cs, this message translates to:
  /// **'Máte rozepsaný podpis. Opravdu ho zahodit?'**
  String get prijemPodpisZahoditPomoc;

  /// No description provided for @prijemPodpisZahodit.
  ///
  /// In cs, this message translates to:
  /// **'Zahodit'**
  String get prijemPodpisZahodit;

  /// No description provided for @predaniTitul.
  ///
  /// In cs, this message translates to:
  /// **'Předání vozidla'**
  String get predaniTitul;

  /// No description provided for @predaniTlacitko.
  ///
  /// In cs, this message translates to:
  /// **'Předat zákazníkovi'**
  String get predaniTlacitko;

  /// No description provided for @predaniProvedenePrace.
  ///
  /// In cs, this message translates to:
  /// **'Provedené práce'**
  String get predaniProvedenePrace;

  /// No description provided for @predaniPridatPraci.
  ///
  /// In cs, this message translates to:
  /// **'Přidat práci'**
  String get predaniPridatPraci;

  /// No description provided for @predaniVybratZCeniku.
  ///
  /// In cs, this message translates to:
  /// **'Vybrat z ceníku'**
  String get predaniVybratZCeniku;

  /// No description provided for @predaniNazevPrace.
  ///
  /// In cs, this message translates to:
  /// **'Název práce'**
  String get predaniNazevPrace;

  /// No description provided for @predaniCena.
  ///
  /// In cs, this message translates to:
  /// **'Cena'**
  String get predaniCena;

  /// No description provided for @predaniCelkem.
  ///
  /// In cs, this message translates to:
  /// **'Celkem k úhradě'**
  String get predaniCelkem;

  /// No description provided for @predaniBezPrace.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné práce. Přidejte provedené úkony.'**
  String get predaniBezPrace;

  /// No description provided for @predaniPorovnani.
  ///
  /// In cs, this message translates to:
  /// **'Porovnání stavu'**
  String get predaniPorovnani;

  /// No description provided for @predaniPriPrijmu.
  ///
  /// In cs, this message translates to:
  /// **'Při příjmu'**
  String get predaniPriPrijmu;

  /// No description provided for @predaniPriPredani.
  ///
  /// In cs, this message translates to:
  /// **'Při předání'**
  String get predaniPriPredani;

  /// No description provided for @predaniTachometrPredani.
  ///
  /// In cs, this message translates to:
  /// **'Tachometr při předání (km)'**
  String get predaniTachometrPredani;

  /// No description provided for @predaniFoto.
  ///
  /// In cs, this message translates to:
  /// **'Foto při předání'**
  String get predaniFoto;

  /// No description provided for @predaniPridatFoto.
  ///
  /// In cs, this message translates to:
  /// **'Přidat foto'**
  String get predaniPridatFoto;

  /// No description provided for @predaniPodpisPrevzeti.
  ///
  /// In cs, this message translates to:
  /// **'Podpis převzetí'**
  String get predaniPodpisPrevzeti;

  /// No description provided for @predaniSouhlas.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník svým podpisem stvrzuje převzetí vozidla a souhlasí s provedenými pracemi i výší účtované částky.'**
  String get predaniSouhlas;

  /// No description provided for @predaniDokoncit.
  ///
  /// In cs, this message translates to:
  /// **'Dokončit předání'**
  String get predaniDokoncit;

  /// No description provided for @predaniHotovo.
  ///
  /// In cs, this message translates to:
  /// **'Vozidlo bylo předáno zákazníkovi.'**
  String get predaniHotovo;

  /// No description provided for @predaniChybaPodpis.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník musí připojit podpis převzetí.'**
  String get predaniChybaPodpis;

  /// No description provided for @predaniProbiha.
  ///
  /// In cs, this message translates to:
  /// **'Ukládám předání…'**
  String get predaniProbiha;

  /// No description provided for @prijemTabletPostup.
  ///
  /// In cs, this message translates to:
  /// **'POSTUP'**
  String get prijemTabletPostup;

  /// No description provided for @prijemTabletPosledniNavsteva.
  ///
  /// In cs, this message translates to:
  /// **'POSLEDNÍ NÁVŠTĚVA'**
  String get prijemTabletPosledniNavsteva;

  /// No description provided for @prijemTabletVozidlo.
  ///
  /// In cs, this message translates to:
  /// **'Vozidlo'**
  String get prijemTabletVozidlo;

  /// No description provided for @prijemTabletTacho.
  ///
  /// In cs, this message translates to:
  /// **'Tachometr'**
  String get prijemTabletTacho;

  /// No description provided for @prijemTabletStk.
  ///
  /// In cs, this message translates to:
  /// **'STK'**
  String get prijemTabletStk;

  /// No description provided for @prijemTabletNaposledy.
  ///
  /// In cs, this message translates to:
  /// **'Naposledy'**
  String get prijemTabletNaposledy;

  /// No description provided for @prijemTabletStav.
  ///
  /// In cs, this message translates to:
  /// **'Stav'**
  String get prijemTabletStav;

  /// No description provided for @prijemTabletStavPriPrijmu.
  ///
  /// In cs, this message translates to:
  /// **'Stav při příjmu'**
  String get prijemTabletStavPriPrijmu;

  /// No description provided for @prijemTabletPoskozeni.
  ///
  /// In cs, this message translates to:
  /// **'Poškození'**
  String get prijemTabletPoskozeni;

  /// No description provided for @prijemTabletNeuvedeno.
  ///
  /// In cs, this message translates to:
  /// **'Neuvedeno'**
  String get prijemTabletNeuvedeno;

  /// No description provided for @prijemTabletNahled.
  ///
  /// In cs, this message translates to:
  /// **'NÁHLED VOZIDLA'**
  String get prijemTabletNahled;

  /// No description provided for @prijemTabletSpz.
  ///
  /// In cs, this message translates to:
  /// **'SPZ'**
  String get prijemTabletSpz;

  /// No description provided for @prijemTabletVin.
  ///
  /// In cs, this message translates to:
  /// **'VIN'**
  String get prijemTabletVin;

  /// No description provided for @prijemTabletZakazka.
  ///
  /// In cs, this message translates to:
  /// **'Zakázka'**
  String get prijemTabletZakazka;

  /// No description provided for @prijemTabletUdajePlni.
  ///
  /// In cs, this message translates to:
  /// **'Údaje se plní průběžně při vyplňování formuláře.'**
  String get prijemTabletUdajePlni;

  /// No description provided for @prijemErrVinVyhledani.
  ///
  /// In cs, this message translates to:
  /// **'Zadejte alespoň část VIN pro vyhledání.'**
  String get prijemErrVinVyhledani;

  /// No description provided for @prijemErrServisId.
  ///
  /// In cs, this message translates to:
  /// **'Chyba: ID Servisu se nepodařilo načíst.'**
  String get prijemErrServisId;

  /// No description provided for @prijemErrZadneVozidloVin.
  ///
  /// In cs, this message translates to:
  /// **'Žádné vozidlo s tímto VIN nebylo nalezeno.'**
  String get prijemErrZadneVozidloVin;

  /// No description provided for @prijemErrSpzVyhledani.
  ///
  /// In cs, this message translates to:
  /// **'Zadejte alespoň část SPZ pro vyhledání.'**
  String get prijemErrSpzVyhledani;

  /// No description provided for @prijemErrZadneVozidloSpz.
  ///
  /// In cs, this message translates to:
  /// **'Žádné vozidlo s touto SPZ nebylo nalezeno.'**
  String get prijemErrZadneVozidloSpz;

  /// No description provided for @prijemErrZadejteVin.
  ///
  /// In cs, this message translates to:
  /// **'Zadejte VIN kód pro dekódování.'**
  String get prijemErrZadejteVin;

  /// No description provided for @prijemStkPlatnaSnackbar.
  ///
  /// In cs, this message translates to:
  /// **'STK platná do {datum}'**
  String prijemStkPlatnaSnackbar(String datum);

  /// No description provided for @prijemStkProslaSnackbar.
  ///
  /// In cs, this message translates to:
  /// **'STK prošlá! Platila do {datum}'**
  String prijemStkProslaSnackbar(String datum);

  /// No description provided for @prijemVincarioDoplneno.
  ///
  /// In cs, this message translates to:
  /// **'Údaje vozidla doplněny z Vincario.'**
  String get prijemVincarioDoplneno;

  /// No description provided for @prijemVozidloNacteno.
  ///
  /// In cs, this message translates to:
  /// **'Údaje o vozidle a zákazníkovi byly načteny.'**
  String get prijemVozidloNacteno;

  /// No description provided for @prijemNalezenoVice.
  ///
  /// In cs, this message translates to:
  /// **'Nalezeno více vozidel'**
  String get prijemNalezenoVice;

  /// No description provided for @prijemVyberVozidlo.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte konkrétní vozidlo ze seznamu:'**
  String get prijemVyberVozidlo;

  /// No description provided for @prijemNeznanaSpz.
  ///
  /// In cs, this message translates to:
  /// **'Neznámá SPZ'**
  String get prijemNeznanaSpz;

  /// No description provided for @prijemErrCisloASpz.
  ///
  /// In cs, this message translates to:
  /// **'Číslo záznamu a SPZ jsou povinné údaje!'**
  String get prijemErrCisloASpz;

  /// No description provided for @prijemErrCislo.
  ///
  /// In cs, this message translates to:
  /// **'Číslo záznamu je povinný údaj!'**
  String get prijemErrCislo;

  /// No description provided for @prijemErrSpz.
  ///
  /// In cs, this message translates to:
  /// **'SPZ vozidla je povinný údaj!'**
  String get prijemErrSpz;

  /// No description provided for @prijemErrCisloDuplicitni.
  ///
  /// In cs, this message translates to:
  /// **'Toto číslo záznamu již v databázi existuje! Zadejte prosím jiné.'**
  String get prijemErrCisloDuplicitni;

  /// No description provided for @prijemErrPodpis.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník musí připojit podpis před odesláním.'**
  String get prijemErrPodpis;

  /// No description provided for @prijemLimitTitle.
  ///
  /// In cs, this message translates to:
  /// **'Limit příjmů dosažen'**
  String get prijemLimitTitle;

  /// No description provided for @prijemLimitText.
  ///
  /// In cs, this message translates to:
  /// **'Váš plán {plan} umožňuje maximálně {limit} příjmů za měsíc. Pro více příjmů upgradujte plán.'**
  String prijemLimitText(String plan, int limit);

  /// No description provided for @prijemZavrit.
  ///
  /// In cs, this message translates to:
  /// **'Zavřít'**
  String get prijemZavrit;

  /// No description provided for @prijemUspesne.
  ///
  /// In cs, this message translates to:
  /// **'Zakázka úspěšně odeslána'**
  String get prijemUspesne;

  /// No description provided for @prijemErrNejstePrirazeni.
  ///
  /// In cs, this message translates to:
  /// **'Nejste přiřazeni k žádnému servisu!'**
  String get prijemErrNejstePrirazeni;

  /// No description provided for @prijemSkenJenApp.
  ///
  /// In cs, this message translates to:
  /// **'Skenování pomocí AI funguje pouze v nainstalované aplikaci (APK/iOS).'**
  String get prijemSkenJenApp;

  /// No description provided for @prijemNavigaceLabel.
  ///
  /// In cs, this message translates to:
  /// **'ZÁZNAM VOZIDLA'**
  String get prijemNavigaceLabel;

  /// No description provided for @prijemNovyZaznam.
  ///
  /// In cs, this message translates to:
  /// **'Nový záznam'**
  String get prijemNovyZaznam;

  /// No description provided for @prijemDokoncit.
  ///
  /// In cs, this message translates to:
  /// **'Dokončit a odeslat'**
  String get prijemDokoncit;

  /// No description provided for @prijemPokracovat.
  ///
  /// In cs, this message translates to:
  /// **'Pokračovat'**
  String get prijemPokracovat;

  /// No description provided for @prijemOdesilamMsg.
  ///
  /// In cs, this message translates to:
  /// **'Odesílám zakázku a protokol...'**
  String get prijemOdesilamMsg;

  /// No description provided for @prijemNahravamFotky.
  ///
  /// In cs, this message translates to:
  /// **'Nahrávám fotky {hotovo}/{celkem}'**
  String prijemNahravamFotky(int hotovo, int celkem);

  /// No description provided for @prijemKrokZ.
  ///
  /// In cs, this message translates to:
  /// **'Krok {krok} z {celkem}'**
  String prijemKrokZ(int krok, int celkem);

  /// No description provided for @prijemStepIdentifikace.
  ///
  /// In cs, this message translates to:
  /// **'Identifikace vozu'**
  String get prijemStepIdentifikace;

  /// No description provided for @prijemStepZakaznik.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník'**
  String get prijemStepZakaznik;

  /// No description provided for @prijemStepFoto.
  ///
  /// In cs, this message translates to:
  /// **'Fotodokumentace'**
  String get prijemStepFoto;

  /// No description provided for @prijemStepStav.
  ///
  /// In cs, this message translates to:
  /// **'Stav vozu'**
  String get prijemStepStav;

  /// No description provided for @prijemStepPrace.
  ///
  /// In cs, this message translates to:
  /// **'Úkony a práce'**
  String get prijemStepPrace;

  /// No description provided for @prijemStepSouhrn.
  ///
  /// In cs, this message translates to:
  /// **'Souhrn'**
  String get prijemStepSouhrn;

  /// No description provided for @prijemSkenNenalezeno.
  ///
  /// In cs, this message translates to:
  /// **'Naskenováno \'{co}\'. V databázi nenalezeno — údaje doplňte ručně.'**
  String prijemSkenNenalezeno(String co);

  /// No description provided for @vinSekceIdentifikace.
  ///
  /// In cs, this message translates to:
  /// **'IDENTIFIKACE'**
  String get vinSekceIdentifikace;

  /// No description provided for @vinSekceMotor.
  ///
  /// In cs, this message translates to:
  /// **'MOTOR A POHON'**
  String get vinSekceMotor;

  /// No description provided for @vinSekceKaroserie.
  ///
  /// In cs, this message translates to:
  /// **'KAROSERIE A ROZMĚRY'**
  String get vinSekceKaroserie;

  /// No description provided for @vinSekcePalivo.
  ///
  /// In cs, this message translates to:
  /// **'PALIVO A EMISE'**
  String get vinSekcePalivo;

  /// No description provided for @vinSekceOstatni.
  ///
  /// In cs, this message translates to:
  /// **'OSTATNÍ INFORMACE'**
  String get vinSekceOstatni;

  /// No description provided for @vinFieldZnacka.
  ///
  /// In cs, this message translates to:
  /// **'Značka'**
  String get vinFieldZnacka;

  /// No description provided for @vinFieldModel.
  ///
  /// In cs, this message translates to:
  /// **'Model'**
  String get vinFieldModel;

  /// No description provided for @vinFieldObchodniOznaceni.
  ///
  /// In cs, this message translates to:
  /// **'Obchodní označení'**
  String get vinFieldObchodniOznaceni;

  /// No description provided for @vinFieldRokVyroby.
  ///
  /// In cs, this message translates to:
  /// **'Rok výroby'**
  String get vinFieldRokVyroby;

  /// No description provided for @vinFieldKaroserie.
  ///
  /// In cs, this message translates to:
  /// **'Karosérie'**
  String get vinFieldKaroserie;

  /// No description provided for @vinFieldTypVarianta.
  ///
  /// In cs, this message translates to:
  /// **'Typ / varianta'**
  String get vinFieldTypVarianta;

  /// No description provided for @vinFieldMistoVyroby.
  ///
  /// In cs, this message translates to:
  /// **'Místo výroby'**
  String get vinFieldMistoVyroby;

  /// No description provided for @vinFieldMotorizace.
  ///
  /// In cs, this message translates to:
  /// **'Motorizace'**
  String get vinFieldMotorizace;

  /// No description provided for @vinFieldTypMotoru.
  ///
  /// In cs, this message translates to:
  /// **'Typ motoru'**
  String get vinFieldTypMotoru;

  /// No description provided for @vinFieldZdvihObjem.
  ///
  /// In cs, this message translates to:
  /// **'Zdvihový objem'**
  String get vinFieldZdvihObjem;

  /// No description provided for @vinFieldPocetValcu.
  ///
  /// In cs, this message translates to:
  /// **'Počet válců'**
  String get vinFieldPocetValcu;

  /// No description provided for @vinFieldVykon.
  ///
  /// In cs, this message translates to:
  /// **'Výkon'**
  String get vinFieldVykon;

  /// No description provided for @vinFieldTocivyMoment.
  ///
  /// In cs, this message translates to:
  /// **'Max. točivý moment'**
  String get vinFieldTocivyMoment;

  /// No description provided for @vinFieldPalivo.
  ///
  /// In cs, this message translates to:
  /// **'Palivo'**
  String get vinFieldPalivo;

  /// No description provided for @vinFieldPrevodovka.
  ///
  /// In cs, this message translates to:
  /// **'Převodovka'**
  String get vinFieldPrevodovka;

  /// No description provided for @vinFieldPocetPrevodu.
  ///
  /// In cs, this message translates to:
  /// **'Počet převodů'**
  String get vinFieldPocetPrevodu;

  /// No description provided for @vinFieldPohon.
  ///
  /// In cs, this message translates to:
  /// **'Pohon'**
  String get vinFieldPohon;

  /// No description provided for @vinFieldMaxRychlost.
  ///
  /// In cs, this message translates to:
  /// **'Max. rychlost'**
  String get vinFieldMaxRychlost;

  /// No description provided for @vinFieldTypKaroserie.
  ///
  /// In cs, this message translates to:
  /// **'Typ karosérie'**
  String get vinFieldTypKaroserie;

  /// No description provided for @vinFieldPocetDveri.
  ///
  /// In cs, this message translates to:
  /// **'Počet dveří'**
  String get vinFieldPocetDveri;

  /// No description provided for @vinFieldPocetMist.
  ///
  /// In cs, this message translates to:
  /// **'Počet míst'**
  String get vinFieldPocetMist;

  /// No description provided for @vinFieldProvozniHmotnost.
  ///
  /// In cs, this message translates to:
  /// **'Provozní hmotnost'**
  String get vinFieldProvozniHmotnost;

  /// No description provided for @vinFieldMaxHmotnost.
  ///
  /// In cs, this message translates to:
  /// **'Max. hmotnost'**
  String get vinFieldMaxHmotnost;

  /// No description provided for @vinFieldTaznaHmotnost.
  ///
  /// In cs, this message translates to:
  /// **'Tažná hmotnost'**
  String get vinFieldTaznaHmotnost;

  /// No description provided for @vinFieldRozvorNaprav.
  ///
  /// In cs, this message translates to:
  /// **'Rozvor náprav'**
  String get vinFieldRozvorNaprav;

  /// No description provided for @vinFieldDelka.
  ///
  /// In cs, this message translates to:
  /// **'Délka'**
  String get vinFieldDelka;

  /// No description provided for @vinFieldSirka.
  ///
  /// In cs, this message translates to:
  /// **'Šířka'**
  String get vinFieldSirka;

  /// No description provided for @vinFieldVyska.
  ///
  /// In cs, this message translates to:
  /// **'Výška'**
  String get vinFieldVyska;

  /// No description provided for @vinFieldObjemNadrze.
  ///
  /// In cs, this message translates to:
  /// **'Objem nádrže'**
  String get vinFieldObjemNadrze;

  /// No description provided for @vinField1Registrace.
  ///
  /// In cs, this message translates to:
  /// **'1. registrace'**
  String get vinField1Registrace;

  /// No description provided for @vinFieldEmisniNorma.
  ///
  /// In cs, this message translates to:
  /// **'Emisní norma'**
  String get vinFieldEmisniNorma;

  /// No description provided for @vinFieldEmiseCo2.
  ///
  /// In cs, this message translates to:
  /// **'Emise CO₂'**
  String get vinFieldEmiseCo2;

  /// No description provided for @vinFieldSpotrebaKomb.
  ///
  /// In cs, this message translates to:
  /// **'Spotřeba (komb.)'**
  String get vinFieldSpotrebaKomb;

  /// No description provided for @vinFieldSpotrebaMesto.
  ///
  /// In cs, this message translates to:
  /// **'Spotřeba ve městě'**
  String get vinFieldSpotrebaMesto;

  /// No description provided for @vinFieldSpotrebaDalnice.
  ///
  /// In cs, this message translates to:
  /// **'Spotřeba mimo město'**
  String get vinFieldSpotrebaDalnice;

  /// No description provided for @vinFieldElektDojezd.
  ///
  /// In cs, this message translates to:
  /// **'Elektrický dojezd'**
  String get vinFieldElektDojezd;

  /// No description provided for @vinLimitDekodovani.
  ///
  /// In cs, this message translates to:
  /// **'Dosáhli jste měsíčního limitu {pocet} / {limit} dekódování. Upgradujte plán pro pokračování.'**
  String vinLimitDekodovani(int pocet, int limit);

  /// No description provided for @vinLimitValue.
  ///
  /// In cs, this message translates to:
  /// **'Dosáhli jste měsíčního limitu {pocet} / {limit} zjištění.'**
  String vinLimitValue(int pocet, int limit);

  /// No description provided for @vinTrzniChybaVerze.
  ///
  /// In cs, this message translates to:
  /// **'Zjištění tržní hodnoty není součástí zkušební verze — odemknete ho v některém z placených plánů.'**
  String get vinTrzniChybaVerze;

  /// No description provided for @vinChybaHistorie.
  ///
  /// In cs, this message translates to:
  /// **'Nepodařilo se načíst historii.'**
  String get vinChybaHistorie;

  /// No description provided for @vinTotoVozidloNebyloDekodovano.
  ///
  /// In cs, this message translates to:
  /// **'Toto vozidlo nebylo dříve dekódováno.'**
  String get vinTotoVozidloNebyloDekodovano;

  /// No description provided for @vinPraveTed.
  ///
  /// In cs, this message translates to:
  /// **'Právě teď'**
  String get vinPraveTed;

  /// No description provided for @vinPredMinutami.
  ///
  /// In cs, this message translates to:
  /// **'před {pocet} min'**
  String vinPredMinutami(int pocet);

  /// No description provided for @vinVincarioKlice.
  ///
  /// In cs, this message translates to:
  /// **'Vincario API klíče nejsou nastaveny. Doplňte je v Nastavení servisu, aby dekódování fungovalo.'**
  String get vinVincarioKlice;

  /// No description provided for @vinTrzniOd.
  ///
  /// In cs, this message translates to:
  /// **'od {value} {mena}'**
  String vinTrzniOd(String value, String mena);

  /// No description provided for @vinTrzniDo.
  ///
  /// In cs, this message translates to:
  /// **'do {value} {mena}'**
  String vinTrzniDo(String value, String mena);

  /// No description provided for @vinTrzniHodnotaTitle.
  ///
  /// In cs, this message translates to:
  /// **'Tržní hodnota'**
  String get vinTrzniHodnotaTitle;

  /// No description provided for @vinStkTitle.
  ///
  /// In cs, this message translates to:
  /// **'Zjištění STK'**
  String get vinStkTitle;

  /// No description provided for @vinTrzniSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Odhad tržní ceny vozidla z dat evropského trhu'**
  String get vinTrzniSubtitle;

  /// No description provided for @vinStkSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Přehled technických prohlídek vozidla z registru'**
  String get vinStkSubtitle;

  /// No description provided for @vinSkenTitleVin.
  ///
  /// In cs, this message translates to:
  /// **'Skenovat VIN kód'**
  String get vinSkenTitleVin;

  /// No description provided for @vinSkenTitleTrzni.
  ///
  /// In cs, this message translates to:
  /// **'Skenovat VIN pro tržní hodnotu'**
  String get vinSkenTitleTrzni;

  /// No description provided for @vinSkenTitleStk.
  ///
  /// In cs, this message translates to:
  /// **'Skenovat VIN pro STK'**
  String get vinSkenTitleStk;

  /// No description provided for @vinSkenPopisVin.
  ///
  /// In cs, this message translates to:
  /// **'Automaticky načte specifikace vozu podle naskenovaného nebo zadaného VIN'**
  String get vinSkenPopisVin;

  /// No description provided for @vinSkenPopisTrzni.
  ///
  /// In cs, this message translates to:
  /// **'Zjistí odhad tržní ceny vozu podle naskenovaného nebo zadaného VIN z dat evropského trhu'**
  String get vinSkenPopisTrzni;

  /// No description provided for @vinSkenPopisStk.
  ///
  /// In cs, this message translates to:
  /// **'Načte data o technických prohlídkách vozidla z registru'**
  String get vinSkenPopisStk;

  /// No description provided for @vinSkenTlacitko.
  ///
  /// In cs, this message translates to:
  /// **'Spustit sken'**
  String get vinSkenTlacitko;

  /// No description provided for @vinInputHint.
  ///
  /// In cs, this message translates to:
  /// **'Zadat VIN ručně (např. TMBJJ7NE5K…)'**
  String get vinInputHint;

  /// No description provided for @vinTooltipHodnota.
  ///
  /// In cs, this message translates to:
  /// **'Zjistit hodnotu'**
  String get vinTooltipHodnota;

  /// No description provided for @vinTooltipStk.
  ///
  /// In cs, this message translates to:
  /// **'Zjistit STK'**
  String get vinTooltipStk;

  /// No description provided for @vinTooltipDekodovat.
  ///
  /// In cs, this message translates to:
  /// **'Dekódovat'**
  String get vinTooltipDekodovat;

  /// No description provided for @vinUpsellTitle.
  ///
  /// In cs, this message translates to:
  /// **'Tržní hodnota je v placených plánech'**
  String get vinUpsellTitle;

  /// No description provided for @vinUpsellSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Ve zkušební verzi není dostupná. Odemknete ji už v plánu Basic.'**
  String get vinUpsellSubtitle;

  /// No description provided for @vinUpsellPlany.
  ///
  /// In cs, this message translates to:
  /// **'Plány'**
  String get vinUpsellPlany;

  /// No description provided for @vinLimitTrzniMesic.
  ///
  /// In cs, this message translates to:
  /// **'Tržní hodnota tento měsíc'**
  String get vinLimitTrzniMesic;

  /// No description provided for @vinLimitDekodovaniMesic.
  ///
  /// In cs, this message translates to:
  /// **'Dekódování VIN tento měsíc'**
  String get vinLimitDekodovaniMesic;

  /// No description provided for @vinLimitVycerpan.
  ///
  /// In cs, this message translates to:
  /// **'Měsíční limit vyčerpán. Upgradujte plán pro pokračování.'**
  String get vinLimitVycerpan;

  /// No description provided for @vinStkInfoBanner.
  ///
  /// In cs, this message translates to:
  /// **'Data pocházejí z veřejného registru vozidel. Dostupnost a aktuálnost se liší — u některých vozidel nemusí být STK evidována.'**
  String get vinStkInfoBanner;

  /// No description provided for @vinChybaDekodovani.
  ///
  /// In cs, this message translates to:
  /// **'Nepodařilo se dekódovat VIN: {chyba}'**
  String vinChybaDekodovani(String chyba);

  /// No description provided for @vinNovySken.
  ///
  /// In cs, this message translates to:
  /// **'Nový sken'**
  String get vinNovySken;

  /// No description provided for @vinTrzniHodnotaHeader.
  ///
  /// In cs, this message translates to:
  /// **'TRŽNÍ HODNOTA'**
  String get vinTrzniHodnotaHeader;

  /// No description provided for @vinStkPlatnostNeznama.
  ///
  /// In cs, this message translates to:
  /// **'STK — datum neznámé'**
  String get vinStkPlatnostNeznama;

  /// No description provided for @vinStkPlatnaJesteXDni.
  ///
  /// In cs, this message translates to:
  /// **'STK platná ještě {dnu} dní'**
  String vinStkPlatnaJesteXDni(int dnu);

  /// No description provided for @vinStkNeplatna.
  ///
  /// In cs, this message translates to:
  /// **'STK neplatná (prošlá o {dnu} dní)'**
  String vinStkNeplatna(int dnu);

  /// No description provided for @vinStkPlatnostDo.
  ///
  /// In cs, this message translates to:
  /// **'Platnost STK do'**
  String get vinStkPlatnostDo;

  /// No description provided for @vinTrzniDataNedostupna.
  ///
  /// In cs, this message translates to:
  /// **'Evropská data nejsou k dispozici.'**
  String get vinTrzniDataNedostupna;

  /// No description provided for @vinTrzniMedian.
  ///
  /// In cs, this message translates to:
  /// **'medián'**
  String get vinTrzniMedian;

  /// No description provided for @vinTrzniPrumernaCena.
  ///
  /// In cs, this message translates to:
  /// **'Průměrná cena'**
  String get vinTrzniPrumernaCena;

  /// No description provided for @vinTrzniPrumernyNajezd.
  ///
  /// In cs, this message translates to:
  /// **'Průměrný nájezd'**
  String get vinTrzniPrumernyNajezd;

  /// No description provided for @vinTrzniPocetVzorku.
  ///
  /// In cs, this message translates to:
  /// **'Počet vzorků'**
  String get vinTrzniPocetVzorku;

  /// No description provided for @vinTrzniObdobiDat.
  ///
  /// In cs, this message translates to:
  /// **'Období dat'**
  String get vinTrzniObdobiDat;

  /// No description provided for @vinTrzniZdroj.
  ///
  /// In cs, this message translates to:
  /// **'Evropský trh · Vincario Market Value'**
  String get vinTrzniZdroj;

  /// No description provided for @vinTrzniNajezdLabel.
  ///
  /// In cs, this message translates to:
  /// **'Najeté km vozidla'**
  String get vinTrzniNajezdLabel;

  /// No description provided for @vinTrzniOdhad.
  ///
  /// In cs, this message translates to:
  /// **'Odhad podle nájezdu'**
  String get vinTrzniOdhad;

  /// No description provided for @vinTrzniOdhadVysvetleni.
  ///
  /// In cs, this message translates to:
  /// **'Orientační odhad zůstatkové hodnoty vypočtený z rozsahu cen a nájezdů ve vzorku.'**
  String get vinTrzniOdhadVysvetleni;

  /// No description provided for @vinHistorieNadpis.
  ///
  /// In cs, this message translates to:
  /// **'Historie skenů'**
  String get vinHistorieNadpis;

  /// No description provided for @vinHistorieDnes.
  ///
  /// In cs, this message translates to:
  /// **'Dnes · {pocet} dekódovaných VIN'**
  String vinHistorieDnes(int pocet);

  /// No description provided for @vinHistoriePosledni.
  ///
  /// In cs, this message translates to:
  /// **'Poslední skeny'**
  String get vinHistoriePosledni;

  /// No description provided for @vinHistorieVse.
  ///
  /// In cs, this message translates to:
  /// **'Vše'**
  String get vinHistorieVse;

  /// No description provided for @vinHistorieNacitani.
  ///
  /// In cs, this message translates to:
  /// **'Načítání…'**
  String get vinHistorieNacitani;

  /// No description provided for @vinHistorieZadneSkeny.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné skeny.'**
  String get vinHistorieZadneSkeny;

  /// No description provided for @vinHistorieNoveVozidlo.
  ///
  /// In cs, this message translates to:
  /// **'Nové vozidlo'**
  String get vinHistorieNoveVozidlo;

  /// No description provided for @vinHistoriePoprve.
  ///
  /// In cs, this message translates to:
  /// **'Poprvé dekódováno'**
  String get vinHistoriePoprve;

  /// No description provided for @vinHistorieDekodovanoX.
  ///
  /// In cs, this message translates to:
  /// **'Dekódováno {pocet}×'**
  String vinHistorieDekodovanoX(int pocet);

  /// No description provided for @vinHistorieNezname.
  ///
  /// In cs, this message translates to:
  /// **'Neznámé vozidlo'**
  String get vinHistorieNezname;

  /// No description provided for @vinZadejteVin.
  ///
  /// In cs, this message translates to:
  /// **'Zadejte VIN kód.'**
  String get vinZadejteVin;

  /// No description provided for @vinSkenJenApk.
  ///
  /// In cs, this message translates to:
  /// **'Skenování funguje pouze v nainstalované aplikaci (APK/iOS).'**
  String get vinSkenJenApk;

  /// No description provided for @vinFieldKodMotoru.
  ///
  /// In cs, this message translates to:
  /// **'Kód motoru'**
  String get vinFieldKodMotoru;

  /// No description provided for @zakZakaznici.
  ///
  /// In cs, this message translates to:
  /// **'Zákazníci'**
  String get zakZakaznici;

  /// No description provided for @zakSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Adresář vašich klientů a jejich vozidel.'**
  String get zakSubtitle;

  /// No description provided for @zakHledatHint.
  ///
  /// In cs, this message translates to:
  /// **'Hledat jméno, telefon nebo IČO...'**
  String get zakHledatHint;

  /// No description provided for @zakChybaDb.
  ///
  /// In cs, this message translates to:
  /// **'Chyba databáze: {chyba}'**
  String zakChybaDb(String chyba);

  /// No description provided for @zakZadniZakaznici.
  ///
  /// In cs, this message translates to:
  /// **'Zatím nemáte žádné zákazníky.'**
  String get zakZadniZakaznici;

  /// No description provided for @zakIcoZnak.
  ///
  /// In cs, this message translates to:
  /// **'🏢 IČO: {ico}'**
  String zakIcoZnak(String ico);

  /// No description provided for @zakEditTitle.
  ///
  /// In cs, this message translates to:
  /// **'Úprava zákazníka'**
  String get zakEditTitle;

  /// No description provided for @zakJmenoLabel.
  ///
  /// In cs, this message translates to:
  /// **'Jméno a Příjmení / Název firmy'**
  String get zakJmenoLabel;

  /// No description provided for @zakTelLabel.
  ///
  /// In cs, this message translates to:
  /// **'Telefon'**
  String get zakTelLabel;

  /// No description provided for @zakVybertePredvolbu.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte předvolbu'**
  String get zakVybertePredvolbu;

  /// No description provided for @zakCisloLabel.
  ///
  /// In cs, this message translates to:
  /// **'Číslo'**
  String get zakCisloLabel;

  /// No description provided for @zakEmailLabel.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get zakEmailLabel;

  /// No description provided for @zakAdresaLabel.
  ///
  /// In cs, this message translates to:
  /// **'Adresa'**
  String get zakAdresaLabel;

  /// No description provided for @zakIcoLabel.
  ///
  /// In cs, this message translates to:
  /// **'IČO'**
  String get zakIcoLabel;

  /// No description provided for @zakDicLabel.
  ///
  /// In cs, this message translates to:
  /// **'DIČ'**
  String get zakDicLabel;

  /// No description provided for @zakUlozitZmeny.
  ///
  /// In cs, this message translates to:
  /// **'ULOŽIT ZMĚNY'**
  String get zakUlozitZmeny;

  /// No description provided for @zakZpracovavam.
  ///
  /// In cs, this message translates to:
  /// **'Zpracovávám data...'**
  String get zakZpracovavam;

  /// No description provided for @zakKartaZakaznika.
  ///
  /// In cs, this message translates to:
  /// **'Karta zákazníka'**
  String get zakKartaZakaznika;

  /// No description provided for @zakHeaderLabel.
  ///
  /// In cs, this message translates to:
  /// **'ZÁKAZNÍK'**
  String get zakHeaderLabel;

  /// No description provided for @zakTabInfo.
  ///
  /// In cs, this message translates to:
  /// **'Info'**
  String get zakTabInfo;

  /// No description provided for @zakTabZaznamy.
  ///
  /// In cs, this message translates to:
  /// **'Záznamy'**
  String get zakTabZaznamy;

  /// No description provided for @zakSmazatMenu.
  ///
  /// In cs, this message translates to:
  /// **'Smazat zákazníka'**
  String get zakSmazatMenu;

  /// No description provided for @zakSmazatTitle.
  ///
  /// In cs, this message translates to:
  /// **'Smazat zákazníka?'**
  String get zakSmazatTitle;

  /// No description provided for @zakSmazatContent.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník bude odebrán z adresáře. Jeho vozidla a historie zakázek zůstanou zachovány.'**
  String get zakSmazatContent;

  /// No description provided for @zakZrusit.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit'**
  String get zakZrusit;

  /// No description provided for @zakSmazatPotvrdit.
  ///
  /// In cs, this message translates to:
  /// **'Smazat'**
  String get zakSmazatPotvrdit;

  /// No description provided for @zakSmazanUspesne.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník byl smazán.'**
  String get zakSmazanUspesne;

  /// No description provided for @zakChybaMazani.
  ///
  /// In cs, this message translates to:
  /// **'Chyba při mazání: {chyba}'**
  String zakChybaMazani(String chyba);

  /// No description provided for @zakNeznamyZakaznik.
  ///
  /// In cs, this message translates to:
  /// **'Neznámý zákazník'**
  String get zakNeznamyZakaznik;

  /// No description provided for @zakFirma.
  ///
  /// In cs, this message translates to:
  /// **'Firma'**
  String get zakFirma;

  /// No description provided for @zakSoukromaOsoba.
  ///
  /// In cs, this message translates to:
  /// **'Soukromá osoba'**
  String get zakSoukromaOsoba;

  /// No description provided for @zakStatVozidel.
  ///
  /// In cs, this message translates to:
  /// **'VOZIDEL'**
  String get zakStatVozidel;

  /// No description provided for @zakStatPrijmu.
  ///
  /// In cs, this message translates to:
  /// **'PŘÍJMŮ'**
  String get zakStatPrijmu;

  /// No description provided for @zakVolat.
  ///
  /// In cs, this message translates to:
  /// **'Volat'**
  String get zakVolat;

  /// No description provided for @zakSms.
  ///
  /// In cs, this message translates to:
  /// **'SMS'**
  String get zakSms;

  /// No description provided for @zakKontaktniUdaje.
  ///
  /// In cs, this message translates to:
  /// **'Kontaktní údaje'**
  String get zakKontaktniUdaje;

  /// No description provided for @zakVozidlaTitle.
  ///
  /// In cs, this message translates to:
  /// **'Vozidla zákazníka'**
  String get zakVozidlaTitle;

  /// No description provided for @zakPridat.
  ///
  /// In cs, this message translates to:
  /// **'Přidat'**
  String get zakPridat;

  /// No description provided for @zakZadnaVozidla.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník nemá uložená žádná vozidla.'**
  String get zakZadnaVozidla;

  /// No description provided for @zakBezSpz.
  ///
  /// In cs, this message translates to:
  /// **'Bez SPZ'**
  String get zakBezSpz;

  /// No description provided for @zakZadneZaznamy.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník zatím nemá žádné záznamy o příjmu.'**
  String get zakZadneZaznamy;

  /// No description provided for @zakZakazka.
  ///
  /// In cs, this message translates to:
  /// **'Zakázka {cislo}'**
  String zakZakazka(Object cislo);

  /// No description provided for @zakPoskozeni.
  ///
  /// In cs, this message translates to:
  /// **'Poškození: {seznam}'**
  String zakPoskozeni(String seznam);

  /// No description provided for @zakPodepsano.
  ///
  /// In cs, this message translates to:
  /// **'Podepsáno'**
  String get zakPodepsano;

  /// No description provided for @zakFotoKs.
  ///
  /// In cs, this message translates to:
  /// **'{pocet} foto'**
  String zakFotoKs(int pocet);

  /// No description provided for @authBiometricReason.
  ///
  /// In cs, this message translates to:
  /// **'Přihlaste se do Torkis'**
  String get authBiometricReason;

  /// No description provided for @authBiometricChybaStorage.
  ///
  /// In cs, this message translates to:
  /// **'Nejprve se přihlaste heslem — Face ID se aktivuje pro příští spuštění.'**
  String get authBiometricChybaStorage;

  /// No description provided for @authBiometricChybaUdaje.
  ///
  /// In cs, this message translates to:
  /// **'Uložené přihlašovací údaje jsou neplatné. Přihlaste se heslem.'**
  String get authBiometricChybaUdaje;

  /// No description provided for @authChybaPrazdnaPola.
  ///
  /// In cs, this message translates to:
  /// **'Zadejte prosím e-mail i heslo.'**
  String get authChybaPrazdnaPola;

  /// No description provided for @authChybaHeslaNeshoda.
  ///
  /// In cs, this message translates to:
  /// **'Zadaná hesla se neshodují.'**
  String get authChybaHeslaNeshoda;

  /// No description provided for @authChybaOverovani.
  ///
  /// In cs, this message translates to:
  /// **'Došlo k chybě při ověřování.'**
  String get authChybaOverovani;

  /// No description provided for @authChybaNeplatneUdaje.
  ///
  /// In cs, this message translates to:
  /// **'Nesprávný e-mail nebo heslo.'**
  String get authChybaNeplatneUdaje;

  /// No description provided for @authChybaEmailExistuje.
  ///
  /// In cs, this message translates to:
  /// **'Tento e-mail je již zaregistrován.'**
  String get authChybaEmailExistuje;

  /// No description provided for @authChybaSlabeHeslo.
  ///
  /// In cs, this message translates to:
  /// **'Heslo je příliš slabé (min. 6 znaků).'**
  String get authChybaSlabeHeslo;

  /// No description provided for @authChybaFormatEmail.
  ///
  /// In cs, this message translates to:
  /// **'Neplatný formát e-mailu.'**
  String get authChybaFormatEmail;

  /// No description provided for @authChybaNeocekvana.
  ///
  /// In cs, this message translates to:
  /// **'Neočekávaná chyba: {chyba}'**
  String authChybaNeocekvana(String chyba);

  /// No description provided for @authResetHint.
  ///
  /// In cs, this message translates to:
  /// **'Pro obnovu hesla zadejte platný e-mail do horního políčka.'**
  String get authResetHint;

  /// No description provided for @authResetOdeslan.
  ///
  /// In cs, this message translates to:
  /// **'E-mail pro obnovu hesla byl odeslán.'**
  String get authResetOdeslan;

  /// No description provided for @authResetChyba.
  ///
  /// In cs, this message translates to:
  /// **'Chyba při odesílání e-mailu pro obnovu.'**
  String get authResetChyba;

  /// No description provided for @authSubtitleLogin.
  ///
  /// In cs, this message translates to:
  /// **'Digitální evidence vozidel'**
  String get authSubtitleLogin;

  /// No description provided for @authSubtitleRegister.
  ///
  /// In cs, this message translates to:
  /// **'Zaregistrujte svůj servis'**
  String get authSubtitleRegister;

  /// No description provided for @authEmailHint.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get authEmailHint;

  /// No description provided for @authHesloHint.
  ///
  /// In cs, this message translates to:
  /// **'Heslo'**
  String get authHesloHint;

  /// No description provided for @authPotvrzeniHeslaHint.
  ///
  /// In cs, this message translates to:
  /// **'Potvrzení hesla'**
  String get authPotvrzeniHeslaHint;

  /// No description provided for @authZapomenuteHeslo.
  ///
  /// In cs, this message translates to:
  /// **'Zapomněli jste heslo?'**
  String get authZapomenuteHeslo;

  /// No description provided for @authPrihlasitSe.
  ///
  /// In cs, this message translates to:
  /// **'Přihlásit se'**
  String get authPrihlasitSe;

  /// No description provided for @authVytvoritUcet.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořit účet'**
  String get authVytvoritUcet;

  /// No description provided for @authBiometrickePrihlaseni.
  ///
  /// In cs, this message translates to:
  /// **'Přihlásit se biometricky'**
  String get authBiometrickePrihlaseni;

  /// No description provided for @authNebo.
  ///
  /// In cs, this message translates to:
  /// **'nebo'**
  String get authNebo;

  /// No description provided for @authGoogleBtn.
  ///
  /// In cs, this message translates to:
  /// **'Pokračovat přes Google'**
  String get authGoogleBtn;

  /// No description provided for @authAppleBtn.
  ///
  /// In cs, this message translates to:
  /// **'Pokračovat přes Apple'**
  String get authAppleBtn;

  /// No description provided for @authNematUcet.
  ///
  /// In cs, this message translates to:
  /// **'Nemáte účet?'**
  String get authNematUcet;

  /// No description provided for @authZaregistrujteSe.
  ///
  /// In cs, this message translates to:
  /// **'Zaregistrujte se'**
  String get authZaregistrujteSe;

  /// No description provided for @authMateUcet.
  ///
  /// In cs, this message translates to:
  /// **'Již máte účet?'**
  String get authMateUcet;

  /// No description provided for @authPrihlasteSe.
  ///
  /// In cs, this message translates to:
  /// **'Přihlaste se'**
  String get authPrihlasteSe;

  /// No description provided for @predChybaNakup.
  ///
  /// In cs, this message translates to:
  /// **'Nákup se nepodařil: {chyba}'**
  String predChybaNakup(String chyba);

  /// No description provided for @predChybaEmailKlient.
  ///
  /// In cs, this message translates to:
  /// **'Nepodařilo se otevřít e-mailového klienta.'**
  String get predChybaEmailKlient;

  /// No description provided for @predTitle.
  ///
  /// In cs, this message translates to:
  /// **'Vaše předplatné'**
  String get predTitle;

  /// No description provided for @predSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Spravujte plán svého servisu a podle potřeby ho upgradujte.'**
  String get predSubtitle;

  /// No description provided for @predTrialBannerTitle.
  ///
  /// In cs, this message translates to:
  /// **'Aktivní zkušební doba'**
  String get predTrialBannerTitle;

  /// No description provided for @predAktivniPlanTitle.
  ///
  /// In cs, this message translates to:
  /// **'Aktivní plán: {plan}'**
  String predAktivniPlanTitle(String plan);

  /// No description provided for @predTrialBannerSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Po skončení trialu si vyberete plán, který vám sedne.'**
  String get predTrialBannerSubtitle;

  /// No description provided for @predAktivniPlanSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Děkujeme, že používáte TORKIS.'**
  String get predAktivniPlanSubtitle;

  /// No description provided for @predMesicne.
  ///
  /// In cs, this message translates to:
  /// **'Měsíčně'**
  String get predMesicne;

  /// No description provided for @predRocne.
  ///
  /// In cs, this message translates to:
  /// **'Ročně'**
  String get predRocne;

  /// No description provided for @predFootnote.
  ///
  /// In cs, this message translates to:
  /// **'Bez závazku · Zrušení kdykoli · Ceny bez DPH'**
  String get predFootnote;

  /// No description provided for @predBasicDesc.
  ///
  /// In cs, this message translates to:
  /// **'Pro malé autoservisy a OSVČ.'**
  String get predBasicDesc;

  /// No description provided for @predStandardDesc.
  ///
  /// In cs, this message translates to:
  /// **'Pro střední servisy do 150 zakázek měsíčně.'**
  String get predStandardDesc;

  /// No description provided for @predProDesc.
  ///
  /// In cs, this message translates to:
  /// **'Pro velké servisy a sítě bez limitu záznamů.'**
  String get predProDesc;

  /// No description provided for @predCustomDesc.
  ///
  /// In cs, this message translates to:
  /// **'Individuální úprava pro speciální požadavky a integrace.'**
  String get predCustomDesc;

  /// No description provided for @predFeat50Zaznamu.
  ///
  /// In cs, this message translates to:
  /// **'50 záznamů/měsíc'**
  String get predFeat50Zaznamu;

  /// No description provided for @predFeat3Uziv.
  ///
  /// In cs, this message translates to:
  /// **'3 uživatelé max.'**
  String get predFeat3Uziv;

  /// No description provided for @predFeat30Vin.
  ///
  /// In cs, this message translates to:
  /// **'30 dekodovaných VIN měsíčně'**
  String get predFeat30Vin;

  /// No description provided for @predFeat1TrzniHodnota.
  ///
  /// In cs, this message translates to:
  /// **'1 zjištění tržní hodnoty měsíčně'**
  String get predFeat1TrzniHodnota;

  /// No description provided for @predFeatNeomezStk.
  ///
  /// In cs, this message translates to:
  /// **'Neomezený počet zjištění platnosti STK'**
  String get predFeatNeomezStk;

  /// No description provided for @predFeatFotodok.
  ///
  /// In cs, this message translates to:
  /// **'Fotodokumentace'**
  String get predFeatFotodok;

  /// No description provided for @predFeatEvidZak.
  ///
  /// In cs, this message translates to:
  /// **'Evidence zákazníků a vozidel'**
  String get predFeatEvidZak;

  /// No description provided for @predFeatHistorie.
  ///
  /// In cs, this message translates to:
  /// **'Historie záznamů'**
  String get predFeatHistorie;

  /// No description provided for @predFeatSpravaTymu.
  ///
  /// In cs, this message translates to:
  /// **'Správa týmu'**
  String get predFeatSpravaTymu;

  /// No description provided for @predFeat150Zaznamu.
  ///
  /// In cs, this message translates to:
  /// **'150 záznamů/měsíc'**
  String get predFeat150Zaznamu;

  /// No description provided for @predFeat10Uziv.
  ///
  /// In cs, this message translates to:
  /// **'10 uživatelů max.'**
  String get predFeat10Uziv;

  /// No description provided for @predFeat60Vin.
  ///
  /// In cs, this message translates to:
  /// **'60 dekodovaných VIN měsíčně'**
  String get predFeat60Vin;

  /// No description provided for @predFeat120Vin.
  ///
  /// In cs, this message translates to:
  /// **'120 dekodovaných VIN měsíčně'**
  String get predFeat120Vin;

  /// No description provided for @predFeat75Vin.
  ///
  /// In cs, this message translates to:
  /// **'75 dekodovaných VIN měsíčně'**
  String get predFeat75Vin;

  /// No description provided for @predFeat3TrzniHodnota.
  ///
  /// In cs, this message translates to:
  /// **'3 zjištění tržní hodnoty měsíčně'**
  String get predFeat3TrzniHodnota;

  /// No description provided for @predFeatVseBasic.
  ///
  /// In cs, this message translates to:
  /// **'Vše z Basic'**
  String get predFeatVseBasic;

  /// No description provided for @predFeatReporty.
  ///
  /// In cs, this message translates to:
  /// **'Reporty a statistiky'**
  String get predFeatReporty;

  /// No description provided for @predFeatChat.
  ///
  /// In cs, this message translates to:
  /// **'Chat se zákazníkem'**
  String get predFeatChat;

  /// No description provided for @predFeatWebPortal.
  ///
  /// In cs, this message translates to:
  /// **'Webový portál pro správu vozidel a zákazníků'**
  String get predFeatWebPortal;

  /// No description provided for @predFeatNeomezZaznamu.
  ///
  /// In cs, this message translates to:
  /// **'Neomezené záznamy'**
  String get predFeatNeomezZaznamu;

  /// No description provided for @predFeatNeomezUziv.
  ///
  /// In cs, this message translates to:
  /// **'Neomezený počet uživatelů'**
  String get predFeatNeomezUziv;

  /// No description provided for @predFeatVseStandard.
  ///
  /// In cs, this message translates to:
  /// **'Vše ze Standard'**
  String get predFeatVseStandard;

  /// No description provided for @predFeat150Vin.
  ///
  /// In cs, this message translates to:
  /// **'150 dekodovaných VIN měsíčně'**
  String get predFeat150Vin;

  /// No description provided for @predFeat5TrzniHodnota.
  ///
  /// In cs, this message translates to:
  /// **'5 zjištění tržní hodnoty měsíčně'**
  String get predFeat5TrzniHodnota;

  /// No description provided for @predFeatPrioritniPodpora.
  ///
  /// In cs, this message translates to:
  /// **'Prioritní podpora'**
  String get predFeatPrioritniPodpora;

  /// No description provided for @predFeatPokrocileStatistiky.
  ///
  /// In cs, this message translates to:
  /// **'Pokročilé statistiky'**
  String get predFeatPokrocileStatistiky;

  /// No description provided for @predFeatVicenasobinaVzd.
  ///
  /// In cs, this message translates to:
  /// **'Vícenásobná pracoviště'**
  String get predFeatVicenasobinaVzd;

  /// No description provided for @predFeatErp.
  ///
  /// In cs, this message translates to:
  /// **'Napojení na vaše ERP/DMS'**
  String get predFeatErp;

  /// No description provided for @predFeatNeomezVin.
  ///
  /// In cs, this message translates to:
  /// **'Neomezený počet dekodovaných VIN měsíčně'**
  String get predFeatNeomezVin;

  /// No description provided for @predFeatNeomezTrzni.
  ///
  /// In cs, this message translates to:
  /// **'Neomezená tržní hodnota vozidel'**
  String get predFeatNeomezTrzni;

  /// No description provided for @predFeatPrioritniSla.
  ///
  /// In cs, this message translates to:
  /// **'Prioritní podpora s SLA'**
  String get predFeatPrioritniSla;

  /// No description provided for @paywallTitle.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte plán'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitleTrialEnding.
  ///
  /// In cs, this message translates to:
  /// **'Vaše zkušební období brzy končí. Vyberte plán pro pokračování.'**
  String get paywallSubtitleTrialEnding;

  /// No description provided for @paywallSubtitleTrialExpired.
  ///
  /// In cs, this message translates to:
  /// **'Vaše zkušební období skončilo. Vyberte plán odpovídající velikosti servisu.'**
  String get paywallSubtitleTrialExpired;

  /// No description provided for @paywallTrialZbyva.
  ///
  /// In cs, this message translates to:
  /// **'Zbývá {n} {slovo} zkušebního období'**
  String paywallTrialZbyva(int n, String slovo);

  /// No description provided for @paywallBezpeci.
  ///
  /// In cs, this message translates to:
  /// **'Vaše data jsou v bezpečí. Po výběru plánu vše obnovíme.'**
  String get paywallBezpeci;

  /// No description provided for @paywallZadnePredplatne.
  ///
  /// In cs, this message translates to:
  /// **'Nenalezeno žádné aktivní předplatné.'**
  String get paywallZadnePredplatne;

  /// No description provided for @paywallChybaObnoveni.
  ///
  /// In cs, this message translates to:
  /// **'Chyba obnovení: {chyba}'**
  String paywallChybaObnoveni(String chyba);

  /// No description provided for @paywallObnovitNakupy.
  ///
  /// In cs, this message translates to:
  /// **'Obnovit nákupy'**
  String get paywallObnovitNakupy;

  /// No description provided for @predPeriodMesic.
  ///
  /// In cs, this message translates to:
  /// **'měsíčně'**
  String get predPeriodMesic;

  /// No description provided for @predPeriodRoc.
  ///
  /// In cs, this message translates to:
  /// **'ročně'**
  String get predPeriodRoc;

  /// No description provided for @predCenaNaMiru.
  ///
  /// In cs, this message translates to:
  /// **'Cena na míru'**
  String get predCenaNaMiru;

  /// No description provided for @predDoporucujeme.
  ///
  /// In cs, this message translates to:
  /// **'DOPORUČUJEME'**
  String get predDoporucujeme;

  /// No description provided for @predAktualniPlanPill.
  ///
  /// In cs, this message translates to:
  /// **'AKTUÁLNÍ PLÁN'**
  String get predAktualniPlanPill;

  /// No description provided for @predAktualneAktivni.
  ///
  /// In cs, this message translates to:
  /// **'Aktuálně aktivní'**
  String get predAktualneAktivni;

  /// No description provided for @predMamZajem.
  ///
  /// In cs, this message translates to:
  /// **'Mám zájem'**
  String get predMamZajem;

  /// No description provided for @predVybrat.
  ///
  /// In cs, this message translates to:
  /// **'Vybrat {name}'**
  String predVybrat(String name);

  /// No description provided for @paywallTrust1Title.
  ///
  /// In cs, this message translates to:
  /// **'99,9 % dostupnost'**
  String get paywallTrust1Title;

  /// No description provided for @paywallTrust1Sub.
  ///
  /// In cs, this message translates to:
  /// **'Garantovaná uptime SLA'**
  String get paywallTrust1Sub;

  /// No description provided for @paywallTrust2Title.
  ///
  /// In cs, this message translates to:
  /// **'Export dat zdarma'**
  String get paywallTrust2Title;

  /// No description provided for @paywallTrust2Sub.
  ///
  /// In cs, this message translates to:
  /// **'Vaše data jsou vždy vaše'**
  String get paywallTrust2Sub;

  /// No description provided for @onbAresChybaIco.
  ///
  /// In cs, this message translates to:
  /// **'Zadejte platné 8místné IČO.'**
  String get onbAresChybaIco;

  /// No description provided for @onbAresNacteno.
  ///
  /// In cs, this message translates to:
  /// **'Údaje z ARES byly načteny.'**
  String get onbAresNacteno;

  /// No description provided for @onbAresNenalezeno.
  ///
  /// In cs, this message translates to:
  /// **'Zadané IČO nebylo v registru ARES nalezeno.'**
  String get onbAresNenalezeno;

  /// No description provided for @onbAresChyba.
  ///
  /// In cs, this message translates to:
  /// **'Chyba při komunikaci s ARES: {chyba}'**
  String onbAresChyba(String chyba);

  /// No description provided for @onbBiometricReason.
  ///
  /// In cs, this message translates to:
  /// **'Potvrďte svou totožnost pro zapnutí biometrického přihlášení'**
  String get onbBiometricReason;

  /// No description provided for @onbDialogUpravitTyp.
  ///
  /// In cs, this message translates to:
  /// **'Upravit typ'**
  String get onbDialogUpravitTyp;

  /// No description provided for @onbDialogNovyTyp.
  ///
  /// In cs, this message translates to:
  /// **'Nový typ záznamu'**
  String get onbDialogNovyTyp;

  /// No description provided for @onbDialogNazevTypuHint.
  ///
  /// In cs, this message translates to:
  /// **'Název typu (např. Servis, Výkup...)'**
  String get onbDialogNazevTypuHint;

  /// No description provided for @onbZrusit.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit'**
  String get onbZrusit;

  /// No description provided for @onbUlozit.
  ///
  /// In cs, this message translates to:
  /// **'Uložit'**
  String get onbUlozit;

  /// No description provided for @onbChybaUkladani.
  ///
  /// In cs, this message translates to:
  /// **'Chyba při ukládání: {chyba}'**
  String onbChybaUkladani(String chyba);

  /// No description provided for @onbChybaNazev.
  ///
  /// In cs, this message translates to:
  /// **'Název servisu je povinný pro pokračování.'**
  String get onbChybaNazev;

  /// No description provided for @onbDokoncit.
  ///
  /// In cs, this message translates to:
  /// **'DOKONČIT NASTAVENÍ'**
  String get onbDokoncit;

  /// No description provided for @onbPokracovat.
  ///
  /// In cs, this message translates to:
  /// **'POKRAČOVAT'**
  String get onbPokracovat;

  /// No description provided for @onbKrok1Nadpis.
  ///
  /// In cs, this message translates to:
  /// **'Vítejte ve TORKIS!'**
  String get onbKrok1Nadpis;

  /// No description provided for @onbKrok1Popis.
  ///
  /// In cs, this message translates to:
  /// **'Nejprve vyplníme základní informace o vás nebo o vaší společnosti.'**
  String get onbKrok1Popis;

  /// No description provided for @onbIcoLabel.
  ///
  /// In cs, this message translates to:
  /// **'IČO (ARES vyhledávání)'**
  String get onbIcoLabel;

  /// No description provided for @onbIcoHint.
  ///
  /// In cs, this message translates to:
  /// **'Např. 12345678'**
  String get onbIcoHint;

  /// No description provided for @onbAresLoadTooltip.
  ///
  /// In cs, this message translates to:
  /// **'Načíst z ARES'**
  String get onbAresLoadTooltip;

  /// No description provided for @onbNazevLabel.
  ///
  /// In cs, this message translates to:
  /// **'Název servisu / Jméno *'**
  String get onbNazevLabel;

  /// No description provided for @onbNazevHint.
  ///
  /// In cs, this message translates to:
  /// **'Zadejte název...'**
  String get onbNazevHint;

  /// No description provided for @onbDicLabel.
  ///
  /// In cs, this message translates to:
  /// **'DIČ (nepovinné)'**
  String get onbDicLabel;

  /// No description provided for @onbDicHint.
  ///
  /// In cs, this message translates to:
  /// **'Např. CZ12345678'**
  String get onbDicHint;

  /// No description provided for @onbRegistraceLabel.
  ///
  /// In cs, this message translates to:
  /// **'Zápis v rejstříku (nepovinné)'**
  String get onbRegistraceLabel;

  /// No description provided for @onbRegistraceHint.
  ///
  /// In cs, this message translates to:
  /// **'Např. zapsán v ŽR u MÚ...'**
  String get onbRegistraceHint;

  /// No description provided for @onbSidloNadpis.
  ///
  /// In cs, this message translates to:
  /// **'Sídlo a kontakt'**
  String get onbSidloNadpis;

  /// No description provided for @onbSidloPopis.
  ///
  /// In cs, this message translates to:
  /// **'Údaje se použijí na nabídkách, fakturách a v komunikaci.'**
  String get onbSidloPopis;

  /// No description provided for @onbUliceLabel.
  ///
  /// In cs, this message translates to:
  /// **'Ulice a č.p.'**
  String get onbUliceLabel;

  /// No description provided for @onbUliceHint.
  ///
  /// In cs, this message translates to:
  /// **'Např. Hlavní 123'**
  String get onbUliceHint;

  /// No description provided for @onbMestoLabel.
  ///
  /// In cs, this message translates to:
  /// **'Město'**
  String get onbMestoLabel;

  /// No description provided for @onbMestoHint.
  ///
  /// In cs, this message translates to:
  /// **'Např. Brno'**
  String get onbMestoHint;

  /// No description provided for @onbPscLabel.
  ///
  /// In cs, this message translates to:
  /// **'PSČ'**
  String get onbPscLabel;

  /// No description provided for @onbTelefonLabel.
  ///
  /// In cs, this message translates to:
  /// **'Telefon servisu'**
  String get onbTelefonLabel;

  /// No description provided for @onbTelefonHint.
  ///
  /// In cs, this message translates to:
  /// **'Např. +420 777 123 456'**
  String get onbTelefonHint;

  /// No description provided for @onbKomunikaceNadpis.
  ///
  /// In cs, this message translates to:
  /// **'Komunikace a vzhled'**
  String get onbKomunikaceNadpis;

  /// No description provided for @onbEmailLabel.
  ///
  /// In cs, this message translates to:
  /// **'E-mailová adresa (z níž budou odcházet e-maily zákazníkům)'**
  String get onbEmailLabel;

  /// No description provided for @onbEmailHint.
  ///
  /// In cs, this message translates to:
  /// **'Např. info@autoservis.cz'**
  String get onbEmailHint;

  /// No description provided for @onbEmailySwitchTitle.
  ///
  /// In cs, this message translates to:
  /// **'Automaticky zasílat e-maily'**
  String get onbEmailySwitchTitle;

  /// No description provided for @onbEmailySwitchSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Zákazníkům bude v nabídkách a při ukončení předzaškrtnuta možnost odeslání PDF e-mailem.'**
  String get onbEmailySwitchSubtitle;

  /// No description provided for @onbAdminNadpis.
  ///
  /// In cs, this message translates to:
  /// **'Váš účet (administrátor)'**
  String get onbAdminNadpis;

  /// No description provided for @onbAdminPopis.
  ///
  /// In cs, this message translates to:
  /// **'Zadejte své jméno — budete přidáni jako hlavní správce servisu.'**
  String get onbAdminPopis;

  /// No description provided for @onbJmenoLabel.
  ///
  /// In cs, this message translates to:
  /// **'Jméno a příjmení *'**
  String get onbJmenoLabel;

  /// No description provided for @onbJmenoHint.
  ///
  /// In cs, this message translates to:
  /// **'Např. Jan Novák'**
  String get onbJmenoHint;

  /// No description provided for @onbTmavyRezimTitle.
  ///
  /// In cs, this message translates to:
  /// **'Vynutit tmavý režim'**
  String get onbTmavyRezimTitle;

  /// No description provided for @onbTmavyRezimSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Aplikace bude okamžitě přepnuta do tmavého vzhledu.'**
  String get onbTmavyRezimSubtitle;

  /// No description provided for @onbKrok2Nadpis.
  ///
  /// In cs, this message translates to:
  /// **'Provoz a automatizace'**
  String get onbKrok2Nadpis;

  /// No description provided for @onbKrok2Popis.
  ///
  /// In cs, this message translates to:
  /// **'Nastavte chování příjmu vozidla. Vše lze později kdykoliv změnit v Nastavení.'**
  String get onbKrok2Popis;

  /// No description provided for @onbAutoCisloTitle.
  ///
  /// In cs, this message translates to:
  /// **'Automaticky generovat číslo zakázky'**
  String get onbAutoCisloTitle;

  /// No description provided for @onbAutoCisloSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Při příjmu vozidla se číslo zakázky předvyplní automaticky. Vypnutím umožníte ruční zadání.'**
  String get onbAutoCisloSubtitle;

  /// No description provided for @onbPodpisTitle.
  ///
  /// In cs, this message translates to:
  /// **'Vyžadovat podpis zákazníka'**
  String get onbPodpisTitle;

  /// No description provided for @onbPodpisSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Při vypnutí se krok s podpisem v příjmu zobrazí bez podpisového plátna.'**
  String get onbPodpisSubtitle;

  /// No description provided for @onbSpzTitle.
  ///
  /// In cs, this message translates to:
  /// **'Povinná SPZ vozidla'**
  String get onbSpzTitle;

  /// No description provided for @onbSpzSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Při vypnutí lze příjem odeslat i bez vyplněné SPZ (např. vozidla bez registrace).'**
  String get onbSpzSubtitle;

  /// No description provided for @onbTypyNadpis.
  ///
  /// In cs, this message translates to:
  /// **'Typy záznamu'**
  String get onbTypyNadpis;

  /// No description provided for @onbTypyPopis.
  ///
  /// In cs, this message translates to:
  /// **'Slouží k rozlišení příjmu vozidla (např. Servis, Výkup). První typ je výchozí.'**
  String get onbTypyPopis;

  /// No description provided for @onbTypyVychozi.
  ///
  /// In cs, this message translates to:
  /// **'výchozí'**
  String get onbTypyVychozi;

  /// No description provided for @onbPridatTyp.
  ///
  /// In cs, this message translates to:
  /// **'Přidat typ'**
  String get onbPridatTyp;

  /// No description provided for @onbTypyHint.
  ///
  /// In cs, this message translates to:
  /// **'Dlouhý stisk = nastavit jako výchozí.'**
  String get onbTypyHint;

  /// No description provided for @onbVzoryNadpis.
  ///
  /// In cs, this message translates to:
  /// **'Vzory popisů poškození'**
  String get onbVzoryNadpis;

  /// No description provided for @onbVzoryPopis.
  ///
  /// In cs, this message translates to:
  /// **'Předdefinované popisy, ze kterých technik vybírá při značení poškození ve fotodokumentaci.'**
  String get onbVzoryPopis;

  /// No description provided for @onbVzoryPrazdne.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné vzory. Přidejte první.'**
  String get onbVzoryPrazdne;

  /// No description provided for @onbPridatVzor.
  ///
  /// In cs, this message translates to:
  /// **'Přidat vzor'**
  String get onbPridatVzor;

  /// No description provided for @onbDialogNovyVzor.
  ///
  /// In cs, this message translates to:
  /// **'Nový vzor poškození'**
  String get onbDialogNovyVzor;

  /// No description provided for @onbDialogUpravitVzor.
  ///
  /// In cs, this message translates to:
  /// **'Upravit vzor'**
  String get onbDialogUpravitVzor;

  /// No description provided for @onbVzorHint.
  ///
  /// In cs, this message translates to:
  /// **'Např. Škrábanec, Promáčklina…'**
  String get onbVzorHint;

  /// No description provided for @onbOsobniNadpis.
  ///
  /// In cs, this message translates to:
  /// **'Osobní nastavení'**
  String get onbOsobniNadpis;

  /// No description provided for @onbBiometrieTitle.
  ///
  /// In cs, this message translates to:
  /// **'Biometrické přihlášení'**
  String get onbBiometrieTitle;

  /// No description provided for @onbBiometrieSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Face ID / otisk prstu při každém spuštění.'**
  String get onbBiometrieSubtitle;

  /// No description provided for @onbLevacTitle.
  ///
  /// In cs, this message translates to:
  /// **'Režim pro leváky'**
  String get onbLevacTitle;

  /// No description provided for @onbLevacSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Spoušť fotoaparátu vlevo, když je zařízení na šířku.'**
  String get onbLevacSubtitle;

  /// No description provided for @onbKrok3Nadpis.
  ///
  /// In cs, this message translates to:
  /// **'Nejčastější úkony'**
  String get onbKrok3Nadpis;

  /// No description provided for @onbKrok3Popis.
  ///
  /// In cs, this message translates to:
  /// **'Připravili jsme pro vás seznam typických úkonů. Můžete je libovolně přepsat, smazat nebo si přidat další. Budou se vám nabízet pro rychlé přidání při příjmu vozu.'**
  String get onbKrok3Popis;

  /// No description provided for @onbUkonNazevLabel.
  ///
  /// In cs, this message translates to:
  /// **'Název úkonu'**
  String get onbUkonNazevLabel;

  /// No description provided for @onbUkonCenaLabel.
  ///
  /// In cs, this message translates to:
  /// **'Jedn. cena (Kč)'**
  String get onbUkonCenaLabel;

  /// No description provided for @onbUkonCasLabel.
  ///
  /// In cs, this message translates to:
  /// **'Čas'**
  String get onbUkonCasLabel;

  /// No description provided for @onbUkonHod.
  ///
  /// In cs, this message translates to:
  /// **'hod'**
  String get onbUkonHod;

  /// No description provided for @onbUkonMin.
  ///
  /// In cs, this message translates to:
  /// **'min'**
  String get onbUkonMin;

  /// No description provided for @onbUkonCelkovaCenaLabel.
  ///
  /// In cs, this message translates to:
  /// **'Celková cena (Kč)'**
  String get onbUkonCelkovaCenaLabel;

  /// No description provided for @onbUkonKategorieLabel.
  ///
  /// In cs, this message translates to:
  /// **'Kategorie'**
  String get onbUkonKategorieLabel;

  /// No description provided for @onbPridatUkon.
  ///
  /// In cs, this message translates to:
  /// **'Přidat další úkon'**
  String get onbPridatUkon;

  /// No description provided for @trialBadge.
  ///
  /// In cs, this message translates to:
  /// **'30 DNÍ ZDARMA'**
  String get trialBadge;

  /// No description provided for @trialNadpis.
  ///
  /// In cs, this message translates to:
  /// **'Vítejte v TORKISu'**
  String get trialNadpis;

  /// No description provided for @trialPopis.
  ///
  /// In cs, this message translates to:
  /// **'Spustili jsme vám zkušební dobu na 30 dní zdarma — bez platební karty a bez závazků.'**
  String get trialPopis;

  /// No description provided for @trialBenefit1.
  ///
  /// In cs, this message translates to:
  /// **'Neomezený počet záznamů vozidel a zákazníků'**
  String get trialBenefit1;

  /// No description provided for @trialBenefit2.
  ///
  /// In cs, this message translates to:
  /// **'10 dekódovaných VINů'**
  String get trialBenefit2;

  /// No description provided for @trialBenefit3.
  ///
  /// In cs, this message translates to:
  /// **'Neomezený počet zjištění platnosti STK'**
  String get trialBenefit3;

  /// No description provided for @trialBenefit4.
  ///
  /// In cs, this message translates to:
  /// **'Plný přístup ke všem funkcím aplikace.'**
  String get trialBenefit4;

  /// No description provided for @trialBenefit5.
  ///
  /// In cs, this message translates to:
  /// **'Žádné platební údaje. Bez automatického strhávání.'**
  String get trialBenefit5;

  /// No description provided for @trialBenefit6.
  ///
  /// In cs, this message translates to:
  /// **'Vaše data jsou vždy vaše — export kdykoli zdarma.'**
  String get trialBenefit6;

  /// No description provided for @trialBtn.
  ///
  /// In cs, this message translates to:
  /// **'Začít používat aplikaci'**
  String get trialBtn;

  /// No description provided for @mainNavNovy.
  ///
  /// In cs, this message translates to:
  /// **'Nový'**
  String get mainNavNovy;

  /// No description provided for @mainNavMenu.
  ///
  /// In cs, this message translates to:
  /// **'Menu'**
  String get mainNavMenu;

  /// No description provided for @mainNavVozidla.
  ///
  /// In cs, this message translates to:
  /// **'Vozidla'**
  String get mainNavVozidla;

  /// No description provided for @mainNavUkony.
  ///
  /// In cs, this message translates to:
  /// **'Úkony'**
  String get mainNavUkony;

  /// No description provided for @mainNavZakaznici.
  ///
  /// In cs, this message translates to:
  /// **'Zákazníci'**
  String get mainNavZakaznici;

  /// No description provided for @mainNavTym.
  ///
  /// In cs, this message translates to:
  /// **'Tým'**
  String get mainNavTym;

  /// No description provided for @mainNavStatistiky.
  ///
  /// In cs, this message translates to:
  /// **'Statistiky'**
  String get mainNavStatistiky;

  /// No description provided for @mainNavNastaveni.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení'**
  String get mainNavNastaveni;

  /// No description provided for @mainNavPrijmy.
  ///
  /// In cs, this message translates to:
  /// **'Příjmy'**
  String get mainNavPrijmy;

  /// No description provided for @mainNavVin.
  ///
  /// In cs, this message translates to:
  /// **'VIN'**
  String get mainNavVin;

  /// No description provided for @mainModVozidlaSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Evidence vozů v servisu'**
  String get mainModVozidlaSubtitle;

  /// No description provided for @mainModZakazniciSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Kontakty a vozový park'**
  String get mainModZakazniciSubtitle;

  /// No description provided for @mainModHistorieLabel.
  ///
  /// In cs, this message translates to:
  /// **'Historie záznamů'**
  String get mainModHistorieLabel;

  /// No description provided for @mainModHistorieSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Archiv zakázek'**
  String get mainModHistorieSubtitle;

  /// No description provided for @mainModUkonySubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Ceník prací a služeb'**
  String get mainModUkonySubtitle;

  /// No description provided for @mainModVinLabel.
  ///
  /// In cs, this message translates to:
  /// **'VIN dekodér'**
  String get mainModVinLabel;

  /// No description provided for @mainModVinSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Údaje o vozidle z VIN'**
  String get mainModVinSubtitle;

  /// No description provided for @mainModTymSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Technici a oprávnění'**
  String get mainModTymSubtitle;

  /// No description provided for @mainModStatistikySubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Přehledy a tržby'**
  String get mainModStatistikySubtitle;

  /// No description provided for @mainModNastaveniSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Servis, faktury, integrace'**
  String get mainModNastaveniSubtitle;

  /// No description provided for @mainModPredplatneLabel.
  ///
  /// In cs, this message translates to:
  /// **'Předplatné'**
  String get mainModPredplatneLabel;

  /// No description provided for @mainModPredplatneSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Plán a platby'**
  String get mainModPredplatneSubtitle;

  /// No description provided for @mainModWebLabel.
  ///
  /// In cs, this message translates to:
  /// **'Web'**
  String get mainModWebLabel;

  /// No description provided for @mainModWebSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Veřejná stránka'**
  String get mainModWebSubtitle;

  /// No description provided for @mainModulyNadpis.
  ///
  /// In cs, this message translates to:
  /// **'Moduly'**
  String get mainModulyNadpis;

  /// No description provided for @mainPrihlasenv.
  ///
  /// In cs, this message translates to:
  /// **'Přihlášen v servisu'**
  String get mainPrihlasenv;

  /// No description provided for @mainOdhlasitSe.
  ///
  /// In cs, this message translates to:
  /// **'Odhlásit se'**
  String get mainOdhlasitSe;

  /// No description provided for @mainOdhlaseniTitle.
  ///
  /// In cs, this message translates to:
  /// **'Odhlášení'**
  String get mainOdhlaseniTitle;

  /// No description provided for @mainOdhlaseniContent.
  ///
  /// In cs, this message translates to:
  /// **'Opravdu se chcete odhlásit?'**
  String get mainOdhlaseniContent;

  /// No description provided for @mainZrusit.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit'**
  String get mainZrusit;

  /// No description provided for @mainOdhlasit.
  ///
  /// In cs, this message translates to:
  /// **'Odhlásit'**
  String get mainOdhlasit;

  /// No description provided for @mainSvetlyRezim.
  ///
  /// In cs, this message translates to:
  /// **'Světlý režim'**
  String get mainSvetlyRezim;

  /// No description provided for @mainTmavyRezim.
  ///
  /// In cs, this message translates to:
  /// **'Tmavý režim'**
  String get mainTmavyRezim;

  /// No description provided for @histZpracovava.
  ///
  /// In cs, this message translates to:
  /// **'Zpracovává se...'**
  String get histZpracovava;

  /// No description provided for @histNadpis.
  ///
  /// In cs, this message translates to:
  /// **'Historie záznamů'**
  String get histNadpis;

  /// No description provided for @histPodnadpis.
  ///
  /// In cs, this message translates to:
  /// **'Přehled všech přijatých vozidel a jejich protokolů.'**
  String get histPodnadpis;

  /// No description provided for @histHledat.
  ///
  /// In cs, this message translates to:
  /// **'Hledat SPZ, zákazníka nebo vozidlo...'**
  String get histHledat;

  /// No description provided for @histChyba.
  ///
  /// In cs, this message translates to:
  /// **'Chyba: {chyba}'**
  String histChyba(String chyba);

  /// No description provided for @histPrazdne.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné záznamy o příjmu.'**
  String get histPrazdne;

  /// No description provided for @histNespecifikovano.
  ///
  /// In cs, this message translates to:
  /// **'Nespecifikováno'**
  String get histNespecifikovano;

  /// No description provided for @histPrijal.
  ///
  /// In cs, this message translates to:
  /// **'Přijal'**
  String get histPrijal;

  /// No description provided for @histFoto.
  ///
  /// In cs, this message translates to:
  /// **'{pocet} foto'**
  String histFoto(int pocet);

  /// No description provided for @histPodepsano.
  ///
  /// In cs, this message translates to:
  /// **'Podepsáno'**
  String get histPodepsano;

  /// No description provided for @histDetailNadpis.
  ///
  /// In cs, this message translates to:
  /// **'Detail příjmu'**
  String get histDetailNadpis;

  /// No description provided for @histChybaTisku.
  ///
  /// In cs, this message translates to:
  /// **'Chyba při tisku: {chyba}'**
  String histChybaTisku(String chyba);

  /// No description provided for @histChybaZobrazeni.
  ///
  /// In cs, this message translates to:
  /// **'Chyba při zobrazení: {chyba}'**
  String histChybaZobrazeni(String chyba);

  /// No description provided for @histProtokol.
  ///
  /// In cs, this message translates to:
  /// **'Protokol {cislo}'**
  String histProtokol(String cislo);

  /// No description provided for @histZobrazitProtokol.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit protokol'**
  String get histZobrazitProtokol;

  /// No description provided for @histTisknoutProtokol.
  ///
  /// In cs, this message translates to:
  /// **'Tisknout protokol'**
  String get histTisknoutProtokol;

  /// No description provided for @histTisknoutBtn.
  ///
  /// In cs, this message translates to:
  /// **'Tisk'**
  String get histTisknoutBtn;

  /// No description provided for @histSekceVozidlo.
  ///
  /// In cs, this message translates to:
  /// **'Vozidlo'**
  String get histSekceVozidlo;

  /// No description provided for @histPoleSPZ.
  ///
  /// In cs, this message translates to:
  /// **'SPZ'**
  String get histPoleSPZ;

  /// No description provided for @histPoleZnackaModel.
  ///
  /// In cs, this message translates to:
  /// **'Značka & Model'**
  String get histPoleZnackaModel;

  /// No description provided for @histPoleVin.
  ///
  /// In cs, this message translates to:
  /// **'VIN'**
  String get histPoleVin;

  /// No description provided for @histPoleRokVyroby.
  ///
  /// In cs, this message translates to:
  /// **'Rok výroby'**
  String get histPoleRokVyroby;

  /// No description provided for @histPolePalivo.
  ///
  /// In cs, this message translates to:
  /// **'Palivo'**
  String get histPolePalivo;

  /// No description provided for @histPolePrevodovka.
  ///
  /// In cs, this message translates to:
  /// **'Převodovka'**
  String get histPolePrevodovka;

  /// No description provided for @histPoleMotorizace.
  ///
  /// In cs, this message translates to:
  /// **'Motorizace'**
  String get histPoleMotorizace;

  /// No description provided for @histSekceZakaznik.
  ///
  /// In cs, this message translates to:
  /// **'Zákazník'**
  String get histSekceZakaznik;

  /// No description provided for @histPoleJmeno.
  ///
  /// In cs, this message translates to:
  /// **'Jméno'**
  String get histPoleJmeno;

  /// No description provided for @histPoleTelefon.
  ///
  /// In cs, this message translates to:
  /// **'Telefon'**
  String get histPoleTelefon;

  /// No description provided for @histPoleEmail.
  ///
  /// In cs, this message translates to:
  /// **'E-mail'**
  String get histPoleEmail;

  /// No description provided for @histPoleAdresa.
  ///
  /// In cs, this message translates to:
  /// **'Adresa'**
  String get histPoleAdresa;

  /// No description provided for @histPoleIco.
  ///
  /// In cs, this message translates to:
  /// **'IČO'**
  String get histPoleIco;

  /// No description provided for @histPoleDic.
  ///
  /// In cs, this message translates to:
  /// **'DIČ'**
  String get histPoleDic;

  /// No description provided for @histSekceStav.
  ///
  /// In cs, this message translates to:
  /// **'Stav při příjmu'**
  String get histSekceStav;

  /// No description provided for @histPoleTachometr.
  ///
  /// In cs, this message translates to:
  /// **'Tachometr'**
  String get histPoleTachometr;

  /// No description provided for @histPoleNadrz.
  ///
  /// In cs, this message translates to:
  /// **'Stav nádrže'**
  String get histPoleNadrz;

  /// No description provided for @histPoleStk.
  ///
  /// In cs, this message translates to:
  /// **'STK'**
  String get histPoleStk;

  /// No description provided for @histPolePoskozeni.
  ///
  /// In cs, this message translates to:
  /// **'Poškození'**
  String get histPolePoskozeni;

  /// No description provided for @histPolePneuLP.
  ///
  /// In cs, this message translates to:
  /// **'Pneumatiky LP / PP'**
  String get histPolePneuLP;

  /// No description provided for @histPolePneuLZ.
  ///
  /// In cs, this message translates to:
  /// **'Pneumatiky LZ / PZ'**
  String get histPolePneuLZ;

  /// No description provided for @histSekcePozadavky.
  ///
  /// In cs, this message translates to:
  /// **'Požadavky zákazníka'**
  String get histSekcePozadavky;

  /// No description provided for @histSekcePoznamky.
  ///
  /// In cs, this message translates to:
  /// **'Poznámky'**
  String get histSekcePoznamky;

  /// No description provided for @histSekceFoto.
  ///
  /// In cs, this message translates to:
  /// **'Fotodokumentace'**
  String get histSekceFoto;

  /// No description provided for @histZadneFoto.
  ///
  /// In cs, this message translates to:
  /// **'Nebyly pořízeny žádné fotografie.'**
  String get histZadneFoto;

  /// No description provided for @histSekcePodpis.
  ///
  /// In cs, this message translates to:
  /// **'Podpis zákazníka'**
  String get histSekcePodpis;

  /// No description provided for @histPodpisNedostupny.
  ///
  /// In cs, this message translates to:
  /// **'Podpis není k dispozici'**
  String get histPodpisNedostupny;

  /// No description provided for @nastUlozit.
  ///
  /// In cs, this message translates to:
  /// **'ULOŽIT'**
  String get nastUlozit;

  /// No description provided for @nastUlozeno.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení uloženo.'**
  String get nastUlozeno;

  /// No description provided for @nastChyba.
  ///
  /// In cs, this message translates to:
  /// **'Chyba: {chyba}'**
  String nastChyba(String chyba);

  /// No description provided for @nastZrusit.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit'**
  String get nastZrusit;

  /// No description provided for @nastExportTitle.
  ///
  /// In cs, this message translates to:
  /// **'Export dat'**
  String get nastExportTitle;

  /// No description provided for @nastExportPopis.
  ///
  /// In cs, this message translates to:
  /// **'Stáhněte záznamy ve formátu CSV (Excel) nebo JSON.'**
  String get nastExportPopis;

  /// No description provided for @nastExportZakaznici.
  ///
  /// In cs, this message translates to:
  /// **'Zákazníci'**
  String get nastExportZakaznici;

  /// No description provided for @nastExportVozidla.
  ///
  /// In cs, this message translates to:
  /// **'Vozidla'**
  String get nastExportVozidla;

  /// No description provided for @nastExportZakazky.
  ///
  /// In cs, this message translates to:
  /// **'Příjmy / Zakázky'**
  String get nastExportZakazky;

  /// No description provided for @nastExportFormatTitle.
  ///
  /// In cs, this message translates to:
  /// **'Formát exportu'**
  String get nastExportFormatTitle;

  /// No description provided for @nastExportFormatPopis.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte formát souboru:'**
  String get nastExportFormatPopis;

  /// No description provided for @nastExportCsv.
  ///
  /// In cs, this message translates to:
  /// **'CSV (Excel)'**
  String get nastExportCsv;

  /// No description provided for @fotoTitle.
  ///
  /// In cs, this message translates to:
  /// **'Fotodokumentace'**
  String get fotoTitle;

  /// No description provided for @fotoPodtitul.
  ///
  /// In cs, this message translates to:
  /// **'Vyfoťte sérii fotek, nebo vyberte hromadně z galerie.'**
  String get fotoPodtitul;

  /// No description provided for @fotoPridatGalerie.
  ///
  /// In cs, this message translates to:
  /// **'Přidat z galerie'**
  String get fotoPridatGalerie;

  /// No description provided for @fotoSeriove.
  ///
  /// In cs, this message translates to:
  /// **'Sériové focení'**
  String get fotoSeriove;

  /// No description provided for @fotoKatZvenku.
  ///
  /// In cs, this message translates to:
  /// **'Pohled zvenku (kolem vozu)'**
  String get fotoKatZvenku;

  /// No description provided for @fotoKatPoskozeni.
  ///
  /// In cs, this message translates to:
  /// **'Zjištěná poškození'**
  String get fotoKatPoskozeni;

  /// No description provided for @fotoKatDisky.
  ///
  /// In cs, this message translates to:
  /// **'Disky a kola'**
  String get fotoKatDisky;

  /// No description provided for @fotoKatStk.
  ///
  /// In cs, this message translates to:
  /// **'Nálepka STK'**
  String get fotoKatStk;

  /// No description provided for @fotoKatInterier.
  ///
  /// In cs, this message translates to:
  /// **'Interiér vozu'**
  String get fotoKatInterier;

  /// No description provided for @fotoKatTachometr.
  ///
  /// In cs, this message translates to:
  /// **'Tachometr a palubní deska'**
  String get fotoKatTachometr;

  /// No description provided for @fotoKatVin.
  ///
  /// In cs, this message translates to:
  /// **'VIN kód'**
  String get fotoKatVin;

  /// No description provided for @fotoKatOstatni.
  ///
  /// In cs, this message translates to:
  /// **'Ostatní dokumentace'**
  String get fotoKatOstatni;

  /// No description provided for @anotTitle.
  ///
  /// In cs, this message translates to:
  /// **'Označení poškození'**
  String get anotTitle;

  /// No description provided for @anotZavritBezUlozeni.
  ///
  /// In cs, this message translates to:
  /// **'Zavřít bez uložení'**
  String get anotZavritBezUlozeni;

  /// No description provided for @anotZrusitPosledni.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit poslední'**
  String get anotZrusitPosledni;

  /// No description provided for @anotSmazatVse.
  ///
  /// In cs, this message translates to:
  /// **'Smazat vše'**
  String get anotSmazatVse;

  /// No description provided for @anotUlozit.
  ///
  /// In cs, this message translates to:
  /// **'Uložit'**
  String get anotUlozit;

  /// No description provided for @anotChybaNacteni.
  ///
  /// In cs, this message translates to:
  /// **'Nepodařilo se načíst fotografii.'**
  String get anotChybaNacteni;

  /// No description provided for @anotVolnaKresba.
  ///
  /// In cs, this message translates to:
  /// **'Volná kresba'**
  String get anotVolnaKresba;

  /// No description provided for @anotElipsa.
  ///
  /// In cs, this message translates to:
  /// **'Elipsa'**
  String get anotElipsa;

  /// No description provided for @anotObdelnik.
  ///
  /// In cs, this message translates to:
  /// **'Obdélník'**
  String get anotObdelnik;

  /// No description provided for @anotSipka.
  ///
  /// In cs, this message translates to:
  /// **'Šipka'**
  String get anotSipka;

  /// No description provided for @anotPopisTitle.
  ///
  /// In cs, this message translates to:
  /// **'Popis poškození'**
  String get anotPopisTitle;

  /// No description provided for @anotVzory.
  ///
  /// In cs, this message translates to:
  /// **'Vzory:'**
  String get anotVzory;

  /// No description provided for @anotVlastniPopis.
  ///
  /// In cs, this message translates to:
  /// **'Nebo napište vlastní popis…'**
  String get anotVlastniPopis;

  /// No description provided for @anotZrusit.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit'**
  String get anotZrusit;

  /// No description provided for @anotZahodi.
  ///
  /// In cs, this message translates to:
  /// **'Zahodit'**
  String get anotZahodi;

  /// No description provided for @anotNeulozenePomoc.
  ///
  /// In cs, this message translates to:
  /// **'Máte neuložené označení poškození. Uložit je?'**
  String get anotNeulozenePomoc;

  /// No description provided for @nastUlozitBtn.
  ///
  /// In cs, this message translates to:
  /// **'Uložit'**
  String get nastUlozitBtn;

  /// No description provided for @nastZavrit.
  ///
  /// In cs, this message translates to:
  /// **'ZAVŘÍT'**
  String get nastZavrit;

  /// No description provided for @nastHotovo.
  ///
  /// In cs, this message translates to:
  /// **'HOTOVO'**
  String get nastHotovo;

  /// No description provided for @nastChecklistTitul.
  ///
  /// In cs, this message translates to:
  /// **'Checklist příjmu'**
  String get nastChecklistTitul;

  /// No description provided for @nastChecklistPovolen.
  ///
  /// In cs, this message translates to:
  /// **'Aktivovat checklist při příjmu'**
  String get nastChecklistPovolen;

  /// No description provided for @nastChecklistPovolenSub.
  ///
  /// In cs, this message translates to:
  /// **'Panel s checklistem se zobrazí při příjmu na tabletu'**
  String get nastChecklistPovolenSub;

  /// No description provided for @nastChecklistPrazdny.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné položky'**
  String get nastChecklistPrazdny;

  /// No description provided for @nastPridatChecklistPolozku.
  ///
  /// In cs, this message translates to:
  /// **'Přidat položku'**
  String get nastPridatChecklistPolozku;

  /// No description provided for @nastNovaChecklistPolozka.
  ///
  /// In cs, this message translates to:
  /// **'Nová položka'**
  String get nastNovaChecklistPolozka;

  /// No description provided for @nastUpravitChecklistPolozku.
  ///
  /// In cs, this message translates to:
  /// **'Upravit položku'**
  String get nastUpravitChecklistPolozku;

  /// No description provided for @nastChecklistPolozkaHint.
  ///
  /// In cs, this message translates to:
  /// **'Název položky checklistu'**
  String get nastChecklistPolozkaHint;

  /// No description provided for @checklistPanelTitul.
  ///
  /// In cs, this message translates to:
  /// **'Checklist'**
  String get checklistPanelTitul;

  /// No description provided for @nastTitulAdmin.
  ///
  /// In cs, this message translates to:
  /// **'Firemní nastavení'**
  String get nastTitulAdmin;

  /// No description provided for @nastTitulUzivatel.
  ///
  /// In cs, this message translates to:
  /// **'Můj profil'**
  String get nastTitulUzivatel;

  /// No description provided for @nastPodtitulAdmin.
  ///
  /// In cs, this message translates to:
  /// **'Správa údajů servisu a ceníku.'**
  String get nastPodtitulAdmin;

  /// No description provided for @nastPodtitulUzivatel.
  ///
  /// In cs, this message translates to:
  /// **'Základní nastavení vašeho účtu.'**
  String get nastPodtitulUzivatel;

  /// No description provided for @nastFiremniUdaje.
  ///
  /// In cs, this message translates to:
  /// **'Firemní údaje'**
  String get nastFiremniUdaje;

  /// No description provided for @nastObchodniJmeno.
  ///
  /// In cs, this message translates to:
  /// **'Obchodní jméno / Název servisu'**
  String get nastObchodniJmeno;

  /// No description provided for @nastIco.
  ///
  /// In cs, this message translates to:
  /// **'IČO'**
  String get nastIco;

  /// No description provided for @nastDic.
  ///
  /// In cs, this message translates to:
  /// **'DIČ'**
  String get nastDic;

  /// No description provided for @nastRejstrik.
  ///
  /// In cs, this message translates to:
  /// **'Zápis v rejstříku (spisová značka)'**
  String get nastRejstrik;

  /// No description provided for @nastSidloKontakt.
  ///
  /// In cs, this message translates to:
  /// **'Sídlo a kontakt'**
  String get nastSidloKontakt;

  /// No description provided for @nastUlice.
  ///
  /// In cs, this message translates to:
  /// **'Ulice a č.p.'**
  String get nastUlice;

  /// No description provided for @nastMesto.
  ///
  /// In cs, this message translates to:
  /// **'Město'**
  String get nastMesto;

  /// No description provided for @nastPsc.
  ///
  /// In cs, this message translates to:
  /// **'PSČ'**
  String get nastPsc;

  /// No description provided for @nastTelefon.
  ///
  /// In cs, this message translates to:
  /// **'Telefon servisu'**
  String get nastTelefon;

  /// No description provided for @nastEmail.
  ///
  /// In cs, this message translates to:
  /// **'E-mail pro komunikaci'**
  String get nastEmail;

  /// No description provided for @nastCislovani.
  ///
  /// In cs, this message translates to:
  /// **'Číslování a automatizace'**
  String get nastCislovani;

  /// No description provided for @nastFormatZakazek.
  ///
  /// In cs, this message translates to:
  /// **'Formát čísla zakázek'**
  String get nastFormatZakazek;

  /// No description provided for @nastAutoEmail.
  ///
  /// In cs, this message translates to:
  /// **'Automaticky zasílat e-maily'**
  String get nastAutoEmail;

  /// No description provided for @nastAutoEmailSub.
  ///
  /// In cs, this message translates to:
  /// **'Přednastaví odesílání PDF nabídek a faktur.'**
  String get nastAutoEmailSub;

  /// No description provided for @nastAutoCislo.
  ///
  /// In cs, this message translates to:
  /// **'Automaticky generovat číslo zakázky'**
  String get nastAutoCislo;

  /// No description provided for @nastAutoCisloSub.
  ///
  /// In cs, this message translates to:
  /// **'Při příjmu vozidla se číslo zakázky předvyplní automaticky. Vypnutím umožníte ruční zadání.'**
  String get nastAutoCisloSub;

  /// No description provided for @nastPodpisPovolen.
  ///
  /// In cs, this message translates to:
  /// **'Vyžadovat podpis zákazníka'**
  String get nastPodpisPovolen;

  /// No description provided for @nastPodpisPovolenSub.
  ///
  /// In cs, this message translates to:
  /// **'Při vypnutí se krok s podpisem v příjmu zobrazí bez podpisového plátna.'**
  String get nastPodpisPovolenSub;

  /// No description provided for @nastSpzPovinne.
  ///
  /// In cs, this message translates to:
  /// **'Povinná SPZ vozidla'**
  String get nastSpzPovinne;

  /// No description provided for @nastSpzPovinneSub.
  ///
  /// In cs, this message translates to:
  /// **'Při vypnutí lze příjem odeslat i bez vyplněné SPZ (např. vozidla bez registrace).'**
  String get nastSpzPovinneSub;

  /// No description provided for @nastSablony.
  ///
  /// In cs, this message translates to:
  /// **'Šablony zpráv'**
  String get nastSablony;

  /// No description provided for @nastSablonyPopis.
  ///
  /// In cs, this message translates to:
  /// **'Přednastavené texty zobrazené jako chipy při psaní zprávy zákazníkovi.'**
  String get nastSablonyPopis;

  /// No description provided for @nastSablonyPrazdne.
  ///
  /// In cs, this message translates to:
  /// **'Zatím žádné šablony. Přidejte první.'**
  String get nastSablonyPrazdne;

  /// No description provided for @nastPridatSablonu.
  ///
  /// In cs, this message translates to:
  /// **'Přidat šablonu'**
  String get nastPridatSablonu;

  /// No description provided for @nastUpravitSablonu.
  ///
  /// In cs, this message translates to:
  /// **'Upravit šablonu'**
  String get nastUpravitSablonu;

  /// No description provided for @nastNovaSablona.
  ///
  /// In cs, this message translates to:
  /// **'Nová šablona'**
  String get nastNovaSablona;

  /// No description provided for @nastSablonaHint.
  ///
  /// In cs, this message translates to:
  /// **'Text zprávy...'**
  String get nastSablonaHint;

  /// No description provided for @nastTypyZaznamu.
  ///
  /// In cs, this message translates to:
  /// **'Typy záznamu'**
  String get nastTypyZaznamu;

  /// No description provided for @nastTypyZaznamuPopis.
  ///
  /// In cs, this message translates to:
  /// **'Typy záznamu slouží k rozlišení příjmu vozidla (např. Servis, Výkup). První přidaný typ je výchozí.'**
  String get nastTypyZaznamuPopis;

  /// No description provided for @nastVychozi.
  ///
  /// In cs, this message translates to:
  /// **'výchozí'**
  String get nastVychozi;

  /// No description provided for @nastPridatTyp.
  ///
  /// In cs, this message translates to:
  /// **'Přidat typ'**
  String get nastPridatTyp;

  /// No description provided for @nastUpravitTyp.
  ///
  /// In cs, this message translates to:
  /// **'Upravit typ'**
  String get nastUpravitTyp;

  /// No description provided for @nastNovyTyp.
  ///
  /// In cs, this message translates to:
  /// **'Nový typ záznamu'**
  String get nastNovyTyp;

  /// No description provided for @nastTypHint.
  ///
  /// In cs, this message translates to:
  /// **'Název typu (např. Servis, Výkup...)'**
  String get nastTypHint;

  /// No description provided for @nastLongPress.
  ///
  /// In cs, this message translates to:
  /// **'Dlouhý stisk = nastavit jako výchozí.'**
  String get nastLongPress;

  /// No description provided for @nastOsobni.
  ///
  /// In cs, this message translates to:
  /// **'Osobní nastavení'**
  String get nastOsobni;

  /// No description provided for @nastPrizpusobitListu.
  ///
  /// In cs, this message translates to:
  /// **'Přizpůsobit spodní lištu'**
  String get nastPrizpusobitListu;

  /// No description provided for @nastPrizpusobitListuSub.
  ///
  /// In cs, this message translates to:
  /// **'Přidejte si zástupce nebo změňte pořadí.'**
  String get nastPrizpusobitListuSub;

  /// No description provided for @nastListaPopis.
  ///
  /// In cs, this message translates to:
  /// **'Můžete mít aktivních 2 až 5 záložek. Přetažením změníte pořadí.'**
  String get nastListaPopis;

  /// No description provided for @nastMenuNelzeOdebrat.
  ///
  /// In cs, this message translates to:
  /// **'Menu nelze odebrat'**
  String get nastMenuNelzeOdebrat;

  /// No description provided for @nastVybrModul.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte modul pro lištu'**
  String get nastVybrModul;

  /// No description provided for @nastPridatZalozku.
  ///
  /// In cs, this message translates to:
  /// **'Přidat další záložku (max 5)'**
  String get nastPridatZalozku;

  /// No description provided for @nastTmavyRezim.
  ///
  /// In cs, this message translates to:
  /// **'Vynutit tmavý režim'**
  String get nastTmavyRezim;

  /// No description provided for @nastTmavyRezimSub.
  ///
  /// In cs, this message translates to:
  /// **'Aplikace bude tmavá bez ohledu na systém.'**
  String get nastTmavyRezimSub;

  /// No description provided for @nastBiometrie.
  ///
  /// In cs, this message translates to:
  /// **'Biometrické přihlášení'**
  String get nastBiometrie;

  /// No description provided for @nastBiometrieSub.
  ///
  /// In cs, this message translates to:
  /// **'Face ID / otisk prstu při každém spuštění.'**
  String get nastBiometrieSub;

  /// No description provided for @nastBiometricReason.
  ///
  /// In cs, this message translates to:
  /// **'Potvrďte svou totožnost pro zapnutí biometrického přihlášení'**
  String get nastBiometricReason;

  /// No description provided for @nastLeVaci.
  ///
  /// In cs, this message translates to:
  /// **'Režim pro leváky'**
  String get nastLeVaci;

  /// No description provided for @nastLeVaciSub.
  ///
  /// In cs, this message translates to:
  /// **'Spoušť fotoaparátu vlevo, když je zařízení na šířku.'**
  String get nastLeVaciSub;

  /// No description provided for @nastUlozitDoZarizeniTitle.
  ///
  /// In cs, this message translates to:
  /// **'Ukládat fotky i do zařízení'**
  String get nastUlozitDoZarizeniTitle;

  /// No description provided for @nastUlozitDoZarizeniSub.
  ///
  /// In cs, this message translates to:
  /// **'Při odeslání se fotky z příjmu uloží také do galerie tohoto zařízení.'**
  String get nastUlozitDoZarizeniSub;

  /// No description provided for @nastJazyk.
  ///
  /// In cs, this message translates to:
  /// **'Jazyk aplikace'**
  String get nastJazyk;

  /// No description provided for @nastSystJazyk.
  ///
  /// In cs, this message translates to:
  /// **'Systémový jazyk'**
  String get nastSystJazyk;

  /// No description provided for @nastModPrijem.
  ///
  /// In cs, this message translates to:
  /// **'Příjem vozidla'**
  String get nastModPrijem;

  /// No description provided for @nastModHistorie.
  ///
  /// In cs, this message translates to:
  /// **'Historie příjmů'**
  String get nastModHistorie;

  /// No description provided for @nastModMenu.
  ///
  /// In cs, this message translates to:
  /// **'Menu (Ostatní moduly)'**
  String get nastModMenu;

  /// No description provided for @nastModVozidla.
  ///
  /// In cs, this message translates to:
  /// **'Vozidla'**
  String get nastModVozidla;

  /// No description provided for @nastModUkony.
  ///
  /// In cs, this message translates to:
  /// **'Úkony'**
  String get nastModUkony;

  /// No description provided for @nastModZakaznici.
  ///
  /// In cs, this message translates to:
  /// **'Zákazníci'**
  String get nastModZakaznici;

  /// No description provided for @nastModTym.
  ///
  /// In cs, this message translates to:
  /// **'Tým a práva'**
  String get nastModTym;

  /// No description provided for @nastModStatistiky.
  ///
  /// In cs, this message translates to:
  /// **'Statistiky'**
  String get nastModStatistiky;

  /// No description provided for @nastModNastaveni.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení'**
  String get nastModNastaveni;

  /// No description provided for @nastModVin.
  ///
  /// In cs, this message translates to:
  /// **'VIN dekodér'**
  String get nastModVin;

  /// No description provided for @nastFormatTitle.
  ///
  /// In cs, this message translates to:
  /// **'Formát čísla pro: {typ}'**
  String nastFormatTitle(String typ);

  /// No description provided for @nastNahledLabel.
  ///
  /// In cs, this message translates to:
  /// **'Náhled budoucího dokladu:'**
  String get nastNahledLabel;

  /// No description provided for @nastInternaMaska.
  ///
  /// In cs, this message translates to:
  /// **'Interní maska: {maska}'**
  String nastInternaMaska(String maska);

  /// No description provided for @nastPrefix.
  ///
  /// In cs, this message translates to:
  /// **'Prefix (Značka)'**
  String get nastPrefix;

  /// No description provided for @nastOddelovac.
  ///
  /// In cs, this message translates to:
  /// **'Oddělovač'**
  String get nastOddelovac;

  /// No description provided for @nastOddelovacPomlcka.
  ///
  /// In cs, this message translates to:
  /// **'Pomlčka (-)'**
  String get nastOddelovacPomlcka;

  /// No description provided for @nastOddelovacLomitko.
  ///
  /// In cs, this message translates to:
  /// **'Lomítko (/)'**
  String get nastOddelovacLomitko;

  /// No description provided for @nastOddelovacPodtrzitko.
  ///
  /// In cs, this message translates to:
  /// **'Podtržítko (_)'**
  String get nastOddelovacPodtrzitko;

  /// No description provided for @nastOddelovacBez.
  ///
  /// In cs, this message translates to:
  /// **'Bez oddělovače'**
  String get nastOddelovacBez;

  /// No description provided for @nastRokFormat.
  ///
  /// In cs, this message translates to:
  /// **'Formát roku'**
  String get nastRokFormat;

  /// No description provided for @nastRok4.
  ///
  /// In cs, this message translates to:
  /// **'4 cifry (2026)'**
  String get nastRok4;

  /// No description provided for @nastRok2.
  ///
  /// In cs, this message translates to:
  /// **'2 cifry (26)'**
  String get nastRok2;

  /// No description provided for @nastBezRoku.
  ///
  /// In cs, this message translates to:
  /// **'Bez roku'**
  String get nastBezRoku;

  /// No description provided for @nastMesicFormat.
  ///
  /// In cs, this message translates to:
  /// **'Formát měsíce'**
  String get nastMesicFormat;

  /// No description provided for @nastMesic2.
  ///
  /// In cs, this message translates to:
  /// **'2 cifry (04)'**
  String get nastMesic2;

  /// No description provided for @nastBezMesice.
  ///
  /// In cs, this message translates to:
  /// **'Bez měsíce'**
  String get nastBezMesice;

  /// No description provided for @nastDelkaCitadla.
  ///
  /// In cs, this message translates to:
  /// **'Délka pořadového čísla na konci: {n}'**
  String nastDelkaCitadla(int n);

  /// No description provided for @nastInfoZmenaFormatu.
  ///
  /// In cs, this message translates to:
  /// **'Pokud změníte formát v průběhu roku, stávající doklady zůstanou nedotčeny a nová řada začne navazovat od aktuálního čísla v databázi.'**
  String get nastInfoZmenaFormatu;

  /// No description provided for @nastUlozitFormat.
  ///
  /// In cs, this message translates to:
  /// **'ULOŽIT FORMÁT'**
  String get nastUlozitFormat;

  /// No description provided for @nastFormatUlozen.
  ///
  /// In cs, this message translates to:
  /// **'Formát číslování byl úspěšně uložen.'**
  String get nastFormatUlozen;

  /// No description provided for @nastTrialVyprselo.
  ///
  /// In cs, this message translates to:
  /// **'Zkušební doba vypršela'**
  String get nastTrialVyprselo;

  /// No description provided for @nastTrialAktivni.
  ///
  /// In cs, this message translates to:
  /// **'Zkušební doba zdarma'**
  String get nastTrialAktivni;

  /// No description provided for @nastPlanNazev.
  ///
  /// In cs, this message translates to:
  /// **'Plán {plan}'**
  String nastPlanNazev(String plan);

  /// No description provided for @nastTrialVyberPlan.
  ///
  /// In cs, this message translates to:
  /// **'Vyberte plán pro pokračování'**
  String get nastTrialVyberPlan;

  /// No description provided for @nastTrialZbyva.
  ///
  /// In cs, this message translates to:
  /// **'Zbývá {n} {slovo} · bez závazku'**
  String nastTrialZbyva(int n, String slovo);

  /// No description provided for @nastPlatnostDo.
  ///
  /// In cs, this message translates to:
  /// **'Platnost do {datum}'**
  String nastPlatnostDo(String datum);

  /// No description provided for @nastAktivni.
  ///
  /// In cs, this message translates to:
  /// **'Aktivní'**
  String get nastAktivni;

  /// No description provided for @nastVybratPlan.
  ///
  /// In cs, this message translates to:
  /// **'Vybrat plán'**
  String get nastVybratPlan;

  /// No description provided for @nastZobrazitPlany.
  ///
  /// In cs, this message translates to:
  /// **'Zobrazit plány'**
  String get nastZobrazitPlany;

  /// No description provided for @nastDayJeden.
  ///
  /// In cs, this message translates to:
  /// **'den'**
  String get nastDayJeden;

  /// No description provided for @nastDayNeco.
  ///
  /// In cs, this message translates to:
  /// **'dny'**
  String get nastDayNeco;

  /// No description provided for @nastDayMnogo.
  ///
  /// In cs, this message translates to:
  /// **'dní'**
  String get nastDayMnogo;

  /// No description provided for @zamModZamestnanci.
  ///
  /// In cs, this message translates to:
  /// **'Zaměstnanci'**
  String get zamModZamestnanci;

  /// No description provided for @zamModNastaveni.
  ///
  /// In cs, this message translates to:
  /// **'Nastavení'**
  String get zamModNastaveni;

  /// No description provided for @zamChyba.
  ///
  /// In cs, this message translates to:
  /// **'Chyba: {chyba}'**
  String zamChyba(String chyba);

  /// No description provided for @zamTitle.
  ///
  /// In cs, this message translates to:
  /// **'Tým a oprávnění'**
  String get zamTitle;

  /// No description provided for @zamSubtitle.
  ///
  /// In cs, this message translates to:
  /// **'Spravujte členy svého servisu a jejich přístup do aplikace.'**
  String get zamSubtitle;

  /// No description provided for @zamPrazdny.
  ///
  /// In cs, this message translates to:
  /// **'Zatím nemáte žádné členy týmu.'**
  String get zamPrazdny;

  /// No description provided for @zamPridatClena.
  ///
  /// In cs, this message translates to:
  /// **'Přidat člena týmu'**
  String get zamPridatClena;

  /// No description provided for @zamLimitTitle.
  ///
  /// In cs, this message translates to:
  /// **'Dosažen limit účtů'**
  String get zamLimitTitle;

  /// No description provided for @zamLimitText.
  ///
  /// In cs, this message translates to:
  /// **'Plán {plan} umožňuje maximálně {limit} uživatelských účtů. Aktuálně využíváte {pocet}/{limit}. Pro přidání dalších členů týmu upgradujte plán.'**
  String zamLimitText(String plan, int limit, int pocet);

  /// No description provided for @zamZrusit.
  ///
  /// In cs, this message translates to:
  /// **'Zrušit'**
  String get zamZrusit;

  /// No description provided for @zamUpgradovat.
  ///
  /// In cs, this message translates to:
  /// **'Upgradovat plán'**
  String get zamUpgradovat;

  /// No description provided for @zamNovyClen.
  ///
  /// In cs, this message translates to:
  /// **'Nový člen týmu'**
  String get zamNovyClen;

  /// No description provided for @zamJmenoLabel.
  ///
  /// In cs, this message translates to:
  /// **'Jméno a příjmení *'**
  String get zamJmenoLabel;

  /// No description provided for @zamEmailLabel.
  ///
  /// In cs, this message translates to:
  /// **'Přihlašovací e-mail *'**
  String get zamEmailLabel;

  /// No description provided for @zamHesloLabel.
  ///
  /// In cs, this message translates to:
  /// **'Přihlašovací heslo (min. 6 znaků) *'**
  String get zamHesloLabel;

  /// No description provided for @zamVychoziPrava.
  ///
  /// In cs, this message translates to:
  /// **'Výchozí přístupová práva'**
  String get zamVychoziPrava;

  /// No description provided for @zamVytvoritUcet.
  ///
  /// In cs, this message translates to:
  /// **'Vytvořit účet'**
  String get zamVytvoritUcet;

  /// No description provided for @zamErrVyplnte.
  ///
  /// In cs, this message translates to:
  /// **'Vyplňte prosím jméno, e-mail i heslo.'**
  String get zamErrVyplnte;

  /// No description provided for @zamErrHesloKratke.
  ///
  /// In cs, this message translates to:
  /// **'Heslo musí mít alespoň 6 znaků.'**
  String get zamErrHesloKratke;

  /// No description provided for @zamUcetVytvoren.
  ///
  /// In cs, this message translates to:
  /// **'Účet vytvořen.'**
  String get zamUcetVytvoren;

  /// No description provided for @zamErrOvereni.
  ///
  /// In cs, this message translates to:
  /// **'Chyba ověření.'**
  String get zamErrOvereni;

  /// No description provided for @zamErrHesloSlabe.
  ///
  /// In cs, this message translates to:
  /// **'Zadané heslo je příliš slabé.'**
  String get zamErrHesloSlabe;

  /// No description provided for @zamErrEmailExistuje.
  ///
  /// In cs, this message translates to:
  /// **'Účet s tímto e-mailem již existuje.'**
  String get zamErrEmailExistuje;

  /// No description provided for @zamErrEmailFormat.
  ///
  /// In cs, this message translates to:
  /// **'Neplatný formát e-mailu.'**
  String get zamErrEmailFormat;

  /// No description provided for @zamErrNeocekavana.
  ///
  /// In cs, this message translates to:
  /// **'Neočekávaná chyba: {chyba}'**
  String zamErrNeocekavana(String chyba);

  /// No description provided for @zamPristupovaPrava.
  ///
  /// In cs, this message translates to:
  /// **'Přístupová práva'**
  String get zamPristupovaPrava;

  /// No description provided for @zamUlozitOpravneni.
  ///
  /// In cs, this message translates to:
  /// **'Uložit oprávnění'**
  String get zamUlozitOpravneni;

  /// No description provided for @zamUdelitVse.
  ///
  /// In cs, this message translates to:
  /// **'Udělit vše'**
  String get zamUdelitVse;

  /// No description provided for @zamOdebratVse.
  ///
  /// In cs, this message translates to:
  /// **'Odebrat vše'**
  String get zamOdebratVse;

  /// No description provided for @zamOdstranit.
  ///
  /// In cs, this message translates to:
  /// **'Odstranit'**
  String get zamOdstranit;

  /// No description provided for @zamOdstranitTitle.
  ///
  /// In cs, this message translates to:
  /// **'Odstranit člena týmu?'**
  String get zamOdstranitTitle;

  /// No description provided for @zamOdstranitText.
  ///
  /// In cs, this message translates to:
  /// **'Opravdu chcete odstranit člena {jmeno}? Ztratí přístup do aplikace. Tuto akci nelze vrátit zpět.'**
  String zamOdstranitText(String jmeno);

  /// No description provided for @zamClenOdstranen.
  ///
  /// In cs, this message translates to:
  /// **'Člen týmu byl odstraněn.'**
  String get zamClenOdstranen;

  /// No description provided for @zamPocetUzivatelu.
  ///
  /// In cs, this message translates to:
  /// **'{pocet} uživatelů'**
  String zamPocetUzivatelu(int pocet);

  /// No description provided for @zamPocetLimit.
  ///
  /// In cs, this message translates to:
  /// **'{pocet} / {limit} uživatelů'**
  String zamPocetLimit(int pocet, int limit);

  /// No description provided for @zamPlanBezLimitu.
  ///
  /// In cs, this message translates to:
  /// **'Plán {plan} · bez limitu'**
  String zamPlanBezLimitu(String plan);

  /// No description provided for @zamPlanLimitDosazen.
  ///
  /// In cs, this message translates to:
  /// **'Plán {plan} · limit dosažen'**
  String zamPlanLimitDosazen(String plan);

  /// No description provided for @zamPlanZbyva.
  ///
  /// In cs, this message translates to:
  /// **'Plán {plan} · zbývá {zbyva}'**
  String zamPlanZbyva(String plan, int zbyva);

  /// No description provided for @zamBezJmena.
  ///
  /// In cs, this message translates to:
  /// **'Bez jména'**
  String get zamBezJmena;

  /// No description provided for @zamBezPrav.
  ///
  /// In cs, this message translates to:
  /// **'Bez rozšířených práv'**
  String get zamBezPrav;

  /// No description provided for @zamBadgeAdmin.
  ///
  /// In cs, this message translates to:
  /// **'ADMIN'**
  String get zamBadgeAdmin;

  /// No description provided for @zamBadgeClen.
  ///
  /// In cs, this message translates to:
  /// **'ČLEN'**
  String get zamBadgeClen;
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
