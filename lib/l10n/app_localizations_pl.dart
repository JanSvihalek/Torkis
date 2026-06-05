// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'TORKIS';

  @override
  String get btnUlozit => 'Zapisz';

  @override
  String get btnZrusit => 'Anuluj';

  @override
  String get btnPotvrdit => 'Potwierdź';

  @override
  String get btnZavrit => 'Zamknij';

  @override
  String get btnNovySken => 'Nowe skanowanie';

  @override
  String get btnSpustitSken => 'Uruchom skan →';

  @override
  String get btnZacitPouzivat => 'Zacznij używać aplikacji';

  @override
  String get btnPlany => 'Plany';

  @override
  String get nacitani => 'Ładowanie…';

  @override
  String get chybaObecna => 'Wystąpił błąd.';

  @override
  String get zadejteVin => 'Proszę wpisać numer VIN.';

  @override
  String get zadejteVinRucne => 'Wpisz VIN ręcznie (np. TMBJJ7NE5K…)';

  @override
  String get vinDekoderNav => 'VIN';

  @override
  String get vinDekoderTabDekodovani => 'Dekodowanie VIN';

  @override
  String get vinDekoderTabTrzniHodnota => 'Wartość rynkowa';

  @override
  String get vinDekoderTabStk => 'Badanie techniczne';

  @override
  String get vinDekoderTitle => 'Dekoder VIN';

  @override
  String get vinDekoderSubtitle =>
      'Szybkie wyszukiwanie specyfikacji pojazdu na podstawie numeru VIN';

  @override
  String get trzniHodnotaTitle => 'Wartość rynkowa';

  @override
  String get trzniHodnotaSubtitle =>
      'Szacunkowa wartość rynkowa pojazdu na podstawie danych z rynku europejskiego';

  @override
  String get stkTitle => 'Badanie techniczne';

  @override
  String get stkSubtitle =>
      'Historia przeglądów technicznych pojazdu z rejestru';

  @override
  String get skenVinKod => 'Skanuj kod VIN';

  @override
  String get skenVinProTrzni => 'Skanuj VIN dla wartości rynkowej';

  @override
  String get skenVinProStk => 'Skanuj VIN dla badania technicznego';

  @override
  String get skenVinPopis =>
      'Automatycznie ładuje dane pojazdu na podstawie zeskanowanego lub wpisanego numeru VIN';

  @override
  String get skenVinTrzniPopis =>
      'Szacuje wartość rynkową pojazdu na podstawie danych z rynku europejskiego';

  @override
  String get skenVinStkPopis =>
      'Ładuje dane o przeglądach technicznych z rejestru pojazdów';

  @override
  String get dekodovat => 'Dekoduj';

  @override
  String get zjstitHodnotu => 'Sprawdź wartość';

  @override
  String get zjstitStk => 'Sprawdź badanie';

  @override
  String get stkPlatna => 'Badanie ważne';

  @override
  String get stkNeplatna => 'Badanie nieważne';

  @override
  String stkPlatnaJeste(int dni) {
    return 'Badanie ważne jeszcze $dni dni';
  }

  @override
  String stkProsla(int dni) {
    return 'Badanie przeterminowane o $dni dni';
  }

  @override
  String get stkDatumNeznamo => 'Badanie — data nieznana';

  @override
  String get stkPlatnostDo => 'Badanie ważne do';

  @override
  String get stkInfoBanner =>
      'Dane pochodzą z publicznego rejestru pojazdów. Dostępność i aktualność mogą się różnić — dane o przeglądach mogą być niedostępne dla niektórych pojazdów.';

  @override
  String get trzniHodnotaTitle2 => 'WARTOŚĆ RYNKOWA';

  @override
  String get trzniMedian => 'mediana';

  @override
  String get trzniPrumernaCena => 'Średnia cena';

  @override
  String get trzniPrumernyNajezd => 'Średni przebieg';

  @override
  String get trzniPocetVzorku => 'Liczba próbek';

  @override
  String get trzniObdobiDat => 'Okres danych';

  @override
  String get trzniZdroj => 'Rynek europejski · Vincario Market Value';

  @override
  String get trzniNeniData => 'Dane europejskie niedostępne.';

  @override
  String get historieNacitani => 'Ładowanie…';

  @override
  String get historieSken => 'Historia skanów';

  @override
  String get historiePrvniDekodovani => 'Pierwsze dekodowanie';

  @override
  String get historieNeznameVozidlo => 'Nieznany pojazd';

  @override
  String get historieZadneSken => 'Brak skanów.';

  @override
  String get historieVse => 'Wszystkie';

  @override
  String historieDnes(int pocet) {
    return 'Dzisiaj · $pocet zdekodowanych VIN';
  }

  @override
  String get historiePosledniSkeny => 'Ostatnie skany';

  @override
  String get historieNoveVozidlo => 'Nowy pojazd';

  @override
  String historieDekodovanoXKrat(int pocet) {
    return 'Zdekodowano $pocet×';
  }

  @override
  String get limitVyprsel =>
      'Miesięczny limit osiągnięty. Zaktualizuj plan, aby kontynuować.';

  @override
  String get limitDekodovaniTitle => 'Dekodowania VIN w tym miesiącu';

  @override
  String get limitTrzniTitle => 'Zapytania o wartość rynkową w tym miesiącu';

  @override
  String get upsellTrzniTitle => 'Wartość rynkowa dostępna w płatnych planach';

  @override
  String get upsellTrzniText =>
      'Niedostępna w wersji próbnej. Odblokuj już w planie Basic.';

  @override
  String chybaDekodovani(String zprava) {
    return 'Nie udało się zdekodować VIN: $zprava';
  }

  @override
  String get trialWelcomeTitle => 'Witamy w TORKIS';

  @override
  String get trialWelcomeSubtitle =>
      'Uruchomiliśmy Twój 30-dniowy bezpłatny okres próbny — bez karty kredytowej i bez zobowiązań.';

  @override
  String get trialWelcomePill => '30 DNI ZA DARMO';

  @override
  String get trialWelcomeFooter =>
      'Po zakończeniu okresu próbnego wybierz odpowiedni plan.';

  @override
  String get trialBenefitVozidla =>
      'Nieograniczona liczba rekordów pojazdów i klientów';

  @override
  String get trialBenefitVin => '10 zdekodowanych numerów VIN';

  @override
  String get trialBenefitStk =>
      'Nieograniczona liczba sprawdzeń ważności przeglądu technicznego';

  @override
  String get trialBenefitFunkce =>
      'Pełny dostęp do wszystkich funkcji aplikacji.';

  @override
  String get trialBenefitKarta =>
      'Brak danych płatniczych. Brak automatycznych obciążeń.';

  @override
  String get trialBenefitData =>
      'Twoje dane zawsze należą do Ciebie — eksportuj je w dowolnym momencie za darmo.';

  @override
  String get vozidloStatTacho => 'LICZNIK';

  @override
  String get vozidloStatStkDo => 'BADANIE DO';

  @override
  String get vozidloStatPrijmu => 'USŁUGI';

  @override
  String get vozidloStkPlatna => 'Badanie ważne';

  @override
  String get vozidloStkProsla => 'Badanie nieważne';

  @override
  String vozidloStkVyprsiBehemMesicu(String mesic, String rok, int pocet) {
    return 'Wygasa $mesic/$rok · zostało $pocet miesięcy';
  }

  @override
  String vozidloStkVyprsela(String mesic, String rok) {
    return 'Wygasło $mesic/$rok';
  }

  @override
  String get vozidloTechnickeUdaje => 'Dane techniczne';

  @override
  String get vozidloZnackaModel => 'Marka & Model';

  @override
  String get vozidloMotorizace => 'Silnik';

  @override
  String get vozidloVin => 'VIN';

  @override
  String get vozidloRokVyroby => 'Rok produkcji';

  @override
  String get vozidloPalivo => 'Paliwo';

  @override
  String get vozidloPrevodovka => 'Skrzynia biegów';

  @override
  String get vozidloTachometrLabel => 'Licznik';

  @override
  String get vozidloMajitel => 'Właściciel pojazdu';

  @override
  String get vozidloJmeno => 'Imię i nazwisko';

  @override
  String get vozidloTelefon => 'Telefon';

  @override
  String get vozidloEmail => 'E-mail';

  @override
  String get vozidloVolat => 'Zadzwoń';

  @override
  String get vozidlaTitle => 'Baza pojazdów';

  @override
  String get vozidlaSubtitle => 'Przegląd wszystkich serwisowanych pojazdów.';

  @override
  String get vozidlaHledatHint => 'Szukaj tablicy, marki lub VIN...';

  @override
  String get vozidlaSkenSpzTooltip => 'Skanuj tablicę aparatem';

  @override
  String get vozidlaZadnaVozidla => 'Brak pojazdów w bazie danych.';

  @override
  String get vozidlaNejstePrihlaseni => 'Nie jesteś zalogowany.';

  @override
  String get vozidlaSkenJenApp =>
      'Skanowanie jest dostępne tylko w zainstalowanej aplikacji (APK/iOS).';

  @override
  String get vozidloDetailUprava => 'Edytuj pojazd';

  @override
  String get vozidloDetailSpz => 'Tablica';

  @override
  String get vozidloDetailZnacka => 'Marka';

  @override
  String get vozidloDetailModel => 'Model';

  @override
  String get vozidloDetailTachoKm => 'Licznik (km)';

  @override
  String get vozidloDetailPlatnostStk => 'Ważność badania';

  @override
  String get vozidloDetailStkMesic => 'Miesiąc (MM)';

  @override
  String get vozidloDetailStkRok => 'Rok (YYYY)';

  @override
  String get vozidloDetailUlozitZmeny => 'ZAPISZ ZMIANY';

  @override
  String get vozidloDetailSpzExistuje => 'Pojazd z taką tablicą już istnieje!';

  @override
  String vozidloDetailPrejmenovano(String spz) {
    return 'Pojazd zmieniony na $spz. Historia została zachowana.';
  }

  @override
  String get vozidloDetailNenalezeno => 'Pojazd nie znaleziony.';

  @override
  String get vozidloDetailBezSpz => 'Pojazd bez tablicy';

  @override
  String get vozidloDetailLabel => 'POJAZD';

  @override
  String get vozidloTabInfo => 'Info';

  @override
  String get vozidloTabZaznamy => 'Zapisy';

  @override
  String get vozidloSmazatAkce => 'Usuń pojazd';

  @override
  String get vozidloSmazatDialogTitle => 'Usunąć pojazd?';

  @override
  String get vozidloSmazatDialogText =>
      'Pojazd zostanie usunięty z katalogu. Historia serwisowa zostanie zachowana.';

  @override
  String get vozidloSmazano => 'Pojazd usunięty.';

  @override
  String get vozidloSmazatBtn => 'Usuń';

  @override
  String get prijemHelperTelefon => 'Numer telefonu';

  @override
  String get prijemHelperPredvolba => 'Wybierz kod kraju';

  @override
  String get prijemStavTitle => 'Stan pojazdu';

  @override
  String get prijemStavTacho => 'Stan licznika (km)';

  @override
  String prijemStavNadrz(int value) {
    return 'Poziom paliwa ($value %)';
  }

  @override
  String get prijemStavPoskozeni =>
      'Stwierdzone uszkodzenia (można wybrać kilka)';

  @override
  String get prijemStavVlastniPopis => 'Własny opis uszkodzenia...';

  @override
  String get prijemStavPridat => 'Dodaj własne uszkodzenie';

  @override
  String get prijemStavPlatnostStk => 'Ważność badania';

  @override
  String get prijemStavMesic => 'Miesiąc';

  @override
  String get prijemStavRok => 'Rok';

  @override
  String get prijemStavPneu => 'Głębokość bieżnika (mm)';

  @override
  String get prijemStavLevaPreh => 'Przód L.';

  @override
  String get prijemStavPravaPreh => 'Przód P.';

  @override
  String get prijemStavLevaZad => 'Tył L.';

  @override
  String get prijemStavPravaZad => 'Tył P.';

  @override
  String get prijemStavPoznamky => 'Dodatkowe uwagi';

  @override
  String get prijemStavPoznamkyHint =>
      'Wszelkie dodatkowe szczegóły dotyczące przyjęcia...';

  @override
  String get prijemZakaznikTitle => 'Dane klienta';

  @override
  String get prijemZakaznikJmeno => 'Imię i nazwisko / Nazwa firmy';

  @override
  String get prijemZakaznikHledat => 'Szukaj zapisanego klienta';

  @override
  String get prijemZakaznikIco => 'NIP (wyszukiwanie w rejestrze)';

  @override
  String get prijemZakaznikHledatAres => 'Szukaj w rejestrze';

  @override
  String get prijemZakaznikPravniForma => 'Forma prawna';

  @override
  String get prijemZakaznikUlice => 'Ulica i numer';

  @override
  String get prijemZakaznikMesto => 'Miasto';

  @override
  String get prijemZakaznikPsc => 'Kod pocztowy';

  @override
  String get prijemZakaznikEmail => 'E-mail';

  @override
  String get prijemZakaznikFyzicka => 'Osoba fizyczna';

  @override
  String get prijemZakaznikOsvc => 'Samozatrudniony';

  @override
  String get prijemVozidloTitle => 'Zapis pojazdu';

  @override
  String get prijemVozidloNapoveda =>
      'Zeskanuj VIN lub tablicę albo wypełnij ręcznie.';

  @override
  String get prijemVozidloZeme => 'Kraj';

  @override
  String get prijemVozidloSpz => 'Tablica rejestracyjna';

  @override
  String get prijemVozidloHledatSpz => 'Szukaj tablicy w bazie danych';

  @override
  String get prijemVozidloHledatSpzSub => 'Znajdź zapisany pojazd po tablicy';

  @override
  String get prijemVozidloVin => 'Numer VIN';

  @override
  String get prijemVozidloHledatVin => 'Szukaj VIN w bazie danych';

  @override
  String get prijemVozidloHledatVinSub => 'Znajdź zapisany pojazd po VIN';

  @override
  String get prijemVozidloDekodovat => 'Dekoduj VIN online';

  @override
  String get prijemVozidloDekodovatSub =>
      'Uzupełnij markę, model, silnik i badanie';

  @override
  String get prijemVozidloZnackaHint => 'Marka (np. Škoda)';

  @override
  String get prijemVozidloModelHint => 'Model (np. Octavia)';

  @override
  String get prijemVozidloSkenovat => 'Skanuj VIN/tablicę';

  @override
  String get prijemVozidloSkenSub => 'Automatycznie rozpoznaje typ kodu';

  @override
  String get prijemVozidloRozlozeniPodSebou => 'Jeden pod drugim';

  @override
  String get prijemVozidloRozlozeniVMrizce => 'Siatka';

  @override
  String get prijemVozidloTypZaznamu => 'Typ zapisu';

  @override
  String get prijemVozidloCisloZaznamu => 'Numer zlecenia';

  @override
  String get prijemVozidloGenerovat => 'Generuj nowy numer';

  @override
  String get prijemVozidloUlozenaVozidla => 'Zapisane pojazdy klienta';

  @override
  String get prijemVozidloRokVyroby => 'Rok produkcji';

  @override
  String get prijemVozidloMotorizaceHint => 'Silnik (np. 2.0 TDI)';

  @override
  String get prijemVozidloTypPaliva => 'Rodzaj paliwa';

  @override
  String get prijemVozidloPrevodovka => 'Skrzynia biegów';

  @override
  String get prijemVozidloTypKaroserie => 'Typ nadwozia';

  @override
  String get prijemVozidloBenzin => 'Benzyna';

  @override
  String get prijemVozidloNafta => 'Diesel';

  @override
  String get prijemVozidloElektro => 'Elektryczny';

  @override
  String get prijemVozidloHybrid => 'Hybryda';

  @override
  String get prijemVozidloLpgCng => 'LPG/CNG';

  @override
  String get prijemVozidloJine => 'Inne';

  @override
  String get prijemVozidloManualni => 'Manualna';

  @override
  String get prijemVozidloAutomaticka => 'Automatyczna';

  @override
  String get prijemPraceTitle => 'Wymagane prace';

  @override
  String get prijemPracePozadavkyHint => 'Co ustaliliśmy z klientem?';

  @override
  String get prijemPraceRychlyVyber => 'Szybki wybór najczęstszych prac:';

  @override
  String get prijemPraceSeznam => 'Lista prac do zlecenia:';

  @override
  String get prijemPracePridat => 'Dodaj inną pracę';

  @override
  String prijemPraceUkonN(int n) {
    return 'Praca $n';
  }

  @override
  String get prijemPodpisTitle => 'Podsumowanie';

  @override
  String get prijemPodpisNeuvedeno => 'Nie podano';

  @override
  String prijemPodpisZakaznik(String jmeno) {
    return 'Klient: $jmeno';
  }

  @override
  String prijemPodpisAdresa(String adresa) {
    return 'Adres: $adresa';
  }

  @override
  String prijemPodpisVozidlo(String spzZnacka) {
    return 'Pojazd: $spzZnacka';
  }

  @override
  String get prijemPodpisSjednaneUkony => 'Uzgodnione prace:';

  @override
  String get prijemPodpisEmailToggle => 'Wyślij kopię protokołu e-mailem';

  @override
  String get prijemPodpisEmailChybi =>
      'Klient (krok 2) nie ma podanego e-maila.';

  @override
  String prijemPodpisEmailKam(String email) {
    return 'Zostanie wysłany na: $email';
  }

  @override
  String get prijemPodpisSouhlas =>
      'Podpisując, klient potwierdza prawidłowość powyższych danych i akceptuje stan pojazdu przy przyjęciu.';

  @override
  String get prijemPodpisSmazat => 'Wyczyść podpis';

  @override
  String get prijemPodpisVypnut =>
      'Podpis klienta jest wyłączony w ustawieniach serwisu.';

  @override
  String get prijemTabletPostup => 'POSTĘP';

  @override
  String get prijemTabletPosledniNavsteva => 'OSTATNIA WIZYTA';

  @override
  String get prijemTabletVozidlo => 'Pojazd';

  @override
  String get prijemTabletTacho => 'Licznik';

  @override
  String get prijemTabletStk => 'Badanie';

  @override
  String get prijemTabletNaposledy => 'Ostatnio';

  @override
  String get prijemTabletStav => 'Stan';

  @override
  String get prijemTabletStavPriPrijmu => 'Stan przy przyjęciu';

  @override
  String get prijemTabletPoskozeni => 'Uszkodzenia';

  @override
  String get prijemTabletNeuvedeno => 'Nie podano';

  @override
  String get prijemTabletNahled => 'PODGLĄD POJAZDU';

  @override
  String get prijemTabletSpz => 'Tablica';

  @override
  String get prijemTabletVin => 'VIN';

  @override
  String get prijemTabletZakazka => 'Zlecenie';

  @override
  String get prijemTabletUdajePlni =>
      'Dane są uzupełniane podczas wypełniania formularza.';

  @override
  String get prijemErrVinVyhledani => 'Wpisz przynajmniej część numeru VIN.';

  @override
  String get prijemErrServisId => 'Błąd: nie można załadować ID serwisu.';

  @override
  String get prijemErrZadneVozidloVin =>
      'Nie znaleziono pojazdu z tym numerem VIN.';

  @override
  String get prijemErrSpzVyhledani =>
      'Wpisz przynajmniej część tablicy rejestracyjnej.';

  @override
  String get prijemErrZadneVozidloSpz => 'Nie znaleziono pojazdu z tą tablicą.';

  @override
  String get prijemErrZadejteVin => 'Wpisz numer VIN do zdekodowania.';

  @override
  String prijemStkPlatnaSnackbar(String datum) {
    return 'Badanie ważne do $datum';
  }

  @override
  String prijemStkProslaSnackbar(String datum) {
    return 'Badanie przeterminowane! Było ważne do $datum';
  }

  @override
  String get prijemVincarioDoplneno => 'Dane pojazdu uzupełnione z Vincario.';

  @override
  String get prijemVozidloNacteno => 'Dane pojazdu i klienta załadowane.';

  @override
  String get prijemNalezenoVice => 'Znaleziono kilka pojazdów';

  @override
  String get prijemVyberVozidlo => 'Wybierz konkretny pojazd z listy:';

  @override
  String get prijemNeznanaSpz => 'Nieznana tablica';

  @override
  String get prijemErrCisloASpz => 'Numer zlecenia i tablica są wymagane!';

  @override
  String get prijemErrCislo => 'Numer zlecenia jest wymagany!';

  @override
  String get prijemErrSpz => 'Tablica rejestracyjna jest wymagana!';

  @override
  String get prijemErrCisloDuplicitni =>
      'Ten numer zlecenia już istnieje w bazie! Podaj inny.';

  @override
  String get prijemErrPodpis => 'Klient musi podpisać przed wysłaniem.';

  @override
  String get prijemLimitTitle => 'Osiągnięto limit przyjęć';

  @override
  String prijemLimitText(String plan, int limit) {
    return 'Twój plan $plan pozwala na maksymalnie $limit przyjęć miesięcznie. Ulepsz plan, aby uzyskać więcej.';
  }

  @override
  String get prijemZavrit => 'Zamknij';

  @override
  String get prijemUspesne => 'Zlecenie wysłane pomyślnie';

  @override
  String get prijemErrNejstePrirazeni =>
      'Nie jesteś przypisany do żadnego serwisu!';

  @override
  String get prijemSkenJenApp =>
      'Skanowanie AI jest dostępne tylko w zainstalowanej aplikacji (APK/iOS).';

  @override
  String get prijemNavigaceLabel => 'ZAPIS POJAZDU';

  @override
  String get prijemNovyZaznam => 'Nowy zapis';

  @override
  String get prijemDokoncit => 'Zakończ i wyślij';

  @override
  String get prijemPokracovat => 'Dalej';

  @override
  String get prijemOdesilamMsg => 'Wysyłanie zlecenia i protokołu...';

  @override
  String prijemKrokZ(int krok, int celkem) {
    return 'Krok $krok z $celkem';
  }

  @override
  String get prijemStepIdentifikace => 'Identyfikacja pojazdu';

  @override
  String get prijemStepZakaznik => 'Klient';

  @override
  String get prijemStepFoto => 'Zdjęcia';

  @override
  String get prijemStepStav => 'Stan';

  @override
  String get prijemStepPrace => 'Prace';

  @override
  String get prijemStepSouhrn => 'Podsumowanie';

  @override
  String prijemSkenNenalezeno(String co) {
    return 'Zeskanowano \'$co\'. Nie znaleziono w bazie — wypełnij ręcznie.';
  }

  @override
  String get vinSekceIdentifikace => 'IDENTYFIKACJA';

  @override
  String get vinSekceMotor => 'SILNIK I NAPĘD';

  @override
  String get vinSekceKaroserie => 'NADWOZIE I WYMIARY';

  @override
  String get vinSekcePalivo => 'PALIWO I EMISJE';

  @override
  String get vinSekceOstatni => 'POZOSTAŁE INFO';

  @override
  String get vinFieldZnacka => 'Marka';

  @override
  String get vinFieldModel => 'Model';

  @override
  String get vinFieldObchodniOznaceni => 'Nazwa handlowa';

  @override
  String get vinFieldRokVyroby => 'Rok produkcji';

  @override
  String get vinFieldKaroserie => 'Nadwozie';

  @override
  String get vinFieldTypVarianta => 'Wersja / wariant';

  @override
  String get vinFieldMistoVyroby => 'Miejsce produkcji';

  @override
  String get vinFieldMotorizace => 'Silnik';

  @override
  String get vinFieldTypMotoru => 'Typ silnika';

  @override
  String get vinFieldZdvihObjem => 'Pojemność';

  @override
  String get vinFieldPocetValcu => 'Cylindry';

  @override
  String get vinFieldVykon => 'Moc';

  @override
  String get vinFieldTocivyMoment => 'Maks. moment obrotowy';

  @override
  String get vinFieldPalivo => 'Paliwo';

  @override
  String get vinFieldPrevodovka => 'Skrzynia biegów';

  @override
  String get vinFieldPocetPrevodu => 'Biegi';

  @override
  String get vinFieldPohon => 'Napęd';

  @override
  String get vinFieldMaxRychlost => 'Prędkość maks.';

  @override
  String get vinFieldTypKaroserie => 'Typ nadwozia';

  @override
  String get vinFieldPocetDveri => 'Drzwi';

  @override
  String get vinFieldPocetMist => 'Miejsca';

  @override
  String get vinFieldProvozniHmotnost => 'Masa własna';

  @override
  String get vinFieldMaxHmotnost => 'Masa całkowita';

  @override
  String get vinFieldTaznaHmotnost => 'Dopuszczalna masa przyczepy';

  @override
  String get vinFieldRozvorNaprav => 'Rozstaw osi';

  @override
  String get vinFieldDelka => 'Długość';

  @override
  String get vinFieldSirka => 'Szerokość';

  @override
  String get vinFieldVyska => 'Wysokość';

  @override
  String get vinFieldObjemNadrze => 'Pojemność baku';

  @override
  String get vinField1Registrace => '1. rejestracja';

  @override
  String get vinFieldEmisniNorma => 'Norma emisji';

  @override
  String get vinFieldEmiseCo2 => 'Emisje CO₂';

  @override
  String get vinFieldSpotrebaKomb => 'Zużycie (komb.)';

  @override
  String get vinFieldSpotrebaMesto => 'Zużycie w mieście';

  @override
  String get vinFieldSpotrebaDalnice => 'Zużycie poza miastem';

  @override
  String get vinFieldElektDojezd => 'Zasięg elektryczny';

  @override
  String vinLimitDekodovani(int pocet, int limit) {
    return 'Osiągnięto miesięczny limit $pocet / $limit dekodowań. Ulepsz plan, aby kontynuować.';
  }

  @override
  String vinLimitValue(int pocet, int limit) {
    return 'Osiągnięto miesięczny limit $pocet / $limit zapytań.';
  }

  @override
  String get vinTrzniChybaVerze =>
      'Zapytanie o wartość rynkową nie jest dostępne w wersji próbnej — odblokuj w płatnym planie.';

  @override
  String get vinChybaHistorie => 'Nie udało się załadować historii.';

  @override
  String get vinTotoVozidloNebyloDekodovano =>
      'Ten pojazd nie był wcześniej dekodowany.';

  @override
  String get vinPraveTed => 'Przed chwilą';

  @override
  String vinPredMinutami(int pocet) {
    return '$pocet min temu';
  }

  @override
  String get vinVincarioKlice =>
      'Klucze API Vincario nie są ustawione. Dodaj je w Ustawieniach serwisu.';

  @override
  String vinTrzniOd(String value, String mena) {
    return 'od $value $mena';
  }

  @override
  String vinTrzniDo(String value, String mena) {
    return 'do $value $mena';
  }

  @override
  String get vinTrzniHodnotaTitle => 'Wartość rynkowa';

  @override
  String get vinStkTitle => 'Przegląd techniczny';

  @override
  String get vinTrzniSubtitle =>
      'Szacunkowa wartość rynkowa pojazdu na podstawie danych z rynku europejskiego';

  @override
  String get vinStkSubtitle =>
      'Przegląd przeglądów technicznych pojazdu z rejestru';

  @override
  String get vinSkenTitleVin => 'Skanuj kod VIN';

  @override
  String get vinSkenTitleTrzni => 'Skanuj VIN dla wartości rynkowej';

  @override
  String get vinSkenTitleStk => 'Skanuj VIN dla przeglądu technicznego';

  @override
  String get vinSkenPopisVin =>
      'Automatycznie wczytuje specyfikacje pojazdu na podstawie zeskanowanego lub wprowadzonego VIN';

  @override
  String get vinSkenPopisTrzni =>
      'Szacuje wartość rynkową pojazdu na podstawie zeskanowanego lub wprowadzonego VIN z danych rynku europejskiego';

  @override
  String get vinSkenPopisStk =>
      'Wczytuje dane o przeglądach technicznych pojazdu z rejestru';

  @override
  String get vinSkenTlacitko => 'Uruchom skan';

  @override
  String get vinInputHint => 'Wprowadź VIN ręcznie (np. TMBJJ7NE5K…)';

  @override
  String get vinTooltipHodnota => 'Sprawdź wartość';

  @override
  String get vinTooltipStk => 'Sprawdź przegląd';

  @override
  String get vinTooltipDekodovat => 'Dekoduj';

  @override
  String get vinUpsellTitle => 'Wartość rynkowa jest funkcją płatną';

  @override
  String get vinUpsellSubtitle =>
      'Niedostępna w wersji próbnej. Odblokuj już w planie Basic.';

  @override
  String get vinUpsellPlany => 'Plany';

  @override
  String get vinLimitTrzniMesic => 'Wartość rynkowa w tym miesiącu';

  @override
  String get vinLimitDekodovaniMesic => 'Dekodowania VIN w tym miesiącu';

  @override
  String get vinLimitVycerpan =>
      'Miesięczny limit wyczerpany. Uaktualnij plan, aby kontynuować.';

  @override
  String get vinStkInfoBanner =>
      'Dane pochodzą z publicznego rejestru pojazdów. Dostępność i aktualność mogą się różnić — dla niektórych pojazdów przegląd może nie być zarejestrowany.';

  @override
  String vinChybaDekodovani(String chyba) {
    return 'Nie udało się zdekodować VIN: $chyba';
  }

  @override
  String get vinNovySken => 'Nowy skan';

  @override
  String get vinTrzniHodnotaHeader => 'WARTOŚĆ RYNKOWA';

  @override
  String get vinStkPlatnostNeznama => 'Przegląd — data nieznana';

  @override
  String vinStkPlatnaJesteXDni(int dnu) {
    return 'Przegląd ważny jeszcze $dnu dni';
  }

  @override
  String vinStkNeplatna(int dnu) {
    return 'Przegląd nieważny (minęło $dnu dni)';
  }

  @override
  String get vinStkPlatnostDo => 'Przegląd ważny do';

  @override
  String get vinTrzniDataNedostupna => 'Dane europejskie niedostępne.';

  @override
  String get vinTrzniMedian => 'mediana';

  @override
  String get vinTrzniPrumernaCena => 'Średnia cena';

  @override
  String get vinTrzniPrumernyNajezd => 'Średni przebieg';

  @override
  String get vinTrzniPocetVzorku => 'Liczba próbek';

  @override
  String get vinTrzniObdobiDat => 'Okres danych';

  @override
  String get vinTrzniZdroj => 'Rynek europejski · Vincario Market Value';

  @override
  String get vinHistorieNadpis => 'Historia skanów';

  @override
  String vinHistorieDnes(int pocet) {
    return 'Dziś · $pocet zdekodowanych VIN';
  }

  @override
  String get vinHistoriePosledni => 'Ostatnie skany';

  @override
  String get vinHistorieVse => 'Wszystkie';

  @override
  String get vinHistorieNacitani => 'Ładowanie…';

  @override
  String get vinHistorieZadneSkeny => 'Brak skanów.';

  @override
  String get vinHistorieNoveVozidlo => 'Nowy pojazd';

  @override
  String get vinHistoriePoprve => 'Po raz pierwszy zdekodowano';

  @override
  String vinHistorieDekodovanoX(int pocet) {
    return 'Zdekodowano $pocet×';
  }

  @override
  String get vinHistorieNezname => 'Nieznany pojazd';

  @override
  String get vinZadejteVin => 'Wprowadź kod VIN.';

  @override
  String get vinSkenJenApk =>
      'Skanowanie działa tylko w zainstalowanej aplikacji (APK/iOS).';

  @override
  String get vinFieldKodMotoru => 'Kod silnika';

  @override
  String get zakZakaznici => 'Klienci';

  @override
  String get zakSubtitle => 'Katalog Twoich klientów i ich pojazdów.';

  @override
  String get zakHledatHint => 'Szukaj po nazwie, telefonie lub NIP...';

  @override
  String zakChybaDb(String chyba) {
    return 'Błąd bazy danych: $chyba';
  }

  @override
  String get zakZadniZakaznici => 'Brak klientów.';

  @override
  String zakIcoZnak(String ico) {
    return '🏢 NIP: $ico';
  }

  @override
  String get zakEditTitle => 'Edytuj klienta';

  @override
  String get zakJmenoLabel => 'Imię i Nazwisko / Nazwa firmy';

  @override
  String get zakTelLabel => 'Telefon';

  @override
  String get zakVybertePredvolbu => 'Wybierz kierunkowy';

  @override
  String get zakCisloLabel => 'Numer';

  @override
  String get zakEmailLabel => 'E-mail';

  @override
  String get zakAdresaLabel => 'Adres';

  @override
  String get zakIcoLabel => 'NIP';

  @override
  String get zakDicLabel => 'REGON';

  @override
  String get zakUlozitZmeny => 'ZAPISZ ZMIANY';

  @override
  String get zakZpracovavam => 'Wczytywanie danych...';

  @override
  String get zakKartaZakaznika => 'Karta klienta';

  @override
  String get zakHeaderLabel => 'KLIENT';

  @override
  String get zakTabInfo => 'Info';

  @override
  String get zakTabZaznamy => 'Zlecenia';

  @override
  String get zakSmazatMenu => 'Usuń klienta';

  @override
  String get zakSmazatTitle => 'Usunąć klienta?';

  @override
  String get zakSmazatContent =>
      'Klient zostanie usunięty z katalogu. Jego pojazdy i historia zleceń zostaną zachowane.';

  @override
  String get zakZrusit => 'Anuluj';

  @override
  String get zakSmazatPotvrdit => 'Usuń';

  @override
  String get zakSmazanUspesne => 'Klient usunięty.';

  @override
  String zakChybaMazani(String chyba) {
    return 'Błąd usuwania: $chyba';
  }

  @override
  String get zakNeznamyZakaznik => 'Nieznany klient';

  @override
  String get zakFirma => 'Firma';

  @override
  String get zakSoukromaOsoba => 'Osoba prywatna';

  @override
  String get zakStatVozidel => 'POJAZDY';

  @override
  String get zakStatPrijmu => 'ZLECENIA';

  @override
  String get zakVolat => 'Zadzwoń';

  @override
  String get zakSms => 'SMS';

  @override
  String get zakKontaktniUdaje => 'Dane kontaktowe';

  @override
  String get zakVozidlaTitle => 'Pojazdy klienta';

  @override
  String get zakPridat => 'Dodaj';

  @override
  String get zakZadnaVozidla => 'Klient nie ma zapisanych pojazdów.';

  @override
  String get zakBezSpz => 'Bez rejestracji';

  @override
  String get zakZadneZaznamy => 'Brak zapisów o przyjęciach.';

  @override
  String zakZakazka(Object cislo) {
    return 'Zlecenie $cislo';
  }

  @override
  String zakPoskozeni(String seznam) {
    return 'Uszkodzenia: $seznam';
  }

  @override
  String get zakPodepsano => 'Podpisano';

  @override
  String zakFotoKs(int pocet) {
    return '$pocet zdjęć';
  }
}
