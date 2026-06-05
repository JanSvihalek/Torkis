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
}
