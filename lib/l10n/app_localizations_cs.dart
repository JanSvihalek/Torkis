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

  @override
  String get vozidloStatTacho => 'TACHOMETR';

  @override
  String get vozidloStatStkDo => 'STK DO';

  @override
  String get vozidloStatPrijmu => 'PŘÍJMŮ';

  @override
  String get vozidloStkPlatna => 'STK platná';

  @override
  String get vozidloStkProsla => 'STK prošlá';

  @override
  String vozidloStkVyprsiBehemMesicu(String mesic, String rok, int pocet) {
    return 'Vyprší $mesic/$rok · zbývá $pocet měsíců';
  }

  @override
  String vozidloStkVyprsela(String mesic, String rok) {
    return 'Vypršela $mesic/$rok';
  }

  @override
  String get vozidloTechnickeUdaje => 'Technické údaje';

  @override
  String get vozidloZnackaModel => 'Značka & Model';

  @override
  String get vozidloMotorizace => 'Motorizace';

  @override
  String get vozidloVin => 'VIN';

  @override
  String get vozidloRokVyroby => 'Rok výroby';

  @override
  String get vozidloPalivo => 'Palivo';

  @override
  String get vozidloPrevodovka => 'Převodovka';

  @override
  String get vozidloBarva => 'Barva';

  @override
  String get vozidloVykon => 'Výkon';

  @override
  String get vozidloPocetMistDveri => 'Místa / dveře';

  @override
  String get vozidloRozmery => 'Rozměry';

  @override
  String get vozidloUdajeZVin => 'Údaje z VIN';

  @override
  String get vozidloTachometrLabel => 'Tachometr';

  @override
  String get vozidloMajitel => 'Majitel vozidla';

  @override
  String get vozidloJmeno => 'Jméno';

  @override
  String get vozidloTelefon => 'Telefon';

  @override
  String get vozidloEmail => 'E-mail';

  @override
  String get vozidloVolat => 'Volat';

  @override
  String get vozidlaTitle => 'Databáze vozidel';

  @override
  String get vozidlaSubtitle => 'Přehled všech servisovaných aut.';

  @override
  String get vozidlaHledatHint => 'Hledat SPZ, Značku nebo VIN...';

  @override
  String get vozidlaSkenSpzTooltip => 'Naskenovat SPZ fotoaparátem';

  @override
  String get vozidlaZadnaVozidla => 'Zatím nemáte v databázi žádná vozidla.';

  @override
  String get vozidlaNejstePrihlaseni => 'Nejste přihlášeni.';

  @override
  String get vozidlaSkenJenApp =>
      'Skenování funguje pouze v nainstalované aplikaci (APK/iOS).';

  @override
  String get vozidloDetailUprava => 'Úprava vozidla';

  @override
  String get vozidloDetailSpz => 'SPZ';

  @override
  String get vozidloDetailZnacka => 'Značka';

  @override
  String get vozidloDetailModel => 'Model';

  @override
  String get vozidloDetailTachoKm => 'Tachometr (km)';

  @override
  String get vozidloDetailPlatnostStk => 'Platnost STK';

  @override
  String get vozidloDetailStkMesic => 'Měsíc (MM)';

  @override
  String get vozidloDetailStkRok => 'Rok (YYYY)';

  @override
  String get vozidloDetailUlozitZmeny => 'ULOŽIT ZMĚNY';

  @override
  String get vozidloDetailSpzExistuje => 'Vozidlo s touto SPZ již existuje!';

  @override
  String vozidloDetailPrejmenovano(String spz) {
    return 'Vozidlo přejmenováno na $spz. Historie byla zachována.';
  }

  @override
  String get vozidloDetailNenalezeno => 'Vozidlo nenalezeno.';

  @override
  String get vozidloDetailBezSpz => 'Vozidlo bez SPZ';

  @override
  String get vozidloDetailLabel => 'VOZIDLO';

  @override
  String get vozidloTabInfo => 'Info';

  @override
  String get vozidloTabZaznamy => 'Záznamy';

  @override
  String get vozidloSmazatAkce => 'Smazat vozidlo';

  @override
  String get vozidloSmazatDialogTitle => 'Smazat vozidlo?';

  @override
  String get vozidloSmazatDialogText =>
      'Vozidlo bude odebráno z adresáře. Historie zakázek zůstane zachována.';

  @override
  String get vozidloSmazano => 'Vozidlo bylo smazáno.';

  @override
  String get vozidloSmazatBtn => 'Smazat';

  @override
  String get prijemHelperTelefon => 'Telefonní číslo';

  @override
  String get prijemHelperPredvolba => 'Vyberte předvolbu';

  @override
  String get prijemStavTitle => 'Stav vozidla';

  @override
  String get prijemStavTacho => 'Stav tachometru (km)';

  @override
  String prijemStavNadrz(int value) {
    return 'Stav paliva v nádrži ($value %)';
  }

  @override
  String get prijemStavPoskozeni => 'Zjištěná poškození (lze vybrat více)';

  @override
  String get prijemStavVlastniPopis => 'Vlastní popis poškození...';

  @override
  String get prijemStavPridat => 'Přidat vlastní poškození';

  @override
  String get prijemStavPlatnostStk => 'Platnost STK';

  @override
  String get prijemStavMesic => 'Měsíc';

  @override
  String get prijemStavRok => 'Rok';

  @override
  String get prijemStavPneu => 'Hloubka dezénu pneu (v mm)';

  @override
  String get prijemStavLevaPreh => 'Levá př.';

  @override
  String get prijemStavPravaPreh => 'Pravá př.';

  @override
  String get prijemStavLevaZad => 'Levá zad.';

  @override
  String get prijemStavPravaZad => 'Pravá zad.';

  @override
  String get prijemStavPoznamky => 'Dodatečné poznámky k vozu';

  @override
  String get prijemStavPoznamkyHint => 'Jakékoliv další detaily k příjmu...';

  @override
  String get prijemZakaznikTitle => 'Údaje o zákazníkovi';

  @override
  String get prijemZakaznikJmeno => 'Jméno a příjmení / Název firmy';

  @override
  String get prijemZakaznikHledat => 'Hledat uloženého zákazníka';

  @override
  String get prijemZakaznikIco => 'IČO (ARES vyhledávání)';

  @override
  String get prijemZakaznikHledatAres => 'Hledat v ARES';

  @override
  String get prijemZakaznikPravniForma => 'Právní forma';

  @override
  String get prijemZakaznikUlice => 'Ulice a číslo';

  @override
  String get prijemZakaznikMesto => 'Město';

  @override
  String get prijemZakaznikPsc => 'PSČ';

  @override
  String get prijemZakaznikEmail => 'E-mail';

  @override
  String get prijemZakaznikFyzicka => 'Fyzická osoba';

  @override
  String get prijemZakaznikOsvc => 'OSVČ';

  @override
  String get prijemVozidloTitle => 'Záznam vozidla';

  @override
  String get prijemVozidloNapoveda =>
      'Naskenujte VIN nebo SPZ, nebo údaje doplňte ručně.';

  @override
  String get prijemVozidloZeme => 'Země';

  @override
  String get prijemVozidloSpz => 'SPZ vozidla';

  @override
  String get prijemVozidloHledatSpz => 'Hledat SPZ v databázi';

  @override
  String get prijemVozidloHledatSpzSub =>
      'Najít dříve uložené vozidlo podle SPZ';

  @override
  String get prijemVozidloVin => 'VIN kód';

  @override
  String get prijemVozidloHledatVin => 'Hledat VIN v databázi';

  @override
  String get prijemVozidloHledatVinSub =>
      'Najít dříve uložené vozidlo podle VIN';

  @override
  String get prijemVozidloDekodovat => 'Dekódovat VIN online';

  @override
  String get prijemVozidloDekodovatSub =>
      'Doplnit značku, model, motorizaci a STK';

  @override
  String get prijemVozidloZnackaHint => 'Značka (např. Škoda)';

  @override
  String get prijemVozidloModelHint => 'Model (např. Octavia)';

  @override
  String get prijemVozidloSkenovat => 'Skenovat VIN/SPZ';

  @override
  String get prijemVozidloSkenSub => 'Automaticky rozpozná typ kódu';

  @override
  String get prijemVozidloRozlozeniPodSebou => 'Pod sebou';

  @override
  String get prijemVozidloRozlozeniVMrizce => 'V mřížce';

  @override
  String get prijemVozidloTypZaznamu => 'Typ záznamu';

  @override
  String get prijemVozidloCisloZaznamu => 'Číslo záznamu';

  @override
  String get prijemVozidloGenerovat => 'Vygenerovat nové číslo';

  @override
  String get prijemVozidloUlozenaVozidla => 'Zákazník má uložená tato vozidla';

  @override
  String get prijemVozidloRokVyroby => 'Rok výroby';

  @override
  String get prijemVozidloMotorizaceHint => 'Motorizace (např. 2.0 TDI)';

  @override
  String get prijemVozidloTypPaliva => 'Typ paliva';

  @override
  String get prijemVozidloPrevodovka => 'Převodovka';

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
  String get prijemVozidloJine => 'Jiné';

  @override
  String get prijemVozidloManualni => 'Manuální';

  @override
  String get prijemVozidloAutomaticka => 'Automatická';

  @override
  String get prijemVozidloDalsiUdaje => 'Další údaje o vozidle';

  @override
  String get prijemVozidloDalsiUdajeSub =>
      'Nepovinné – doplní se z VIN dekodéru';

  @override
  String get prijemVozidloBarva => 'Barva';

  @override
  String get prijemVozidloVykon => 'Výkon (kW)';

  @override
  String get prijemVozidloPocetMist => 'Počet míst';

  @override
  String get prijemVozidloPocetDveri => 'Počet dveří';

  @override
  String get prijemVozidloRozmery => 'Rozměry (D × Š × V mm)';

  @override
  String get prijemVozidloDelka => 'Délka';

  @override
  String get prijemVozidloSirka => 'Šířka';

  @override
  String get prijemVozidloVyska => 'Výška';

  @override
  String get prijemPraceTitle => 'Požadované práce';

  @override
  String get prijemPracePozadavkyHint =>
      'Na čem jsme se se zákazníkem domluvili?';

  @override
  String get prijemPraceRychlyVyber => 'Rychlý výběr nejčastějších úkonů:';

  @override
  String get prijemPraceSeznam => 'Seznam požadavků k zakázce:';

  @override
  String get prijemPracePridat => 'Přidat jiný úkon';

  @override
  String prijemPraceUkonN(int n) {
    return 'Úkon $n';
  }

  @override
  String get prijemPodpisTitle => 'Shrnutí';

  @override
  String get prijemPodpisNeuvedeno => 'Neuvedeno';

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
  String get prijemPodpisSjednaneUkony => 'Sjednané úkony:';

  @override
  String get prijemRekapZaznam => 'Záznam';

  @override
  String get prijemKonceptTitle => 'Neodeslaná zakázka';

  @override
  String get prijemKonceptText =>
      'Máte rozpracovanou neodeslanou zakázku. Chcete pokračovat tam, kde jste skončili?';

  @override
  String get prijemKonceptObnovit => 'Obnovit';

  @override
  String get prijemKonceptZahodit => 'Zahodit';

  @override
  String get prijemPodpisEmailToggle => 'Odeslat kopii protokolu na e-mail';

  @override
  String get prijemPodpisEmailChybi =>
      'U zákazníka (krok 2) není vyplněn žádný e-mail.';

  @override
  String prijemPodpisEmailKam(String email) {
    return 'Bude odesláno na: $email';
  }

  @override
  String get prijemPodpisSouhlas =>
      'Zákazník svým podpisem stvrzuje správnost výše uvedených údajů a souhlasí se stavem vozidla při převzetí do servisu.';

  @override
  String get prijemPodpisSmazat => 'Smazat podpis';

  @override
  String get prijemPodpisVypnut =>
      'Podpis zákazníka je v nastavení servisu vypnut.';

  @override
  String get prijemPodpisOtevrit => 'Podepsat';

  @override
  String get prijemPodpisZnovu => 'Podepsat znovu';

  @override
  String get prijemPodpisHotovo => 'Hotovo';

  @override
  String get prijemPodpisZavrit => 'Zavřít';

  @override
  String get prijemPodpisHint => 'Podepište se prstem nebo perem';

  @override
  String get prijemPodpisNahled => 'Podpis zákazníka';

  @override
  String get prijemPodpisZahoditTitul => 'Zahodit podpis?';

  @override
  String get prijemPodpisZahoditPomoc =>
      'Máte rozepsaný podpis. Opravdu ho zahodit?';

  @override
  String get prijemPodpisZahodit => 'Zahodit';

  @override
  String get predaniTitul => 'Předání vozidla';

  @override
  String get predaniTlacitko => 'Předat zákazníkovi';

  @override
  String get predaniProvedenePrace => 'Provedené práce';

  @override
  String get predaniPridatPraci => 'Přidat práci';

  @override
  String get predaniVybratZCeniku => 'Vybrat z ceníku';

  @override
  String get predaniNazevPrace => 'Název práce';

  @override
  String get predaniCena => 'Cena';

  @override
  String get predaniCelkem => 'Celkem k úhradě';

  @override
  String get predaniBezPrace => 'Zatím žádné práce. Přidejte provedené úkony.';

  @override
  String get predaniPorovnani => 'Porovnání stavu';

  @override
  String get predaniPriPrijmu => 'Při příjmu';

  @override
  String get predaniPriPredani => 'Při předání';

  @override
  String get predaniTachometrPredani => 'Tachometr při předání (km)';

  @override
  String get predaniFoto => 'Foto při předání';

  @override
  String get predaniPridatFoto => 'Přidat foto';

  @override
  String get predaniPodpisPrevzeti => 'Podpis převzetí';

  @override
  String get predaniSouhlas =>
      'Zákazník svým podpisem stvrzuje převzetí vozidla a souhlasí s provedenými pracemi i výší účtované částky.';

  @override
  String get predaniDokoncit => 'Dokončit předání';

  @override
  String get predaniHotovo => 'Vozidlo bylo předáno zákazníkovi.';

  @override
  String get predaniChybaPodpis => 'Zákazník musí připojit podpis převzetí.';

  @override
  String get predaniProbiha => 'Ukládám předání…';

  @override
  String get predaniDatum => 'Datum předání';

  @override
  String get predaniPredal => 'Předal';

  @override
  String get prijemTabletPostup => 'POSTUP';

  @override
  String get prijemTabletPosledniNavsteva => 'POSLEDNÍ NÁVŠTĚVA';

  @override
  String get prijemTabletVozidlo => 'Vozidlo';

  @override
  String get prijemTabletTacho => 'Tachometr';

  @override
  String get prijemTabletStk => 'STK';

  @override
  String get prijemTabletNaposledy => 'Naposledy';

  @override
  String get prijemTabletStav => 'Stav';

  @override
  String get prijemTabletStavPriPrijmu => 'Stav při příjmu';

  @override
  String get prijemTabletPoskozeni => 'Poškození';

  @override
  String get prijemTabletNeuvedeno => 'Neuvedeno';

  @override
  String get prijemTabletNahled => 'NÁHLED VOZIDLA';

  @override
  String get prijemTabletSpz => 'SPZ';

  @override
  String get prijemTabletVin => 'VIN';

  @override
  String get prijemTabletZakazka => 'Zakázka';

  @override
  String get prijemTabletUdajePlni =>
      'Údaje se plní průběžně při vyplňování formuláře.';

  @override
  String get prijemErrVinVyhledani => 'Zadejte alespoň část VIN pro vyhledání.';

  @override
  String get prijemErrServisId => 'Chyba: ID Servisu se nepodařilo načíst.';

  @override
  String get prijemErrZadneVozidloVin =>
      'Žádné vozidlo s tímto VIN nebylo nalezeno.';

  @override
  String get prijemErrSpzVyhledani => 'Zadejte alespoň část SPZ pro vyhledání.';

  @override
  String get prijemErrZadneVozidloSpz =>
      'Žádné vozidlo s touto SPZ nebylo nalezeno.';

  @override
  String get prijemErrZadejteVin => 'Zadejte VIN kód pro dekódování.';

  @override
  String prijemStkPlatnaSnackbar(String datum) {
    return 'STK platná do $datum';
  }

  @override
  String prijemStkProslaSnackbar(String datum) {
    return 'STK prošlá! Platila do $datum';
  }

  @override
  String get prijemVincarioDoplneno => 'Údaje vozidla doplněny z Vincario.';

  @override
  String get prijemVozidloNacteno =>
      'Údaje o vozidle a zákazníkovi byly načteny.';

  @override
  String get prijemNalezenoVice => 'Nalezeno více vozidel';

  @override
  String get prijemVyberVozidlo => 'Vyberte konkrétní vozidlo ze seznamu:';

  @override
  String get prijemNeznanaSpz => 'Neznámá SPZ';

  @override
  String get prijemErrCisloASpz => 'Číslo záznamu a SPZ jsou povinné údaje!';

  @override
  String get prijemErrCislo => 'Číslo záznamu je povinný údaj!';

  @override
  String get prijemErrSpz => 'SPZ vozidla je povinný údaj!';

  @override
  String get prijemErrCisloDuplicitni =>
      'Toto číslo záznamu již v databázi existuje! Zadejte prosím jiné.';

  @override
  String get prijemErrPodpis => 'Zákazník musí připojit podpis před odesláním.';

  @override
  String get prijemLimitTitle => 'Limit příjmů dosažen';

  @override
  String prijemLimitText(String plan, int limit) {
    return 'Váš plán $plan umožňuje maximálně $limit příjmů za měsíc. Pro více příjmů upgradujte plán.';
  }

  @override
  String get prijemZavrit => 'Zavřít';

  @override
  String get prijemUspesne => 'Zakázka úspěšně odeslána';

  @override
  String get prijemErrNejstePrirazeni => 'Nejste přiřazeni k žádnému servisu!';

  @override
  String get prijemSkenJenApp =>
      'Skenování pomocí AI funguje pouze v nainstalované aplikaci (APK/iOS).';

  @override
  String get prijemNavigaceLabel => 'ZÁZNAM VOZIDLA';

  @override
  String get prijemNovyZaznam => 'Nový záznam';

  @override
  String get prijemDokoncit => 'Dokončit a odeslat';

  @override
  String get prijemPokracovat => 'Pokračovat';

  @override
  String get prijemOdesilamMsg => 'Odesílám zakázku a protokol...';

  @override
  String prijemNahravamFotky(int hotovo, int celkem) {
    return 'Nahrávám fotky $hotovo/$celkem';
  }

  @override
  String prijemKrokZ(int krok, int celkem) {
    return 'Krok $krok z $celkem';
  }

  @override
  String get prijemStepIdentifikace => 'Identifikace vozu';

  @override
  String get prijemStepZakaznik => 'Zákazník';

  @override
  String get prijemStepFoto => 'Fotodokumentace';

  @override
  String get prijemStepStav => 'Stav vozu';

  @override
  String get prijemStepPrace => 'Úkony a práce';

  @override
  String get prijemStepSouhrn => 'Souhrn';

  @override
  String prijemSkenNenalezeno(String co) {
    return 'Naskenováno \'$co\'. V databázi nenalezeno — údaje doplňte ručně.';
  }

  @override
  String get vinSekceIdentifikace => 'IDENTIFIKACE';

  @override
  String get vinSekceMotor => 'MOTOR A POHON';

  @override
  String get vinSekceKaroserie => 'KAROSERIE A ROZMĚRY';

  @override
  String get vinSekcePalivo => 'PALIVO A EMISE';

  @override
  String get vinSekceOstatni => 'OSTATNÍ INFORMACE';

  @override
  String get vinFieldZnacka => 'Značka';

  @override
  String get vinFieldModel => 'Model';

  @override
  String get vinFieldObchodniOznaceni => 'Obchodní označení';

  @override
  String get vinFieldRokVyroby => 'Rok výroby';

  @override
  String get vinFieldKaroserie => 'Karosérie';

  @override
  String get vinFieldTypVarianta => 'Typ / varianta';

  @override
  String get vinFieldMistoVyroby => 'Místo výroby';

  @override
  String get vinFieldMotorizace => 'Motorizace';

  @override
  String get vinFieldTypMotoru => 'Typ motoru';

  @override
  String get vinFieldZdvihObjem => 'Zdvihový objem';

  @override
  String get vinFieldPocetValcu => 'Počet válců';

  @override
  String get vinFieldVykon => 'Výkon';

  @override
  String get vinFieldTocivyMoment => 'Max. točivý moment';

  @override
  String get vinFieldPalivo => 'Palivo';

  @override
  String get vinFieldPrevodovka => 'Převodovka';

  @override
  String get vinFieldPocetPrevodu => 'Počet převodů';

  @override
  String get vinFieldPohon => 'Pohon';

  @override
  String get vinFieldMaxRychlost => 'Max. rychlost';

  @override
  String get vinFieldTypKaroserie => 'Typ karosérie';

  @override
  String get vinFieldPocetDveri => 'Počet dveří';

  @override
  String get vinFieldPocetMist => 'Počet míst';

  @override
  String get vinFieldProvozniHmotnost => 'Provozní hmotnost';

  @override
  String get vinFieldMaxHmotnost => 'Max. hmotnost';

  @override
  String get vinFieldTaznaHmotnost => 'Tažná hmotnost';

  @override
  String get vinFieldRozvorNaprav => 'Rozvor náprav';

  @override
  String get vinFieldDelka => 'Délka';

  @override
  String get vinFieldSirka => 'Šířka';

  @override
  String get vinFieldVyska => 'Výška';

  @override
  String get vinFieldObjemNadrze => 'Objem nádrže';

  @override
  String get vinField1Registrace => '1. registrace';

  @override
  String get vinFieldEmisniNorma => 'Emisní norma';

  @override
  String get vinFieldEmiseCo2 => 'Emise CO₂';

  @override
  String get vinFieldSpotrebaKomb => 'Spotřeba (komb.)';

  @override
  String get vinFieldSpotrebaMesto => 'Spotřeba ve městě';

  @override
  String get vinFieldSpotrebaDalnice => 'Spotřeba mimo město';

  @override
  String get vinFieldElektDojezd => 'Elektrický dojezd';

  @override
  String vinLimitDekodovani(int pocet, int limit) {
    return 'Dosáhli jste měsíčního limitu $pocet / $limit dekódování. Upgradujte plán pro pokračování.';
  }

  @override
  String vinLimitValue(int pocet, int limit) {
    return 'Dosáhli jste měsíčního limitu $pocet / $limit zjištění.';
  }

  @override
  String get vinTrzniChybaVerze =>
      'Zjištění tržní hodnoty není součástí zkušební verze — odemknete ho v některém z placených plánů.';

  @override
  String get vinChybaHistorie => 'Nepodařilo se načíst historii.';

  @override
  String get vinTotoVozidloNebyloDekodovano =>
      'Toto vozidlo nebylo dříve dekódováno.';

  @override
  String get vinPraveTed => 'Právě teď';

  @override
  String vinPredMinutami(int pocet) {
    return 'před $pocet min';
  }

  @override
  String get vinVincarioKlice =>
      'Vincario API klíče nejsou nastaveny. Doplňte je v Nastavení servisu, aby dekódování fungovalo.';

  @override
  String vinTrzniOd(String value, String mena) {
    return 'od $value $mena';
  }

  @override
  String vinTrzniDo(String value, String mena) {
    return 'do $value $mena';
  }

  @override
  String get vinTrzniHodnotaTitle => 'Tržní hodnota';

  @override
  String get vinStkTitle => 'Zjištění STK';

  @override
  String get vinTrzniSubtitle =>
      'Odhad tržní ceny vozidla z dat evropského trhu';

  @override
  String get vinStkSubtitle =>
      'Přehled technických prohlídek vozidla z registru';

  @override
  String get vinSkenTitleVin => 'Skenovat VIN kód';

  @override
  String get vinSkenTitleTrzni => 'Skenovat VIN pro tržní hodnotu';

  @override
  String get vinSkenTitleStk => 'Skenovat VIN pro STK';

  @override
  String get vinSkenPopisVin =>
      'Automaticky načte specifikace vozu podle naskenovaného nebo zadaného VIN';

  @override
  String get vinSkenPopisTrzni =>
      'Zjistí odhad tržní ceny vozu podle naskenovaného nebo zadaného VIN z dat evropského trhu';

  @override
  String get vinSkenPopisStk =>
      'Načte data o technických prohlídkách vozidla z registru';

  @override
  String get vinSkenTlacitko => 'Spustit sken';

  @override
  String get vinInputHint => 'Zadat VIN ručně (např. TMBJJ7NE5K…)';

  @override
  String get vinTooltipHodnota => 'Zjistit hodnotu';

  @override
  String get vinTooltipStk => 'Zjistit STK';

  @override
  String get vinTooltipDekodovat => 'Dekódovat';

  @override
  String get vinUpsellTitle => 'Tržní hodnota je v placených plánech';

  @override
  String get vinUpsellSubtitle =>
      'Ve zkušební verzi není dostupná. Odemknete ji už v plánu Basic.';

  @override
  String get vinUpsellPlany => 'Plány';

  @override
  String get vinLimitTrzniMesic => 'Tržní hodnota tento měsíc';

  @override
  String get vinLimitDekodovaniMesic => 'Dekódování VIN tento měsíc';

  @override
  String get vinLimitVycerpan =>
      'Měsíční limit vyčerpán. Upgradujte plán pro pokračování.';

  @override
  String get vinStkInfoBanner =>
      'Data pocházejí z veřejného registru vozidel. Dostupnost a aktuálnost se liší — u některých vozidel nemusí být STK evidována.';

  @override
  String vinChybaDekodovani(String chyba) {
    return 'Nepodařilo se dekódovat VIN: $chyba';
  }

  @override
  String get vinNovySken => 'Nový sken';

  @override
  String get vinTrzniHodnotaHeader => 'TRŽNÍ HODNOTA';

  @override
  String get vinStkPlatnostNeznama => 'STK — datum neznámé';

  @override
  String vinStkPlatnaJesteXDni(int dnu) {
    return 'STK platná ještě $dnu dní';
  }

  @override
  String vinStkNeplatna(int dnu) {
    return 'STK neplatná (prošlá o $dnu dní)';
  }

  @override
  String get vinStkPlatnostDo => 'Platnost STK do';

  @override
  String get vinTrzniDataNedostupna => 'Evropská data nejsou k dispozici.';

  @override
  String get vinTrzniMedian => 'medián';

  @override
  String get vinTrzniPrumernaCena => 'Průměrná cena';

  @override
  String get vinTrzniPrumernyNajezd => 'Průměrný nájezd';

  @override
  String get vinTrzniPocetVzorku => 'Počet vzorků';

  @override
  String get vinTrzniObdobiDat => 'Období dat';

  @override
  String get vinTrzniZdroj => 'Evropský trh · Vincario Market Value';

  @override
  String get vinTrzniNajezdLabel => 'Najeté km vozidla';

  @override
  String get vinTrzniOdhad => 'Odhad podle nájezdu';

  @override
  String get vinTrzniOdhadVysvetleni =>
      'Orientační odhad zůstatkové hodnoty vypočtený z rozsahu cen a nájezdů ve vzorku.';

  @override
  String get vinHistorieNadpis => 'Historie skenů';

  @override
  String vinHistorieDnes(int pocet) {
    return 'Dnes · $pocet dekódovaných VIN';
  }

  @override
  String get vinHistoriePosledni => 'Poslední skeny';

  @override
  String get vinHistorieVse => 'Vše';

  @override
  String get vinHistorieNacitani => 'Načítání…';

  @override
  String get vinHistorieZadneSkeny => 'Zatím žádné skeny.';

  @override
  String get vinHistorieNoveVozidlo => 'Nové vozidlo';

  @override
  String get vinHistoriePoprve => 'Poprvé dekódováno';

  @override
  String vinHistorieDekodovanoX(int pocet) {
    return 'Dekódováno $pocet×';
  }

  @override
  String get vinHistorieNezname => 'Neznámé vozidlo';

  @override
  String get vinZadejteVin => 'Zadejte VIN kód.';

  @override
  String get vinSkenJenApk =>
      'Skenování funguje pouze v nainstalované aplikaci (APK/iOS).';

  @override
  String get vinFieldKodMotoru => 'Kód motoru';

  @override
  String get zakZakaznici => 'Zákazníci';

  @override
  String get zakSubtitle => 'Adresář vašich klientů a jejich vozidel.';

  @override
  String get zakHledatHint => 'Hledat jméno, telefon nebo IČO...';

  @override
  String zakChybaDb(String chyba) {
    return 'Chyba databáze: $chyba';
  }

  @override
  String get zakZadniZakaznici => 'Zatím nemáte žádné zákazníky.';

  @override
  String zakIcoZnak(String ico) {
    return '🏢 IČO: $ico';
  }

  @override
  String get zakEditTitle => 'Úprava zákazníka';

  @override
  String get zakJmenoLabel => 'Jméno a Příjmení / Název firmy';

  @override
  String get zakTelLabel => 'Telefon';

  @override
  String get zakVybertePredvolbu => 'Vyberte předvolbu';

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
  String get zakUlozitZmeny => 'ULOŽIT ZMĚNY';

  @override
  String get zakZpracovavam => 'Zpracovávám data...';

  @override
  String get zakKartaZakaznika => 'Karta zákazníka';

  @override
  String get zakHeaderLabel => 'ZÁKAZNÍK';

  @override
  String get zakTabInfo => 'Info';

  @override
  String get zakTabZaznamy => 'Záznamy';

  @override
  String get zakSmazatMenu => 'Smazat zákazníka';

  @override
  String get zakSmazatTitle => 'Smazat zákazníka?';

  @override
  String get zakSmazatContent =>
      'Zákazník bude odebrán z adresáře. Jeho vozidla a historie zakázek zůstanou zachovány.';

  @override
  String get zakZrusit => 'Zrušit';

  @override
  String get zakSmazatPotvrdit => 'Smazat';

  @override
  String get zakSmazanUspesne => 'Zákazník byl smazán.';

  @override
  String zakChybaMazani(String chyba) {
    return 'Chyba při mazání: $chyba';
  }

  @override
  String get zakNeznamyZakaznik => 'Neznámý zákazník';

  @override
  String get zakFirma => 'Firma';

  @override
  String get zakSoukromaOsoba => 'Soukromá osoba';

  @override
  String get zakStatVozidel => 'VOZIDEL';

  @override
  String get zakStatPrijmu => 'PŘÍJMŮ';

  @override
  String get zakVolat => 'Volat';

  @override
  String get zakSms => 'SMS';

  @override
  String get zakKontaktniUdaje => 'Kontaktní údaje';

  @override
  String get zakVozidlaTitle => 'Vozidla zákazníka';

  @override
  String get zakPridat => 'Přidat';

  @override
  String get zakZadnaVozidla => 'Zákazník nemá uložená žádná vozidla.';

  @override
  String get zakBezSpz => 'Bez SPZ';

  @override
  String get zakZadneZaznamy => 'Zákazník zatím nemá žádné záznamy o příjmu.';

  @override
  String zakZakazka(Object cislo) {
    return 'Zakázka $cislo';
  }

  @override
  String zakPoskozeni(String seznam) {
    return 'Poškození: $seznam';
  }

  @override
  String get zakPodepsano => 'Podepsáno';

  @override
  String zakFotoKs(int pocet) {
    return '$pocet foto';
  }

  @override
  String get authBiometricReason => 'Přihlaste se do Torkis';

  @override
  String get authBiometricChybaStorage =>
      'Nejprve se přihlaste heslem — Face ID se aktivuje pro příští spuštění.';

  @override
  String get authBiometricChybaUdaje =>
      'Uložené přihlašovací údaje jsou neplatné. Přihlaste se heslem.';

  @override
  String get authChybaPrazdnaPola => 'Zadejte prosím e-mail i heslo.';

  @override
  String get authChybaHeslaNeshoda => 'Zadaná hesla se neshodují.';

  @override
  String get authChybaOverovani => 'Došlo k chybě při ověřování.';

  @override
  String get authChybaNeplatneUdaje => 'Nesprávný e-mail nebo heslo.';

  @override
  String get authChybaEmailExistuje => 'Tento e-mail je již zaregistrován.';

  @override
  String get authChybaSlabeHeslo => 'Heslo je příliš slabé (min. 6 znaků).';

  @override
  String get authChybaFormatEmail => 'Neplatný formát e-mailu.';

  @override
  String authChybaNeocekvana(String chyba) {
    return 'Neočekávaná chyba: $chyba';
  }

  @override
  String get authResetHint =>
      'Pro obnovu hesla zadejte platný e-mail do horního políčka.';

  @override
  String get authResetOdeslan => 'E-mail pro obnovu hesla byl odeslán.';

  @override
  String get authResetChyba => 'Chyba při odesílání e-mailu pro obnovu.';

  @override
  String get authSubtitleLogin => 'Digitální evidence vozidel';

  @override
  String get authSubtitleRegister => 'Zaregistrujte svůj servis';

  @override
  String get authEmailHint => 'E-mail';

  @override
  String get authHesloHint => 'Heslo';

  @override
  String get authPotvrzeniHeslaHint => 'Potvrzení hesla';

  @override
  String get authZapomenuteHeslo => 'Zapomněli jste heslo?';

  @override
  String get authPrihlasitSe => 'Přihlásit se';

  @override
  String get authVytvoritUcet => 'Vytvořit účet';

  @override
  String get authBiometrickePrihlaseni => 'Přihlásit se biometricky';

  @override
  String get authNebo => 'nebo';

  @override
  String get authGoogleBtn => 'Pokračovat přes Google';

  @override
  String get authAppleBtn => 'Pokračovat přes Apple';

  @override
  String get authNematUcet => 'Nemáte účet?';

  @override
  String get authZaregistrujteSe => 'Zaregistrujte se';

  @override
  String get authMateUcet => 'Již máte účet?';

  @override
  String get authPrihlasteSe => 'Přihlaste se';

  @override
  String predChybaNakup(String chyba) {
    return 'Nákup se nepodařil: $chyba';
  }

  @override
  String get predChybaEmailKlient =>
      'Nepodařilo se otevřít e-mailového klienta.';

  @override
  String get predTitle => 'Vaše předplatné';

  @override
  String get predSubtitle =>
      'Spravujte plán svého servisu a podle potřeby ho upgradujte.';

  @override
  String get predTrialBannerTitle => 'Aktivní zkušební doba';

  @override
  String predAktivniPlanTitle(String plan) {
    return 'Aktivní plán: $plan';
  }

  @override
  String get predTrialBannerSubtitle =>
      'Po skončení trialu si vyberete plán, který vám sedne.';

  @override
  String get predAktivniPlanSubtitle => 'Děkujeme, že používáte TORKIS.';

  @override
  String get predMesicne => 'Měsíčně';

  @override
  String get predRocne => 'Ročně';

  @override
  String get predFootnote => 'Bez závazku · Zrušení kdykoli · Ceny bez DPH';

  @override
  String get predBasicDesc => 'Pro malé autoservisy a OSVČ.';

  @override
  String get predStandardDesc => 'Pro střední servisy do 150 zakázek měsíčně.';

  @override
  String get predProDesc => 'Pro velké servisy a sítě bez limitu záznamů.';

  @override
  String get predCustomDesc =>
      'Individuální úprava pro speciální požadavky a integrace.';

  @override
  String get predFeat50Zaznamu => '50 záznamů/měsíc';

  @override
  String get predFeat3Uziv => '3 uživatelé max.';

  @override
  String get predFeat30Vin => '30 dekodovaných VIN měsíčně';

  @override
  String get predFeat1TrzniHodnota => '1 zjištění tržní hodnoty měsíčně';

  @override
  String get predFeatNeomezStk => 'Neomezený počet zjištění platnosti STK';

  @override
  String get predFeatFotodok => 'Fotodokumentace';

  @override
  String get predFeatEvidZak => 'Evidence zákazníků a vozidel';

  @override
  String get predFeatHistorie => 'Historie záznamů';

  @override
  String get predFeatSpravaTymu => 'Správa týmu';

  @override
  String get predFeat150Zaznamu => '150 záznamů/měsíc';

  @override
  String get predFeat10Uziv => '10 uživatelů max.';

  @override
  String get predFeat60Vin => '60 dekodovaných VIN měsíčně';

  @override
  String get predFeat120Vin => '120 dekodovaných VIN měsíčně';

  @override
  String get predFeat75Vin => '75 dekodovaných VIN měsíčně';

  @override
  String get predFeat3TrzniHodnota => '3 zjištění tržní hodnoty měsíčně';

  @override
  String get predFeatVseBasic => 'Vše z Basic';

  @override
  String get predFeatReporty => 'Reporty a statistiky';

  @override
  String get predFeatChat => 'Chat se zákazníkem';

  @override
  String get predFeatWebPortal =>
      'Webový portál pro správu vozidel a zákazníků';

  @override
  String get predFeatNeomezZaznamu => 'Neomezené záznamy';

  @override
  String get predFeatNeomezUziv => 'Neomezený počet uživatelů';

  @override
  String get predFeatVseStandard => 'Vše ze Standard';

  @override
  String get predFeat150Vin => '150 dekodovaných VIN měsíčně';

  @override
  String get predFeat5TrzniHodnota => '5 zjištění tržní hodnoty měsíčně';

  @override
  String get predFeatPrioritniPodpora => 'Prioritní podpora';

  @override
  String get predFeatPokrocileStatistiky => 'Pokročilé statistiky';

  @override
  String get predFeatVicenasobinaVzd => 'Vícenásobná pracoviště';

  @override
  String get predFeatErp => 'Napojení na vaše ERP/DMS';

  @override
  String get predFeatNeomezVin => 'Neomezený počet dekodovaných VIN měsíčně';

  @override
  String get predFeatNeomezTrzni => 'Neomezená tržní hodnota vozidel';

  @override
  String get predFeatPrioritniSla => 'Prioritní podpora s SLA';

  @override
  String get paywallTitle => 'Vyberte plán';

  @override
  String get paywallSubtitleTrialEnding =>
      'Vaše zkušební období brzy končí. Vyberte plán pro pokračování.';

  @override
  String get paywallSubtitleTrialExpired =>
      'Vaše zkušební období skončilo. Vyberte plán odpovídající velikosti servisu.';

  @override
  String paywallTrialZbyva(int n, String slovo) {
    return 'Zbývá $n $slovo zkušebního období';
  }

  @override
  String get paywallBezpeci =>
      'Vaše data jsou v bezpečí. Po výběru plánu vše obnovíme.';

  @override
  String get paywallZadnePredplatne => 'Nenalezeno žádné aktivní předplatné.';

  @override
  String paywallChybaObnoveni(String chyba) {
    return 'Chyba obnovení: $chyba';
  }

  @override
  String get paywallObnovitNakupy => 'Obnovit nákupy';

  @override
  String get predPeriodMesic => 'měsíčně';

  @override
  String get predPeriodRoc => 'ročně';

  @override
  String get predCenaNaMiru => 'Cena na míru';

  @override
  String get predDoporucujeme => 'DOPORUČUJEME';

  @override
  String get predAktualniPlanPill => 'AKTUÁLNÍ PLÁN';

  @override
  String get predAktualneAktivni => 'Aktuálně aktivní';

  @override
  String get predMamZajem => 'Mám zájem';

  @override
  String predVybrat(String name) {
    return 'Vybrat $name';
  }

  @override
  String get paywallTrust1Title => '99,9 % dostupnost';

  @override
  String get paywallTrust1Sub => 'Garantovaná uptime SLA';

  @override
  String get paywallTrust2Title => 'Export dat zdarma';

  @override
  String get paywallTrust2Sub => 'Vaše data jsou vždy vaše';

  @override
  String get onbAresChybaIco => 'Zadejte platné 8místné IČO.';

  @override
  String get onbAresNacteno => 'Údaje z ARES byly načteny.';

  @override
  String get onbAresNenalezeno => 'Zadané IČO nebylo v registru ARES nalezeno.';

  @override
  String onbAresChyba(String chyba) {
    return 'Chyba při komunikaci s ARES: $chyba';
  }

  @override
  String get onbBiometricReason =>
      'Potvrďte svou totožnost pro zapnutí biometrického přihlášení';

  @override
  String get onbDialogUpravitTyp => 'Upravit typ';

  @override
  String get onbDialogNovyTyp => 'Nový typ záznamu';

  @override
  String get onbDialogNazevTypuHint => 'Název typu (např. Servis, Výkup...)';

  @override
  String get onbZrusit => 'Zrušit';

  @override
  String get onbUlozit => 'Uložit';

  @override
  String onbChybaUkladani(String chyba) {
    return 'Chyba při ukládání: $chyba';
  }

  @override
  String get onbChybaNazev => 'Název servisu je povinný pro pokračování.';

  @override
  String get onbDokoncit => 'DOKONČIT NASTAVENÍ';

  @override
  String get onbPokracovat => 'POKRAČOVAT';

  @override
  String get onbKrok1Nadpis => 'Vítejte ve TORKIS!';

  @override
  String get onbKrok1Popis =>
      'Nejprve vyplníme základní informace o vás nebo o vaší společnosti.';

  @override
  String get onbIcoLabel => 'IČO (ARES vyhledávání)';

  @override
  String get onbIcoHint => 'Např. 12345678';

  @override
  String get onbAresLoadTooltip => 'Načíst z ARES';

  @override
  String get onbNazevLabel => 'Název servisu / Jméno *';

  @override
  String get onbNazevHint => 'Zadejte název...';

  @override
  String get onbDicLabel => 'DIČ (nepovinné)';

  @override
  String get onbDicHint => 'Např. CZ12345678';

  @override
  String get onbRegistraceLabel => 'Zápis v rejstříku (nepovinné)';

  @override
  String get onbRegistraceHint => 'Např. zapsán v ŽR u MÚ...';

  @override
  String get onbSidloNadpis => 'Sídlo a kontakt';

  @override
  String get onbSidloPopis =>
      'Údaje se použijí na nabídkách, fakturách a v komunikaci.';

  @override
  String get onbUliceLabel => 'Ulice a č.p.';

  @override
  String get onbUliceHint => 'Např. Hlavní 123';

  @override
  String get onbMestoLabel => 'Město';

  @override
  String get onbMestoHint => 'Např. Brno';

  @override
  String get onbPscLabel => 'PSČ';

  @override
  String get onbTelefonLabel => 'Telefon servisu';

  @override
  String get onbTelefonHint => 'Např. +420 777 123 456';

  @override
  String get onbKomunikaceNadpis => 'Komunikace a vzhled';

  @override
  String get onbEmailLabel =>
      'E-mailová adresa (z níž budou odcházet e-maily zákazníkům)';

  @override
  String get onbEmailHint => 'Např. info@autoservis.cz';

  @override
  String get onbEmailySwitchTitle => 'Automaticky zasílat e-maily';

  @override
  String get onbEmailySwitchSubtitle =>
      'Zákazníkům bude v nabídkách a při ukončení předzaškrtnuta možnost odeslání PDF e-mailem.';

  @override
  String get onbAdminNadpis => 'Váš účet (administrátor)';

  @override
  String get onbAdminPopis =>
      'Zadejte své jméno — budete přidáni jako hlavní správce servisu.';

  @override
  String get onbJmenoLabel => 'Jméno a příjmení *';

  @override
  String get onbJmenoHint => 'Např. Jan Novák';

  @override
  String get onbTmavyRezimTitle => 'Vynutit tmavý režim';

  @override
  String get onbTmavyRezimSubtitle =>
      'Aplikace bude okamžitě přepnuta do tmavého vzhledu.';

  @override
  String get onbKrok2Nadpis => 'Provoz a automatizace';

  @override
  String get onbKrok2Popis =>
      'Nastavte chování příjmu vozidla. Vše lze později kdykoliv změnit v Nastavení.';

  @override
  String get onbAutoCisloTitle => 'Automaticky generovat číslo zakázky';

  @override
  String get onbAutoCisloSubtitle =>
      'Při příjmu vozidla se číslo zakázky předvyplní automaticky. Vypnutím umožníte ruční zadání.';

  @override
  String get onbPodpisTitle => 'Vyžadovat podpis zákazníka';

  @override
  String get onbPodpisSubtitle =>
      'Při vypnutí se krok s podpisem v příjmu zobrazí bez podpisového plátna.';

  @override
  String get onbSpzTitle => 'Povinná SPZ vozidla';

  @override
  String get onbSpzSubtitle =>
      'Při vypnutí lze příjem odeslat i bez vyplněné SPZ (např. vozidla bez registrace).';

  @override
  String get onbTypyNadpis => 'Typy záznamu';

  @override
  String get onbTypyPopis =>
      'Slouží k rozlišení příjmu vozidla (např. Servis, Výkup). První typ je výchozí.';

  @override
  String get onbTypyVychozi => 'výchozí';

  @override
  String get onbPridatTyp => 'Přidat typ';

  @override
  String get onbTypyHint => 'Dlouhý stisk = nastavit jako výchozí.';

  @override
  String get onbVzoryNadpis => 'Vzory popisů poškození';

  @override
  String get onbVzoryPopis =>
      'Předdefinované popisy, ze kterých technik vybírá při značení poškození ve fotodokumentaci.';

  @override
  String get onbVzoryPrazdne => 'Zatím žádné vzory. Přidejte první.';

  @override
  String get onbPridatVzor => 'Přidat vzor';

  @override
  String get onbDialogNovyVzor => 'Nový vzor poškození';

  @override
  String get onbDialogUpravitVzor => 'Upravit vzor';

  @override
  String get onbVzorHint => 'Např. Škrábanec, Promáčklina…';

  @override
  String get onbOsobniNadpis => 'Osobní nastavení';

  @override
  String get onbBiometrieTitle => 'Biometrické přihlášení';

  @override
  String get onbBiometrieSubtitle =>
      'Face ID / otisk prstu při každém spuštění.';

  @override
  String get onbLevacTitle => 'Režim pro leváky';

  @override
  String get onbLevacSubtitle =>
      'Spoušť fotoaparátu vlevo, když je zařízení na šířku.';

  @override
  String get onbKrok3Nadpis => 'Nejčastější úkony';

  @override
  String get onbKrok3Popis =>
      'Připravili jsme pro vás seznam typických úkonů. Můžete je libovolně přepsat, smazat nebo si přidat další. Budou se vám nabízet pro rychlé přidání při příjmu vozu.';

  @override
  String get onbUkonNazevLabel => 'Název úkonu';

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
  String get onbUkonKategorieLabel => 'Kategorie';

  @override
  String get onbPridatUkon => 'Přidat další úkon';

  @override
  String get trialBadge => '30 DNÍ ZDARMA';

  @override
  String get trialNadpis => 'Vítejte v TORKISu';

  @override
  String get trialPopis =>
      'Spustili jsme vám zkušební dobu na 30 dní zdarma — bez platební karty a bez závazků.';

  @override
  String get trialBenefit1 => 'Neomezený počet záznamů vozidel a zákazníků';

  @override
  String get trialBenefit2 => '10 dekódovaných VINů';

  @override
  String get trialBenefit3 => 'Neomezený počet zjištění platnosti STK';

  @override
  String get trialBenefit4 => 'Plný přístup ke všem funkcím aplikace.';

  @override
  String get trialBenefit5 =>
      'Žádné platební údaje. Bez automatického strhávání.';

  @override
  String get trialBenefit6 =>
      'Vaše data jsou vždy vaše — export kdykoli zdarma.';

  @override
  String get trialBtn => 'Začít používat aplikaci';

  @override
  String get mainNavNovy => 'Nový';

  @override
  String get mainNavMenu => 'Menu';

  @override
  String get mainNavVozidla => 'Vozidla';

  @override
  String get mainNavUkony => 'Úkony';

  @override
  String get mainNavZakaznici => 'Zákazníci';

  @override
  String get mainNavTym => 'Tým';

  @override
  String get mainNavStatistiky => 'Statistiky';

  @override
  String get mainNavNastaveni => 'Nastavení';

  @override
  String get mainNavPrijmy => 'Příjmy';

  @override
  String get mainNavVin => 'VIN';

  @override
  String get mainModVozidlaSubtitle => 'Evidence vozů v servisu';

  @override
  String get mainModZakazniciSubtitle => 'Kontakty a vozový park';

  @override
  String get mainModHistorieLabel => 'Historie záznamů';

  @override
  String get mainModHistorieSubtitle => 'Archiv zakázek';

  @override
  String get mainModUkonySubtitle => 'Ceník prací a služeb';

  @override
  String get mainModVinLabel => 'VIN dekodér';

  @override
  String get mainModVinSubtitle => 'Údaje o vozidle z VIN';

  @override
  String get mainModTymSubtitle => 'Technici a oprávnění';

  @override
  String get mainModStatistikySubtitle => 'Přehledy a tržby';

  @override
  String get mainModNastaveniSubtitle => 'Servis, faktury, integrace';

  @override
  String get mainModPredplatneLabel => 'Předplatné';

  @override
  String get mainModPredplatneSubtitle => 'Plán a platby';

  @override
  String get mainModWebLabel => 'Web';

  @override
  String get mainModWebSubtitle => 'Veřejná stránka';

  @override
  String get mainModulyNadpis => 'Moduly';

  @override
  String get mainPrihlasenv => 'Přihlášen v servisu';

  @override
  String get mainOdhlasitSe => 'Odhlásit se';

  @override
  String get mainOdhlaseniTitle => 'Odhlášení';

  @override
  String get mainOdhlaseniContent => 'Opravdu se chcete odhlásit?';

  @override
  String get mainZrusit => 'Zrušit';

  @override
  String get mainOdhlasit => 'Odhlásit';

  @override
  String get mainSvetlyRezim => 'Světlý režim';

  @override
  String get mainTmavyRezim => 'Tmavý režim';

  @override
  String get histZpracovava => 'Zpracovává se...';

  @override
  String get histNadpis => 'Historie záznamů';

  @override
  String get histPodnadpis =>
      'Přehled všech přijatých vozidel a jejich protokolů.';

  @override
  String get histHledat => 'Hledat SPZ, zákazníka nebo vozidlo...';

  @override
  String histChyba(String chyba) {
    return 'Chyba: $chyba';
  }

  @override
  String get histPrazdne => 'Zatím žádné záznamy o příjmu.';

  @override
  String get histNespecifikovano => 'Nespecifikováno';

  @override
  String get histPrijal => 'Přijal';

  @override
  String histFoto(int pocet) {
    return '$pocet foto';
  }

  @override
  String get histPodepsano => 'Podepsáno';

  @override
  String get histDetailNadpis => 'Detail příjmu';

  @override
  String histChybaTisku(String chyba) {
    return 'Chyba při tisku: $chyba';
  }

  @override
  String histChybaZobrazeni(String chyba) {
    return 'Chyba při zobrazení: $chyba';
  }

  @override
  String histProtokol(String cislo) {
    return 'Protokol $cislo';
  }

  @override
  String get histZobrazitProtokol => 'Zobrazit protokol';

  @override
  String get histTisknoutProtokol => 'Tisknout protokol';

  @override
  String get histTisknoutBtn => 'Tisk';

  @override
  String get histSekceVozidlo => 'Vozidlo';

  @override
  String get histPoleSPZ => 'SPZ';

  @override
  String get histPoleZnackaModel => 'Značka & Model';

  @override
  String get histPoleVin => 'VIN';

  @override
  String get histPoleRokVyroby => 'Rok výroby';

  @override
  String get histPolePalivo => 'Palivo';

  @override
  String get histPolePrevodovka => 'Převodovka';

  @override
  String get histPoleMotorizace => 'Motorizace';

  @override
  String get histSekceZakaznik => 'Zákazník';

  @override
  String get histPoleJmeno => 'Jméno';

  @override
  String get histPoleTelefon => 'Telefon';

  @override
  String get histPoleEmail => 'E-mail';

  @override
  String get histPoleAdresa => 'Adresa';

  @override
  String get histPoleIco => 'IČO';

  @override
  String get histPoleDic => 'DIČ';

  @override
  String get histSekceStav => 'Stav při příjmu';

  @override
  String get histPoleTachometr => 'Tachometr';

  @override
  String get histPoleNadrz => 'Stav nádrže';

  @override
  String get histPoleStk => 'STK';

  @override
  String get histPolePoskozeni => 'Poškození';

  @override
  String get histPolePneuLP => 'Pneumatiky LP / PP';

  @override
  String get histPolePneuLZ => 'Pneumatiky LZ / PZ';

  @override
  String get histSekcePozadavky => 'Požadavky zákazníka';

  @override
  String get histSekcePoznamky => 'Poznámky';

  @override
  String get histSekceFoto => 'Fotodokumentace';

  @override
  String get histZadneFoto => 'Nebyly pořízeny žádné fotografie.';

  @override
  String get histSekcePodpis => 'Podpis zákazníka';

  @override
  String get histPodpisNedostupny => 'Podpis není k dispozici';

  @override
  String get nastUlozit => 'ULOŽIT';

  @override
  String get nastUlozeno => 'Nastavení uloženo.';

  @override
  String nastChyba(String chyba) {
    return 'Chyba: $chyba';
  }

  @override
  String get nastZrusit => 'Zrušit';

  @override
  String get nastExportTitle => 'Export dat';

  @override
  String get nastExportPopis =>
      'Stáhněte záznamy ve formátu CSV (Excel) nebo JSON.';

  @override
  String get nastExportZakaznici => 'Zákazníci';

  @override
  String get nastExportVozidla => 'Vozidla';

  @override
  String get nastExportZakazky => 'Příjmy / Zakázky';

  @override
  String get nastExportFormatTitle => 'Formát exportu';

  @override
  String get nastExportFormatPopis => 'Vyberte formát souboru:';

  @override
  String get nastExportCsv => 'CSV (Excel)';

  @override
  String get fotoTitle => 'Fotodokumentace';

  @override
  String get fotoPodtitul =>
      'Vyfoťte sérii fotek, nebo vyberte hromadně z galerie.';

  @override
  String get fotoPridatGalerie => 'Přidat z galerie';

  @override
  String get fotoSeriove => 'Sériové focení';

  @override
  String get fotoKatZvenku => 'Pohled zvenku (kolem vozu)';

  @override
  String get fotoKatPoskozeni => 'Zjištěná poškození';

  @override
  String get fotoKatDisky => 'Disky a kola';

  @override
  String get fotoKatStk => 'Nálepka STK';

  @override
  String get fotoKatInterier => 'Interiér vozu';

  @override
  String get fotoKatTachometr => 'Tachometr a palubní deska';

  @override
  String get fotoKatVin => 'VIN kód';

  @override
  String get fotoKatOstatni => 'Ostatní dokumentace';

  @override
  String get anotTitle => 'Označení poškození';

  @override
  String get anotZavritBezUlozeni => 'Zavřít bez uložení';

  @override
  String get anotZrusitPosledni => 'Zrušit poslední';

  @override
  String get anotSmazatVse => 'Smazat vše';

  @override
  String get anotUlozit => 'Uložit';

  @override
  String get anotChybaNacteni => 'Nepodařilo se načíst fotografii.';

  @override
  String get anotVolnaKresba => 'Volná kresba';

  @override
  String get anotElipsa => 'Elipsa';

  @override
  String get anotObdelnik => 'Obdélník';

  @override
  String get anotSipka => 'Šipka';

  @override
  String get anotPopisTitle => 'Popis poškození';

  @override
  String get anotVzory => 'Vzory:';

  @override
  String get anotVlastniPopis => 'Nebo napište vlastní popis…';

  @override
  String get anotZrusit => 'Zrušit';

  @override
  String get anotZahodi => 'Zahodit';

  @override
  String get anotNeulozenePomoc =>
      'Máte neuložené označení poškození. Uložit je?';

  @override
  String get nastUlozitBtn => 'Uložit';

  @override
  String get nastZavrit => 'ZAVŘÍT';

  @override
  String get nastHotovo => 'HOTOVO';

  @override
  String get nastChecklistTitul => 'Checklist příjmu';

  @override
  String get nastChecklistPovolen => 'Aktivovat checklist při příjmu';

  @override
  String get nastChecklistPovolenSub =>
      'Panel s checklistem se zobrazí při příjmu na tabletu';

  @override
  String get nastChecklistPrazdny => 'Zatím žádné položky';

  @override
  String get nastPridatChecklistPolozku => 'Přidat položku';

  @override
  String get nastNovaChecklistPolozka => 'Nová položka';

  @override
  String get nastUpravitChecklistPolozku => 'Upravit položku';

  @override
  String get nastChecklistPolozkaHint => 'Název položky checklistu';

  @override
  String get checklistPanelTitul => 'Checklist';

  @override
  String get nastTitulAdmin => 'Firemní nastavení';

  @override
  String get nastTitulUzivatel => 'Můj profil';

  @override
  String get nastPodtitulAdmin => 'Správa údajů servisu a ceníku.';

  @override
  String get nastPodtitulUzivatel => 'Základní nastavení vašeho účtu.';

  @override
  String get nastFiremniUdaje => 'Firemní údaje';

  @override
  String get nastObchodniJmeno => 'Obchodní jméno / Název servisu';

  @override
  String get nastIco => 'IČO';

  @override
  String get nastDic => 'DIČ';

  @override
  String get nastRejstrik => 'Zápis v rejstříku (spisová značka)';

  @override
  String get nastSidloKontakt => 'Sídlo a kontakt';

  @override
  String get nastUlice => 'Ulice a č.p.';

  @override
  String get nastMesto => 'Město';

  @override
  String get nastPsc => 'PSČ';

  @override
  String get nastTelefon => 'Telefon servisu';

  @override
  String get nastEmail => 'E-mail pro komunikaci';

  @override
  String get nastCislovani => 'Číslování a automatizace';

  @override
  String get nastFormatZakazek => 'Formát čísla zakázek';

  @override
  String get nastAutoEmail => 'Automaticky zasílat e-maily';

  @override
  String get nastAutoEmailSub => 'Přednastaví odesílání PDF nabídek a faktur.';

  @override
  String get nastAutoCislo => 'Automaticky generovat číslo zakázky';

  @override
  String get nastAutoCisloSub =>
      'Při příjmu vozidla se číslo zakázky předvyplní automaticky. Vypnutím umožníte ruční zadání.';

  @override
  String get nastPodpisPovolen => 'Vyžadovat podpis zákazníka';

  @override
  String get nastPodpisPovolenSub =>
      'Při vypnutí se krok s podpisem v příjmu zobrazí bez podpisového plátna.';

  @override
  String get nastSpzPovinne => 'Povinná SPZ vozidla';

  @override
  String get nastSpzPovinneSub =>
      'Při vypnutí lze příjem odeslat i bez vyplněné SPZ (např. vozidla bez registrace).';

  @override
  String get nastSablony => 'Šablony zpráv';

  @override
  String get nastSablonyPopis =>
      'Přednastavené texty zobrazené jako chipy při psaní zprávy zákazníkovi.';

  @override
  String get nastSablonyPrazdne => 'Zatím žádné šablony. Přidejte první.';

  @override
  String get nastPridatSablonu => 'Přidat šablonu';

  @override
  String get nastUpravitSablonu => 'Upravit šablonu';

  @override
  String get nastNovaSablona => 'Nová šablona';

  @override
  String get nastSablonaHint => 'Text zprávy...';

  @override
  String get nastTypyZaznamu => 'Typy záznamu';

  @override
  String get nastTypyZaznamuPopis =>
      'Typy záznamu slouží k rozlišení příjmu vozidla (např. Servis, Výkup). První přidaný typ je výchozí.';

  @override
  String get nastVychozi => 'výchozí';

  @override
  String get nastPridatTyp => 'Přidat typ';

  @override
  String get nastUpravitTyp => 'Upravit typ';

  @override
  String get nastNovyTyp => 'Nový typ záznamu';

  @override
  String get nastTypHint => 'Název typu (např. Servis, Výkup...)';

  @override
  String get nastLongPress => 'Dlouhý stisk = nastavit jako výchozí.';

  @override
  String get nastOsobni => 'Osobní nastavení';

  @override
  String get nastPrizpusobitListu => 'Přizpůsobit spodní lištu';

  @override
  String get nastPrizpusobitListuSub =>
      'Přidejte si zástupce nebo změňte pořadí.';

  @override
  String get nastListaPopis =>
      'Můžete mít aktivních 2 až 5 záložek. Přetažením změníte pořadí.';

  @override
  String get nastMenuNelzeOdebrat => 'Menu nelze odebrat';

  @override
  String get nastVybrModul => 'Vyberte modul pro lištu';

  @override
  String get nastPridatZalozku => 'Přidat další záložku (max 5)';

  @override
  String get nastTmavyRezim => 'Vynutit tmavý režim';

  @override
  String get nastTmavyRezimSub => 'Aplikace bude tmavá bez ohledu na systém.';

  @override
  String get nastBiometrie => 'Biometrické přihlášení';

  @override
  String get nastBiometrieSub => 'Face ID / otisk prstu při každém spuštění.';

  @override
  String get nastBiometricReason =>
      'Potvrďte svou totožnost pro zapnutí biometrického přihlášení';

  @override
  String get nastLeVaci => 'Režim pro leváky';

  @override
  String get nastLeVaciSub =>
      'Spoušť fotoaparátu vlevo, když je zařízení na šířku.';

  @override
  String get nastUlozitDoZarizeniTitle => 'Ukládat fotky i do zařízení';

  @override
  String get nastUlozitDoZarizeniSub =>
      'Při odeslání se fotky z příjmu uloží také do galerie tohoto zařízení.';

  @override
  String get nastJazyk => 'Jazyk aplikace';

  @override
  String get nastSystJazyk => 'Systémový jazyk';

  @override
  String get nastModPrijem => 'Příjem vozidla';

  @override
  String get nastModHistorie => 'Historie příjmů';

  @override
  String get nastModMenu => 'Menu (Ostatní moduly)';

  @override
  String get nastModVozidla => 'Vozidla';

  @override
  String get nastModUkony => 'Úkony';

  @override
  String get nastModZakaznici => 'Zákazníci';

  @override
  String get nastModTym => 'Tým a práva';

  @override
  String get nastModStatistiky => 'Statistiky';

  @override
  String get nastModNastaveni => 'Nastavení';

  @override
  String get nastModVin => 'VIN dekodér';

  @override
  String nastFormatTitle(String typ) {
    return 'Formát čísla pro: $typ';
  }

  @override
  String get nastNahledLabel => 'Náhled budoucího dokladu:';

  @override
  String nastInternaMaska(String maska) {
    return 'Interní maska: $maska';
  }

  @override
  String get nastPrefix => 'Prefix (Značka)';

  @override
  String get nastOddelovac => 'Oddělovač';

  @override
  String get nastOddelovacPomlcka => 'Pomlčka (-)';

  @override
  String get nastOddelovacLomitko => 'Lomítko (/)';

  @override
  String get nastOddelovacPodtrzitko => 'Podtržítko (_)';

  @override
  String get nastOddelovacBez => 'Bez oddělovače';

  @override
  String get nastRokFormat => 'Formát roku';

  @override
  String get nastRok4 => '4 cifry (2026)';

  @override
  String get nastRok2 => '2 cifry (26)';

  @override
  String get nastBezRoku => 'Bez roku';

  @override
  String get nastMesicFormat => 'Formát měsíce';

  @override
  String get nastMesic2 => '2 cifry (04)';

  @override
  String get nastBezMesice => 'Bez měsíce';

  @override
  String nastDelkaCitadla(int n) {
    return 'Délka pořadového čísla na konci: $n';
  }

  @override
  String get nastInfoZmenaFormatu =>
      'Pokud změníte formát v průběhu roku, stávající doklady zůstanou nedotčeny a nová řada začne navazovat od aktuálního čísla v databázi.';

  @override
  String get nastUlozitFormat => 'ULOŽIT FORMÁT';

  @override
  String get nastFormatUlozen => 'Formát číslování byl úspěšně uložen.';

  @override
  String get nastTrialVyprselo => 'Zkušební doba vypršela';

  @override
  String get nastTrialAktivni => 'Zkušební doba zdarma';

  @override
  String nastPlanNazev(String plan) {
    return 'Plán $plan';
  }

  @override
  String get nastTrialVyberPlan => 'Vyberte plán pro pokračování';

  @override
  String nastTrialZbyva(int n, String slovo) {
    return 'Zbývá $n $slovo · bez závazku';
  }

  @override
  String nastPlatnostDo(String datum) {
    return 'Platnost do $datum';
  }

  @override
  String get nastAktivni => 'Aktivní';

  @override
  String get nastVybratPlan => 'Vybrat plán';

  @override
  String get nastZobrazitPlany => 'Zobrazit plány';

  @override
  String get nastDayJeden => 'den';

  @override
  String get nastDayNeco => 'dny';

  @override
  String get nastDayMnogo => 'dní';

  @override
  String get zamModZamestnanci => 'Zaměstnanci';

  @override
  String get zamModNastaveni => 'Nastavení';

  @override
  String zamChyba(String chyba) {
    return 'Chyba: $chyba';
  }

  @override
  String get zamTitle => 'Tým a oprávnění';

  @override
  String get zamSubtitle =>
      'Spravujte členy svého servisu a jejich přístup do aplikace.';

  @override
  String get zamPrazdny => 'Zatím nemáte žádné členy týmu.';

  @override
  String get zamPridatClena => 'Přidat člena týmu';

  @override
  String get zamLimitTitle => 'Dosažen limit účtů';

  @override
  String zamLimitText(String plan, int limit, int pocet) {
    return 'Plán $plan umožňuje maximálně $limit uživatelských účtů. Aktuálně využíváte $pocet/$limit. Pro přidání dalších členů týmu upgradujte plán.';
  }

  @override
  String get zamZrusit => 'Zrušit';

  @override
  String get zamUpgradovat => 'Upgradovat plán';

  @override
  String get zamNovyClen => 'Nový člen týmu';

  @override
  String get zamJmenoLabel => 'Jméno a příjmení *';

  @override
  String get zamEmailLabel => 'Přihlašovací e-mail *';

  @override
  String get zamHesloLabel => 'Přihlašovací heslo (min. 6 znaků) *';

  @override
  String get zamVychoziPrava => 'Výchozí přístupová práva';

  @override
  String get zamVytvoritUcet => 'Vytvořit účet';

  @override
  String get zamErrVyplnte => 'Vyplňte prosím jméno, e-mail i heslo.';

  @override
  String get zamErrHesloKratke => 'Heslo musí mít alespoň 6 znaků.';

  @override
  String get zamUcetVytvoren => 'Účet vytvořen.';

  @override
  String get zamErrOvereni => 'Chyba ověření.';

  @override
  String get zamErrHesloSlabe => 'Zadané heslo je příliš slabé.';

  @override
  String get zamErrEmailExistuje => 'Účet s tímto e-mailem již existuje.';

  @override
  String get zamErrEmailFormat => 'Neplatný formát e-mailu.';

  @override
  String zamErrNeocekavana(String chyba) {
    return 'Neočekávaná chyba: $chyba';
  }

  @override
  String get zamPristupovaPrava => 'Přístupová práva';

  @override
  String get zamUlozitOpravneni => 'Uložit oprávnění';

  @override
  String get zamUdelitVse => 'Udělit vše';

  @override
  String get zamOdebratVse => 'Odebrat vše';

  @override
  String get zamOdstranit => 'Odstranit';

  @override
  String get zamOdstranitTitle => 'Odstranit člena týmu?';

  @override
  String zamOdstranitText(String jmeno) {
    return 'Opravdu chcete odstranit člena $jmeno? Ztratí přístup do aplikace. Tuto akci nelze vrátit zpět.';
  }

  @override
  String get zamClenOdstranen => 'Člen týmu byl odstraněn.';

  @override
  String zamPocetUzivatelu(int pocet) {
    return '$pocet uživatelů';
  }

  @override
  String zamPocetLimit(int pocet, int limit) {
    return '$pocet / $limit uživatelů';
  }

  @override
  String zamPlanBezLimitu(String plan) {
    return 'Plán $plan · bez limitu';
  }

  @override
  String zamPlanLimitDosazen(String plan) {
    return 'Plán $plan · limit dosažen';
  }

  @override
  String zamPlanZbyva(String plan, int zbyva) {
    return 'Plán $plan · zbývá $zbyva';
  }

  @override
  String get zamBezJmena => 'Bez jména';

  @override
  String get zamBezPrav => 'Bez rozšířených práv';

  @override
  String get zamBadgeAdmin => 'ADMIN';

  @override
  String get zamBadgeClen => 'ČLEN';
}
