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
}
