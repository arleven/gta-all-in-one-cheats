import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';

import 'package:all_gta/ARAppKit/ARAnalytics/ARAnalytics.dart';
import 'package:all_gta/ARAppKit/ARAnalytics/ARAtribution.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode;

import 'dart:async';
import 'package:flutter/services.dart';

class ARConfig with WidgetsBindingObserver {
  // MARK: - Static Methods
  static final ARConfig shared = ARConfig._internal();

  ARConfig._internal() {
    initializeServices();

    // Register for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  void load() {
    ARConfig.shared;
  }

  bool remoteConfigFetchInProgress = false;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      applicationWillEnterForegrounds();
    }
  }

  // MARK: - Lifecycle
  void initializeServices() {
    initializeServer();
  }

  void initializeServer() async {
    String applicationId = '';

    final id = await backendApplicationId;
    String? clientKey = await backendClientKey();
    String? server = await backendServer();

    if (id == null || clientKey == null || server == null) {
      return;
    }

    applicationId = id;
    clientKey = clientKey;
    server = server;

    if (applicationId.length < 2) {
      return;
    }

    initConfig();
  }

  void initConfig() {
    Future.delayed(const Duration(seconds: 3), () {
      fetchLatestRemoteConfig();
    });
  }

  void applicationWillEnterForegrounds() {
    print("LTConfig - applicationWillEnterForeground called");
    fetchLatestRemoteConfigIfExpired();
  }

  // MARK: - Config - Updating + Access
  // PFConfig? get config {
  //   fetchLatestRemoteConfigIfExpired();
  //   return PFConfig.current();
  // }

  void fetchLatestRemoteConfig() {
    if (remoteConfigFetchInProgress) return;

    remoteConfigFetchInProgress = true;

    Future.delayed(const Duration(seconds: 5), () {
      remoteConfigFetchInProgress = false;
    });

    // Dummy request replace it with actual request to get datasource
    // APIRequests.rephraseText("", mode: "", tone: "").then((result) {
    //   remoteConfigFetchInProgress = false;
    //
    //   final config = result.config;
    //   final error = result.error;
    //
    //   if (config != null && error == null) {
    //     if (config is Map<String, dynamic>) {
    //       AppUserDefaults.setConfig(config);
    //     }
    //     print("Config retrieved");
    //     markConfigUpdate();
    //     postConfigUpdatedNotification();
    //     // initializeProFeaturesModeIfPossible();
    //     // initializePurchaseVCModeIfPossible();
    //   }
    // });

    // PFConfig.getConfigInBackground().then((config, error) {
    //   // TODO: Implement logic if needed
    // });
  }

  void turnOffFetchInProgressMarker() {
    remoteConfigFetchInProgress = false;
  }

  void fetchLatestRemoteConfigIfExpired() {
    if (isConfigExpired) {
      fetchLatestRemoteConfig();
    }
  }

  bool get isConfigExpired {
    final updateTimeMillis = _userDefaultsGetTimestamp(
      "ARCONFIG_CONFIGUPDATETIME",
    );
    if (updateTimeMillis == null) {
      return true;
    }

    final updateTime = DateTime.fromMillisecondsSinceEpoch(updateTimeMillis);
    final secondsSinceUpdate = DateTime.now().difference(updateTime).inSeconds;
    final configExpiryDuration = 60 * 10; // 10 minutes

    const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;

    if (isDebug) {
      return secondsSinceUpdate > 15; // Fetch every 15 seconds in debug mode
    }

    return secondsSinceUpdate > configExpiryDuration;
  }

  // Helper to get stored timestamp from SharedPreferences (equivalent to UserDefaults)
  int? _userDefaultsGetTimestamp(String key) {
    // TODO: Replace with actual SharedPreferences access
    // For example:
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getInt(key);
    return null;
  }

  void postConfigUpdatedNotification() {
    // Equivalent of NotificationCenter post
    _notificationController.add(configUpdatedNotificationName);
  }

  String get configUpdatedNotificationName => "ARConfig Updated";

  dynamic configValueForKey(String key) {
    return config()[key];
  }

  // Broadcast controller for notifications
  final StreamController<String> _notificationController =
      StreamController<String>.broadcast();

  // To listen for notifications
  Stream<String> get configNotifications => _notificationController.stream;

  // Simulated config map (replace with actual logic if needed)
  Map<String, dynamic> config() {
    // TODO: Return actual config data
    return {};
  }

  // MARK: - Config - Setup Setting Helpers
  Future<String?> get backendApplicationId async {
    final backend = await configBackend;
    return backend?['BackendApplicationId'] as String?;
  }

  Future<String?> backendClientKey() async {
    final backend = await configBackend;
    return backend?['BackendClientKey'] as String?;
  }

  Future<String?> backendServer() async {
    final backend = await configBackend;
    return backend?['BackendServer'] as String?;
  }

  void markconfigUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(
      "ARCONFIG_CONFIGUPDATETIME",
      DateTime.now().millisecondsSinceEpoch,
    );
    // No need to call synchronize; SharedPreferences handles it internally
  }

  String config_configMarker() {
    String value = '';
    final valueConfig = config()['configMarker'] as String?;
    if (valueConfig != null) {
      value = valueConfig;
    }
    return value;
  }

  // TODOv2 - figure out if this should be kept - right now it seems to require the backend to have this param
  bool hasConfigLoaded() {
    final valueConfig = config()['configLoaded'] as bool?;
    if (valueConfig == null) {
      return false;
    }
    return valueConfig;
  }

  // MARK: - ProFeaturesMode
  Future<ConfigProFeaturesMode?> getproFeaturesMode() async {
    // #if DEBUG
    // return ConfigProFeaturesMode.ProFeaturesMode_2; // Replace with appropriate debug value
    // #endif

    if (await isP_modeD_configValue()) {
      return ConfigProFeaturesMode.ProFeaturesMode_2;
    }

    performProFeaturesModeASACheck();

    // TODOv2 - if config says override use that one
    final overrideLocalValue = config_proFeaturesModeOverrideLocalValue();

    // If there is a purchase mode in the defaults, then use that
    Future<int?> getIntFromPrefs(String key) async {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(key)) {
        return prefs.getInt(key);
      }
      return null;
    }

    final localMode = await getIntFromPrefs("ARAppKit_proFeaturesMode");

    if (localMode != null && !overrideLocalValue) {
      return ConfigProFeaturesMode.fromRawValue(localMode);
    }

    // If not, then let's look at the config
    final configMode = config_proFeaturesMode();
    if (configMode >= 0) {
      setProFeaturesMode(
        ConfigProFeaturesMode.fromRawValue(configMode) ??
            ConfigProFeaturesMode.ProFeaturesMode_0,
        withOverwrite: overrideLocalValue,
      );
      return ConfigProFeaturesMode.fromRawValue(configMode);
    }

    // If we are in override local value mode and
    // there is nothing returned from the remote config, then we fall back
    // to the locally stored value (if there is one) and return that.
    if (overrideLocalValue && localMode != null) {
      return ConfigProFeaturesMode.fromRawValue(localMode);
    }

    return ConfigProFeaturesMode.ProFeaturesMode_0;
  }

  void initializeProFeaturesModeIfPossible() {
    // final mode = proFeaturesMode;
    // #if DEBUG
    // print("ProFeaturesMode: $mode");
    // #endif
  }

  void setProFeaturesMode(
    ConfigProFeaturesMode mode, {
    required bool withOverwrite,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final storedMode = prefs.getInt("ARAppKit_proFeaturesMode");

    if (storedMode != null && !withOverwrite) {
      return;
    }

    prefs.setInt("ARAppKit_proFeaturesMode", mode.index);
    // No need to call synchronize; SharedPreferences is auto-managed
  }

  // TOTESTv2
  void performProFeaturesModeASACheck() {
    // #if DEBUG
    // return;
    // #endif

    // The logic can vary per app
    // Can consolidate in the future
    if (ARConfig.shared.isAppRepost()) {
      // performProFeaturesModeASACheck_repostApp();
    } else {
      performProFeaturesModeASACheck_generalApp();
    }
  }

  // This function is only for Repost App
  // void performProFeaturesModeASACheck_repostApp() {
  //   // #ifdef DEBUG
  //   // return;
  //   // #endif

  //   bool asaInstall = LTAttribution.shared.isInstallFromPaidUserAcquisitionCampaign();
  //   bool isNonOrganicInstall = LTAttribution.shared.isNonOrganicInstall();
  //   bool shouldConvertNonOrganicFlagInstalls = config_shouldFModeConvertNonOrganicFlagInstalls();

  //   bool isFromChannelToConvert = asaInstall;
  //   if (shouldConvertNonOrganicFlagInstalls) {
  //     isFromChannelToConvert = asaInstall || isNonOrganicInstall;
  //   }

  //   int numCheckins = LTAnalytics.getNumCheckIns();
  //   bool shouldConvert = isFromChannelToConvert && numCheckins <= 1;

  //   if (shouldConvert) {
  //     bool config_asaShouldChangeFMode = config_proFeaturesModeASAConversion();
  //     if (config_asaShouldChangeFMode) {
  //       // If we've already overwritten, don't do it again.
  //       bool conversionPerformedBefore = hasFlagBeenSetBefore("RMAppKit_asaConversionPerformed");
  //       if (conversionPerformedBefore) return;

  //       final params = {
  //         "isAsaInstall": asaInstall,
  //         "isNonOrganicInstall": isNonOrganicInstall,
  //       };

  //       LTAnalytics.shared.trackEventOnce("ASA FMode Conversion", params);

  //       // Auto switch to features mode = 2 - this may vary per app
  //       setProFeaturesMode(ConfigProFeaturesMode.ProFeaturesMode_2, withOverwrite: true);
  //     }
  //   }
  // }

  void performProFeaturesModeASACheck_generalApp() async {
    // #if DEBUG
    // return;
    // #endif

    int numCheckins = await ARAnalytics.getNumCheckIns();

    if (numCheckins > 1) {
      return;
    }

    bool asaInstall = await ARAttribution.shared.isInstallFromAppleSearchAds();
    bool isNonOrganic = await ARAttribution.shared.isNonOrganicInstall();

    if (asaInstall || isNonOrganic) {
      bool configAsaShouldChangeFMode =
          await config_proFeaturesModeASAConversion();
      if (configAsaShouldChangeFMode) {
        return;
      }

      ARAnalytics.shared.trackEventOnce("Non Orgainc FMode Conversion", null);

      setProFeaturesMode(
        ConfigProFeaturesMode.ProFeaturesMode_3,
        withOverwrite: true,
      );
    }

    return;
  }

  bool config_shouldFModeConvertNonOrganicFlagInstalls() {
    bool value = false;
    final valueConfig = config()["convertNonOrganic"];
    if (valueConfig is int) {
      return true;
    }
    return value;
  }

  // MARK: - ProFeaturesMode - Config Getters
  int config_intValueForKey(String key) {
    if (key.isEmpty) {
      return -1;
    }

    int value = -1;
    final valueConfig = config()[key];
    if (valueConfig is int) {
      value = valueConfig;
    }

    return value;
  }

  // This tells us to update the featuresMode using remote config even if there is a locally stored
  // value from the past
  bool config_proFeaturesModeOverrideLocalValue() {
    bool value = false;
    final valueConfig = config()["fMode_overrideLocal"];
    if (valueConfig is int) {
      value = true;
    }
    return value;
  }

  int config_proFeaturesMode() {
    int mode0Amount = config_intValueForKey("fMode_0");
    int mode1Amount = config_intValueForKey("fMode_1");
    int mode2Amount = config_intValueForKey("fMode_2");
    int mode3Amount = config_intValueForKey("fMode_3");
    int mode4Amount = config_intValueForKey("fMode_4");
    int mode5Amount = config_intValueForKey("fMode_5");
    int mode6Amount = config_intValueForKey("fMode_6");
    int mode7Amount = config_intValueForKey("fMode_7");

    List<int> values = [];

    for (int i = 0; i <= mode0Amount; i++) {
      values.add(0);
    }

    for (int i = 0; i <= mode1Amount; i++) {
      values.add(1);
    }

    for (int i = 0; i <= mode2Amount; i++) {
      values.add(2);
    }

    for (int i = 0; i <= mode3Amount; i++) {
      values.add(3);
    }

    for (int i = 0; i <= mode4Amount; i++) {
      values.add(4);
    }

    for (int i = 0; i <= mode5Amount; i++) {
      values.add(5);
    }

    for (int i = 0; i <= mode6Amount; i++) {
      values.add(6);
    }

    for (int i = 0; i <= mode7Amount; i++) {
      values.add(7);
    }

    if (values.isNotEmpty) {
      int rnd = Random().nextInt(values.length);
      int randomValue = values[rnd];
      int randomValueInt = randomValue;
      if (randomValueInt >= 0) {
        return randomValueInt;
      }
    }

    return -1;
  }

  Future<bool> config_proFeaturesModeASAConversion() async {
    if (await isPModeD()) {
      return false;
    }

    int probability = config_intValueForKey("asaConv");
    if (probability <= 0) {
      return false;
    }

    int negativeProbability = max(0, 100 - probability);
    List<int> values = [];

    for (int i = 0; i < probability; i++) {
      values.add(1);
    }

    for (int i = 0; i < negativeProbability; i++) {
      values.add(0);
    }

    if (values.isNotEmpty) {
      int rnd = Random().nextInt(values.length);
      int randomValue = values[rnd];
      int randomValueInt = randomValue;
      if (randomValueInt >= 0) {
        return true;
      }
    }

    return false;
  }

  // MARK: - PurchaseVCMode
  Future<ConfigPurchaseVCMode> purchaseVCMode() async {
    // DEBUG override (commented out like in Swift)
    // return ConfigPurchaseVCMode.PurchaseVCMode_7;

    final overrideLocalValue = config_purchaseVCModeOverrideLocalValue();

    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getInt("ARConfig_purchaseVCMode");

    if (mode != null && !overrideLocalValue) {
      return ConfigPurchaseVCMode.values[mode];
    }

    final configMode = config_purchaseVCMode();
    if (configMode >= 0) {
      setPurchaseVCMode(configMode, withOverwrite: overrideLocalValue);
      return ConfigPurchaseVCMode.values[configMode];
    }

    if (overrideLocalValue && mode == null) {
      return ConfigPurchaseVCMode.values[(mode ?? 0)];
    }

    return ConfigPurchaseVCMode.PurchaseVCMode_0;
  }

  void initializePurchaseVCModeIfPossible() async {
    final mode = await purchaseVCMode(); // Assuming async version is used

    // Debug print (like Swift's `#if DEBUG`)
    assert(() {
      print("PurchaseVCMode: $mode");
      return true;
    }());
  }

  Future<void> setPurchaseVCMode(
    int mode, {
    required bool withOverwrite,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final storedMode = prefs.getInt("ARConfig_purchaseVCMode");

    if (storedMode != null && !withOverwrite) {
      return;
    }

    await prefs.setInt("ARConfig_purchaseVCMode", mode);
  }

  // MARK: - Purchase VC Mode - Config Getters
  bool config_purchaseVCModeOverrideLocalValue() {
    final valueConfig = config()['pvcMode_overideLocal'];
    bool value = false;
    if (valueConfig is int) {
      value = true;
    }
    return value;
  }

  int config_purchaseVCMode() {
    int pvcMode0Amount = config_intValueForKey("pvcMode_0");
    int pvcMode1Amount = config_intValueForKey("pvcMode_1");
    int pvcMode2Amount = config_intValueForKey("pvcMode_2");
    int pvcMode3Amount = config_intValueForKey("pvcMode_3");
    int pvcMode4Amount = config_intValueForKey("pvcMode_4");
    int pvcMode5Amount = config_intValueForKey("pvcMode_5");
    int pvcMode6Amount = config_intValueForKey("pvcMode_6");
    int pvcMode7Amount = config_intValueForKey("pvcMode_7");
    int pvcMode8Amount = config_intValueForKey("pvcMode_8");
    int pvcMode9Amount = config_intValueForKey("pvcMode_9");
    int pvcMode10Amount = config_intValueForKey("pvcMode_10");
    int pvcMode11Amount = config_intValueForKey("pvcMode_11");
    int pvcMode12Amount = config_intValueForKey("pvcMode_12");

    List<int> values = [];

    for (int i = 0; i < pvcMode0Amount; i++) {
      values.add(0);
    }
    for (int i = 0; i < pvcMode1Amount; i++) {
      values.add(1);
    }
    for (int i = 0; i < pvcMode2Amount; i++) {
      values.add(2);
    }
    for (int i = 0; i < pvcMode3Amount; i++) {
      values.add(3);
    }
    for (int i = 0; i < pvcMode4Amount; i++) {
      values.add(4);
    }
    for (int i = 0; i < pvcMode5Amount; i++) {
      values.add(5);
    }
    for (int i = 0; i < pvcMode6Amount; i++) {
      values.add(6);
    }
    for (int i = 0; i < pvcMode7Amount; i++) {
      values.add(7);
    }
    for (int i = 0; i < pvcMode8Amount; i++) {
      values.add(8);
    }
    for (int i = 0; i < pvcMode9Amount; i++) {
      values.add(9);
    }
    for (int i = 0; i < pvcMode10Amount; i++) {
      values.add(10);
    }
    for (int i = 0; i < pvcMode11Amount; i++) {
      values.add(11);
    }
    for (int i = 0; i < pvcMode12Amount; i++) {
      values.add(12);
    }

    if (values.isNotEmpty) {
      int rnd = Random().nextInt(values.length);
      int randomValue = values[rnd];
      if (randomValue >= 0) {
        return randomValue;
      }
      return -1;
    }

    return -1;
  }

  // MARK: - PurchaseVC Configurations
  Future<double> getOnboardingPurchaseVCCloseAlpha() async {
    // #if DEBUG
    // return 1.0;
    // return 0.1;
    // #endif

    bool isPMD = await ARConfig.shared.isPModeD();
    if (isPMD) {
      return 1.0;
    }

    bool asaInstall = await ARAttribution.shared.isInstallFromAppleSearchAds();
    bool isNonOrganic = await ARAttribution.shared.isNonOrganicInstall();

    if (asaInstall || isNonOrganic) {
      double abTestValue =
          (await ARConfig.shared.getUserValueForABTest("onbXAlpha_paid")) /
          100.0;

      if (abTestValue >= 0) {
        return abTestValue;
      }

      final configValue = config()["onbXAlpha_paid"];
      if (configValue is int) {
        double value = configValue.toDouble();
        return value;
      }

      return 0.0;
    }

    // For organic installs (default = soft paywall)
    double abTestValue =
        await ARConfig.shared.getUserValueForABTest("onbXAlpha_paid") / 100.0;
    if (abTestValue >= 0) {
      return abTestValue;
    }

    final configValue = config()["onbXAlpha_paid"];
    if (configValue is int) {
      double value = configValue.toDouble();
      return value;
    }

    return 1.0;
  }

  // Returns a bool which signifies whether the purchase/subscription page should be shown during onboarding
  bool shouldShowOnboardingPurchaseVC() {
    // DEBUG override
    // return false;

    // Optional PMD override (currently disabled)
    // bool isPMD = ARConfig.shared.isPModeD();
    // if (isPMD) {
    //   return false;
    // }

    return true;
  }

  bool shouldOfferVaryForNonOrganicUsers() {
    bool value = false;

    final valueConfig = config()["pvc_offersVary"];
    if (valueConfig is int) {
      value = true;
    }

    return value;
  }

  // MARK: - User Type
  // Future<ConfigUserType> getCurrentUserType() async {
  //   final SharedPreferences defaults = await SharedPreferences.getInstance();
  //   final int value = defaults.getInt('ARAppKit_currentUserType') ?? 0;
  //   return ConfigUserType.values.firstWhere(
  //     (e) => e.index == value,
  //     orElse: () => ConfigUserType.ConfigUserType_Undefined,
  //   );
  // }

  Future<String> getCurrentUserTypeAsString() async {
    ARConfigUserType type = await getCurrentUserType();

    if (type == ARConfigUserType.personal) {
      return "Personal";
    } else if (type == ARConfigUserType.business) {
      return "Business";
    }

    return "Undefined";
  }

  Future<void> setCurrentUserType(ConfigUserType type) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("ARAppKit_currentUserType", type.index);
  }

  // MARK: - PMode D Settings
  Future<bool> isP_modeD() async {
    // #if DEBUG
    // return false;
    // #endif

    final prefs = await SharedPreferences.getInstance();
    final overrideStore = pModeD_overrideStore();

    final storedValue = prefs.getInt("LTConfig_isP_modeD");
    if (storedValue != null && !overrideStore) {
      return true;
    }

    if (overrideStore) {
      clear_isP_modeD_defaults();
    }

    if (pModeD_ignoreOld()) {
      final numCheckins = ARAnalytics.getNumCheckIns();
      if (await numCheckins > 10) {
        return false;
      }
    }

    final configValue = isP_modeD_configValue();
    if (await configValue) {
      set_isP_modeD_defaults();
      return configValue;
    }

    return false;
  }

  Future<void> set_isP_modeD_defaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("ARConfig_isP_modeD", true);
  }

  Future<void> clear_isP_modeD_defaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("ARConfig_isP_modeD");
  }

  Future<bool> isP_modeD_configValue() async {
    bool val1 = isP_modeD_configValue_numberBased(); // make sure it's awaited
    if (val1) return true;

    bool val2 = await isP_modeD_configValue_versionBased();
    if (val2) return true;

    bool val3 = await isP_modeD_configValue_buildBased();
    if (val3) return true;

    return false;
  }

  bool isP_modeD_configValue_numberBased() {
    // DEBUG check (optional: can wrap with assert or use kDebugMode from Flutter foundation)
    // assert(() {
    //   return true;
    // }());

    bool value = false;
    int? valueConfig = config()["a_isPmodeD14"] as int?;
    if (valueConfig != null) {
      value = true;
    }
    return value;
  }

  Future<bool> isP_modeD_configValue_versionBased() async {
    // DEBUG flag (optional)
    // if (kDebugMode) {
    //   return true;
    // }

    String version = '';
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;

    if (version.isNotEmpty) {
      version = version.replaceAll('.', '_');

      String key = "a_isPmodeD_$version";
      int? valueConfig = config()[key] as int?;
      if (valueConfig != null) {
        return true;
      }
    }

    return false;
  }

  Future<bool> isP_modeD_configValue_buildBased() async {
    // DEBUG flag (optional)
    // if (kDebugMode) {
    //   return true;
    // }

    String version = '';
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.buildNumber;

    if (version.isNotEmpty) {
      version = version.replaceAll('.', '_');

      String key = "a_isPmodeD_$version";
      int? valueConfig = config()[key] as int?;
      if (valueConfig != null) {
        return true;
      }
    }

    return false;
  }

  bool pModeD_overrideStore() {
    bool value = false;
    int? valueConfig = config()["a_pModeD_overrideStore"] as int?;
    if (valueConfig != null) {
      value = true;
    }
    return value;
  }

  bool pModeD_ignoreOld() {
    bool value = false;
    int? valueConfig = config()["a_pModeD_ignoreOld"] as int?;
    if (valueConfig != null) {
      return true;
    }
    return value;
  }

  // MARK: - PMode N Settings
  Future<bool> isP_modeN() async {
    // DEBUG flag (optional)
    // if (kDebugMode) {
    //   return true;
    // }

    double installVersion =
        await ARAnalytics.getInstallVersion(); // Equivalent to ARAnalytics.getInstallVersion()
    double cutoff = 20.99;

    int? cutoffVal = config()["b_pModeN_val"] as int?;
    if (cutoffVal != null) {
      cutoff = cutoffVal.toDouble();
    }

    if (installVersion <= cutoff) {
      return false;
    }

    return true;
  }

  Future<int> configValueVersionedForKey(String inputKey) async {
    int finalValue = config()[inputKey] as int? ?? 0;

    // Use alternate config value if it exists
    if (inputKey.length > 1) {
      String alternateKey = "${inputKey}_n";
      int? valueConfig = config()[alternateKey] as int?;
      if (valueConfig != null) {
        finalValue = valueConfig;
      }
    }

    // Use alternate config value if exists for UA users
    if (inputKey.length > 1) {
      String alternateKey = "${inputKey}_n";

      bool asaInstall = await ARAttribution.shared
          .isInstallFromAppleSearchAds();
      bool isNonOrganic = await ARAttribution.shared.isNonOrganicInstall();

      if (asaInstall || isNonOrganic) {
        int? valueConfig = config()[alternateKey] as int?;
        if (valueConfig != null) {
          finalValue = valueConfig;
        }
      }
    }

    return finalValue;
  }

  // MARK: - AB Testing
  Future<int> getUserValueForABTest(String abTest) async {
    return getUserValueForABTestWithConditions(
      abTest,
      withMinInstallVersion: -1,
      andMaxCheckins: -1,
    );
  }

  Future<int> getUserValueForABTestWithConditions(
    String abTest, {
    required double withMinInstallVersion,
    required int andMaxCheckins,
  }) async {
    String? configABTest = config_abTestConfigName();

    if (configABTest != abTest) {
      return -1;
    }

    if (andMaxCheckins >= 0) {
      int numCheckins = await ARAnalytics.getNumCheckIns();
      if (numCheckins > andMaxCheckins) {
        return -1;
      }
    }

    if (withMinInstallVersion > 0) {
      double installVersion = await ARAnalytics.getInstallVersion();
      if (installVersion < withMinInstallVersion && installVersion < 10000) {
        return -1;
      }
    }

    int value = await getCurrentAbTestValue();
    return value;
  }

  String? config_abTestConfigName() {
    String value = '';
    String? valueConfig = config()["abTest1_name"] as String?;
    if (valueConfig != null) {
      value = valueConfig;
    }
    return value;
  }

  List<int> config_abTestValues() {
    List<int> valueConfig = [];
    List<dynamic>? valueConfigArray =
        config()["abTest1_values"] as List<dynamic>?;

    if (valueConfigArray != null) {
      valueConfig = valueConfigArray.whereType<int>().toList();
    }

    return valueConfig;
  }

  // TODOv2
  void trackAbTestStart(String abTest, int value) {
    // TODOv2
    // Replace the below call with your analytics SDK event method
    // trackOneTimeEventWithName(
    //   "AB Test Started",
    //   withParams: {"abTest": abTest, "value": value},
    // );
  }

  Future<int> getCurrentAbTestValue() async {
    String? configAbTest = config_abTestConfigName();
    if (configAbTest == null || configAbTest.length <= 1) {
      return -1;
    }

    String abTestStorageKey = "AbTestValueForTest_configTestId_$configAbTest";

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? abTestValue = prefs.getInt(abTestStorageKey);

    if (abTestValue != null && abTestValue >= 0) {
      return abTestValue;
    }

    List<int> possibleValues = config_abTestValues();

    if (possibleValues.isNotEmpty) {
      int rnd = Random().nextInt(possibleValues.length);
      int randomValue = possibleValues[rnd];
      if (randomValue >= 0) {
        await prefs.setInt(abTestStorageKey, randomValue);
        return randomValue;
      }
    }

    // No stored value, and no config values — error fallback
    return -1;
  }

  // MARK: - Analytics Configs
  double getAnalyticsEventThrottlingFactor() {
    double value = 1.0;
    int? valueConfig = config()["x_throttleFactor"] as int?;
    if (valueConfig != null) {
      value = valueConfig.toDouble();
    }
    return value;
  }

  double getAnalyticsEventThrottlingFactorForEventName(String? eventName) {
    double value = 1.0;

    if (eventName != null && eventName.isNotEmpty) {
      String configKey = "x_throttle_$eventName";
      int? valueConfig = config()[configKey] as int?;
      if (valueConfig != null) {
        value = valueConfig.toDouble();
      }
    }

    return value;
  }

  int diagnosticsMode() {
    int? valNum = config()["diagnosticsMode"] as int?;
    if (valNum != null) {
      return valNum;
    }
    return 0;
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // MARK: - Helper Local Plist Config Methods

  Future<Map<String, dynamic>?> get configRoot async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/lt_config.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return jsonMap;
    } catch (e) {
      // File not found or JSON parsing failed
      return null;
    }
  }

  Future<Map<String, dynamic>?> get configBackend async {
    final root = await configRoot;
    final backend = root?['Backend'];
    if (backend is Map<String, dynamic>) {
      return backend;
    }
    return null;
  }

  Future<Map<String, dynamic>?> get configCommon async {
    final root = await configRoot;
    final common = root?['Common'];
    if (common is Map<String, dynamic>) {
      return common;
    }
    return null;
  }

  // MARK: - Helper Methods - General
  Future<bool> hasFlagBeenSetBefore(String flag) async {
    final prefs = await SharedPreferences.getInstance();
    String? stored = prefs.getString(flag);

    if (stored == null) {
      await prefs.setString(flag, "set");
      return false;
    }

    return true;
  }

  void logCurrentStatus() {
    ConfigProFeaturesMode? proFeaturesMode;
    if (kDebugMode) {
      final currentMode =
          proFeaturesMode ?? ConfigProFeaturesMode.ProFeaturesMode_0;
      print('--');
      // print('Current pMode: $purchaseVCMode');
      print('Current proFeaturesMode: $currentMode');
      // print('isPro: $isPro');
      print('--');
    }
  }

  int daysBetween(DateTime fromDateTime, DateTime toDateTime) {
    final fromDate = DateTime(
      fromDateTime.year,
      fromDateTime.month,
      fromDateTime.day,
    );
    final toDate = DateTime(toDateTime.year, toDateTime.month, toDateTime.day);

    return toDate.difference(fromDate).inDays;
  }

  bool isAppRepost() {
    final String currentBundleId = const String.fromEnvironment(
      'FLUTTER_BUNDLE_IDENTIFIER',
      defaultValue: '',
    );
    final String targetIdentifier =
        ''; // TODO :- HOTFIX, This is only for repost app

    return currentBundleId == targetIdentifier;
  }

  int configPurchaseVCMode() {
    // Logic to determine PurchaseVCMode based on config
    return 0; // Replace with actual logic
  }

  // MARK: - Notification Handlers
  void applicationWillEnterForeground() {
    debugPrint('ARConfig - applicationWillEnterForeground called');
    fetchLatestRemoteConfigIfExpired();
  }

  // MARK: - User Type
  Future<ARConfigUserType> getCurrentUserType() async {
    final prefs = await SharedPreferences.getInstance();
    final intValue = prefs.getInt("_userTypeKey") ?? -1;
    return ARConfigUserType.values.asMap().containsKey(intValue)
        ? ARConfigUserType.values[intValue]
        : ARConfigUserType.undefined;
  }

  // Future<void> setCurrentUserType(ARConfigUserType type) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setInt(_userTypeKey, type.index);
  // }

  // MARK: - PMode D Settings

  Future<bool> isPModeD() async {
    if (kDebugMode) {
      // return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.getBool("ARConfig_isP_modeD");

    if (!pModeDOverrideStore() && storedValue != null) {
      return storedValue;
    }

    if (pModeDOverrideStore()) {
      await clearIsPModeDDefaults();
    }

    if (pModeDIgnoreOld()) {
      if (await ARAnalytics.getNumCheckIns() > 10) {
        return false;
      }
    }

    if (isPModeDConfigValue()) {
      await setIsPModeDDefaults();
      return true;
    }

    return false;
  }

  Future<void> setIsPModeDDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ARConfig_isP_modeD', true);
  }

  Future<void> clearIsPModeDDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("ARConfig_isP_modeD");
    // No direct equivalent of synchronize() in Dart — changes are saved immediately
  }

  bool isPModeDConfigValueVersionBased() {
    // TODO: Implement this logic
    return false;
  }

  bool isPModeDConfigValue() {
    // In Swift: DEBUG preprocessor block (ignored in release)
    // In Dart: you'd usually handle this with asserts, or debug-specific logic elsewhere

    return isPModeDConfigValueNumberBased() ||
        isPModeDConfigValueVersionBased();
  }

  bool isPModeDConfigValueNumberBased() {
    // In Swift: #if DEBUG is ignored here – same here in Dart.
    // If needed, handle debug behavior with assert(() {}()); externally.

    final configValue = config()['a_isPmodeD15'];
    if (configValue is bool) {
      return configValue;
    }
    return false;
  }

  // bool isPModeDConfigValueVersionBased() {
  //   // In Swift: #if DEBUG is ignored — Dart doesn't compile out debug sections the same way.
  //   // Use assert() or environment variables in main() if needed.

  //   final version = packageInfo
  //       ?.version; // Assumes you have `packageInfo` set from `package_info_plus`
  //   if (version == null) {
  //     return false;
  //   }

  //   final sanitizedVersion = version.replaceAll('.', '_');
  //   final key = 'a_isPmodeD_$sanitizedVersion';
  //   final valueConfig = config()[key];

  //   if (valueConfig is bool) {
  //     return valueConfig;
  //   }
  //   return false;
  // }

  bool pModeDOverrideStore() {
    final valueConfig = config()['a_pModeD_overrideStore'];
    if (valueConfig is bool) {
      return valueConfig;
    }
    return false;
  }

  bool pModeDIgnoreOld() {
    final valueConfig = config()['a_pModeD_ignoreOld'];
    if (valueConfig is bool) {
      return valueConfig;
    }
    return false;
  }

  // MARK: - AB Testing
  // int getUserValueForABTest(String abTest) {
  //   return getUserValueForABTestWithParams(
  //     abTest,
  //     minInstallVersion: -1,
  //     maxCheckins: -1,
  //   );
  // }

  Future<int> getUserValueForABTestWithParams(
    String abTest, {
    required double minInstallVersion,
    required int maxCheckins,
  }) async {
    if (configABTestConfigName() != abTest) {
      return -1;
    }

    if (maxCheckins >= 0 && await ARAnalytics.getNumCheckIns() > maxCheckins) {
      return -1;
    }

    // if (minInstallVersion > 0 && ARAnalytics.getInstallVersion() < minInstallVersion) {
    //   return -1;
    // }

    return await getCurrentAbTestValue();
  }

  String? configABTestConfigName() {
    final configMap = config();
    return configMap['abTestName'] as String?;
  }

  List<int> configABTestValues() {
    final configMap = config();
    return (configMap['abTestValues'] as List?)?.cast<int>() ?? [];
  }

  // MARK: - Analytics Configs
  // Map<String, dynamic> config() {
  //   return AppUserDefaults.getConfig();
  //   // Replace with actual implementation
  // }

  // MARK: - ProFeaturesMode
}

