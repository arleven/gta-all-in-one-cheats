// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get howWeDoingMessage => 'Вам нравится это приложение?';

  @override
  String get yesGreat => 'Да, отличное';

  @override
  String get noCouldBeBetter => 'Нет, могло бы быть лучше';

  @override
  String get reviewTitle => 'Небольшая просьба 🙏';

  @override
  String get reviewMessage => 'Дорогой пользователь,\n\nМы — небольшая команда, старающаяся создать отличное приложение для всех наших любимых пользователей ♥️.\n\nНе могли бы вы оставить нам честный отзыв в магазине приложений, чтобы помочь нам расти? Это поможет нам выпускать классные обновления и сохранить приложение без рекламы!';

  @override
  String get reviewAccept => 'Конечно, оставлю отзыв ☺️';

  @override
  String get reviewDecline => 'Нет, извините';

  @override
  String get feedbackTitle => 'Спасибо, что сообщили нам!';

  @override
  String get feedbackMessage => 'Не могли бы вы отправить нам отзыв, чтобы помочь нам стать лучше? 😊';

  @override
  String get sendFeedback => 'Отправить отзыв';

  @override
  String get close => 'Закрыть';

  @override
  String get searchHint => 'Найти чит';

  @override
  String get cancel => 'Отмена';

  @override
  String get favoritesTitle => '❤️ Избранное';

  @override
  String get loading => 'Загрузка...';

  @override
  String get sectionIconLabel => 'Раздел';

  @override
  String get userSettings => 'Настройки пользователя';

  @override
  String get platformTitle => 'Платформа';

  @override
  String get platformSubtitle => 'Выберите свою платформу.';

  @override
  String get contactSection => 'Контакт';

  @override
  String get contactMeTitle => 'Связаться с нами';

  @override
  String get contactMeSubtitle => 'Свяжитесь с нами для вопросов или поддержки.';

  @override
  String get couldNotOpenMailApp => 'Не удалось открыть почтовое приложение';

  @override
  String get informationSection => 'Информация';

  @override
  String get privacyPolicyTitle => 'Политика конфиденциальности';

  @override
  String get privacyPolicySubtitle => 'Узнайте больше о политике конфиденциальности приложения.';

  @override
  String get termsOfServiceTitle => 'Условия использования';

  @override
  String get termsOfServiceSubtitle => 'Ознакомьтесь с нашими правилами.';

  @override
  String get languageSection => 'Язык';

  @override
  String get changeLanguageTitle => 'Сменить язык';

  @override
  String get changeLanguageSubtitle => 'Изменить язык.';

  @override
  String languageChangedMessage(String language) {
    return 'Язык изменён на $language';
  }

  @override
  String get playstation => 'PlayStation';

  @override
  String get pc => 'ПК';

  @override
  String get xbox => 'Xbox';

  @override
  String get iphone => 'iPhone';

  @override
  String get settings => 'Настройки';

  @override
  String get cheatHelpTitle => 'Как использовать читы на iPhone?';

  @override
  String get cheatStep1 => 'Поставьте игру на паузу, нажав на карту в левом верхнем углу экрана.';

  @override
  String get cheatStep2 => 'В меню слева выберите «Настройки».';

  @override
  String get cheatStep3 => 'В верхнем меню выберите «Специальные возможности».';

  @override
  String get cheatStep4 => 'Прокрутите вниз и выберите «Ввести чит-код».';

  @override
  String get cheatStep5 => 'С помощью появившейся клавиатуры введите нужный чит-код.';

  @override
  String get cheatHelpNote => 'Если у вас НЕТ Definitive Edition, единственный способ использовать читы — подключить внешнюю клавиатуру к вашему устройству.';
}
