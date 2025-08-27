import 'package:flutter/material.dart';
import 'package:all_gta/ARAppKit/ARAnalytics/ARAtribution.dart';
import 'package:all_gta/ARAppKit/ARAnalytics/ARCrashTracking.dart';
import 'package:all_gta/ARAppKit/ARAnalytics/ARAnalytics.dart';
import 'package:all_gta/ARAppKit/ARConfig/ARConfig.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:superwallkit_flutter/superwallkit_flutter.dart' as sw;
import 'package:all_gta/ARAppKit/ARAnalytics/arAnalytics_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart';

typedef PurchaseFailedBlock = void Function(Exception error);
typedef PurchaseCanceledBlock = void Function();
typedef PurchaseSuccessBlock = void Function(rc.CustomerInfo? customerInfo);
typedef RestorePurchasesFailedBlock = void Function(Exception error);
typedef RestorePurchasesSuccessBlock = void Function();
typedef FetchProductsBlock = void Function(List<rc.Package> packages);

enum ARProUserDeterminationMode {
  subscriptionBased,
  forceProUser,
  forceGoldUser,
  forceFreeUser,
}

class ARProductManager {
  // Singleton instance
  static final ARProductManager _instance = ARProductManager._internal();

  factory ARProductManager() => _instance;
  ARProductManager._internal() {
    _initializeService();
  }

  // Properties
  rc.CustomerInfo? cachedCustomerInfo;
  BuildContext? context;
  List<rc.Package> availablePackages = [];

  // Replace with your RevenueCat entitlement/product identifiers
  final String kEntitlementIdentifierPro = "pro";
  final String kEntitlementIdentifierGold = "gold";
  final String kProDeprecatedProductID1 = "carbon.unlockall";
  final String kProDeprecatedProductID2 = "carbon.unlockall.2";
  final String kProDeprecatedProductID3 = "carbon.unlockall.3";
  final String kProDeprecatedProductID4 = "carbon.unlockall.discount";

  // MARK: - Initialization

  // MARK: - Service Initialization

  void _initializeService() {
    // Initializes
    _initializeRevenueCat();
    _registerForNotifications();

    // TODO TEST - don't know if this works, but it should
    // Modeled after MKStoreKit and FB observer
    // _initializeTransactionObserver(); // Uncomment if implemented

    _initializePurchase();
  }
  // MARK: - RevenueCat Methods

