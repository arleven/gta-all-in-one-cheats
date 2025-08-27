class AppConfigResponse {
  final int code;
  final String message;
  final AppConfigData data;

  AppConfigResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory AppConfigResponse.fromJson(Map<String, dynamic> json) {
    return AppConfigResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: AppConfigData.fromJson(json['data']),
    );
  }
}

class AppConfigData {
  final String appId;
  final String bundleId;
  final String appName;
  final Urls urls;
  final List<ToolConfig> configs;

  AppConfigData({
    required this.appId,
    required this.bundleId,
    required this.appName,
    required this.urls,
    required this.configs,
  });

  factory AppConfigData.fromJson(Map<String, dynamic> json) {
    return AppConfigData(
      appId: json['appId'] ?? '',
      bundleId: json['bundleId'] ?? '',
      appName: json['appName'] ?? '',
      urls: Urls.fromJson(json['urls']),
      configs: (json['configs'] as List<dynamic>)
          .map((e) => ToolConfig.fromJson(e))
          .toList(),
    );
  }
}

class Urls {
  final String termsOfService;
  final String privacyPolicy;

  Urls({required this.termsOfService, required this.privacyPolicy});

  factory Urls.fromJson(Map<String, dynamic> json) {
    return Urls(
      termsOfService: json['termsOfService'] ?? '',
      privacyPolicy: json['privacyPolicy'] ?? '',
    );
  }
}

class ToolConfig {
  final String tool;
  final String modelName;
  final String apiKey;

  ToolConfig({
    required this.tool,
    required this.modelName,
    required this.apiKey,
  });

  factory ToolConfig.fromJson(Map<String, dynamic> json) {
    return ToolConfig(
      tool: json['tool'] ?? '',
      modelName: json['modelName'] ?? '',
      apiKey: json['apiKey'] ?? '',
    );
  }
}
