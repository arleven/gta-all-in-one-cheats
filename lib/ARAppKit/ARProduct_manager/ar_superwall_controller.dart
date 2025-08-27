import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:superwallkit_flutter/superwallkit_flutter.dart'
    as sw
    hide LogLevel;

class RCPurchaseController extends sw.PurchaseController {
  // MARK: Configure and sync subscription Status
  /// Makes sure that Superwall knows the customers subscription status by
  /// changing `Superwall.shared.subscriptionStatus`
  Future<void> configureAndSyncSubscriptionStatus() async {
    // Configure RevenueCat
    await rc.Purchases.setLogLevel(rc.LogLevel.debug);
    final configuration = Platform.isIOS
        ? rc.PurchasesConfiguration('appl_zytZgDretwVAviWrdfFXipcAppM')
        : rc.PurchasesConfiguration('goog_fQHtkmiKIKGUWbmibGybHTGTQIO');
    await rc.Purchases.configure(configuration);

    // Listen for changes
    rc.Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      // Gets called whenever new CustomerInfo is available
      final entitlements = customerInfo.entitlements.active.keys
          .map((id) => sw.Entitlement(id: id))
          .toSet();

      final hasActiveEntitlementOrSubscription = customerInfo
          .hasActiveEntitlementOrSubscription(); // Why? -> https://www.revenuecat.com/docs/entitlements#entitlements

      if (hasActiveEntitlementOrSubscription) {
        await sw.Superwall.shared.setSubscriptionStatus(
          sw.SubscriptionStatusActive(entitlements: entitlements),
        );
      } else {
        await sw.Superwall.shared.setSubscriptionStatus(
          sw.SubscriptionStatusInactive(),
        );
      }
    });
  }

  // MARK: Handle Purchases

  /// Makes a purchase from App Store with RevenueCat and returns its
  /// result. This gets called when someone tries to purchase a product on
  /// one of your paywalls from iOS.
  @override
  Future<sw.PurchaseResult> purchaseFromAppStore(String productId) async {
    // Find products matching productId from RevenueCat
    final products = await PurchasesAdditions.getAllProducts([productId]);

    // Get first product for product ID (this will properly throw if empty)
    final storeProduct = products.firstOrNull;

    if (storeProduct == null) {
      return sw.PurchaseResult.failed(
        'Failed to find store product for $productId',
      );
    }

    final purchaseResult = await _purchaseStoreProduct(storeProduct);
    return purchaseResult;
  }

  /// Makes a purchase from Google Play with RevenueCat and returns its
  /// result. This gets called when someone tries to purchase a product on
  /// one of your paywalls from Android.
  @override
  Future<sw.PurchaseResult> purchaseFromGooglePlay(
    String productId,
    String? basePlanId,
    String? offerId,
  ) async {
    // Find products matching productId from RevenueCat
    List<rc.StoreProduct> products = await PurchasesAdditions.getAllProducts([
      productId,
    ]);

    // Choose the product which matches the given base plan.
    // If no base plan set, select first product or fail.
    String storeProductId = "$productId:$basePlanId";

    // Try to find the first product where the googleProduct's basePlanId matches the given basePlanId.
    rc.StoreProduct? matchingProduct;

    // Loop through each product in the products list.
    for (final product in products) {
      // Check if the current product's basePlanId matches the given basePlanId.
      if (product.identifier == storeProductId) {
        // If a match is found, assign this product to matchingProduct.
        matchingProduct = product;
        // Break the loop as we found our matching product.
        break;
      }
    }

    // If a matching product is not found, then try to get the first product from the list.
    rc.StoreProduct? storeProduct =
        matchingProduct ?? (products.isNotEmpty ? products.first : null);

    // If no product is found (either matching or the first one), return a failed purchase result.
    if (storeProduct == null) {
      return sw.PurchaseResult.failed("Product not found");
    }

    switch (storeProduct.productCategory) {
      case rc.ProductCategory.subscription:
        rc.SubscriptionOption? subscriptionOption =
            await _fetchGooglePlaySubscriptionOption(
              storeProduct,
              basePlanId,
              offerId,
            );
        if (subscriptionOption == null) {
          return sw.PurchaseResult.failed(
            "Valid subscription option not found for product.",
          );
        }
        return await _purchaseSubscriptionOption(subscriptionOption);
      case rc.ProductCategory.nonSubscription:
        return await _purchaseStoreProduct(storeProduct);
      case null:
        return sw.PurchaseResult.failed("Unable to determine product category");
    }
  }

  Future<rc.SubscriptionOption?> _fetchGooglePlaySubscriptionOption(
    rc.StoreProduct storeProduct,
    String? basePlanId,
    String? offerId,
  ) async {
    final subscriptionOptions = storeProduct.subscriptionOptions;

    if (subscriptionOptions != null && subscriptionOptions.isNotEmpty) {
      // Concatenate base + offer ID
      final subscriptionOptionId = _buildSubscriptionOptionId(
        basePlanId,
        offerId,
      );

      // Find first subscription option that matches the subscription option ID or use the default offer
      rc.SubscriptionOption? subscriptionOption;

      // Search for the subscription option with the matching ID
      for (final option in subscriptionOptions) {
        if (option.id == subscriptionOptionId) {
          subscriptionOption = option;
          break;
        }
      }

      // If no matching subscription option is found, use the default option
      subscriptionOption ??= storeProduct.defaultOption;

      // Return the subscription option
      return subscriptionOption;
    }

    return null;
  }

  Future<sw.PurchaseResult> _purchaseSubscriptionOption(
    rc.SubscriptionOption subscriptionOption,
  ) async {
    // Define the async perform purchase function
    Future<rc.CustomerInfo> performPurchase() async {
      // Attempt to purchase product
      rc.CustomerInfo customerInfo =
          await rc.Purchases.purchaseSubscriptionOption(subscriptionOption);
      return customerInfo;
    }

    sw.PurchaseResult purchaseResult = await _handleSharedPurchase(
      performPurchase,
    );
    return purchaseResult;
  }

  Future<sw.PurchaseResult> _purchaseStoreProduct(
    rc.StoreProduct storeProduct,
  ) async {
    // Define the async perform purchase function
    Future<rc.CustomerInfo> performPurchase() async {
      // Attempt to purchase product
      rc.CustomerInfo customerInfo = await rc.Purchases.purchaseStoreProduct(
        storeProduct,
      );
      return customerInfo;
    }

    sw.PurchaseResult purchaseResult = await _handleSharedPurchase(
      performPurchase,
    );
    return purchaseResult;
  }

  // MARK: Shared purchase
  Future<sw.PurchaseResult> _handleSharedPurchase(
    Future<rc.CustomerInfo> Function() performPurchase,
  ) async {
    try {
      // Perform the purchase using the function provided
      rc.CustomerInfo customerInfo = await performPurchase();
      print(customerInfo.activeSubscriptions.length);
      print(customerInfo.entitlements.all.length);
      print(customerInfo.entitlements.active);

      // Handle the results
      if (customerInfo.hasActiveEntitlementOrSubscription()) {
        return sw.PurchaseResult.purchased;
      } else {
        return sw.PurchaseResult.failed("No active subscriptions found.");
      }
    } on PlatformException catch (e) {
      var errorCode = rc.PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == rc.PurchasesErrorCode.paymentPendingError) {
        return sw.PurchaseResult.pending;
      } else if (errorCode == rc.PurchasesErrorCode.purchaseCancelledError) {
        return sw.PurchaseResult.cancelled;
      } else {
        return sw.PurchaseResult.failed(
          e.message ?? "Purchase failed in RCPurchaseController",
        );
      }
    }
  }

  // MARK: Handle Restores

  /// Makes a restore with RevenueCat and returns `.restored`, unless an error is thrown.
  /// This gets called when someone tries to restore purchases on one of your paywalls.
  @override
  Future<sw.RestorationResult> restorePurchases() async {
    try {
      rc.CustomerInfo customerInfo = await rc.Purchases.restorePurchases();
      await configureAndSyncSubscriptionStatus();

      sw.Superwall.shared.setUserAttributes({
        'entitlements': customerInfo.entitlements.active.keys.join(','),
        'isSubscribed': customerInfo.hasActiveEntitlementOrSubscription(),
      });

      return sw.RestorationResult.restored;
    } on PlatformException catch (e) {
      // Error restoring purchases
      return sw.RestorationResult.failed(
        e.message ?? "Restore failed in RCPurchaseController",
      );
    }
  }
}

// MARK: Helpers

String _buildSubscriptionOptionId(String? basePlanId, String? offerId) {
  String result = '';

  if (basePlanId != null) {
    result += basePlanId;
  }

  if (offerId != null) {
    if (basePlanId != null) {
      result += ':';
    }
    result += offerId;
  }

  return result;
}

extension PurchasesAdditions on rc.Purchases {
  static Future<List<rc.StoreProduct>> getAllProducts(
    List<String> productIdentifiers,
  ) async {
    final subscriptionProducts = await rc.Purchases.getProducts(
      productIdentifiers,
      productCategory: rc.ProductCategory.subscription,
    );
    final nonSubscriptionProducts = await rc.Purchases.getProducts(
      productIdentifiers,
      productCategory: rc.ProductCategory.nonSubscription,
    );
    final combinedProducts = [
      ...subscriptionProducts,
      ...nonSubscriptionProducts,
    ];
    return combinedProducts;
  }
}

extension CustomerInfoAdditions on rc.CustomerInfo {
  bool hasActiveEntitlementOrSubscription() {
    return (activeSubscriptions.isNotEmpty || entitlements.active.isNotEmpty);
  }
}
