import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:all_gta/ARAppKit/ARAnalytics/arAnalytics_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_gta/ARAppKit/ARAnalytics/ARAnalytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:plist_parser/plist_parser.dart';

class ARAttribution {
  static final ARAttribution shared = ARAttribution._internal();

  AppsflyerSdk? _appsflyerSdk;

  ARAttribution._internal();

  factory ARAttribution() => shared;

  // Setup AppsFlyer SDK
  void initialize(AppsflyerSdk appsflyerSdk) {
    _appsflyerSdk = appsflyerSdk;
    _appsflyerSdk?.onInstallConversionData((data) {
      onConversionDataSuccess(data);
    });
  }

  void onConversionDataSuccess(Map<dynamic, dynamic> conversionInfo) {
    bool firstLaunchFlag = false;
    String? status;

    if (conversionInfo.containsKey("is_first_launch") &&
        conversionInfo["is_first_launch"] is bool) {
      firstLaunchFlag = conversionInfo["is_first_launch"];
      print(firstLaunchFlag);

      status = conversionInfo["af_status"];
      setAppsFlyerInstallType(status);

      if (status == "Non-organic") {
        final sourceID = conversionInfo["media_source"];
        final campaign = conversionInfo["campaign"];
        if (sourceID is String && campaign is String) {
          print(
            "This is a non-organic install. Media source: $sourceID Campaign: $campaign",
          );
          setAppsFlyerInstallCampaign(campaign);
          setAppsFlyerInstallMediaSource(sourceID);
        }
      } else {
        setAppsFlyerInstallCampaign("Organic");
        setAppsFlyerInstallMediaSource("Organic");
        print("This is an organic install.");
      }
    } else {
      print("Not first launch");
    }
  }

  // MARK: - Static Methods
  void initializeServices() {
    initializeAppsFlyer();
  }

  // MARK: - AppsFlyer Methods
  Future<void> initializeAppsFlyer() async {
    final configMap = await config();
    final analyticsConfig =
        configMap['Analytics'] as Map<String, dynamic>? ?? {};
    final commonConfig = configMap['Common'] as Map<String, dynamic>? ?? {};

    final String appsFlyerDevKey = kDebugMode
        ? analyticsConfig['AppsFlyerKeyDev'] as String? ?? ''
        : analyticsConfig['AppsFlyerKeyProd'] as String? ?? '';

    final String appId = commonConfig['AppId'] as String? ?? '';

    final options = {
      'afDevKey': appsFlyerDevKey,
      'appleAppID': appId,
      'isDebug': kDebugMode,
    };

    _appsflyerSdk = AppsflyerSdk(
      AppsFlyerOptions(
        afDevKey: options['afDevKey'] as String,
        appId: options['appleAppID'] as String,
        showDebug: options['isDebug'] as bool,
      ),
    );

    final userId = await ARAnalytics.shared.getARUserId();
    _appsflyerSdk?.setCustomerUserId(userId);

    _appsflyerSdk?.onInstallConversionData((res) {
      final status = res['status'];
      if (status == 'success') {
        final data = res['data'] as Map<String, dynamic>;
        onConversionDataSuccess(data);
      } else {
        final error = res['data'] as String;
        onConversionDataFail(error);
      }
    });

    _appsflyerSdk?.onAppOpenAttribution((data) {
      _onAppOpenAttribution(data);
    });

    // Optional: Start immediately if consent is not required
    // _startAppsFlyerIfConsentNotRequired();
  }

  void startAppsFlyer() {
    _appsflyerSdk?.startSDK();
  }

  void optOutAppsFlyer() {
    _appsflyerSdk?.stop(true);
  }

  Future<String> getAppsFlyerUID() async {
    String? appsFlyerUID = await _appsflyerSdk?.getAppsFlyerUID();

    if (appsFlyerUID == null || appsFlyerUID.trim().isEmpty) {
      return "-1";
    }

    return appsFlyerUID;
  }

  //MARK:- AppFlyer Delegate Methods
  void onConversionDataFail(String error) {
    String errorMessage = error.trim();
    if (errorMessage.isEmpty) {
      errorMessage = "-1";
    }

    ARAnalytics.shared.trackEventOnce("Attribution Error", {
      "errorMessage": errorMessage,
    });
  }

  void _onAppOpenAttribution(Map<dynamic, dynamic> attributionData) {
    print(attributionData);
  }

  void onAppOpenAttributionFailure(dynamic error) {
    print(error);
  }

  // MARK: - Apple Search Ads & Google Attribution Tracking
  Future<bool> isInstallFromPaidUserAcquisitionCampaign() async {
    if (await isInstallFromAppleSearchAds()) {
      return true;
    }

    if (await isInstallFromGoogleAdWords()) {
      return true;
    }

    return false;
  }

  Future<bool> isInstallFromAppleSearchAds() async {
    if (kDebugMode) return true;

    final prefs = await SharedPreferences.getInstance();
    final mediaSource = prefs
        .getString(
          ARAnalyticsConstants.USERDEFAULTS_APPSFLYER_INSTALL_MEDIASOURCE,
        )
        ?.toLowerCase();

    if (mediaSource == null) return false;

    return mediaSource == "apple search ads" ||
        mediaSource == "apple_search_ads";
  }

