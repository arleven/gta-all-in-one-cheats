import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:all_gta/Networking/other_apps_model.dart';

class OtherAppsService {
  static const String sheetUrl =
      'https://script.google.com/macros/s/AKfycbxwEKaXpOjWb_IgMeBdCx2TTwuZWX-iIoqlzeXqLfWCY_oPhdZnFxUSMXaIHt2_jOQ/exec';

  static Future<List<OtherApp>> fetchOtherApps() async {
    final response = await http.get(Uri.parse(sheetUrl));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => OtherApp.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load apps');
    }
  }
}
