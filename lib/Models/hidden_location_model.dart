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
      section: json['section'] ?? '',
      title: json['title'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      desc: json['desc'] ?? '',
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
