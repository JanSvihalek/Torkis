// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'TORKIS';

  @override
  String get btnUlozit => 'Speichern';

  @override
  String get btnZrusit => 'Abbrechen';

  @override
  String get btnPotvrdit => 'Bestätigen';

  @override
  String get btnZavrit => 'Schließen';

  @override
  String get btnNovySken => 'Neuer Scan';

  @override
  String get btnSpustitSken => 'Scan starten →';

  @override
  String get btnZacitPouzivat => 'App verwenden';

  @override
  String get btnPlany => 'Pläne';

  @override
  String get nacitani => 'Wird geladen…';

  @override
  String get chybaObecna => 'Ein Fehler ist aufgetreten.';

  @override
  String get zadejteVin => 'Bitte VIN-Code eingeben.';

  @override
  String get zadejteVinRucne => 'VIN manuell eingeben (z.B. TMBJJ7NE5K…)';

  @override
  String get vinDekoderNav => 'VIN';

  @override
  String get vinDekoderTabDekodovani => 'VIN-Dekodierung';

  @override
  String get vinDekoderTabTrzniHodnota => 'Marktwert';

  @override
  String get vinDekoderTabStk => 'HU-Prüfung';

  @override
  String get vinDekoderTitle => 'VIN-Dekoder';

  @override
  String get vinDekoderSubtitle =>
      'Schnelle Fahrzeugspezifikation anhand der VIN';

  @override
  String get trzniHodnotaTitle => 'Marktwert';

  @override
  String get trzniHodnotaSubtitle =>
      'Geschätzter Fahrzeugmarktwert aus europäischen Marktdaten';

  @override
  String get stkTitle => 'HU-Prüfung';

  @override
  String get stkSubtitle =>
      'Hauptuntersuchungsnachweis aus dem Fahrzeugregister';

  @override
  String get skenVinKod => 'VIN-Code scannen';

  @override
  String get skenVinProTrzni => 'VIN für Marktwert scannen';

  @override
  String get skenVinProStk => 'VIN für HU scannen';

  @override
  String get skenVinPopis =>
      'Lädt automatisch Fahrzeugdaten anhand der gescannten oder eingegebenen VIN';

  @override
  String get skenVinTrzniPopis =>
      'Schätzt den Fahrzeugmarktwert aus europäischen Marktdaten';

  @override
  String get skenVinStkPopis =>
      'Lädt Hauptuntersuchungsdaten aus dem Fahrzeugregister';

  @override
  String get dekodovat => 'Dekodieren';

  @override
  String get zjstitHodnotu => 'Wert ermitteln';

  @override
  String get zjstitStk => 'HU prüfen';

  @override
  String get stkPlatna => 'HU gültig';

  @override
  String get stkNeplatna => 'HU abgelaufen';

  @override
  String stkPlatnaJeste(int dni) {
    return 'HU noch $dni Tage gültig';
  }

  @override
  String stkProsla(int dni) {
    return 'HU seit $dni Tagen abgelaufen';
  }

  @override
  String get stkDatumNeznamo => 'HU — Datum unbekannt';

  @override
  String get stkPlatnostDo => 'HU gültig bis';

  @override
  String get stkInfoBanner =>
      'Daten stammen aus dem öffentlichen Fahrzeugregister. Verfügbarkeit und Aktualität können variieren — HU-Daten sind nicht für alle Fahrzeuge verfügbar.';

  @override
  String get trzniHodnotaTitle2 => 'MARKTWERT';

  @override
  String get trzniMedian => 'Median';

  @override
  String get trzniPrumernaCena => 'Durchschnittspreis';

  @override
  String get trzniPrumernyNajezd => 'Durchschnittslaufleistung';

  @override
  String get trzniPocetVzorku => 'Stichprobenanzahl';

  @override
  String get trzniObdobiDat => 'Datenzeitraum';

  @override
  String get trzniZdroj => 'Europäischer Markt · Vincario Market Value';

  @override
  String get trzniNeniData => 'Europäische Daten nicht verfügbar.';

  @override
  String get historieNacitani => 'Wird geladen…';

  @override
  String get historieSken => 'Scan-Verlauf';

  @override
  String get historiePrvniDekodovani => 'Zum ersten Mal dekodiert';

  @override
  String get historieNeznameVozidlo => 'Unbekanntes Fahrzeug';

  @override
  String get historieZadneSken => 'Noch keine Scans.';

  @override
  String get historieVse => 'Alle';

  @override
  String historieDnes(int pocet) {
    return 'Heute · $pocet dekodierte VINs';
  }

  @override
  String get historiePosledniSkeny => 'Letzte Scans';

  @override
  String get historieNoveVozidlo => 'Neues Fahrzeug';

  @override
  String historieDekodovanoXKrat(int pocet) {
    return '$pocet× dekodiert';
  }

  @override
  String get limitVyprsel =>
      'Monatslimit erreicht. Upgraden Sie Ihren Plan, um fortzufahren.';

  @override
  String get limitDekodovaniTitle => 'VIN-Dekodierungen diesen Monat';

  @override
  String get limitTrzniTitle => 'Marktwertabfragen diesen Monat';

  @override
  String get upsellTrzniTitle =>
      'Marktwert ist in kostenpflichtigen Plänen verfügbar';

  @override
  String get upsellTrzniText =>
      'In der Testversion nicht verfügbar. Ab dem Basic-Plan freigeschaltet.';

  @override
  String chybaDekodovani(String zprava) {
    return 'VIN-Dekodierung fehlgeschlagen: $zprava';
  }

  @override
  String get trialWelcomeTitle => 'Willkommen bei TORKIS';

  @override
  String get trialWelcomeSubtitle =>
      'Wir haben Ihre 30-tägige kostenlose Testphase gestartet — ohne Kreditkarte, ohne Verpflichtung.';

  @override
  String get trialWelcomePill => '30 TAGE KOSTENLOS';

  @override
  String get trialWelcomeFooter =>
      'Nach der Testphase wählen Sie den passenden Plan.';

  @override
  String get trialBenefitVozidla =>
      'Unbegrenzte Fahrzeug- und Kundendatensätze';

  @override
  String get trialBenefitVin => '10 dekodierte VINs';

  @override
  String get trialBenefitStk => 'Unbegrenzte HU-Gültigkeitsprüfungen';

  @override
  String get trialBenefitFunkce =>
      'Vollständiger Zugriff auf alle App-Funktionen.';

  @override
  String get trialBenefitKarta =>
      'Keine Zahlungsdaten. Keine automatischen Abbuchungen.';

  @override
  String get trialBenefitData =>
      'Ihre Daten gehören immer Ihnen — jederzeit kostenlos exportieren.';
}
