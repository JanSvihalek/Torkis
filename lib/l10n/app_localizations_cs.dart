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
}
