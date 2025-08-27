// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get howWeDoingMessage => '지금까지 이 앱이 마음에 드시나요?';

  @override
  String get yesGreat => '네, 정말 좋아요';

  @override
  String get noCouldBeBetter => '아니요, 더 나아질 수 있어요';

  @override
  String get reviewTitle => '작은 부탁 🙏';

  @override
  String get reviewMessage => '소중한 사용자님께,\n\n우리는 모든 사용자분들을 위해 멋진 앱을 만들기 위해 노력하는 소규모 팀입니다 ♥️.\n\n앱 스토어에 솔직한 리뷰를 남겨 저희가 성장할 수 있도록 도와주시겠어요? 여러분의 도움이 있다면 멋진 업데이트를 제공하고 광고 없이 앱을 유지할 수 있습니다!';

  @override
  String get reviewAccept => '좋아요, 리뷰할게요 ☺️';

  @override
  String get reviewDecline => '죄송해요, 안 할래요';

  @override
  String get feedbackTitle => '알려주셔서 감사합니다!';

  @override
  String get feedbackMessage => '더 나은 앱을 만들 수 있도록 피드백을 보내주시겠어요? 😊';

  @override
  String get sendFeedback => '피드백 보내기';

  @override
  String get close => '닫기';

  @override
  String get searchHint => '치트 검색';

  @override
  String get cancel => '취소';

  @override
  String get favoritesTitle => '❤️ 즐겨찾기';

  @override
  String get loading => '로딩 중...';

  @override
  String get sectionIconLabel => '섹션';

  @override
  String get userSettings => '사용자 설정';

  @override
  String get platformTitle => '플랫폼';

  @override
  String get platformSubtitle => '사용 중인 플랫폼을 선택하세요.';

  @override
  String get contactSection => '문의';

  @override
  String get contactMeTitle => '문의하기';

  @override
  String get contactMeSubtitle => '문의나 지원이 필요하시면 저희에게 연락주세요.';

  @override
  String get couldNotOpenMailApp => '메일 앱을 열 수 없습니다';

  @override
  String get informationSection => '정보';

  @override
  String get privacyPolicyTitle => '개인정보 처리방침';

  @override
  String get privacyPolicySubtitle => '앱의 개인정보 보호 정책에 대해 알아보세요.';

  @override
  String get termsOfServiceTitle => '서비스 이용약관';

  @override
  String get termsOfServiceSubtitle => '저희의 가이드라인을 확인하세요.';

  @override
  String get languageSection => '언어';

  @override
  String get changeLanguageTitle => '언어 변경';

  @override
  String get changeLanguageSubtitle => '언어를 변경하세요.';

  @override
  String languageChangedMessage(String language) {
    return '언어가 $language(으)로 변경되었습니다';
  }

  @override
  String get playstation => '플레이스테이션';

  @override
  String get pc => 'PC';

  @override
  String get xbox => '엑스박스';

  @override
  String get iphone => '아이폰';

  @override
  String get settings => '설정';

  @override
  String get cheatHelpTitle => 'iPhone 치트 사용하는 방법?';

  @override
  String get cheatStep1 => '화면 왼쪽 상단의 지도를 눌러 게임을 일시 정지합니다.';

  @override
  String get cheatStep2 => '왼쪽에서 \'옵션\'을 선택합니다.';

  @override
  String get cheatStep3 => '상단의 선택지 중에서 \'접근성\'을 선택합니다.';

  @override
  String get cheatStep4 => '아래로 스크롤하여 \'치트 코드 입력\'을 선택합니다.';

  @override
  String get cheatStep5 => '표시되는 키보드를 사용하여 원하는 치트 코드를 입력합니다.';

  @override
  String get cheatHelpNote => '디피니티브 에디션이 없는 경우, 치트 코드를 사용하는 유일한 방법은 외부 키보드를 장치에 연결하는 것입니다.';
}
