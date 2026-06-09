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
  String get trialWelcomePill => '30 DNÍ ZADARMO';

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

  @override
  String get vozidloStatTacho => 'TACHOMETER';

  @override
  String get vozidloStatStkDo => 'TK DO';

  @override
  String get vozidloStatPrijmu => 'SERVISOV';

  @override
  String get vozidloStkPlatna => 'TK platná';

  @override
  String get vozidloStkProsla => 'TK prešla';

  @override
  String vozidloStkVyprsiBehemMesicu(String mesic, String rok, int pocet) {
    return 'Vyprší $mesic/$rok · zostáva $pocet mesiacov';
  }

  @override
  String vozidloStkVyprsela(String mesic, String rok) {
    return 'Vypršala $mesic/$rok';
  }

  @override
  String get vozidloTechnickeUdaje => 'Technické údaje';

  @override
  String get vozidloZnackaModel => 'Značka & Model';

  @override
  String get vozidloMotorizace => 'Motorizácia';

  @override
  String get vozidloVin => 'VIN';

  @override
  String get vozidloRokVyroby => 'Rok výroby';

  @override
  String get vozidloPalivo => 'Palivo';

  @override
  String get vozidloPrevodovka => 'Prevodovka';

  @override
  String get vozidloBarva => 'Farba';

  @override
  String get vozidloVykon => 'Výkon';

  @override
  String get vozidloPocetMistDveri => 'Miesta / dvere';

  @override
  String get vozidloRozmery => 'Rozmery';

  @override
  String get vozidloUdajeZVin => 'Údaje z VIN';

  @override
  String get vozidloTachometrLabel => 'Tachometer';

  @override
  String get vozidloMajitel => 'Majiteľ vozidla';

  @override
  String get vozidloJmeno => 'Meno';

  @override
  String get vozidloTelefon => 'Telefón';

  @override
  String get vozidloEmail => 'E-mail';

  @override
  String get vozidloVolat => 'Volať';

  @override
  String get vozidlaTitle => 'Databáza vozidiel';

  @override
  String get vozidlaSubtitle => 'Prehľad všetkých servisovaných áut.';

  @override
  String get vozidlaHledatHint => 'Hľadať EČV, Značku alebo VIN...';

  @override
  String get vozidlaSkenSpzTooltip => 'Naskenovať EČV fotoaparátom';

  @override
  String get vozidlaZadnaVozidla => 'Zatiaľ nemáte v databáze žiadne vozidlá.';

  @override
  String get vozidlaNejstePrihlaseni => 'Nie ste prihlásení.';

  @override
  String get vozidlaSkenJenApp =>
      'Skenovanie funguje iba v nainštalovanej aplikácii (APK/iOS).';

  @override
  String get vozidloDetailUprava => 'Úprava vozidla';

  @override
  String get vozidloDetailSpz => 'EČV';

  @override
  String get vozidloDetailZnacka => 'Značka';

  @override
  String get vozidloDetailModel => 'Model';

  @override
  String get vozidloDetailTachoKm => 'Tachometer (km)';

  @override
  String get vozidloDetailPlatnostStk => 'Platnosť TK';

  @override
  String get vozidloDetailStkMesic => 'Mesiac (MM)';

  @override
  String get vozidloDetailStkRok => 'Rok (YYYY)';

  @override
  String get vozidloDetailUlozitZmeny => 'ULOŽIŤ ZMENY';

  @override
  String get vozidloDetailSpzExistuje => 'Vozidlo s týmto EČV už existuje!';

  @override
  String vozidloDetailPrejmenovano(String spz) {
    return 'Vozidlo premenované na $spz. História bola zachovaná.';
  }

  @override
  String get vozidloDetailNenalezeno => 'Vozidlo nenájdené.';

  @override
  String get vozidloDetailBezSpz => 'Vozidlo bez EČV';

  @override
  String get vozidloDetailLabel => 'VOZIDLO';

  @override
  String get vozidloTabInfo => 'Info';

  @override
  String get vozidloTabZaznamy => 'Záznamy';

  @override
  String get vozidloSmazatAkce => 'Zmazať vozidlo';

  @override
  String get vozidloSmazatDialogTitle => 'Zmazať vozidlo?';

  @override
  String get vozidloSmazatDialogText =>
      'Vozidlo bude odobrané z adresára. História zákaziek zostane zachovaná.';

  @override
  String get vozidloSmazano => 'Vozidlo bolo zmazané.';

  @override
  String get vozidloSmazatBtn => 'Zmazať';

  @override
  String get prijemHelperTelefon => 'Telefónne číslo';

  @override
  String get prijemHelperPredvolba => 'Vyberte predvoľbu';

  @override
  String get prijemStavTitle => 'Stav vozidla';

  @override
  String get prijemStavTacho => 'Stav tachometra (km)';

  @override
  String prijemStavNadrz(int value) {
    return 'Stav paliva v nádrži ($value %)';
  }

  @override
  String get prijemStavPoskozeni => 'Zistené poškodenia (možno vybrať viac)';

  @override
  String get prijemStavVlastniPopis => 'Vlastný popis poškodenia...';

  @override
  String get prijemStavPridat => 'Pridať vlastné poškodenie';

  @override
  String get prijemStavPlatnostStk => 'Platnosť TK';

  @override
  String get prijemStavMesic => 'Mesiac';

  @override
  String get prijemStavRok => 'Rok';

  @override
  String get prijemStavPneu => 'Hĺbka dezénu pneumatík (mm)';

  @override
  String get prijemStavLevaPreh => 'Ľavá pred.';

  @override
  String get prijemStavPravaPreh => 'Pravá pred.';

  @override
  String get prijemStavLevaZad => 'Ľavá zad.';

  @override
  String get prijemStavPravaZad => 'Pravá zad.';

  @override
  String get prijemStavPoznamky => 'Ďalšie poznámky k vozidlu';

  @override
  String get prijemStavPoznamkyHint => 'Akékoľvek ďalšie detaily k príjmu...';

  @override
  String get prijemZakaznikTitle => 'Údaje o zákazníkovi';

  @override
  String get prijemZakaznikJmeno => 'Meno a priezvisko / Názov firmy';

  @override
  String get prijemZakaznikHledat => 'Hľadať uloženého zákazníka';

  @override
  String get prijemZakaznikIco => 'IČO (vyhľadávanie v registri)';

  @override
  String get prijemZakaznikHledatAres => 'Hľadať v registri';

  @override
  String get prijemZakaznikPravniForma => 'Právna forma';

  @override
  String get prijemZakaznikUlice => 'Ulica a číslo';

  @override
  String get prijemZakaznikMesto => 'Mesto';

  @override
  String get prijemZakaznikPsc => 'PSČ';

  @override
  String get prijemZakaznikEmail => 'E-mail';

  @override
  String get prijemZakaznikFyzicka => 'Fyzická osoba';

  @override
  String get prijemZakaznikOsvc => 'SZČO';

  @override
  String get prijemVozidloTitle => 'Záznam vozidla';

  @override
  String get prijemVozidloNapoveda =>
      'Naskenujte VIN alebo EČV alebo údaje doplňte ručne.';

  @override
  String get prijemVozidloZeme => 'Krajina';

  @override
  String get prijemVozidloSpz => 'EČV vozidla';

  @override
  String get prijemVozidloHledatSpz => 'Hľadať EČV v databáze';

  @override
  String get prijemVozidloHledatSpzSub =>
      'Nájsť skôr uložené vozidlo podľa EČV';

  @override
  String get prijemVozidloVin => 'VIN kód';

  @override
  String get prijemVozidloHledatVin => 'Hľadať VIN v databáze';

  @override
  String get prijemVozidloHledatVinSub =>
      'Nájsť skôr uložené vozidlo podľa VIN';

  @override
  String get prijemVozidloDekodovat => 'Dekódovať VIN online';

  @override
  String get prijemVozidloDekodovatSub =>
      'Doplniť značku, model, motorizáciu a TK';

  @override
  String get prijemVozidloZnackaHint => 'Značka (napr. Škoda)';

  @override
  String get prijemVozidloModelHint => 'Model (napr. Octavia)';

  @override
  String get prijemVozidloSkenovat => 'Skenovať VIN/EČV';

  @override
  String get prijemVozidloSkenSub => 'Automaticky rozpozná typ kódu';

  @override
  String get prijemVozidloRozlozeniPodSebou => 'Pod sebou';

  @override
  String get prijemVozidloRozlozeniVMrizce => 'V mriežke';

  @override
  String get prijemVozidloTypZaznamu => 'Typ záznamu';

  @override
  String get prijemVozidloCisloZaznamu => 'Číslo záznamu';

  @override
  String get prijemVozidloGenerovat => 'Vygenerovať nové číslo';

  @override
  String get prijemVozidloUlozenaVozidla => 'Zákazník má uložené tieto vozidlá';

  @override
  String get prijemVozidloRokVyroby => 'Rok výroby';

  @override
  String get prijemVozidloMotorizaceHint => 'Motorizácia (napr. 2.0 TDI)';

  @override
  String get prijemVozidloTypPaliva => 'Typ paliva';

  @override
  String get prijemVozidloPrevodovka => 'Prevodovka';

  @override
  String get prijemVozidloTypKaroserie => 'Typ karosérie';

  @override
  String get prijemVozidloBenzin => 'Benzín';

  @override
  String get prijemVozidloNafta => 'Nafta';

  @override
  String get prijemVozidloElektro => 'Elektro';

  @override
  String get prijemVozidloHybrid => 'Hybrid';

  @override
  String get prijemVozidloLpgCng => 'LPG/CNG';

  @override
  String get prijemVozidloJine => 'Iné';

  @override
  String get prijemVozidloManualni => 'Manuálna';

  @override
  String get prijemVozidloAutomaticka => 'Automatická';

  @override
  String get prijemVozidloDalsiUdaje => 'Ďalšie údaje o vozidle';

  @override
  String get prijemVozidloDalsiUdajeSub =>
      'Nepovinné – doplnia sa z VIN dekodéra';

  @override
  String get prijemVozidloBarva => 'Farba';

  @override
  String get prijemVozidloVykon => 'Výkon (kW)';

  @override
  String get prijemVozidloPocetMist => 'Počet miest';

  @override
  String get prijemVozidloPocetDveri => 'Počet dverí';

  @override
  String get prijemVozidloRozmery => 'Rozmery (D × Š × V mm)';

  @override
  String get prijemVozidloDelka => 'Dĺžka';

  @override
  String get prijemVozidloSirka => 'Šírka';

  @override
  String get prijemVozidloVyska => 'Výška';

  @override
  String get prijemPraceTitle => 'Požadované práce';

  @override
  String get prijemPracePozadavkyHint => 'Na čom sme sa so zákazníkom dohodli?';

  @override
  String get prijemPraceRychlyVyber => 'Rýchly výber najčastejších úkonov:';

  @override
  String get prijemPraceSeznam => 'Zoznam požiadaviek k zákazke:';

  @override
  String get prijemPracePridat => 'Pridať iný úkon';

  @override
  String prijemPraceUkonN(int n) {
    return 'Úkon $n';
  }

  @override
  String get prijemPodpisTitle => 'Súhrn';

  @override
  String get prijemPodpisNeuvedeno => 'Neuvedené';

  @override
  String prijemPodpisZakaznik(String jmeno) {
    return 'Zákazník: $jmeno';
  }

  @override
  String prijemPodpisAdresa(String adresa) {
    return 'Adresa: $adresa';
  }

  @override
  String prijemPodpisVozidlo(String spzZnacka) {
    return 'Vozidlo: $spzZnacka';
  }

  @override
  String get prijemPodpisSjednaneUkony => 'Dohodnuté úkony:';

  @override
  String get prijemRekapZaznam => 'Záznam';

  @override
  String get prijemKonceptTitle => 'Neodoslaná zákazka';

  @override
  String get prijemKonceptText =>
      'Máte rozpracovanú neodoslanú zákazku. Chcete pokračovať tam, kde ste skončili?';

  @override
  String get prijemKonceptObnovit => 'Obnoviť';

  @override
  String get prijemKonceptZahodit => 'Zahodiť';

  @override
  String get prijemPodpisEmailToggle => 'Odoslať kópiu protokolu e-mailom';

  @override
  String get prijemPodpisEmailChybi =>
      'Zákazník (krok 2) nemá vyplnený e-mail.';

  @override
  String prijemPodpisEmailKam(String email) {
    return 'Bude odoslané na: $email';
  }

  @override
  String get prijemPodpisSouhlas =>
      'Zákazník svojím podpisom potvrdzuje správnosť vyššie uvedených údajov a súhlasí so stavom vozidla pri prevzatí do servisu.';

  @override
  String get prijemPodpisSmazat => 'Zmazať podpis';

  @override
  String get prijemPodpisVypnut =>
      'Podpis zákazníka je v nastavení servisu vypnutý.';

  @override
  String get prijemPodpisOtevrit => 'Podpísať';

  @override
  String get prijemPodpisZnovu => 'Podpísať znova';

  @override
  String get prijemPodpisHotovo => 'Hotovo';

  @override
  String get prijemPodpisZavrit => 'Zavrieť';

  @override
  String get prijemPodpisHint => 'Podpíšte sa prstom alebo perom';

  @override
  String get prijemPodpisNahled => 'Podpis zákazníka';

  @override
  String get prijemPodpisZahoditTitul => 'Zahodiť podpis?';

  @override
  String get prijemPodpisZahoditPomoc =>
      'Máte rozpísaný podpis. Naozaj ho zahodiť?';

  @override
  String get prijemPodpisZahodit => 'Zahodiť';

  @override
  String get prijemTabletPostup => 'POSTUP';

  @override
  String get prijemTabletPosledniNavsteva => 'POSLEDNÁ NÁVŠTEVA';

  @override
  String get prijemTabletVozidlo => 'Vozidlo';

  @override
  String get prijemTabletTacho => 'Tachometer';

  @override
  String get prijemTabletStk => 'TK';

  @override
  String get prijemTabletNaposledy => 'Naposledy';

  @override
  String get prijemTabletStav => 'Stav';

  @override
  String get prijemTabletStavPriPrijmu => 'Stav pri príjme';

  @override
  String get prijemTabletPoskozeni => 'Poškodenia';

  @override
  String get prijemTabletNeuvedeno => 'Neuvedené';

  @override
  String get prijemTabletNahled => 'NÁHĽAD VOZIDLA';

  @override
  String get prijemTabletSpz => 'EČV';

  @override
  String get prijemTabletVin => 'VIN';

  @override
  String get prijemTabletZakazka => 'Zákazka';

  @override
  String get prijemTabletUdajePlni =>
      'Údaje sa plnia priebežne pri vypĺňaní formulára.';

  @override
  String get prijemErrVinVyhledani => 'Zadajte aspoň časť VIN pre vyhľadanie.';

  @override
  String get prijemErrServisId => 'Chyba: ID Servisu sa nepodarilo načítať.';

  @override
  String get prijemErrZadneVozidloVin =>
      'Žiadne vozidlo s týmto VIN nebolo nájdené.';

  @override
  String get prijemErrSpzVyhledani => 'Zadajte aspoň časť EČV pre vyhľadanie.';

  @override
  String get prijemErrZadneVozidloSpz =>
      'Žiadne vozidlo s týmto EČV nebolo nájdené.';

  @override
  String get prijemErrZadejteVin => 'Zadajte VIN kód pre dekódovanie.';

  @override
  String prijemStkPlatnaSnackbar(String datum) {
    return 'TK platná do $datum';
  }

  @override
  String prijemStkProslaSnackbar(String datum) {
    return 'TK prešla! Platila do $datum';
  }

  @override
  String get prijemVincarioDoplneno => 'Údaje vozidla doplnené z Vincario.';

  @override
  String get prijemVozidloNacteno =>
      'Údaje o vozidle a zákazníkovi boli načítané.';

  @override
  String get prijemNalezenoVice => 'Nájdených viac vozidiel';

  @override
  String get prijemVyberVozidlo => 'Vyberte konkrétne vozidlo zo zoznamu:';

  @override
  String get prijemNeznanaSpz => 'Neznáme EČV';

  @override
  String get prijemErrCisloASpz => 'Číslo záznamu a EČV sú povinné údaje!';

  @override
  String get prijemErrCislo => 'Číslo záznamu je povinný údaj!';

  @override
  String get prijemErrSpz => 'EČV vozidla je povinný údaj!';

  @override
  String get prijemErrCisloDuplicitni =>
      'Toto číslo záznamu už v databáze existuje! Zadajte iné.';

  @override
  String get prijemErrPodpis => 'Zákazník musí pripojiť podpis pred odoslaním.';

  @override
  String get prijemLimitTitle => 'Dosiahnutý limit príjmov';

  @override
  String prijemLimitText(String plan, int limit) {
    return 'Váš plán $plan umožňuje maximálne $limit príjmov za mesiac. Pre viac príjmov upgradujte plán.';
  }

  @override
  String get prijemZavrit => 'Zavrieť';

  @override
  String get prijemUspesne => 'Zákazka úspešne odoslaná';

  @override
  String get prijemErrNejstePrirazeni =>
      'Nie ste priradení k žiadnemu servisu!';

  @override
  String get prijemSkenJenApp =>
      'Skenovanie pomocou AI funguje iba v nainštalovanej aplikácii (APK/iOS).';

  @override
  String get prijemNavigaceLabel => 'ZÁZNAM VOZIDLA';

  @override
  String get prijemNovyZaznam => 'Nový záznam';

  @override
  String get prijemDokoncit => 'Dokončiť a odoslať';

  @override
  String get prijemPokracovat => 'Pokračovať';

  @override
  String get prijemOdesilamMsg => 'Odosielam zákazku a protokol...';

  @override
  String prijemNahravamFotky(int hotovo, int celkem) {
    return 'Nahrávam fotky $hotovo/$celkem';
  }

  @override
  String prijemKrokZ(int krok, int celkem) {
    return 'Krok $krok z $celkem';
  }

  @override
  String get prijemStepIdentifikace => 'Identifikácia vozidla';

  @override
  String get prijemStepZakaznik => 'Zákazník';

  @override
  String get prijemStepFoto => 'Fotodokumentácia';

  @override
  String get prijemStepStav => 'Stav vozidla';

  @override
  String get prijemStepPrace => 'Úkony a práce';

  @override
  String get prijemStepSouhrn => 'Súhrn';

  @override
  String prijemSkenNenalezeno(String co) {
    return 'Naskenované \'$co\'. V databáze nenájdené — údaje doplňte ručne.';
  }

  @override
  String get vinSekceIdentifikace => 'IDENTIFIKÁCIA';

  @override
  String get vinSekceMotor => 'MOTOR A POHON';

  @override
  String get vinSekceKaroserie => 'KAROSÉRIA A ROZMERY';

  @override
  String get vinSekcePalivo => 'PALIVO A EMISIE';

  @override
  String get vinSekceOstatni => 'OSTATNÉ INFORMÁCIE';

  @override
  String get vinFieldZnacka => 'Značka';

  @override
  String get vinFieldModel => 'Model';

  @override
  String get vinFieldObchodniOznaceni => 'Obchodné označenie';

  @override
  String get vinFieldRokVyroby => 'Rok výroby';

  @override
  String get vinFieldKaroserie => 'Karoséria';

  @override
  String get vinFieldTypVarianta => 'Typ / variant';

  @override
  String get vinFieldMistoVyroby => 'Miesto výroby';

  @override
  String get vinFieldMotorizace => 'Motorizácia';

  @override
  String get vinFieldTypMotoru => 'Typ motora';

  @override
  String get vinFieldZdvihObjem => 'Zdvihový objem';

  @override
  String get vinFieldPocetValcu => 'Počet valcov';

  @override
  String get vinFieldVykon => 'Výkon';

  @override
  String get vinFieldTocivyMoment => 'Max. krútiaci moment';

  @override
  String get vinFieldPalivo => 'Palivo';

  @override
  String get vinFieldPrevodovka => 'Prevodovka';

  @override
  String get vinFieldPocetPrevodu => 'Počet prevodov';

  @override
  String get vinFieldPohon => 'Pohon';

  @override
  String get vinFieldMaxRychlost => 'Max. rýchlosť';

  @override
  String get vinFieldTypKaroserie => 'Typ karosérie';

  @override
  String get vinFieldPocetDveri => 'Počet dverí';

  @override
  String get vinFieldPocetMist => 'Počet miest';

  @override
  String get vinFieldProvozniHmotnost => 'Prevádzková hmotnosť';

  @override
  String get vinFieldMaxHmotnost => 'Max. hmotnosť';

  @override
  String get vinFieldTaznaHmotnost => 'Ťažná hmotnosť';

  @override
  String get vinFieldRozvorNaprav => 'Rázvor náprav';

  @override
  String get vinFieldDelka => 'Dĺžka';

  @override
  String get vinFieldSirka => 'Šírka';

  @override
  String get vinFieldVyska => 'Výška';

  @override
  String get vinFieldObjemNadrze => 'Objem nádrže';

  @override
  String get vinField1Registrace => '1. registrácia';

  @override
  String get vinFieldEmisniNorma => 'Emisná norma';

  @override
  String get vinFieldEmiseCo2 => 'Emisie CO₂';

  @override
  String get vinFieldSpotrebaKomb => 'Spotreba (komb.)';

  @override
  String get vinFieldSpotrebaMesto => 'Spotreba v meste';

  @override
  String get vinFieldSpotrebaDalnice => 'Spotreba mimo mesta';

  @override
  String get vinFieldElektDojezd => 'Elektrický dojazd';

  @override
  String vinLimitDekodovani(int pocet, int limit) {
    return 'Dosiahli ste mesačný limit $pocet / $limit dekódovaní. Upgradujte plán pre pokračovanie.';
  }

  @override
  String vinLimitValue(int pocet, int limit) {
    return 'Dosiahli ste mesačný limit $pocet / $limit zistení.';
  }

  @override
  String get vinTrzniChybaVerze =>
      'Zistenie trhovej hodnoty nie je súčasťou skúšobnej verzie — odomknite ho v niektorom z platených plánov.';

  @override
  String get vinChybaHistorie => 'Nepodarilo sa načítať históriu.';

  @override
  String get vinTotoVozidloNebyloDekodovano =>
      'Toto vozidlo nebolo doteraz dekódované.';

  @override
  String get vinPraveTed => 'Práve teraz';

  @override
  String vinPredMinutami(int pocet) {
    return 'pred $pocet min';
  }

  @override
  String get vinVincarioKlice =>
      'Vincario API kľúče nie sú nastavené. Doplňte ich v Nastavení servisu.';

  @override
  String vinTrzniOd(String value, String mena) {
    return 'od $value $mena';
  }

  @override
  String vinTrzniDo(String value, String mena) {
    return 'do $value $mena';
  }

  @override
  String get vinTrzniHodnotaTitle => 'Trhová hodnota';

  @override
  String get vinStkTitle => 'Technická kontrola';

  @override
  String get vinTrzniSubtitle =>
      'Odhad trhovej ceny vozidla z dát európskeho trhu';

  @override
  String get vinStkSubtitle => 'Prehľad technických kontrol vozidla z registra';

  @override
  String get vinSkenTitleVin => 'Skenovať kód VIN';

  @override
  String get vinSkenTitleTrzni => 'Skenovať VIN pre trhovú hodnotu';

  @override
  String get vinSkenTitleStk => 'Skenovať VIN pre technickú kontrolu';

  @override
  String get vinSkenPopisVin =>
      'Automaticky načíta špecifikácie vozidla podľa naskenovaného alebo zadaného VIN';

  @override
  String get vinSkenPopisTrzni =>
      'Odhadne trhovú cenu vozidla podľa naskenovaného alebo zadaného VIN z dát európskeho trhu';

  @override
  String get vinSkenPopisStk =>
      'Načíta dáta o technických kontrolách vozidla z registra';

  @override
  String get vinSkenTlacitko => 'Spustiť skenovanie';

  @override
  String get vinInputHint => 'Zadať VIN ručne (napr. TMBJJ7NE5K…)';

  @override
  String get vinTooltipHodnota => 'Zistiť hodnotu';

  @override
  String get vinTooltipStk => 'Zistiť TK';

  @override
  String get vinTooltipDekodovat => 'Dekódovať';

  @override
  String get vinUpsellTitle => 'Trhová hodnota je v platených plánoch';

  @override
  String get vinUpsellSubtitle =>
      'V skúšobnej verzii nie je dostupná. Odomknete ju už v pláne Basic.';

  @override
  String get vinUpsellPlany => 'Plány';

  @override
  String get vinLimitTrzniMesic => 'Trhová hodnota tento mesiac';

  @override
  String get vinLimitDekodovaniMesic => 'Dekódovanie VIN tento mesiac';

  @override
  String get vinLimitVycerpan =>
      'Mesačný limit vyčerpaný. Inováciou plánu pokračujte.';

  @override
  String get vinStkInfoBanner =>
      'Dáta pochádzajú z verejného registra vozidiel. Dostupnosť a aktuálnosť sa líšia — u niektorých vozidiel nemusí byť TK evidovaná.';

  @override
  String vinChybaDekodovani(String chyba) {
    return 'Nepodarilo sa dekódovať VIN: $chyba';
  }

  @override
  String get vinNovySken => 'Nové skenovanie';

  @override
  String get vinTrzniHodnotaHeader => 'TRHOVÁ HODNOTA';

  @override
  String get vinStkPlatnostNeznama => 'TK — dátum neznámy';

  @override
  String vinStkPlatnaJesteXDni(int dnu) {
    return 'TK platná ešte $dnu dní';
  }

  @override
  String vinStkNeplatna(int dnu) {
    return 'TK neplatná (uplynulo $dnu dní)';
  }

  @override
  String get vinStkPlatnostDo => 'Platnosť TK do';

  @override
  String get vinTrzniDataNedostupna => 'Európske dáta nie sú k dispozícii.';

  @override
  String get vinTrzniMedian => 'medián';

  @override
  String get vinTrzniPrumernaCena => 'Priemerná cena';

  @override
  String get vinTrzniPrumernyNajezd => 'Priemerný nájazd';

  @override
  String get vinTrzniPocetVzorku => 'Počet vzoriek';

  @override
  String get vinTrzniObdobiDat => 'Obdobie dát';

  @override
  String get vinTrzniZdroj => 'Európsky trh · Vincario Market Value';

  @override
  String get vinTrzniNajezdLabel => 'Najazdené km vozidla';

  @override
  String get vinTrzniOdhad => 'Odhad podľa najazdených km';

  @override
  String get vinTrzniOdhadVysvetleni =>
      'Orientačný odhad zostatkovej hodnoty vypočítaný z rozsahu cien a najazdených km vo vzorke.';

  @override
  String get vinHistorieNadpis => 'História skenov';

  @override
  String vinHistorieDnes(int pocet) {
    return 'Dnes · $pocet dekódovaných VIN';
  }

  @override
  String get vinHistoriePosledni => 'Posledné skeny';

  @override
  String get vinHistorieVse => 'Všetky';

  @override
  String get vinHistorieNacitani => 'Načítavam…';

  @override
  String get vinHistorieZadneSkeny => 'Zatiaľ žiadne skeny.';

  @override
  String get vinHistorieNoveVozidlo => 'Nové vozidlo';

  @override
  String get vinHistoriePoprve => 'Prvýkrát dekódované';

  @override
  String vinHistorieDekodovanoX(int pocet) {
    return 'Dekódované $pocet×';
  }

  @override
  String get vinHistorieNezname => 'Neznáme vozidlo';

  @override
  String get vinZadejteVin => 'Zadajte kód VIN.';

  @override
  String get vinSkenJenApk =>
      'Skenovanie funguje iba v nainštalovanej aplikácii (APK/iOS).';

  @override
  String get vinFieldKodMotoru => 'Kód motora';

  @override
  String get zakZakaznici => 'Zákazníci';

  @override
  String get zakSubtitle => 'Adresár vašich klientov a ich vozidiel.';

  @override
  String get zakHledatHint => 'Hľadať meno, telefón alebo IČO...';

  @override
  String zakChybaDb(String chyba) {
    return 'Chyba databázy: $chyba';
  }

  @override
  String get zakZadniZakaznici => 'Zatiaľ nemáte žiadnych zákazníkov.';

  @override
  String zakIcoZnak(String ico) {
    return '🏢 IČO: $ico';
  }

  @override
  String get zakEditTitle => 'Úprava zákazníka';

  @override
  String get zakJmenoLabel => 'Meno a Priezvisko / Názov firmy';

  @override
  String get zakTelLabel => 'Telefón';

  @override
  String get zakVybertePredvolbu => 'Vyberte predvoľbu';

  @override
  String get zakCisloLabel => 'Číslo';

  @override
  String get zakEmailLabel => 'E-mail';

  @override
  String get zakAdresaLabel => 'Adresa';

  @override
  String get zakIcoLabel => 'IČO';

  @override
  String get zakDicLabel => 'DIČ';

  @override
  String get zakUlozitZmeny => 'ULOŽIŤ ZMENY';

  @override
  String get zakZpracovavam => 'Spracovávam dáta...';

  @override
  String get zakKartaZakaznika => 'Karta zákazníka';

  @override
  String get zakHeaderLabel => 'ZÁKAZNÍK';

  @override
  String get zakTabInfo => 'Info';

  @override
  String get zakTabZaznamy => 'Záznamy';

  @override
  String get zakSmazatMenu => 'Zmazať zákazníka';

  @override
  String get zakSmazatTitle => 'Zmazať zákazníka?';

  @override
  String get zakSmazatContent =>
      'Zákazník bude odobraný z adresára. Jeho vozidlá a história zákaziek zostanú zachované.';

  @override
  String get zakZrusit => 'Zrušiť';

  @override
  String get zakSmazatPotvrdit => 'Zmazať';

  @override
  String get zakSmazanUspesne => 'Zákazník bol zmazaný.';

  @override
  String zakChybaMazani(String chyba) {
    return 'Chyba pri mazaní: $chyba';
  }

  @override
  String get zakNeznamyZakaznik => 'Neznámy zákazník';

  @override
  String get zakFirma => 'Firma';

  @override
  String get zakSoukromaOsoba => 'Súkromná osoba';

  @override
  String get zakStatVozidel => 'VOZIDIEL';

  @override
  String get zakStatPrijmu => 'PRÍJMOV';

  @override
  String get zakVolat => 'Volať';

  @override
  String get zakSms => 'SMS';

  @override
  String get zakKontaktniUdaje => 'Kontaktné údaje';

  @override
  String get zakVozidlaTitle => 'Vozidlá zákazníka';

  @override
  String get zakPridat => 'Pridať';

  @override
  String get zakZadnaVozidla => 'Zákazník nemá uložené žiadne vozidlá.';

  @override
  String get zakBezSpz => 'Bez ŠPZ';

  @override
  String get zakZadneZaznamy => 'Zákazník zatiaľ nemá žiadne záznamy o príjme.';

  @override
  String zakZakazka(Object cislo) {
    return 'Zákazka $cislo';
  }

  @override
  String zakPoskozeni(String seznam) {
    return 'Poškodenia: $seznam';
  }

  @override
  String get zakPodepsano => 'Podpísané';

  @override
  String zakFotoKs(int pocet) {
    return '$pocet foto';
  }

  @override
  String get authBiometricReason => 'Prihláste sa do Torkis';

  @override
  String get authBiometricChybaStorage =>
      'Najprv sa prihláste heslom – Face ID sa aktivuje pri ďalšom spustení.';

  @override
  String get authBiometricChybaUdaje =>
      'Uložené prihlasovacie údaje sú neplatné. Prihláste sa heslom.';

  @override
  String get authChybaPrazdnaPola => 'Zadajte prosím e-mail aj heslo.';

  @override
  String get authChybaHeslaNeshoda => 'Zadané heslá sa nezhodujú.';

  @override
  String get authChybaOverovani => 'Došlo k chybe pri overovaní.';

  @override
  String get authChybaNeplatneUdaje => 'Nesprávny e-mail alebo heslo.';

  @override
  String get authChybaEmailExistuje => 'Tento e-mail je už zaregistrovaný.';

  @override
  String get authChybaSlabeHeslo => 'Heslo je príliš slabé (min. 6 znakov).';

  @override
  String get authChybaFormatEmail => 'Neplatný formát e-mailu.';

  @override
  String authChybaNeocekvana(String chyba) {
    return 'Neočakávaná chyba: $chyba';
  }

  @override
  String get authResetHint =>
      'Pre obnovu hesla zadajte platný e-mail do horného políčka.';

  @override
  String get authResetOdeslan => 'E-mail na obnovu hesla bol odoslaný.';

  @override
  String get authResetChyba => 'Chyba pri odosielaní e-mailu na obnovu.';

  @override
  String get authSubtitleLogin => 'Digitálna evidencia vozidiel';

  @override
  String get authSubtitleRegister => 'Zaregistrujte svoj servis';

  @override
  String get authEmailHint => 'E-mail';

  @override
  String get authHesloHint => 'Heslo';

  @override
  String get authPotvrzeniHeslaHint => 'Potvrdenie hesla';

  @override
  String get authZapomenuteHeslo => 'Zabudli ste heslo?';

  @override
  String get authPrihlasitSe => 'Prihlásiť sa';

  @override
  String get authVytvoritUcet => 'Vytvoriť účet';

  @override
  String get authBiometrickePrihlaseni => 'Prihlásiť sa biometricky';

  @override
  String get authNebo => 'alebo';

  @override
  String get authGoogleBtn => 'Pokračovať cez Google';

  @override
  String get authAppleBtn => 'Pokračovať cez Apple';

  @override
  String get authNematUcet => 'Nemáte účet?';

  @override
  String get authZaregistrujteSe => 'Zaregistrujte sa';

  @override
  String get authMateUcet => 'Máte už účet?';

  @override
  String get authPrihlasteSe => 'Prihláste sa';

  @override
  String predChybaNakup(String chyba) {
    return 'Nákup sa nepodaril: $chyba';
  }

  @override
  String get predChybaEmailKlient =>
      'Nepodarilo sa otvoriť e-mailového klienta.';

  @override
  String get predTitle => 'Vaše predplatné';

  @override
  String get predSubtitle =>
      'Spravujte plán svojho servisu a podľa potreby ho upgradujte.';

  @override
  String get predTrialBannerTitle => 'Aktívna skúšobná doba';

  @override
  String predAktivniPlanTitle(String plan) {
    return 'Aktívny plán: $plan';
  }

  @override
  String get predTrialBannerSubtitle =>
      'Po skončení trialu si vyberiete plán, ktorý vám sadne.';

  @override
  String get predAktivniPlanSubtitle => 'Ďakujeme, že používate TORKIS.';

  @override
  String get predMesicne => 'Mesačne';

  @override
  String get predRocne => 'Ročne';

  @override
  String get predFootnote => 'Bez záväzku · Zrušenie kedykoľvek · Ceny bez DPH';

  @override
  String get predBasicDesc => 'Pre malé autoservisy a SZČO.';

  @override
  String get predStandardDesc => 'Pre stredné servisy do 150 zákaziek mesačne.';

  @override
  String get predProDesc => 'Pre veľké servisy a siete bez limitu záznamov.';

  @override
  String get predCustomDesc =>
      'Individuálna úprava pre špeciálne požiadavky a integrácie.';

  @override
  String get predFeat50Zaznamu => '50 záznamov/mesiac';

  @override
  String get predFeat3Uziv => 'Max. 3 používatelia';

  @override
  String get predFeat30Vin => '30 dekódovaní VIN/mesiac';

  @override
  String get predFeat1TrzniHodnota => '1 zistenie trhovej hodnoty/mesiac';

  @override
  String get predFeatNeomezStk => 'Neobmedzené zistenia platnosti STK';

  @override
  String get predFeatFotodok => 'Fotodokumentácia';

  @override
  String get predFeatEvidZak => 'Evidencia zákazníkov a vozidiel';

  @override
  String get predFeatHistorie => 'História záznamov';

  @override
  String get predFeatSpravaTymu => 'Správa tímu';

  @override
  String get predFeat150Zaznamu => '150 záznamov/mesiac';

  @override
  String get predFeat10Uziv => 'Max. 10 používateľov';

  @override
  String get predFeat60Vin => '60 dekódovaní VIN/mesiac';

  @override
  String get predFeat120Vin => '120 dekódovaní VIN/mesiac';

  @override
  String get predFeat75Vin => '75 dekódovaní VIN/mesiac';

  @override
  String get predFeat3TrzniHodnota => '3 zistenia trhovej hodnoty/mesiac';

  @override
  String get predFeatVseBasic => 'Všetko z Basic';

  @override
  String get predFeatReporty => 'Reporty a štatistiky';

  @override
  String get predFeatChat => 'Chat so zákazníkom';

  @override
  String get predFeatWebPortal =>
      'Webový portál pre správu vozidiel a zákazníkov';

  @override
  String get predFeatNeomezZaznamu => 'Neobmedzené záznamy';

  @override
  String get predFeatNeomezUziv => 'Neobmedzený počet používateľov';

  @override
  String get predFeatVseStandard => 'Všetko zo Standard';

  @override
  String get predFeat150Vin => '150 dekódovaní VIN/mesiac';

  @override
  String get predFeat5TrzniHodnota => '5 zistení trhovej hodnoty/mesiac';

  @override
  String get predFeatPrioritniPodpora => 'Prioritná podpora';

  @override
  String get predFeatPokrocileStatistiky => 'Pokročilé štatistiky';

  @override
  String get predFeatVicenasobinaVzd => 'Viacnásobné pracoviská';

  @override
  String get predFeatErp => 'Napojenie na váš ERP/DMS';

  @override
  String get predFeatNeomezVin => 'Neobmedzený počet dekódovaní VIN/mesiac';

  @override
  String get predFeatNeomezTrzni => 'Neobmedzená trhová hodnota vozidiel';

  @override
  String get predFeatPrioritniSla => 'Prioritná podpora s SLA';

  @override
  String get paywallTitle => 'Vyberte plán';

  @override
  String get paywallSubtitleTrialEnding =>
      'Vaše skúšobné obdobie čoskoro končí. Vyberte plán pre pokračovanie.';

  @override
  String get paywallSubtitleTrialExpired =>
      'Vaše skúšobné obdobie skončilo. Vyberte plán zodpovedajúci veľkosti servisu.';

  @override
  String paywallTrialZbyva(int n, String slovo) {
    return 'Zostáva $n $slovo skúšobného obdobia';
  }

  @override
  String get paywallBezpeci =>
      'Vaše dáta sú v bezpečí. Po výbere plánu všetko obnovíme.';

  @override
  String get paywallZadnePredplatne => 'Nenájdené žiadne aktívne predplatné.';

  @override
  String paywallChybaObnoveni(String chyba) {
    return 'Chyba obnovenia: $chyba';
  }

  @override
  String get paywallObnovitNakupy => 'Obnoviť nákupy';

  @override
  String get predPeriodMesic => 'mesačne';

  @override
  String get predPeriodRoc => 'ročne';

  @override
  String get predCenaNaMiru => 'Cena na mieru';

  @override
  String get predDoporucujeme => 'ODPORÚČAME';

  @override
  String get predAktualniPlanPill => 'AKTUÁLNY PLÁN';

  @override
  String get predAktualneAktivni => 'Aktuálne aktívny';

  @override
  String get predMamZajem => 'Mám záujem';

  @override
  String predVybrat(String name) {
    return 'Vybrať $name';
  }

  @override
  String get paywallTrust1Title => '99,9 % dostupnosť';

  @override
  String get paywallTrust1Sub => 'Garantovaná uptime SLA';

  @override
  String get paywallTrust2Title => 'Export dát zadarmo';

  @override
  String get paywallTrust2Sub => 'Vaše dáta sú vždy vaše';

  @override
  String get onbAresChybaIco => 'Zadajte platné 8-miestne IČO.';

  @override
  String get onbAresNacteno => 'Údaje z registra boli načítané.';

  @override
  String get onbAresNenalezeno => 'Zadané IČO nebolo v registri nájdené.';

  @override
  String onbAresChyba(String chyba) {
    return 'Chyba pri komunikácii s registrom: $chyba';
  }

  @override
  String get onbBiometricReason =>
      'Potvrďte svoju totožnosť na zapnutie biometrického prihlásenia';

  @override
  String get onbDialogUpravitTyp => 'Upraviť typ';

  @override
  String get onbDialogNovyTyp => 'Nový typ záznamu';

  @override
  String get onbDialogNazevTypuHint => 'Názov typu (napr. Servis, Výkup...)';

  @override
  String get onbZrusit => 'Zrušiť';

  @override
  String get onbUlozit => 'Uložiť';

  @override
  String onbChybaUkladani(String chyba) {
    return 'Chyba pri ukladaní: $chyba';
  }

  @override
  String get onbChybaNazev => 'Názov servisu je povinný pre pokračovanie.';

  @override
  String get onbDokoncit => 'DOKONČIŤ NASTAVENIE';

  @override
  String get onbPokracovat => 'POKRAČOVAŤ';

  @override
  String get onbKrok1Nadpis => 'Vitajte v TORKIS!';

  @override
  String get onbKrok1Popis =>
      'Najprv vyplníme základné informácie o vás alebo o vašej spoločnosti.';

  @override
  String get onbIcoLabel => 'IČO (vyhľadávanie v registri)';

  @override
  String get onbIcoHint => 'Napr. 12345678';

  @override
  String get onbAresLoadTooltip => 'Načítať z registra';

  @override
  String get onbNazevLabel => 'Názov servisu / Meno *';

  @override
  String get onbNazevHint => 'Zadajte názov...';

  @override
  String get onbDicLabel => 'DIČ (nepovinné)';

  @override
  String get onbDicHint => 'Napr. CZ12345678';

  @override
  String get onbRegistraceLabel => 'Zápis v registri (nepovinné)';

  @override
  String get onbRegistraceHint => 'Napr. zapísaný v ŽR u Mestského úradu...';

  @override
  String get onbSidloNadpis => 'Sídlo a kontakt';

  @override
  String get onbSidloPopis =>
      'Údaje sa použijú na ponukách, faktúrach a v komunikácii.';

  @override
  String get onbUliceLabel => 'Ulica a č.p.';

  @override
  String get onbUliceHint => 'Napr. Hlavná 123';

  @override
  String get onbMestoLabel => 'Mesto';

  @override
  String get onbMestoHint => 'Napr. Bratislava';

  @override
  String get onbPscLabel => 'PSČ';

  @override
  String get onbTelefonLabel => 'Telefón servisu';

  @override
  String get onbTelefonHint => 'Napr. +421 777 123 456';

  @override
  String get onbKomunikaceNadpis => 'Komunikácia a vzhľad';

  @override
  String get onbEmailLabel =>
      'E-mailová adresa (z ktorej budú odchádzať e-maily zákazníkom)';

  @override
  String get onbEmailHint => 'Napr. info@autoservis.sk';

  @override
  String get onbEmailySwitchTitle => 'Automaticky zasielať e-maily';

  @override
  String get onbEmailySwitchSubtitle =>
      'Zákazníkom bude v ponukách a pri ukončení predoznačená možnosť odoslania PDF e-mailom.';

  @override
  String get onbAdminNadpis => 'Váš účet (administrátor)';

  @override
  String get onbAdminPopis =>
      'Zadajte svoje meno — budete pridaní ako hlavný správca servisu.';

  @override
  String get onbJmenoLabel => 'Meno a priezvisko *';

  @override
  String get onbJmenoHint => 'Napr. Ján Novák';

  @override
  String get onbTmavyRezimTitle => 'Vynútiť tmavý režim';

  @override
  String get onbTmavyRezimSubtitle =>
      'Aplikácia bude okamžite prepnutá do tmavého vzhľadu.';

  @override
  String get onbKrok2Nadpis => 'Prevádzka a automatizácia';

  @override
  String get onbKrok2Popis =>
      'Nastavte správanie príjmu vozidla. Všetko možno neskôr kedykoľvek zmeniť v Nastaveniach.';

  @override
  String get onbAutoCisloTitle => 'Automaticky generovať číslo zákazky';

  @override
  String get onbAutoCisloSubtitle =>
      'Pri príjme vozidla sa číslo zákazky predvyplní automaticky. Vypnutím umožníte ručné zadanie.';

  @override
  String get onbPodpisTitle => 'Vyžadovať podpis zákazníka';

  @override
  String get onbPodpisSubtitle =>
      'Pri vypnutí sa krok s podpisom zobrazí bez podpisového plátna.';

  @override
  String get onbSpzTitle => 'Povinná ŠPZ vozidla';

  @override
  String get onbSpzSubtitle =>
      'Pri vypnutí možno príjem odoslať aj bez vyplnenej ŠPZ.';

  @override
  String get onbTypyNadpis => 'Typy záznamu';

  @override
  String get onbTypyPopis =>
      'Slúži na rozlíšenie príjmu vozidla (napr. Servis, Výkup). Prvý typ je predvolený.';

  @override
  String get onbTypyVychozi => 'predvolený';

  @override
  String get onbPridatTyp => 'Pridať typ';

  @override
  String get onbTypyHint => 'Dlhý stisk = nastaviť ako predvolený.';

  @override
  String get onbOsobniNadpis => 'Osobné nastavenia';

  @override
  String get onbBiometrieTitle => 'Biometrické prihlásenie';

  @override
  String get onbBiometrieSubtitle =>
      'Face ID / odtlačok prsta pri každom spustení.';

  @override
  String get onbLevacTitle => 'Režim pre ľavákov';

  @override
  String get onbLevacSubtitle =>
      'Spúšť fotoaparátu vľavo, keď je zariadenie na šírku.';

  @override
  String get onbKrok3Nadpis => 'Najčastejšie úkony';

  @override
  String get onbKrok3Popis =>
      'Pripravili sme pre vás zoznam typických úkonov. Môžete ich ľubovoľne prepísať, zmazať alebo pridať ďalšie.';

  @override
  String get onbUkonNazevLabel => 'Názov úkonu';

  @override
  String get onbUkonCenaLabel => 'Jedn. cena (Kč)';

  @override
  String get onbUkonCasLabel => 'Čas';

  @override
  String get onbUkonHod => 'hod';

  @override
  String get onbUkonMin => 'min';

  @override
  String get onbUkonCelkovaCenaLabel => 'Celková cena (Kč)';

  @override
  String get onbUkonKategorieLabel => 'Kategória';

  @override
  String get onbPridatUkon => 'Pridať ďalší úkon';

  @override
  String get trialBadge => '30 DNÍ ZADARMO';

  @override
  String get trialNadpis => 'Vitajte v TORKIS';

  @override
  String get trialPopis =>
      'Spustili sme vám skúšobnú dobu na 30 dní zadarmo — bez platobnej karty a bez záväzkov.';

  @override
  String get trialBenefit1 =>
      'Neobmedzený počet záznamov vozidiel a zákazníkov';

  @override
  String get trialBenefit2 => '10 dekódovaných VINov';

  @override
  String get trialBenefit3 => 'Neobmedzený počet zistení platnosti STK';

  @override
  String get trialBenefit4 => 'Plný prístup ku všetkým funkciám aplikácie.';

  @override
  String get trialBenefit5 =>
      'Žiadne platobné údaje. Bez automatického strhávanie.';

  @override
  String get trialBenefit6 =>
      'Vaše dáta sú vždy vaše — export kedykoľvek zadarmo.';

  @override
  String get trialBtn => 'Začať používať aplikáciu';

  @override
  String get mainNavNovy => 'Nový';

  @override
  String get mainNavMenu => 'Menu';

  @override
  String get mainNavVozidla => 'Vozidlá';

  @override
  String get mainNavUkony => 'Úkony';

  @override
  String get mainNavZakaznici => 'Zákazníci';

  @override
  String get mainNavTym => 'Tím';

  @override
  String get mainNavStatistiky => 'Štatistiky';

  @override
  String get mainNavNastaveni => 'Nastavenia';

  @override
  String get mainNavPrijmy => 'Príjmy';

  @override
  String get mainNavVin => 'VIN';

  @override
  String get mainModVozidlaSubtitle => 'Evidencia vozidiel v servise';

  @override
  String get mainModZakazniciSubtitle => 'Kontakty a vozový park';

  @override
  String get mainModHistorieLabel => 'História záznamov';

  @override
  String get mainModHistorieSubtitle => 'Archív zákaziek';

  @override
  String get mainModUkonySubtitle => 'Cenník prác a služieb';

  @override
  String get mainModVinLabel => 'VIN dekodér';

  @override
  String get mainModVinSubtitle => 'Údaje o vozidle z VIN';

  @override
  String get mainModTymSubtitle => 'Technici a oprávnenia';

  @override
  String get mainModStatistikySubtitle => 'Prehľady a tržby';

  @override
  String get mainModNastaveniSubtitle => 'Servis, faktúry, integrácie';

  @override
  String get mainModPredplatneLabel => 'Predplatné';

  @override
  String get mainModPredplatneSubtitle => 'Plán a platby';

  @override
  String get mainModWebLabel => 'Web';

  @override
  String get mainModWebSubtitle => 'Verejná stránka';

  @override
  String get mainModulyNadpis => 'Moduly';

  @override
  String get mainPrihlasenv => 'Prihlásený v servise';

  @override
  String get mainOdhlasitSe => 'Odhlásiť sa';

  @override
  String get mainOdhlaseniTitle => 'Odhlásenie';

  @override
  String get mainOdhlaseniContent => 'Naozaj sa chcete odhlásiť?';

  @override
  String get mainZrusit => 'Zrušiť';

  @override
  String get mainOdhlasit => 'Odhlásiť';

  @override
  String get mainSvetlyRezim => 'Svetlý režim';

  @override
  String get mainTmavyRezim => 'Tmavý režim';

  @override
  String get histZpracovava => 'Spracováva sa...';

  @override
  String get histNadpis => 'História príjmov';

  @override
  String get histPodnadpis =>
      'Prehľad všetkých prijatých vozidiel a ich protokolov.';

  @override
  String get histHledat => 'Hľadať EČV, zákazníka alebo vozidlo...';

  @override
  String histChyba(String chyba) {
    return 'Chyba: $chyba';
  }

  @override
  String get histPrazdne => 'Zatiaľ žiadne záznamy o príjme.';

  @override
  String get histNespecifikovano => 'Nešpecifikované';

  @override
  String get histPrijal => 'Prijal';

  @override
  String histFoto(int pocet) {
    return '$pocet foto';
  }

  @override
  String get histPodepsano => 'Podpísané';

  @override
  String get histDetailNadpis => 'Detail príjmu';

  @override
  String histChybaTisku(String chyba) {
    return 'Chyba pri tlači: $chyba';
  }

  @override
  String histChybaZobrazeni(String chyba) {
    return 'Chyba pri zobrazení: $chyba';
  }

  @override
  String histProtokol(String cislo) {
    return 'Protokol $cislo';
  }

  @override
  String get histZobrazitProtokol => 'Zobraziť protokol';

  @override
  String get histTisknoutProtokol => 'Tlačiť protokol';

  @override
  String get histTisknoutBtn => 'Tlač';

  @override
  String get histSekceVozidlo => 'Vozidlo';

  @override
  String get histPoleSPZ => 'EČV';

  @override
  String get histPoleZnackaModel => 'Značka & Model';

  @override
  String get histPoleVin => 'VIN';

  @override
  String get histPoleRokVyroby => 'Rok výroby';

  @override
  String get histPolePalivo => 'Palivo';

  @override
  String get histPolePrevodovka => 'Prevodovka';

  @override
  String get histPoleMotorizace => 'Motorizácia';

  @override
  String get histSekceZakaznik => 'Zákazník';

  @override
  String get histPoleJmeno => 'Meno';

  @override
  String get histPoleTelefon => 'Telefón';

  @override
  String get histPoleEmail => 'E-mail';

  @override
  String get histPoleAdresa => 'Adresa';

  @override
  String get histPoleIco => 'IČO';

  @override
  String get histPoleDic => 'DIČ';

  @override
  String get histSekceStav => 'Stav pri príjme';

  @override
  String get histPoleTachometr => 'Tachometer';

  @override
  String get histPoleNadrz => 'Stav nádrže';

  @override
  String get histPoleStk => 'STK';

  @override
  String get histPolePoskozeni => 'Poškodenia';

  @override
  String get histPolePneuLP => 'Pneumatiky LP / PP';

  @override
  String get histPolePneuLZ => 'Pneumatiky LZ / PZ';

  @override
  String get histSekcePozadavky => 'Požiadavky zákazníka';

  @override
  String get histSekcePoznamky => 'Poznámky';

  @override
  String get histSekceFoto => 'Fotodokumentácia';

  @override
  String get histZadneFoto => 'Neboli pořízené žiadne fotografie.';

  @override
  String get histSekcePodpis => 'Podpis zákazníka';

  @override
  String get histPodpisNedostupny => 'Podpis nie je k dispozícii';

  @override
  String get nastUlozit => 'ULOŽIŤ';

  @override
  String get nastUlozeno => 'Nastavenia uložené.';

  @override
  String nastChyba(String chyba) {
    return 'Chyba: $chyba';
  }

  @override
  String get nastZrusit => 'Zrušiť';

  @override
  String get nastExportTitle => 'Export dát';

  @override
  String get nastExportPopis =>
      'Stiahnite záznamy vo formáte CSV (Excel) alebo JSON.';

  @override
  String get nastExportZakaznici => 'Zákazníci';

  @override
  String get nastExportVozidla => 'Vozidlá';

  @override
  String get nastExportZakazky => 'Príjmy / Zákazky';

  @override
  String get nastExportFormatTitle => 'Formát exportu';

  @override
  String get nastExportFormatPopis => 'Vyberte formát súboru:';

  @override
  String get nastExportCsv => 'CSV (Excel)';

  @override
  String get fotoTitle => 'Fotodokumentácia';

  @override
  String get fotoPodtitul =>
      'Odfoťte sériu fotiek alebo vyberte hromadne z galérie.';

  @override
  String get fotoPridatGalerie => 'Pridať z galérie';

  @override
  String get fotoSeriove => 'Sériové fotenie';

  @override
  String get fotoKatZvenku => 'Pohľad zvonku (okolo vozidla)';

  @override
  String get fotoKatPoskozeni => 'Zistené poškodenia';

  @override
  String get fotoKatDisky => 'Disky a kolesá';

  @override
  String get fotoKatStk => 'Nálepka STK';

  @override
  String get fotoKatInterier => 'Interiér vozidla';

  @override
  String get fotoKatTachometr => 'Tachometer a palubná doska';

  @override
  String get fotoKatVin => 'VIN kód';

  @override
  String get fotoKatOstatni => 'Ostatná dokumentácia';

  @override
  String get anotTitle => 'Označenie poškodenia';

  @override
  String get anotZavritBezUlozeni => 'Zavrieť bez uloženia';

  @override
  String get anotZrusitPosledni => 'Zrušiť posledné';

  @override
  String get anotSmazatVse => 'Zmazať všetko';

  @override
  String get anotUlozit => 'Uložiť';

  @override
  String get anotChybaNacteni => 'Fotografiu sa nepodarilo načítať.';

  @override
  String get anotVolnaKresba => 'Voľná kresba';

  @override
  String get anotElipsa => 'Elipsa';

  @override
  String get anotObdelnik => 'Obdĺžnik';

  @override
  String get anotSipka => 'Šípka';

  @override
  String get anotPopisTitle => 'Popis poškodenia';

  @override
  String get anotVzory => 'Vzory:';

  @override
  String get anotVlastniPopis => 'Alebo napíšte vlastný popis…';

  @override
  String get anotZrusit => 'Zrušiť';

  @override
  String get anotZahodi => 'Zahodiť';

  @override
  String get anotNeulozenePomoc =>
      'Máte neuložené označenie poškodenia. Uložiť ich?';

  @override
  String get nastUlozitBtn => 'Uložiť';

  @override
  String get nastZavrit => 'ZAVRIEŤ';

  @override
  String get nastHotovo => 'HOTOVO';

  @override
  String get nastChecklistTitul => 'Checklist príjmu';

  @override
  String get nastChecklistPovolen => 'Aktivovať checklist pri príjme';

  @override
  String get nastChecklistPovolenSub =>
      'Panel s checklistom sa zobrazí pri príjme na tablete';

  @override
  String get nastChecklistPrazdny => 'Zatiaľ žiadne položky';

  @override
  String get nastPridatChecklistPolozku => 'Pridať položku';

  @override
  String get nastNovaChecklistPolozka => 'Nová položka';

  @override
  String get nastUpravitChecklistPolozku => 'Upraviť položku';

  @override
  String get nastChecklistPolozkaHint => 'Názov položky checklistu';

  @override
  String get checklistPanelTitul => 'Checklist';

  @override
  String get nastTitulAdmin => 'Firemné nastavenia';

  @override
  String get nastTitulUzivatel => 'Môj profil';

  @override
  String get nastPodtitulAdmin => 'Správa údajov servisu a cenníka.';

  @override
  String get nastPodtitulUzivatel => 'Základné nastavenia vášho účtu.';

  @override
  String get nastFiremniUdaje => 'Firemné údaje';

  @override
  String get nastObchodniJmeno => 'Obchodné meno / Názov servisu';

  @override
  String get nastIco => 'IČO';

  @override
  String get nastDic => 'DIČ';

  @override
  String get nastRejstrik => 'Zápis v registri (spisová značka)';

  @override
  String get nastSidloKontakt => 'Sídlo a kontakt';

  @override
  String get nastUlice => 'Ulica a č.p.';

  @override
  String get nastMesto => 'Mesto';

  @override
  String get nastPsc => 'PSČ';

  @override
  String get nastTelefon => 'Telefón servisu';

  @override
  String get nastEmail => 'E-mail pre komunikáciu';

  @override
  String get nastCislovani => 'Číslovanie a automatizácia';

  @override
  String get nastFormatZakazek => 'Formát čísla zákazky';

  @override
  String get nastAutoEmail => 'Automaticky posielať e-maily';

  @override
  String get nastAutoEmailSub => 'Prednastaví odosielanie PDF ponúk a faktúr.';

  @override
  String get nastAutoCislo => 'Automaticky generovať číslo zákazky';

  @override
  String get nastAutoCisloSub =>
      'Pri príjme vozidla sa číslo zákazky predvyplní automaticky. Vypnutím umožníte ručné zadanie.';

  @override
  String get nastPodpisPovolen => 'Vyžadovať podpis zákazníka';

  @override
  String get nastPodpisPovolenSub =>
      'Pri vypnutí sa krok s podpisom v príjme zobrazí bez podpisového plátna.';

  @override
  String get nastSpzPovinne => 'Povinné EČV vozidla';

  @override
  String get nastSpzPovinneSub =>
      'Pri vypnutí možno príjem odoslať aj bez vyplneného EČV.';

  @override
  String get nastSablony => 'Šablóny správ';

  @override
  String get nastSablonyPopis =>
      'Preddefinované texty zobrazené ako chipy pri písaní správy zákazníkovi.';

  @override
  String get nastSablonyPrazdne => 'Zatiaľ žiadne šablóny. Pridajte prvú.';

  @override
  String get nastPridatSablonu => 'Pridať šablónu';

  @override
  String get nastUpravitSablonu => 'Upraviť šablónu';

  @override
  String get nastNovaSablona => 'Nová šablóna';

  @override
  String get nastSablonaHint => 'Text správy...';

  @override
  String get nastTypyZaznamu => 'Typy záznamu';

  @override
  String get nastTypyZaznamuPopis =>
      'Typy záznamu slúžia na rozlíšenie príjmu vozidla (napr. Servis, Výkup). Prvý pridaný typ je predvolený.';

  @override
  String get nastVychozi => 'predvolený';

  @override
  String get nastPridatTyp => 'Pridať typ';

  @override
  String get nastUpravitTyp => 'Upraviť typ';

  @override
  String get nastNovyTyp => 'Nový typ záznamu';

  @override
  String get nastTypHint => 'Názov typu (napr. Servis, Výkup...)';

  @override
  String get nastLongPress => 'Dlhé stlačenie = nastaviť ako predvolený.';

  @override
  String get nastOsobni => 'Osobné nastavenia';

  @override
  String get nastPrizpusobitListu => 'Prispôsobiť spodnú lištu';

  @override
  String get nastPrizpusobitListuSub =>
      'Pridajte zástupce alebo zmeňte poradie.';

  @override
  String get nastListaPopis =>
      'Môžete mať aktívnych 2 až 5 záložiek. Ťahaním zmeníte poradie.';

  @override
  String get nastMenuNelzeOdebrat => 'Menu nemožno odstrániť';

  @override
  String get nastVybrModul => 'Vyberte modul pre lištu';

  @override
  String get nastPridatZalozku => 'Pridať ďalšiu záložku (max 5)';

  @override
  String get nastTmavyRezim => 'Vynútiť tmavý režim';

  @override
  String get nastTmavyRezimSub => 'Aplikácia bude tmavá bez ohľadu na systém.';

  @override
  String get nastBiometrie => 'Biometrické prihlásenie';

  @override
  String get nastBiometrieSub =>
      'Face ID / odtlačok prsta pri každom spustení.';

  @override
  String get nastBiometricReason =>
      'Potvrďte svoju totožnosť pre zapnutie biometrického prihlásenia';

  @override
  String get nastLeVaci => 'Režim pre ľavákov';

  @override
  String get nastLeVaciSub =>
      'Spúšť fotoaparátu vľavo, keď je zariadenie na šírku.';

  @override
  String get nastUlozitDoZarizeniTitle => 'Ukladať fotky aj do zariadenia';

  @override
  String get nastUlozitDoZarizeniSub =>
      'Pri odoslaní sa fotky z príjmu uložia aj do galérie tohto zariadenia.';

  @override
  String get nastJazyk => 'Jazyk aplikácie';

  @override
  String get nastSystJazyk => 'Systémový jazyk';

  @override
  String get nastModPrijem => 'Príjem vozidla';

  @override
  String get nastModHistorie => 'História príjmov';

  @override
  String get nastModMenu => 'Menu (Ostatné moduly)';

  @override
  String get nastModVozidla => 'Vozidlá';

  @override
  String get nastModUkony => 'Úkony';

  @override
  String get nastModZakaznici => 'Zákazníci';

  @override
  String get nastModTym => 'Tím a práva';

  @override
  String get nastModStatistiky => 'Štatistiky';

  @override
  String get nastModNastaveni => 'Nastavenia';

  @override
  String get nastModVin => 'VIN dekodér';

  @override
  String nastFormatTitle(String typ) {
    return 'Formát čísla pre: $typ';
  }

  @override
  String get nastNahledLabel => 'Náhľad budúceho dokladu:';

  @override
  String nastInternaMaska(String maska) {
    return 'Interná maska: $maska';
  }

  @override
  String get nastPrefix => 'Prefix (Značka)';

  @override
  String get nastOddelovac => 'Oddeľovač';

  @override
  String get nastOddelovacPomlcka => 'Pomlčka (-)';

  @override
  String get nastOddelovacLomitko => 'Lomka (/)';

  @override
  String get nastOddelovacPodtrzitko => 'Podčiarkovník (_)';

  @override
  String get nastOddelovacBez => 'Bez oddeľovača';

  @override
  String get nastRokFormat => 'Formát roka';

  @override
  String get nastRok4 => '4 cifry (2026)';

  @override
  String get nastRok2 => '2 cifry (26)';

  @override
  String get nastBezRoku => 'Bez roka';

  @override
  String get nastMesicFormat => 'Formát mesiaca';

  @override
  String get nastMesic2 => '2 cifry (04)';

  @override
  String get nastBezMesice => 'Bez mesiaca';

  @override
  String nastDelkaCitadla(int n) {
    return 'Dĺžka poradového čísla na konci: $n';
  }

  @override
  String get nastInfoZmenaFormatu =>
      'Ak zmeníte formát v priebehu roka, existujúce doklady zostanú nedotknuté a nová rad bude pokračovať od aktuálneho čísla v databáze.';

  @override
  String get nastUlozitFormat => 'ULOŽIŤ FORMÁT';

  @override
  String get nastFormatUlozen => 'Formát číslovania bol úspešne uložený.';

  @override
  String get nastTrialVyprselo => 'Skúšobná doba vypršala';

  @override
  String get nastTrialAktivni => 'Skúšobná doba zadarmo';

  @override
  String nastPlanNazev(String plan) {
    return 'Plán $plan';
  }

  @override
  String get nastTrialVyberPlan => 'Vyberte plán pre pokračovanie';

  @override
  String nastTrialZbyva(int n, String slovo) {
    return 'Zostáva $n $slovo · bez záväzku';
  }

  @override
  String nastPlatnostDo(String datum) {
    return 'Platnosť do $datum';
  }

  @override
  String get nastAktivni => 'Aktívny';

  @override
  String get nastVybratPlan => 'Vybrať plán';

  @override
  String get nastZobrazitPlany => 'Zobraziť plány';

  @override
  String get nastDayJeden => 'deň';

  @override
  String get nastDayNeco => 'dni';

  @override
  String get nastDayMnogo => 'dní';

  @override
  String get zamModZamestnanci => 'Zamestnanci';

  @override
  String get zamModNastaveni => 'Nastavenia';

  @override
  String zamChyba(String chyba) {
    return 'Chyba: $chyba';
  }

  @override
  String get zamTitle => 'Tím a oprávnenia';

  @override
  String get zamSubtitle =>
      'Spravujte členov svojho servisu a ich prístup do aplikácie.';

  @override
  String get zamPrazdny => 'Zatiaľ nemáte žiadnych členov tímu.';

  @override
  String get zamPridatClena => 'Pridať člena tímu';

  @override
  String get zamLimitTitle => 'Dosiahnutý limit účtov';

  @override
  String zamLimitText(String plan, int limit, int pocet) {
    return 'Plán $plan umožňuje maximálne $limit používateľských účtov. Aktuálne využívate $pocet/$limit. Pre pridanie ďalších členov tímu inovujte plán.';
  }

  @override
  String get zamZrusit => 'Zrušiť';

  @override
  String get zamUpgradovat => 'Inovovať plán';

  @override
  String get zamNovyClen => 'Nový člen tímu';

  @override
  String get zamJmenoLabel => 'Meno a priezvisko *';

  @override
  String get zamEmailLabel => 'Prihlasovací e-mail *';

  @override
  String get zamHesloLabel => 'Prihlasovacie heslo (min. 6 znakov) *';

  @override
  String get zamVychoziPrava => 'Predvolené prístupové práva';

  @override
  String get zamVytvoritUcet => 'Vytvoriť účet';

  @override
  String get zamErrVyplnte => 'Vyplňte prosím meno, e-mail aj heslo.';

  @override
  String get zamErrHesloKratke => 'Heslo musí mať aspoň 6 znakov.';

  @override
  String get zamUcetVytvoren => 'Účet vytvorený.';

  @override
  String get zamErrOvereni => 'Chyba overenia.';

  @override
  String get zamErrHesloSlabe => 'Zadané heslo je príliš slabé.';

  @override
  String get zamErrEmailExistuje => 'Účet s týmto e-mailom už existuje.';

  @override
  String get zamErrEmailFormat => 'Neplatný formát e-mailu.';

  @override
  String zamErrNeocekavana(String chyba) {
    return 'Neočakávaná chyba: $chyba';
  }

  @override
  String get zamPristupovaPrava => 'Prístupové práva';

  @override
  String get zamUlozitOpravneni => 'Uložiť oprávnenia';

  @override
  String get zamUdelitVse => 'Udeliť všetko';

  @override
  String get zamOdebratVse => 'Odobrať všetko';

  @override
  String get zamOdstranit => 'Odstrániť';

  @override
  String get zamOdstranitTitle => 'Odstrániť člena tímu?';

  @override
  String zamOdstranitText(String jmeno) {
    return 'Naozaj chcete odstrániť člena $jmeno? Stratí prístup do aplikácie. Túto akciu nie je možné vrátiť späť.';
  }

  @override
  String get zamClenOdstranen => 'Člen tímu bol odstránený.';

  @override
  String zamPocetUzivatelu(int pocet) {
    return '$pocet používateľov';
  }

  @override
  String zamPocetLimit(int pocet, int limit) {
    return '$pocet / $limit používateľov';
  }

  @override
  String zamPlanBezLimitu(String plan) {
    return 'Plán $plan · bez limitu';
  }

  @override
  String zamPlanLimitDosazen(String plan) {
    return 'Plán $plan · limit dosiahnutý';
  }

  @override
  String zamPlanZbyva(String plan, int zbyva) {
    return 'Plán $plan · zostáva $zbyva';
  }

  @override
  String get zamBezJmena => 'Bez mena';

  @override
  String get zamBezPrav => 'Bez rozšírených práv';

  @override
  String get zamBadgeAdmin => 'ADMIN';

  @override
  String get zamBadgeClen => 'ČLEN';
}
