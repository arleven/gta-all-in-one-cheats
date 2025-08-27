// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get howWeDoingMessage => '你目前喜欢这个应用吗？';

  @override
  String get yesGreat => '是的，很棒';

  @override
  String get noCouldBeBetter => '不，还可以更好';

  @override
  String get reviewTitle => '一个小小的请求 🙏';

  @override
  String get reviewMessage => '亲爱的用户，\n\n我们是一个小团队，致力于为所有亲爱的用户打造一个优秀的应用 ♥️。\n\n您愿意在应用商店留下真实的评价来帮助我们成长吗？这将有助于我们带来精彩的更新，并保持应用无广告！';

  @override
  String get reviewAccept => '好的，我去评价 ☺️';

  @override
  String get reviewDecline => '不，谢谢';

  @override
  String get feedbackTitle => '感谢您的反馈！';

  @override
  String get feedbackMessage => '您愿意发送反馈，帮助我们改进吗？😊';

  @override
  String get sendFeedback => '发送反馈';

  @override
  String get close => '关闭';

  @override
  String get searchHint => '搜索任何秘籍';

  @override
  String get cancel => '取消';

  @override
  String get favoritesTitle => '❤️ 收藏夹';

  @override
  String get loading => '加载中...';

  @override
  String get sectionIconLabel => '分类';

  @override
  String get userSettings => '用户设置';

  @override
  String get platformTitle => '平台';

  @override
  String get platformSubtitle => '请选择您的平台。';

  @override
  String get contactSection => '联系';

  @override
  String get contactMeTitle => '联系我们';

  @override
  String get contactMeSubtitle => '如有疑问或需要支持，请与我们联系。';

  @override
  String get couldNotOpenMailApp => '无法打开邮件应用';

  @override
  String get informationSection => '信息';

  @override
  String get privacyPolicyTitle => '隐私政策';

  @override
  String get privacyPolicySubtitle => '了解有关应用隐私的更多信息。';

  @override
  String get termsOfServiceTitle => '服务条款';

  @override
  String get termsOfServiceSubtitle => '了解我们的使用规范。';

  @override
  String get languageSection => '语言';

  @override
  String get changeLanguageTitle => '更改语言';

  @override
  String get changeLanguageSubtitle => '更换应用语言。';

  @override
  String languageChangedMessage(String language) {
    return '语言已更改为 $language';
  }

  @override
  String get playstation => 'PlayStation';

  @override
  String get pc => '电脑';

  @override
  String get xbox => 'Xbox';

  @override
  String get iphone => 'iPhone';

  @override
  String get settings => '设置';

  @override
  String get cheatHelpTitle => '如何使用 iPhone 作弊码？';

  @override
  String get cheatStep1 => '点击屏幕左上角的地图暂停游戏。';

  @override
  String get cheatStep2 => '在左侧选项中选择“选项”。';

  @override
  String get cheatStep3 => '在顶部菜单中选择“辅助功能”。';

  @override
  String get cheatStep4 => '向下滚动并选择“输入作弊码”。';

  @override
  String get cheatStep5 => '使用弹出的键盘输入你想使用的作弊码。';

  @override
  String get cheatHelpNote => '如果你没有终极版，唯一可以在游戏中使用作弊码的方法是将外接键盘插入你的设备。';
}
