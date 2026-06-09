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
  String get vozidloBarva => 'Kolor';

  @override
  String get vozidloVykon => 'Moc';

  @override
  String get vozidloPocetMistDveri => 'Miejsca / drzwi';

  @override
  String get vozidloRozmery => 'Wymiary';

  @override
  String get vozidloUdajeZVin => 'Dane z VIN';

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
  String get prijemVozidloDalsiUdaje => 'Dodatkowe dane pojazdu';

  @override
  String get prijemVozidloDalsiUdajeSub =>
      'Opcjonalne – uzupełniane z dekodera VIN';

  @override
  String get prijemVozidloBarva => 'Kolor';

  @override
  String get prijemVozidloVykon => 'Moc (kW)';

  @override
  String get prijemVozidloPocetMist => 'Liczba miejsc';

  @override
  String get prijemVozidloPocetDveri => 'Liczba drzwi';

  @override
  String get prijemVozidloRozmery => 'Wymiary (Dł × Sz × Wys mm)';

  @override
  String get prijemVozidloDelka => 'Długość';

  @override
  String get prijemVozidloSirka => 'Szerokość';

  @override
  String get prijemVozidloVyska => 'Wysokość';

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
  String get prijemRekapZaznam => 'Zapis';

  @override
  String get prijemKonceptTitle => 'Niewysłane zlecenie';

  @override
  String get prijemKonceptText =>
      'Masz rozpoczęte niewysłane zlecenie. Czy chcesz kontynuować od miejsca, w którym przerwano?';

  @override
  String get prijemKonceptObnovit => 'Przywróć';

  @override
  String get prijemKonceptZahodit => 'Odrzuć';

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
  String get prijemPodpisOtevrit => 'Podpisz';

  @override
  String get prijemPodpisZnovu => 'Podpisz ponownie';

  @override
  String get prijemPodpisHotovo => 'Gotowe';

  @override
  String get prijemPodpisZavrit => 'Zamknij';

  @override
  String get prijemPodpisHint => 'Podpisz palcem lub piórem';

  @override
  String get prijemPodpisNahled => 'Podpis klienta';

  @override
  String get prijemPodpisZahoditTitul => 'Odrzucić podpis?';

  @override
  String get prijemPodpisZahoditPomoc =>
      'Masz niedokończony podpis. Na pewno odrzucić?';

  @override
  String get prijemPodpisZahodit => 'Odrzuć';

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
  String prijemNahravamFotky(int hotovo, int celkem) {
    return 'Przesyłanie zdjęć $hotovo/$celkem';
  }

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
  String get vinTrzniNajezdLabel => 'Przebieg pojazdu (km)';

  @override
  String get vinTrzniOdhad => 'Szacunek wg przebiegu';

  @override
  String get vinTrzniOdhadVysvetleni =>
      'Orientacyjny szacunek wartości rezydualnej obliczony z zakresu cen i przebiegów w próbce.';

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

  @override
  String get authBiometricReason => 'Zaloguj się do Torkis';

  @override
  String get authBiometricChybaStorage =>
      'Najpierw zaloguj się hasłem – Face ID zostanie aktywowane przy następnym uruchomieniu.';

  @override
  String get authBiometricChybaUdaje =>
      'Zapisane dane logowania są nieprawidłowe. Zaloguj się hasłem.';

  @override
  String get authChybaPrazdnaPola => 'Wprowadź adres e-mail i hasło.';

  @override
  String get authChybaHeslaNeshoda => 'Podane hasła nie są zgodne.';

  @override
  String get authChybaOverovani => 'Wystąpił błąd uwierzytelniania.';

  @override
  String get authChybaNeplatneUdaje => 'Nieprawidłowy adres e-mail lub hasło.';

  @override
  String get authChybaEmailExistuje =>
      'Ten adres e-mail jest już zarejestrowany.';

  @override
  String get authChybaSlabeHeslo => 'Hasło jest za słabe (min. 6 znaków).';

  @override
  String get authChybaFormatEmail => 'Nieprawidłowy format adresu e-mail.';

  @override
  String authChybaNeocekvana(String chyba) {
    return 'Nieoczekiwany błąd: $chyba';
  }

  @override
  String get authResetHint =>
      'Wpisz prawidłowy adres e-mail w pole powyżej, aby zresetować hasło.';

  @override
  String get authResetOdeslan => 'E-mail do resetowania hasła został wysłany.';

  @override
  String get authResetChyba =>
      'Błąd przy wysyłaniu e-maila do resetowania hasła.';

  @override
  String get authSubtitleLogin => 'Cyfrowa ewidencja pojazdów';

  @override
  String get authSubtitleRegister => 'Zarejestruj swój serwis';

  @override
  String get authEmailHint => 'E-mail';

  @override
  String get authHesloHint => 'Hasło';

  @override
  String get authPotvrzeniHeslaHint => 'Potwierdź hasło';

  @override
  String get authZapomenuteHeslo => 'Nie pamiętasz hasła?';

  @override
  String get authPrihlasitSe => 'Zaloguj się';

  @override
  String get authVytvoritUcet => 'Utwórz konto';

  @override
  String get authBiometrickePrihlaseni => 'Zaloguj się biometrycznie';

  @override
  String get authNebo => 'lub';

  @override
  String get authGoogleBtn => 'Kontynuuj przez Google';

  @override
  String get authAppleBtn => 'Kontynuuj przez Apple';

  @override
  String get authNematUcet => 'Nie masz konta?';

  @override
  String get authZaregistrujteSe => 'Zarejestruj się';

  @override
  String get authMateUcet => 'Masz już konto?';

  @override
  String get authPrihlasteSe => 'Zaloguj się';

  @override
  String predChybaNakup(String chyba) {
    return 'Zakup nie powiódł się: $chyba';
  }

  @override
  String get predChybaEmailKlient => 'Nie można otworzyć klienta poczty.';

  @override
  String get predTitle => 'Twoja subskrypcja';

  @override
  String get predSubtitle =>
      'Zarządzaj planem swojego serwisu i aktualizuj go wedle potrzeb.';

  @override
  String get predTrialBannerTitle => 'Aktywny okres próbny';

  @override
  String predAktivniPlanTitle(String plan) {
    return 'Aktywny plan: $plan';
  }

  @override
  String get predTrialBannerSubtitle =>
      'Po zakończeniu okresu próbnego wybierz plan odpowiedni dla Ciebie.';

  @override
  String get predAktivniPlanSubtitle => 'Dziękujemy za korzystanie z TORKIS.';

  @override
  String get predMesicne => 'Miesięcznie';

  @override
  String get predRocne => 'Rocznie';

  @override
  String get predFootnote =>
      'Bez zobowiązań · Anuluj w dowolnym momencie · Ceny bez VAT';

  @override
  String get predBasicDesc =>
      'Dla małych serwisów i jednoosobowych działalności.';

  @override
  String get predStandardDesc =>
      'Dla średnich serwisów z do 150 zleceń miesięcznie.';

  @override
  String get predProDesc => 'Dla dużych serwisów i sieci bez limitu wpisów.';

  @override
  String get predCustomDesc =>
      'Indywidualne dostosowanie do specjalnych wymagań i integracji.';

  @override
  String get predFeat50Zaznamu => '50 wpisów/miesiąc';

  @override
  String get predFeat3Uziv => 'Maks. 3 użytkowników';

  @override
  String get predFeat30Vin => '30 dekodowań VIN/miesiąc';

  @override
  String get predFeat1TrzniHodnota => '1 wycena rynkowa/miesiąc';

  @override
  String get predFeatNeomezStk =>
      'Nieograniczone sprawdzenia ważności przeglądu';

  @override
  String get predFeatFotodok => 'Dokumentacja fotograficzna';

  @override
  String get predFeatEvidZak => 'Ewidencja klientów i pojazdów';

  @override
  String get predFeatHistorie => 'Historia wpisów';

  @override
  String get predFeatSpravaTymu => 'Zarządzanie zespołem';

  @override
  String get predFeat150Zaznamu => '150 wpisów/miesiąc';

  @override
  String get predFeat10Uziv => 'Maks. 10 użytkowników';

  @override
  String get predFeat60Vin => '60 dekodowań VIN/miesiąc';

  @override
  String get predFeat120Vin => '120 dekodowań VIN/miesiąc';

  @override
  String get predFeat75Vin => '75 dekodowań VIN/miesiąc';

  @override
  String get predFeat3TrzniHodnota => '3 wyceny rynkowe/miesiąc';

  @override
  String get predFeatVseBasic => 'Wszystko z Basic';

  @override
  String get predFeatReporty => 'Raporty i statystyki';

  @override
  String get predFeatChat => 'Czat z klientem';

  @override
  String get predFeatWebPortal =>
      'Portal internetowy do zarządzania pojazdami i klientami';

  @override
  String get predFeatNeomezZaznamu => 'Nieograniczone wpisy';

  @override
  String get predFeatNeomezUziv => 'Nieograniczona liczba użytkowników';

  @override
  String get predFeatVseStandard => 'Wszystko ze Standard';

  @override
  String get predFeat150Vin => '150 dekodowań VIN/miesiąc';

  @override
  String get predFeat5TrzniHodnota => '5 wycen rynkowych/miesiąc';

  @override
  String get predFeatPrioritniPodpora => 'Wsparcie priorytetowe';

  @override
  String get predFeatPokrocileStatistiky => 'Zaawansowane statystyki';

  @override
  String get predFeatVicenasobinaVzd => 'Wiele lokalizacji';

  @override
  String get predFeatErp => 'Integracja ERP/DMS';

  @override
  String get predFeatNeomezVin => 'Nieograniczone dekodowania VIN/miesiąc';

  @override
  String get predFeatNeomezTrzni => 'Nieograniczone wyceny rynkowe pojazdów';

  @override
  String get predFeatPrioritniSla => 'Wsparcie priorytetowe z SLA';

  @override
  String get paywallTitle => 'Wybierz plan';

  @override
  String get paywallSubtitleTrialEnding =>
      'Twój okres próbny wkrótce się kończy. Wybierz plan, aby kontynuować.';

  @override
  String get paywallSubtitleTrialExpired =>
      'Twój okres próbny dobiegł końca. Wybierz plan odpowiedni dla Twojego serwisu.';

  @override
  String paywallTrialZbyva(int n, String slovo) {
    return 'Pozostało $n $slovo okresu próbnego';
  }

  @override
  String get paywallBezpeci =>
      'Twoje dane są bezpieczne. Przywrócimy wszystko po wyborze planu.';

  @override
  String get paywallZadnePredplatne => 'Nie znaleziono aktywnej subskrypcji.';

  @override
  String paywallChybaObnoveni(String chyba) {
    return 'Błąd przywracania: $chyba';
  }

  @override
  String get paywallObnovitNakupy => 'Przywróć zakupy';

  @override
  String get predPeriodMesic => 'miesięcznie';

  @override
  String get predPeriodRoc => 'rocznie';

  @override
  String get predCenaNaMiru => 'Cena na miarę';

  @override
  String get predDoporucujeme => 'POLECAMY';

  @override
  String get predAktualniPlanPill => 'OBECNY PLAN';

  @override
  String get predAktualneAktivni => 'Obecnie aktywny';

  @override
  String get predMamZajem => 'Jestem zainteresowany';

  @override
  String predVybrat(String name) {
    return 'Wybierz $name';
  }

  @override
  String get paywallTrust1Title => 'Dostępność 99,9%';

  @override
  String get paywallTrust1Sub => 'Gwarantowany SLA dostępności';

  @override
  String get paywallTrust2Title => 'Bezpłatny eksport danych';

  @override
  String get paywallTrust2Sub => 'Twoje dane zawsze należą do Ciebie';

  @override
  String get onbAresChybaIco => 'Wprowadź prawidłowy 8-cyfrowy numer ID firmy.';

  @override
  String get onbAresNacteno => 'Dane firmy zostały załadowane z rejestru.';

  @override
  String get onbAresNenalezeno =>
      'Podany numer nie został znaleziony w rejestrze.';

  @override
  String onbAresChyba(String chyba) {
    return 'Błąd komunikacji z rejestrem: $chyba';
  }

  @override
  String get onbBiometricReason =>
      'Potwierdź swoją tożsamość, aby włączyć logowanie biometryczne';

  @override
  String get onbDialogUpravitTyp => 'Edytuj typ';

  @override
  String get onbDialogNovyTyp => 'Nowy typ zlecenia';

  @override
  String get onbDialogNazevTypuHint => 'Nazwa typu (np. Serwis, Skup...)';

  @override
  String get onbZrusit => 'Anuluj';

  @override
  String get onbUlozit => 'Zapisz';

  @override
  String onbChybaUkladani(String chyba) {
    return 'Błąd podczas zapisywania: $chyba';
  }

  @override
  String get onbChybaNazev => 'Nazwa serwisu jest wymagana do kontynuowania.';

  @override
  String get onbDokoncit => 'ZAKOŃCZ KONFIGURACJĘ';

  @override
  String get onbPokracovat => 'DALEJ';

  @override
  String get onbKrok1Nadpis => 'Witamy w TORKIS!';

  @override
  String get onbKrok1Popis =>
      'Najpierw uzupełnimy podstawowe informacje o Tobie lub Twojej firmie.';

  @override
  String get onbIcoLabel => 'ID firmy (wyszukiwanie w rejestrze)';

  @override
  String get onbIcoHint => 'np. 12345678';

  @override
  String get onbAresLoadTooltip => 'Załaduj z rejestru';

  @override
  String get onbNazevLabel => 'Nazwa serwisu / Imię i nazwisko *';

  @override
  String get onbNazevHint => 'Wpisz nazwę...';

  @override
  String get onbDicLabel => 'NIP VAT (opcjonalne)';

  @override
  String get onbDicHint => 'np. PL12345678';

  @override
  String get onbRegistraceLabel => 'Wpis do rejestru (opcjonalne)';

  @override
  String get onbRegistraceHint => 'np. zarejestrowany w CEIDG...';

  @override
  String get onbSidloNadpis => 'Adres i kontakt';

  @override
  String get onbSidloPopis =>
      'Dane będą używane na ofertach, fakturach i w komunikacji.';

  @override
  String get onbUliceLabel => 'Ulica i numer';

  @override
  String get onbUliceHint => 'np. Główna 123';

  @override
  String get onbMestoLabel => 'Miasto';

  @override
  String get onbMestoHint => 'np. Warszawa';

  @override
  String get onbPscLabel => 'Kod pocztowy';

  @override
  String get onbTelefonLabel => 'Telefon serwisu';

  @override
  String get onbTelefonHint => 'np. +48 777 123 456';

  @override
  String get onbKomunikaceNadpis => 'Komunikacja i wygląd';

  @override
  String get onbEmailLabel =>
      'Adres e-mail (z którego będą wysyłane e-maile do klientów)';

  @override
  String get onbEmailHint => 'np. info@serwis.pl';

  @override
  String get onbEmailySwitchTitle => 'Automatyczne wysyłanie e-maili';

  @override
  String get onbEmailySwitchSubtitle =>
      'Na ofertach i przy zakończeniu będzie wstępnie zaznaczona opcja wysyłania PDF e-mailem.';

  @override
  String get onbAdminNadpis => 'Twoje konto (administrator)';

  @override
  String get onbAdminPopis =>
      'Podaj swoje imię — zostaniesz dodany jako główny zarządca serwisu.';

  @override
  String get onbJmenoLabel => 'Imię i nazwisko *';

  @override
  String get onbJmenoHint => 'np. Jan Kowalski';

  @override
  String get onbTmavyRezimTitle => 'Wymuś tryb ciemny';

  @override
  String get onbTmavyRezimSubtitle =>
      'Aplikacja zostanie natychmiast przełączona na ciemny wygląd.';

  @override
  String get onbKrok2Nadpis => 'Operacje i automatyzacja';

  @override
  String get onbKrok2Popis =>
      'Skonfiguruj zachowanie przy przyjęciu pojazdu. Wszystko można zmienić później w Ustawieniach.';

  @override
  String get onbAutoCisloTitle => 'Automatyczne generowanie numeru zlecenia';

  @override
  String get onbAutoCisloSubtitle =>
      'Numer zlecenia będzie automatycznie wypełniony przy przyjęciu. Wyłącz, aby umożliwić ręczne wprowadzanie.';

  @override
  String get onbPodpisTitle => 'Wymagaj podpisu klienta';

  @override
  String get onbPodpisSubtitle =>
      'Po wyłączeniu krok z podpisem będzie wyświetlany bez płótna podpisu.';

  @override
  String get onbSpzTitle => 'Wymagaj tablicy rejestracyjnej';

  @override
  String get onbSpzSubtitle =>
      'Po wyłączeniu przyjęcie można wysłać bez tablicy rejestracyjnej.';

  @override
  String get onbTypyNadpis => 'Typy zleceń';

  @override
  String get onbTypyPopis =>
      'Służy do klasyfikacji przyjęcia pojazdu (np. Serwis, Skup). Pierwszy typ jest domyślny.';

  @override
  String get onbTypyVychozi => 'domyślny';

  @override
  String get onbPridatTyp => 'Dodaj typ';

  @override
  String get onbTypyHint => 'Długie naciśnięcie = ustaw jako domyślny.';

  @override
  String get onbVzoryNadpis => 'Szablony opisów uszkodzeń';

  @override
  String get onbVzoryPopis =>
      'Predefiniowane opisy, z których technik wybiera podczas oznaczania uszkodzeń w dokumentacji zdjęciowej.';

  @override
  String get onbVzoryPrazdne => 'Brak szablonów. Dodaj pierwszy.';

  @override
  String get onbPridatVzor => 'Dodaj szablon';

  @override
  String get onbDialogNovyVzor => 'Nowy szablon uszkodzenia';

  @override
  String get onbDialogUpravitVzor => 'Edytuj szablon';

  @override
  String get onbVzorHint => 'Np. Zarysowanie, Wgniecenie…';

  @override
  String get onbOsobniNadpis => 'Ustawienia osobiste';

  @override
  String get onbBiometrieTitle => 'Logowanie biometryczne';

  @override
  String get onbBiometrieSubtitle =>
      'Face ID / odcisk palca przy każdym uruchomieniu.';

  @override
  String get onbLevacTitle => 'Tryb leworęczny';

  @override
  String get onbLevacSubtitle =>
      'Spust aparatu po lewej stronie, gdy urządzenie jest w poziomie.';

  @override
  String get onbKrok3Nadpis => 'Najczęstsze usługi';

  @override
  String get onbKrok3Popis =>
      'Przygotowaliśmy listę typowych usług. Możesz je dowolnie edytować, usuwać lub dodawać kolejne.';

  @override
  String get onbUkonNazevLabel => 'Nazwa usługi';

  @override
  String get onbUkonCenaLabel => 'Cena jedn. (CZK)';

  @override
  String get onbUkonCasLabel => 'Czas';

  @override
  String get onbUkonHod => 'godz';

  @override
  String get onbUkonMin => 'min';

  @override
  String get onbUkonCelkovaCenaLabel => 'Cena całkowita (CZK)';

  @override
  String get onbUkonKategorieLabel => 'Kategoria';

  @override
  String get onbPridatUkon => 'Dodaj kolejną usługę';

  @override
  String get trialBadge => '30 DNI BEZPŁATNIE';

  @override
  String get trialNadpis => 'Witamy w TORKIS';

  @override
  String get trialPopis =>
      'Uruchomiliśmy Twój 30-dniowy bezpłatny okres próbny — bez karty kredytowej i bez zobowiązań.';

  @override
  String get trialBenefit1 =>
      'Nieograniczona liczba wpisów pojazdów i klientów';

  @override
  String get trialBenefit2 => '10 zdekodowanych numerów VIN';

  @override
  String get trialBenefit3 => 'Nieograniczone sprawdzenia ważności przeglądu';

  @override
  String get trialBenefit4 => 'Pełny dostęp do wszystkich funkcji aplikacji.';

  @override
  String get trialBenefit5 =>
      'Brak danych płatności. Bez automatycznych obciążeń.';

  @override
  String get trialBenefit6 =>
      'Twoje dane zawsze należą do Ciebie — bezpłatny eksport w dowolnym momencie.';

  @override
  String get trialBtn => 'Zacznij używać aplikacji';

  @override
  String get mainNavNovy => 'Nowy';

  @override
  String get mainNavMenu => 'Menu';

  @override
  String get mainNavVozidla => 'Pojazdy';

  @override
  String get mainNavUkony => 'Usługi';

  @override
  String get mainNavZakaznici => 'Klienci';

  @override
  String get mainNavTym => 'Zespół';

  @override
  String get mainNavStatistiky => 'Statystyki';

  @override
  String get mainNavNastaveni => 'Ustawienia';

  @override
  String get mainNavPrijmy => 'Przyjęcia';

  @override
  String get mainNavVin => 'VIN';

  @override
  String get mainModVozidlaSubtitle => 'Pojazdy w serwisie';

  @override
  String get mainModZakazniciSubtitle => 'Kontakty i flota pojazdów';

  @override
  String get mainModHistorieLabel => 'Historia zleceń';

  @override
  String get mainModHistorieSubtitle => 'Archiwum zleceń';

  @override
  String get mainModUkonySubtitle => 'Cennik usług';

  @override
  String get mainModVinLabel => 'Dekoder VIN';

  @override
  String get mainModVinSubtitle => 'Dane pojazdu z numeru VIN';

  @override
  String get mainModTymSubtitle => 'Technicy i uprawnienia';

  @override
  String get mainModStatistikySubtitle => 'Raporty i przychody';

  @override
  String get mainModNastaveniSubtitle => 'Serwis, faktury, integracje';

  @override
  String get mainModPredplatneLabel => 'Subskrypcja';

  @override
  String get mainModPredplatneSubtitle => 'Plan i płatności';

  @override
  String get mainModWebLabel => 'Web';

  @override
  String get mainModWebSubtitle => 'Strona publiczna';

  @override
  String get mainModulyNadpis => 'Moduły';

  @override
  String get mainPrihlasenv => 'Zalogowany w serwisie';

  @override
  String get mainOdhlasitSe => 'Wyloguj się';

  @override
  String get mainOdhlaseniTitle => 'Wylogowanie';

  @override
  String get mainOdhlaseniContent => 'Czy na pewno chcesz się wylogować?';

  @override
  String get mainZrusit => 'Anuluj';

  @override
  String get mainOdhlasit => 'Wyloguj';

  @override
  String get mainSvetlyRezim => 'Tryb jasny';

  @override
  String get mainTmavyRezim => 'Tryb ciemny';

  @override
  String get histZpracovava => 'Przetwarzanie...';

  @override
  String get histNadpis => 'Historia przyjęć';

  @override
  String get histPodnadpis =>
      'Przegląd wszystkich przyjętych pojazdów i ich protokołów.';

  @override
  String get histHledat => 'Szukaj po tablicy, kliencie lub pojeździe...';

  @override
  String histChyba(String chyba) {
    return 'Błąd: $chyba';
  }

  @override
  String get histPrazdne => 'Brak zapisów.';

  @override
  String get histNespecifikovano => 'Nieokreślono';

  @override
  String get histPrijal => 'Przyjął';

  @override
  String histFoto(int pocet) {
    return '$pocet zdjęcie';
  }

  @override
  String get histPodepsano => 'Podpisano';

  @override
  String get histDetailNadpis => 'Szczegóły przyjęcia';

  @override
  String histChybaTisku(String chyba) {
    return 'Błąd druku: $chyba';
  }

  @override
  String histChybaZobrazeni(String chyba) {
    return 'Błąd wyświetlania: $chyba';
  }

  @override
  String histProtokol(String cislo) {
    return 'Protokół $cislo';
  }

  @override
  String get histZobrazitProtokol => 'Pokaż protokół';

  @override
  String get histTisknoutProtokol => 'Drukuj protokół';

  @override
  String get histTisknoutBtn => 'Drukuj';

  @override
  String get histSekceVozidlo => 'Pojazd';

  @override
  String get histPoleSPZ => 'Nr rejestracyjny';

  @override
  String get histPoleZnackaModel => 'Marka & Model';

  @override
  String get histPoleVin => 'VIN';

  @override
  String get histPoleRokVyroby => 'Rok produkcji';

  @override
  String get histPolePalivo => 'Paliwo';

  @override
  String get histPolePrevodovka => 'Skrzynia biegów';

  @override
  String get histPoleMotorizace => 'Silnik';

  @override
  String get histSekceZakaznik => 'Klient';

  @override
  String get histPoleJmeno => 'Imię i nazwisko';

  @override
  String get histPoleTelefon => 'Telefon';

  @override
  String get histPoleEmail => 'E-mail';

  @override
  String get histPoleAdresa => 'Adres';

  @override
  String get histPoleIco => 'NIP';

  @override
  String get histPoleDic => 'REGON';

  @override
  String get histSekceStav => 'Stan przy przyjęciu';

  @override
  String get histPoleTachometr => 'Przebieg';

  @override
  String get histPoleNadrz => 'Poziom paliwa';

  @override
  String get histPoleStk => 'Przegląd';

  @override
  String get histPolePoskozeni => 'Uszkodzenia';

  @override
  String get histPolePneuLP => 'Opony PL / PP';

  @override
  String get histPolePneuLZ => 'Opony TL / TP';

  @override
  String get histSekcePozadavky => 'Życzenia klienta';

  @override
  String get histSekcePoznamky => 'Uwagi';

  @override
  String get histSekceFoto => 'Dokumentacja fotograficzna';

  @override
  String get histZadneFoto => 'Brak zdjęć.';

  @override
  String get histSekcePodpis => 'Podpis klienta';

  @override
  String get histPodpisNedostupny => 'Podpis niedostępny';

  @override
  String get nastUlozit => 'ZAPISZ';

  @override
  String get nastUlozeno => 'Ustawienia zapisane.';

  @override
  String nastChyba(String chyba) {
    return 'Błąd: $chyba';
  }

  @override
  String get nastZrusit => 'Anuluj';

  @override
  String get nastExportTitle => 'Eksport danych';

  @override
  String get nastExportPopis =>
      'Pobierz rekordy w formacie CSV (Excel) lub JSON.';

  @override
  String get nastExportZakaznici => 'Klienci';

  @override
  String get nastExportVozidla => 'Pojazdy';

  @override
  String get nastExportZakazky => 'Przyjęcia / Zlecenia';

  @override
  String get nastExportFormatTitle => 'Format eksportu';

  @override
  String get nastExportFormatPopis => 'Wybierz format pliku:';

  @override
  String get nastExportCsv => 'CSV (Excel)';

  @override
  String get fotoTitle => 'Dokumentacja zdjęciowa';

  @override
  String get fotoPodtitul => 'Zrób serię zdjęć lub wybierz kilka z galerii.';

  @override
  String get fotoPridatGalerie => 'Dodaj z galerii';

  @override
  String get fotoSeriove => 'Zdjęcia seryjne';

  @override
  String get fotoKatZvenku => 'Widok z zewnątrz (dookoła auta)';

  @override
  String get fotoKatPoskozeni => 'Stwierdzone uszkodzenia';

  @override
  String get fotoKatDisky => 'Felgi i koła';

  @override
  String get fotoKatStk => 'Naklejka przeglądu';

  @override
  String get fotoKatInterier => 'Wnętrze pojazdu';

  @override
  String get fotoKatTachometr => 'Licznik i deska rozdzielcza';

  @override
  String get fotoKatVin => 'Kod VIN';

  @override
  String get fotoKatOstatni => 'Pozostała dokumentacja';

  @override
  String get anotTitle => 'Oznaczenie uszkodzeń';

  @override
  String get anotZavritBezUlozeni => 'Zamknij bez zapisywania';

  @override
  String get anotZrusitPosledni => 'Cofnij ostatnie';

  @override
  String get anotSmazatVse => 'Usuń wszystko';

  @override
  String get anotUlozit => 'Zapisz';

  @override
  String get anotChybaNacteni => 'Nie udało się wczytać zdjęcia.';

  @override
  String get anotVolnaKresba => 'Odręcznie';

  @override
  String get anotElipsa => 'Elipsa';

  @override
  String get anotObdelnik => 'Prostokąt';

  @override
  String get anotSipka => 'Strzałka';

  @override
  String get anotPopisTitle => 'Opis uszkodzenia';

  @override
  String get anotVzory => 'Wzory:';

  @override
  String get anotVlastniPopis => 'Lub wpisz własny opis…';

  @override
  String get anotZrusit => 'Anuluj';

  @override
  String get anotZahodi => 'Odrzuć';

  @override
  String get anotNeulozenePomoc =>
      'Masz niezapisane oznaczenia uszkodzeń. Zapisać je?';

  @override
  String get nastUlozitBtn => 'Zapisz';

  @override
  String get nastZavrit => 'ZAMKNIJ';

  @override
  String get nastHotovo => 'GOTOWE';

  @override
  String get nastChecklistTitul => 'Lista kontrolna przyjęcia';

  @override
  String get nastChecklistPovolen => 'Włącz listę kontrolną przy przyjęciu';

  @override
  String get nastChecklistPovolenSub =>
      'Panel listy kontrolnej zostanie wyświetlony przy przyjęciu na tablecie';

  @override
  String get nastChecklistPrazdny => 'Brak pozycji';

  @override
  String get nastPridatChecklistPolozku => 'Dodaj pozycję';

  @override
  String get nastNovaChecklistPolozka => 'Nowa pozycja';

  @override
  String get nastUpravitChecklistPolozku => 'Edytuj pozycję';

  @override
  String get nastChecklistPolozkaHint => 'Nazwa pozycji listy kontrolnej';

  @override
  String get checklistPanelTitul => 'Lista kontrolna';

  @override
  String get nastTitulAdmin => 'Ustawienia firmowe';

  @override
  String get nastTitulUzivatel => 'Mój profil';

  @override
  String get nastPodtitulAdmin => 'Zarządzaj danymi serwisu i cennikiem.';

  @override
  String get nastPodtitulUzivatel => 'Podstawowe ustawienia konta.';

  @override
  String get nastFiremniUdaje => 'Dane firmowe';

  @override
  String get nastObchodniJmeno => 'Nazwa firmy / Nazwa serwisu';

  @override
  String get nastIco => 'NIP';

  @override
  String get nastDic => 'REGON';

  @override
  String get nastRejstrik => 'Wpis do rejestru';

  @override
  String get nastSidloKontakt => 'Siedziba i kontakt';

  @override
  String get nastUlice => 'Ulica i numer';

  @override
  String get nastMesto => 'Miasto';

  @override
  String get nastPsc => 'Kod pocztowy';

  @override
  String get nastTelefon => 'Telefon serwisu';

  @override
  String get nastEmail => 'E-mail do komunikacji';

  @override
  String get nastCislovani => 'Numeracja i automatyzacja';

  @override
  String get nastFormatZakazek => 'Format numeru zlecenia';

  @override
  String get nastAutoEmail => 'Automatycznie wysyłaj e-maile';

  @override
  String get nastAutoEmailSub =>
      'Wstępnie ustawia wysyłanie ofert PDF i faktur.';

  @override
  String get nastAutoCislo => 'Automatycznie generuj numer zlecenia';

  @override
  String get nastAutoCisloSub =>
      'Podczas przyjęcia pojazdu numer zlecenia jest wypełniany automatycznie. Wyłącz, aby umożliwić ręczne wprowadzanie.';

  @override
  String get nastPodpisPovolen => 'Wymagaj podpisu klienta';

  @override
  String get nastPodpisPovolenSub =>
      'Po wyłączeniu krok z podpisem jest wyświetlany bez płótna podpisu.';

  @override
  String get nastSpzPovinne => 'Wymagany numer rejestracyjny';

  @override
  String get nastSpzPovinneSub =>
      'Po wyłączeniu przyjęcie można przesłać bez numeru rejestracyjnego.';

  @override
  String get nastSablony => 'Szablony wiadomości';

  @override
  String get nastSablonyPopis =>
      'Wstępnie ustawione teksty wyświetlane jako chipy podczas pisania wiadomości do klienta.';

  @override
  String get nastSablonyPrazdne => 'Brak szablonów. Dodaj pierwszy.';

  @override
  String get nastPridatSablonu => 'Dodaj szablon';

  @override
  String get nastUpravitSablonu => 'Edytuj szablon';

  @override
  String get nastNovaSablona => 'Nowy szablon';

  @override
  String get nastSablonaHint => 'Treść wiadomości...';

  @override
  String get nastTypyZaznamu => 'Typy wpisów';

  @override
  String get nastTypyZaznamuPopis =>
      'Typy wpisów rozróżniają typ przyjęcia (np. Serwis, Skup). Pierwszy dodany typ jest domyślny.';

  @override
  String get nastVychozi => 'domyślny';

  @override
  String get nastPridatTyp => 'Dodaj typ';

  @override
  String get nastUpravitTyp => 'Edytuj typ';

  @override
  String get nastNovyTyp => 'Nowy typ wpisu';

  @override
  String get nastTypHint => 'Nazwa typu (np. Serwis, Skup...)';

  @override
  String get nastLongPress => 'Długie naciśnięcie = ustaw jako domyślny.';

  @override
  String get nastOsobni => 'Ustawienia osobiste';

  @override
  String get nastPrizpusobitListu => 'Dostosuj dolny pasek';

  @override
  String get nastPrizpusobitListuSub => 'Dodaj skróty lub zmień kolejność.';

  @override
  String get nastListaPopis =>
      'Możesz mieć 2 do 5 aktywnych zakładek. Przeciągnij, aby zmienić kolejność.';

  @override
  String get nastMenuNelzeOdebrat => 'Menu nie można usunąć';

  @override
  String get nastVybrModul => 'Wybierz moduł dla paska';

  @override
  String get nastPridatZalozku => 'Dodaj kolejną zakładkę (maks. 5)';

  @override
  String get nastTmavyRezim => 'Wymuś tryb ciemny';

  @override
  String get nastTmavyRezimSub =>
      'Aplikacja będzie ciemna niezależnie od systemu.';

  @override
  String get nastBiometrie => 'Logowanie biometryczne';

  @override
  String get nastBiometrieSub =>
      'Face ID / odcisk palca przy każdym uruchomieniu.';

  @override
  String get nastBiometricReason =>
      'Potwierdź swoją tożsamość, aby włączyć logowanie biometryczne';

  @override
  String get nastLeVaci => 'Tryb dla leworęcznych';

  @override
  String get nastLeVaciSub =>
      'Wyzwalacz aparatu po lewej stronie w orientacji poziomej.';

  @override
  String get nastUlozitDoZarizeniTitle => 'Zapisuj zdjęcia także na urządzeniu';

  @override
  String get nastUlozitDoZarizeniSub =>
      'Przy wysyłaniu zdjęcia z przyjęcia są zapisywane również w galerii tego urządzenia.';

  @override
  String get nastJazyk => 'Język aplikacji';

  @override
  String get nastSystJazyk => 'Język systemu';

  @override
  String get nastModPrijem => 'Przyjęcie pojazdu';

  @override
  String get nastModHistorie => 'Historia przyjęć';

  @override
  String get nastModMenu => 'Menu (Inne moduły)';

  @override
  String get nastModVozidla => 'Pojazdy';

  @override
  String get nastModUkony => 'Zadania';

  @override
  String get nastModZakaznici => 'Klienci';

  @override
  String get nastModTym => 'Zespół i uprawnienia';

  @override
  String get nastModStatistiky => 'Statystyki';

  @override
  String get nastModNastaveni => 'Ustawienia';

  @override
  String get nastModVin => 'Dekoder VIN';

  @override
  String nastFormatTitle(String typ) {
    return 'Format numeru dla: $typ';
  }

  @override
  String get nastNahledLabel => 'Podgląd przyszłego dokumentu:';

  @override
  String nastInternaMaska(String maska) {
    return 'Maska wewnętrzna: $maska';
  }

  @override
  String get nastPrefix => 'Prefiks (Kod)';

  @override
  String get nastOddelovac => 'Separator';

  @override
  String get nastOddelovacPomlcka => 'Myślnik (-)';

  @override
  String get nastOddelovacLomitko => 'Ukośnik (/)';

  @override
  String get nastOddelovacPodtrzitko => 'Podkreślenie (_)';

  @override
  String get nastOddelovacBez => 'Bez separatora';

  @override
  String get nastRokFormat => 'Format roku';

  @override
  String get nastRok4 => '4 cyfry (2026)';

  @override
  String get nastRok2 => '2 cyfry (26)';

  @override
  String get nastBezRoku => 'Bez roku';

  @override
  String get nastMesicFormat => 'Format miesiąca';

  @override
  String get nastMesic2 => '2 cyfry (04)';

  @override
  String get nastBezMesice => 'Bez miesiąca';

  @override
  String nastDelkaCitadla(int n) {
    return 'Długość licznika końcowego: $n';
  }

  @override
  String get nastInfoZmenaFormatu =>
      'Jeśli zmienisz format w ciągu roku, istniejące dokumenty pozostają niezmienione, a nowa seria kontynuuje od aktualnego numeru w bazie danych.';

  @override
  String get nastUlozitFormat => 'ZAPISZ FORMAT';

  @override
  String get nastFormatUlozen => 'Format numeracji zapisany pomyślnie.';

  @override
  String get nastTrialVyprselo => 'Okres próbny wygasł';

  @override
  String get nastTrialAktivni => 'Bezpłatny okres próbny';

  @override
  String nastPlanNazev(String plan) {
    return 'Plan $plan';
  }

  @override
  String get nastTrialVyberPlan => 'Wybierz plan, aby kontynuować';

  @override
  String nastTrialZbyva(int n, String slovo) {
    return 'Pozostało $n $slovo · bez zobowiązań';
  }

  @override
  String nastPlatnostDo(String datum) {
    return 'Ważność do $datum';
  }

  @override
  String get nastAktivni => 'Aktywny';

  @override
  String get nastVybratPlan => 'Wybierz plan';

  @override
  String get nastZobrazitPlany => 'Pokaż plany';

  @override
  String get nastDayJeden => 'dzień';

  @override
  String get nastDayNeco => 'dni';

  @override
  String get nastDayMnogo => 'dni';

  @override
  String get zamModZamestnanci => 'Pracownicy';

  @override
  String get zamModNastaveni => 'Ustawienia';

  @override
  String zamChyba(String chyba) {
    return 'Błąd: $chyba';
  }

  @override
  String get zamTitle => 'Zespół i uprawnienia';

  @override
  String get zamSubtitle =>
      'Zarządzaj członkami swojego serwisu i ich dostępem do aplikacji.';

  @override
  String get zamPrazdny => 'Nie masz jeszcze żadnych członków zespołu.';

  @override
  String get zamPridatClena => 'Dodaj członka zespołu';

  @override
  String get zamLimitTitle => 'Osiągnięto limit kont';

  @override
  String zamLimitText(String plan, int limit, int pocet) {
    return 'Plan $plan umożliwia maksymalnie $limit kont użytkowników. Obecnie używasz $pocet/$limit. Aby dodać więcej członków zespołu, zaktualizuj plan.';
  }

  @override
  String get zamZrusit => 'Anuluj';

  @override
  String get zamUpgradovat => 'Zaktualizuj plan';

  @override
  String get zamNovyClen => 'Nowy członek zespołu';

  @override
  String get zamJmenoLabel => 'Imię i nazwisko *';

  @override
  String get zamEmailLabel => 'E-mail logowania *';

  @override
  String get zamHesloLabel => 'Hasło logowania (min. 6 znaków) *';

  @override
  String get zamVychoziPrava => 'Domyślne uprawnienia dostępu';

  @override
  String get zamVytvoritUcet => 'Utwórz konto';

  @override
  String get zamErrVyplnte => 'Wypełnij imię, e-mail i hasło.';

  @override
  String get zamErrHesloKratke => 'Hasło musi mieć co najmniej 6 znaków.';

  @override
  String get zamUcetVytvoren => 'Konto utworzone.';

  @override
  String get zamErrOvereni => 'Błąd uwierzytelniania.';

  @override
  String get zamErrHesloSlabe => 'Wprowadzone hasło jest zbyt słabe.';

  @override
  String get zamErrEmailExistuje => 'Konto z tym adresem e-mail już istnieje.';

  @override
  String get zamErrEmailFormat => 'Nieprawidłowy format e-mail.';

  @override
  String zamErrNeocekavana(String chyba) {
    return 'Nieoczekiwany błąd: $chyba';
  }

  @override
  String get zamPristupovaPrava => 'Uprawnienia dostępu';

  @override
  String get zamUlozitOpravneni => 'Zapisz uprawnienia';

  @override
  String get zamUdelitVse => 'Przyznaj wszystko';

  @override
  String get zamOdebratVse => 'Odbierz wszystko';

  @override
  String get zamOdstranit => 'Usuń';

  @override
  String get zamOdstranitTitle => 'Usunąć członka zespołu?';

  @override
  String zamOdstranitText(String jmeno) {
    return 'Czy na pewno chcesz usunąć członka $jmeno? Utraci dostęp do aplikacji. Tej operacji nie można cofnąć.';
  }

  @override
  String get zamClenOdstranen => 'Członek zespołu został usunięty.';

  @override
  String zamPocetUzivatelu(int pocet) {
    return '$pocet użytkowników';
  }

  @override
  String zamPocetLimit(int pocet, int limit) {
    return '$pocet / $limit użytkowników';
  }

  @override
  String zamPlanBezLimitu(String plan) {
    return 'Plan $plan · bez limitu';
  }

  @override
  String zamPlanLimitDosazen(String plan) {
    return 'Plan $plan · limit osiągnięty';
  }

  @override
  String zamPlanZbyva(String plan, int zbyva) {
    return 'Plan $plan · pozostało $zbyva';
  }

  @override
  String get zamBezJmena => 'Brak nazwy';

  @override
  String get zamBezPrav => 'Brak rozszerzonych uprawnień';

  @override
  String get zamBadgeAdmin => 'ADMIN';

  @override
  String get zamBadgeClen => 'CZŁONEK';
}
