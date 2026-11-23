import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Error legible que devuelve el cliente cuando algo falla (red o servidor).
/// [code] coincide con el `error_code` del backend (ej. ERR_FORBIDDEN_TRUCK).
class ApiException implements Exception {
  final int? statusCode;
  final String code;
  final String message;

  ApiException(this.message, {this.statusCode, this.code = 'ERR_UNKNOWN'});

  @override
  String toString() => message;
}

/// Cliente único para hablar con el backend de TravelCC.
/// Agrega solo el token de Supabase del usuario logueado a cada petición.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const _timeout = Duration(seconds: 15);

  Map<String, String> get _headers {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  /// GET. Ejemplo: `await ApiClient.instance.get('/me')`
  Future<Map<String, dynamic>> get(String path) {
    return _send(() => http.get(_uri(path), headers: _headers));
  }

  /// POST con cuerpo JSON. Ejemplo: `post('/routes/plan', {...})`
  Future<Map<String, dynamic>> post(String path, Object body) {
    return _send(
      () => http.post(_uri(path), headers: _headers, body: jsonEncode(body)),
    );
  }

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      final res = await request().timeout(_timeout);

      final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : null;
      final json = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

      if (res.statusCode >= 400) {
        throw ApiException(
          json['message']?.toString() ?? 'Error del servidor (${res.statusCode})',
          statusCode: res.statusCode,
          code: json['error_code']?.toString() ?? 'ERR_UNKNOWN',
        );
      }

      return json;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(
        'El servidor tardó demasiado en responder',
        code: 'ERR_TIMEOUT',
      );
    } on SocketException {
      throw ApiException(
        'No se pudo conectar con el servidor',
        code: 'ERR_NO_CONNECTION',
      );
    } on http.ClientException {
      throw ApiException(
        'No se pudo conectar con el servidor',
        code: 'ERR_NO_CONNECTION',
      );
    } on FormatException {
      throw ApiException(
        'Respuesta inválida del servidor',
        code: 'ERR_BAD_RESPONSE',
      );
    }
  }
}