  Future<bool> isInstallFromGoogleAdWords() async {
    final prefs = await SharedPreferences.getInstance();
    final mediaSource = prefs
        .getString(
          ARAnalyticsConstants.USERDEFAULTS_APPSFLYER_INSTALL_MEDIASOURCE,
        )
        ?.toLowerCase();

    if (mediaSource == null) return false;

    return mediaSource.contains("google");
  }

  // MARK: - AppsFlyer Stored Data
  Future<bool> isNonOrganicInstall() async {
    const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;

    if (isDebug) {
      // return true;
    }

    String type = await getAppsFlyerInstallType();
    if (type == "Non-organic") {
      return true;
    }
    if (type == "non-organic") {
      return true;
    }

    return false;
  }

  Future<String> getAppsFlyerInstallType() async {
    final SharedPreferences defaults = await SharedPreferences.getInstance();
    String? result = defaults.getString(
      ARAnalyticsConstants.USERDEFAULTS_APPSFLYER_INSTALL_TYPE,
    );

    return result ?? "0";
  }

  Future<String> getAppsFlyerInstallMediaSource() async {
    final SharedPreferences defaults = await SharedPreferences.getInstance();
    String? result = defaults.getString(
      ARAnalyticsConstants.USERDEFAULTS_APPSFLYER_INSTALL_MEDIASOURCE,
    );

    return result ?? "0";
  }

  Future<String> getAppsFlyerInstallCampaign() async {
    final SharedPreferences defaults = await SharedPreferences.getInstance();
    String? result = defaults.getString(
      ARAnalyticsConstants.USERDEFAULTS_APPSFLYER_INSTALL_CAMPAIGN,
    );

    return result ?? "0";
  }

  //This will only store if there isn't an already stored value
  Future<void> setAppsFlyerInstallType(String? value) async {
    if (value == null) {
      return;
    }

    final SharedPreferences defaults = await SharedPreferences.getInstance();
    String? storedValue = defaults.getString(
      ARAnalyticsConstants.USERDEFAULTS_APPSFLYER_INSTALL_TYPE,
    );

    if (storedValue != null) {
      return;
    }

    await defaults.setString(
      ARAnalyticsConstants.USERDEFAULTS_APPSFLYER_INSTALL_TYPE,
      value,
    );
  }

  //This will only store if there isn't an already stored value
  Future<void> setAppsFlyerInstallMediaSource(String? value) async {
    if (value == null) {
      return;
    }

    final SharedPreferences defaults = await SharedPreferences.getInstance();
    String? storedValue = defaults.getString(
      ARAnalyticsConstants.USERDEFAULTS_APPSFLYER_INSTALL_MEDIASOURCE,
    );

    if (storedValue != null) {
      return;
    }

    await defaults.setString(
      ARAnalyticsConstants.USERDEFAULTS_APPSFLYER_INSTALL_MEDIASOURCE,
      value,
    );
  }

  Future<void> setAppsFlyerInstallCampaign(String? value) async {
    if (value == null) {
      return;
    }

    final SharedPreferences defaults = await SharedPreferences.getInstance();
    String? storedValue = defaults.getString(
      ARAnalyticsConstants.USERDEFAULTS_APPSFLYER_INSTALL_CAMPAIGN,
    );

    if (storedValue != null) {
      return;
    }

    await defaults.setString(
      ARAnalyticsConstants.USERDEFAULTS_APPSFLYER_INSTALL_CAMPAIGN,
      value,
    );
  }

  // MARK: - Config
  Future<Map<String, dynamic>> config() async {
    try {
      final String plistContent = await rootBundle.loadString(
        'ARAppKit/ARConfig/ARConfig.plist',
      );

      final parser = PlistParser();
      final Map<String, dynamic> configDictionary = Map<String, dynamic>.from(
        parser.parse(plistContent),
      );

      return configDictionary;
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> loadPlistConfig() async {
    final plistContent = await rootBundle.loadString('assets/Config.plist');

    // Create an instance of PlistParser
    final parser = PlistParser();

    // Use the instance to parse
    final Map<String, dynamic> configDictionary = Map<String, dynamic>.from(
      parser.parse(plistContent),
    );

    return configDictionary;
  }

  Future<String?> getAppsFlyerKeyFromConfig() async {
    final Map<String, dynamic> configMap = await config();
    final Map<String, dynamic>? configElements =
        configMap["Analytics"] as Map<String, dynamic>?;

    if (configElements == null) return null;

    const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;

    if (isDebug) {
      return configElements["AppsFlyerKeyDev"] as String?;
    } else {
      return configElements["AppsFlyerKeyProd"] as String?;
    }
  }

  Future<String?> getAppId() async {
    final Map<String, dynamic> configMap = await config();
    final Map<String, dynamic> configElements =
        configMap["Common"] as Map<String, dynamic>? ?? {};

    return configElements["AppId"] as String?;
  }
}
