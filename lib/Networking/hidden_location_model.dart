class HiddenLocation {
  final String section;
  final String title;
  final String videourl;
  final String desc;
  final Map<String, dynamic> rawData;

  HiddenLocation({
    required this.section,
    required this.title,
    required this.videourl,
    required this.desc,
    required this.rawData,
  });

  factory HiddenLocation.fromJson(Map<String, dynamic> json) {
    return HiddenLocation(
      section: json['section'] ?? json['Section'] ?? '',
      title: json['title'] ?? json['Title'] ?? '',
      videourl: json['videourl'] ?? json['videourl'] ?? '',
      desc: json['desc'] ?? json['Desc'] ?? '',
      rawData: json,
    );
  }

  Map<String, dynamic> toJson() => {
    'section': section,
    'title': title,
    'videourl': videourl,
    'desc': desc,
  };
}
