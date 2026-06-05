// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appName => 'TORKIS';

  @override
  String get btnUlozit => 'Uložit';

  @override
  String get btnZrusit => 'Zrušit';

  @override
  String get btnPotvrdit => 'Potvrdit';

  @override
  String get btnZavrit => 'Zavřít';

  @override
  String get btnNovySken => 'Nový sken';

  @override
  String get btnSpustitSken => 'Spustit sken →';

  @override
  String get btnZacitPouzivat => 'Začít používat aplikaci';

  @override
  String get btnPlany => 'Plány';

  @override
  String get nacitani => 'Načítání…';

  @override
  String get chybaObecna => 'Nastala chyba.';

  @override
  String get zadejteVin => 'Zadejte VIN kód.';

  @override
  String get zadejteVinRucne => 'Zadat VIN ručně (např. TMBJJ7NE5K…)';

  @override
  String get vinDekoderNav => 'VIN';

  @override
  String get vinDekoderTabDekodovani => 'Dekódování VIN';

  @override
  String get vinDekoderTabTrzniHodnota => 'Tržní hodnota';

  @override
  String get vinDekoderTabStk => 'Zjištění STK';

  @override
  String get vinDekoderTitle => 'Dekodér VIN';

  @override
  String get vinDekoderSubtitle =>
      'Rychlé vyhledání specifikace vozu z VIN kódu';

  @override
  String get trzniHodnotaTitle => 'Tržní hodnota';

  @override
  String get trzniHodnotaSubtitle =>
      'Odhad tržní ceny vozidla z dat evropského trhu';

  @override
  String get stkTitle => 'Zjištění STK';

  @override
  String get stkSubtitle => 'Přehled technických prohlídek vozidla z registru';

  @override
  String get skenVinKod => 'Skenovat VIN kód';

  @override
  String get skenVinProTrzni => 'Skenovat VIN pro tržní hodnotu';

  @override
  String get skenVinProStk => 'Skenovat VIN pro STK';

  @override
  String get skenVinPopis =>
      'Automaticky načte specifikace vozu podle naskenovaného nebo zadaného VIN';

  @override
  String get skenVinTrzniPopis =>
      'Zjistí odhad tržní ceny vozu podle naskenovaného nebo zadaného VIN z dat evropského trhu';

  @override
  String get skenVinStkPopis =>
      'Načte data o technických prohlídkách vozidla z registru';

  @override
  String get dekodovat => 'Dekódovat';

  @override
  String get zjstitHodnotu => 'Zjistit hodnotu';

  @override
  String get zjstitStk => 'Zjistit STK';

  @override
  String get stkPlatna => 'STK platná';

  @override
  String get stkNeplatna => 'STK neplatná';

  @override
  String stkPlatnaJeste(int dni) {
    return 'STK platná ještě $dni dní';
  }

  @override
  String stkProsla(int dni) {
    return 'STK neplatná (prošlá o $dni dní)';
  }

  @override
  String get stkDatumNeznamo => 'STK — datum neznámé';

  @override
  String get stkPlatnostDo => 'Platnost STK do';

  @override
  String get stkInfoBanner =>
      'Data pocházejí z veřejného registru vozidel. Dostupnost a aktuálnost se liší — u některých vozidel nemusí být STK evidována.';

  @override
  String get trzniHodnotaTitle2 => 'TRŽNÍ HODNOTA';

  @override
  String get trzniMedian => 'medián';

  @override
  String get trzniPrumernaCena => 'Průměrná cena';

  @override
  String get trzniPrumernyNajezd => 'Průměrný nájezd';

  @override
  String get trzniPocetVzorku => 'Počet vzorků';

  @override
  String get trzniObdobiDat => 'Období dat';

  @override
  String get trzniZdroj => 'Evropský trh · Vincario Market Value';

  @override
  String get trzniNeniData => 'Evropská data nejsou k dispozici.';

  @override
  String get historieNacitani => 'Načítání…';

  @override
  String get historieSken => 'Historie skenů';

  @override
  String get historiePrvniDekodovani => 'Poprvé dekódováno';

  @override
  String get historieNeznameVozidlo => 'Neznámé vozidlo';

  @override
  String get historieZadneSken => 'Zatím žádné skeny.';

  @override
  String get historieVse => 'Vše';

  @override
  String historieDnes(int pocet) {
    return 'Dnes · $pocet dekódovaných VIN';
  }

  @override
  String get historiePosledniSkeny => 'Poslední skeny';

  @override
  String get historieNoveVozidlo => 'Nové vozidlo';

  @override
  String historieDekodovanoXKrat(int pocet) {
    return 'Dekódováno $pocet×';
  }

  @override
  String get limitVyprsel =>
      'Měsíční limit vyčerpán. Upgradujte plán pro pokračování.';

  @override
  String get limitDekodovaniTitle => 'Dekódování VIN tento měsíc';

  @override
  String get limitTrzniTitle => 'Tržní hodnota tento měsíc';

  @override
  String get upsellTrzniTitle => 'Tržní hodnota je v placených plánech';

  @override
  String get upsellTrzniText =>
      'Ve zkušební verzi není dostupná. Odemknete ji už v plánu Basic.';

  @override
  String chybaDekodovani(String zprava) {
    return 'Nepodařilo se dekódovat VIN: $zprava';
  }

  @override
  String get trialWelcomeTitle => 'Vítejte v TORKISu';

  @override
  String get trialWelcomeSubtitle =>
      'Spustili jsme vám zkušební dobu na 30 dní zdarma — bez platební karty a bez závazků.';

  @override
  String get trialWelcomePill => '30 DNÍ ZDARMA';

  @override
  String get trialWelcomeFooter =>
      'Po skončení trialu si vyberete plán, který vám sedne.';

  @override
  String get trialBenefitVozidla =>
      'Neomezený počet záznamů vozidel a zákazníků';

  @override
  String get trialBenefitVin => '10 dekódovaných VINů';

  @override
  String get trialBenefitStk => 'Neomezený počet zjištění platnosti STK';

  @override
  String get trialBenefitFunkce => 'Plný přístup ke všem funkcím aplikace.';

  @override
  String get trialBenefitKarta =>
      'Žádné platební údaje. Bez automatického strhávání.';

  @override
  String get trialBenefitData =>
      'Vaše data jsou vždy vaše — export kdykoli zdarma.';
}
