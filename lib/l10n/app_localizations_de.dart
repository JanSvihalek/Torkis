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

  @override
  String get vozidloStatTacho => 'TACHO';

  @override
  String get vozidloStatStkDo => 'HU BIS';

  @override
  String get vozidloStatPrijmu => 'DIENSTE';

  @override
  String get vozidloStkPlatna => 'HU gültig';

  @override
  String get vozidloStkProsla => 'HU abgelaufen';

  @override
  String vozidloStkVyprsiBehemMesicu(String mesic, String rok, int pocet) {
    return 'Läuft ab $mesic/$rok · noch $pocet Monate';
  }

  @override
  String vozidloStkVyprsela(String mesic, String rok) {
    return 'Abgelaufen $mesic/$rok';
  }

  @override
  String get vozidloTechnickeUdaje => 'Technische Daten';

  @override
  String get vozidloZnackaModel => 'Marke & Modell';

  @override
  String get vozidloMotorizace => 'Motor';

  @override
  String get vozidloVin => 'FIN';

  @override
  String get vozidloRokVyroby => 'Baujahr';

  @override
  String get vozidloPalivo => 'Kraftstoff';

  @override
  String get vozidloPrevodovka => 'Getriebe';

  @override
  String get vozidloBarva => 'Farbe';

  @override
  String get vozidloVykon => 'Leistung';

  @override
  String get vozidloPocetMistDveri => 'Sitze / Türen';

  @override
  String get vozidloRozmery => 'Abmessungen';

  @override
  String get vozidloUdajeZVin => 'VIN-Daten';

  @override
  String get vozidloTachometrLabel => 'Tachostand';

  @override
  String get vozidloMajitel => 'Fahrzeughalter';

  @override
  String get vozidloJmeno => 'Name';

  @override
  String get vozidloTelefon => 'Telefon';

  @override
  String get vozidloEmail => 'E-Mail';

  @override
  String get vozidloVolat => 'Anrufen';

  @override
  String get vozidlaTitle => 'Fahrzeugdatenbank';

  @override
  String get vozidlaSubtitle => 'Übersicht aller gewarteten Fahrzeuge.';

  @override
  String get vozidlaHledatHint => 'Kennzeichen, Marke oder FIN suchen...';

  @override
  String get vozidlaSkenSpzTooltip => 'Kennzeichen mit Kamera scannen';

  @override
  String get vozidlaZadnaVozidla => 'Noch keine Fahrzeuge in der Datenbank.';

  @override
  String get vozidlaNejstePrihlaseni => 'Sie sind nicht angemeldet.';

  @override
  String get vozidlaSkenJenApp =>
      'Scannen ist nur in der installierten App (APK/iOS) möglich.';

  @override
  String get vozidloDetailUprava => 'Fahrzeug bearbeiten';

  @override
  String get vozidloDetailSpz => 'Kennzeichen';

  @override
  String get vozidloDetailZnacka => 'Marke';

  @override
  String get vozidloDetailModel => 'Modell';

  @override
  String get vozidloDetailTachoKm => 'Tachostand (km)';

  @override
  String get vozidloDetailPlatnostStk => 'HU-Gültigkeit';

  @override
  String get vozidloDetailStkMesic => 'Monat (MM)';

  @override
  String get vozidloDetailStkRok => 'Jahr (YYYY)';

  @override
  String get vozidloDetailUlozitZmeny => 'ÄNDERUNGEN SPEICHERN';

  @override
  String get vozidloDetailSpzExistuje =>
      'Ein Fahrzeug mit diesem Kennzeichen existiert bereits!';

  @override
  String vozidloDetailPrejmenovano(String spz) {
    return 'Fahrzeug in $spz umbenannt. Verlauf wurde beibehalten.';
  }

  @override
  String get vozidloDetailNenalezeno => 'Fahrzeug nicht gefunden.';

  @override
  String get vozidloDetailBezSpz => 'Fahrzeug ohne Kennzeichen';

  @override
  String get vozidloDetailLabel => 'FAHRZEUG';

  @override
  String get vozidloTabInfo => 'Info';

  @override
  String get vozidloTabZaznamy => 'Einträge';

  @override
  String get vozidloSmazatAkce => 'Fahrzeug löschen';

  @override
  String get vozidloSmazatDialogTitle => 'Fahrzeug löschen?';

  @override
  String get vozidloSmazatDialogText =>
      'Das Fahrzeug wird aus dem Verzeichnis entfernt. Der Serviceverlauf bleibt erhalten.';

  @override
  String get vozidloSmazano => 'Fahrzeug gelöscht.';

  @override
  String get vozidloSmazatBtn => 'Löschen';

  @override
  String get prijemHelperTelefon => 'Telefonnummer';

  @override
  String get prijemHelperPredvolba => 'Vorwahl auswählen';

  @override
  String get prijemStavTitle => 'Fahrzeugzustand';

  @override
  String get prijemStavTacho => 'Tachostand (km)';

  @override
  String prijemStavNadrz(int value) {
    return 'Kraftstoffstand ($value %)';
  }

  @override
  String get prijemStavPoskozeni => 'Festgestellte Schäden (mehrere möglich)';

  @override
  String get prijemStavVlastniPopis => 'Schadensbeschreibung...';

  @override
  String get prijemStavPridat => 'Eigenen Schaden hinzufügen';

  @override
  String get prijemStavPlatnostStk => 'HU-Gültigkeit';

  @override
  String get prijemStavMesic => 'Monat';

  @override
  String get prijemStavRok => 'Jahr';

  @override
  String get prijemStavPneu => 'Profiltiefe (mm)';

  @override
  String get prijemStavLevaPreh => 'VL';

  @override
  String get prijemStavPravaPreh => 'VR';

  @override
  String get prijemStavLevaZad => 'HL';

  @override
  String get prijemStavPravaZad => 'HR';

  @override
  String get prijemStavPoznamky => 'Zusätzliche Hinweise';

  @override
  String get prijemStavPoznamkyHint => 'Weitere Details zur Annahme...';

  @override
  String get prijemZakaznikTitle => 'Kundendaten';

  @override
  String get prijemZakaznikJmeno => 'Vor- und Nachname / Firmenname';

  @override
  String get prijemZakaznikHledat => 'Gespeicherten Kunden suchen';

  @override
  String get prijemZakaznikIco => 'Handelsregisternummer';

  @override
  String get prijemZakaznikHledatAres => 'Register durchsuchen';

  @override
  String get prijemZakaznikPravniForma => 'Rechtsform';

  @override
  String get prijemZakaznikUlice => 'Straße und Hausnummer';

  @override
  String get prijemZakaznikMesto => 'Stadt';

  @override
  String get prijemZakaznikPsc => 'PLZ';

  @override
  String get prijemZakaznikEmail => 'E-Mail';

  @override
  String get prijemZakaznikFyzicka => 'Privatperson';

  @override
  String get prijemZakaznikOsvc => 'Selbstständig';

  @override
  String get prijemVozidloTitle => 'Fahrzeugdatensatz';

  @override
  String get prijemVozidloNapoveda =>
      'FIN oder Kennzeichen scannen oder manuell eingeben.';

  @override
  String get prijemVozidloZeme => 'Land';

  @override
  String get prijemVozidloSpz => 'Kennzeichen';

  @override
  String get prijemVozidloHledatSpz => 'Kennzeichen in Datenbank suchen';

  @override
  String get prijemVozidloHledatSpzSub =>
      'Gespeichertes Fahrzeug nach Kennzeichen finden';

  @override
  String get prijemVozidloVin => 'FIN';

  @override
  String get prijemVozidloHledatVin => 'FIN in Datenbank suchen';

  @override
  String get prijemVozidloHledatVinSub =>
      'Gespeichertes Fahrzeug nach FIN finden';

  @override
  String get prijemVozidloDekodovat => 'FIN online dekodieren';

  @override
  String get prijemVozidloDekodovatSub =>
      'Marke, Modell, Motor und HU ergänzen';

  @override
  String get prijemVozidloZnackaHint => 'Marke (z.B. Škoda)';

  @override
  String get prijemVozidloModelHint => 'Modell (z.B. Octavia)';

  @override
  String get prijemVozidloSkenovat => 'FIN/Kennzeichen scannen';

  @override
  String get prijemVozidloSkenSub => 'Erkennt automatisch den Codetyp';

  @override
  String get prijemVozidloRozlozeniPodSebou => 'Untereinander';

  @override
  String get prijemVozidloRozlozeniVMrizce => 'Raster';

  @override
  String get prijemVozidloTypZaznamu => 'Datensatztyp';

  @override
  String get prijemVozidloCisloZaznamu => 'Auftragsnummer';

  @override
  String get prijemVozidloGenerovat => 'Neue Nummer generieren';

  @override
  String get prijemVozidloUlozenaVozidla => 'Gespeicherte Fahrzeuge des Kunden';

  @override
  String get prijemVozidloRokVyroby => 'Baujahr';

  @override
  String get prijemVozidloMotorizaceHint => 'Motor (z.B. 2.0 TDI)';

  @override
  String get prijemVozidloTypPaliva => 'Kraftstoffart';

  @override
  String get prijemVozidloPrevodovka => 'Getriebe';

  @override
  String get prijemVozidloTypKaroserie => 'Karosserietyp';

  @override
  String get prijemVozidloBenzin => 'Benzin';

  @override
  String get prijemVozidloNafta => 'Diesel';

  @override
  String get prijemVozidloElektro => 'Elektro';

  @override
  String get prijemVozidloHybrid => 'Hybrid';

  @override
  String get prijemVozidloLpgCng => 'LPG/CNG';

  @override
  String get prijemVozidloJine => 'Sonstige';

  @override
  String get prijemVozidloManualni => 'Schaltgetriebe';

  @override
  String get prijemVozidloAutomaticka => 'Automatik';

  @override
  String get prijemVozidloDalsiUdaje => 'Weitere Fahrzeugdaten';

  @override
  String get prijemVozidloDalsiUdajeSub =>
      'Optional – wird aus dem VIN-Decoder ausgefüllt';

  @override
  String get prijemVozidloBarva => 'Farbe';

  @override
  String get prijemVozidloVykon => 'Leistung (kW)';

  @override
  String get prijemVozidloPocetMist => 'Anzahl Sitze';

  @override
  String get prijemVozidloPocetDveri => 'Anzahl Türen';

  @override
  String get prijemVozidloRozmery => 'Abmessungen (L × B × H mm)';

  @override
  String get prijemVozidloDelka => 'Länge';

  @override
  String get prijemVozidloSirka => 'Breite';

  @override
  String get prijemVozidloVyska => 'Höhe';

  @override
  String get prijemPraceTitle => 'Erforderliche Arbeiten';

  @override
  String get prijemPracePozadavkyHint =>
      'Was haben wir mit dem Kunden vereinbart?';

  @override
  String get prijemPraceRychlyVyber => 'Schnellauswahl häufiger Arbeiten:';

  @override
  String get prijemPraceSeznam => 'Arbeitsliste für den Auftrag:';

  @override
  String get prijemPracePridat => 'Weitere Arbeit hinzufügen';

  @override
  String prijemPraceUkonN(int n) {
    return 'Arbeit $n';
  }

  @override
  String get prijemPodpisTitle => 'Zusammenfassung';

  @override
  String get prijemPodpisNeuvedeno => 'Nicht angegeben';

  @override
  String prijemPodpisZakaznik(String jmeno) {
    return 'Kunde: $jmeno';
  }

  @override
  String prijemPodpisAdresa(String adresa) {
    return 'Adresse: $adresa';
  }

  @override
  String prijemPodpisVozidlo(String spzZnacka) {
    return 'Fahrzeug: $spzZnacka';
  }

  @override
  String get prijemPodpisSjednaneUkony => 'Vereinbarte Arbeiten:';

  @override
  String get prijemRekapZaznam => 'Datensatz';

  @override
  String get prijemKonceptTitle => 'Nicht gesendeter Auftrag';

  @override
  String get prijemKonceptText =>
      'Sie haben einen nicht gesendeten Auftrag in Bearbeitung. Möchten Sie dort fortfahren, wo Sie aufgehört haben?';

  @override
  String get prijemKonceptObnovit => 'Wiederherstellen';

  @override
  String get prijemKonceptZahodit => 'Verwerfen';

  @override
  String get prijemPodpisEmailToggle =>
      'Kopie des Protokolls per E-Mail senden';

  @override
  String get prijemPodpisEmailChybi =>
      'Keine E-Mail für diesen Kunden (Schritt 2) angegeben.';

  @override
  String prijemPodpisEmailKam(String email) {
    return 'Wird gesendet an: $email';
  }

  @override
  String get prijemPodpisSouhlas =>
      'Mit seiner Unterschrift bestätigt der Kunde die Richtigkeit der obigen Angaben und akzeptiert den Fahrzeugzustand bei der Übernahme.';

  @override
  String get prijemPodpisSmazat => 'Unterschrift löschen';

  @override
  String get prijemPodpisVypnut =>
      'Kundenunterschrift ist in den Serviceeinstellungen deaktiviert.';

  @override
  String get prijemPodpisOtevrit => 'Unterschreiben';

  @override
  String get prijemPodpisZnovu => 'Erneut unterschreiben';

  @override
  String get prijemPodpisHotovo => 'Fertig';

  @override
  String get prijemPodpisZavrit => 'Schließen';

  @override
  String get prijemPodpisHint => 'Mit dem Finger oder Stift unterschreiben';

  @override
  String get prijemPodpisNahled => 'Unterschrift des Kunden';

  @override
  String get prijemPodpisZahoditTitul => 'Unterschrift verwerfen?';

  @override
  String get prijemPodpisZahoditPomoc =>
      'Sie haben eine unfertige Unterschrift. Wirklich verwerfen?';

  @override
  String get prijemPodpisZahodit => 'Verwerfen';

  @override
  String get predaniTitul => 'Fahrzeugübergabe';

  @override
  String get predaniTlacitko => 'An Kunden übergeben';

  @override
  String get predaniProvedenePrace => 'Durchgeführte Arbeiten';

  @override
  String get predaniPridatPraci => 'Arbeit hinzufügen';

  @override
  String get predaniVybratZCeniku => 'Aus Preisliste wählen';

  @override
  String get predaniNazevPrace => 'Bezeichnung der Arbeit';

  @override
  String get predaniCena => 'Preis';

  @override
  String get predaniCelkem => 'Gesamtbetrag';

  @override
  String get predaniBezPrace =>
      'Noch keine Arbeiten. Fügen Sie die durchgeführten Tätigkeiten hinzu.';

  @override
  String get predaniPorovnani => 'Zustandsvergleich';

  @override
  String get predaniPriPrijmu => 'Bei Annahme';

  @override
  String get predaniPriPredani => 'Bei Übergabe';

  @override
  String get predaniTachometrPredani => 'Kilometerstand bei Übergabe (km)';

  @override
  String get predaniFoto => 'Übergabefotos';

  @override
  String get predaniPridatFoto => 'Foto hinzufügen';

  @override
  String get predaniPodpisPrevzeti => 'Übergabeunterschrift';

  @override
  String get predaniSouhlas =>
      'Mit seiner Unterschrift bestätigt der Kunde die Übernahme des Fahrzeugs und stimmt den durchgeführten Arbeiten sowie dem berechneten Betrag zu.';

  @override
  String get predaniDokoncit => 'Übergabe abschließen';

  @override
  String get predaniHotovo => 'Das Fahrzeug wurde an den Kunden übergeben.';

  @override
  String get predaniChybaPodpis =>
      'Der Kunde muss die Übergabeunterschrift hinzufügen.';

  @override
  String get predaniProbiha => 'Übergabe wird gespeichert…';

  @override
  String get prijemTabletPostup => 'VERLAUF';

  @override
  String get prijemTabletPosledniNavsteva => 'LETZTER BESUCH';

  @override
  String get prijemTabletVozidlo => 'Fahrzeug';

  @override
  String get prijemTabletTacho => 'Tachostand';

  @override
  String get prijemTabletStk => 'HU';

  @override
  String get prijemTabletNaposledy => 'Zuletzt';

  @override
  String get prijemTabletStav => 'Zustand';

  @override
  String get prijemTabletStavPriPrijmu => 'Zustand bei Annahme';

  @override
  String get prijemTabletPoskozeni => 'Schäden';

  @override
  String get prijemTabletNeuvedeno => 'Nicht angegeben';

  @override
  String get prijemTabletNahled => 'FAHRZEUGVORSCHAU';

  @override
  String get prijemTabletSpz => 'Kennzeichen';

  @override
  String get prijemTabletVin => 'FIN';

  @override
  String get prijemTabletZakazka => 'Auftrag';

  @override
  String get prijemTabletUdajePlni =>
      'Daten werden beim Ausfüllen des Formulars aktualisiert.';

  @override
  String get prijemErrVinVyhledani =>
      'Geben Sie mindestens einen Teil der FIN ein.';

  @override
  String get prijemErrServisId =>
      'Fehler: Service-ID konnte nicht geladen werden.';

  @override
  String get prijemErrZadneVozidloVin =>
      'Kein Fahrzeug mit dieser FIN gefunden.';

  @override
  String get prijemErrSpzVyhledani =>
      'Geben Sie mindestens einen Teil des Kennzeichens ein.';

  @override
  String get prijemErrZadneVozidloSpz =>
      'Kein Fahrzeug mit diesem Kennzeichen gefunden.';

  @override
  String get prijemErrZadejteVin =>
      'Geben Sie einen FIN-Code zum Dekodieren ein.';

  @override
  String prijemStkPlatnaSnackbar(String datum) {
    return 'HU gültig bis $datum';
  }

  @override
  String prijemStkProslaSnackbar(String datum) {
    return 'HU abgelaufen! War gültig bis $datum';
  }

  @override
  String get prijemVincarioDoplneno => 'Fahrzeugdaten aus Vincario ergänzt.';

  @override
  String get prijemVozidloNacteno => 'Fahrzeug- und Kundendaten geladen.';

  @override
  String get prijemNalezenoVice => 'Mehrere Fahrzeuge gefunden';

  @override
  String get prijemVyberVozidlo =>
      'Wählen Sie ein bestimmtes Fahrzeug aus der Liste:';

  @override
  String get prijemNeznanaSpz => 'Unbekanntes Kennzeichen';

  @override
  String get prijemErrCisloASpz =>
      'Auftragsnummer und Kennzeichen sind Pflichtfelder!';

  @override
  String get prijemErrCislo => 'Auftragsnummer ist ein Pflichtfeld!';

  @override
  String get prijemErrSpz => 'Kennzeichen ist ein Pflichtfeld!';

  @override
  String get prijemErrCisloDuplicitni =>
      'Diese Auftragsnummer existiert bereits! Bitte eine andere eingeben.';

  @override
  String get prijemErrPodpis => 'Kunde muss vor dem Absenden unterschreiben.';

  @override
  String get prijemLimitTitle => 'Annahmelimit erreicht';

  @override
  String prijemLimitText(String plan, int limit) {
    return 'Ihr $plan-Plan erlaubt maximal $limit Annahmen pro Monat. Upgraden Sie für mehr.';
  }

  @override
  String get prijemZavrit => 'Schließen';

  @override
  String get prijemUspesne => 'Auftrag erfolgreich übermittelt';

  @override
  String get prijemErrNejstePrirazeni => 'Sie sind keinem Service zugeordnet!';

  @override
  String get prijemSkenJenApp =>
      'KI-Scannen ist nur in der installierten App (APK/iOS) verfügbar.';

  @override
  String get prijemNavigaceLabel => 'FAHRZEUGDATENSATZ';

  @override
  String get prijemNovyZaznam => 'Neuer Datensatz';

  @override
  String get prijemDokoncit => 'Abschließen und übermitteln';

  @override
  String get prijemPokracovat => 'Weiter';

  @override
  String get prijemOdesilamMsg => 'Auftrag und Protokoll werden übermittelt...';

  @override
  String prijemNahravamFotky(int hotovo, int celkem) {
    return 'Fotos werden hochgeladen $hotovo/$celkem';
  }

  @override
  String prijemKrokZ(int krok, int celkem) {
    return 'Schritt $krok von $celkem';
  }

  @override
  String get prijemStepIdentifikace => 'Fahrzeugidentifikation';

  @override
  String get prijemStepZakaznik => 'Kunde';

  @override
  String get prijemStepFoto => 'Fotos';

  @override
  String get prijemStepStav => 'Zustand';

  @override
  String get prijemStepPrace => 'Arbeiten';

  @override
  String get prijemStepSouhrn => 'Zusammenfassung';

  @override
  String prijemSkenNenalezeno(String co) {
    return 'Gescannt \'$co\'. Nicht in Datenbank gefunden — bitte manuell ausfüllen.';
  }

  @override
  String get vinSekceIdentifikace => 'IDENTIFIKATION';

  @override
  String get vinSekceMotor => 'MOTOR & ANTRIEB';

  @override
  String get vinSekceKaroserie => 'KAROSSERIE & ABMESSUNGEN';

  @override
  String get vinSekcePalivo => 'KRAFTSTOFF & EMISSIONEN';

  @override
  String get vinSekceOstatni => 'WEITERE INFOS';

  @override
  String get vinFieldZnacka => 'Marke';

  @override
  String get vinFieldModel => 'Modell';

  @override
  String get vinFieldObchodniOznaceni => 'Handelsname';

  @override
  String get vinFieldRokVyroby => 'Baujahr';

  @override
  String get vinFieldKaroserie => 'Karosserie';

  @override
  String get vinFieldTypVarianta => 'Ausstattung / Variante';

  @override
  String get vinFieldMistoVyroby => 'Herstellungsort';

  @override
  String get vinFieldMotorizace => 'Motor';

  @override
  String get vinFieldTypMotoru => 'Motortyp';

  @override
  String get vinFieldZdvihObjem => 'Hubraum';

  @override
  String get vinFieldPocetValcu => 'Zylinder';

  @override
  String get vinFieldVykon => 'Leistung';

  @override
  String get vinFieldTocivyMoment => 'Max. Drehmoment';

  @override
  String get vinFieldPalivo => 'Kraftstoff';

  @override
  String get vinFieldPrevodovka => 'Getriebe';

  @override
  String get vinFieldPocetPrevodu => 'Gänge';

  @override
  String get vinFieldPohon => 'Antrieb';

  @override
  String get vinFieldMaxRychlost => 'Höchstgeschwindigkeit';

  @override
  String get vinFieldTypKaroserie => 'Karosserietyp';

  @override
  String get vinFieldPocetDveri => 'Türen';

  @override
  String get vinFieldPocetMist => 'Sitze';

  @override
  String get vinFieldProvozniHmotnost => 'Leergewicht';

  @override
  String get vinFieldMaxHmotnost => 'Zul. Gesamtgewicht';

  @override
  String get vinFieldTaznaHmotnost => 'Anhängelast';

  @override
  String get vinFieldRozvorNaprav => 'Radstand';

  @override
  String get vinFieldDelka => 'Länge';

  @override
  String get vinFieldSirka => 'Breite';

  @override
  String get vinFieldVyska => 'Höhe';

  @override
  String get vinFieldObjemNadrze => 'Tankvolumen';

  @override
  String get vinField1Registrace => 'Erstzulassung';

  @override
  String get vinFieldEmisniNorma => 'Abgasnorm';

  @override
  String get vinFieldEmiseCo2 => 'CO₂-Emissionen';

  @override
  String get vinFieldSpotrebaKomb => 'Verbrauch (komb.)';

  @override
  String get vinFieldSpotrebaMesto => 'Stadtverbrauch';

  @override
  String get vinFieldSpotrebaDalnice => 'Autobahnverbrauch';

  @override
  String get vinFieldElektDojezd => 'Elektrische Reichweite';

  @override
  String vinLimitDekodovani(int pocet, int limit) {
    return 'Sie haben das Monatslimit von $pocet / $limit Dekodierungen erreicht. Upgraden Sie für mehr.';
  }

  @override
  String vinLimitValue(int pocet, int limit) {
    return 'Sie haben das Monatslimit von $pocet / $limit Abfragen erreicht.';
  }

  @override
  String get vinTrzniChybaVerze =>
      'Marktwertabfrage ist nicht im Testpaket enthalten — in einem Bezahlplan freischalten.';

  @override
  String get vinChybaHistorie => 'Verlauf konnte nicht geladen werden.';

  @override
  String get vinTotoVozidloNebyloDekodovano =>
      'Dieses Fahrzeug wurde noch nicht dekodiert.';

  @override
  String get vinPraveTed => 'Gerade eben';

  @override
  String vinPredMinutami(int pocet) {
    return 'vor $pocet Min.';
  }

  @override
  String get vinVincarioKlice =>
      'Vincario API-Schlüssel sind nicht gesetzt. In den Serviceeinstellungen ergänzen.';

  @override
  String vinTrzniOd(String value, String mena) {
    return 'ab $value $mena';
  }

  @override
  String vinTrzniDo(String value, String mena) {
    return 'bis $value $mena';
  }

  @override
  String get vinTrzniHodnotaTitle => 'Marktwert';

  @override
  String get vinStkTitle => 'HU-Prüfung';

  @override
  String get vinTrzniSubtitle =>
      'Geschätzter Marktwert des Fahrzeugs aus europäischen Marktdaten';

  @override
  String get vinStkSubtitle =>
      'Übersicht der Hauptuntersuchungen aus dem Fahrzeugregister';

  @override
  String get vinSkenTitleVin => 'VIN-Code scannen';

  @override
  String get vinSkenTitleTrzni => 'VIN für Marktwert scannen';

  @override
  String get vinSkenTitleStk => 'VIN für HU scannen';

  @override
  String get vinSkenPopisVin =>
      'Lädt automatisch Fahrzeugspezifikationen anhand des gescannten oder eingegebenen VIN';

  @override
  String get vinSkenPopisTrzni =>
      'Schätzt den Marktwert des Fahrzeugs aus dem gescannten oder eingegebenen VIN anhand europäischer Marktdaten';

  @override
  String get vinSkenPopisStk =>
      'Lädt Hauptuntersuchungsdaten des Fahrzeugs aus dem Register';

  @override
  String get vinSkenTlacitko => 'Scan starten';

  @override
  String get vinInputHint => 'VIN manuell eingeben (z. B. TMBJJ7NE5K…)';

  @override
  String get vinTooltipHodnota => 'Wert abfragen';

  @override
  String get vinTooltipStk => 'HU abfragen';

  @override
  String get vinTooltipDekodovat => 'Dekodieren';

  @override
  String get vinUpsellTitle => 'Marktwert ist ein kostenpflichtiges Feature';

  @override
  String get vinUpsellSubtitle =>
      'In der Testversion nicht verfügbar. Im Basic-Plan freischaltbar.';

  @override
  String get vinUpsellPlany => 'Pläne';

  @override
  String get vinLimitTrzniMesic => 'Marktwert diesen Monat';

  @override
  String get vinLimitDekodovaniMesic => 'VIN-Dekodierungen diesen Monat';

  @override
  String get vinLimitVycerpan =>
      'Monatslimit erreicht. Upgraden Sie Ihren Plan, um fortzufahren.';

  @override
  String get vinStkInfoBanner =>
      'Die Daten stammen aus dem öffentlichen Fahrzeugregister. Verfügbarkeit und Aktualität können variieren — bei einigen Fahrzeugen ist keine HU erfasst.';

  @override
  String vinChybaDekodovani(String chyba) {
    return 'VIN konnte nicht dekodiert werden: $chyba';
  }

  @override
  String get vinNovySken => 'Neuer Scan';

  @override
  String get vinTrzniHodnotaHeader => 'MARKTWERT';

  @override
  String get vinStkPlatnostNeznama => 'HU — Datum unbekannt';

  @override
  String vinStkPlatnaJesteXDni(int dnu) {
    return 'HU noch $dnu Tage gültig';
  }

  @override
  String vinStkNeplatna(int dnu) {
    return 'HU abgelaufen (vor $dnu Tagen)';
  }

  @override
  String get vinStkPlatnostDo => 'HU gültig bis';

  @override
  String get vinTrzniDataNedostupna => 'Europäische Daten nicht verfügbar.';

  @override
  String get vinTrzniMedian => 'Median';

  @override
  String get vinTrzniPrumernaCena => 'Durchschnittspreis';

  @override
  String get vinTrzniPrumernyNajezd => 'Durchschnittslaufleistung';

  @override
  String get vinTrzniPocetVzorku => 'Stichprobenanzahl';

  @override
  String get vinTrzniObdobiDat => 'Datenzeitraum';

  @override
  String get vinTrzniZdroj => 'Europäischer Markt · Vincario Market Value';

  @override
  String get vinTrzniNajezdLabel => 'Laufleistung des Fahrzeugs (km)';

  @override
  String get vinTrzniOdhad => 'Schätzung nach Laufleistung';

  @override
  String get vinTrzniOdhadVysvetleni =>
      'Ungefährer Restwert, geschätzt aus Preis- und Laufleistungsspanne der Stichprobe.';

  @override
  String get vinHistorieNadpis => 'Scanverlauf';

  @override
  String vinHistorieDnes(int pocet) {
    return 'Heute · $pocet VINs dekodiert';
  }

  @override
  String get vinHistoriePosledni => 'Letzte Scans';

  @override
  String get vinHistorieVse => 'Alle';

  @override
  String get vinHistorieNacitani => 'Laden…';

  @override
  String get vinHistorieZadneSkeny => 'Noch keine Scans.';

  @override
  String get vinHistorieNoveVozidlo => 'Neues Fahrzeug';

  @override
  String get vinHistoriePoprve => 'Erstmals dekodiert';

  @override
  String vinHistorieDekodovanoX(int pocet) {
    return '$pocet× dekodiert';
  }

  @override
  String get vinHistorieNezname => 'Unbekanntes Fahrzeug';

  @override
  String get vinZadejteVin => 'Bitte VIN-Code eingeben.';

  @override
  String get vinSkenJenApk =>
      'Scannen funktioniert nur in der installierten App (APK/iOS).';

  @override
  String get vinFieldKodMotoru => 'Motorcode';

  @override
  String get zakZakaznici => 'Kunden';

  @override
  String get zakSubtitle => 'Verzeichnis Ihrer Kunden und ihrer Fahrzeuge.';

  @override
  String get zakHledatHint => 'Name, Telefon oder USt-IdNr. suchen...';

  @override
  String zakChybaDb(String chyba) {
    return 'Datenbankfehler: $chyba';
  }

  @override
  String get zakZadniZakaznici => 'Noch keine Kunden vorhanden.';

  @override
  String zakIcoZnak(String ico) {
    return '🏢 Reg.-Nr.: $ico';
  }

  @override
  String get zakEditTitle => 'Kunden bearbeiten';

  @override
  String get zakJmenoLabel => 'Vor- und Nachname / Firmenname';

  @override
  String get zakTelLabel => 'Telefon';

  @override
  String get zakVybertePredvolbu => 'Vorwahl wählen';

  @override
  String get zakCisloLabel => 'Nummer';

  @override
  String get zakEmailLabel => 'E-Mail';

  @override
  String get zakAdresaLabel => 'Adresse';

  @override
  String get zakIcoLabel => 'Reg.-Nr.';

  @override
  String get zakDicLabel => 'USt-IdNr.';

  @override
  String get zakUlozitZmeny => 'ÄNDERUNGEN SPEICHERN';

  @override
  String get zakZpracovavam => 'Daten werden geladen...';

  @override
  String get zakKartaZakaznika => 'Kundenkarte';

  @override
  String get zakHeaderLabel => 'KUNDE';

  @override
  String get zakTabInfo => 'Info';

  @override
  String get zakTabZaznamy => 'Aufträge';

  @override
  String get zakSmazatMenu => 'Kunden löschen';

  @override
  String get zakSmazatTitle => 'Kunden löschen?';

  @override
  String get zakSmazatContent =>
      'Der Kunde wird aus dem Verzeichnis entfernt. Seine Fahrzeuge und Auftragshistorie bleiben erhalten.';

  @override
  String get zakZrusit => 'Abbrechen';

  @override
  String get zakSmazatPotvrdit => 'Löschen';

  @override
  String get zakSmazanUspesne => 'Kunde gelöscht.';

  @override
  String zakChybaMazani(String chyba) {
    return 'Fehler beim Löschen: $chyba';
  }

  @override
  String get zakNeznamyZakaznik => 'Unbekannter Kunde';

  @override
  String get zakFirma => 'Firma';

  @override
  String get zakSoukromaOsoba => 'Privatperson';

  @override
  String get zakStatVozidel => 'FAHRZEUGE';

  @override
  String get zakStatPrijmu => 'AUFTRÄGE';

  @override
  String get zakVolat => 'Anrufen';

  @override
  String get zakSms => 'SMS';

  @override
  String get zakKontaktniUdaje => 'Kontaktdaten';

  @override
  String get zakVozidlaTitle => 'Fahrzeuge des Kunden';

  @override
  String get zakPridat => 'Hinzufügen';

  @override
  String get zakZadnaVozidla =>
      'Keine Fahrzeuge für diesen Kunden gespeichert.';

  @override
  String get zakBezSpz => 'Kein Kennzeichen';

  @override
  String get zakZadneZaznamy => 'Noch keine Serviceaufzeichnungen.';

  @override
  String zakZakazka(Object cislo) {
    return 'Auftrag $cislo';
  }

  @override
  String zakPoskozeni(String seznam) {
    return 'Schäden: $seznam';
  }

  @override
  String get zakPodepsano => 'Unterschrieben';

  @override
  String zakFotoKs(int pocet) {
    return '$pocet Fotos';
  }

  @override
  String get authBiometricReason => 'Bei Torkis anmelden';

  @override
  String get authBiometricChybaStorage =>
      'Melden Sie sich zuerst mit Ihrem Passwort an – Face ID wird beim nächsten Start aktiviert.';

  @override
  String get authBiometricChybaUdaje =>
      'Die gespeicherten Anmeldedaten sind ungültig. Bitte melden Sie sich mit Ihrem Passwort an.';

  @override
  String get authChybaPrazdnaPola => 'Bitte geben Sie E-Mail und Passwort ein.';

  @override
  String get authChybaHeslaNeshoda =>
      'Die eingegebenen Passwörter stimmen nicht überein.';

  @override
  String get authChybaOverovani =>
      'Bei der Authentifizierung ist ein Fehler aufgetreten.';

  @override
  String get authChybaNeplatneUdaje => 'Falsche E-Mail oder falsches Passwort.';

  @override
  String get authChybaEmailExistuje =>
      'Diese E-Mail-Adresse ist bereits registriert.';

  @override
  String get authChybaSlabeHeslo =>
      'Das Passwort ist zu schwach (mind. 6 Zeichen).';

  @override
  String get authChybaFormatEmail => 'Ungültiges E-Mail-Format.';

  @override
  String authChybaNeocekvana(String chyba) {
    return 'Unerwarteter Fehler: $chyba';
  }

  @override
  String get authResetHint =>
      'Geben Sie eine gültige E-Mail in das obere Feld ein, um Ihr Passwort zurückzusetzen.';

  @override
  String get authResetOdeslan =>
      'E-Mail zum Zurücksetzen des Passworts wurde gesendet.';

  @override
  String get authResetChyba =>
      'Fehler beim Senden der E-Mail zum Zurücksetzen.';

  @override
  String get authSubtitleLogin => 'Digitale Fahrzeugdokumentation';

  @override
  String get authSubtitleRegister => 'Registrieren Sie Ihre Werkstatt';

  @override
  String get authEmailHint => 'E-Mail';

  @override
  String get authHesloHint => 'Passwort';

  @override
  String get authPotvrzeniHeslaHint => 'Passwort bestätigen';

  @override
  String get authZapomenuteHeslo => 'Passwort vergessen?';

  @override
  String get authPrihlasitSe => 'Anmelden';

  @override
  String get authVytvoritUcet => 'Konto erstellen';

  @override
  String get authBiometrickePrihlaseni => 'Biometrisch anmelden';

  @override
  String get authNebo => 'oder';

  @override
  String get authGoogleBtn => 'Mit Google fortfahren';

  @override
  String get authAppleBtn => 'Mit Apple fortfahren';

  @override
  String get authNematUcet => 'Noch kein Konto?';

  @override
  String get authZaregistrujteSe => 'Registrieren';

  @override
  String get authMateUcet => 'Bereits ein Konto?';

  @override
  String get authPrihlasteSe => 'Anmelden';

  @override
  String predChybaNakup(String chyba) {
    return 'Kauf fehlgeschlagen: $chyba';
  }

  @override
  String get predChybaEmailKlient =>
      'E-Mail-Client konnte nicht geöffnet werden.';

  @override
  String get predTitle => 'Ihr Abonnement';

  @override
  String get predSubtitle =>
      'Verwalten Sie den Plan Ihrer Werkstatt und upgraden Sie ihn bei Bedarf.';

  @override
  String get predTrialBannerTitle => 'Aktive Testphase';

  @override
  String predAktivniPlanTitle(String plan) {
    return 'Aktiver Plan: $plan';
  }

  @override
  String get predTrialBannerSubtitle =>
      'Nach der Testphase wählen Sie den passenden Plan.';

  @override
  String get predAktivniPlanSubtitle =>
      'Vielen Dank, dass Sie TORKIS verwenden.';

  @override
  String get predMesicne => 'Monatlich';

  @override
  String get predRocne => 'Jährlich';

  @override
  String get predFootnote =>
      'Keine Bindung · Jederzeit kündbar · Preise zzgl. MwSt.';

  @override
  String get predBasicDesc => 'Für kleine Werkstätten und Einzelunternehmer.';

  @override
  String get predStandardDesc =>
      'Für mittlere Werkstätten mit bis zu 150 Aufträgen monatlich.';

  @override
  String get predProDesc =>
      'Für große Werkstätten und Netzwerke ohne Datensatzlimit.';

  @override
  String get predCustomDesc =>
      'Individuelle Anpassung für spezielle Anforderungen und Integrationen.';

  @override
  String get predFeat50Zaznamu => '50 Einträge/Monat';

  @override
  String get predFeat3Uziv => 'Max. 3 Benutzer';

  @override
  String get predFeat30Vin => '30 VIN-Dekodierungen/Monat';

  @override
  String get predFeat1TrzniHodnota => '1 Marktwertabfrage/Monat';

  @override
  String get predFeatNeomezStk => 'Unbegrenzte HU-Gültigkeitsprüfungen';

  @override
  String get predFeatFotodok => 'Fotodokumentation';

  @override
  String get predFeatEvidZak => 'Kunden- und Fahrzeugverwaltung';

  @override
  String get predFeatHistorie => 'Aufzeichnungsverlauf';

  @override
  String get predFeatSpravaTymu => 'Teamverwaltung';

  @override
  String get predFeat150Zaznamu => '150 Einträge/Monat';

  @override
  String get predFeat10Uziv => 'Max. 10 Benutzer';

  @override
  String get predFeat60Vin => '60 VIN-Dekodierungen/Monat';

  @override
  String get predFeat120Vin => '120 VIN-Dekodierungen/Monat';

  @override
  String get predFeat75Vin => '75 VIN-Dekodierungen/Monat';

  @override
  String get predFeat3TrzniHodnota => '3 Marktwertabfragen/Monat';

  @override
  String get predFeatVseBasic => 'Alles aus Basic';

  @override
  String get predFeatReporty => 'Berichte und Statistiken';

  @override
  String get predFeatChat => 'Kundenchat';

  @override
  String get predFeatWebPortal =>
      'Webportal für Fahrzeug- und Kundenverwaltung';

  @override
  String get predFeatNeomezZaznamu => 'Unbegrenzte Einträge';

  @override
  String get predFeatNeomezUziv => 'Unbegrenzte Benutzeranzahl';

  @override
  String get predFeatVseStandard => 'Alles aus Standard';

  @override
  String get predFeat150Vin => '150 VIN-Dekodierungen/Monat';

  @override
  String get predFeat5TrzniHodnota => '5 Marktwertabfragen/Monat';

  @override
  String get predFeatPrioritniPodpora => 'Prioritätssupport';

  @override
  String get predFeatPokrocileStatistiky => 'Erweiterte Statistiken';

  @override
  String get predFeatVicenasobinaVzd => 'Mehrere Standorte';

  @override
  String get predFeatErp => 'ERP/DMS-Integration';

  @override
  String get predFeatNeomezVin => 'Unbegrenzte VIN-Dekodierungen/Monat';

  @override
  String get predFeatNeomezTrzni => 'Unbegrenzte Fahrzeugmarktwerte';

  @override
  String get predFeatPrioritniSla => 'Prioritätssupport mit SLA';

  @override
  String get paywallTitle => 'Plan auswählen';

  @override
  String get paywallSubtitleTrialEnding =>
      'Ihre Testphase endet bald. Wählen Sie einen Plan, um fortzufahren.';

  @override
  String get paywallSubtitleTrialExpired =>
      'Ihre Testphase ist abgelaufen. Wählen Sie einen Plan, der zu Ihrer Werkstatt passt.';

  @override
  String paywallTrialZbyva(int n, String slovo) {
    return 'Noch $n $slovo der Testphase';
  }

  @override
  String get paywallBezpeci =>
      'Ihre Daten sind sicher. Wir stellen alles wieder her, sobald Sie einen Plan gewählt haben.';

  @override
  String get paywallZadnePredplatne => 'Kein aktives Abonnement gefunden.';

  @override
  String paywallChybaObnoveni(String chyba) {
    return 'Fehler beim Wiederherstellen: $chyba';
  }

  @override
  String get paywallObnovitNakupy => 'Käufe wiederherstellen';

  @override
  String get predPeriodMesic => 'monatlich';

  @override
  String get predPeriodRoc => 'jährlich';

  @override
  String get predCenaNaMiru => 'Individueller Preis';

  @override
  String get predDoporucujeme => 'EMPFOHLEN';

  @override
  String get predAktualniPlanPill => 'AKTUELLER PLAN';

  @override
  String get predAktualneAktivni => 'Aktuell aktiv';

  @override
  String get predMamZajem => 'Ich bin interessiert';

  @override
  String predVybrat(String name) {
    return '$name wählen';
  }

  @override
  String get paywallTrust1Title => '99,9 % Verfügbarkeit';

  @override
  String get paywallTrust1Sub => 'Garantierte Verfügbarkeits-SLA';

  @override
  String get paywallTrust2Title => 'Kostenloser Datenexport';

  @override
  String get paywallTrust2Sub => 'Ihre Daten gehören immer Ihnen';

  @override
  String get onbAresChybaIco =>
      'Bitte geben Sie eine gültige 8-stellige Unternehmens-ID ein.';

  @override
  String get onbAresNacteno => 'Unternehmensdaten aus dem Register geladen.';

  @override
  String get onbAresNenalezeno =>
      'Die eingegebene ID wurde im Register nicht gefunden.';

  @override
  String onbAresChyba(String chyba) {
    return 'Fehler bei der Kommunikation mit dem Register: $chyba';
  }

  @override
  String get onbBiometricReason =>
      'Bestätigen Sie Ihre Identität, um die biometrische Anmeldung zu aktivieren';

  @override
  String get onbDialogUpravitTyp => 'Typ bearbeiten';

  @override
  String get onbDialogNovyTyp => 'Neuer Auftragstyp';

  @override
  String get onbDialogNazevTypuHint => 'Typname (z.B. Service, Ankauf...)';

  @override
  String get onbZrusit => 'Abbrechen';

  @override
  String get onbUlozit => 'Speichern';

  @override
  String onbChybaUkladani(String chyba) {
    return 'Fehler beim Speichern: $chyba';
  }

  @override
  String get onbChybaNazev =>
      'Der Werkstattname ist für die Fortsetzung erforderlich.';

  @override
  String get onbDokoncit => 'EINRICHTUNG ABSCHLIESSEN';

  @override
  String get onbPokracovat => 'WEITER';

  @override
  String get onbKrok1Nadpis => 'Willkommen bei TORKIS!';

  @override
  String get onbKrok1Popis =>
      'Zuerst füllen wir einige grundlegende Informationen über Sie oder Ihr Unternehmen aus.';

  @override
  String get onbIcoLabel => 'Unternehmens-ID (Register-Suche)';

  @override
  String get onbIcoHint => 'z.B. 12345678';

  @override
  String get onbAresLoadTooltip => 'Aus Register laden';

  @override
  String get onbNazevLabel => 'Werkstattname / Vollständiger Name *';

  @override
  String get onbNazevHint => 'Namen eingeben...';

  @override
  String get onbDicLabel => 'USt-ID (optional)';

  @override
  String get onbDicHint => 'z.B. CZ12345678';

  @override
  String get onbRegistraceLabel => 'Handelsregistereintrag (optional)';

  @override
  String get onbRegistraceHint => 'z.B. eingetragen im Handelsregister...';

  @override
  String get onbSidloNadpis => 'Adresse & Kontakt';

  @override
  String get onbSidloPopis =>
      'Wird auf Angeboten, Rechnungen und in der Kommunikation verwendet.';

  @override
  String get onbUliceLabel => 'Straße & Hausnummer';

  @override
  String get onbUliceHint => 'z.B. Hauptstraße 123';

  @override
  String get onbMestoLabel => 'Stadt';

  @override
  String get onbMestoHint => 'z.B. Berlin';

  @override
  String get onbPscLabel => 'PLZ';

  @override
  String get onbTelefonLabel => 'Telefon der Werkstatt';

  @override
  String get onbTelefonHint => 'z.B. +49 151 123 456';

  @override
  String get onbKomunikaceNadpis => 'Kommunikation & Erscheinungsbild';

  @override
  String get onbEmailLabel =>
      'E-Mail-Adresse (von der E-Mails an Kunden versendet werden)';

  @override
  String get onbEmailHint => 'z.B. info@autowerkstatt.de';

  @override
  String get onbEmailySwitchTitle => 'E-Mails automatisch versenden';

  @override
  String get onbEmailySwitchSubtitle =>
      'Bei Angeboten und beim Abschluss wird die Option zum Versenden einer PDF per E-Mail vorangehakt.';

  @override
  String get onbAdminNadpis => 'Ihr Konto (Administrator)';

  @override
  String get onbAdminPopis =>
      'Geben Sie Ihren Namen ein — Sie werden als Hauptverantwortlicher der Werkstatt hinzugefügt.';

  @override
  String get onbJmenoLabel => 'Vollständiger Name *';

  @override
  String get onbJmenoHint => 'z.B. Max Mustermann';

  @override
  String get onbTmavyRezimTitle => 'Dunklen Modus erzwingen';

  @override
  String get onbTmavyRezimSubtitle =>
      'Die App wird sofort auf ein dunkles Erscheinungsbild umgestellt.';

  @override
  String get onbKrok2Nadpis => 'Betrieb & Automatisierung';

  @override
  String get onbKrok2Popis =>
      'Konfigurieren Sie das Verhalten bei der Fahrzeugannahme. Alles kann später in den Einstellungen geändert werden.';

  @override
  String get onbAutoCisloTitle => 'Auftragsnummer automatisch generieren';

  @override
  String get onbAutoCisloSubtitle =>
      'Die Auftragsnummer wird bei der Annahme automatisch vorausgefüllt. Deaktivieren für manuelle Eingabe.';

  @override
  String get onbPodpisTitle => 'Kundenunterschrift erforderlich';

  @override
  String get onbPodpisSubtitle =>
      'Bei Deaktivierung wird der Unterschriftsschritt ohne Unterschriftenfeld angezeigt.';

  @override
  String get onbSpzTitle => 'Kennzeichen erforderlich';

  @override
  String get onbSpzSubtitle =>
      'Bei Deaktivierung kann die Annahme auch ohne Kennzeichen abgeschlossen werden.';

  @override
  String get onbTypyNadpis => 'Auftragstypen';

  @override
  String get onbTypyPopis =>
      'Zur Klassifizierung der Fahrzeugannahme (z.B. Service, Ankauf). Der erste Typ ist Standard.';

  @override
  String get onbTypyVychozi => 'Standard';

  @override
  String get onbPridatTyp => 'Typ hinzufügen';

  @override
  String get onbTypyHint => 'Lang drücken = als Standard setzen.';

  @override
  String get onbVzoryNadpis => 'Vorlagen für Schadensbeschreibungen';

  @override
  String get onbVzoryPopis =>
      'Vordefinierte Beschreibungen, aus denen der Techniker beim Markieren von Schäden in der Fotodokumentation auswählt.';

  @override
  String get onbVzoryPrazdne =>
      'Noch keine Vorlagen. Fügen Sie die erste hinzu.';

  @override
  String get onbPridatVzor => 'Vorlage hinzufügen';

  @override
  String get onbDialogNovyVzor => 'Neue Schadensvorlage';

  @override
  String get onbDialogUpravitVzor => 'Vorlage bearbeiten';

  @override
  String get onbVzorHint => 'z. B. Kratzer, Delle…';

  @override
  String get onbOsobniNadpis => 'Persönliche Einstellungen';

  @override
  String get onbBiometrieTitle => 'Biometrische Anmeldung';

  @override
  String get onbBiometrieSubtitle => 'Face ID / Fingerabdruck bei jedem Start.';

  @override
  String get onbLevacTitle => 'Linkshänder-Modus';

  @override
  String get onbLevacSubtitle =>
      'Kameraauslöser links, wenn das Gerät im Querformat ist.';

  @override
  String get onbKrok3Nadpis => 'Häufige Leistungen';

  @override
  String get onbKrok3Popis =>
      'Wir haben eine Liste typischer Leistungen vorbereitet. Sie können diese bearbeiten, löschen oder weitere hinzufügen.';

  @override
  String get onbUkonNazevLabel => 'Leistungsname';

  @override
  String get onbUkonCenaLabel => 'Einzelpreis (CZK)';

  @override
  String get onbUkonCasLabel => 'Zeit';

  @override
  String get onbUkonHod => 'Std';

  @override
  String get onbUkonMin => 'Min';

  @override
  String get onbUkonCelkovaCenaLabel => 'Gesamtpreis (CZK)';

  @override
  String get onbUkonKategorieLabel => 'Kategorie';

  @override
  String get onbPridatUkon => 'Weitere Leistung hinzufügen';

  @override
  String get trialBadge => '30 TAGE KOSTENLOS';

  @override
  String get trialNadpis => 'Willkommen bei TORKIS';

  @override
  String get trialPopis =>
      'Wir haben Ihre 30-tägige kostenlose Testphase gestartet — keine Kreditkarte, keine Verpflichtungen.';

  @override
  String get trialBenefit1 => 'Unbegrenzte Fahrzeug- und Kundendatensätze';

  @override
  String get trialBenefit2 => '10 dekodierte VINs';

  @override
  String get trialBenefit3 => 'Unbegrenzte HU-Gültigkeitsprüfungen';

  @override
  String get trialBenefit4 => 'Vollständiger Zugriff auf alle App-Funktionen.';

  @override
  String get trialBenefit5 =>
      'Keine Zahlungsdaten. Keine automatischen Abbuchungen.';

  @override
  String get trialBenefit6 =>
      'Ihre Daten gehören immer Ihnen — kostenloser Export jederzeit.';

  @override
  String get trialBtn => 'App verwenden';

  @override
  String get mainNavNovy => 'Neu';

  @override
  String get mainNavMenu => 'Menü';

  @override
  String get mainNavVozidla => 'Fahrzeuge';

  @override
  String get mainNavUkony => 'Leistungen';

  @override
  String get mainNavZakaznici => 'Kunden';

  @override
  String get mainNavTym => 'Team';

  @override
  String get mainNavStatistiky => 'Statistiken';

  @override
  String get mainNavNastaveni => 'Einstellungen';

  @override
  String get mainNavPrijmy => 'Annahmen';

  @override
  String get mainNavVin => 'VIN';

  @override
  String get mainModVozidlaSubtitle => 'Fahrzeuge in der Werkstatt';

  @override
  String get mainModZakazniciSubtitle => 'Kontakte & Fuhrpark';

  @override
  String get mainModHistorieLabel => 'Auftragshistorie';

  @override
  String get mainModHistorieSubtitle => 'Auftragsarchiv';

  @override
  String get mainModUkonySubtitle => 'Preisliste der Leistungen';

  @override
  String get mainModVinLabel => 'VIN-Decoder';

  @override
  String get mainModVinSubtitle => 'Fahrzeugdaten aus VIN';

  @override
  String get mainModTymSubtitle => 'Techniker & Berechtigungen';

  @override
  String get mainModStatistikySubtitle => 'Berichte & Umsatz';

  @override
  String get mainModNastaveniSubtitle => 'Werkstatt, Rechnungen, Integrationen';

  @override
  String get mainModPredplatneLabel => 'Abonnement';

  @override
  String get mainModPredplatneSubtitle => 'Plan & Zahlungen';

  @override
  String get mainModWebLabel => 'Web';

  @override
  String get mainModWebSubtitle => 'Öffentliche Seite';

  @override
  String get mainModulyNadpis => 'Module';

  @override
  String get mainPrihlasenv => 'In Werkstatt angemeldet';

  @override
  String get mainOdhlasitSe => 'Abmelden';

  @override
  String get mainOdhlaseniTitle => 'Abmeldung';

  @override
  String get mainOdhlaseniContent => 'Möchten Sie sich wirklich abmelden?';

  @override
  String get mainZrusit => 'Abbrechen';

  @override
  String get mainOdhlasit => 'Abmelden';

  @override
  String get mainSvetlyRezim => 'Heller Modus';

  @override
  String get mainTmavyRezim => 'Dunkler Modus';

  @override
  String get histZpracovava => 'Wird verarbeitet...';

  @override
  String get histNadpis => 'Annahmehistorie';

  @override
  String get histPodnadpis =>
      'Übersicht aller angenommenen Fahrzeuge und ihrer Protokolle.';

  @override
  String get histHledat => 'Nach Kennzeichen, Kunde oder Fahrzeug suchen...';

  @override
  String histChyba(String chyba) {
    return 'Fehler: $chyba';
  }

  @override
  String get histPrazdne => 'Noch keine Einträge.';

  @override
  String get histNespecifikovano => 'Nicht angegeben';

  @override
  String get histPrijal => 'Angenommen von';

  @override
  String histFoto(int pocet) {
    return '$pocet Foto';
  }

  @override
  String get histPodepsano => 'Unterschrieben';

  @override
  String get histDetailNadpis => 'Annahmedetail';

  @override
  String histChybaTisku(String chyba) {
    return 'Druckfehler: $chyba';
  }

  @override
  String histChybaZobrazeni(String chyba) {
    return 'Anzeigefehler: $chyba';
  }

  @override
  String histProtokol(String cislo) {
    return 'Protokoll $cislo';
  }

  @override
  String get histZobrazitProtokol => 'Protokoll anzeigen';

  @override
  String get histTisknoutProtokol => 'Protokoll drucken';

  @override
  String get histTisknoutBtn => 'Drucken';

  @override
  String get histSekceVozidlo => 'Fahrzeug';

  @override
  String get histPoleSPZ => 'Kennzeichen';

  @override
  String get histPoleZnackaModel => 'Marke & Modell';

  @override
  String get histPoleVin => 'FIN';

  @override
  String get histPoleRokVyroby => 'Baujahr';

  @override
  String get histPolePalivo => 'Kraftstoff';

  @override
  String get histPolePrevodovka => 'Getriebe';

  @override
  String get histPoleMotorizace => 'Motor';

  @override
  String get histSekceZakaznik => 'Kunde';

  @override
  String get histPoleJmeno => 'Name';

  @override
  String get histPoleTelefon => 'Telefon';

  @override
  String get histPoleEmail => 'E-Mail';

  @override
  String get histPoleAdresa => 'Adresse';

  @override
  String get histPoleIco => 'Steuernummer';

  @override
  String get histPoleDic => 'USt-IdNr.';

  @override
  String get histSekceStav => 'Zustand bei Annahme';

  @override
  String get histPoleTachometr => 'Tachostand';

  @override
  String get histPoleNadrz => 'Tankstand';

  @override
  String get histPoleStk => 'HU';

  @override
  String get histPolePoskozeni => 'Schäden';

  @override
  String get histPolePneuLP => 'Reifen VL / VR';

  @override
  String get histPolePneuLZ => 'Reifen HL / HR';

  @override
  String get histSekcePozadavky => 'Kundenwünsche';

  @override
  String get histSekcePoznamky => 'Notizen';

  @override
  String get histSekceFoto => 'Fotodokumentation';

  @override
  String get histZadneFoto => 'Keine Fotos aufgenommen.';

  @override
  String get histSekcePodpis => 'Kundenunterschrift';

  @override
  String get histPodpisNedostupny => 'Unterschrift nicht verfügbar';

  @override
  String get nastUlozit => 'SPEICHERN';

  @override
  String get nastUlozeno => 'Einstellungen gespeichert.';

  @override
  String nastChyba(String chyba) {
    return 'Fehler: $chyba';
  }

  @override
  String get nastZrusit => 'Abbrechen';

  @override
  String get nastExportTitle => 'Datenexport';

  @override
  String get nastExportPopis =>
      'Datensätze im CSV- (Excel) oder JSON-Format herunterladen.';

  @override
  String get nastExportZakaznici => 'Kunden';

  @override
  String get nastExportVozidla => 'Fahrzeuge';

  @override
  String get nastExportZakazky => 'Annahmen / Aufträge';

  @override
  String get nastExportFormatTitle => 'Exportformat';

  @override
  String get nastExportFormatPopis => 'Dateiformat auswählen:';

  @override
  String get nastExportCsv => 'CSV (Excel)';

  @override
  String get fotoTitle => 'Fotodokumentation';

  @override
  String get fotoPodtitul =>
      'Machen Sie eine Fotoserie oder wählen Sie mehrere aus der Galerie.';

  @override
  String get fotoPridatGalerie => 'Aus Galerie hinzufügen';

  @override
  String get fotoSeriove => 'Serienaufnahme';

  @override
  String get fotoKatZvenku => 'Außenansicht (rund ums Fahrzeug)';

  @override
  String get fotoKatPoskozeni => 'Festgestellte Schäden';

  @override
  String get fotoKatDisky => 'Felgen und Räder';

  @override
  String get fotoKatStk => 'TÜV-Plakette';

  @override
  String get fotoKatInterier => 'Fahrzeuginnenraum';

  @override
  String get fotoKatTachometr => 'Tacho und Armaturenbrett';

  @override
  String get fotoKatVin => 'FIN-Code';

  @override
  String get fotoKatOstatni => 'Sonstige Dokumentation';

  @override
  String get anotTitle => 'Schadensmarkierung';

  @override
  String get anotZavritBezUlozeni => 'Ohne Speichern schließen';

  @override
  String get anotZrusitPosledni => 'Letztes rückgängig';

  @override
  String get anotSmazatVse => 'Alles löschen';

  @override
  String get anotUlozit => 'Speichern';

  @override
  String get anotChybaNacteni => 'Foto konnte nicht geladen werden.';

  @override
  String get anotVolnaKresba => 'Freihand';

  @override
  String get anotElipsa => 'Ellipse';

  @override
  String get anotObdelnik => 'Rechteck';

  @override
  String get anotSipka => 'Pfeil';

  @override
  String get anotPopisTitle => 'Schadensbeschreibung';

  @override
  String get anotVzory => 'Vorlagen:';

  @override
  String get anotVlastniPopis => 'Oder eigene Beschreibung eingeben…';

  @override
  String get anotZrusit => 'Abbrechen';

  @override
  String get anotZahodi => 'Verwerfen';

  @override
  String get anotNeulozenePomoc =>
      'Sie haben nicht gespeicherte Schadensmarkierungen. Speichern?';

  @override
  String get nastUlozitBtn => 'Speichern';

  @override
  String get nastZavrit => 'SCHLIEẞEN';

  @override
  String get nastHotovo => 'FERTIG';

  @override
  String get nastChecklistTitul => 'Annahme-Checkliste';

  @override
  String get nastChecklistPovolen => 'Checkliste bei der Annahme aktivieren';

  @override
  String get nastChecklistPovolenSub =>
      'Ein Checklisten-Panel wird bei der Annahme auf dem Tablet angezeigt';

  @override
  String get nastChecklistPrazdny => 'Noch keine Einträge';

  @override
  String get nastPridatChecklistPolozku => 'Eintrag hinzufügen';

  @override
  String get nastNovaChecklistPolozka => 'Neuer Eintrag';

  @override
  String get nastUpravitChecklistPolozku => 'Eintrag bearbeiten';

  @override
  String get nastChecklistPolozkaHint => 'Name des Checklisteneintrags';

  @override
  String get checklistPanelTitul => 'Checkliste';

  @override
  String get nastTitulAdmin => 'Firmeneinstellungen';

  @override
  String get nastTitulUzivatel => 'Mein Profil';

  @override
  String get nastPodtitulAdmin => 'Servicedaten und Preisliste verwalten.';

  @override
  String get nastPodtitulUzivatel => 'Grundeinstellungen Ihres Kontos.';

  @override
  String get nastFiremniUdaje => 'Firmendaten';

  @override
  String get nastObchodniJmeno => 'Firmenname / Servicename';

  @override
  String get nastIco => 'Steuernummer';

  @override
  String get nastDic => 'USt-IdNr.';

  @override
  String get nastRejstrik => 'Handelsregistereintrag';

  @override
  String get nastSidloKontakt => 'Adresse & Kontakt';

  @override
  String get nastUlice => 'Straße und Hausnummer';

  @override
  String get nastMesto => 'Stadt';

  @override
  String get nastPsc => 'PLZ';

  @override
  String get nastTelefon => 'Servicetelefon';

  @override
  String get nastEmail => 'E-Mail für Kommunikation';

  @override
  String get nastCislovani => 'Nummerierung & Automatisierung';

  @override
  String get nastFormatZakazek => 'Format der Auftragsnummer';

  @override
  String get nastAutoEmail => 'E-Mails automatisch senden';

  @override
  String get nastAutoEmailSub =>
      'Voreinstellt das Senden von PDF-Angeboten und Rechnungen.';

  @override
  String get nastAutoCislo => 'Auftragsnummer automatisch generieren';

  @override
  String get nastAutoCisloSub =>
      'Bei Fahrzeugannahme wird die Auftragsnummer automatisch ausgefüllt. Deaktivieren für manuelle Eingabe.';

  @override
  String get nastPodpisPovolen => 'Kundenunterschrift erforderlich';

  @override
  String get nastPodpisPovolenSub =>
      'Wenn deaktiviert, wird der Unterschriftsschritt ohne Unterschriftsfeld angezeigt.';

  @override
  String get nastSpzPovinne => 'Kennzeichen erforderlich';

  @override
  String get nastSpzPovinneSub =>
      'Wenn deaktiviert, kann die Annahme ohne Kennzeichen abgeschlossen werden.';

  @override
  String get nastSablony => 'Nachrichtenvorlagen';

  @override
  String get nastSablonyPopis =>
      'Voreingestellte Texte, die beim Schreiben einer Nachricht als Chips angezeigt werden.';

  @override
  String get nastSablonyPrazdne => 'Noch keine Vorlagen. Erste hinzufügen.';

  @override
  String get nastPridatSablonu => 'Vorlage hinzufügen';

  @override
  String get nastUpravitSablonu => 'Vorlage bearbeiten';

  @override
  String get nastNovaSablona => 'Neue Vorlage';

  @override
  String get nastSablonaHint => 'Nachrichtentext...';

  @override
  String get nastTypyZaznamu => 'Eintragstypen';

  @override
  String get nastTypyZaznamuPopis =>
      'Eintragstypen unterscheiden den Aufnahmetyp (z. B. Service, Ankauf). Der zuerst hinzugefügte Typ ist Standard.';

  @override
  String get nastVychozi => 'Standard';

  @override
  String get nastPridatTyp => 'Typ hinzufügen';

  @override
  String get nastUpravitTyp => 'Typ bearbeiten';

  @override
  String get nastNovyTyp => 'Neuer Eintragstyp';

  @override
  String get nastTypHint => 'Typname (z. B. Service, Ankauf...)';

  @override
  String get nastLongPress => 'Lang drücken = als Standard festlegen.';

  @override
  String get nastOsobni => 'Persönliche Einstellungen';

  @override
  String get nastPrizpusobitListu => 'Untere Leiste anpassen';

  @override
  String get nastPrizpusobitListuSub =>
      'Verknüpfungen hinzufügen oder Reihenfolge ändern.';

  @override
  String get nastListaPopis =>
      'Sie können 2 bis 5 aktive Tabs haben. Ziehen zum Neuanordnen.';

  @override
  String get nastMenuNelzeOdebrat => 'Menü kann nicht entfernt werden';

  @override
  String get nastVybrModul => 'Modul für Leiste auswählen';

  @override
  String get nastPridatZalozku => 'Weiteren Tab hinzufügen (max. 5)';

  @override
  String get nastTmavyRezim => 'Dunkelmodus erzwingen';

  @override
  String get nastTmavyRezimSub => 'App ist unabhängig vom System dunkel.';

  @override
  String get nastBiometrie => 'Biometrische Anmeldung';

  @override
  String get nastBiometrieSub => 'Face ID / Fingerabdruck bei jedem Start.';

  @override
  String get nastBiometricReason =>
      'Bestätigen Sie Ihre Identität zum Aktivieren der biometrischen Anmeldung';

  @override
  String get nastLeVaci => 'Linkshänder-Modus';

  @override
  String get nastLeVaciSub => 'Kameraauslöser links im Querformat.';

  @override
  String get nastUlozitDoZarizeniTitle => 'Fotos auch auf Gerät speichern';

  @override
  String get nastUlozitDoZarizeniSub =>
      'Beim Senden werden Annahmefotos auch in der Galerie dieses Geräts gespeichert.';

  @override
  String get nastJazyk => 'App-Sprache';

  @override
  String get nastSystJazyk => 'Systemsprache';

  @override
  String get nastModPrijem => 'Fahrzeugannahme';

  @override
  String get nastModHistorie => 'Annahmehistorie';

  @override
  String get nastModMenu => 'Menü (Weitere Module)';

  @override
  String get nastModVozidla => 'Fahrzeuge';

  @override
  String get nastModUkony => 'Aufgaben';

  @override
  String get nastModZakaznici => 'Kunden';

  @override
  String get nastModTym => 'Team & Rechte';

  @override
  String get nastModStatistiky => 'Statistiken';

  @override
  String get nastModNastaveni => 'Einstellungen';

  @override
  String get nastModVin => 'FIN-Decoder';

  @override
  String nastFormatTitle(String typ) {
    return 'Nummernformat für: $typ';
  }

  @override
  String get nastNahledLabel => 'Vorschau des zukünftigen Dokuments:';

  @override
  String nastInternaMaska(String maska) {
    return 'Interne Maske: $maska';
  }

  @override
  String get nastPrefix => 'Präfix (Kürzel)';

  @override
  String get nastOddelovac => 'Trennzeichen';

  @override
  String get nastOddelovacPomlcka => 'Bindestrich (-)';

  @override
  String get nastOddelovacLomitko => 'Schrägstrich (/)';

  @override
  String get nastOddelovacPodtrzitko => 'Unterstrich (_)';

  @override
  String get nastOddelovacBez => 'Kein Trennzeichen';

  @override
  String get nastRokFormat => 'Jahresformat';

  @override
  String get nastRok4 => '4 Ziffern (2026)';

  @override
  String get nastRok2 => '2 Ziffern (26)';

  @override
  String get nastBezRoku => 'Ohne Jahr';

  @override
  String get nastMesicFormat => 'Monatsformat';

  @override
  String get nastMesic2 => '2 Ziffern (04)';

  @override
  String get nastBezMesice => 'Ohne Monat';

  @override
  String nastDelkaCitadla(int n) {
    return 'Länge der laufenden Nummer: $n';
  }

  @override
  String get nastInfoZmenaFormatu =>
      'Wenn Sie das Format im Laufe des Jahres ändern, bleiben vorhandene Dokumente unverändert und die neue Reihe setzt ab der aktuellen Nummer fort.';

  @override
  String get nastUlozitFormat => 'FORMAT SPEICHERN';

  @override
  String get nastFormatUlozen => 'Nummerierungsformat erfolgreich gespeichert.';

  @override
  String get nastTrialVyprselo => 'Testzeitraum abgelaufen';

  @override
  String get nastTrialAktivni => 'Kostenloser Testzeitraum';

  @override
  String nastPlanNazev(String plan) {
    return 'Plan $plan';
  }

  @override
  String get nastTrialVyberPlan => 'Plan auswählen um fortzufahren';

  @override
  String nastTrialZbyva(int n, String slovo) {
    return 'Noch $n $slovo · kein Abonnement';
  }

  @override
  String nastPlatnostDo(String datum) {
    return 'Gültig bis $datum';
  }

  @override
  String get nastAktivni => 'Aktiv';

  @override
  String get nastVybratPlan => 'Plan auswählen';

  @override
  String get nastZobrazitPlany => 'Pläne anzeigen';

  @override
  String get nastDayJeden => 'Tag';

  @override
  String get nastDayNeco => 'Tage';

  @override
  String get nastDayMnogo => 'Tage';

  @override
  String get zamModZamestnanci => 'Mitarbeiter';

  @override
  String get zamModNastaveni => 'Einstellungen';

  @override
  String zamChyba(String chyba) {
    return 'Fehler: $chyba';
  }

  @override
  String get zamTitle => 'Team & Berechtigungen';

  @override
  String get zamSubtitle =>
      'Verwalten Sie die Mitglieder Ihrer Werkstatt und deren Zugriff auf die App.';

  @override
  String get zamPrazdny => 'Sie haben noch keine Teammitglieder.';

  @override
  String get zamPridatClena => 'Teammitglied hinzufügen';

  @override
  String get zamLimitTitle => 'Kontolimit erreicht';

  @override
  String zamLimitText(String plan, int limit, int pocet) {
    return 'Der Tarif $plan erlaubt maximal $limit Benutzerkonten. Sie nutzen derzeit $pocet/$limit. Um weitere Teammitglieder hinzuzufügen, führen Sie ein Upgrade durch.';
  }

  @override
  String get zamZrusit => 'Abbrechen';

  @override
  String get zamUpgradovat => 'Tarif upgraden';

  @override
  String get zamNovyClen => 'Neues Teammitglied';

  @override
  String get zamJmenoLabel => 'Vor- und Nachname *';

  @override
  String get zamEmailLabel => 'Anmelde-E-Mail *';

  @override
  String get zamHesloLabel => 'Anmeldepasswort (mind. 6 Zeichen) *';

  @override
  String get zamVychoziPrava => 'Standard-Zugriffsrechte';

  @override
  String get zamVytvoritUcet => 'Konto erstellen';

  @override
  String get zamErrVyplnte => 'Bitte Name, E-Mail und Passwort ausfüllen.';

  @override
  String get zamErrHesloKratke =>
      'Das Passwort muss mindestens 6 Zeichen lang sein.';

  @override
  String get zamUcetVytvoren => 'Konto erstellt.';

  @override
  String get zamErrOvereni => 'Authentifizierungsfehler.';

  @override
  String get zamErrHesloSlabe => 'Das eingegebene Passwort ist zu schwach.';

  @override
  String get zamErrEmailExistuje =>
      'Ein Konto mit dieser E-Mail existiert bereits.';

  @override
  String get zamErrEmailFormat => 'Ungültiges E-Mail-Format.';

  @override
  String zamErrNeocekavana(String chyba) {
    return 'Unerwarteter Fehler: $chyba';
  }

  @override
  String get zamPristupovaPrava => 'Zugriffsrechte';

  @override
  String get zamUlozitOpravneni => 'Berechtigungen speichern';

  @override
  String get zamUdelitVse => 'Alle gewähren';

  @override
  String get zamOdebratVse => 'Alle entziehen';

  @override
  String get zamOdstranit => 'Entfernen';

  @override
  String get zamOdstranitTitle => 'Teammitglied entfernen?';

  @override
  String zamOdstranitText(String jmeno) {
    return 'Möchten Sie $jmeno wirklich entfernen? Die Person verliert den Zugriff auf die App. Diese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String get zamClenOdstranen => 'Teammitglied entfernt.';

  @override
  String zamPocetUzivatelu(int pocet) {
    return '$pocet Benutzer';
  }

  @override
  String zamPocetLimit(int pocet, int limit) {
    return '$pocet / $limit Benutzer';
  }

  @override
  String zamPlanBezLimitu(String plan) {
    return 'Tarif $plan · unbegrenzt';
  }

  @override
  String zamPlanLimitDosazen(String plan) {
    return 'Tarif $plan · Limit erreicht';
  }

  @override
  String zamPlanZbyva(String plan, int zbyva) {
    return 'Tarif $plan · $zbyva übrig';
  }

  @override
  String get zamBezJmena => 'Kein Name';

  @override
  String get zamBezPrav => 'Keine erweiterten Rechte';

  @override
  String get zamBadgeAdmin => 'ADMIN';

  @override
  String get zamBadgeClen => 'MITGLIED';
}
