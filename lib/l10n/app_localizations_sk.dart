// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appName => 'TORKIS';

  @override
  String get btnUlozit => 'Uložiť';

  @override
  String get btnZrusit => 'Zrušiť';

  @override
  String get btnPotvrdit => 'Potvrdiť';

  @override
  String get btnZavrit => 'Zavrieť';

  @override
  String get btnNovySken => 'Nový sken';

  @override
  String get btnSpustitSken => 'Spustiť sken →';

  @override
  String get btnZacitPouzivat => 'Začať používať aplikáciu';

  @override
  String get btnPlany => 'Plány';

  @override
  String get nacitani => 'Načítava sa…';

  @override
  String get chybaObecna => 'Nastala chyba.';

  @override
  String get zadejteVin => 'Zadajte VIN kód.';

  @override
  String get zadejteVinRucne => 'Zadať VIN ručne (napr. TMBJJ7NE5K…)';

  @override
  String get vinDekoderNav => 'VIN';

  @override
  String get vinDekoderTabDekodovani => 'Dekódovanie VIN';

  @override
  String get vinDekoderTabTrzniHodnota => 'Trhová hodnota';

  @override
  String get vinDekoderTabStk => 'Zistenie TK';

  @override
  String get vinDekoderTitle => 'Dekodér VIN';

  @override
  String get vinDekoderSubtitle =>
      'Rýchle vyhľadanie špecifikácie vozidla podľa VIN kódu';

  @override
  String get trzniHodnotaTitle => 'Trhová hodnota';

  @override
  String get trzniHodnotaSubtitle =>
      'Odhad trhovej ceny vozidla z dát európskeho trhu';

  @override
  String get stkTitle => 'Zistenie TK';

  @override
  String get stkSubtitle => 'Prehľad technických prehliadok vozidla z registra';

  @override
  String get skenVinKod => 'Skenovať VIN kód';

  @override
  String get skenVinProTrzni => 'Skenovať VIN pre trhovú hodnotu';

  @override
  String get skenVinProStk => 'Skenovať VIN pre TK';

  @override
  String get skenVinPopis =>
      'Automaticky načíta špecifikácie vozidla podľa naskenovaného alebo zadaného VIN';

  @override
  String get skenVinTrzniPopis =>
      'Zistí odhad trhovej ceny vozidla z dát európskeho trhu';

  @override
  String get skenVinStkPopis =>
      'Načíta dáta o technických prehliadkach vozidla z registra';

  @override
  String get dekodovat => 'Dekódovať';

  @override
  String get zjstitHodnotu => 'Zistiť hodnotu';

  @override
  String get zjstitStk => 'Zistiť TK';

  @override
  String get stkPlatna => 'TK platná';

  @override
  String get stkNeplatna => 'TK neplatná';

  @override
  String stkPlatnaJeste(int dni) {
    return 'TK platná ešte $dni dní';
  }

  @override
  String stkProsla(int dni) {
    return 'TK neplatná (prešla o $dni dní)';
  }

  @override
  String get stkDatumNeznamo => 'TK — dátum neznámy';

  @override
  String get stkPlatnostDo => 'Platnosť TK do';

  @override
  String get stkInfoBanner =>
      'Dáta pochádzajú z verejného registra vozidiel. Dostupnosť a aktuálnosť sa líšia — u niektorých vozidiel nemusí byť TK evidovaná.';

  @override
  String get trzniHodnotaTitle2 => 'TRHOVÁ HODNOTA';

  @override
  String get trzniMedian => 'medián';

  @override
  String get trzniPrumernaCena => 'Priemerná cena';

  @override
  String get trzniPrumernyNajezd => 'Priemerný nájazd';

  @override
  String get trzniPocetVzorku => 'Počet vzoriek';

  @override
  String get trzniObdobiDat => 'Obdobie dát';

  @override
  String get trzniZdroj => 'Európsky trh · Vincario Market Value';

  @override
  String get trzniNeniData => 'Európske dáta nie sú k dispozícii.';

  @override
  String get historieNacitani => 'Načítava sa…';

  @override
  String get historieSken => 'História skenov';

  @override
  String get historiePrvniDekodovani => 'Prvýkrát dekódované';

  @override
  String get historieNeznameVozidlo => 'Neznáme vozidlo';

  @override
  String get historieZadneSken => 'Zatiaľ žiadne skeny.';

  @override
  String get historieVse => 'Všetky';

  @override
  String historieDnes(int pocet) {
    return 'Dnes · $pocet dekódovaných VIN';
  }

  @override
  String get historiePosledniSkeny => 'Posledné skeny';

  @override
  String get historieNoveVozidlo => 'Nové vozidlo';

  @override
  String historieDekodovanoXKrat(int pocet) {
    return 'Dekódované $pocet×';
  }

  @override
  String get limitVyprsel =>
      'Mesačný limit vyčerpaný. Upgradujte plán pre pokračovanie.';

  @override
  String get limitDekodovaniTitle => 'Dekódovania VIN tento mesiac';

  @override
  String get limitTrzniTitle => 'Zistenia trhovej hodnoty tento mesiac';

  @override
  String get upsellTrzniTitle => 'Trhová hodnota je v platených plánoch';

  @override
  String get upsellTrzniText =>
      'V skúšobnej verzii nie je dostupná. Odomknete ju už v pláne Basic.';

  @override
  String chybaDekodovani(String zprava) {
    return 'Nepodarilo sa dekódovať VIN: $zprava';
  }

  @override
  String get trialWelcomeTitle => 'Vitajte v TORKISe';

  @override
  String get trialWelcomeSubtitle =>
      'Spustili sme vám skúšobnú dobu na 30 dní zdarma — bez platobnej karty a bez záväzkov.';

  @override
  String get trialWelcomePill => '30 DNÍ ZDARMA';

  @override
  String get trialWelcomeFooter =>
      'Po skončení trialu si vyberiete plán, ktorý vám sadne.';

  @override
  String get trialBenefitVozidla =>
      'Neobmedzený počet záznamov vozidiel a zákazníkov';

  @override
  String get trialBenefitVin => '10 dekódovaných VINov';

  @override
  String get trialBenefitStk => 'Neobmedzený počet zistení platnosti TK';

  @override
  String get trialBenefitFunkce =>
      'Plný prístup ku všetkým funkciám aplikácie.';

  @override
  String get trialBenefitKarta =>
      'Žiadne platobné údaje. Bez automatického strhávania.';

  @override
  String get trialBenefitData =>
      'Vaše dáta sú vždy vaše — export kedykoľvek zdarma.';
}
