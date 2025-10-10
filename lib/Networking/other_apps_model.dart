class OtherApp {
  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String appStoreUrl;

  OtherApp({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.appStoreUrl,
  });

  factory OtherApp.fromJson(Map<String, dynamic> json) {
    return OtherApp(
      id: json['id'].toString(),
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      appStoreUrl: json['appStoreUrl'] ?? '',
    );
  }
}
