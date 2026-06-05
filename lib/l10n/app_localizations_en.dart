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
}
