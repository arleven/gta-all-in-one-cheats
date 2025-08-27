// ar_crash_tracking.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:all_gta/ARAppKit/ARAnalytics/ARAnalytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ARCrashTracking {
  // MARK: - Static Methods
  static final ARCrashTracking shared = ARCrashTracking._internal();

  // Private constructor
  ARCrashTracking._internal();

  void initializeService() {
    // Initializes crashlytics, but doesn't start tracking immediately due to plist-style setting that turns it off by default
    initializeCrashlytics();
  }

  // MARK: -  Crashlytics Methods
  void initializeCrashlytics() {
    // Use the Firebase library to configure APIs.
    Firebase.initializeApp();
  }

  Future<void> optInAndStartService() async {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    String userId = await ARAnalytics.shared.getARUserId();

    await analytics.setUserId(id: userId);
    await analytics.setAnalyticsCollectionEnabled(true);

    // Equivalent of: FIRCrashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }

  Future<void> optOutService() async {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    await FirebaseCrashlytics.instance.deleteUnsentReports();
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
  }

  Future<String?> getFirebaseAppInstanceId() async {
    return await FirebaseAnalytics.instance.appInstanceId;
  }

  Future<void> trackEventWithName(
    String eventName,
    Map<String, dynamic>? andParams,
  ) async {
    String sanitizedEventName = eventName.replaceAll(' ', '_');

    await FirebaseAnalytics.instance.logEvent(
      name: sanitizedEventName,
      parameters: andParams?.cast<String, Object>(),
    );
  }
}
