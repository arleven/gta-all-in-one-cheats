class HiddenLocation {
  final String section;
  final String title;
  final String videoUrl;
  final String desc;
  final Map<String, dynamic> rawData;

  HiddenLocation({
    required this.section,
    required this.title,
    required this.videoUrl,
    required this.desc,
    required this.rawData,
  });

  factory HiddenLocation.fromJson(Map<String, dynamic> json) {
    return HiddenLocation(
      section: json['section'] ?? json['Section'] ?? '',
      title: json['title'] ?? json['Title'] ?? '',

      videoUrl:
          json['videoUrl'] ??
          json['VideoUrl'] ??
          json['videoURL'] ??
          json['Youtube'] ??
          json['youtube'] ??
          '',
      desc: json['desc'] ?? json['Desc'] ?? '',
      rawData: json,
    );
  }

  Map<String, dynamic> toJson() => {
    'section': section,
    'title': title,
    'videoUrl': videoUrl,
    'desc': desc,
  };
}
