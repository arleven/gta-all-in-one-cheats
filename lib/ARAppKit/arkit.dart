import 'package:flutter/material.dart';
import 'package:all_gta/ARAppKit/ARAnalytics/ARAnalytics.dart';
import 'package:all_gta/ARAppKit/ARAnalytics/ARCrashTracking.dart';
import 'package:all_gta/ARAppKit/ARConfig/ARConfig.dart';
import 'package:all_gta/ARAppKit/ARProduct_manager/ar_product_manager.dart';
import 'package:all_gta/ARAppKit/ARReview_Manager/ARReview_Manager.dart';

class ARAppKit {
  // MARK: - Static Methods
  static final ARAppKit shared = ARAppKit._internal();

  static void load() {
    shared;
  }

  ARAppKit._internal();

  void initializeServices() {
    ARProductManager();
    // SuperwallManager.shared;
  }

  // MARK: - App Lifecycle
  void initializeServicesRequiringLaunchOptions(
    Map<String, dynamic>? launchOptions,
  ) {
    ARAnalytics.shared.initializeServicesRequiringLaunchOptions(
      launchOptions: launchOptions,
    );
  }

  void performApplicationDidBecomeActiveActions() {
    ARAnalytics.shared.performApplicationDidBecomeActiveActions();
  }

  // MARK: - Analytics
  Future<String> getFirebaseAppInstanceId() async {
    final id = await ARCrashTracking.shared.getFirebaseAppInstanceId();
    return id ?? "";
  }

  Future<Map<String, dynamic>> getUserIdentifiersDictionary() async {
    return ARAnalytics.shared.getUserIdentifiersDictionary();
  }

  Future<String> getUserId() {
    return ARAnalytics.shared.getARUserId();
  }

  void trackOneTimeEventWithName(
    String eventName, {
    Map<String, dynamic>? params,
  }) {
    ARAnalytics.shared.trackEventOnce(eventName, params);
  }

  void trackEventWithName(String eventName, {Map<String, dynamic>? params}) {
    ARAnalytics.shared.trackEventWithName(eventName, params);
  }

  void trackEventWithThrottling(String eventName, Map<String, dynamic> params) {
    ARAnalytics.shared.trackEventWithThrottling(eventName, params);
  }

  Future<int> getNumCheckIns() {
    return ARAnalytics.getNumCheckIns();
  }

  Future<double> getInstallVersion() {
    return ARAnalytics.getInstallVersion();
  }

  // Tracks and increments 'goal 1' (e.g., number of scans by user)
  void trackGoal1() {
    ARAnalytics.shared.trackGoal1();
  }

  // Tracks and increments 'goal 2' (e.g., number of exports by user)
  void trackGoal2() {
    ARAnalytics.shared.trackGoal2();
  }

  // Sets goal 1 manually for apps that don't have a steadily increasing goal 1 - used by LTReview later. No tracking in this one
  void setNumGoal1(int goal1) {
    ARAnalytics.setNumGoal1(goal1);
  }

  // Find out if it is legacy app based on cutoff version number
  Future<bool> isLegacyAppUser(double cutoffVersion) {
    return ARAnalytics.shared.isLegacyAppUser(cutoffVersion: cutoffVersion);
  }

  Future<bool> isVPNOn() {
    return ARAnalytics.shared.isVPNOn();
  }

  // MARK: - Config
  dynamic configValue({required String key}) {
    return ARConfig.shared.configValueForKey(key);
  }

  // void setProFeaturesMode(ARConfig.ConfigProFeaturesMode mode, {required bool withOverwrite}) {
  //   ARConfig.shared.setProFeaturesMode(mode, withOverwrite: withOverwrite);
  // }

  // Map<String, dynamic> getUserIdentifiersDictionary() {
  //   return ARAnalytics.shared.getUserIdentifiersDictionary() ?? {};
  // }

  // MARK: - Review
  void startReviewRequestIfRequired(BuildContext context) {
    // #if DEBUG
    // Uncomment these lines for testing during development
    // ARReviewManager.sharedInstance().showHowWeDoingAlert();
    // ARReviewManager.sharedInstance().showWrittenReviewRequestAlert();
    // return;
    // #endif

    ARReviewManager.startReviewRequestIfRequired(context);
  }

  void showWrittenReviewRequestAlertOn({required dynamic viewController}) {
    ARReviewManager.shared.showWrittenReviewRequestAlertOn(viewController);
  }

  void showNativeAppRatingAlertOnceThisSession() {
    ARReviewManager.shared.showNativeAppRatingAlertOnceThisSession();
  }

  void showNativeAppRatingOnceEver() {
    ARReviewManager.showNativeAppRatingOnceEver();
  }

  void showNativeRatingRequestToNewUserIfRequired() {
    ARReviewManager.shared
        .showNativeRatingRequestToNewUserIfRequired_position1();
  }

  void showNativeRatingRequestToNewUserIfRequired_position2() {
    ARReviewManager.shared
        .showNativeRatingRequestToNewUserIfRequired_position2();
  }

  // MARK: - Privacy

  // MARK: - Purchases

  // Returns whether the user is a pro user via an active subscription using RevenueCat
  bool isProUser() {
    final arProductManager = ARProductManager();
    return arProductManager.isProUser();
  }

  // Performs necessary actions when purchases are updated
  void performPurchaseUpdatedActions() {
    ARProductManager().refreshCustomerInfo();
  }
}
