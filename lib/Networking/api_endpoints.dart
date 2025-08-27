class ApiEndpoints {
  static const String baseUrl =
      'https://quiz-api-pudf.onrender.com/v1/apps/6832a8b067a5b49dec3e076c';

  static String getAllQuestions(String userId) => '$baseUrl/quiz/test';
  static const String postAnswer = '$baseUrl/answers';

  static String report(String id) => '$baseUrl/questions/$id/report';

  static String skippedQuestions(String userId) =>
      '$baseUrl/quiz/missed?userId=$userId';
  static String randomQuestions(String userId) =>
      '$baseUrl/quiz/random?userId=$userId';
  static String timedQuestions(String userId) =>
      '$baseUrl/quiz/timed?userId=$userId';

  static const String userPreferences = '$baseUrl/preferences';
  static const String updatePreferences = '$baseUrl/preferences';
  static String getPrefs(String userId) => '$baseUrl/preferences/$userId';
  static String saveQuestion(String userId) =>
      '$baseUrl/questions/save/$userId';
  static String getSavedQuestions(String userId) =>
      '$baseUrl/quiz/saved?userId=$userId';
  static String stats(String userId) => '$baseUrl/stats/$userId';
  static String streak(String userId, String timeZone) =>
      '$baseUrl/stats/$userId/streak?tz=$timeZone';
  static String todayQuestion(String userId) =>
      '$baseUrl/quiz/today?userId=$userId';

  static String getReview(String userId) => '$baseUrl/review?userId=$userId';

  static const String registerToken = '$baseUrl/device-tokens/register';

  static const String config = '$baseUrl/config';

  static String resetProgress(String userId) =>
      '$baseUrl/users/$userId/reset-progress';

  static const String contactUs = '$baseUrl/contact';
  static String postTodaysAnswer = '$baseUrl/quiz/today/answer';
  static String quickQuiz(String userId) =>
      '$baseUrl/quiz/quick?userId=$userId';
  static String answerQuickQuiz = '$baseUrl/quiz/quick/answer';
  static String answerRandomQuiz = '$baseUrl/quiz/random/answer';
  static String answerTimedQuiz = '$baseUrl/quiz/timed/answer';
  static String answerMissedQuiz = '$baseUrl/quiz/missed/answer';
  static String answerSavedQuiz = '$baseUrl/quiz/saved/answer';
  static String resetchatBot =
      'https://quiz-api-pudf.onrender.com/v1/apps/6836d0bb4c85b017bc545b4f/reset';

  static String chatBot =
      "https://quiz-api-pudf.onrender.com/v1/apps/6836d0bb4c85b017bc545b4f/chat";
}
