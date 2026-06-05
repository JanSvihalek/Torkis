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
}
