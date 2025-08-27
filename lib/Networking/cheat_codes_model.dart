class CheatCode {
  final String title;
  final String description;
  final String codes;
  final String section;
  final Map<String, dynamic> rawData;

  CheatCode({
    required this.title,
    required this.description,
    required this.codes,
    required this.section,
    required this.rawData,
  });

  factory CheatCode.fromJson(Map<String, dynamic> json) {
    return CheatCode(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      codes: json['codes'] ?? '',
      section: json['section'] ?? '',
      rawData: json,
    );
  }
}
