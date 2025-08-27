// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get howWeDoingMessage => 'Vous aimez cette application jusqu\'à présent ?';

  @override
  String get yesGreat => 'Oui, elle est géniale';

  @override
  String get noCouldBeBetter => 'Non, cela pourrait être mieux';

  @override
  String get reviewTitle => 'Un petit service 🙏';

  @override
  String get reviewMessage => 'Cher utilisateur,\n\nNous sommes une petite équipe qui essaie de créer une super application pour tous nos utilisateurs adorés ♥️.\n\nPourriez-vous nous laisser un avis honnête sur l’App Store pour nous aider à grandir ? Cela nous aidera à vous proposer des mises à jour géniales et à garder cette application sans publicité !';

  @override
  String get reviewAccept => 'Bien sûr, je vais laisser un avis ☺️';

  @override
  String get reviewDecline => 'Non, désolé';

  @override
  String get feedbackTitle => 'Merci pour votre retour !';

  @override
  String get feedbackMessage => 'Accepteriez-vous de nous envoyer vos commentaires pour nous aider à nous améliorer ? 😊';

  @override
  String get sendFeedback => 'Envoyer un retour';

  @override
  String get close => 'Fermer';

  @override
  String get searchHint => 'Rechercher un code de triche';

  @override
  String get cancel => 'Annuler';

  @override
  String get favoritesTitle => '❤️ Favoris';

  @override
  String get loading => 'Chargement...';

  @override
  String get sectionIconLabel => 'Section';

  @override
  String get userSettings => 'Paramètres utilisateur';

  @override
  String get platformTitle => 'Plateforme';

  @override
  String get platformSubtitle => 'Choisissez votre plateforme.';

  @override
  String get contactSection => 'Contact';

  @override
  String get contactMeTitle => 'Nous contacter';

  @override
  String get contactMeSubtitle => 'Contactez-nous pour des questions ou du support.';

  @override
  String get couldNotOpenMailApp => 'Impossible d’ouvrir l’application mail';

  @override
  String get informationSection => 'Informations';

  @override
  String get privacyPolicyTitle => 'Politique de confidentialité';

  @override
  String get privacyPolicySubtitle => 'En savoir plus sur la confidentialité de l’application.';

  @override
  String get termsOfServiceTitle => 'Conditions d’utilisation';

  @override
  String get termsOfServiceSubtitle => 'Familiarisez-vous avec nos règles.';

  @override
  String get languageSection => 'Langue';

  @override
  String get changeLanguageTitle => 'Changer de langue';

  @override
  String get changeLanguageSubtitle => 'Changer la langue.';

  @override
  String languageChangedMessage(String language) {
    return 'Langue changée en $language';
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
  String get settings => 'Paramètres';

  @override
  String get cheatHelpTitle => 'Comment utiliser les codes de triche sur iPhone ?';

  @override
  String get cheatStep1 => 'Mettez le jeu en pause en appuyant sur la carte en haut à gauche de l\'écran.';

  @override
  String get cheatStep2 => 'Dans le menu de gauche, sélectionnez \"Options\".';

  @override
  String get cheatStep3 => 'Dans le menu du haut, sélectionnez \"Accessibilité\".';

  @override
  String get cheatStep4 => 'Faites défiler vers le bas et sélectionnez \"Entrer un code de triche\".';

  @override
  String get cheatStep5 => 'À l\'aide du clavier qui s\'affiche, tapez le code de triche que vous souhaitez utiliser.';

  @override
  String get cheatHelpNote => 'Si vous n\'avez PAS l\'Édition Définitive, la seule façon d\'utiliser des codes de triche est de connecter un clavier externe à votre appareil.';
}
