class CheatCode {
  final String title;
  final String description;
  final String codes;
  final String section;
  final String? phoneNum;
  final Map<String, dynamic> rawData;

  CheatCode({
    required this.title,
    required this.description,
    required this.codes,
    required this.section,
    this.phoneNum,
    required this.rawData,
  });

  factory CheatCode.fromJson(Map<String, dynamic> json) {
    return CheatCode(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      codes: json['codes'] ?? '',
      section: json['section'] ?? '',
      phoneNum: json['phoneNum'] as String?,
      rawData: json,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'title': title,
      'description': description,
      'codes': codes,
      'section': section,
    };

    if (phoneNum != null && phoneNum!.isNotEmpty) {
      data['phoneNum'] = phoneNum!;
    }

    return data;
  }
}
