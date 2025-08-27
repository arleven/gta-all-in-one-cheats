import 'package:amplitude_flutter/constants.dart';
import 'package:amplitude_flutter/default_tracking.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:flutter/widgets.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:all_gta/ARAppKit/ARAnalytics/ARAtribution.dart';
import 'package:all_gta/ARAppKit/ARAnalytics/arAnalytics_constants.dart';
import 'package:all_gta/ARAppKit/ARAnalytics/User_Defaults.dart';
import 'package:all_gta/ARAppKit/ARConfig/ARConfig.dart';
import 'package:all_gta/ARAppKit/ARProduct_manager/ar_product_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show MethodChannel;
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:intl/intl.dart';
import 'package:country_codes/country_codes.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:amplitude_flutter/events/identify.dart';

extension AsyncMapForEach<K, V> on Map<K, V> {
  Future<void> forEachAsync(
    Future<void> Function(K key, V value) action,
  ) async {
    for (final entry in entries) {
      await action(entry.key, entry.value);
    }
  }
}

class ARAnalytics {
  static final ARAnalytics shared = ARAnalytics._internal();

  late final Amplitude amplitude;
  ARAnalyticsAppSessionSource appSessionSource =
      ARAnalyticsAppSessionSource.ARAnalyticsAppSessionSource_None;
  String _appSessionSourceParam = "";

  final MethodChannel _vpnChannel = MethodChannel('com.example.vpncheck');

  ARAnalytics._internal() {
    _setup();
  }