//MARK:- Enums
enum ConfigProFeaturesMode {
  ProFeaturesMode_0,
  ProFeaturesMode_1,
  ProFeaturesMode_2,
  ProFeaturesMode_3,
  ProFeaturesMode_4,
  ProFeaturesMode_5,
  ProFeaturesMode_6,
  ProFeaturesMode_7;

  static ConfigProFeaturesMode? fromRawValue(int rawValue) {
    switch (rawValue) {
      case 0:
        return ConfigProFeaturesMode.ProFeaturesMode_0;
      case 1:
        return ConfigProFeaturesMode.ProFeaturesMode_1;
      case 2:
        return ConfigProFeaturesMode.ProFeaturesMode_2;
      case 3:
        return ConfigProFeaturesMode.ProFeaturesMode_3;
      case 4:
        return ConfigProFeaturesMode.ProFeaturesMode_4;
      case 5:
        return ConfigProFeaturesMode.ProFeaturesMode_5;
      case 6:
        return ConfigProFeaturesMode.ProFeaturesMode_6;
      case 7:
        return ConfigProFeaturesMode.ProFeaturesMode_7;
      default:
        return null;
    }
  }
}

enum ConfigPurchaseVCMode {
  PurchaseVCMode_0,
  PurchaseVCMode_1,
  PurchaseVCMode_2,
  PurchaseVCMode_3,
  PurchaseVCMode_4,
  PurchaseVCMode_5,
  PurchaseVCMode_6,
  PurchaseVCMode_7,
  PurchaseVCMode_8,
  PurchaseVCMode_9,
  PurchaseVCMode_10,
  PurchaseVCMode_11,
  PurchaseVCMode_12;

