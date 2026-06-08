// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'TORKIS';

  @override
  String get btnUlozit => 'Save';

  @override
  String get btnZrusit => 'Cancel';

  @override
  String get btnPotvrdit => 'Confirm';

  @override
  String get btnZavrit => 'Close';

  @override
  String get btnNovySken => 'New Scan';

  @override
  String get btnSpustitSken => 'Start Scan →';

  @override
  String get btnZacitPouzivat => 'Start using the app';

  @override
  String get btnPlany => 'Plans';

  @override
  String get nacitani => 'Loading…';

  @override
  String get chybaObecna => 'An error occurred.';

  @override
  String get zadejteVin => 'Please enter a VIN code.';

  @override
  String get zadejteVinRucne => 'Enter VIN manually (e.g. TMBJJ7NE5K…)';

  @override
  String get vinDekoderNav => 'VIN';

  @override
  String get vinDekoderTabDekodovani => 'VIN Decode';

  @override
  String get vinDekoderTabTrzniHodnota => 'Market Value';

  @override
  String get vinDekoderTabStk => 'MOT Check';

  @override
  String get vinDekoderTitle => 'VIN Decoder';

  @override
  String get vinDekoderSubtitle =>
      'Quick vehicle specification lookup by VIN code';

  @override
  String get trzniHodnotaTitle => 'Market Value';

  @override
  String get trzniHodnotaSubtitle =>
      'Estimated vehicle market price from European market data';

  @override
  String get stkTitle => 'MOT Check';

  @override
  String get stkSubtitle => 'Vehicle inspection record from the registry';

  @override
  String get skenVinKod => 'Scan VIN Code';

  @override
  String get skenVinProTrzni => 'Scan VIN for Market Value';

  @override
  String get skenVinProStk => 'Scan VIN for MOT';

  @override
  String get skenVinPopis =>
      'Automatically loads vehicle specifications from a scanned or entered VIN';

  @override
  String get skenVinTrzniPopis =>
      'Estimates vehicle market price from European market data based on scanned or entered VIN';

  @override
  String get skenVinStkPopis =>
      'Loads vehicle inspection records from the registry';

  @override
  String get dekodovat => 'Decode';

  @override
  String get zjstitHodnotu => 'Get Value';

  @override
  String get zjstitStk => 'Check MOT';

  @override
  String get stkPlatna => 'MOT Valid';

  @override
  String get stkNeplatna => 'MOT Expired';

  @override
  String stkPlatnaJeste(int dni) {
    return 'MOT valid for $dni more days';
  }

  @override
  String stkProsla(int dni) {
    return 'MOT expired $dni days ago';
  }

  @override
  String get stkDatumNeznamo => 'MOT — date unknown';

  @override
  String get stkPlatnostDo => 'MOT Valid Until';

  @override
  String get stkInfoBanner =>
      'Data comes from the public vehicle registry. Availability and accuracy may vary — MOT records may not be available for all vehicles.';

  @override
  String get trzniHodnotaTitle2 => 'MARKET VALUE';

  @override
  String get trzniMedian => 'median';

  @override
  String get trzniPrumernaCena => 'Average price';

  @override
  String get trzniPrumernyNajezd => 'Average mileage';

  @override
  String get trzniPocetVzorku => 'Sample count';

  @override
  String get trzniObdobiDat => 'Data period';

  @override
  String get trzniZdroj => 'European market · Vincario Market Value';

  @override
  String get trzniNeniData => 'European data not available.';

  @override
  String get historieNacitani => 'Loading…';

  @override
  String get historieSken => 'Scan History';

  @override
  String get historiePrvniDekodovani => 'Decoded for the first time';

  @override
  String get historieNeznameVozidlo => 'Unknown vehicle';

  @override
  String get historieZadneSken => 'No scans yet.';

  @override
  String get historieVse => 'All';

  @override
  String historieDnes(int pocet) {
    return 'Today · $pocet decoded VINs';
  }

  @override
  String get historiePosledniSkeny => 'Recent scans';

  @override
  String get historieNoveVozidlo => 'New vehicle';

  @override
  String historieDekodovanoXKrat(int pocet) {
    return 'Decoded $pocet×';
  }

  @override
  String get limitVyprsel =>
      'Monthly limit reached. Upgrade your plan to continue.';

  @override
  String get limitDekodovaniTitle => 'VIN decodes this month';

  @override
  String get limitTrzniTitle => 'Market value checks this month';

  @override
  String get upsellTrzniTitle => 'Market Value is available in paid plans';

  @override
  String get upsellTrzniText =>
      'Not available in the trial. Unlock it from the Basic plan.';

  @override
  String chybaDekodovani(String zprava) {
    return 'Failed to decode VIN: $zprava';
  }

  @override
  String get trialWelcomeTitle => 'Welcome to TORKIS';

  @override
  String get trialWelcomeSubtitle =>
      'We\'ve started your 30-day free trial — no credit card, no commitment.';

  @override
  String get trialWelcomePill => '30 DAYS FREE';

  @override
  String get trialWelcomeFooter =>
      'After the trial, choose the plan that fits you.';

  @override
  String get trialBenefitVozidla => 'Unlimited vehicle and customer records';

  @override
  String get trialBenefitVin => '10 decoded VINs';

  @override
  String get trialBenefitStk => 'Unlimited MOT validity checks';

  @override
  String get trialBenefitFunkce => 'Full access to all app features.';

  @override
  String get trialBenefitKarta => 'No payment details. No automatic charges.';

  @override
  String get trialBenefitData =>
      'Your data is always yours — export anytime for free.';

  @override
  String get vozidloStatTacho => 'ODOMETER';

  @override
  String get vozidloStatStkDo => 'MOT UNTIL';

  @override
  String get vozidloStatPrijmu => 'SERVICES';

  @override
  String get vozidloStkPlatna => 'MOT Valid';

  @override
  String get vozidloStkProsla => 'MOT Expired';

  @override
  String vozidloStkVyprsiBehemMesicu(String mesic, String rok, int pocet) {
    return 'Expires $mesic/$rok · $pocet months left';
  }

  @override
  String vozidloStkVyprsela(String mesic, String rok) {
    return 'Expired $mesic/$rok';
  }

  @override
  String get vozidloTechnickeUdaje => 'Technical Data';

  @override
  String get vozidloZnackaModel => 'Brand & Model';

  @override
  String get vozidloMotorizace => 'Engine';

  @override
  String get vozidloVin => 'VIN';

  @override
  String get vozidloRokVyroby => 'Year';

  @override
  String get vozidloPalivo => 'Fuel';

  @override
  String get vozidloPrevodovka => 'Transmission';

  @override
  String get vozidloBarva => 'Color';

  @override
  String get vozidloVykon => 'Power';

  @override
  String get vozidloPocetMistDveri => 'Seats / doors';

  @override
  String get vozidloRozmery => 'Dimensions';

  @override
  String get vozidloUdajeZVin => 'VIN data';

  @override
  String get vozidloTachometrLabel => 'Odometer';

  @override
  String get vozidloMajitel => 'Vehicle Owner';

  @override
  String get vozidloJmeno => 'Name';

  @override
  String get vozidloTelefon => 'Phone';

  @override
  String get vozidloEmail => 'E-mail';

  @override
  String get vozidloVolat => 'Call';

  @override
  String get vozidlaTitle => 'Vehicle Database';

  @override
  String get vozidlaSubtitle => 'Overview of all serviced vehicles.';

  @override
  String get vozidlaHledatHint => 'Search plate, brand or VIN...';

  @override
  String get vozidlaSkenSpzTooltip => 'Scan plate with camera';

  @override
  String get vozidlaZadnaVozidla => 'No vehicles in the database yet.';

  @override
  String get vozidlaNejstePrihlaseni => 'You are not logged in.';

  @override
  String get vozidlaSkenJenApp =>
      'Scanning is only available in the installed app (APK/iOS).';

  @override
  String get vozidloDetailUprava => 'Edit Vehicle';

  @override
  String get vozidloDetailSpz => 'Plate';

  @override
  String get vozidloDetailZnacka => 'Brand';

  @override
  String get vozidloDetailModel => 'Model';

  @override
  String get vozidloDetailTachoKm => 'Odometer (km)';

  @override
  String get vozidloDetailPlatnostStk => 'MOT Validity';

  @override
  String get vozidloDetailStkMesic => 'Month (MM)';

  @override
  String get vozidloDetailStkRok => 'Year (YYYY)';

  @override
  String get vozidloDetailUlozitZmeny => 'SAVE CHANGES';

  @override
  String get vozidloDetailSpzExistuje =>
      'A vehicle with this plate already exists!';

  @override
  String vozidloDetailPrejmenovano(String spz) {
    return 'Vehicle renamed to $spz. History was preserved.';
  }

  @override
  String get vozidloDetailNenalezeno => 'Vehicle not found.';

  @override
  String get vozidloDetailBezSpz => 'Vehicle without plate';

  @override
  String get vozidloDetailLabel => 'VEHICLE';

  @override
  String get vozidloTabInfo => 'Info';

  @override
  String get vozidloTabZaznamy => 'Records';

  @override
  String get vozidloSmazatAkce => 'Delete vehicle';

  @override
  String get vozidloSmazatDialogTitle => 'Delete vehicle?';

  @override
  String get vozidloSmazatDialogText =>
      'The vehicle will be removed from the directory. Service history will be preserved.';

  @override
  String get vozidloSmazano => 'Vehicle deleted.';

  @override
  String get vozidloSmazatBtn => 'Delete';

  @override
  String get prijemHelperTelefon => 'Phone number';

  @override
  String get prijemHelperPredvolba => 'Select country code';

  @override
  String get prijemStavTitle => 'Vehicle condition';

  @override
  String get prijemStavTacho => 'Odometer reading (km)';

  @override
  String prijemStavNadrz(int value) {
    return 'Fuel level ($value %)';
  }

  @override
  String get prijemStavPoskozeni => 'Damage found (multiple allowed)';

  @override
  String get prijemStavVlastniPopis => 'Custom damage description...';

  @override
  String get prijemStavPridat => 'Add custom damage';

  @override
  String get prijemStavPlatnostStk => 'MOT Validity';

  @override
  String get prijemStavMesic => 'Month';

  @override
  String get prijemStavRok => 'Year';

  @override
  String get prijemStavPneu => 'Tread depth (mm)';

  @override
  String get prijemStavLevaPreh => 'Front L.';

  @override
  String get prijemStavPravaPreh => 'Front R.';

  @override
  String get prijemStavLevaZad => 'Rear L.';

  @override
  String get prijemStavPravaZad => 'Rear R.';

  @override
  String get prijemStavPoznamky => 'Additional notes';

  @override
  String get prijemStavPoznamkyHint =>
      'Any additional details about the intake...';

  @override
  String get prijemZakaznikTitle => 'Customer details';

  @override
  String get prijemZakaznikJmeno => 'Full name / Company name';

  @override
  String get prijemZakaznikHledat => 'Search saved customers';

  @override
  String get prijemZakaznikIco => 'Company ID (registry search)';

  @override
  String get prijemZakaznikHledatAres => 'Search registry';

  @override
  String get prijemZakaznikPravniForma => 'Legal form';

  @override
  String get prijemZakaznikUlice => 'Street and number';

  @override
  String get prijemZakaznikMesto => 'City';

  @override
  String get prijemZakaznikPsc => 'Postal code';

  @override
  String get prijemZakaznikEmail => 'E-mail';

  @override
  String get prijemZakaznikFyzicka => 'Individual';

  @override
  String get prijemZakaznikOsvc => 'Self-employed';

  @override
  String get prijemVozidloTitle => 'Vehicle record';

  @override
  String get prijemVozidloNapoveda => 'Scan VIN or plate, or fill in manually.';

  @override
  String get prijemVozidloZeme => 'Country';

  @override
  String get prijemVozidloSpz => 'Licence plate';

  @override
  String get prijemVozidloHledatSpz => 'Search plate in database';

  @override
  String get prijemVozidloHledatSpzSub =>
      'Find a previously saved vehicle by plate';

  @override
  String get prijemVozidloVin => 'VIN code';

  @override
  String get prijemVozidloHledatVin => 'Search VIN in database';

  @override
  String get prijemVozidloHledatVinSub =>
      'Find a previously saved vehicle by VIN';

  @override
  String get prijemVozidloDekodovat => 'Decode VIN online';

  @override
  String get prijemVozidloDekodovatSub =>
      'Fill in brand, model, engine and MOT';

  @override
  String get prijemVozidloZnackaHint => 'Brand (e.g. Škoda)';

  @override
  String get prijemVozidloModelHint => 'Model (e.g. Octavia)';

  @override
  String get prijemVozidloSkenovat => 'Scan VIN/Plate';

  @override
  String get prijemVozidloSkenSub => 'Automatically detects code type';

  @override
  String get prijemVozidloRozlozeniPodSebou => 'Stacked';

  @override
  String get prijemVozidloRozlozeniVMrizce => 'Grid';

  @override
  String get prijemVozidloTypZaznamu => 'Record type';

  @override
  String get prijemVozidloCisloZaznamu => 'Record number';

  @override
  String get prijemVozidloGenerovat => 'Generate new number';

  @override
  String get prijemVozidloUlozenaVozidla => 'Customer\'s saved vehicles';

  @override
  String get prijemVozidloRokVyroby => 'Year of manufacture';

  @override
  String get prijemVozidloMotorizaceHint => 'Engine (e.g. 2.0 TDI)';

  @override
  String get prijemVozidloTypPaliva => 'Fuel type';

  @override
  String get prijemVozidloPrevodovka => 'Transmission';

  @override
  String get prijemVozidloTypKaroserie => 'Body type';

  @override
  String get prijemVozidloBenzin => 'Petrol';

  @override
  String get prijemVozidloNafta => 'Diesel';

  @override
  String get prijemVozidloElektro => 'Electric';

  @override
  String get prijemVozidloHybrid => 'Hybrid';

  @override
  String get prijemVozidloLpgCng => 'LPG/CNG';

  @override
  String get prijemVozidloJine => 'Other';

  @override
  String get prijemVozidloManualni => 'Manual';

  @override
  String get prijemVozidloAutomaticka => 'Automatic';

  @override
  String get prijemVozidloDalsiUdaje => 'Additional vehicle details';

  @override
  String get prijemVozidloDalsiUdajeSub =>
      'Optional – filled from the VIN decoder';

  @override
  String get prijemVozidloBarva => 'Color';

  @override
  String get prijemVozidloVykon => 'Power (kW)';

  @override
  String get prijemVozidloPocetMist => 'Number of seats';

  @override
  String get prijemVozidloPocetDveri => 'Number of doors';

  @override
  String get prijemVozidloRozmery => 'Dimensions (L × W × H mm)';

  @override
  String get prijemVozidloDelka => 'Length';

  @override
  String get prijemVozidloSirka => 'Width';

  @override
  String get prijemVozidloVyska => 'Height';

  @override
  String get prijemPraceTitle => 'Required work';

  @override
  String get prijemPracePozadavkyHint => 'What did we agree with the customer?';

  @override
  String get prijemPraceRychlyVyber => 'Quick selection of common jobs:';

  @override
  String get prijemPraceSeznam => 'Job list for the order:';

  @override
  String get prijemPracePridat => 'Add other job';

  @override
  String prijemPraceUkonN(int n) {
    return 'Job $n';
  }

  @override
  String get prijemPodpisTitle => 'Summary';

  @override
  String get prijemPodpisNeuvedeno => 'Not specified';

  @override
  String prijemPodpisZakaznik(String jmeno) {
    return 'Customer: $jmeno';
  }

  @override
  String prijemPodpisAdresa(String adresa) {
    return 'Address: $adresa';
  }

  @override
  String prijemPodpisVozidlo(String spzZnacka) {
    return 'Vehicle: $spzZnacka';
  }

  @override
  String get prijemPodpisSjednaneUkony => 'Agreed jobs:';

  @override
  String get prijemRekapZaznam => 'Record';

  @override
  String get prijemKonceptTitle => 'Unsent record';

  @override
  String get prijemKonceptText =>
      'You have an unsent record in progress. Do you want to continue where you left off?';

  @override
  String get prijemKonceptObnovit => 'Restore';

  @override
  String get prijemKonceptZahodit => 'Discard';

  @override
  String get prijemPodpisEmailToggle => 'Send copy of protocol by e-mail';

  @override
  String get prijemPodpisEmailChybi =>
      'No e-mail provided for this customer (step 2).';

  @override
  String prijemPodpisEmailKam(String email) {
    return 'Will be sent to: $email';
  }

  @override
  String get prijemPodpisSouhlas =>
      'By signing, the customer confirms the accuracy of the above information and accepts the vehicle condition at intake.';

  @override
  String get prijemPodpisSmazat => 'Clear signature';

  @override
  String get prijemPodpisVypnut =>
      'Customer signature is disabled in service settings.';

  @override
  String get prijemTabletPostup => 'PROGRESS';

  @override
  String get prijemTabletPosledniNavsteva => 'LAST VISIT';

  @override
  String get prijemTabletVozidlo => 'Vehicle';

  @override
  String get prijemTabletTacho => 'Odometer';

  @override
  String get prijemTabletStk => 'MOT';

  @override
  String get prijemTabletNaposledy => 'Last';

  @override
  String get prijemTabletStav => 'Condition';

  @override
  String get prijemTabletStavPriPrijmu => 'Condition at intake';

  @override
  String get prijemTabletPoskozeni => 'Damage';

  @override
  String get prijemTabletNeuvedeno => 'Not specified';

  @override
  String get prijemTabletNahled => 'VEHICLE PREVIEW';

  @override
  String get prijemTabletSpz => 'Plate';

  @override
  String get prijemTabletVin => 'VIN';

  @override
  String get prijemTabletZakazka => 'Order';

  @override
  String get prijemTabletUdajePlni =>
      'Data is filled in as you complete the form.';

  @override
  String get prijemErrVinVyhledani =>
      'Enter at least part of the VIN to search.';

  @override
  String get prijemErrServisId => 'Error: Service ID could not be loaded.';

  @override
  String get prijemErrZadneVozidloVin => 'No vehicle found with this VIN.';

  @override
  String get prijemErrSpzVyhledani =>
      'Enter at least part of the plate to search.';

  @override
  String get prijemErrZadneVozidloSpz => 'No vehicle found with this plate.';

  @override
  String get prijemErrZadejteVin => 'Enter a VIN code to decode.';

  @override
  String prijemStkPlatnaSnackbar(String datum) {
    return 'MOT valid until $datum';
  }

  @override
  String prijemStkProslaSnackbar(String datum) {
    return 'MOT expired! Was valid until $datum';
  }

  @override
  String get prijemVincarioDoplneno => 'Vehicle details filled from Vincario.';

  @override
  String get prijemVozidloNacteno => 'Vehicle and customer details loaded.';

  @override
  String get prijemNalezenoVice => 'Multiple vehicles found';

  @override
  String get prijemVyberVozidlo => 'Select a specific vehicle from the list:';

  @override
  String get prijemNeznanaSpz => 'Unknown plate';

  @override
  String get prijemErrCisloASpz => 'Record number and plate are required!';

  @override
  String get prijemErrCislo => 'Record number is required!';

  @override
  String get prijemErrSpz => 'Licence plate is required!';

  @override
  String get prijemErrCisloDuplicitni =>
      'This record number already exists in the database! Please enter a different one.';

  @override
  String get prijemErrPodpis => 'Customer must sign before submitting.';

  @override
  String get prijemLimitTitle => 'Intake limit reached';

  @override
  String prijemLimitText(String plan, int limit) {
    return 'Your $plan plan allows a maximum of $limit intakes per month. Upgrade your plan for more.';
  }

  @override
  String get prijemZavrit => 'Close';

  @override
  String get prijemUspesne => 'Order successfully submitted';

  @override
  String get prijemErrNejstePrirazeni => 'You are not assigned to any service!';

  @override
  String get prijemSkenJenApp =>
      'AI scanning is only available in the installed app (APK/iOS).';

  @override
  String get prijemNavigaceLabel => 'VEHICLE RECORD';

  @override
  String get prijemNovyZaznam => 'New record';

  @override
  String get prijemDokoncit => 'Complete and submit';

  @override
  String get prijemPokracovat => 'Continue';

  @override
  String get prijemOdesilamMsg => 'Submitting order and protocol...';

  @override
  String prijemKrokZ(int krok, int celkem) {
    return 'Step $krok of $celkem';
  }

  @override
  String get prijemStepIdentifikace => 'Vehicle ID';

  @override
  String get prijemStepZakaznik => 'Customer';

  @override
  String get prijemStepFoto => 'Photos';

  @override
  String get prijemStepStav => 'Condition';

  @override
  String get prijemStepPrace => 'Jobs';

  @override
  String get prijemStepSouhrn => 'Summary';

  @override
  String prijemSkenNenalezeno(String co) {
    return 'Scanned \'$co\'. Not found in database — fill in manually.';
  }

  @override
  String get vinSekceIdentifikace => 'IDENTIFICATION';

  @override
  String get vinSekceMotor => 'ENGINE & DRIVETRAIN';

  @override
  String get vinSekceKaroserie => 'BODY & DIMENSIONS';

  @override
  String get vinSekcePalivo => 'FUEL & EMISSIONS';

  @override
  String get vinSekceOstatni => 'OTHER INFO';

  @override
  String get vinFieldZnacka => 'Brand';

  @override
  String get vinFieldModel => 'Model';

  @override
  String get vinFieldObchodniOznaceni => 'Commercial name';

  @override
  String get vinFieldRokVyroby => 'Year';

  @override
  String get vinFieldKaroserie => 'Body';

  @override
  String get vinFieldTypVarianta => 'Trim / variant';

  @override
  String get vinFieldMistoVyroby => 'Place of manufacture';

  @override
  String get vinFieldMotorizace => 'Engine';

  @override
  String get vinFieldTypMotoru => 'Engine type';

  @override
  String get vinFieldZdvihObjem => 'Displacement';

  @override
  String get vinFieldPocetValcu => 'Cylinders';

  @override
  String get vinFieldVykon => 'Power';

  @override
  String get vinFieldTocivyMoment => 'Max. torque';

  @override
  String get vinFieldPalivo => 'Fuel';

  @override
  String get vinFieldPrevodovka => 'Transmission';

  @override
  String get vinFieldPocetPrevodu => 'Gears';

  @override
  String get vinFieldPohon => 'Drive';

  @override
  String get vinFieldMaxRychlost => 'Max. speed';

  @override
  String get vinFieldTypKaroserie => 'Body type';

  @override
  String get vinFieldPocetDveri => 'Doors';

  @override
  String get vinFieldPocetMist => 'Seats';

  @override
  String get vinFieldProvozniHmotnost => 'Kerb weight';

  @override
  String get vinFieldMaxHmotnost => 'Max. weight';

  @override
  String get vinFieldTaznaHmotnost => 'Towing capacity';

  @override
  String get vinFieldRozvorNaprav => 'Wheelbase';

  @override
  String get vinFieldDelka => 'Length';

  @override
  String get vinFieldSirka => 'Width';

  @override
  String get vinFieldVyska => 'Height';

  @override
  String get vinFieldObjemNadrze => 'Tank capacity';

  @override
  String get vinField1Registrace => '1st registration';

  @override
  String get vinFieldEmisniNorma => 'Emission standard';

  @override
  String get vinFieldEmiseCo2 => 'CO₂ emissions';

  @override
  String get vinFieldSpotrebaKomb => 'Consumption (comb.)';

  @override
  String get vinFieldSpotrebaMesto => 'City consumption';

  @override
  String get vinFieldSpotrebaDalnice => 'Highway consumption';

  @override
  String get vinFieldElektDojezd => 'Electric range';

  @override
  String vinLimitDekodovani(int pocet, int limit) {
    return 'You have reached the monthly limit of $pocet / $limit decodes. Upgrade your plan to continue.';
  }

  @override
  String vinLimitValue(int pocet, int limit) {
    return 'You have reached the monthly limit of $pocet / $limit checks.';
  }

  @override
  String get vinTrzniChybaVerze =>
      'Market value lookup is not included in the trial — unlock it in any paid plan.';

  @override
  String get vinChybaHistorie => 'Failed to load history.';

  @override
  String get vinTotoVozidloNebyloDekodovano =>
      'This vehicle has not been decoded before.';

  @override
  String get vinPraveTed => 'Just now';

  @override
  String vinPredMinutami(int pocet) {
    return '$pocet min ago';
  }

  @override
  String get vinVincarioKlice =>
      'Vincario API keys are not set. Add them in Service Settings to enable decoding.';

  @override
  String vinTrzniOd(String value, String mena) {
    return 'from $value $mena';
  }

  @override
  String vinTrzniDo(String value, String mena) {
    return 'to $value $mena';
  }

  @override
  String get vinTrzniHodnotaTitle => 'Market value';

  @override
  String get vinStkTitle => 'MOT check';

  @override
  String get vinTrzniSubtitle =>
      'Estimated market price of the vehicle from European market data';

  @override
  String get vinStkSubtitle =>
      'Overview of vehicle technical inspections from the register';

  @override
  String get vinSkenTitleVin => 'Scan VIN code';

  @override
  String get vinSkenTitleTrzni => 'Scan VIN for market value';

  @override
  String get vinSkenTitleStk => 'Scan VIN for MOT';

  @override
  String get vinSkenPopisVin =>
      'Automatically loads vehicle specifications from the scanned or entered VIN';

  @override
  String get vinSkenPopisTrzni =>
      'Estimates the market price of the vehicle from the scanned or entered VIN using European market data';

  @override
  String get vinSkenPopisStk =>
      'Loads vehicle technical inspection data from the register';

  @override
  String get vinSkenTlacitko => 'Start scan';

  @override
  String get vinInputHint => 'Enter VIN manually (e.g. TMBJJ7NE5K…)';

  @override
  String get vinTooltipHodnota => 'Get value';

  @override
  String get vinTooltipStk => 'Get MOT';

  @override
  String get vinTooltipDekodovat => 'Decode';

  @override
  String get vinUpsellTitle => 'Market value is a paid feature';

  @override
  String get vinUpsellSubtitle =>
      'Not available in the trial version. Unlock it in the Basic plan.';

  @override
  String get vinUpsellPlany => 'Plans';

  @override
  String get vinLimitTrzniMesic => 'Market value this month';

  @override
  String get vinLimitDekodovaniMesic => 'VIN decoding this month';

  @override
  String get vinLimitVycerpan =>
      'Monthly limit reached. Upgrade your plan to continue.';

  @override
  String get vinStkInfoBanner =>
      'Data comes from the public vehicle register. Availability and accuracy may vary — MOT data may not be recorded for some vehicles.';

  @override
  String vinChybaDekodovani(String chyba) {
    return 'Failed to decode VIN: $chyba';
  }

  @override
  String get vinNovySken => 'New scan';

  @override
  String get vinTrzniHodnotaHeader => 'MARKET VALUE';

  @override
  String get vinStkPlatnostNeznama => 'MOT — date unknown';

  @override
  String vinStkPlatnaJesteXDni(int dnu) {
    return 'MOT valid for $dnu more days';
  }

  @override
  String vinStkNeplatna(int dnu) {
    return 'MOT expired ($dnu days ago)';
  }

  @override
  String get vinStkPlatnostDo => 'MOT valid until';

  @override
  String get vinTrzniDataNedostupna => 'European data not available.';

  @override
  String get vinTrzniMedian => 'median';

  @override
  String get vinTrzniPrumernaCena => 'Average price';

  @override
  String get vinTrzniPrumernyNajezd => 'Average mileage';

  @override
  String get vinTrzniPocetVzorku => 'Sample count';

  @override
  String get vinTrzniObdobiDat => 'Data period';

  @override
  String get vinTrzniZdroj => 'European market · Vincario Market Value';

  @override
  String get vinTrzniNajezdLabel => 'Vehicle mileage (km)';

  @override
  String get vinTrzniOdhad => 'Estimate by mileage';

  @override
  String get vinTrzniOdhadVysvetleni =>
      'Approximate residual value estimated from the sample\'s price and mileage range.';

  @override
  String get vinHistorieNadpis => 'Scan history';

  @override
  String vinHistorieDnes(int pocet) {
    return 'Today · $pocet VINs decoded';
  }

  @override
  String get vinHistoriePosledni => 'Recent scans';

  @override
  String get vinHistorieVse => 'All';

  @override
  String get vinHistorieNacitani => 'Loading…';

  @override
  String get vinHistorieZadneSkeny => 'No scans yet.';

  @override
  String get vinHistorieNoveVozidlo => 'New vehicle';

  @override
  String get vinHistoriePoprve => 'First decoded';

  @override
  String vinHistorieDekodovanoX(int pocet) {
    return 'Decoded $pocet×';
  }

  @override
  String get vinHistorieNezname => 'Unknown vehicle';

  @override
  String get vinZadejteVin => 'Enter a VIN code.';

  @override
  String get vinSkenJenApk =>
      'Scanning only works in the installed app (APK/iOS).';

  @override
  String get vinFieldKodMotoru => 'Engine code';

  @override
  String get zakZakaznici => 'Customers';

  @override
  String get zakSubtitle => 'Directory of your clients and their vehicles.';

  @override
  String get zakHledatHint => 'Search by name, phone or company ID...';

  @override
  String zakChybaDb(String chyba) {
    return 'Database error: $chyba';
  }

  @override
  String get zakZadniZakaznici => 'No customers yet.';

  @override
  String zakIcoZnak(String ico) {
    return '🏢 Reg: $ico';
  }

  @override
  String get zakEditTitle => 'Edit customer';

  @override
  String get zakJmenoLabel => 'First and Last Name / Company name';

  @override
  String get zakTelLabel => 'Phone';

  @override
  String get zakVybertePredvolbu => 'Select country code';

  @override
  String get zakCisloLabel => 'Number';

  @override
  String get zakEmailLabel => 'E-mail';

  @override
  String get zakAdresaLabel => 'Address';

  @override
  String get zakIcoLabel => 'Reg. No.';

  @override
  String get zakDicLabel => 'VAT No.';

  @override
  String get zakUlozitZmeny => 'SAVE CHANGES';

  @override
  String get zakZpracovavam => 'Loading data...';

  @override
  String get zakKartaZakaznika => 'Customer card';

  @override
  String get zakHeaderLabel => 'CUSTOMER';

  @override
  String get zakTabInfo => 'Info';

  @override
  String get zakTabZaznamy => 'Records';

  @override
  String get zakSmazatMenu => 'Delete customer';

  @override
  String get zakSmazatTitle => 'Delete customer?';

  @override
  String get zakSmazatContent =>
      'The customer will be removed from the directory. Their vehicles and job history will be preserved.';

  @override
  String get zakZrusit => 'Cancel';

  @override
  String get zakSmazatPotvrdit => 'Delete';

  @override
  String get zakSmazanUspesne => 'Customer deleted.';

  @override
  String zakChybaMazani(String chyba) {
    return 'Delete error: $chyba';
  }

  @override
  String get zakNeznamyZakaznik => 'Unknown customer';

  @override
  String get zakFirma => 'Company';

  @override
  String get zakSoukromaOsoba => 'Individual';

  @override
  String get zakStatVozidel => 'VEHICLES';

  @override
  String get zakStatPrijmu => 'JOBS';

  @override
  String get zakVolat => 'Call';

  @override
  String get zakSms => 'SMS';

  @override
  String get zakKontaktniUdaje => 'Contact details';

  @override
  String get zakVozidlaTitle => 'Customer vehicles';

  @override
  String get zakPridat => 'Add';

  @override
  String get zakZadnaVozidla => 'No vehicles saved for this customer.';

  @override
  String get zakBezSpz => 'No plate';

  @override
  String get zakZadneZaznamy => 'No service records yet.';

  @override
  String zakZakazka(Object cislo) {
    return 'Job $cislo';
  }

  @override
  String zakPoskozeni(String seznam) {
    return 'Damage: $seznam';
  }

  @override
  String get zakPodepsano => 'Signed';

  @override
  String zakFotoKs(int pocet) {
    return '$pocet photos';
  }

  @override
  String get authBiometricReason => 'Sign in to Torkis';

  @override
  String get authBiometricChybaStorage =>
      'Sign in with your password first — Face ID will be enabled for the next launch.';

  @override
  String get authBiometricChybaUdaje =>
      'Saved credentials are invalid. Please sign in with your password.';

  @override
  String get authChybaPrazdnaPola => 'Please enter your email and password.';

  @override
  String get authChybaHeslaNeshoda => 'Passwords do not match.';

  @override
  String get authChybaOverovani => 'An authentication error occurred.';

  @override
  String get authChybaNeplatneUdaje => 'Incorrect email or password.';

  @override
  String get authChybaEmailExistuje => 'This email is already registered.';

  @override
  String get authChybaSlabeHeslo => 'Password is too weak (min. 6 characters).';

  @override
  String get authChybaFormatEmail => 'Invalid email format.';

  @override
  String authChybaNeocekvana(String chyba) {
    return 'Unexpected error: $chyba';
  }

  @override
  String get authResetHint =>
      'Enter a valid email in the field above to reset your password.';

  @override
  String get authResetOdeslan => 'Password reset email has been sent.';

  @override
  String get authResetChyba => 'Error sending password reset email.';

  @override
  String get authSubtitleLogin => 'Digital vehicle evidence';

  @override
  String get authSubtitleRegister => 'Register your garage';

  @override
  String get authEmailHint => 'Email';

  @override
  String get authHesloHint => 'Password';

  @override
  String get authPotvrzeniHeslaHint => 'Confirm password';

  @override
  String get authZapomenuteHeslo => 'Forgot your password?';

  @override
  String get authPrihlasitSe => 'Sign in';

  @override
  String get authVytvoritUcet => 'Create account';

  @override
  String get authBiometrickePrihlaseni => 'Sign in with biometrics';

  @override
  String get authNebo => 'or';

  @override
  String get authGoogleBtn => 'Continue with Google';

  @override
  String get authAppleBtn => 'Continue with Apple';

  @override
  String get authNematUcet => 'Don\'t have an account?';

  @override
  String get authZaregistrujteSe => 'Sign up';

  @override
  String get authMateUcet => 'Already have an account?';

  @override
  String get authPrihlasteSe => 'Sign in';

  @override
  String predChybaNakup(String chyba) {
    return 'Purchase failed: $chyba';
  }

  @override
  String get predChybaEmailKlient => 'Could not open email client.';

  @override
  String get predTitle => 'Your subscription';

  @override
  String get predSubtitle => 'Manage your garage plan and upgrade as needed.';

  @override
  String get predTrialBannerTitle => 'Active trial period';

  @override
  String predAktivniPlanTitle(String plan) {
    return 'Active plan: $plan';
  }

  @override
  String get predTrialBannerSubtitle =>
      'After the trial, choose the plan that suits you.';

  @override
  String get predAktivniPlanSubtitle => 'Thank you for using TORKIS.';

  @override
  String get predMesicne => 'Monthly';

  @override
  String get predRocne => 'Yearly';

  @override
  String get predFootnote =>
      'No commitment · Cancel anytime · Prices excl. VAT';

  @override
  String get predBasicDesc => 'For small garages and sole traders.';

  @override
  String get predStandardDesc =>
      'For medium garages with up to 150 orders per month.';

  @override
  String get predProDesc =>
      'For large garages and networks with unlimited records.';

  @override
  String get predCustomDesc =>
      'Custom setup for special requirements and integrations.';

  @override
  String get predFeat50Zaznamu => '50 records/month';

  @override
  String get predFeat3Uziv => '3 users max.';

  @override
  String get predFeat30Vin => '30 VIN decodings/month';

  @override
  String get predFeat1TrzniHodnota => '1 market value lookup/month';

  @override
  String get predFeatNeomezStk => 'Unlimited MOT validity checks';

  @override
  String get predFeatFotodok => 'Photo documentation';

  @override
  String get predFeatEvidZak => 'Customer and vehicle records';

  @override
  String get predFeatHistorie => 'Record history';

  @override
  String get predFeatSpravaTymu => 'Team management';

  @override
  String get predFeat150Zaznamu => '150 records/month';

  @override
  String get predFeat10Uziv => '10 users max.';

  @override
  String get predFeat60Vin => '60 VIN decodings/month';

  @override
  String get predFeat120Vin => '120 VIN decodings/month';

  @override
  String get predFeat75Vin => '75 VIN decodings/month';

  @override
  String get predFeat3TrzniHodnota => '3 market value lookups/month';

  @override
  String get predFeatVseBasic => 'All Basic features';

  @override
  String get predFeatReporty => 'Reports and statistics';

  @override
  String get predFeatChat => 'Customer chat';

  @override
  String get predFeatWebPortal =>
      'Web portal for vehicle and customer management';

  @override
  String get predFeatNeomezZaznamu => 'Unlimited records';

  @override
  String get predFeatNeomezUziv => 'Unlimited users';

  @override
  String get predFeatVseStandard => 'All Standard features';

  @override
  String get predFeat150Vin => '150 VIN decodings/month';

  @override
  String get predFeat5TrzniHodnota => '5 market value lookups/month';

  @override
  String get predFeatPrioritniPodpora => 'Priority support';

  @override
  String get predFeatPokrocileStatistiky => 'Advanced statistics';

  @override
  String get predFeatVicenasobinaVzd => 'Multiple locations';

  @override
  String get predFeatErp => 'ERP/DMS integration';

  @override
  String get predFeatNeomezVin => 'Unlimited VIN decodings/month';

  @override
  String get predFeatNeomezTrzni => 'Unlimited vehicle market values';

  @override
  String get predFeatPrioritniSla => 'Priority support with SLA';

  @override
  String get paywallTitle => 'Choose a plan';

  @override
  String get paywallSubtitleTrialEnding =>
      'Your trial is ending soon. Choose a plan to continue.';

  @override
  String get paywallSubtitleTrialExpired =>
      'Your trial has ended. Choose a plan that suits your garage.';

  @override
  String paywallTrialZbyva(int n, String slovo) {
    return '$n $slovo of trial remaining';
  }

  @override
  String get paywallBezpeci =>
      'Your data is safe. We\'ll restore everything once you choose a plan.';

  @override
  String get paywallZadnePredplatne => 'No active subscription found.';

  @override
  String paywallChybaObnoveni(String chyba) {
    return 'Restore error: $chyba';
  }

  @override
  String get paywallObnovitNakupy => 'Restore purchases';

  @override
  String get predPeriodMesic => 'monthly';

  @override
  String get predPeriodRoc => 'yearly';

  @override
  String get predCenaNaMiru => 'Custom pricing';

  @override
  String get predDoporucujeme => 'RECOMMENDED';

  @override
  String get predAktualniPlanPill => 'CURRENT PLAN';

  @override
  String get predAktualneAktivni => 'Currently active';

  @override
  String get predMamZajem => 'I\'m interested';

  @override
  String predVybrat(String name) {
    return 'Choose $name';
  }

  @override
  String get paywallTrust1Title => '99.9% uptime';

  @override
  String get paywallTrust1Sub => 'Guaranteed uptime SLA';

  @override
  String get paywallTrust2Title => 'Free data export';

  @override
  String get paywallTrust2Sub => 'Your data is always yours';

  @override
  String get onbAresChybaIco => 'Please enter a valid 8-digit company ID.';

  @override
  String get onbAresNacteno => 'Company data loaded from registry.';

  @override
  String get onbAresNenalezeno =>
      'The entered ID was not found in the registry.';

  @override
  String onbAresChyba(String chyba) {
    return 'Error communicating with registry: $chyba';
  }

  @override
  String get onbBiometricReason =>
      'Confirm your identity to enable biometric login';

  @override
  String get onbDialogUpravitTyp => 'Edit type';

  @override
  String get onbDialogNovyTyp => 'New record type';

  @override
  String get onbDialogNazevTypuHint => 'Type name (e.g. Service, Purchase...)';

  @override
  String get onbZrusit => 'Cancel';

  @override
  String get onbUlozit => 'Save';

  @override
  String onbChybaUkladani(String chyba) {
    return 'Error saving data: $chyba';
  }

  @override
  String get onbChybaNazev => 'Garage name is required to continue.';

  @override
  String get onbDokoncit => 'COMPLETE SETUP';

  @override
  String get onbPokracovat => 'CONTINUE';

  @override
  String get onbKrok1Nadpis => 'Welcome to TORKIS!';

  @override
  String get onbKrok1Popis =>
      'First, let\'s fill in some basic information about you or your company.';

  @override
  String get onbIcoLabel => 'Company ID (registry lookup)';

  @override
  String get onbIcoHint => 'e.g. 12345678';

  @override
  String get onbAresLoadTooltip => 'Load from registry';

  @override
  String get onbNazevLabel => 'Garage name / Full name *';

  @override
  String get onbNazevHint => 'Enter name...';

  @override
  String get onbDicLabel => 'VAT number (optional)';

  @override
  String get onbDicHint => 'e.g. CZ12345678';

  @override
  String get onbRegistraceLabel => 'Trade register entry (optional)';

  @override
  String get onbRegistraceHint => 'e.g. registered in trade register...';

  @override
  String get onbSidloNadpis => 'Address & contact';

  @override
  String get onbSidloPopis => 'Used on quotes, invoices and in communications.';

  @override
  String get onbUliceLabel => 'Street & number';

  @override
  String get onbUliceHint => 'e.g. Main St 123';

  @override
  String get onbMestoLabel => 'City';

  @override
  String get onbMestoHint => 'e.g. Prague';

  @override
  String get onbPscLabel => 'ZIP';

  @override
  String get onbTelefonLabel => 'Garage phone';

  @override
  String get onbTelefonHint => 'e.g. +420 777 123 456';

  @override
  String get onbKomunikaceNadpis => 'Communication & appearance';

  @override
  String get onbEmailLabel =>
      'Email address (used to send emails to customers)';

  @override
  String get onbEmailHint => 'e.g. info@autogarage.com';

  @override
  String get onbEmailySwitchTitle => 'Automatically send emails';

  @override
  String get onbEmailySwitchSubtitle =>
      'On quotes and at handover, the option to send a PDF by email will be pre-checked.';

  @override
  String get onbAdminNadpis => 'Your account (administrator)';

  @override
  String get onbAdminPopis =>
      'Enter your name — you will be added as the primary manager of the garage.';

  @override
  String get onbJmenoLabel => 'Full name *';

  @override
  String get onbJmenoHint => 'e.g. John Smith';

  @override
  String get onbTmavyRezimTitle => 'Force dark mode';

  @override
  String get onbTmavyRezimSubtitle =>
      'The app will immediately switch to a dark appearance.';

  @override
  String get onbKrok2Nadpis => 'Operations & automation';

  @override
  String get onbKrok2Popis =>
      'Configure vehicle intake behaviour. Everything can be changed later in Settings.';

  @override
  String get onbAutoCisloTitle => 'Auto-generate job number';

  @override
  String get onbAutoCisloSubtitle =>
      'The job number will be pre-filled automatically at intake. Disable to allow manual entry.';

  @override
  String get onbPodpisTitle => 'Require customer signature';

  @override
  String get onbPodpisSubtitle =>
      'When disabled, the signature step will appear without the signature canvas.';

  @override
  String get onbSpzTitle => 'Require licence plate';

  @override
  String get onbSpzSubtitle =>
      'When disabled, intake can be submitted without a licence plate (e.g. unregistered vehicles).';

  @override
  String get onbTypyNadpis => 'Record types';

  @override
  String get onbTypyPopis =>
      'Used to classify vehicle intake (e.g. Service, Purchase). The first type is default.';

  @override
  String get onbTypyVychozi => 'default';

  @override
  String get onbPridatTyp => 'Add type';

  @override
  String get onbTypyHint => 'Long press = set as default.';

  @override
  String get onbOsobniNadpis => 'Personal settings';

  @override
  String get onbBiometrieTitle => 'Biometric login';

  @override
  String get onbBiometrieSubtitle => 'Face ID / fingerprint at every launch.';

  @override
  String get onbLevacTitle => 'Left-handed mode';

  @override
  String get onbLevacSubtitle =>
      'Camera shutter on the left when the device is in landscape.';

  @override
  String get onbKrok3Nadpis => 'Common operations';

  @override
  String get onbKrok3Popis =>
      'We\'ve prepared a list of typical operations. You can freely edit, delete or add more. They\'ll be offered for quick selection during intake.';

  @override
  String get onbUkonNazevLabel => 'Operation name';

  @override
  String get onbUkonCenaLabel => 'Unit price (CZK)';

  @override
  String get onbUkonCasLabel => 'Time';

  @override
  String get onbUkonHod => 'hr';

  @override
  String get onbUkonMin => 'min';

  @override
  String get onbUkonCelkovaCenaLabel => 'Total price (CZK)';

  @override
  String get onbUkonKategorieLabel => 'Category';

  @override
  String get onbPridatUkon => 'Add another operation';

  @override
  String get trialBadge => '30 DAYS FREE';

  @override
  String get trialNadpis => 'Welcome to TORKIS';

  @override
  String get trialPopis =>
      'We\'ve started your 30-day free trial — no credit card, no commitment.';

  @override
  String get trialBenefit1 => 'Unlimited vehicle and customer records';

  @override
  String get trialBenefit2 => '10 decoded VINs';

  @override
  String get trialBenefit3 => 'Unlimited MOT validity checks';

  @override
  String get trialBenefit4 => 'Full access to all app features.';

  @override
  String get trialBenefit5 => 'No payment details. No automatic charges.';

  @override
  String get trialBenefit6 =>
      'Your data is always yours — free export anytime.';

  @override
  String get trialBtn => 'Start using the app';

  @override
  String get mainNavNovy => 'New';

  @override
  String get mainNavMenu => 'Menu';

  @override
  String get mainNavVozidla => 'Vehicles';

  @override
  String get mainNavUkony => 'Operations';

  @override
  String get mainNavZakaznici => 'Customers';

  @override
  String get mainNavTym => 'Team';

  @override
  String get mainNavStatistiky => 'Statistics';

  @override
  String get mainNavNastaveni => 'Settings';

  @override
  String get mainNavPrijmy => 'Intakes';

  @override
  String get mainNavVin => 'VIN';

  @override
  String get mainModVozidlaSubtitle => 'Vehicles in service';

  @override
  String get mainModZakazniciSubtitle => 'Contacts & vehicle fleet';

  @override
  String get mainModHistorieLabel => 'Record history';

  @override
  String get mainModHistorieSubtitle => 'Job archive';

  @override
  String get mainModUkonySubtitle => 'Price list of services';

  @override
  String get mainModVinLabel => 'VIN decoder';

  @override
  String get mainModVinSubtitle => 'Vehicle data from VIN';

  @override
  String get mainModTymSubtitle => 'Technicians & permissions';

  @override
  String get mainModStatistikySubtitle => 'Reports & revenue';

  @override
  String get mainModNastaveniSubtitle => 'Service, invoices, integrations';

  @override
  String get mainModPredplatneLabel => 'Subscription';

  @override
  String get mainModPredplatneSubtitle => 'Plan & payments';

  @override
  String get mainModWebLabel => 'Web';

  @override
  String get mainModWebSubtitle => 'Public page';

  @override
  String get mainModulyNadpis => 'Modules';

  @override
  String get mainPrihlasenv => 'Logged in to service';

  @override
  String get mainOdhlasitSe => 'Log out';

  @override
  String get mainOdhlaseniTitle => 'Log out';

  @override
  String get mainOdhlaseniContent => 'Are you sure you want to log out?';

  @override
  String get mainZrusit => 'Cancel';

  @override
  String get mainOdhlasit => 'Log out';

  @override
  String get mainSvetlyRezim => 'Light mode';

  @override
  String get mainTmavyRezim => 'Dark mode';

  @override
  String get histZpracovava => 'Processing...';

  @override
  String get histNadpis => 'Service history';

  @override
  String get histPodnadpis =>
      'Overview of all received vehicles and their records.';

  @override
  String get histHledat => 'Search by plate, customer or vehicle...';

  @override
  String histChyba(String chyba) {
    return 'Error: $chyba';
  }

  @override
  String get histPrazdne => 'No records yet.';

  @override
  String get histNespecifikovano => 'Unspecified';

  @override
  String get histPrijal => 'Received by';

  @override
  String histFoto(int pocet) {
    return '$pocet photo';
  }

  @override
  String get histPodepsano => 'Signed';

  @override
  String get histDetailNadpis => 'Intake detail';

  @override
  String histChybaTisku(String chyba) {
    return 'Print error: $chyba';
  }

  @override
  String histChybaZobrazeni(String chyba) {
    return 'Display error: $chyba';
  }

  @override
  String histProtokol(String cislo) {
    return 'Record $cislo';
  }

  @override
  String get histZobrazitProtokol => 'View record';

  @override
  String get histTisknoutProtokol => 'Print record';

  @override
  String get histTisknoutBtn => 'Print';

  @override
  String get histSekceVozidlo => 'Vehicle';

  @override
  String get histPoleSPZ => 'Plate';

  @override
  String get histPoleZnackaModel => 'Make & Model';

  @override
  String get histPoleVin => 'VIN';

  @override
  String get histPoleRokVyroby => 'Year';

  @override
  String get histPolePalivo => 'Fuel';

  @override
  String get histPolePrevodovka => 'Transmission';

  @override
  String get histPoleMotorizace => 'Engine';

  @override
  String get histSekceZakaznik => 'Customer';

  @override
  String get histPoleJmeno => 'Name';

  @override
  String get histPoleTelefon => 'Phone';

  @override
  String get histPoleEmail => 'E-mail';

  @override
  String get histPoleAdresa => 'Address';

  @override
  String get histPoleIco => 'Company ID';

  @override
  String get histPoleDic => 'Tax ID';

  @override
  String get histSekceStav => 'Condition at intake';

  @override
  String get histPoleTachometr => 'Odometer';

  @override
  String get histPoleNadrz => 'Fuel level';

  @override
  String get histPoleStk => 'MOT';

  @override
  String get histPolePoskozeni => 'Damage';

  @override
  String get histPolePneuLP => 'Tyres FL / FR';

  @override
  String get histPolePneuLZ => 'Tyres RL / RR';

  @override
  String get histSekcePozadavky => 'Customer requests';

  @override
  String get histSekcePoznamky => 'Notes';

  @override
  String get histSekceFoto => 'Photo documentation';

  @override
  String get histZadneFoto => 'No photos taken.';

  @override
  String get histSekcePodpis => 'Customer signature';

  @override
  String get histPodpisNedostupny => 'Signature not available';

  @override
  String get nastUlozit => 'SAVE';

  @override
  String get nastUlozeno => 'Settings saved.';

  @override
  String nastChyba(String chyba) {
    return 'Error: $chyba';
  }

  @override
  String get nastZrusit => 'Cancel';

  @override
  String get nastExportTitle => 'Data export';

  @override
  String get nastExportPopis =>
      'Download records in CSV (Excel) or JSON format.';

  @override
  String get nastExportZakaznici => 'Customers';

  @override
  String get nastExportVozidla => 'Vehicles';

  @override
  String get nastExportZakazky => 'Intakes / Jobs';

  @override
  String get nastExportFormatTitle => 'Export format';

  @override
  String get nastExportFormatPopis => 'Choose the file format:';

  @override
  String get nastExportCsv => 'CSV (Excel)';

  @override
  String get fotoTitle => 'Photo documentation';

  @override
  String get fotoPodtitul =>
      'Take a series of photos, or pick several from the gallery.';

  @override
  String get fotoPridatGalerie => 'Add from gallery';

  @override
  String get fotoSeriove => 'Burst capture';

  @override
  String get fotoKatZvenku => 'Exterior view (around the car)';

  @override
  String get fotoKatPoskozeni => 'Identified damage';

  @override
  String get fotoKatDisky => 'Rims and wheels';

  @override
  String get fotoKatStk => 'Inspection sticker';

  @override
  String get fotoKatInterier => 'Vehicle interior';

  @override
  String get fotoKatTachometr => 'Odometer and dashboard';

  @override
  String get fotoKatVin => 'VIN code';

  @override
  String get fotoKatOstatni => 'Other documentation';

  @override
  String get anotTitle => 'Damage marking';

  @override
  String get anotZavritBezUlozeni => 'Close without saving';

  @override
  String get anotZrusitPosledni => 'Undo last';

  @override
  String get anotSmazatVse => 'Clear all';

  @override
  String get anotUlozit => 'Save';

  @override
  String get anotChybaNacteni => 'Failed to load the photo.';

  @override
  String get anotVolnaKresba => 'Freehand';

  @override
  String get anotElipsa => 'Ellipse';

  @override
  String get anotObdelnik => 'Rectangle';

  @override
  String get anotSipka => 'Arrow';

  @override
  String get anotPopisTitle => 'Damage description';

  @override
  String get anotVzory => 'Presets:';

  @override
  String get anotVlastniPopis => 'Or type your own description…';

  @override
  String get anotZrusit => 'Cancel';

  @override
  String get nastUlozitBtn => 'Save';

  @override
  String get nastZavrit => 'CLOSE';

  @override
  String get nastHotovo => 'DONE';

  @override
  String get nastTitulAdmin => 'Company settings';

  @override
  String get nastTitulUzivatel => 'My profile';

  @override
  String get nastPodtitulAdmin => 'Manage service details and price list.';

  @override
  String get nastPodtitulUzivatel => 'Basic settings of your account.';

  @override
  String get nastFiremniUdaje => 'Company details';

  @override
  String get nastObchodniJmeno => 'Business name / Service name';

  @override
  String get nastIco => 'Company ID';

  @override
  String get nastDic => 'Tax ID';

  @override
  String get nastRejstrik => 'Registry entry (file number)';

  @override
  String get nastSidloKontakt => 'Address & contact';

  @override
  String get nastUlice => 'Street and number';

  @override
  String get nastMesto => 'City';

  @override
  String get nastPsc => 'Postal code';

  @override
  String get nastTelefon => 'Service phone';

  @override
  String get nastEmail => 'E-mail for communication';

  @override
  String get nastCislovani => 'Numbering & automation';

  @override
  String get nastFormatZakazek => 'Order number format';

  @override
  String get nastAutoEmail => 'Automatically send emails';

  @override
  String get nastAutoEmailSub => 'Pre-sets sending of PDF offers and invoices.';

  @override
  String get nastAutoCislo => 'Auto-generate order number';

  @override
  String get nastAutoCisloSub =>
      'At vehicle intake, the order number is filled in automatically. Disable to allow manual entry.';

  @override
  String get nastPodpisPovolen => 'Require customer signature';

  @override
  String get nastPodpisPovolenSub =>
      'When disabled, the signature step is shown without the signature canvas.';

  @override
  String get nastSpzPovinne => 'Plate number required';

  @override
  String get nastSpzPovinneSub =>
      'When disabled, intake can be submitted without a plate number (e.g. unregistered vehicles).';

  @override
  String get nastSablony => 'Message templates';

  @override
  String get nastSablonyPopis =>
      'Preset texts displayed as chips when writing a message to the customer.';

  @override
  String get nastSablonyPrazdne => 'No templates yet. Add the first one.';

  @override
  String get nastPridatSablonu => 'Add template';

  @override
  String get nastUpravitSablonu => 'Edit template';

  @override
  String get nastNovaSablona => 'New template';

  @override
  String get nastSablonaHint => 'Message text...';

  @override
  String get nastTypyZaznamu => 'Record types';

  @override
  String get nastTypyZaznamuPopis =>
      'Record types distinguish intake type (e.g. Service, Purchase). The first added type is the default.';

  @override
  String get nastVychozi => 'default';

  @override
  String get nastPridatTyp => 'Add type';

  @override
  String get nastUpravitTyp => 'Edit type';

  @override
  String get nastNovyTyp => 'New record type';

  @override
  String get nastTypHint => 'Type name (e.g. Service, Purchase...)';

  @override
  String get nastLongPress => 'Long press = set as default.';

  @override
  String get nastOsobni => 'Personal settings';

  @override
  String get nastPrizpusobitListu => 'Customise bottom bar';

  @override
  String get nastPrizpusobitListuSub => 'Add shortcuts or change order.';

  @override
  String get nastListaPopis =>
      'You can have 2 to 5 active tabs. Drag to reorder.';

  @override
  String get nastMenuNelzeOdebrat => 'Menu cannot be removed';

  @override
  String get nastVybrModul => 'Select module for bar';

  @override
  String get nastPridatZalozku => 'Add another tab (max 5)';

  @override
  String get nastTmavyRezim => 'Force dark mode';

  @override
  String get nastTmavyRezimSub => 'App will be dark regardless of system.';

  @override
  String get nastBiometrie => 'Biometric login';

  @override
  String get nastBiometrieSub => 'Face ID / fingerprint at every launch.';

  @override
  String get nastBiometricReason =>
      'Confirm your identity to enable biometric login';

  @override
  String get nastLeVaci => 'Left-handed mode';

  @override
  String get nastLeVaciSub =>
      'Camera shutter on the left when device is in landscape.';

  @override
  String get nastUlozitDoZarizeniTitle => 'Also save photos to device';

  @override
  String get nastUlozitDoZarizeniSub =>
      'When submitting, intake photos are also saved to this device\'s gallery.';

  @override
  String get nastJazyk => 'App language';

  @override
  String get nastSystJazyk => 'System language';

  @override
  String get nastModPrijem => 'Vehicle intake';

  @override
  String get nastModHistorie => 'Intake history';

  @override
  String get nastModMenu => 'Menu (Other modules)';

  @override
  String get nastModVozidla => 'Vehicles';

  @override
  String get nastModUkony => 'Tasks';

  @override
  String get nastModZakaznici => 'Customers';

  @override
  String get nastModTym => 'Team & permissions';

  @override
  String get nastModStatistiky => 'Statistics';

  @override
  String get nastModNastaveni => 'Settings';

  @override
  String get nastModVin => 'VIN decoder';

  @override
  String nastFormatTitle(String typ) {
    return 'Number format for: $typ';
  }

  @override
  String get nastNahledLabel => 'Preview of future document:';

  @override
  String nastInternaMaska(String maska) {
    return 'Internal mask: $maska';
  }

  @override
  String get nastPrefix => 'Prefix (Code)';

  @override
  String get nastOddelovac => 'Separator';

  @override
  String get nastOddelovacPomlcka => 'Dash (-)';

  @override
  String get nastOddelovacLomitko => 'Slash (/)';

  @override
  String get nastOddelovacPodtrzitko => 'Underscore (_)';

  @override
  String get nastOddelovacBez => 'No separator';

  @override
  String get nastRokFormat => 'Year format';

  @override
  String get nastRok4 => '4 digits (2026)';

  @override
  String get nastRok2 => '2 digits (26)';

  @override
  String get nastBezRoku => 'No year';

  @override
  String get nastMesicFormat => 'Month format';

  @override
  String get nastMesic2 => '2 digits (04)';

  @override
  String get nastBezMesice => 'No month';

  @override
  String nastDelkaCitadla(int n) {
    return 'Length of trailing counter: $n';
  }

  @override
  String get nastInfoZmenaFormatu =>
      'If you change the format mid-year, existing documents remain unchanged and the new series continues from the current number in the database.';

  @override
  String get nastUlozitFormat => 'SAVE FORMAT';

  @override
  String get nastFormatUlozen => 'Numbering format saved successfully.';

  @override
  String get nastTrialVyprselo => 'Trial period expired';

  @override
  String get nastTrialAktivni => 'Free trial period';

  @override
  String nastPlanNazev(String plan) {
    return 'Plan $plan';
  }

  @override
  String get nastTrialVyberPlan => 'Choose a plan to continue';

  @override
  String nastTrialZbyva(int n, String slovo) {
    return '$n $slovo remaining · no commitment';
  }

  @override
  String nastPlatnostDo(String datum) {
    return 'Valid until $datum';
  }

  @override
  String get nastAktivni => 'Active';

  @override
  String get nastVybratPlan => 'Choose plan';

  @override
  String get nastZobrazitPlany => 'View plans';

  @override
  String get nastDayJeden => 'day';

  @override
  String get nastDayNeco => 'days';

  @override
  String get nastDayMnogo => 'days';

  @override
  String get zamModZamestnanci => 'Employees';

  @override
  String get zamModNastaveni => 'Settings';

  @override
  String zamChyba(String chyba) {
    return 'Error: $chyba';
  }

  @override
  String get zamTitle => 'Team & permissions';

  @override
  String get zamSubtitle =>
      'Manage your shop\'s members and their access to the app.';

  @override
  String get zamPrazdny => 'You don\'t have any team members yet.';

  @override
  String get zamPridatClena => 'Add team member';

  @override
  String get zamLimitTitle => 'Account limit reached';

  @override
  String zamLimitText(String plan, int limit, int pocet) {
    return 'The $plan plan allows a maximum of $limit user accounts. You are currently using $pocet/$limit. To add more team members, upgrade your plan.';
  }

  @override
  String get zamZrusit => 'Cancel';

  @override
  String get zamUpgradovat => 'Upgrade plan';

  @override
  String get zamNovyClen => 'New team member';

  @override
  String get zamJmenoLabel => 'Full name *';

  @override
  String get zamEmailLabel => 'Login e-mail *';

  @override
  String get zamHesloLabel => 'Login password (min. 6 characters) *';

  @override
  String get zamVychoziPrava => 'Default access permissions';

  @override
  String get zamVytvoritUcet => 'Create account';

  @override
  String get zamErrVyplnte => 'Please fill in name, e-mail and password.';

  @override
  String get zamErrHesloKratke => 'Password must be at least 6 characters.';

  @override
  String get zamUcetVytvoren => 'Account created.';

  @override
  String get zamErrOvereni => 'Authentication error.';

  @override
  String get zamErrHesloSlabe => 'The entered password is too weak.';

  @override
  String get zamErrEmailExistuje =>
      'An account with this e-mail already exists.';

  @override
  String get zamErrEmailFormat => 'Invalid e-mail format.';

  @override
  String zamErrNeocekavana(String chyba) {
    return 'Unexpected error: $chyba';
  }

  @override
  String get zamPristupovaPrava => 'Access permissions';

  @override
  String get zamUlozitOpravneni => 'Save permissions';

  @override
  String get zamUdelitVse => 'Grant all';

  @override
  String get zamOdebratVse => 'Revoke all';

  @override
  String get zamOdstranit => 'Remove';

  @override
  String get zamOdstranitTitle => 'Remove team member?';

  @override
  String zamOdstranitText(String jmeno) {
    return 'Do you really want to remove $jmeno? They will lose access to the app. This action cannot be undone.';
  }

  @override
  String get zamClenOdstranen => 'Team member removed.';

  @override
  String zamPocetUzivatelu(int pocet) {
    return '$pocet users';
  }

  @override
  String zamPocetLimit(int pocet, int limit) {
    return '$pocet / $limit users';
  }

  @override
  String zamPlanBezLimitu(String plan) {
    return '$plan plan · unlimited';
  }

  @override
  String zamPlanLimitDosazen(String plan) {
    return '$plan plan · limit reached';
  }

  @override
  String zamPlanZbyva(String plan, int zbyva) {
    return '$plan plan · $zbyva remaining';
  }

  @override
  String get zamBezJmena => 'No name';

  @override
  String get zamBezPrav => 'No extended permissions';

  @override
  String get zamBadgeAdmin => 'ADMIN';

  @override
  String get zamBadgeClen => 'MEMBER';
}
