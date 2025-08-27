// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get howWeDoingMessage => 'Are you liking this app so far?';

  @override
  String get yesGreat => 'Yes, it\'s great';

  @override
  String get noCouldBeBetter => 'No, it could be better';

  @override
  String get reviewTitle => 'A small favor 🙏';

  @override
  String get reviewMessage => 'Dear beloved user,\n\nWe are a small team trying to build a great app for all our beloved users ♥️.\n\nWould you mind leaving us an honest review on the app store to help us grow? It will help us bring you awesome updates and keep this app ad free!';

  @override
  String get reviewAccept => 'Sure, I\'ll review ☺️';

  @override
  String get reviewDecline => 'No, sorry';

  @override
  String get feedbackTitle => 'Thanks for letting us know!';

  @override
  String get feedbackMessage => 'Would you mind sending us feedback to help us improve? 😊';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get close => 'Close';

  @override
  String get searchHint => 'Search any cheat';

  @override
  String get cancel => 'Cancel';

  @override
  String get favoritesTitle => '❤️ Favorites';

  @override
  String get loading => 'Loading...';

  @override
  String get sectionIconLabel => 'Section';

  @override
  String get userSettings => 'User Settings';

  @override
  String get platformTitle => 'Platform';

  @override
  String get platformSubtitle => 'Choose your platform.';

  @override
  String get contactSection => 'Contact';

  @override
  String get contactMeTitle => 'Contact Us';

  @override
  String get contactMeSubtitle => 'Get in touch with us for inquiries or support.';

  @override
  String get couldNotOpenMailApp => 'Could not open mail app';

  @override
  String get informationSection => 'Information';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'Learn more about the app\'s privacy practices.';

  @override
  String get termsOfServiceTitle => 'Terms Of Service';

  @override
  String get termsOfServiceSubtitle => 'Familiarize yourself with our guidelines.';

  @override
  String get languageSection => 'Language';

  @override
  String get changeLanguageTitle => 'Change Language';

  @override
  String get changeLanguageSubtitle => 'Change Languages.';

  @override
  String languageChangedMessage(String language) {
    return 'Language changed to $language';
  }

  @override
  String get playstation => 'PlayStation';

  @override
  String get pc => 'PC';

  @override
  String get xbox => 'Xbox';

  @override
  String get iphone => 'iPhone';

  @override
  String get settings => 'Settings';

  @override
  String get cheatHelpTitle => 'How to use iPhone cheats?';

  @override
  String get cheatStep1 => 'Pause the game by pressing on the map at the top-left of the screen.';

  @override
  String get cheatStep2 => 'From the choices on the left, select \"Options\".';

  @override
  String get cheatStep3 => 'From the choices at the top, select \"Accessibility\".';

  @override
  String get cheatStep4 => 'Scroll down and select \"Enter cheat code\".';

  @override
  String get cheatStep5 => 'Using the keyboard that pops up, type in the cheat code you want to use.';

  @override
  String get cheatHelpNote => 'If you do NOT have the Definitive Edition, the only way to use cheat codes in the game is by plugging an external keyboard into your device.';
}
