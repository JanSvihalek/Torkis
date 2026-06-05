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
  String get vinFieldTocivyMoment => 'Max. točivý moment';

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
  String get vinFieldRozvorNaprav => 'Rozvor náprav';

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
}
