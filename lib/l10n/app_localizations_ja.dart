// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get howWeDoingMessage => 'このアプリは今のところ気に入っていますか？';

  @override
  String get yesGreat => 'はい、素晴らしいです';

  @override
  String get noCouldBeBetter => 'いいえ、もっと良くなると思います';

  @override
  String get reviewTitle => 'ちょっとしたお願い 🙏';

  @override
  String get reviewMessage => '親愛なるユーザーの皆さまへ、\n\n私たちは小さなチームで、皆さまに素晴らしいアプリを届けるために頑張っています ♥️。\n\nよろしければ、アプリストアで正直なレビューを残していただけませんか？それが私たちの成長に繋がり、素晴らしいアップデートをお届けしたり、広告なしでアプリを提供し続ける助けになります！';

  @override
  String get reviewAccept => 'もちろん、レビューします ☺️';

  @override
  String get reviewDecline => 'ごめんなさい、しません';

  @override
  String get feedbackTitle => 'ご意見ありがとうございます！';

  @override
  String get feedbackMessage => 'アプリ改善のためにフィードバックを送っていただけますか？😊';

  @override
  String get sendFeedback => 'フィードバックを送信';

  @override
  String get close => '閉じる';

  @override
  String get searchHint => 'チートを検索';

  @override
  String get cancel => 'キャンセル';

  @override
  String get favoritesTitle => '❤️ お気に入り';

  @override
  String get loading => '読み込み中...';

  @override
  String get sectionIconLabel => 'セクション';

  @override
  String get userSettings => 'ユーザー設定';

  @override
  String get platformTitle => 'プラットフォーム';

  @override
  String get platformSubtitle => 'ご利用のプラットフォームを選択してください。';

  @override
  String get contactSection => 'お問い合わせ';

  @override
  String get contactMeTitle => 'お問い合わせ';

  @override
  String get contactMeSubtitle => 'ご質問やサポートについては私たちにご連絡ください。';

  @override
  String get couldNotOpenMailApp => 'メールアプリを開けませんでした';

  @override
  String get informationSection => '情報';

  @override
  String get privacyPolicyTitle => 'プライバシーポリシー';

  @override
  String get privacyPolicySubtitle => 'アプリのプライバシーに関する情報をご覧ください。';

  @override
  String get termsOfServiceTitle => '利用規約';

  @override
  String get termsOfServiceSubtitle => 'ガイドラインをご確認ください。';

  @override
  String get languageSection => '言語';

  @override
  String get changeLanguageTitle => '言語を変更';

  @override
  String get changeLanguageSubtitle => '言語を切り替えます。';

  @override
  String languageChangedMessage(String language) {
    return '言語が $language に変更されました';
  }

  @override
  String get playstation => 'プレイステーション';

  @override
  String get pc => 'PC';

  @override
  String get xbox => 'Xbox';

  @override
  String get iphone => 'iPhone';

  @override
  String get settings => '設定';

  @override
  String get cheatHelpTitle => 'iPhoneでチートを使うには？';

  @override
  String get cheatStep1 => '画面左上のマップをタップしてゲームを一時停止します。';

  @override
  String get cheatStep2 => '左側のメニューから「オプション」を選択します。';

  @override
  String get cheatStep3 => '上部のメニューから「アクセシビリティ」を選択します。';

  @override
  String get cheatStep4 => '下にスクロールして「チートコードを入力」を選択します。';

  @override
  String get cheatStep5 => '表示されたキーボードを使って使用したいチートコードを入力します。';

  @override
  String get cheatHelpNote => 'デフィニティブ・エディションを持っていない場合、チートコードを使用する唯一の方法は、外部キーボードをデバイスに接続することです。';
}