  Future<void> _setup() async {
    WidgetsFlutterBinding.ensureInitialized();

    amplitude = Amplitude(
      Configuration(
        apiKey: ARAnalyticsConstants.AMPLITUDE_API_KEY,
        flushQueueSize: 1,
        flushIntervalMillis: 5000,
        defaultTracking: const DefaultTrackingOptions(sessions: true),
      ),
    );

    WidgetsBinding.instance.addObserver(
      _AppLifecycleHandler(
        onResumed: applicationWillEnterForeground,
        onPaused: applicationDidEnterBackground,
      ),
    );

    await trackEvent('app_initialized');
  }

  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    final event = BaseEvent(eventName, eventProperties: properties);
    await amplitude.track(event);
  }

  // MARK: - Services Initialization
  Future<void> initializeServices() async {
    final bool isPrivacyConsentRequiredButNotProvided =
        await _isPrivacyConsentRequiredButNotProvided();

    // Disable country tracking
    // amplitude.configuration.trackingOptions.disableCountry();

    // Set user ID
    final userId =
        await AppUserDefaults.getUserID(); // Assume this returns a String?
    amplitude.setUserId(userId);

    // Set log level
    amplitude.configuration.logLevel = LogLevel.debug;

    // Track initial event
    await amplitude.track(BaseEvent("Sign Up Amplitude"));

    // Set opt-out flag
    amplitude.setOptOut(isPrivacyConsentRequiredButNotProvided);

    if (!isPrivacyConsentRequiredButNotProvided) {
      // Setup Facebook or other third-party SDK
      // For example: FacebookSdk.init();
    }

    debugPrint("ARANALYTICS - Finished Initializing Services");
  }

  Future<void> initializeServicesRequiringLaunchOptions({
    Map<String, dynamic>? launchOptions,
  }) async {
    final bool isPrivacyConsentRequiredButNotProvided =
        await _isPrivacyConsentRequiredButNotProvided();

    // Placeholder: Uncomment when implementing these services
    // ARAttribution.shared.initializeServices();
    // ARCrashTracking.shared.initializeService();
    // ARFacebook.shared.initializeService(launchOptions: launchOptions);

    if (!isPrivacyConsentRequiredButNotProvided) {
      // ARCrashTracking.shared.optInAndStartService();
      // ARFacebook.shared.optInAndStartService();
    }

    int checkIns = await ARAnalytics.getNumCheckIns();
    int delaySeconds = 5;
    if (checkIns > 0) {
      delaySeconds = 1;
    }

    Future.delayed(Duration(seconds: delaySeconds), () {
      shared.trackAppInstall();
      shared.trackNewSession();
      shared.trackCheckIn();
      shared.handleCustomDeeplinkingRouteIfPresent();
    });
  }

  Future<void> performApplicationDidBecomeActiveActions() async {
    final bool isPrivacyConsentRequiredButNotProvided =
        await _isPrivacyConsentRequiredButNotProvided();

    if (!isPrivacyConsentRequiredButNotProvided) {
      // TODO: Uncomment and implement this if needed
      // await ARAttribution.shared.startAppsFlyer();
    }
  }

  void handleCustomDeeplinkingRouteIfPresent() {
    // TODO: Implement custom deep link handling if needed
  }

  // MARK: - Notification Selectors
  void applicationWillEnterForeground() {
    print("ARAnalytics - applicationWillEnterForeground called");
    trackCheckIn();
    trackNewSession();
  }

  void applicationDidEnterBackground() {
    print("ARAnalytics - applicationDidEnterBackground called");
    trackFirstSessionEnded();
    updateUserProperties();
    clearAppSessionSource();
  }

  // MARK: - Event Methods

  // MARK: - Event Tracking
  Future<void> trackAppInstall() async {
    final isConsentRequired = await _isPrivacyConsentRequiredButNotProvided();
    if (isConsentRequired) return;

    final hasTrackedBefore = await hasFlagBeenSetBefore(
      'ARANALYTICS_appInstallTrackedBefore',
    );
    if (!hasTrackedBefore) {
      markHasNotPurchased();
      await ARAnalytics.resetNumPurchases();

      final params = await getGlobalTrackingParameters();
      trackEventWithName('App Install', params);
    }
  }

  Future<void> trackCheckIn() async {
    final hasCheckedInToday = await ARAnalytics.hasUserCheckedInToday();

    if (!hasCheckedInToday) {
      print('FIRST CHECK IN OF THE DAY');
      await ARAnalytics.incrementNumCheckIns();
      final params = await getGlobalTrackingParameters();
      trackEventWithName('Check In', params);
    } else {
      print('USER ALREADY CHECKED IN TODAY');
    }
  }

  Future<void> trackNewSession() async {
    await ARAnalytics.incrementNumSessions();
  }

  Future<void> trackARReviewPresented() async {
    trackEventOnce('ARReview Presented', {});
  }

  Future<void> trackPurchaseVCPresented() async {
    trackEventOnce('Purchase VC Presentation', {});
  }

  Future<void> trackDiscountVCPresented() async {
    trackEventOnce('Discount VC Presentation', {});
  }

  Future<void> trackHomeVCPresented() async {
    trackEventOnce('Home VC Presentation', {});
  }

  Future<void> trackGoal1() async {
    await ARAnalytics.incrementNumGoal1();
    trackEventOnce('Goal 1', {});
  }

  Future<void> trackGoal2() async {
    await ARAnalytics.incrementNumGoal2();
    trackEventOnce('Goal 2', {});
  }

  Future<void> trackPushPermissionRequested() async {
    trackEventOnce('Push Permission Requested', {});
  }

  Future<void> trackPushGranted() async {
    trackEventOnce('Push Granted', {});
  }

  Future<void> trackPushDenied() async {
    trackEventOnce('Push Denied', {});
  }

  Future<void> trackOnboardingCompleted() async {
    trackEventOnce('Onboarding Completed', {});
  }

  Future<void> trackForceProStarted() async {
    trackEventOnce('Force Pro Started', {});
  }

  Future<void> trackFirstSessionEnded() async {
    // TODO: Implement first session ended tracking here
    // Example placeholder if you later want to track this via analytics:
    trackEventWithName('First Session Ended', {});
  }

  Future<void> trackSignUpVCPresented() async {
    final hasTrackedBefore = await hasFlagBeenSetBefore(
      'ARANALYTICS_signUpVCPresented',
    );
    if (!hasTrackedBefore) {
      final params = await getGlobalTrackingParameters();
      trackEventOnce('Sign Up VC Presented', params);
    }
  }

  Future<void> trackSignedUpCompletedWithSource(String? source) async {
    final hasTrackedBefore = await hasFlagBeenSetBefore(
      'ARANALYTICS_signUpCompleted',
    );

    if (!hasTrackedBefore) {
      final params = await getGlobalTrackingParameters();
      params['signupSource'] = source ?? 'undefined';
      trackEventOnce('Sign Up Completed', params);
    }
  }

  Future<void> trackSignUpSkipped() async {
    final hasTrackedBefore = await hasFlagBeenSetBefore(
      'ARANALYTICS_signUpSkipped',
    );

    if (!hasTrackedBefore) {
      final params = await getGlobalTrackingParameters();
      trackEventOnce('Sign Up Skipped', params);
    }
  }

  /// NOT IMPLEMENTED: Track an exception with a name and exception details.
  void trackExceptionWithName(String errorName, dynamic exception) {
    // TODO: Implement exception tracking logic here.
    // Example: Send to analytics or crash reporting tool.
  }

  /// NOT IMPLEMENTED: Track a generic error by name.
  void trackErrorWithName(String errorName) {
    // TODO: Implement error tracking logic here.
    // Example: Send to analytics or crash reporting tool.
  }

  // MARK: - Tracking Events - Conversion Events
  void trackConversionWithProductIdentifier(String productId) {
    trackConversionWithDetails(
      productId: productId,
      presentationSource: 'none',
      vcSource: 'none',
      viewSource: 'none',
    );
  }

  void trackConversionWithDetails({
    required String productId,
    required String presentationSource,
    required String vcSource,
    required String viewSource,
  }) async {
    // Flag for checking whether the purchase was already tracked
    bool hasTrackedBefore = await hasFlagBeenSetBefore(
      ARAnalyticsConstants.USERDEFAULTS_PURCHASE_TRACKED_BEFORE,
    );

    // If productId is not empty, use a product-specific flag
    if (productId.isNotEmpty) {
      hasTrackedBefore = await hasFlagBeenSetBefore(
        '${ARAnalyticsConstants.USERDEFAULTS_PURCHASE_TRACKED_BEFORE}_$productId',
      );
    }

    if (!hasTrackedBefore) {
      print('Purchase Made: $productId');

      markHasPurchased();
      // ARAnalytics.incrementNumPurchases(); // Uncomment if method exists

      final Map<String, dynamic> params = await getGlobalTrackingParameters();

      if (presentationSource.isNotEmpty) {
        params['purchasePresentationSource'] = presentationSource;
      }

      if (vcSource.isNotEmpty) {
        params['purchaseVCSource'] = vcSource;
      }

      if (viewSource.isNotEmpty) {
        params['purchaseViewSource'] = viewSource;
      }

      final String finalProductId = productId.isNotEmpty ? productId : 'N/A';
      params['productIdentifier'] = finalProductId;

      trackEventWithName('Purchase Made', params);
    }
  }

  void trackRestorePurchaseWithProductIdentifier(String productId) async {
    // Check if restore has already been tracked
    bool hasTrackedBefore = await hasFlagBeenSetBefore(
      ARAnalyticsConstants.USERDEFAULTS_PURCHASE_TRACKED_BEFORE,
    );

    // If product ID is not empty, check product-specific flag
    if (productId.isNotEmpty) {
      hasTrackedBefore = await hasFlagBeenSetBefore(
        ARAnalyticsConstants
            .USERDEFAULTS_PURCHASE_TRACKED_BEFORE_WITH_PRODUCT_ID,
      );
    }

    if (!hasTrackedBefore) {
      print('Restore Purchase Made: $productId');

      markHasPurchased();

      final Map<String, dynamic> params = await getGlobalTrackingParameters();

      final String finalProductId = productId.isNotEmpty ? productId : 'N/A';
      params['productIdentifier'] = finalProductId;

      trackEventWithName('Purchase Restored', params);
    }
  }

  // MARK: - Event Tracking - Base Event Tracking Methods
  void trackEventWithName(
    String eventName,
    Map<String, dynamic>? params,
  ) async {
    if (await _isPrivacyConsentRequiredButNotProvided()) return;

    final allParams = await getGlobalTrackingParameters();
    for (final entry in params?.entries ?? <MapEntry<String, dynamic>>[]) {
      allParams[entry.key] = entry.value;
    }

    amplitude.track(BaseEvent(eventName));
    amplitude.flush();

    // Track in Firebase
    // ARCrashTracking.trackEventWithName(trackEventWithName: eventName, andParams: params);
  }

  void trackEventOnce(String eventName, Map<String, dynamic>? params) async {
    if (await _isPrivacyConsentRequiredButNotProvided()) return;

    bool hasTrackedBefore = await hasFlagBeenSetBefore(
      ARAnalyticsConstants.USERDEFAULTS_TRACK_ONE_TIME_EVENT,
    );

    if (eventName.isNotEmpty) {
      hasTrackedBefore = await hasFlagBeenSetBefore(
        '${ARAnalyticsConstants.USERDEFAULTS_TRACK_ONE_TIME_EVENT}$eventName',
      );
    }

    if (hasTrackedBefore) {
      // ARCrashTracking.trackEventWithName(trackEventWithName: eventName, andParams: params);
      return;
    }

    trackEventWithName(eventName, params);
  }

  void trackEventWithThrottling(
    String? eventName,
    Map<String, dynamic>? params,
  ) async {
    if (await _isPrivacyConsentRequiredButNotProvided()) return;

    // Always track the event once for the first time
    bool hasTrackedBefore = await hasFlagBeenSetBefore(
      ARAnalyticsConstants.USERDEFAULTS_TRACK_ONE_TIME_EVENT,
    );

    if (eventName != null && eventName.isNotEmpty) {
      hasTrackedBefore = await hasFlagBeenSetBefore(
        '${ARAnalyticsConstants.USERDEFAULTS_TRACK_ONE_TIME_EVENT_WITH_NAME}$eventName',
      );
    }

    if (!hasTrackedBefore) {
      trackEventWithName(eventName ?? '', params);
      return;
    }

    // If it's been tracked before, we use throttling — only track if it meets the criteria
    double throttlingFactorConfig = ARConfig.shared
        .getAnalyticsEventThrottlingFactor();

    // Uncomment if needed:
    // double eventSpecificThrottlingFactorConfig = ARConfig.getAnalyticsEventThrottlingFactorForEventName(eventName ?? "");
    // if (eventSpecificThrottlingFactorConfig > -1) {
    //   throttlingFactorConfig = eventSpecificThrottlingFactorConfig;
    // }

    final throttlingFactor = (throttlingFactorConfig * 100).toInt();
    final randomNum = Random().nextInt(100) + 1; // 1 to 100

    // Track the event only if random number is within throttling range
    if (randomNum <= throttlingFactor) {
      trackEventWithName(eventName ?? 'No event name', params);
    }
  }

  Future<Map<String, dynamic>> getGlobalTrackingParameters() async {
    final Map<String, dynamic> params = {
      'numCheckins': ARAnalytics.getNumCheckIns(),
      'numSessions': ARAnalytics.getNumSessions(),
      'numGoal1': ARAnalytics.getNumGoal1(),
      'numPurchases': ARAnalytics.getNumPurchases(),
      'hasPurchased': ARAnalytics.hasUserPurchased(),
      // 'isJailbroken': ARAnalytics.isJailbroken(),
      // 'isJailbroken2': ARAnalytics.isJailbroken2(),
      'isJailbrokenAny': ARAnalytics.isJailbrokenAny(),
      'isUserEngaged': ARAnalytics.getUserEngagedState(),
      'purchaseVCMode': ARConfig.shared.purchaseVCMode,
      'proFeaturesMode': ARConfig.shared.getproFeaturesMode(),
      'userType': ARConfig.shared.getCurrentUserTypeAsString(),
      'abTestName': ARConfig.shared.configABTestConfigName(),
      'abTestValue': ARConfig.shared.getCurrentAbTestValue(),
      'configMarker': ARConfig.shared.config_configMarker(),
      // 'sessionSource': getCurrentAppSessionSourceString(),
    };

    // New params added for Repost2
    // params['isLegacyUser'] = ARAppKit.shared.isLegacyRepostUser();
    params['isRepost2'] = true;
    // params['proDetermMode'] = ARProductManager.shared.userSubscriptionDeterminationModeAsString();
    params['isProUser'] = ARProductManager().isProUser();
    // params['numPosts'] = ARAnalytics.getNumPostsInFeed();
    // params['legacyUpgradeVersion'] = ARAnalytics.shared.legacyUpgradeVersion();
    // params['legacyUpgradeBuild'] = ARAnalytics.shared.legacyUpgradeBuild();
    // params['isProUser_cached'] = ARProductManager.shared.cached_isProUser;
    // params['isGoldUser_cached'] = ARProductManager.shared.cached_isGoldUser;

    String plan = 'free';
    if (await ARProductManager().cached_isProUser()) {
      plan = 'pro';
    }
    if (await ARProductManager().cached_isGoldUser()) {
      plan = 'gold';
    }
    params['subscriptionPlan'] = plan;
    params['sessionSource'] = getCurrentAppSessionSourceString();

    final DateTime? lastUpdate =
        await ARAnalytics.getLastAppSessionSourceUpdateTime();
    if (lastUpdate != null) {
      final String lastUpdateString = ARAnalytics.shared.formattedISO8601Date(
        lastUpdate,
      );
      params['sessionSourceLastUpdate'] = lastUpdateString;
    }

    final String appSessionSourceParam = _appSessionSourceParam;
    params['sessionSourceParam'] = appSessionSourceParam;
    params['timestamp'] = formattedISO8601NowDate();

    // Track ASA conversion details (currently commented)
    // params['af_installType'] = ARAttribution.getAppsFlyerInstallType();
    // params['af_mediaSource'] = ARAttribution.getAppsFlyerInstallMediaSource();
    // params['af_campaign'] = ARAttribution.getAppsFlyerInstallCampaign();

    final String country = await ARAnalytics.currentLocaleCountry();
    params['localeDevice'] = country;
    params['localeLang'] = ARAnalytics.currentLocaleCountry();

    // Simulate push notification status
    final bool pushAuthorized = true;
    params['pushAuthorized'] = pushAuthorized;

    final Map<String, dynamic> installParams =
        await ARAnalytics.getInstallMetadata();
    params.addAll(installParams);

    assert(() {
      print("GLOBAL TRACKING PARAMS: $params");
      return true;
    }());

    return params;
  }

  Future<Map<String, String>> getUserIdentifiersDictionary() async {
    final Map<String, String> params = {};

    // Use Dart null-checking to prevent null values in map
    final String afUid = await ARAttribution.shared.getAppsFlyerUID();
    if (afUid != '') {
      params['af_uid'] = afUid;
    }

    // Uncomment and implement if using Facebook SDK
    // final String? fbUid = LTFacebook.shared.usersFacebookAnonymousID();
    // if (fbUid != null) {
    //   params['fb_uid'] = fbUid;
    // }

    final String? rcUid = await ARProductManager().revenueCatUserId();
    if (rcUid != null) {
      params['rc_uid'] = rcUid;
    }

    final String ltUid = await ARAnalytics.shared.getARUserId();
    params['lt_uid'] = ltUid;

    // let os_uid = swiftExpose.oneSignalId
    final String osUid = ''; // Stubbed OneSignal ID
    params['os_uid'] = osUid;

    return params;
  }

  Future<String> getARUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString('ARUserId');

    if (value == null || value.length < 2) {
      value = randomString(length: 10);
      await prefs.setString('ARUserId', value);
    }

    return value;
  }

  Future<void> clearARUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('ARUserId');
  }

  String randomString({required int length}) {
    const String letters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random.secure();
    return List.generate(
      length,
      (_) => letters[random.nextInt(letters.length)],
    ).join();
  }

  // MARK: - Event Tracking - Facebook & Purchase SDK Tracking Methods
  //     // Helper methods
  //   static bool isPrivacyConsentRequiredButNotProvided() {
  //     // Implement your privacy consent logic here
  //     return false;
  //   }

  //   static bool isJailbrokenAny() {
  //     // Implement jailbreak detection logic here
  //     return false;
  //   }

  //   static bool shouldTrackPurchasesOnFacebook() {
  //     // Implement your tracking permission logic here
  //     return true;
  //   }

  //   // Product-related methods (mock implementations)
  //   static ProductManager get sharedInstance => ProductManager();

  //   static void trackError({required String withName}) {
  //     // Implement error tracking
  //     print('Error tracked: $withName');
  //   }

  //   static void trackEventOnce(String eventName, {Map<String, dynamic>? withParams}) {
  //     // Implement your event tracking logic
  //     print('Tracked event once: $eventName with params: $withParams');
  //   }
  // }

  // class ProductManager {
  //   SKProduct? getSKProduct({required String withIdentifier}) {
  //     // Implement your product retrieval logic
  //     return null;
  //   }

  //   Product? getProduct({required String withIdentifier}) {
  //     // Implement your product retrieval logic
  //     return null;
  //   }

  //   List<String> getFacebookProductIdentifierStringArray({required String forProductWithIdentifier}) {
  //     // Implement your product ID conversion logic
  //     return [forProductWithIdentifier];
  //   }
  // }

  // class SKProduct {
  //   final double price;
  //   final Locale priceLocale;
  //   final String? localizedTitle;

  //   SKProduct({
  //     required this.price,
  //     required this.priceLocale,
  //     this.localizedTitle,
  //   });
  // }

  // class Product {
  //   final bool isSubscription;
  //   final double subscriptionMultiple;

  //   Product({
  //     required this.isSubscription,
  //     required this.subscriptionMultiple,
  //   });
  // }

  // class Locale {
  //   final String languageCode;
  //   final String countryCode;

  //   Locale({required this.languageCode, required this.countryCode});
  // }

  // // Main implementation
  // void trackFacebookAnd3rdPartySDKEventPurchase({required String withProductIdentifier}) {
  //   if (ARAnalytics.isPrivacyConsentRequiredButNotProvided()) return;

  //   if (withProductIdentifier.isEmpty) return;

  //   if (ARAnalytics.isJailbrokenAny()) {
  //     print("ARAnalytics - NOT TRACKING JAILBROKEN PURCHASE ON FACEBOOK. Skipping...");
  //     return;
  //   }

  //   final product = ARAnalytics.sharedInstance.getSKProduct(withIdentifier: withProductIdentifier);
  //   if (product == null) {
  //     print("ARAnalytics - no skproduct found when tracking on facebook. Skipping...");
  //     ARAnalytics.trackError(withName: "ERROR_ARAnalytics_trackFacebookAnd3rdPartySDKEventPurchaseWithProductIdentifier");
  //     return;
  //   }

  //   // Set up the required parameters
  //   double priceOriginal = product.price;
  //   double priceProfit = priceOriginal * 0.7;

  //   // Adjust profit by the subscription multiple
  //   final ltProduct = ARAnalytics.sharedInstance.getProduct(withIdentifier: withProductIdentifier);
  //   if (ltProduct != null && ltProduct.isSubscription) {
  //     final subscriptionMultiple = ltProduct.subscriptionMultiple;
  //     if (subscriptionMultiple > 0.1) {
  //       priceProfit *= subscriptionMultiple;
  //     }
  //   }

  //   final productTitle = product.localizedTitle;
  //   final contentType = "product";
  //   final numItems = 1;
  //   final productIdentifierArray = ARAnalytics.sharedInstance
  //       .getFacebookProductIdentifierStringArray(forProductWithIdentifier: withProductIdentifier);

  //   // Currency Code
  //   final formatter = NumberFormat.currency(locale: '${product.priceLocale.languageCode}_${product.priceLocale.countryCode}');
  //   final currencyCode = formatter.currencySymbol ?? "USD";

  //   var params = <String, dynamic>{
  //     'fb_content_id': productIdentifierArray,
  //     'fb_num_items': numItems,
  //     'fb_content_type': contentType,
  //     'fb_description': productTitle ?? "",
  //   };

  //   if (productTitle != null) {
  //     params["Product Title"] = productTitle;
  //   }

  //   if (ARAnalytics.shouldTrackPurchasesOnFacebook()) {
  //     ARAnalytics.facebookAppEvents.logPurchase(
  //       amount: priceProfit,
  //       currency: currencyCode,
  //       parameters: params,
  //     );
  //     ARAnalytics.facebookAppEvents.flush();
  //   }
  // }

  // void trackFacebookAddedToCart({required String forProductWithIdentifier}) {
  //   if (ARAnalytics.isPrivacyConsentRequiredButNotProvided()) return;

  //   if (ARAnalytics.isJailbrokenAny()) return;

  //   final product = ARAnalytics.sharedInstance.getSKProduct(withIdentifier: forProductWithIdentifier);
  //   if (product == null) return;

  //   // Set up the required parameters
  //   double priceOriginal = product.price;
  //   double priceProfit = priceOriginal * 0.7;

  //   // Adjust profit by the subscription multiple
  //   final ltProduct = ARAnalytics.sharedInstance.getProduct(withIdentifier: forProductWithIdentifier);
  //   if (ltProduct != null && ltProduct.isSubscription) {
  //     final subscriptionMultiple = ltProduct.subscriptionMultiple;
  //     if (subscriptionMultiple > 0.1) {
  //       priceProfit *= subscriptionMultiple;
  //     }
  //   }

  //   final contentType = "product";
  //   priceProfit = 0; // Disabled as per original code

  //   // Currency Code
  //   final formatter = NumberFormat.currency(locale: '${product.priceLocale.languageCode}_${product.priceLocale.countryCode}');
  //   final currencyCode = formatter.currencySymbol ?? "USD";

  //   if (ARAnalytics.shouldTrackPurchasesOnFacebook()) {
  //     ARAnalytics.facebookAppEvents.logEvent(
  //       name: 'fb_mobile_add_to_cart',
  //       value: priceProfit,
  //       parameters: {
  //         'fb_currency': currencyCode,
  //         'fb_content_type': contentType,
  //         'fb_content_id': forProductWithIdentifier,
  //       },
  //     );
  //   }

  //   var params = <String, dynamic>{};
  //   if (forProductWithIdentifier.isNotEmpty) {
  //     params["productId"] = forProductWithIdentifier;
  //   }
  //   ARAnalytics.trackEventOnce("Checkout Started", withParams: params);
  // }

  // void trackFacebookViewedContent({required String forProductWithIdentifier}) {
  //   if (ARAnalytics.isPrivacyConsentRequiredButNotProvided()) return;

  //   final contentType = "product";
  //   if (forProductWithIdentifier.isEmpty) {
  //     print("ARAnalytics - no productId found when tracking on facebook. Skipping...");
  //     ARAnalytics.trackError(withName: "ERROR_ARAnalytics_trackPurchaseOnFacebook_noSKProduct");
  //     return;
  //   }

  //   if (ARAnalytics.isJailbrokenAny()) return;

  //   if (ARAnalytics.shouldTrackPurchasesOnFacebook()) {
  //     ARAnalytics.facebookAppEvents.logEvent(
  //       name: 'fb_mobile_content_view',
  //       parameters: {
  //         'fb_content_id': forProductWithIdentifier,
  //         'fb_content_type': contentType,
  //       },
  //     );
  //   }

  // MARK: - Deep Linking Methods
  void handleDeepLink({
    required Uri url,
    String? sourceApplication,
    Object? annotation,
  }) {
    // NOT IMPLEMENTED - can be implemented with a deep linking tool
    // and if we need promotions to specific purchase pages or similar
    // Handle deep link
  }

  bool continueUserActivity({required Object userActivity}) {
    // NOT IMPLEMENTED
    return true;
  }

  // MARK: - User Properties Updating
  void updateUserProperties() async {
    // FIRST SET ONE TIME PARAMETERS
    final oneTimeParams = await ARAnalytics.getInstallMetadata();

    final identify = Identify();

    oneTimeParams.forEach((key, value) {
      identify.set(key, value);
    });

    await amplitude.identify(identify);

    final params = await getGlobalTrackingParameters();
    final Map<String, dynamic> amplitudeParams = Map.from(params);

    // Add additional values
    amplitudeParams['isProUser'] = ARProductManager().isProUser();
    amplitudeParams['activeSubscriptionIds'] = ARProductManager()
        .activeSubscriptionProductIds();

    final identify2 = Identify();
    amplitudeParams.forEach((key, value) {
      identify2.add(key, value);
    });

    await amplitude.identify(identify2);
  }

  // MARK: - Helper Methods
  static Future<Map<String, dynamic>?> config() async {
    // TODO: Add logic here
    return null; // or return {}; for an empty map
  }

  String formattedISO8601Date(DateTime date) {
    final formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", 'en_US');
    return formatter.format(date.toUtc());
  }

  String formattedISO8601NowDate() {
    return formattedISO8601Date(DateTime.now());
  }

  DateTime? dateFromISO8601DateString(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  //   bool shouldTrackPurchasesOnFacebook() {
  //   // Simulate the same ARConfig2.sharedInstance().fb_logPurchasesManually
  //   final value = ARConfig2.instance.fbLogPurchasesManually;
  //   return value ?? true; // fallback to true if null
  // }

  Future<String> getAmplitudeKeyFromConfig() async {
    final configMap = await config();
    final configElements = configMap?["Analytics"] as Map<String, dynamic>?;

    if (configElements == null) return "";

    String keyName;

    const bool isDebug =
        bool.fromEnvironment('dart.vm.product') == false; // true in debug/dev
    const bool isBeta = bool.fromEnvironment('BETA_BUILD'); // optional custom

    if (isDebug) {
      keyName = "AmplitudeTokenDev";
    } else if (isBeta) {
      keyName = "AmplitudeTokenBeta";
    } else {
      keyName = "AmplitudeTokenProd";
    }

    final key = configElements[keyName] as String?;
    return key ?? "";
  }

  Future<String?> get appId async {
    final config = await ARAnalytics.config();
    final common = config?['Common'];
    if (common is Map<String, dynamic>) {
      final appId = common['AppId'];
      if (appId is String) {
        return appId;
      }
    }
    return null;
  }

  int getRandomNumber({required int from, required int to}) {
    return from + Random().nextInt(to - from + 1);
  }

  Future<bool> isVPNOn() async {
    try {
      final bool result = await _vpnChannel.invokeMethod('isVPNOn');
      return result;
    } catch (e) {
      return false;
    }
  }

  // MARK: - User Defaults for Tracking
  Future<bool> hasFlagBeenSetBefore(String flag) async {
    final prefs = await SharedPreferences.getInstance();
    final flagValue = prefs.getString(flag);
    if (flagValue == null) {
      await prefs.setString(flag, "set");
      return false;
    }
    return true;
  }

  static Future<bool> hasUserCheckedInToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckInStr = prefs.getString('lastUserCheckInDate');

    if (lastCheckInStr == null) {
      await updateLastUserCheckInDateStatic();
      print("hasUserCheckedInToday was null, returning true...");
      return true;
    }

    await updateLastUserCheckInDateStatic();

    final lastCheckInDate = DateTime.tryParse(lastCheckInStr);
    if (lastCheckInDate == null) {
      return false;
    }

    final now = DateTime.now();
    final isSameDay =
        now.year == lastCheckInDate.year &&
        now.month == lastCheckInDate.month &&
        now.day == lastCheckInDate.day;

    print("hasUserCheckedInToday result = $isSameDay");
    return isSameDay;
  }

  static Future<void> updateLastUserCheckInDateStatic() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'lastUserCheckInDate',
      DateTime.now().toIso8601String(),
    );
  }

  static Future<String> hasUserPurchased() async {
    final prefs = await SharedPreferences.getInstance();
    final result = prefs.getBool(
      ARAnalyticsConstants.USERDEFAULTS_HASUSERPURCHASED,
    );
    if (result != null) {
      return result.toString(); // returns "true" or "false"
    }
    return "undefined";
  }

  static Future<int> getNumPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    final result = prefs.getInt(
      ARAnalyticsConstants.USERDEFAULTS_USERPURCHASECOUNT,
    );
    if (result != null) {
      return result;
    }
    return -1;
  }

  Future<void> updateLastUserCheckInDate() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    await prefs.setString(
      ARAnalyticsConstants.USERDEFAULTS_USER_LAST_CHECKIN_DATE,
      now,
    );
    print("latestImageFetchDate set new date: $now");
  }

  Future<DateTime?> getLastUserCheckInDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(
      ARAnalyticsConstants.USERDEFAULTS_USER_LAST_CHECKIN_DATE,
    );
    if (dateString != null) {
      final date = DateTime.tryParse(dateString);
      if (date != null) {
        print("lastUserCheckInDate: $date");
        return date;
      }
    }
    return null;
  }

  static Future<void> updateLastAppSessionSourceUpdateTime() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    await prefs.setString(
      ARAnalyticsConstants.USERDEFAULTS_LAST_APP_SESSION_SOURCE_UPDATE,
      now,
    );
  }

  static Future<DateTime?> getLastAppSessionSourceUpdateTime() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(
      ARAnalyticsConstants.USERDEFAULTS_LAST_APP_SESSION_SOURCE_UPDATE,
    );
    if (dateString != null) {
      return DateTime.tryParse(dateString);
    }
    return null;
  }

  Future<String> getUserPhotographerType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(
          ARAnalyticsConstants.USERDEFAULTS_USER_PHOTOGRAPHER_TYPE,
        ) ??
        'N/A';
  }

  Future<String> getUserPhotoType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(ARAnalyticsConstants.USERDEFAULTS_USER_PHOTO_TYPE) ??
        'N/A';
  }

  static Future<int> incrementNumCheckIns() async {
    final prefs = await SharedPreferences.getInstance();
    int num = prefs.getInt(ARAnalyticsConstants.USERDEFAULTS_NUM_CHECKINS) ?? 0;
    num += 1;
    await prefs.setInt(ARAnalyticsConstants.USERDEFAULTS_NUM_CHECKINS, num);
    return num;
  }

  static Future<int> incrementNumSessions() async {
    final prefs = await SharedPreferences.getInstance();
    int num =
        prefs.getInt(ARAnalyticsConstants.USERDEFAULTS_NUM_SESSIONS) ?? -1;
    num += 1;
    await prefs.setInt(ARAnalyticsConstants.USERDEFAULTS_NUM_SESSIONS, num);
    return num;
  }

  static Future<int> getNumCheckIns() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(ARAnalyticsConstants.USERDEFAULTS_NUM_CHECKINS) ?? 0;
  }

  Future<void> setNumCheckIns(int numCheckins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      ARAnalyticsConstants.USERDEFAULTS_NUM_CHECKINS,
      numCheckins,
    );
  }

  static Future<int> getNumSessions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(ARAnalyticsConstants.USERDEFAULTS_NUM_SESSIONS) ?? 0;
  }

  Future<void> setUserPhotographerType([String type = "N/A"]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      ARAnalyticsConstants.USERDEFAULTS_USER_PHOTOGRAPHER_TYPE,
      type,
    );
  }

  static Future<void> setUserPhotoType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      ARAnalyticsConstants.USERDEFAULTS_USER_PHOTO_TYPE,
      type,
    );
  }

  static Future<void> markHasPurchased() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      ARAnalyticsConstants.USERDEFAULTS_HASUSERPURCHASED,
      true,
    );
  }

  static Future<void> markHasNotPurchased() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      ARAnalyticsConstants.USERDEFAULTS_HASUSERPURCHASED,
      false,
    );
  }

  static Future<void> resetNumPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(ARAnalyticsConstants.USERDEFAULTS_USERPURCHASECOUNT, 0);
  }

  // Goal 1 methods
  static Future<int> incrementNumGoal1() async {
    final prefs = await SharedPreferences.getInstance();
    int num = prefs.getInt(ARAnalyticsConstants.USERDEFAULTS_NUM_GOAL1) ?? 0;
    num += 1;
    await prefs.setInt(ARAnalyticsConstants.USERDEFAULTS_NUM_GOAL1, num);
    return num;
  }

  static Future<int> getNumGoal1() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(ARAnalyticsConstants.USERDEFAULTS_NUM_GOAL1) ?? 0;
  }

  static Future<void> setNumGoal1(int goal1) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(ARAnalyticsConstants.USERDEFAULTS_NUM_GOAL1, goal1);
  }

  // Goal 2 methods
  static Future<int> incrementNumGoal2() async {
    final prefs = await SharedPreferences.getInstance();
    int num = prefs.getInt(ARAnalyticsConstants.USERDEFAULTS_NUM_GOAL2) ?? 0;
    num += 1;
    await prefs.setInt(ARAnalyticsConstants.USERDEFAULTS_NUM_GOAL2, num);
    return num;
  }

  static Future<int> getNumGoal2() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(ARAnalyticsConstants.USERDEFAULTS_NUM_GOAL2) ?? 0;
  }

  static Future<int> getNumPostsInFeed() async {
    final prefs = await SharedPreferences.getInstance();
    int num = prefs.getInt(ARAnalyticsConstants.USERDEFAULTS_NUM_POSTS) ?? 0;
    return num;
  }

  static Future<void> setNumPostsInFeed(int numPosts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(ARAnalyticsConstants.USERDEFAULTS_NUM_POSTS, numPosts);
  }

  // User engagement state
  static Future<int> getUserEngagedState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(ARAnalyticsConstants.USERDEFAULTS_IS_USER_ENGAGED) ??
        -1;
  }

  static Future<void> setUserEngagedState({required bool engaged}) async {
    final prefs = await SharedPreferences.getInstance();
    final int result = engaged ? 1 : 0;
    await prefs.setInt(
      ARAnalyticsConstants.USERDEFAULTS_IS_USER_ENGAGED,
      result,
    );
  }

  static Future<bool> isUserEngaged() async {
    final prefs = await SharedPreferences.getInstance();
    final int? value = prefs.getInt(
      ARAnalyticsConstants.USERDEFAULTS_IS_USER_ENGAGED,
    );
    return value == 1;
  }

  static Future<bool> isJailbroken() async {
    try {
      final bool isJailbroken = await FlutterJailbreakDetection.jailbroken;
      return isJailbroken;
    } catch (e) {
      // If there's an error (e.g. unsupported device), treat as not jailbroken
      return false;
    }
  }

  static bool isJailbroken2() {
    // Jailbreak detection logic (mocked as false for now)
    return false;
  }

  static Future<bool> isJailbrokenAny() async {
    final bool result1 = await isJailbroken();
    final bool result2 = isJailbroken2();
    return result1 || result2;
  }

  static Future<String> currentLocaleCountry() async {
    try {
      await CountryCodes.init(); // Initialize once before accessing
      final countryDetails = CountryCodes.detailsForLocale();
      return countryDetails.name ?? ""; // Full country name like "India"
    } catch (e) {
      return ""; // fallback in case of error
    }
  }

  static Future<DateTime?> get installDate async {
    final params = await ARAnalytics.getInstallMetadata();

    final installDateISO = params["installTimestamp"];
    if (installDateISO is! String) return null;

    return ARAnalytics.shared.dateFromISO8601DateString(installDateISO);
  }

  static Future<Map<String, dynamic>> getInstallMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    final storedJson = prefs.getString(
      ARAnalyticsConstants.USERDEFAULTS_INSTALL_METADATA,
    );
    Map<String, dynamic> params = {};

    if (storedJson != null) {
      try {
        params = jsonDecode(storedJson);
      } catch (_) {
        params = {};
      }
    }

    if (params.isEmpty) {
      final nowISO = ARAnalytics.shared.formattedISO8601NowDate();
      final packageInfo = await PackageInfo.fromPlatform();

      params["installTimestamp"] = nowISO;
      params["installVersion"] = packageInfo.version;
      params["installBuild"] = packageInfo.buildNumber;
      params["bundleIdentifier"] = packageInfo.packageName;

      await prefs.setString(
        ARAnalyticsConstants.USERDEFAULTS_INSTALL_METADATA,
        jsonEncode(params),
      );
    }

    // Add daysSinceInstall if installTimestamp exists
    final installDateISO = params["installTimestamp"];
    if (installDateISO is String) {
      final installDate = ARAnalytics.shared.dateFromISO8601DateString(
        installDateISO,
      );
      if (installDate != null) {
        final now = DateTime.now().toUtc();
        final daysSince = now.difference(installDate).inDays;
        params["daysSinceInstall"] = daysSince;
      }
    }

    // Always update current version/build
    final packageInfo = await PackageInfo.fromPlatform();
    params["currentVersion"] = packageInfo.version;
    params["currentBuild"] = packageInfo.buildNumber;

    return params;
  }

  static Future<double> getInstallVersion() async {
    final params = await ARAnalytics.getInstallMetadata();
    final installString = params["installVersion"] as String? ?? "-1.0";
    return double.tryParse(installString) ?? -1.0;
  }

  static Future<String> getInstallVersionString() async {
    final params = await ARAnalytics.getInstallMetadata();
    final installString = params["installVersion"] as String? ?? "";
    return installString;
  }

  static Future<int> getDaysSinceInstall() async {
    final params = await ARAnalytics.getInstallMetadata();
    final installDateISO = params["installTimestamp"] as String? ?? "";
    final installDate =
        ARAnalytics.shared.dateFromISO8601DateString(installDateISO) ??
        DateTime.now();
    final duration = DateTime.now().difference(installDate);
    return duration.inDays;
  }

  Future<bool> isLegacyAppUser({required double cutoffVersion}) async {
    final installedVersion = await ARAnalytics.getInstallVersion();
    return installedVersion > -1 && installedVersion < cutoffVersion;
  }

  Future<void> trackLegacyAppUpgrade() async {
    trackEventOnce("Legacy Upgrade Detected", null);

    final hasTrackedBefore = await ARAnalytics.shared.hasFlagBeenSetBefore(
      ARAnalyticsConstants.USERDEFAULTS_LEGACY_UPDATE_VERSION_TRACKED_BEFORE,
    );

    if (!hasTrackedBefore) {
      final prefs = await SharedPreferences.getInstance();
      final packageInfo = await PackageInfo.fromPlatform();

      final currentVersion = packageInfo.version;
      final currentBuild = packageInfo.buildNumber;

      await prefs.setString(
        ARAnalyticsConstants.USERDEFAULTS_LEGACY_UPDATE_VERSION,
        currentVersion,
      );
      await prefs.setString(
        ARAnalyticsConstants.USERDEFAULTS_LEGACY_UPDATE_BUILD,
        currentBuild,
      );
    }
  }

  Future<String> getLegacyUpgradeVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(
          ARAnalyticsConstants.USERDEFAULTS_LEGACY_UPDATE_VERSION,
        ) ??
        "-1";
  }

  Future<String> getLegacyUpgradeBuild() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(
          ARAnalyticsConstants.USERDEFAULTS_LEGACY_UPDATE_BUILD,
        ) ??
        "-1";
  }

  // MARK: - User Data - Opt in opt out methods

  // User Data Management
  void userOptOutOfTracking() {
    trackEventWithName("Opt Out Tracking", null);
    setUserTrackingOptedInStatus(userOptedIn: false);

    amplitude.configuration.optOut = true;

    ARAttribution.shared.optOutAppsFlyer();

    // ARCrashTracking.shared.optOutService();

    // Opt-out from other services
    // Example for Amplitude:
    // Amplitude.getInstance().setOptOut(true);
  }

  void userOptInForTracking() {
    setUserTrackingOptedInStatus(userOptedIn: true);

    amplitude.configuration.optOut = false;

    ARAttribution.shared.optOutAppsFlyer();

    // ARCrashTracking.shared.optOutService();
  }

  Future<void> toggleTrackingStatus() async {
    final isOptedIn = await getUserTrackingOptedInStatus();

    if (isOptedIn) {
      userOptOutOfTracking();
    } else {
      userOptInForTracking();
    }
  }

  Future<bool> getUserTrackingOptedInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final flag = prefs.getBool('UserTrackingOptedInStatus');

    if (flag != null) {
      return flag;
    } else {
      final isInEU = await isUserInEU();
      if (isInEU) {
        setUserTrackingOptedInStatus(userOptedIn: false);
        return false;
      } else {
        setUserTrackingOptedInStatus(userOptedIn: true);
        return true;
      }
    }
  }

  Future<void> setUserTrackingOptedInStatus({bool? userOptedIn}) async {
    final prefs = await SharedPreferences.getInstance();

    if (userOptedIn != null) {
      await prefs.setBool('UserTrackingOptedInStatus', true);
    } else {
      await prefs.setBool('UserTrackingOptedInStatus', false);
    }

    // SharedPreferences doesn't need explicit "synchronize" like iOS UserDefaults.
    print('UserTrackingOptedInStatus set to: ${userOptedIn != null}');
  }

  // MARK: - User Data Management Methods

  // Future<void> deleteUserDataWithCompletionBlock(
  //   Future<void> Function({
  //     required bool success,
  //     Object? error,
  //     Object? object,
  //   })
  //   block,
  // ) async {
  //   try {
  //     // 1. Retrieve required IDs
  //     final oneSignalUserId = await SwiftExpose().oneSignalId;
  //     final mixpanelDistinctId = await AnalyticsIdentifiers.mixpanelDistinctID;
  //     final mmpId = await AnalyticsIdentifiers.mmpId;

  //     // 2. Link to backend class (LTUserManager equivalent)
  //     final success = await LTUserManager.shared.createUserDeletionRequest(
  //       mixpanelDistinctId: mixpanelDistinctId,
  //       oneSignalUserId: oneSignalUserId,
  //       mmpId: mmpId,
  //     );

  //     // 3. Fire callback
  //     await block(success: success, error: null, object: null);
  //   } catch (e) {
  //     await block(success: false, error: e, object: null);
  //   }

  //   // TODO: AppsFlyer deletion if applicable

  //   // 4. Opt out of tracking after deletion
  //   userOptOutOfTracking();
  // }

  Future<bool> isUserInEU() async {
    // ✅ Debug mode override (same as #if DEBUG)
    if (kDebugMode) {
      return true;
    }

    // ✅ Check timezone
    final String timezone = await FlutterNativeTimezone.getLocalTimezone();
    const euTimeZones = [
      "Europe/Vienna",
      "Europe/Brussels",
      "Europe/Sofia",
      "Europe/Zagreb",
      "Asia/Nicosia",
      "Europe/Prague",
      "Europe/Copenhagen",
      "Europe/Tallinn",
      "Europe/Helsinki",
      "Europe/Paris",
      "Europe/Berlin",
      "Europe/Athens",
      "Europe/Budapest",
      "Europe/Dublin",
      "Europe/Rome",
      "Europe/Riga",
      "Europe/Vilnius",
      "Europe/Luxembourg",
      "Europe/Malta",
      "Europe/Amsterdam",
      "Europe/Warsaw",
      "Europe/Lisbon",
      "Europe/Bucharest",
      "Europe/Bratislava",
      "Europe/Ljubljana",
      "Europe/Madrid",
      "Europe/Stockholm",
      "Europe/London",
      "Atlantic/Reykjavik",
      "Europe/Vaduz",
      "Europe/Oslo",
    ];

    if (euTimeZones.contains(timezone)) {
      return true;
    }

    // ✅ Region code fallback
    final locale = Platform.localeName; // e.g., "en_GB"
    final countryCode = locale.split('_').length > 1
        ? locale.split('_')[1]
        : '';

    const euCountryCodes = [
      "AT",
      "BE",
      "BG",
      "HR",
      "CY",
      "CZ",
      "DK",
      "EE",
      "FI",
      "FR",
      "DE",
      "GR",
      "HU",
      "IE",
      "IT",
      "LV",
      "LT",
      "LU",
      "MT",
      "NL",
      "PL",
      "PT",
      "RO",
      "SK",
      "SI",
      "ES",
      "SE",
      "GB",
      "IS",
      "LI",
      "NO",
    ];

    return euCountryCodes.contains(countryCode);
  }

  Future<bool> _isPrivacyConsentRequiredButNotProvided() async {
    final isOptedIn = await getUserTrackingOptedInStatus();

    return !isOptedIn;
  }

  Future<bool> shouldShowPrivacyConsentForm() async {
    final isInEU = await isUserInEU();

    if (!isInEU) {
      return false;
    }

    return !(await isConsentFormCompleted());
  }

  Future<bool> isConsentFormCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('PrivacyConsentFormCompleted') ?? false;
  }

  void trackConsentFormPresented() {
    trackEventWithName("Consent Form Presented", null);
  }

  Future<void> markConsentFormAsCompleted() async {
    // Step 1: Opt the user in for tracking
    userOptInForTracking();

    // Step 2: Track the consent event
    trackEventWithName("Consent Form Completed", null);

    // Step 3: Check if the consent form was already completed
    final prefs = await SharedPreferences.getInstance();
    final alreadyCompleted =
        prefs.getBool('PrivacyConsentFormCompleted') ?? false;

    if (!alreadyCompleted) {
      // Mark consent form as completed
      await prefs.setBool('PrivacyConsentFormCompleted', true);

      // Step 4: Perform one-time setup after consent
      await performOneTimeConsentProvidedActions();
    }
  }

  Future<void> setTermsFormCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('TermsFormCompleted', completed);
  }

  Future<void> trackTermsFormCompleted() async {
    // Step 1: Opt the user in for tracking
    userOptInForTracking();

    // Step 2: Track the event
    trackEventWithName("Terms Form Completed", null);

    // Step 3: Save flag to persistent storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('TermsFormCompleted', true);

    // No need for synchronize(); SharedPreferences writes immediately
  }

  Future<void> performOneTimeConsentProvidedActions() async {
    updateUserProperties();
    trackAppInstall(); // If no Branch SDK, ensure you log install event manually
    trackCheckIn();
  }

  // MARK: - App Session Source
  void clearAppSessionSource() {
    appSessionSource =
        ARAnalyticsAppSessionSource.ARAnalyticsAppSessionSource_None;
    _appSessionSourceParam = '';
  }

  void setAppSessionSource(ARAnalyticsAppSessionSource appSessionSource) {
    this.appSessionSource = appSessionSource;

    if (appSessionSource !=
        ARAnalyticsAppSessionSource.ARAnalyticsAppSessionSource_None) {
      ARAnalytics.updateLastAppSessionSourceUpdateTime();
    }
  }

  String getCurrentAppSessionSourceString() {
    switch (appSessionSource) {
      case ARAnalyticsAppSessionSource.ARAnalyticsAppSessionSource_None:
        return "undefined";
      case ARAnalyticsAppSessionSource.ARAnalyticsAppSessionSource_Push:
        return "push";
      case ARAnalyticsAppSessionSource.ARAnalyticsAppSessionSource_Deeplink:
        return "deepLink";
    }
  }

  String getAppSessionSourceParam() {
    if (_appSessionSourceParam == '') {
      _appSessionSourceParam = '';
    }

    if (_appSessionSourceParam.length > 40) {
      return _appSessionSourceParam.substring(0, 38);
    }

    return _appSessionSourceParam;
  }

  static DateTime? dateFromISO860DateString(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      return null;
    }
  }
}

enum ARAnalyticsAppSessionSource {
  ARAnalyticsAppSessionSource_None,
  ARAnalyticsAppSessionSource_Push,
  ARAnalyticsAppSessionSource_Deeplink,
}

class _AppLifecycleHandler extends WidgetsBindingObserver {
  final VoidCallback onResumed;
  final VoidCallback onPaused;

  _AppLifecycleHandler({required this.onResumed, required this.onPaused});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    } else if (state == AppLifecycleState.paused) {
      onPaused();
    }
  }
}
