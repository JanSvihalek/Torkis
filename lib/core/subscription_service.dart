import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// TODO: Po nastavení RevenueCat vyplň tyto hodnoty:
// - kRevenueCatApiKey: Project Settings → API Keys → Public iOS key (appl_...)
// - kPlanEntitlements: identifikátory entitlementů v RevenueCat (basic, standard, pro)
const String kRevenueCatApiKey = 'appl_TjtSivEXQlOMtVBsuMJPDxMNMWb';

/// Identifikátory entitlementů v RevenueCat — musí přesně souhlasit s názvy v RC konzoli.
const List<String> kPlanEntitlements = ['basic', 'standard', 'pro'];

class SubscriptionService {
  static Future<void> init() async {
    if (kIsWeb) return;
    if (kRevenueCatApiKey == 'PLACEHOLDER_REVENUECAT_API_KEY') return;
    await Purchases.configure(PurchasesConfiguration(kRevenueCatApiKey));
  }

  static Future<void> identifyUser(String userId) async {
    if (kIsWeb) return;
    if (kRevenueCatApiKey == 'PLACEHOLDER_REVENUECAT_API_KEY') return;
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('RevenueCat logIn error: $e');
    }
  }

  static Future<void> logOut() async {
    if (kIsWeb) return;
    if (kRevenueCatApiKey == 'PLACEHOLDER_REVENUECAT_API_KEY') return;
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('RevenueCat logOut error: $e');
    }
  }

  /// Vrátí true pokud je aktivní jakýkoliv plán (basic / standard / pro).
  static Future<bool> isEntitlementActive() async {
    if (kIsWeb) return true;
    if (kRevenueCatApiKey == 'PLACEHOLDER_REVENUECAT_API_KEY') return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return kPlanEntitlements.any(
        (e) => info.entitlements.active.containsKey(e),
      );
    } catch (e) {
      debugPrint('RevenueCat getCustomerInfo error: $e');
      return false;
    }
  }

  /// Vrátí aktivní typ plánu ('pro' > 'standard' > 'basic') nebo null.
  static Future<String?> getActivePlanTyp() async {
    if (kIsWeb) return 'pro';
    if (kRevenueCatApiKey == 'PLACEHOLDER_REVENUECAT_API_KEY') return null;
    try {
      final info = await Purchases.getCustomerInfo();
      for (final plan in ['pro', 'standard', 'basic']) {
        if (info.entitlements.active.containsKey(plan)) return plan;
      }
      return null;
    } catch (e) {
      debugPrint('RevenueCat getCustomerInfo error: $e');
      return null;
    }
  }

  static Future<List<Package>> getPackages() async {
    if (kIsWeb) return [];
    if (kRevenueCatApiKey == 'PLACEHOLDER_REVENUECAT_API_KEY') return [];
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } catch (e) {
      debugPrint('RevenueCat getOfferings error: $e');
      return [];
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    if (kIsWeb) return false;
    try {
      final info = await Purchases.purchasePackage(package);
      return kPlanEntitlements.any(
        (e) => info.entitlements.active.containsKey(e),
      );
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) return false;
      rethrow;
    }
  }

  static Future<bool> restorePurchases() async {
    if (kIsWeb) return false;
    try {
      final info = await Purchases.restorePurchases();
      return kPlanEntitlements.any(
        (e) => info.entitlements.active.containsKey(e),
      );
    } catch (e) {
      debugPrint('RevenueCat restorePurchases error: $e');
      return false;
    }
  }
}
