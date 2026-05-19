import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// TODO: Po nastavení RevenueCat vyplň tyto hodnoty:
// - kRevenueCatApiKey: Project Settings → API Keys → Public iOS key (appl_...)
// - kEntitlementId: název entitlementu v RevenueCat (výchozí 'premium')
const String kRevenueCatApiKey = 'PLACEHOLDER_REVENUECAT_API_KEY';
const String kEntitlementId = 'premium';

class SubscriptionService {
  static Future<void> init() async {
    if (kRevenueCatApiKey == 'PLACEHOLDER_REVENUECAT_API_KEY') return;
    await Purchases.configure(PurchasesConfiguration(kRevenueCatApiKey));
  }

  static Future<void> identifyUser(String userId) async {
    if (kRevenueCatApiKey == 'PLACEHOLDER_REVENUECAT_API_KEY') return;
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('RevenueCat logIn error: $e');
    }
  }

  static Future<void> logOut() async {
    if (kRevenueCatApiKey == 'PLACEHOLDER_REVENUECAT_API_KEY') return;
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('RevenueCat logOut error: $e');
    }
  }

  static Future<bool> isEntitlementActive() async {
    if (kRevenueCatApiKey == 'PLACEHOLDER_REVENUECAT_API_KEY') return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(kEntitlementId);
    } catch (e) {
      debugPrint('RevenueCat getCustomerInfo error: $e');
      return false;
    }
  }

  static Future<List<Package>> getPackages() async {
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
    try {
      final info = await Purchases.purchasePackage(package);
      return info.entitlements.active.containsKey(kEntitlementId);
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) return false;
      rethrow;
    }
  }

  static Future<bool> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      return info.entitlements.active.containsKey(kEntitlementId);
    } catch (e) {
      debugPrint('RevenueCat restorePurchases error: $e');
      return false;
    }
  }
}
