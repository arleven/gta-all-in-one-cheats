import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fil.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fil'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('ms'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('tr'),
    Locale('zh')
  ];

  /// No description provided for @howWeDoingMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you liking this app so far?'**
  String get howWeDoingMessage;

  /// No description provided for @yesGreat.
  ///
  /// In en, this message translates to:
  /// **'Yes, it\'s great'**
  String get yesGreat;

  /// No description provided for @noCouldBeBetter.
  ///
  /// In en, this message translates to:
  /// **'No, it could be better'**
  String get noCouldBeBetter;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'A small favor 🙏'**
  String get reviewTitle;

  /// No description provided for @reviewMessage.
  ///
  /// In en, this message translates to:
  /// **'Dear beloved user,\n\nWe are a small team trying to build a great app for all our beloved users ♥️.\n\nWould you mind leaving us an honest review on the app store to help us grow? It will help us bring you awesome updates and keep this app ad free!'**
  String get reviewMessage;

  /// No description provided for @reviewAccept.
  ///
  /// In en, this message translates to:
  /// **'Sure, I\'ll review ☺️'**
  String get reviewAccept;

  /// No description provided for @reviewDecline.
  ///
  /// In en, this message translates to:
  /// **'No, sorry'**
  String get reviewDecline;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Thanks for letting us know!'**
  String get feedbackTitle;

  /// No description provided for @feedbackMessage.
  ///
  /// In en, this message translates to:
  /// **'Would you mind sending us feedback to help us improve? 😊'**
  String get feedbackMessage;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search any cheat'**
  String get searchHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'❤️ Favorites'**
  String get favoritesTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @sectionIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get sectionIconLabel;

  /// No description provided for @userSettings.
  ///
  /// In en, this message translates to:
  /// **'User Settings'**
  String get userSettings;

  /// No description provided for @platformTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platformTitle;

  /// No description provided for @platformSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your platform.'**
  String get platformSubtitle;

  /// No description provided for @contactSection.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactSection;

  /// No description provided for @contactMeTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactMeTitle;

  /// No description provided for @contactMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get in touch with us for inquiries or support.'**
  String get contactMeSubtitle;

  /// No description provided for @couldNotOpenMailApp.
  ///
  /// In en, this message translates to:
  /// **'Could not open mail app'**
  String get couldNotOpenMailApp;

  /// No description provided for @informationSection.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get informationSection;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn more about the app\'s privacy practices.'**
  String get privacyPolicySubtitle;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms Of Service'**
  String get termsOfServiceTitle;

  /// No description provided for @termsOfServiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Familiarize yourself with our guidelines.'**
  String get termsOfServiceSubtitle;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// No description provided for @changeLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguageTitle;

  /// No description provided for @changeLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change Languages.'**
  String get changeLanguageSubtitle;

  /// Message shown after the user changes the language.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChangedMessage(String language);

  /// No description provided for @playstation.
  ///
  /// In en, this message translates to:
  /// **'PlayStation'**
  String get playstation;

  /// No description provided for @pc.
  ///
  /// In en, this message translates to:
  /// **'PC'**
  String get pc;

  /// No description provided for @xbox.
  ///
  /// In en, this message translates to:
  /// **'Xbox'**
  String get xbox;

  /// No description provided for @iphone.
  ///
  /// In en, this message translates to:
  /// **'iPhone'**
  String get iphone;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @cheatHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'How to use iPhone cheats?'**
  String get cheatHelpTitle;

  /// No description provided for @cheatStep1.
  ///
  /// In en, this message translates to:
  /// **'Pause the game by pressing on the map at the top-left of the screen.'**
  String get cheatStep1;

  /// No description provided for @cheatStep2.
  ///
  /// In en, this message translates to:
  /// **'From the choices on the left, select \"Options\".'**
  String get cheatStep2;

  /// No description provided for @cheatStep3.
  ///
  /// In en, this message translates to:
  /// **'From the choices at the top, select \"Accessibility\".'**
  String get cheatStep3;

  /// No description provided for @cheatStep4.
  ///
  /// In en, this message translates to:
  /// **'Scroll down and select \"Enter cheat code\".'**
  String get cheatStep4;

  /// No description provided for @cheatStep5.
  ///
  /// In en, this message translates to:
  /// **'Using the keyboard that pops up, type in the cheat code you want to use.'**
  String get cheatStep5;

  /// No description provided for @cheatHelpNote.
  ///
  /// In en, this message translates to:
  /// **'If you do NOT have the Definitive Edition, the only way to use cheat codes in the game is by plugging an external keyboard into your device.'**
  String get cheatHelpNote;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'de', 'en', 'es', 'fil', 'fr', 'hi', 'it', 'ja', 'ko', 'ms', 'pl', 'pt', 'ru', 'th', 'tr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fil': return AppLocalizationsFil();
    case 'fr': return AppLocalizationsFr();
    case 'hi': return AppLocalizationsHi();
    case 'it': return AppLocalizationsIt();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'ms': return AppLocalizationsMs();
    case 'pl': return AppLocalizationsPl();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'th': return AppLocalizationsTh();
    case 'tr': return AppLocalizationsTr();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
