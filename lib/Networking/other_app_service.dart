import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:all_gta/Networking/other_apps_model.dart';

class OtherAppsService {
  static const String sheetUrl =
      'https://script.google.com/macros/s/AKfycbxwEKaXpOjWb_IgMeBdCx2TTwuZWX-iIoqlzeXqLfWCY_oPhdZnFxUSMXaIHt2_jOQ/exec';

  static List<OtherApp> _apps = [];

  static List<OtherApp> get apps => _apps;

  static Future<void> fetchOtherApps() async {
    try {
      final response = await http.get(Uri.parse(sheetUrl));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        _apps = data.map((e) => OtherApp.fromJson(e)).toList();
      } else {
        print("Failed to load apps: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching apps: $e");
    }
  }
}
