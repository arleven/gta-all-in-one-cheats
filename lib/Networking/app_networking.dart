import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkRequestType { GET, POST, PUT, DELETE, PATCH }

enum ResponseCode {
  success,
  created,
  badRequest,
  unauthorized,
  internalServerError,
  noInternet,
  unknown,
}

typedef NetworkCallback = Function(
  dynamic data,
  ResponseCode code,
  String? message,
);

class NetworkRequest {
  final String url;
  final NetworkRequestType method;
  final Map<String, dynamic>? params;
  final Map<String, String>? headers;
  final NetworkCallback? callback;

  NetworkRequest({
    required this.url,
    required this.method,
    this.params,
    this.headers,
    this.callback,
  });
}

class AppNetworking {
  static final AppNetworking instance = AppNetworking._internal();
  AppNetworking._internal();

  Future<bool> _isInternetAvailable() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void callRequest(NetworkRequest request) async {
    if (!await _isInternetAvailable()) {
      request.callback
          ?.call(null, ResponseCode.noInternet, 'No Internet Connection');
      return;
    }

    try {
      final uri = Uri.parse(request.url);
      final headers = request.headers ?? {'Content-Type': 'application/json'};
      http.Response response;

      switch (request.method) {
        case NetworkRequestType.GET:
          response = await http.get(uri, headers: headers);
          break;
        case NetworkRequestType.POST:
          response = await http.post(uri,
              headers: headers, body: jsonEncode(request.params ?? {}));
          break;
        case NetworkRequestType.PUT:
          response = await http.put(uri,
              headers: headers, body: jsonEncode(request.params ?? {}));
          break;
        case NetworkRequestType.DELETE:
          response = await http.delete(uri, headers: headers);
          break;
        case NetworkRequestType.PATCH:
          response = await http.patch(uri,
              headers: headers, body: jsonEncode(request.params ?? {}));
          break;
      }

      print('Request: ${request.method} ${request.url}');
      print('Request Headers: $headers');
      print('Request Params: ${request.params}');

      final statusCode = response.statusCode;
      final responseCode = _mapStatusCode(statusCode);
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      dynamic data;
      try {
        data = json.decode(response.body);
      } catch (_) {
        data = response.body;
      }

      request.callback?.call(data, responseCode, null);
    } catch (e) {
      request.callback?.call(null, ResponseCode.unknown, e.toString());
    }
  }

  ResponseCode _mapStatusCode(int statusCode) {
    switch (statusCode) {
      case 200:
        return ResponseCode.success;
      case 201:
        return ResponseCode.created;
      case 400:
        return ResponseCode.badRequest;
      case 401:
        return ResponseCode.unauthorized;
      case 500:
        return ResponseCode.internalServerError;
      default:
        return ResponseCode.unknown;
    }
  }
}
