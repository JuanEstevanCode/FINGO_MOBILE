import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://fingo-backend-eag1.onrender.com',
);

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final _storage = const FlutterSecureStorage();
  String? _token;
  String? get token => _token;

  Future<void> loadToken() async => _token = await _storage.read(key: 'fingo_access_token');

  Future<void> saveToken(String token) async {
    _token = token;
    await _storage.write(key: 'fingo_access_token', value: token);
  }

  Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: 'fingo_access_token');
  }

  Future<void> saveProfile({required String name, required String email, required String birthDate}) async {
    await _storage.write(key: 'fingo_profile_name', value: name);
    await _storage.write(key: 'fingo_profile_email', value: email);
    await _storage.write(key: 'fingo_profile_birth_date', value: birthDate);
  }

  Future<void> saveLoginEmail(String email) async {
    final existingEmail = await _storage.read(key: 'fingo_profile_email');
    if (existingEmail?.toLowerCase() != email.toLowerCase()) {
      await _storage.delete(key: 'fingo_profile_name');
      await _storage.delete(key: 'fingo_profile_birth_date');
    }
    await _storage.write(key: 'fingo_profile_email', value: email);
  }

  Future<Map<String, String?>> readProfile() async => {
        'name': await _storage.read(key: 'fingo_profile_name'),
        'email': await _storage.read(key: 'fingo_profile_email'),
        'birthDate': await _storage.read(key: 'fingo_profile_birth_date'),
      };

  Future<void> clearSession() async {
    await clearToken();
    await _storage.delete(key: 'fingo_profile_name');
    await _storage.delete(key: 'fingo_profile_email');
    await _storage.delete(key: 'fingo_profile_birth_date');
  }

  Future<dynamic> request(String method, String path, {
    Map<String, String>? query,
    Object? body,
    bool authenticated = true,
  }) async {
    final uri = Uri.parse('$apiBaseUrl$path').replace(queryParameters: query);
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (authenticated && _token != null) headers['Authorization'] = 'Bearer $_token';
    final encoded = body == null ? null : jsonEncode(body);

    try {
      late http.Response response;
      switch (method) {
        case 'GET': response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 25));
        case 'POST': response = await http.post(uri, headers: headers, body: encoded).timeout(const Duration(seconds: 25));
        case 'PUT': response = await http.put(uri, headers: headers, body: encoded).timeout(const Duration(seconds: 25));
        case 'PATCH': response = await http.patch(uri, headers: headers, body: encoded).timeout(const Duration(seconds: 25));
        case 'DELETE': response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 25));
        default: throw ArgumentError('Método no soportado: $method');
      }
      if (response.statusCode == 204 || response.body.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) return null;
      }
      dynamic data;
      try { data = jsonDecode(response.body); } catch (_) { data = null; }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (response.statusCode == 401) await clearToken();
        final detail = data is Map ? data['detail'] : null;
        throw ApiException(response.statusCode, _errorMessage(response.statusCode, detail));
      }
      return data;
    } on ApiException { rethrow; } on Exception catch (error) {
      throw ApiException(0, error is http.ClientException ? 'No fue posible conectar con el servidor.' : 'La solicitud falló. Revisa tu conexión e inténtalo de nuevo.');
    }
  }

  String _errorMessage(int code, dynamic detail) {
    final fallback = switch (code) { 401 => 'Sesión vencida. Inicia sesión nuevamente.', 404 => 'No se encontró el recurso solicitado.', 409 => 'El recurso entra en conflicto con uno existente.', 422 => 'Revisa los datos ingresados.', _ => 'Error del servidor ($code).' };
    if (detail is String && detail.isNotEmpty) return detail;
    if (detail is List && detail.isNotEmpty) return fallback;
    return fallback;
  }
}
