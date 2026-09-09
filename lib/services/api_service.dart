import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

Map<String, dynamic> asJsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw Exception('Invalid JSON object from API');
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  String? lastError;

  Future<void> initToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey);
  }

  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null && token.isNotEmpty) {
      await prefs.setString(AppConstants.tokenKey, token);
    } else {
      await prefs.remove(AppConstants.tokenKey);
    }
  }

  String? get token => _token;

  Map<String, String> _buildHeaders({bool skipAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (!skipAuth && _token != null && _token!.isNotEmpty) {
      headers['token'] = _token!;
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String endpoint, {bool skipAuth = false}) async {
    final url = Uri.parse('${AppConstants.backendUrl}$endpoint');
    try {
      final response = await http
          .get(url, headers: _buildHeaders(skipAuth: skipAuth))
          .timeout(const Duration(seconds: 20));
      return _processResponse(response, endpoint);
    } catch (e) {
      lastError = _friendlyError(e, endpoint);
      debugPrint('[Kozzy API] GET $endpoint failed: $lastError');
      throw Exception(lastError);
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool skipAuth = false,
  }) async {
    final url = Uri.parse('${AppConstants.backendUrl}$endpoint');
    try {
      final response = await http
          .post(
            url,
            headers: _buildHeaders(skipAuth: skipAuth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 25));
      return _processResponse(response, endpoint);
    } catch (e) {
      lastError = _friendlyError(e, endpoint);
      debugPrint('[Kozzy API] POST $endpoint failed: $lastError');
      throw Exception(lastError);
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool skipAuth = false,
  }) async {
    final url = Uri.parse('${AppConstants.backendUrl}$endpoint');
    try {
      final response = await http
          .put(
            url,
            headers: _buildHeaders(skipAuth: skipAuth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
      return _processResponse(response, endpoint);
    } catch (e) {
      lastError = _friendlyError(e, endpoint);
      debugPrint('[Kozzy API] PUT $endpoint failed: $lastError');
      throw Exception(lastError);
    }
  }

  Map<String, dynamic> _processResponse(http.Response response, String endpoint) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      lastError = null;
      if (response.body.isEmpty) return {'success': true};
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return asJsonMap(decoded);
      return {'success': true, 'data': decoded};
    }

    String message = 'Request failed (${response.statusCode})';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['message'] != null) {
        message = decoded['message'].toString();
      }
    } catch (_) {}
    lastError = message;
    debugPrint('[Kozzy API] $endpoint ${response.statusCode}: $message');
    throw Exception(message);
  }

  String _friendlyError(Object e, String endpoint) {
    final text = e.toString();
    if (text.contains('Failed to fetch') ||
        text.contains('XMLHttpRequest') ||
        text.contains('ClientException') ||
        text.contains('NetworkError')) {
      return 'Cannot reach ${AppConstants.backendUrl}$endpoint. Check internet or CORS for this origin.';
    }
    if (text.startsWith('Exception: ')) return text.substring(11);
    return text;
  }
}