  void _initializeRevenueCat() async {
    // #if DEBUG
    assert(() {
      rc.Purchases.setLogLevel(rc.LogLevel.debug);
      return true;
    }());

    String? revenueCatKey = await _getRevenueCatKeyFromConfig();
    String? appUserId = await ARAnalytics.shared.getARUserId();

    final configuration = rc.PurchasesConfiguration(revenueCatKey);
    if (appUserId != '') {
      configuration.appUserID = appUserId;
    }

    await rc.Purchases.configure(configuration);

    await rc.Purchases.collectDeviceIdentifiers();

    rc.Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      cachedCustomerInfo = customerInfo;
      // Add delegate-equivalent logic here if needed
    });

    await _refreshPurchaserInfo();

    // TOTEST
    String? appsFlyerId = await ARAttribution().getAppsFlyerUID();
    if (appsFlyerId != '') {
      await rc.Purchases.setAppsflyerID(appsFlyerId);
    }

    // Update OneSignal User Id
    _updateOneSignalUserId();

    // Update Firebase User Id
    _updateFirebaseId();
  }

  Future<String?> revenueCatUserId() {
    return rc.Purchases.appUserID;
  }

  Future<void> _refreshPurchaserInfo() async {
    debugPrint("[ARProductManager][refreshPurchaserInfo] In method.");

    try {
      final rc.CustomerInfo customerInfo = await rc.Purchases.getCustomerInfo();

      debugPrint(
        "[ARProductManager][refreshPurchaserInfo] Did refresh customerInfo",
      );

      cachedCustomerInfo = customerInfo;

      final bool isPro =
          customerInfo.entitlements.all[kEntitlementIdentifierPro]?.isActive ??
          false;

      updateCachedIsProUser(isPro);

      final bool isGold =
          customerInfo.entitlements.all[kEntitlementIdentifierGold]?.isActive ??
          false;
      updateCachedIsGoldUser(isGold);
    } catch (e) {
      debugPrint(
        "[ARProductManager][refreshPurchaserInfo] Did refresh customerInfo with error: $e",
      );
    }
  }

  void updateServiceBasedOnATTStatus() {
    // No need to manually call collectDeviceIdentifiers in Flutter.
    // It’s handled automatically on iOS if ATT permissions are granted.

    // But if you want to simulate the structure:
    _collectDeviceIdentifiersIfNeeded();
  }

  void _collectDeviceIdentifiersIfNeeded() {
    // This is just a placeholder to match the structure of your Swift code
    // No actual call needed here in Flutter.
    print("Device identifiers collection is automatic in Flutter SDK.");
  }

  Future<void> _updateOneSignalUserId() async {
    String userId = "";

    if (userId.isNotEmpty) {
      // await rc.Purchases.setOnesignalUserID(userId);
      await rc.Purchases.setOnesignalID(userId);
    }
  }

  Future<void> _updateFirebaseId() async {
    String? instanceId = await ARCrashTracking.shared
        .getFirebaseAppInstanceId();

    if (instanceId != null && instanceId.isNotEmpty) {
      await rc.Purchases.setFirebaseAppInstanceId(instanceId);
    }
  }

  // MARK: - Purchase Status Getters
  // TOTEST
  bool isProUser() {
    print("[ARProductManager][isProUser] In method.");
    refreshPurchaserInfo();

    if (getUserSubscriptionDeterminationMode() ==
        ARProUserDeterminationMode.forceProUser) {
      print("[ARProductManager][isProUser] User is pro - ForceProUser");
      return true;
    } else if (getUserSubscriptionDeterminationMode() ==
        ARProUserDeterminationMode.forceGoldUser) {
      print("[ARProductManager][isProUser] User is gold - ForceGoldUser");
    } else if (getUserSubscriptionDeterminationMode() ==
        ARProUserDeterminationMode.forceFreeUser) {
      print("[ARProductManager][isProUser] User is NOT pro - ForceFreeUser");
      return false;
    }

    if (cachedCustomerInfo
            ?.entitlements
            .all[kEntitlementIdentifierPro]
            ?.isActive ==
        true) {
      print("[ARProductManager][isProUser] User is pro - subscription");
      return true;
    }

    if (cachedCustomerInfo
            ?.entitlements
            .all[kEntitlementIdentifierGold]
            ?.isActive ==
        true) {
      print("[ARProductManager][isProUser] User is gold - subscription");
      return true;
    }

    print(
      "[ARProductManager][isProUser] User is NOT pro - based on  subscription state",
    );
    return false;
  }

  bool isGoldUser() {
    print("[ARProductManager][isGoldUser] In method.");
    refreshPurchaserInfo();

    if (getUserSubscriptionDeterminationMode() ==
        ARProUserDeterminationMode.forceGoldUser) {
      print("[ARProductManager][isGoldUser] User is gold - ForceGoldUser");
      return true;
    } else if (getUserSubscriptionDeterminationMode() ==
        ARProUserDeterminationMode.forceFreeUser) {
      print("[ARProductManager][isGoldUser] User is NOT gold - ForceFreeUser");
      return false;
    }

    // Duplicate check, as in Swift
    if (getUserSubscriptionDeterminationMode() ==
        ARProUserDeterminationMode.forceGoldUser) {
      print("[ARProductManager][isGoldUser] User is gold - ForceGoldUser");
      return true;
    } else if (getUserSubscriptionDeterminationMode() ==
        ARProUserDeterminationMode.forceFreeUser) {
      print("[ARProductManager][isGoldUser] User is NOT gold - ForceFreeUser");
      return false;
    }

    if (cachedCustomerInfo
            ?.entitlements
            .all[kEntitlementIdentifierGold]
            ?.isActive ==
        true) {
      print("[ARProductManager][isGoldUser] User is gold - subscription");
      return true;
    }

    print(
      "[ARProductManager][isGoldUser] User is NOT gold - based on  subscription state",
    );
    return false;
  }

  bool hasPurchasedProductId(String prodictId) {
    print("[ARProductManager][isSubscribedToProductId] In method.");
    refreshPurchaserInfo();

    if (cachedCustomerInfo?.allPurchasedProductIdentifiers.contains(
          prodictId,
        ) ==
        true) {
      print(
        "[ARProductManager][isSubscribedToProductId] User IS subscribed to productId: $prodictId",
      );
      return true;
    }

    print(
      "[LTProductManager][isSubscribedToProductId] User is NOT subscribed to productId: $prodictId",
    );
    return false;
  }

  bool isSubscribedToEntitlementId(String entitlementId) {
    print("[ARProductManager][isSubscribedToEntitlementId] In method.");
    refreshPurchaserInfo();

    if (cachedCustomerInfo?.entitlements.all[entitlementId]?.isActive == true) {
      print(
        "[ARProductManager][isSubscribedToEntitlementId] User IS subscribed to entitlementId: $entitlementId",
      );
      return true;
    }

    print(
      "[ARProductManager][isSubscribedToEntitlementId] User is NOT subscribed to entitlementId: $entitlementId",
    );
    return false;
  }

  List<String> activeSubscriptionProductIds() {
    final activeSubscriptions = cachedCustomerInfo?.activeSubscriptions;
    if (activeSubscriptions == null) {
      return [];
    }

    List<String> productIds = [];
    for (final subscription in activeSubscriptions) {
      productIds.add(subscription);
    }

    return productIds;
  }

  // MARK: - RevenueCat Delegate Method
  void purchases(rc.Purchases purchases, rc.CustomerInfo customerInfo) {
    print('[ARProductManager][purchases] In method.');
    performPurchaseUpdatedActions();
  }

  void performPurchaseUpdatedActions() {
    // TODO: add this to global variables for analytics
    refreshPurchaserInfo();
  }

  // MARK: - Revenue Cat Purcahses

  void fetchAvailablePackages(FetchProductsBlock completion) async {
    print("[ARProductManager][fetchAvailablePackages] In method.");

    try {
      rc.Offerings offerings = await rc.Purchases.getOfferings();
      print("[ARProductManager][fetchAvailablePackages] In completion.");

      List<rc.Package> packages = offerings.current?.availablePackages ?? [];

      if (packages.isEmpty) {
        print(
          "[ARProductManager][fetchAvailablePackages] No current offering or no packages available.",
        );
        completion([]);
        return;
      }

      print(
        "[ARProductManager][fetchAvailablePackages] Found current offering and available packages.",
      );
      completion(packages);
    } catch (e) {
      print(
        "[ARProductManager][fetchAvailablePackages] Error fetching packages: $e",
      );
      completion([]);
    }
  }

  void superfetchAvailablePackages(
    String? identifier,
    FetchProductsBlock completion,
  ) async {
    print("[ARProductManager][fetchAvailablePackagesFromOffering] In method.");

    // Input validation similar to guard in Swift
    if (identifier == null || identifier.isEmpty) {
      print(
        "[ARProductManager][fetchAvailablePackagesFromOffering] Offering identifier is nil or empty. Returning empty array.",
      );
      completion([]);
      return;
    }

    try {
      rc.Offerings offerings = await rc.Purchases.getOfferings();
      print(
        "[ARProductManager][fetchAvailablePackagesFromOffering] In completion.",
      );

      List<rc.Package> packages =
          offerings.getOffering(identifier)?.availablePackages ?? [];

      if (packages.isEmpty) {
        print(
          "[ARProductManager][fetchAvailablePackagesFromOffering] Offering not found or has no available packages.",
        );
      } else {
        print(
          "[ARProductManager][fetchAvailablePackagesFromOffering] Successfully found offering with packages.",
        );
      }

      completion(packages);
    } catch (e) {
      print(
        "[ARProductManager][fetchAvailablePackagesFromOffering] Error fetching packages: $e",
      );
      completion([]);
    }
  }

  void restorePurchasesWithSuccessBlock(
    RestorePurchasesSuccessBlock successBlock,
    RestorePurchasesFailedBlock failureBlock,
  ) async {
    print("[ARProductManager][restorePurchasesWithSuccessBlock] In method.");

    try {
      rc.CustomerInfo customerInfo = await rc.Purchases.restorePurchases();
      print("[ARProductManager][restorePurchases] Did restore purchases!");

      cachedCustomerInfo = customerInfo;

      Map<String, rc.EntitlementInfo> activeEntitlements =
          cachedCustomerInfo?.entitlements.active ?? {};
      int numActiveSubscriptions = activeEntitlements.length;

      if (numActiveSubscriptions > 0) {
        print(
          "[ARProductManager][restorePurchases] User had purchases to be restored!",
        );
        successBlock();
      } else {
        print(
          "[ARProductManager][restorePurchases] No previous purchases found!",
        );
        final customError = Exception("No previous purchases found!");
        failureBlock(customError);
      }
    } catch (error) {
      print(
        "[ARProductManager][restorePurchases] Did fail restoring purchases! Error: $error",
      );
      failureBlock(error as Exception);
    }
  }

  void purchasePackage({
    required rc.Package package,
    required PurchaseFailedBlock didFailWithErrorBlock,
    required PurchaseCanceledBlock didCancelBlock,
    required PurchaseSuccessBlock successBlock,
  }) async {
    print("[ARProductManager][purchasePackage] In method.");

    try {
      rc.CustomerInfo customerInfo = await rc.Purchases.purchasePackage(
        package,
      );
      print("[ARProductManager][purchasePackage] Success!");
      cachedCustomerInfo = customerInfo;
      successBlock(customerInfo);
    } on rc.PurchasesError catch (error) {
      if (error.code == rc.PurchasesErrorCode.purchaseCancelledError) {
        print("[ARProductManager][purchasePackage] User canceled purchase!");
        didCancelBlock();
      } else {
        print(
          "[LTProductManager][purchasePackage] Error purchasing package: $error",
        );
        didFailWithErrorBlock(error as Exception);
      }
    } catch (error) {
      print("[LTProductManager][purchasePackage] Unexpected error: $error");
      didFailWithErrorBlock(error as Exception);
    }
  }

  Future<rc.Offering?> getOfferingToPresentOutOfAllOfferings(
    rc.Offerings? offerings,
  ) async {
    bool ispmd = await ARConfig.shared.isPModeD();

    if (ispmd) {
      rc.Offering? result = offerings?.getOffering("demo");
      if (result != null) {
        return result;
      }
    }

    bool shouldOfferVaryForNonOrganicUsers = ARConfig.shared
        .shouldOfferVaryForNonOrganicUsers();
    bool isNonOrganicUser = await ARAttribution().isNonOrganicInstall();

    if (isNonOrganicUser && shouldOfferVaryForNonOrganicUsers) {
      rc.Offering? result = offerings?.getOffering("nonOrganic");
      if (result != null) {
        return result;
      }
    }

    return offerings?.current;
  }

  //MARK:- Helpers
  /// Currently only used for debugging and internal event analytics
  /// Can be used later in the future if this turns out to be reliable to solve the issue where isPro is wrong for first 3 seconds of a users new session
  Future<bool> cached_isProUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final dynamic value = prefs.get("USERDEFAULTS_PURCHASE_CACHED_IS_PRO_USER");
    if (value is int) {
      return true;
    }
    return false;
  }

  Future<void> updateCachedIsProUser(bool isPro) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("USERDEFAULTS_PURCHASE_CACHED_IS_PRO_USER", isPro);
    await prefs.reload(); // Similar to synchronize()
  }

  Future<bool> cached_isGoldUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final dynamic value = prefs.get(
      "USERDEFAULTS_PURCHASE_CACHED_IS_GOLD_USER",
    );
    if (value is int) {
      return true;
    }
    return false;
  }

  Future<void> updateCachedIsGoldUser(bool isPro) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("USERDEFAULTS_PURCHASE_CACHED_IS_GOLD_USER", isPro);
    await prefs.reload();
  }

  void refreshPurchaserInfo() {
    // Your logic to update cachedCustomerInfo
  }

  //MARK: Notifications
  void _registerForNotifications() {
    // To be implemented if notification registration is needed
  }

  void unregisterForNotifications() {
    // In Flutter, we typically use StreamSubscription for event listening
    // This method would cancel any active subscriptions

    // If you're using Firebase Messaging
    // FirebaseMessaging.instance.onTokenUpdate.listen(null).cancel();
    // FirebaseMessaging.instance.onMessage.listen(null).cancel();

    // If you're using local notifications plugin
    // FlutterLocalNotificationsPlugin().cancelAll();

    // For general Dart streams, you would maintain a list of subscriptions
    // and cancel them here:
    /*
  for (var subscription in _streamSubscriptions) {
    subscription.cancel();
  }
  _streamSubscriptions.clear();
  */

    // Note: Flutter doesn't have a direct equivalent to NSNotificationCenter
    // You'll need to manage your subscriptions manually
  }

  void oneSignalUserIdUpdatedNotificationReceived(Notification notification) {
    _updateOneSignalUserId();
  }

  // MARK: - Pro User Determination Methods
  Future<ARProUserDeterminationMode>
  getUserSubscriptionDeterminationMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? mode = prefs.getInt("USERDEFAULTS_PROUSERDETERMINATIONMODE");

    if (mode != null) {
      return ARProUserDeterminationMode.values.firstWhere(
        (e) => e.index == mode,
        orElse: () => ARProUserDeterminationMode.forceFreeUser,
      );
    }

    return ARProUserDeterminationMode.forceFreeUser;
  }

  Future<String> getUserSubscriptionDeterminationModeAsString() async {
    ARProUserDeterminationMode mode =
        await getUserSubscriptionDeterminationMode();
    switch (mode) {
      case ARProUserDeterminationMode.subscriptionBased:
        return "Subscription";
      case ARProUserDeterminationMode.forceProUser:
        return "ForcePro";
      case ARProUserDeterminationMode.forceGoldUser:
        return "ForceGold";
      case ARProUserDeterminationMode.forceFreeUser:
        return "ForceFree";
    }
  }

  Future<void> setUserSubscriptionDeterminationMode({
    required ARProUserDeterminationMode mode,
  }) async {
    final SharedPreferences defaults = await SharedPreferences.getInstance();
    await defaults.setInt('USERDEFAULTS_PROUSERDETERMINATIONMODE', mode.index);
  }

  //MARK: Config

  Future<Map<String, dynamic>> config() async {
    // Assuming ARCONFIG_FILENAME is "Config.plist" located in assets
    Map<String, dynamic> configDictionary = {};

    try {
      final String configContent = await rootBundle.loadString(
        'assets/${ARAnalyticsConstants.ARCONFIG_FILENAME}.plist',
      );

      final xml = XmlDocument.parse(configContent);
      configDictionary = _parsePlistXml(xml);
    } catch (e) {
      debugPrint("[ARProductManager][config] Failed to load config: $e");
    }

    return configDictionary;
  }

  Future<String> _getRevenueCatKeyFromConfig() async {
    final Map<String, dynamic> configMap = await config();
    final Map<String, dynamic> configElements =
        configMap['Product'] as Map<String, dynamic>? ?? {};

    String key = '';

    // If in debug mode, try dev key first
    assert(() {
      key = configElements['RevenueCatKeyDev'] as String? ?? '';
      return true;
    }());

    // If dev key is empty or not in debug mode, use prod key
    if (key.isEmpty) {
      key = configElements['RevenueCatKeyProd'] as String? ?? '';
    }

    return key;
  }

  Future<String> getAppId() async {
    Map<String, dynamic> config =
        (await this.config())['Common'] as Map<String, dynamic>? ?? {};
    String appId = config['AppId'] as String? ?? '';
    return appId;
  }

  Future<void> _initializePurchase() async {
    // Set up the purchase configuration
    // Purchases.initialize() is not required in Flutter SDK

    final userId = ARAnalyticsConstants.APP_ID;

    final configuration = rc.PurchasesConfiguration(
      ARAnalyticsConstants.REVENUE_CAT_API_KEY_IOS,
    );
    configuration.appUserID = userId;

    await rc.Purchases.configure(configuration);

    // Optionally refresh customer info
    await refreshCustomerInfo();
  }

  // MARK: - Purchase Methods
  Future<void> refreshCustomerInfo() async {
    try {
      final customerInfo = await rc.Purchases.getCustomerInfo();

      final entitlement = customerInfo.entitlements.all['pro'];
      final hasPro = entitlement != null && entitlement.isActive;

      final currentStatus = await sw.Superwall.shared.subscriptionStatus.first;

      if (currentStatus is! sw.SubscriptionStatusActive) {
        if (hasPro) {
          // Do something or notify UI: user is now active
          print('Setting status to active (locally)');
        } else {
          // Handle inactive
          print('Setting status to inactive (locally)');
        }
      }

      cachedCustomerInfo = customerInfo;
      print(customerInfo.entitlements.all);
      print(customerInfo.activeSubscriptions.length);
    } catch (error) {
      print('Error fetching customer info: $error');
    }
  }

  // MARK: - Purchase Logic
  Future<void> makePurchase(BuildContext context, rc.Package product) async {
    try {
      final customerInfo = await rc.Purchases.purchasePackage(product);

      final entitlement = customerInfo.entitlements.all[product.identifier];
      final isActive = entitlement != null && entitlement.isActive;

      if (isActive) {
        await refreshCustomerInfo();

        showAlert(
          context,
          "Purchase Successful",
          "Purchase successful for product",
          onDismiss: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        );
      } else {
        showAlert(context, "Error!!", "Purchase failed");
      }
    } catch (e) {
      showAlert(context, "Error!!", "Purchase failed: ${e.toString()}");
    }
  }

  Future<void> restorePurchase(BuildContext context) async {
    showLoading(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final customerInfo = await rc.Purchases.restorePurchases();

      hideLoading(context);
      Navigator.of(context).pop();

      if (customerInfo.entitlements.active.isNotEmpty) {
        showAlert(
          context,
          "Restoration Successful",
          "Restoration Successful - user is subscribed.",
          onDismiss: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        );
      } else {
        showAlert(
          context,
          "Restoration Successful",
          "Restoration completed but no active subscription found.",
        );
      }
    } catch (e) {
      // Hide loading
      Navigator.of(context).pop();

      showAlert(
        context,
        "Error!!",
        "Error restoring purchases: ${e.toString()}",
      );
    }
  }

  Future<void> fetchOfferingsAndShowSubscriptionVC(
    BuildContext context, {
    bool present = false,
  }) async {
    showLoading(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final offerings = await rc.Purchases.getOfferings();

      hideLoading(context);
      Navigator.of(context).pop();

      if (offerings.current != null) {
        availablePackages = offerings.current!.availablePackages;
        showSubscriptionController(context, present);
      } else {
        showAlert(context, "Error!!", "No current offering found.");
      }
    } catch (e) {
      // Hide loading
      Navigator.of(context).pop();

      showAlert(
        context,
        "Error!!",
        "Error fetching offerings: ${e.toString()}",
      );
    }
  }

  void showSubscriptionController(BuildContext context, bool present) {
    // Close the keyboard if open
    FocusScope.of(context).unfocus();

    // If no available packages, do nothing
    if (availablePackages.isEmpty) return;

    final subscriptionScreen = SubscriptionScreen(packages: availablePackages);

    if (present) {
      // Present as modal (like Swift's modalPresentationStyle)
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => subscriptionScreen,
      );
    } else {
      // Push to navigation stack (like pushViewController)
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => subscriptionScreen));
    }
  }

  //MARK:- Helpers
  Map<String, dynamic> _parsePlistXml(XmlDocument xml) {
    final Map<String, dynamic> result = {};
    final dict = xml.findAllElements('dict').first;

    String? currentKey;

    for (final node in dict.children) {
      if (node is XmlElement) {
        if (node.name.local == 'key') {
          currentKey = node.text;
        } else if (currentKey != null) {
          switch (node.name.local) {
            case 'string':
              result[currentKey] = node.text;
              break;
            case 'true':
              result[currentKey] = true;
              break;
            case 'false':
              result[currentKey] = false;
              break;
            case 'integer':
              result[currentKey] = int.tryParse(node.text);
              break;
            case 'real':
              result[currentKey] = double.tryParse(node.text);
              break;
          }
          currentKey = null;
        }
      }
    }

    return result;
  }

  void showAlert(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }
}

// MARK: - Subscription Screen
class SubscriptionScreen extends StatelessWidget {
  final List<rc.Package> packages;

  const SubscriptionScreen({super.key, required this.packages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: ListView.builder(
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final package = packages[index];
          return ListTile(
            title: Text(package.storeProduct.title),
            subtitle: Text(package.storeProduct.priceString),
            onTap: () {
              // handle purchase logic
            },
          );
        },
      ),
    );
  }
}