  static ConfigPurchaseVCMode? fromRawValue(int rawValue) {
    switch (rawValue) {
      case 0:
        return ConfigPurchaseVCMode.PurchaseVCMode_0;
      case 1:
        return ConfigPurchaseVCMode.PurchaseVCMode_1;
      case 2:
        return ConfigPurchaseVCMode.PurchaseVCMode_2;
      case 3:
        return ConfigPurchaseVCMode.PurchaseVCMode_3;
      case 4:
        return ConfigPurchaseVCMode.PurchaseVCMode_4;
      case 5:
        return ConfigPurchaseVCMode.PurchaseVCMode_5;
      case 6:
        return ConfigPurchaseVCMode.PurchaseVCMode_6;
      case 8:
        return ConfigPurchaseVCMode.PurchaseVCMode_7;
      case 9:
        return ConfigPurchaseVCMode.PurchaseVCMode_8;
      case 10:
        return ConfigPurchaseVCMode.PurchaseVCMode_9;
      case 11:
        return ConfigPurchaseVCMode.PurchaseVCMode_10;
      case 12:
        return ConfigPurchaseVCMode.PurchaseVCMode_11;
      case 13:
        return ConfigPurchaseVCMode.PurchaseVCMode_12;
      default:
        return null;
    }
  }
}

enum ConfigUserType {
  ConfigUserType_Undefined,
  ConfigUserType_Personal,
  ConfigUserType_Business,
}

enum ARConfigUserType {
  undefined,
  personal,
  business;

  int get rawValue {
    switch (this) {
      case ARConfigUserType.undefined:
        return -1;
      case ARConfigUserType.personal:
        return 0;
      case ARConfigUserType.business:
        return 1;
    }
  }

  static ARConfigUserType fromRawValue(int? value) {
    switch (value) {
      case 0:
        return ARConfigUserType.personal;
      case 1:
        return ARConfigUserType.business;
      case -1:
      default:
        return ARConfigUserType.undefined;
    }
  }
}

class ConfigService {
  // Getter equivalent for isDevDatabase
  Future<bool> get isDevDatabase async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('kSashidoDBEnvironment');
    return mode == 'development';
  }

  // Method equivalent for markConfigUpdate
  Future<void> markConfigUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now()
        .toIso8601String(); // Since SharedPreferences can't store DateTime directly
    await prefs.setString('ARCONFIG_CONFIGUPDATETIME', now);
  }
}
