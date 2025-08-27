import 'package:flutter/material.dart';
import 'package:all_gta/ARAppKit/ARAnalytics/User_Defaults.dart';
import 'package:all_gta/ARAppKit/ARProduct_manager/ar_product_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_gta/ARAppKit/ARAnalytics/ARAnalytics.dart';
import 'package:all_gta/ARAppKit/ARConfig/ARConfig.dart';
import 'package:all_gta/ARAppKit/arkit.dart';
import 'package:all_gta/ARAppKit/ARAnalytics/arAnalytics_constants.dart';
import 'dart:math';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';

enum ReviewMode { ReviewMode_checkins, ARReviewMode_Goal1, ARReviewMode_Goal2 }

enum ReviewRequestType {
  ReviewRequestType_None,
  ReviewRequestType_Native,
  ReviewRequestType_Native_Engaged,
  ReviewRequestType_AlertRequest,
  ReviewRequestType_AlertRequest_Engagement,
  ReviewRequestType_WrittenRequest,
  ReviewRequestType_WrittenRequest_Engaged,
}

enum MFMailComposeResult { cancelled, saved, sent, failed, unknown }

class ARReviewManager with WidgetsBindingObserver {
  // Singleton
  static final ARReviewManager shared = ARReviewManager._internal();

  bool showNativeAppRatingAlertOnceThisSession_marker = false;
  late SharedPreferences prefs;

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  ARReviewManager._internal() {
    // Equivalent to super.init() in Swift
    WidgetsBinding.instance.addObserver(this);

    // Equivalent to NotificationCenter observers
    // In Flutter, WidgetsBindingObserver handles lifecycle events
    // Instead of selectors, we override didChangeAppLifecycleState below

    // Equivalent to ARAnalytics.shared.trackCheckIn()
    ARAnalytics.shared.trackCheckIn();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      applicationWillEnterForeground();
    } else if (state == AppLifecycleState.paused) {
      applicationDidEnterBackground();
    }
  }

  bool get isProUser {
    return ARProductManager().isProUser();
  }

  void mailComposeController(
    dynamic controller,
    MFMailComposeResult result,
    Object? error,
  ) {
    switch (result) {
      case MFMailComposeResult.cancelled:
        controller?.dismiss();
        Fluttertoast.showToast(msg: "Save");
        break;
      case MFMailComposeResult.saved:
        controller?.dismiss();
        Fluttertoast.showToast(msg: "Saved");
        break;
      case MFMailComposeResult.sent:
        controller?.dismiss();
        Fluttertoast.showToast(msg: "Sent");
        break;
      case MFMailComposeResult.failed:
        controller?.dismiss();
        Fluttertoast.showToast(msg: "Failed");
        break;
      default:
        Fluttertoast.showToast(msg: "Unable to send");
        break;
    }
  }

  static void showContactSupportMailbox() {
    final shared = ARReviewManager.shared;
    shared.sendEmailWithSubject(
      shared.updatedEmailSubject(subject: "Contact Support"),
    );
  }

  static void showFeedbackRequestAlert(BuildContext context) {
    final String title = "Thanks for letting us know!";
    final String message =
        "Would you mind sending us feedback to help us improve? 😊";

    if (Platform.isIOS) {
      // iOS style dialog
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                message,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  ARReviewManager.shared.sendEmailWithSubject(
                    "Feedback Rating",
                  );
                },
                child: const Text(
                  "Send Feedback",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                isDestructiveAction: true,
                child: const Text(
                  "Close",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Android / Material style dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ARReviewManager.shared.sendEmailWithSubject(
                    "Feedback Rating",
                  );
                },
                child: const Text("Send Feedback"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    }
  }

  static Future<void> showNativeAppRatingOnceEver() async {
    final hasBeenSet = await ARAnalytics.shared.hasFlagBeenSetBefore(
      "ARReviewManager_oneTimeNativeAppRatingShown",
    );

    if (!hasBeenSet) {
      ARReviewManager.shared.showNativeAppRatingAlert();
    }
  }

  static void startReviewRequestIfRequired(BuildContext context) async {
    final shared = ARReviewManager.shared;
    ARReviewManager.reviewRequestedThisSession;

    if (!shared.howWeDoingEnabled()) {
      return;
    }

    // if (shared.isHowWeDoingDisabledDueToProFeaturesMode()) {
    //   return;
    // }

    if (await shared.showReviewRequestWithNumberIfRequired(0, context)) {
      return;
    }

    if (await shared.showReviewRequestWithNumberIfRequired(1, context)) {
      return;
    }

    if (await shared.showReviewRequestWithNumberIfRequired(2, context)) {
      return;
    }

    if (await shared.showReviewRequestWithNumberIfRequired(3, context)) {
      return;
    }

    if (await shared.showReviewRequestWithNumberIfRequired(4, context)) {
      return;
    }

    if (await shared.showReviewRequestWithNumberIfRequired(5, context)) {
      return;
    }

    if (await shared.showReviewRequestWithNumberIfRequired(6, context)) {
      return;
    }
  }

  String updatedEmailSubject({required String subject}) {
    return "${ARAnalyticsConstants.APP_NAME} - $subject";
  }

  void applicationWillEnterForeground() {
    ARAnalytics.shared.trackCheckIn();
  }

  void applicationDidEnterBackground() {}

  bool howWeDoingEnabled() {
    // TODO:- We have to change here because this code is working with dynamic values came from config and decide pro user or not
    // var pmodeD = [[ARConfig sharedInstance] isP_modeD];
    // var pmodeD = false;
    //
    // if (pmodeD) {
    //   return false;
    // }
    //
    // var value = false;
    //
    // if (UserDefaults.standard.value(forKey: "hwd_on") as int?) != null {
    //   return true;
    // }
    return true;
  }

  bool isHowWeDoingDisabledDueToProFeaturesMode() {
    // If it's a pro user, ask as normal
    if (isProUser) {
      return false;
    }

    // TODO V2 - Read this from a config file because it varies by app

    // Only ask for reviews in proFeaturesMode 0 or 1
    final proFeaturesMode = ARConfig.shared.getproFeaturesMode();
    if (proFeaturesMode != ConfigProFeaturesMode.ProFeaturesMode_0 &&
        proFeaturesMode != ConfigProFeaturesMode.ProFeaturesMode_1) {
      return true;
    }

    return false;
  }

  Future<ReviewMode> hwdMode() async {
    ReviewMode mode = ReviewMode.ReviewMode_checkins;

    final int? valueConfig = await AppUserDefaults().getIntFromPrefs(
      "hwd_mode",
    );
    if (valueConfig != null) {
      mode = ReviewMode.values[valueConfig];
    }

    // TODO: If you want to override mode here for testing, keep it
    mode = ReviewMode.ReviewMode_checkins;

    return mode;
  }

  Future<int> getNumCheckIns() async {
    final int value = await ARAnalytics.getNumCheckIns();
    return value;
  }

  Future<int> getNumGoal1() async {
    final int value = await ARAnalytics.getNumGoal1();
    return value;
  }

  Future<int> getNumGoal2() async {
    final int value = await ARAnalytics.getNumGoal2();
    return value;
  }

  bool? setUserEngagedState;

  static bool reviewRequestedThisSession = false;

  bool isUserEngaged() {
    return true;
    // bool value = ARAnalytics.isUserEngaged();
    // return value;
  }

  Future<bool> showReviewRequestWithNumberIfRequired(
    int requestNumber,
    BuildContext context,
  ) async {
    if (ARReviewManager.reviewRequestedThisSession) {
      return false;
    }

    if (!(await hwdOnWithSeed())) {
      return false;
    }

    ReviewMode reviewMode = await hwdMode();

    int currentValue = 0;

    if (reviewMode == ReviewMode.ReviewMode_checkins) {
      currentValue = await getNumCheckIns();
    } else if (reviewMode == ReviewMode.ARReviewMode_Goal1) {
      currentValue = await getNumGoal1();
    } else if (reviewMode == ReviewMode.ARReviewMode_Goal2) {
      currentValue = await getNumGoal2();
    }

    int requiredValue = reviewRequiredValueForRequestWithNumber(requestNumber);
    if (currentValue < requiredValue) {
      return false;
    }

    bool hasTrackedBefore = await ARConfig.shared.hasFlagBeenSetBefore(
      "ARReviewPromptedBefore_$requestNumber",
    );
    if (hasTrackedBefore) {
      return false;
    }

    ReviewRequestType requestType = reviewTypeForRequestWithNumber(
      requestNumber,
    );

    Map<String, dynamic> params = {
      "hwdType": requestType,
      "hwdNumber": requestNumber,
    };
    ARAnalytics.shared.trackEventWithName("hwdRequest", params);

    if (requestType == ReviewRequestType.ReviewRequestType_None) {
      return false;
    } else if (requestType == ReviewRequestType.ReviewRequestType_Native) {
      showNativeAppRatingAlert();
    } else if (requestType ==
        ReviewRequestType.ReviewRequestType_AlertRequest) {
      showHowWeDoingAlert(context);
    } else if (requestType ==
        ReviewRequestType.ReviewRequestType_WrittenRequest) {
      showWrittenReviewRequestAlert(context);
    } else if (requestType ==
        ReviewRequestType.ReviewRequestType_Native_Engaged) {
      // Only ask engaged users
      if (isUserEngaged()) {
        showNativeAppRatingAlert();
      }
    } else if (requestType ==
        ReviewRequestType.ReviewRequestType_AlertRequest_Engagement) {
      showHowWeDoingAlertForEngagement(context);
    } else if (requestType ==
        ReviewRequestType.ReviewRequestType_WrittenRequest_Engaged) {
      // TESTED - Only ask engaged users
      if (isUserEngaged()) {
        showWrittenReviewRequestAlert(context);
      }
    }

    ARReviewManager.reviewRequestedThisSession = true;
    return true;
  }

  void showWrittenReviewRequestAlert(BuildContext? context) {
    showWrittenReviewRequestAlertOn(context);
  }

  void showWrittenReviewRequestAlertOn(BuildContext? context) {
    if (context == null) return;

    final String title = "A small favor 🙏";
    final String message = writtenRequestMessage();

    if (Platform.isIOS) {
      // iOS style dialog
      showCupertinoDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return CupertinoAlertDialog(
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(message),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  openAppStoreForWrittenReview();
                },
                child: const Text(
                  "Sure, I'll review ☺️",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              CupertinoDialogAction(
                onPressed: () => Navigator.of(dialogContext).pop(),
                isDestructiveAction: true,
                child: const Text(
                  "No, sorry",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Android / Material style dialog
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  openAppStoreForWrittenReview();
                },
                child: const Text("Sure, I'll review ☺️"),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text("No, sorry"),
              ),
            ],
          );
        },
      );
    }
  }

  void showNativeAppRatingAlertOnceThisSession() async {
    // Check if user has already rated
    if (await _hasUserRated()) {
      return;
    }

    // Show the rating alert if we haven't shown it yet.
    // On the next app launch, this will reset and show again.
    if (!showNativeAppRatingAlertOnceThisSession_marker) {
      showNativeAppRatingAlertOnceThisSession_marker = true;
      showNativeAppRatingAlert();
    }
  }

  void showHowWeDoingAlertForEngagement(BuildContext context) async {
    // Check if user has already rated
    if (await _hasUserRated()) {
      return;
    }

    // Rest of the existing code remains the same...
    ARAppKit.shared.trackOneTimeEventWithName(
      "HowWeDoing_E_Presented",
      params: {},
    );

    const String? title = null;
    const String message = "Are you liking this app so far?";

    if (Platform.isIOS) {
      // iOS style dialog
      showCupertinoDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: title != null ? Text(title) : null,
            content: const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                message,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  ARAppKit.shared.trackOneTimeEventWithName(
                    "HowWeDoing_Yes",
                    params: {},
                  );
                  ARReviewManager.showFeedbackRequestAlert(context);
                  ARReviewManager.shared.setUserEngagedState = true;
                  Navigator.of(ctx).pop();
                },
                child: const Text(
                  "Yes, it's great",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  ARAppKit.shared.trackOneTimeEventWithName(
                    "HowWeDoing_No",
                    params: {},
                  );
                  ARReviewManager.shared.setUserEngagedState = false;

                  Navigator.of(ctx).pop(); // First close the current dialog

                  // Then show the next alert after closing
                  Future.microtask(() {
                    ARReviewManager.showFeedbackRequestAlert(context);
                  });
                },

                isDestructiveAction: true,
                child: const Text(
                  "No, it could be better",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Android / Material style dialog
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: title != null ? Text(title) : null,
            content: const Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  ARAppKit.shared.trackOneTimeEventWithName(
                    "HowWeDoing_Yes",
                    params: {},
                  );
                  ARReviewManager.showFeedbackRequestAlert(context);
                  ARReviewManager.shared.setUserEngagedState = true;
                  Navigator.of(ctx).pop();
                },
                child: const Text("Yes, it's great"),
              ),
              TextButton(
                onPressed: () {
                  ARAppKit.shared.trackOneTimeEventWithName(
                    "HowWeDoing_No",
                    params: {},
                  );
                  ARReviewManager.shared.setUserEngagedState = false;

                  Navigator.of(ctx).pop(); // First close the current dialog

                  // Then show the next alert after closing
                  Future.microtask(() {
                    ARReviewManager.showFeedbackRequestAlert(context);
                  });
                },

                child: const Text("No, it could be better"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> showNativeAppRatingAlert() async {
    // Check if user has already rated
    if (await _hasUserRated()) {
      return;
    }

    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
  }

  Future<bool> _hasUserRated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('userClickedRate') ?? false;
  }

  void showHowWeDoingAlert(BuildContext context) async {
    // Check if user has already rated
    if (await _hasUserRated()) {
      return;
    }

    // Rest of the existing code remains the same...
    ARAppKit.shared.trackOneTimeEventWithName(
      "HowWeDoing_Presented",
      params: {},
    );

    const String message = "Are you liking this app so far?";

    if (Platform.isIOS) {
      // iOS style dialog
      showCupertinoDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: null,
            content: const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                message,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  ARAppKit.shared.trackOneTimeEventWithName(
                    "HowWeDoing_Yes",
                    params: {},
                  );
                  showNativeAppRatingAlert();
                  setUserEngagedState = true;
                  Navigator.of(ctx).pop();
                },
                child: const Text(
                  "Yes, it's great",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  ARAppKit.shared.trackOneTimeEventWithName(
                    "HowWeDoing_No",
                    params: {},
                  );
                  ARReviewManager.shared.setUserEngagedState = false;

                  Navigator.of(ctx).pop(); // First close the current dialog

                  // Then show the next alert after closing
                  Future.microtask(() {
                    ARReviewManager.showFeedbackRequestAlert(context);
                  });
                },

                isDestructiveAction: true,
                child: const Text(
                  "No, it could be better",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Android / Material style dialog
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: null,
            content: const Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  ARAppKit.shared.trackOneTimeEventWithName(
                    "HowWeDoing_Yes",
                    params: {},
                  );
                  showNativeAppRatingAlert();
                  setUserEngagedState = true;
                  Navigator.of(ctx).pop();
                },
                child: const Text("Yes, it's great"),
              ),
              TextButton(
                onPressed: () {
                  ARAppKit.shared.trackOneTimeEventWithName(
                    "HowWeDoing_No",
                    params: {},
                  );
                  ARReviewManager.shared.setUserEngagedState = false;

                  Navigator.of(ctx).pop(); // First close the current dialog

                  // Then show the next alert after closing
                  Future.microtask(() {
                    ARReviewManager.showFeedbackRequestAlert(context);
                  });
                },

                child: const Text("No, it could be better"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> openAppStoreForWrittenReview() async {
    final String appID = ARAnalyticsConstants.APP_ID;
    final String urlString =
        "https://itunes.apple.com/app/id$appID?action=write-review";
    final Uri url = Uri.parse(urlString);

    // Check if appID has more than 5 chars and can open the URL
    if (appID.length > 5 && await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // In Swift: if #available(iOS 13.0, *) { showNativeAppRatingAlert() }
      // Here: just call the same function without iOS version check
      showNativeAppRatingAlert();
    }

    // Equivalent to NotificationCenter.default.post(...)
    // Replace this with your own event/analytics tracking if needed
    // Example: using a simple function call
    reviewDidOpenAppStore();
  }

  // Simple replacement for notification center post
  void reviewDidOpenAppStore() {
    // Track the event or trigger your listeners here
    print("ReviewDidOpenAppStore");
  }

  String writtenRequestMessage() {
    String message =
        "\nDear beloved user,\n\nWe are a small team trying to build a great app for all our beloved users ♥️.\n\nWould you mind leaving us an honest review on the app store to help us grow? It will help us bring you awesome updates and keep this app ad free!";

    // String? valueConfig = ARConfig.sharedInstance.configValueForKey("hwd_wMessage");
    // if (valueConfig != null && valueConfig.length > 5) {
    //   message = valueConfig;
    // }

    return message;
  }

  Future<void> sendEmailWithSubject(String subject) async {
    // TODO: Store this email in a constants file and use the variable
    const String supportEmail = ARAnalyticsConstants.SUPPORT_EMAIL;

    final Email email = Email(
      recipients: [supportEmail],
      subject: subject,
      body: '',
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      print("Mail services are not available: $error");
    }
  }

  bool ratingRequestPosition1Enabled() {
    bool value = false;

    // Retrieve the stored value for key "hwdPos1_native" from local storage
    // Equivalent to: UserDefaults.standard.object(forKey: "hwdPos1_native") as? Int
    final storedValue = prefs.getInt("hwdPos1_native");
    // NOTE: 'prefs' should be your SharedPreferences instance

    if (storedValue != null) {
      value = true;
    }

    return value;
  }

  bool ratingRequestPosition2Enabled() {
    bool value = false;

    // Retrieve the stored value for key "hwdPos2_native" from local storage
    // Equivalent to: UserDefaults.standard.object(forKey: "hwdPos2_native") as? Int
    final storedValue = prefs.getInt("hwdPos2_native");
    // NOTE: 'prefs' should be your SharedPreferences instance

    if (storedValue != null) {
      value = true;
    }

    return value;
  }

  // TESTED
  void showNativeRatingRequestToNewUserIfRequired_position1() async {
    if (await _hasUserRated()) {
      return;
    }

    // Only show to relatively new users
    if (await ARAnalytics.getNumCheckIns() > 1) {
      return;
    }

    // If disabled in config then don't show
    if (!ratingRequestPosition1Enabled()) {
      return;
    }

    // If native alert already shown to user this session, don't show again
    if (showNativeAppRatingAlertOnceThisSession_marker) {
      return;
    }

    // If shown before, don't show
    if (await ARConfig.shared.hasFlagBeenSetBefore(
      "ARReviewPromptedBefore_NativeAlert_Position_1",
    )) {
      return;
    }

    // Show the native app rating alert
    showNativeAppRatingAlertOnceThisSession();
  }

  // TESTED
  void showNativeRatingRequestToNewUserIfRequired_position2() async {
    if (await _hasUserRated()) {
      return;
    }
    // Only show to relatively new users
    if (await ARAnalytics.getNumCheckIns() > 1) {
      return;
    }

    // If disabled in config then don't show
    if (!ratingRequestPosition2Enabled()) {
      return;
    }

    // If native alert already shown to user this session, don't show again
    if (showNativeAppRatingAlertOnceThisSession_marker) {
      return;
    }

    // If shown before, don't show
    if (await ARConfig.shared.hasFlagBeenSetBefore(
      "ARReviewPromptedBefore_NativeAlert_Position_2",
    )) {
      return;
    }

    // Show the native app rating alert
    showNativeAppRatingAlertOnceThisSession();
  }

  ReviewRequestType reviewTypeForRequestWithNumber(int requestNumber) {
    ReviewRequestType type = ReviewRequestType.ReviewRequestType_WrittenRequest;

    // Default config (same as Swift's [3, 5, 3, 1, 5])
    final List<int> valueConfig = [3, 5, 3, 1, 5];
    // If loading from SharedPreferences:
    // final prefs = await SharedPreferences.getInstance();
    // final List<int> valueConfig = prefs.getStringList('hwd_types')?.map(int.parse).toList() ?? [];

    if (valueConfig.isNotEmpty &&
        requestNumber >= 0 &&
        requestNumber < valueConfig.length) {
      final typeNum = valueConfig[requestNumber];
      // Safe enum mapping: if index is invalid, default to None
      type = ReviewRequestType.values.firstWhere(
        (e) => e.index == typeNum,
        orElse: () => ReviewRequestType.ReviewRequestType_None,
      );
    }

    return type;
  }

  int reviewRequiredValueForRequestWithNumber(int requestNumber) {
    int result = 100000;

    // Default config (same as Swift's [1, 3, 5, 7, 11])
    final List<int> valueConfig = [1, 3, 5, 7, 11];
    // If loading from SharedPreferences:
    // final prefs = await SharedPreferences.getInstance();
    // final List<int> valueConfig = prefs.getStringList('hwd_points2')?.map(int.parse).toList() ?? [];

    if (valueConfig.isNotEmpty &&
        requestNumber >= 0 &&
        requestNumber < valueConfig.length) {
      final resultNum = valueConfig[requestNumber];
      result = resultNum;
    }

    return result;
  }

  Future<bool> hwdOnWithSeed() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if value already stored
    final storedValues = prefs.get("ARAppKit_hwdSeed");
    if (storedValues != null) {
      return true;
    }

    // Read hwd_seed, if missing, return true
    final hwd2Seed = prefs.getInt("hwd_seed");
    if (hwd2Seed == null) {
      return true;
    }

    final int numTrueValues = hwd2Seed;
    final int numFalseValues = max(100 - numTrueValues, 0);

    List<int> values = [];

    for (int item = 0; item < numTrueValues; item++) {
      values.add(item);
    }

    for (int item = 0; item < numFalseValues; item++) {
      values.add(item);
    }

    if (values.isNotEmpty) {
      final randomValue = values[Random().nextInt(values.length)];
      if (randomValue >= 0) {
        await prefs.setInt("ARAppKit_hwdSeed", randomValue);
        return true;
      }
      return true;
    }
    return true;
  }
}

class EmailHelper {
  static Future<void> sendEmailWithSubject(String subject) async {
    try {
      // Prepare email
      final email = Email(
        body: '', // Same as Swift's empty body
        subject: subject,
        recipients: [ARAnalyticsConstants.SUPPORT_EMAIL],
        isHTML: false,
      );

      // Try to send
      await FlutterEmailSender.send(email);
    } catch (e) {
      debugPrint("Mail services are not available: $e");
    }
  }
}
